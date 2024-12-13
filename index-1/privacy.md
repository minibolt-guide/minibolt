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

# 1.6 Privacy

We configure Tor and I2P to run your node anonymously.

<figure><img src="../.gitbook/assets/privacy.jpg" alt="" width="375"><figcaption></figcaption></figure>

Running your own Bitcoin and Lightning node at home makes you a direct, sovereign peer on the Bitcoin network. However, if not configured without privacy in mind, it also tells the world that there is someone with Bitcoin at that address.

We'll also make it easy to connect to your node from outside your home network as an added benefit.

True, it's only your IP address that is revealed, but using services like [iplocation.net](https://www.iplocation.net), your physical address can be determined quite accurately. Especially with Lightning, your IP address would be widely used. We need to make sure that you keep your privacy.

## Tor Project

<div align="left"><img src="../images/tor-logo.png" alt="" width="166"></div>

We use Tor, a free software built by the [Tor Project](https://www.torproject.org). It allows you to anonymize internet traffic by routing it through a network of nodes, hiding your location and usage profile.

It is called "Tor" for "The Onion Router": information is routed through many hops and encrypted multiple times. Each node decrypts only the layer of information addressed to it, learning only the previous and the next hop of the whole route. The data package is peeled like an onion until it reaches the final destination.

### **Tor installation**

* With user `admin`, update and upgrade the packages to keep up to date with the OS

```bash
sudo apt update && sudo apt full-upgrade
```

* Install dependency. Press "**y**" and `enter` or directly `enter` when the prompt asks you

```sh
sudo apt install apt-transport-https
```

* Create a new file called `tor.list`

```sh
sudo nano /etc/apt/sources.list.d/tor.list
```

* Add the following entries. Save and exit

```
deb     [arch=amd64 signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org jammy main
deb-src [arch=amd64 signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org jammy main
```

* Up to `"root"` user temporarily

```sh
sudo su
```

* Add the GPG key used to sign the packages by running the following command at your command prompt

{% code overflow="wrap" %}
```sh
wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null
```
{% endcode %}

* Return to `admin` using `exit` command

```bash
exit
```

* Update the apt repository, and install Tor and Tor Debian keyring. Press "**y**" and `enter` or directly `enter` when the prompt asks you

```sh
sudo apt update && sudo apt install tor deb.torproject.org-keyring
```

* Check Tor has been correctly installed

```sh
tor --version
```

**Example** of expected output:

```
Tor version 0.4.7.13.
[...]
```

{% hint style="info" %}
Please note that the before version number might change in your case, this is just an example of when the guide was made
{% endhint %}

### **Tor configuration**

Bitcoin Core will communicate directly with the Tor daemon to route all traffic through the Tor network. We need to enable Tor to accept instructions through its control port, with the proper authentication.

* Edit the Tor configuration

```sh
sudo nano +56 -l /etc/tor/torrc
```

* Uncomment **line 56** to enable the control port by deleting `#` at the beginning of the line. Save and exit

```
ControlPort 9051
```

* Reload the Tor configuration to activate the modifications

```sh
sudo systemctl reload tor
```

* Ensure that the Tor service is working and listening at the default ports `9050` and `9051` on the localhost (127.0.0.1)

```sh
sudo ss -tulpn | grep tor
```

<details>

<summary>Expected output ⬇️</summary>

```
tcp     LISTEN 0    4096     127.0.0.1:9050   0.0.0.0:*    users:(("tor",pid=795,fd=6))
tcp     LISTEN 0    4096     127.0.0.1:9051   0.0.0.0:*    users:(("tor",pid=795,fd=7))
```

</details>

* **(Optional)** Check the systemd journal to see Tor in real time updates output logs. Ctrl + C to exit

```sh
journalctl -fu tor@default --since='1 hour ago'
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
Dec 11 10:47:04 minibolt Tor[1065]: Tor 0.4.7.11 running on Linux with Libevent 2.1.12-stable, OpenSSL 3.0.2, Zlib 1.2.11, Liblzma 5.2.5, Libzstd 1.4.8 and Glibc 2.35 as libc.
Dec 11 10:47:04 minibolt Tor[1065]: Tor can't help you if you use it wrong! Learn how to be safe at https://support.torproject.org/faq/staying-anonymous/
Dec 11 10:47:04 minibolt Tor[1065]: Read configuration file "/usr/share/tor/tor-service-defaults-torrc".
Dec 11 10:47:04 minibolt Tor[1065]: Read configuration file "/etc/tor/torrc".
Dec 11 10:47:04 minibolt Tor[1065]: Based on detected system memory, MaxMemInQueues is set to 2751 MB. You can override this by setting MaxMemInQueues by hand.
Dec 11 10:47:04 minibolt Tor[1065]: Opening Socks listener on 127.0.0.1:9050
Dec 11 10:47:04 minibolt Tor[1065]: Opened Socks listener connection (ready) on 127.0.0.1:9050
Dec 11 10:47:04 minibolt Tor[1065]: Opening Control listener on 127.0.0.1:9051
Dec 11 10:47:04 minibolt Tor[1065]: Opened Control listener connection (ready) on 127.0.0.1:9051
[...]
Dec 11 10:47:36 minibolt Tor[1065]: Bootstrapped 75% (enough_dirinfo): Loaded enough directory info to build circuits
Dec 11 10:47:37 minibolt Tor[1065]: Bootstrapped 89% (ap_handshake): Finishing handshake with a relay to build circuits
Dec 11 10:47:37 minibolt Tor[1065]: Bootstrapped 90% (ap_handshake_done): Handshake finished with a relay to build circuits
Dec 11 10:47:37 minibolt Tor[1065]: Bootstrapped 95% (circuit_create): Establishing a Tor circuit
Dec 11 10:47:37 minibolt Tor[1065]: Bootstrapped 100% (done): Done
Nov 13 23:19:20 minibolt systemd[1]: Reloading tor@default.service - Anonymizing overlay network for TCP...
Nov 13 23:19:20 minibolt Tor[27155]: Received reload signal (hup). Reloading config and resetting internal state.
Nov 13 23:19:20 minibolt Tor[27155]: Read configuration file "/usr/share/tor/tor-service-defaults-torrc".
Nov 13 23:19:20 minibolt Tor[27155]: Read configuration file "/etc/tor/torrc".
Nov 13 23:19:20 minibolt Tor[27155]: Opening Control listener on 127.0.0.1:9051
Nov 13 23:19:20 minibolt Tor[27155]: Opened Control listener connection (ready) on 127.0.0.1:9051
Nov 13 23:19:20 minibolt systemd[1]: Reloaded tor@default.service - Anonymizing overlay network for TCP.

```

</details>

{% hint style="info" %}
Not all network traffic is routed over the Tor network, by default some services don't include a proxy SOCKS5 configuration. Anyway, we now have the base to configure sensitive applications to use it
{% endhint %}

{% hint style="info" %}
**(Optional)** -> If you want, you can **disable the autoboot** option for Tor using:

<pre class="language-bash"><code class="lang-bash"><strong>sudo systemctl disable tor
</strong></code></pre>

**Expected output:**

```
Synchronizing state of tor.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install disable tor
Removed /etc/systemd/system/multi-user.target.wants/tor.service.
```
{% endhint %}

{% hint style="info" %}
-> If you want to **avoid your ISP knowing you are using Tor**, follow the [**Add obfs4 bridge to the default Tor instance**](../bonus-guides/system/tor-services.md#add-obfs4-bridge-to-the-default-tor-instance) section on the Tor services bonus guide to use ofbs4 bridges

-> You can host [**your Tor obfs4 bridge**](../bonus-guides/system/tor-services.md#obsf4-bridge) or connect to an external one as mentioned before
{% endhint %}

## I2P Project

<div align="left"><img src="../images/i2pd.png" alt="" width="150"></div>

[I2P](https://geti2p.net/en/) is a universal anonymous network layer. All communications over I2P are anonymous and end-to-end encrypted, participants don't reveal their real IP addresses. I2P allows people from all around the world to communicate and share information without restrictions.

I2P client is software used for building and using anonymous I2P networks. Such networks are commonly used for anonymous peer-to-peer applications (filesharing, cryptocurrencies) and anonymous client-server applications (websites, instant messengers, chat-servers).

We are to use [i2pd](https://i2pd.readthedocs.io/en/latest/) (I2P Daemon), a full-featured C++ implementation of the I2P client, as a Tor network complement.

### **I2P installation**

* Ensure that you are logged in with the user `admin` and add the i2pd repository

```sh
wget -q -O - https://repo.i2pd.xyz/.help/add_repo | sudo bash -s -
```

Expected output:

```
Importing signing key
Adding APT repository
```

* Update the apt repository and install i2pd as any other software package. Press "**y**" and `enter` or directly `enter` when the prompt asks you

```sh
sudo apt update && sudo apt install i2pd
```

* Check that i2pd has been correctly installed

```sh
i2pd --version
```

**Example** of expected output:

<pre><code><strong>i2pd version 2.44.0 (0.9.56)
</strong>[...]
</code></pre>

* Ensure that the i2pd service is working and listening at the default ports

```sh
sudo ss -tulpn | grep i2pd
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
udp   UNCONN 0      0              127.0.0.1:7655       0.0.0.0:*    users:(("i2pd",pid=1305094,fd=45))
udp   UNCONN 0      0                0.0.0.0:20003      0.0.0.0:*    users:(("i2pd",pid=1305094,fd=21))
tcp   LISTEN 0      4096             0.0.0.0:20003      0.0.0.0:*    users:(("i2pd",pid=1305094,fd=20))
tcp   LISTEN 0      4096           127.0.0.1:7656       0.0.0.0:*    users:(("i2pd",pid=1305094,fd=44))
tcp   LISTEN 0      4096           127.0.0.1:6668       0.0.0.0:*    users:(("i2pd",pid=1305094,fd=40))
tcp   LISTEN 0      4096           127.0.0.1:7070       0.0.0.0:*    users:(("i2pd",pid=1305094,fd=25))
tcp   LISTEN 0      4096           127.0.0.1:4444       0.0.0.0:*    users:(("i2pd",pid=1305094,fd=35))
tcp   LISTEN 0      4096           127.0.0.1:4447       0.0.0.0:*    users:(("i2pd",pid=1305094,fd=36))
```

</details>

* See “i2p” in action by monitoring its log file. Exit with Ctrl-C

```sh
sudo tail -f /var/log/i2pd/i2pd.log
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
11:52:56@883/none - i2pd v2.44.0 (0.9.56) starting...
11:52:57@444/warn - Transports: 15 ephemeral keys generated at the time
11:52:57@883/warn - Addressbook: subscriptions.txt usage is deprecated, use config file instead
11:52:58@783/warn - SSU2: Peer test 4 router not found
11:52:58@783/warn - SSU2: Peer test 4 router not found
11:53:02@783/warn - SSU2: Session with 81.155.117.241:24027 was not established after 5 seconds
11:53:02@783/warn - SSU2: Session with 82.48.155.160:20423 was not established after 5 seconds
11:53:02@783/warn - SSU2: Session with 81.107.248.153:24716 was not established after 5 seconds
11:53:02@783/warn - SSU2: Session with 188.127.17.98:39249 was not established after 5 seconds
11:53:02@553/warn - NTCP2: SessionCreated read error: End of file
```

</details>

{% hint style="info" %}
**(Optional)** -> If you want, you can **disable the autoboot** option for I2P using:

```bash
sudo systemctl disable i2pd
```

**Expected output:**

```
Synchronizing state of i2pd.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install disable i2pd
Removed /etc/systemd/system/multi-user.target.wants/i2pd.service.
```
{% endhint %}

## Extras (optional)

### Access to the i2pd webconsole

I2P by default creates an HTTP web service that makes it easy to view node statistics such as tunnels, bandwidth, active connections, and network configuration. If you want to use that the only one have to do is secure the connection, configure the auth method, reverse proxy, and open the UFW. Follow the next steps

{% hint style="info" %}
Realize that if you modify the config file, you will need to select "Keep" or reconfigure the i2p config file again when the prompt asks you in the next update process
{% endhint %}

* With user `admin`, create the reverse proxy configuration

```bash
sudo nano /etc/nginx/sites-available/i2pd-webconsole-reverse-proxy.conf
```

* Paste the complete following configuration. Save and exit

```nginx
server {
  listen 7071 ssl;
  error_page 497 =301 https://$host:$server_port$request_uri;
  location / {
    proxy_pass http://127.0.0.1:7070;
  }
}
```

* Create the symbolic link that points to the directory `sites-enabled`

{% code overflow="wrap" %}
```bash
sudo ln -s /etc/nginx/sites-available/i2pd-webconsole-reverse-proxy.conf /etc/nginx/sites-enabled/
```
{% endcode %}

* Test Nginx configuration

```sh
sudo nginx -t
```

Expected output:

```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

* Reload the Nginx configuration to apply changes

```sh
sudo systemctl reload nginx
```

* Configure the firewall to allow incoming HTTPS requests

```bash
sudo ufw allow 7071/tcp comment 'allow i2pd webconsole SSL from anywhere'
```

* Enable i2pd webconsole authentication

```bash
sudo nano +130 -l /etc/i2pd/i2pd.conf
```

* Uncomment (delete "#" at the first of the lines) and replace "`changeme`" with your "`[ F ] i2pd webconsole password`". Save and exit

```
auth = true
user = i2pd
pass = [ F ] i2pd webconsole password
```

* Restart i2pd to apply changes

```bash
sudo systemctl restart i2pd
```

#### Validation

* Ensure that the i2pd service is working and listening at the webconsole HTTP & HTTPS ports

```bash
sudo ss -tulpn | grep -E '(:7070|:7071)'
```

Expected output:

```
tcp   LISTEN 0      511          0.0.0.0:7071       0.0.0.0:*    users:(("nginx",pid=916,fd=4),("nginx",pid=915,fd=4),("nginx",pid=914,fd=4),("nginx",pid=913,fd=4),("nginx",pid=912,fd=4))
tcp   LISTEN 0      4096       127.0.0.1:7070       0.0.0.0:*    users:(("i2pd",pid=566214,fd=25))
```

{% hint style="info" %}
Now point your browser to the secure access point provided by the NGINX web proxy, for example, `"https://ramix.local:7071"` (or your node IP address) like `"https://192.168.x.xxx:7071"`. Type the before credentials configurated (`user: i2pd; password: [ F ] i2pd webconsole password`). After that, you should see something similar to the next screenshot

This access is only available from the local network, no Tor or Wireguard VPN is allowed
{% endhint %}

<figure><img src="../.gitbook/assets/i2pd_webconsole.png" alt="" width="563"><figcaption></figcaption></figure>

### **SSH remote access through Tor**

If you want to log into your MiniBolt with SSH when you're away, you can easily do so by adding a Tor hidden service. This makes "calling home" very easy, without the need to configure anything on your internet router.

#### **SSH server**

* Ensure that you are logged in with the user `admin` , edit the `torrc` file

```sh
sudo nano +63 /etc/tor/torrc
```

* Add the following lines in the "location hidden services" section, below "`## This section is just for location-hidden services ##`" in the torrc file. Save and exit

```
# Hidden Service SSH server
HiddenServiceDir /var/lib/tor/hidden_service_ssh_server/
HiddenServiceVersion 3
HiddenServicePoWDefensesEnabled 1
HiddenServicePort 22 127.0.0.1:22
```

* Reload the Tor configuration to apply the configuration

```sh
sudo systemctl reload tor
```

* Get the SSH Onion address

```sh
sudo cat /var/lib/tor/hidden_service_ssh_server/hostname
```

**Example** of expected output:

```
> abcdefg..............xyz.onion
```

* Save the Tor address in a secure location, e.g. your password manager

#### **SSH client**

You also need to have Tor installed on your regular computer where you start the SSH connection. Usage of SSH over Tor differs by client and operating system.

* **Windows**:

To enable Tor in the background follow the same instructions for the [preparations](../bitcoin/bitcoin/desktop-signing-app-sparrow.md#preparations-on-your-computer) section of the Desktop Wallet guide.

* PuTTy:
  * Follow the same instructions of the [remote access section](remote-access.md#access-with-secure-shell) for Putty, but this time type the `.onion` address on the hostname.
    * Go to the "Connection" tab -> Proxy, select "Socks5" as proxy type, on Proxy hostname, type "localhost", port "9050".
    * Press the button OPEN, when a "PuTTy security alert" banner appears, and press on the "Accept" button, if the prompt asks you user/password, leave it empty and press ENTER directly, and finally type your `password [A]`.
* MobaXterm:
  * Follow the same instructions of the [remote access section](remote-access.md#access-with-secure-shell) for MobaXterm, but this time type the `.onion` address on the hostname.
  * Go to the "Network settings" tab, select Proxy type "Socks5" on the host, type "localhost", for login, left empty, port "9050".
  * Press the button OK, when a "Connexion to..." banner appears press the "Accept" button, if the prompt asks you user/password, leave it empty and press ENTER directly, and finally type your `password [A]`.

{% hint style="info" %}
If you are using PuTTy and fail to connect to your PC by setting port 9050 in the PuTTy proxy settings, try setting port 9150 instead. When Tor runs as an installed application instead of a background process it uses port 9150
{% endhint %}

* **Linux**:
  * Use `torify` or `torsocks`, both work similarly; just use whatever you have available

```bash
torify ssh admin@abcdefg..............xyz.onion
```

```bash
torsocks ssh admin@abcdefg..............xyz.onion
```

{% hint style="info" %}
When the prompt asks you "Are you sure you want to continue connecting?" type "yes" and press ENTER
{% endhint %}

* **macOS**: Using `torify` or `torsocks` may not work due to Apple's _System Integrity Protection (SIP)_ which will deny access to `/usr/bin/ssh`.

To work around this, first, make sure Tor is installed and running on your Mac:

```sh
brew install tor && brew services start tor
```

You can SSH to your PC "out of the box" with the following proxy command:

{% code overflow="wrap" %}
```bash
ssh -o "ProxyCommand nc -X 5 -x 127.0.0.1:9050 %h %p" admin@abcdefg..............xyz.onion
```
{% endcode %}

* For a more permanent solution, add these six lines below to your local SSH config file. Choose any HOSTNICKNAME you want, save, and exit

```bash
sudo nano .ssh/config
```

```
Host HOSTNICKNAME
  Hostname abcdefg..............xyz.onion
  User admin
  Port 22
  CheckHostIP no
  ProxyCommand /usr/bin/nc -x localhost:9050 %h %p
```

* Restart Tor

```bash
brew services restart tor
```

* You should now be able to SSH to your PC with

```bash
ssh HOSTNICKNAME
```

### **Use the Tor proxy from another device**

It's possible to use the Tor proxy of the node from another device in the same local network (e.g your regular computer)

* With `admin` user, edit the torrc file

```bash
sudo nano +18 /etc/tor/torrc -l
```

* Replace the existing line 18 to this

```
SocksPort 0.0.0.0:9050
```

* Add down the next line (on line 19). Save and exit

```
SocksPort unix:/run/tor/socks WorldWritable
```

* Reload the Tor configuration to apply changes

```bash
sudo systemctl reload tor
```

* Configure the firewall to allow incoming Tor connections from anywhere

```bash
sudo ufw allow 9050/tcp comment 'allow Tor socks5 from anywhere'
```

* Ensure that the Tor service is working and listening at the default ports `9050` on the `0.0.0.0`

```bash
sudo ss -tulpn | grep tor
```

Expected output:

<pre><code>tcp   LISTEN 0      4096        <a data-footnote-ref href="#user-content-fn-1">0.0.0.0</a>:9050       0.0.0.0:*    users:(("tor",pid=2162,fd=6))
tcp   LISTEN 0      4096       127.0.0.1:9051       0.0.0.0:*    users:(("tor",pid=2162,fd=7))
</code></pre>

{% hint style="info" %}
You can use this connection from another device in the same local network for example to navigate using a standard browser, without using the Tor browser
{% endhint %}

#### **Example from Firefox:**

-> Go to Settings > General > Network Settings > Push to the "Settings" button

Edit the screen to match with this, replacing `SOCKS Host`, with your node's local IP address:

<figure><img src="../.gitbook/assets/tor-proxy-browser.png" alt="" width="563"><figcaption></figcaption></figure>

-> Click on the **OK** button, and try to navigate to some clearnet domain like [https://minibolt.info](https://minibolt.info), if it resolves, you are OK.

{% hint style="info" %}
You can also go to this [website](https://check.torproject.org/) and see "_Congratulations. This browser is configured to use Tor."_

Also, you can use the Tor proxy connection to reach clearnet or third-party address connection on Sparrow wallet. Check out the [Desktop signing app: Sparrow Wallet](../bitcoin/bitcoin/desktop-signing-app-sparrow.md) guide to get instructions.
{% endhint %}

## Upgrade Tor and I2P

The latest release can be found on the [official Tor web page](https://gitweb.torproject.org/tor.git/plain/ChangeLog) or the [unofficial GitHub page](https://github.com/torproject/tor/tags) and for I2P on the [PPA page](https://launchpad.net/~purplei2p/+archive/ubuntu/i2pd). To upgrade type this command:

```sh
sudo apt update && sudo apt upgrade
```

{% hint style="info" %}
If during the I2P update the prompts show you the next:

```
apt-listchanges: News
---------------------

i2pd (2.53.0-1) unstable; urgency=medium

  i2pd binary moved from /usr/sbin to /usr/bin. Please check your scripts if you used the old path.

 -- r4sas <r4sas@i2pmail.org>  Fri, 19 Jul 2024 16:00:00 +0000
```

Simply press `Ctrl + X` and then the update will continue
{% endhint %}

## Uninstall

### Uninstall Tor

* With user `admin`, enter the next command. Press "**y**" and `enter` or directly `enter` when the prompt asks you

```bash
sudo apt autoremove tor deb.torproject.org-keyring && sudo apt purge tor
```

Expected output:

```
[...]
The following packages will be REMOVED:
  deb.torproject.org-keyring tor tor-geoipdb torsocks
[...]
```

### Uninstall I2P

* With user `admin`, enter the next command. Press "**y**" and `enter` or directly `enter` when the prompt asks you

```bash
sudo apt autoremove i2pd && sudo apt purge i2pd
```

Expected output:

```
[...]
The following packages will be REMOVED:
  i2pd libminiupnpc17
[...]
```

## **Troubleshooting**

### **Tor troubleshooting**

#### **Tor network issues**

If you have problems with the Tor connection (LN channels offline, excessive delay to the hidden services access, etc...), it is possible that the set of entry guards is overloaded, delete the file called "state" in your Tor directory, and you will be forcing Tor to select an entirely new set of entry guards next time it starts.

* Stop Tor

```sh
sudo systemctl stop tor
```

* Delete the file called "`state`" in your Tor directory

```sh
sudo rm /var/lib/tor/state
```

* Start Tor again

```sh
sudo systemctl start tor
```

{% hint style="info" %}
-> If your new set of entry guards still produces the stream error, try connecting to the internet using a cable if you're using Wireless. If that doesn't help, I'd suggest downloading [Wireshark](https://www.wireshark.org/) and seeing if you're getting drowned in TCP transmission errors for non-Tor traffic. If yes, your ISP is who you need to talk to

-> If not, try using [obfs4 bridges](../bonus-guides/system/tor-services.md#add-obfs4-bridge-to-the-default-tor-instance) and see if that helps. Your ISP, the company's network, your country, etc, could be censoring completely your Tor access, use of obfs4 bridges could help to avoid this censorship
{% endhint %}

**Example** of Tor censorship output:

![](../images/tor-censorship.png)

#### Tor signature verification error

If you obtain this error [after updating](privacy.md#upgrade-tor-and-i2p) the repositories using the apt package manager:

<figure><img src="../.gitbook/assets/tor_keyring_error.png" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
This means Tor has renovated the signature due probably that is soon to expiry or expired, follow the next steps to fix that ⬇️
{% endhint %}

* With user `admin`, up to `"root"` user temporarily

```sh
sudo su
```

* Add the GPG key used to sign the packages by running the following command at your command prompt

{% code overflow="wrap" %}
```sh
wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null
```
{% endcode %}

* Return to `admin` using `exit` command

```bash
exit
```

{% hint style="info" %}
Try to do `sudo apt update` again and see the error doesn't appear
{% endhint %}

### **I2P troubleshooting**

If you see these output logs on Bitcoin Core, normally, it could be that I2P is failing:

![](../images/i2p-troubleshoting.png)

{% hint style="info" %}
If this happens, usually this fix only with **restarting** the i2pd service
{% endhint %}

* With user `admin`, restart the service

```sh
sudo systemctl restart i2pd
```

* Check again the Bitcoin Core logs to ensure that the errors don't appear anymore

## Port reference

| Port | Protocol |             Use            |
| :--: | :------: | :------------------------: |
| 9050 |    TCP   |     Default SOCKS port     |
| 9051 |    TCP   |    Default control port    |
| 7656 |    TCP   | Default I2P SAM proxy port |

[^1]: Check this
