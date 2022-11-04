---
layout: default
title: Security
nav_order: 40
parent: System
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->

{% include include_metatags.md %}

# Security

{: .no_toc }

---

We make sure that your MiniBolt is secured against unauthorized remote access.

Status: Tested MiniBolt
{: .label .label-blue }

---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

The MiniBolt will be visible from the internet and therefore needs to be secured against online attacks using various methods.

## Login with SSH keys (optional)

One of the best options to secure the sensitive SSH login is to disable passwords altogether and require an SSH key certificate.
Only someone with physical possession of the private certificate key can log in.

### Generate SSH keys on Windows

Follow this guide [Configure “No Password SSH Keys Authentication” with PuTTY on Linux Servers](https://www.tecmint.com/ssh-passwordless-login-with-putty/){:target="_blank"}

* You have now generated three new files.
  Keep them safe!

  * `MiniBolt-Private-Key.ppk`
  * `MiniBolt-Public-Key`
  * `authorized-Keys.txt`

* You also copied the content of `authorized-Keys.txt` into the file `~/.ssh/authorized_keys` on your PC and changed the directory's permissions to `700`.

* After specifying your private key file in the PuTTY configuration, you're all set.

### Generate SSH keys on macOS or Linux

* In the terminal on your regular computer, check if keys already exist:

  ```sh
  $ ls -la ~/.ssh/*.pub
  ```

* If files are listed, your public key should be named something like `id_dsa.pub`, `id_ecdsa.pub`, `id_ed25519.pub` or `id_rsa.pub`.
   If one of these files already exists, skip the next step.

* If none of those files exist, or you get a "No such file or directory" error, create a new public / private key pair:

  ```sh
  $ ssh-keygen -t rsa -b 4096
  ```

  When you're prompted to "Enter a file in which to save the key," press Enter to use the default file location.
  Optionally, for maximum security, use `password [A]` to protect your key.

* The public key now needs to be copied to the PC.
  Use the command `ssh-copy-id`, which stores your public key on the remote machine (and creates files and directories, if needed).
  You will be prompted for your SSH login password once.

  ```sh
  $ ssh-copy-id admin@minibolt.local
  ```

💡 If you are on macOS and encounter an error, you might need install `ssh-copy-id` first by running the following command on your Mac's command line:

* ```sh
  $ brew install ssh-copy-id
  ```

### Disable password login (only if you chose SSH keys method)

* Log in to the PC as "admin" using SSH with your SSH key.
  You shouldn't be prompted for the admin's password anymore.

* Edit the ssh configuration file `/etc/ssh/sshd_config` by uncommenting the following two options and setting their value to `no`.

  ```sh
  $ sudo nano /etc/ssh/sshd_config
  ```

  ```sh
  PasswordAuthentication no
  ChallengeResponseAuthentication no
  ```

* Restart the SSH daemon, then exit your session

  ```sh
  $ sudo systemctl restart sshd
  $ exit
  ```

* Log in again with user "admin"

You can no longer log in with a password.
User "admin" is the only user that has the necessary SSH keys, no other user can log in remotely.

🚨 **Backup your SSH keys!**
You will need to attach a screen and keyboard to your PC if you lose them.

## Enabling the Uncomplicated Firewall

A firewall controls what kind of outside traffic your machine accepts and which applications can send data out.
By default, many network ports are open and listening for incoming connections.
Closing unnecessary ports can mitigate many potential system vulnerabilities.

For now, only SSH should be reachable from the outside.
Bitcoin Core and LND are using Tor and don't need incoming ports.
We'll open the port for Electrs and web applications later if needed.

* With user "admin", configure and enable the firewall rules, when the prompt ask you `Command may disrupt existing ssh connections. Proceed with operation (y|n)?` type `y` key and enter

  ```sh
  $ sudo ufw default deny incoming
  $ sudo ufw default allow outgoing
  $ sudo ufw allow from 192.168.0.0/16 to any port 22 proto tcp comment 'allow SSH from local network'
  $ sudo ufw logging off
  $ sudo ufw enable
  ```

Expected output:

  ```sh
  > Firewall is active and enabled on system startup
  ```

* Check if the UFW is properly configured and active

  ```sh
  $ sudo ufw status verbose
  > Status: active
  > Logging: off
  > Default: deny (incoming), allow (outgoing), disabled (routed)
  > New profiles: skip

  >
  > To                            Action      From
  > --                            ------      ----
  > 22                            ALLOW       192.168.0.0/16       # allow SSH from local network
  ```

🔍 *more: [UFW Essentials](https://www.digitalocean.com/community/tutorials/ufw-essentials-common-firewall-rules-and-commands){:target="_blank"}*

💡 If you find yourself locked out by mistake, you can connect a keyboard and screen to your PC to log in locally and fix these settings (especially for the SSH port 22).

## Increase your open files limit

If your MiniBolt is swamped with internet requests (honest or malicious due to a DoS attack), you will quickly encounter the "can't accept connection: too many open files" error.
This is due to the limit of open files (representing individual TCP connections) set too low.

Create the file `/etc/security/limits.d/90-limits.conf`, copy these lines into it, save and exit.

```sh
$ sudo nano /etc/security/limits.d/90-limits.conf

*    soft nofile 128000
*    hard nofile 128000
root soft nofile 128000
root hard nofile 128000
```

Edit both of the following two files, add the additional line(s) right before the end comment, save and exit.

```sh
$ sudo nano /etc/pam.d/common-session
session required                        pam_limits.so
```

```sh
$ sudo nano /etc/pam.d/common-session-noninteractive
session required                        pam_limits.so
```

## Monitoring SSH authentication logs

* You can monitor authentication general logs in your system in real-time

  ```sh
  $ sudo tail -f /var/log/auth.log
  ```

* Or filtering only by ssh authentication logs in the last 500 lines

  ```sh
  $ sudo tail --lines 500 /var/log/auth.log | grep sshd
  ```

* Discarding your own connections from your regular computer in local network

  ```sh
  $ sudo tail --lines 500 /var/log/auth.log | grep sshd | grep -v 192.168.X.XXX
  ```

In this way, you can detect a possible brute-force attack and take appropriate mitigation measures.

💡 Do this regularly to get security-related incidents.

## Prepare NGINX reverse proxy

Several components of this guide will expose a communication port, for example the Electrum server, the Block Explorer, or the "Ride The Lightning" web interface for your Lightning node.
Even if you use these services only within your own home network, communication should always be encrypted.
Otherwise, any device in the same network can listen to the exchanged data, including passwords.

We use NGINX to encrypt the communication with SSL/TLS (Transport Layer Security).
This setup is called a "reverse proxy": NGINX provides secure communication to the outside and routes the traffic back to the internal service without encryption.

💡 _Hint: NGINX is pronounced "Engine X"_ ;)

* Install NGINX

  ```sh
  $ sudo apt install nginx
  ```

* Create a self-signed SSL/TLS certificate (valid for 10 years)

  ```sh
  $ sudo openssl req -x509 -nodes -newkey rsa:4096 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt -subj "/CN=localhost" -days 3650
  ```

* NGINX is also a full webserver.
  To use it only as a reverse proxy, remove the default configuration and paste the following configuration into the `nginx.conf` file.

  ```sh
  $ sudo mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
  $ sudo nano /etc/nginx/nginx.conf
  ```

  ```nginx
  user www-data;
  worker_processes 1;
  pid /run/nginx.pid;
  include /etc/nginx/modules-enabled/*.conf;

  events {
    worker_connections 768;
  }

  stream {
    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;
    ssl_session_cache shared:SSL:1m;
    ssl_session_timeout 4h;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    include /etc/nginx/streams-enabled/*.conf;

  }
  ```

* Create a new directory for future configuration files

  ```sh
  $ sudo mkdir /etc/nginx/streams-enabled
  ```

* Test this barebone NGINX configuration

  ```sh
  $ sudo nginx -t
  > nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
  > nginx: configuration file /etc/nginx/nginx.conf test is successful
  ```

<br /><br />

---

Next: [Privacy >>](privacy.md)
