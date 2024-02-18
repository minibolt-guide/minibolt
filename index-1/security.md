---
layout:
  title:
    visible: true
  description:
    visible: false
  tableOfContents:
    visible: true
  outline:
    visible: true
  pagination:
    visible: true
---

# 1.5 Security

We make sure that your MiniBolt is secured against unauthorized remote access.

The MiniBolt needs to be secured against online attacks using various methods.

<figure><img src="../.gitbook/assets/security.jpg" alt="" width="375"><figcaption></figcaption></figure>

## Uncomplicated Firewall (enable & configure)

A firewall controls what kind of outside traffic your machine accepts and which applications can send data out. By default, many network ports are open and listening for incoming connections. Closing unnecessary ports can mitigate many potential system vulnerabilities.

For now, only SSH should be reachable from the outside. Bitcoin Core and LND are using Tor and don't need incoming ports. We'll open the port for Electrs and web applications later if needed.

### Check IPv6 availability

* With user `admin`, check your IPv6 availability

{% code overflow="wrap" %}
```bash
$ ping6 -c2 2001:858:2:2:aabb:0:563b:1526 && ping6 -c2 2620:13:4000:6000::1000:118 && ping6 -c2 2001:67c:289c::9 && ping6 -c2 2001:678:558:1000::244 && ping6 -c2 2001:638:a000:4140::ffff:189 && echo OK.
```
{% endcode %}

2 options:

1. If you obtain the `"OK."` output, you have IPv6 availability, additionally, you can obtain your IPv6 with: `curl -s ipv6.icanhazip.com` you are OK, continue the guide without modifications
2. If you obtain `ping6: connect: Network is unreachable`, you don't have IPv6 availability, don't worry, the IPv6 adoption is new, you will use your internet connection using the common IPv4, additionally, you can obtain your IPv4 with: `curl -s ipv4.icanhazip.com`

If you don't have IPv6 availability, you can disable IPv6 on UFW to avoid the creation of rules related to it:

* Edit the UFW configuration

```bash
$ sudo nano /etc/default/ufw
```

* Change `IPV6=yes` to `IPV6=no`. Save and exit

```
IPV6=no
```

* Deny incoming connections (we are going to allow incoming connections on demand)

```sh
$ sudo ufw default deny incoming
```

* Allow outgoing connections

```sh
$ sudo ufw default allow outgoing
```

* Allow SSH incoming connection

{% hint style="warning" %}
Attention! Don't forget the next step!
{% endhint %}

```sh
$ sudo ufw allow 22/tcp comment 'allow SSH from anywhere'
```

* Disable logging

```sh
$ sudo ufw logging off
```

* Enable ufw, when the prompt shows you `"Command may disrupt existing ssh connections. Proceed with operation (y|n)?"`, press `"y"` and enter

```sh
$ sudo ufw enable
```

Expected output:

```
> Firewall is active and enabled on system startup
```

* Check if the UFW is properly configured and active

```sh
$ sudo ufw status verbose
```

<details>

<summary>Expected output ⬇️</summary>

```
> Status: active
> Logging: off
> Default: deny (incoming), allow (outgoing), disabled (routed)
> New profiles: skip

>
> To                    Action      From
> --                    ------      ----
> 22                    ALLOW       Anywhere       # allow SSH from anywhere
```

</details>

{% hint style="info" %}
If you find yourself locked out by mistake, you can connect a keyboard and screen to your PC to log in locally and fix these settings (especially for the SSH port 22). More: [UFW Essentials](https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands)
{% endhint %}

### Monitoring SSH authentication logs (optional)

* You can monitor authentication general logs in your system in real-time

```sh
$ sudo tail -f /var/log/auth.log
```

* Or filtering only by SSH authentication logs in the last 500 lines

```sh
$ sudo tail --lines 500 /var/log/auth.log | grep sshd
```

* With this command, you can show a listing of the last satisfactory logged-in users in your MiniBolt since 7 days ago. Change `-7days` option to whatever you want

```sh
$ last -s -7days -t today
```

In this way, you can detect a possible brute-force attack and take appropriate mitigation measures

{% hint style="info" %}
Do this regularly to get security-related incidents
{% endhint %}

## Install Nginx

Several components of this guide will expose a communication port, for example, the Block Explorer, or the ThunderHub web interface for your Lightning node. Even if you use these services only within your own home network, communication should always be encrypted. Otherwise, any device in the same network can listen to the exchanged data, including passwords.

We use Ngnix to encrypt the communication with SSL/TLS (Transport Layer Security). This setup is called a "reverse proxy": Nginx provides secure communication to the outside and routes the traffic back to the internal service without encryption.

* Install Ngnix

```sh
$ sudo apt install nginx
```

* Check the correct installation

```bash
$ nginx -v
```

**Example** of expected output:

```
> nginx version: nginx/1.18.0 (Ubuntu)
```

* Create a self-signed SSL/TLS certificate (valid for 10 years)

{% code overflow="wrap" %}
```bash
$ sudo openssl req -x509 -nodes -newkey rsa:4096 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/CN=localhost" -days 3650
```
{% endcode %}

**Example** of expected output:

```
> .......+......+...+..+....+.....+......++++++........
```

* NGINX is also a full web server. To use it only as a reverse proxy, backup the default configuration

```bash
$ sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
```

* Create a new blank configuration file

```bash
$ sudo nano /etc/nginx/nginx.conf
```

* &#x20;Paste the following configuration into the `nginx.conf` file. Save and exit

```nginx
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
  worker_connections 768;
}

http {
  ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
  ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
  ssl_session_cache shared:HTTP-TLS:1m;
  ssl_session_timeout 4h;
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_prefer_server_ciphers on;
  include /etc/nginx/sites-enabled/*.conf;
}

stream {
  ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
  ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
  ssl_session_cache shared:STREAM-TLS:1m;
  ssl_session_timeout 4h;
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_prefer_server_ciphers on;
  include /etc/nginx/streams-enabled/*.conf;
}
```

* Create the `streams-available` and `streams-enabled` directories for future configuration files

```bash
$ sudo mkdir /etc/nginx/streams-available
```

```sh
$ sudo mkdir /etc/nginx/streams-enabled
```

* Remove the Nginx `site available` and `site enabled` default configuration files

```bash
$ sudo rm /etc/nginx/sites-available/default
```

```sh
$ sudo rm /etc/nginx/sites-enabled/default
```

* Test this barebone Nginx configuration

```sh
$ sudo nginx -t
```

Expected output:

```
> nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
> nginx: configuration file /etc/nginx/nginx.conf test is successful
```

* Reload Nginx to apply the configuration

```sh
$ sudo systemctl reload nginx
```

&#x20;You can monitor the Nginx logs by entering this command. Exit with Ctrl + C

```bash
$ journalctl -f -u nginx
```

Expected output:

<pre><code><strong>> Nov 16 16:56:56 minibolt systemd[1]: Starting A high performance web server and a reverse proxy server...
</strong>> Nov 16 16:56:56 minibolt systemd[1]: Started A high performance web server and a reverse proxy server.
</code></pre>

You can monitor Nginx error logs by entering this command. Exit with Ctrl + C

```bash
$ sudo tail -f /var/log/nginx/error.log
```
