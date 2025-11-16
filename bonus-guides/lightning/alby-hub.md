---
layout:
  width: default
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
  metadata:
    visible: true
---

# Alby Hub

[Alby Hub](https://github.com/getAlby/hub) is a self-custodial, open source Lightning wallet that connects to apps.

<figure><img src="../../.gitbook/assets/albyhub.jpeg" alt=""><figcaption></figcaption></figure>

### Requirements

* Bitcoin Core
* LND

### Preparations

#### Reverse proxy & Firewall

In the security section, we set up Nginx as a reverse proxy. Now we can add the AlbyHub configuration.

Enable the Nginx reverse proxy to route external encrypted HTTPS traffic internally to AlbyHub. The `error_page 497` directive instructs browsers that send HTTP requests to resend them over HTTPS.

* With user `admin`, create the reverse proxy configuration

```sh
sudo nano /etc/nginx/sites-available/albyhub-reverse-proxy.conf
```

* Paste the following complete configuration. Save and exit

```nginx
server {
    listen 3003 ssl;
    error_page 497 =301 https://$host:$server_port$request_uri;	
    
    location / {
        proxy_pass http://127.0.0.1:8090;
    }
}
```

* Create the symbolic link that points to the directory `sites-enabled`

{% code overflow="wrap" %}
```bash
sudo ln -s /etc/nginx/sites-available/albyhub-reverse-proxy.conf /etc/nginx/sites-enabled/
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

* Reload the NGINX configuration to apply changes

```bash
sudo systemctl reload nginx
```

* Configure the firewall to allow incoming HTTP requests from anywhere to the web server

```sh
sudo ufw allow 3003/tcp comment 'allow AlbyHub SSL from anywhere'
```

### Installation

We download the latest Albyhub binary (the application) and verify the download.

#### Download binaries

* Login as `admin` and change to a temporary directory, which is cleared on reboot

```sh
cd /tmp
```

* Set a temporary version environment variable for the installation

```sh
VERSION=1.20.0
```

* Get the latest binaries and signatures

{% code overflow="wrap" %}
```sh
wget https://github.com/getAlby/hub/releases/download/v$VERSION/albyhub-Server-Linux-x86_64.tar.bz2
```
{% endcode %}

```sh
wget https://github.com/getAlby/hub/releases/download/v$VERSION/manifest.txt
```

```sh
wget https://github.com/getAlby/hub/releases/download/v$VERSION/manifest.txt.asc
```

#### Signature check

* Get the public key from the AlbyHub developer

{% code overflow="wrap" %}
```sh
curl https://raw.githubusercontent.com/getalby/hub/master/scripts/keys/rolznz.asc | gpg --import
```
{% endcode %}

Expected output:

```
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  3154  100  3154    0     0   103k      0 --:--:-- --:--:-- --:--:--  106k
gpg: clave A5EABD8835092B08: clave pública "Roland Bewick <roland.bewick@gmail.com>" importada
gpg: Cantidad total procesada: 1
gpg:               importadas: 1
```

* Verify the signature of the text file containing the checksums for the application

```sh
gpg --verify manifest.txt.asc manifest.txt
```

Expected output:

{% code overflow="wrap" %}
```
[...]
gpg: Good signature from "Roland Bewick <roland.bewick@gmail.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg: There is no indication that the signature belongs to the owner.
Primary key fingerprint: 5D92 1859 38E6 DBF8 93DC  CC5B A5EA BD88 3509 2B08
[...]
```
{% endcode %}

#### Checksum check

* Verify the signed checksum against the actual checksum of your download

```sh
grep 'Server-Linux-x86_64.tar.bz2' manifest.txt | sha256sum --check
```

**Example** of expected output:

<pre><code><strong>albyhub-Server-Linux-x86_64.tar.bz2: OK
</strong></code></pre>

* Extract

```sh
sudo tar -xjvf albyhub-Server-Linux-x86_64.tar.bz2
```

**Example** of expected output:

```
./
./bin/
./bin/albyhub
./lib/
./lib/libldk_node.so
```

#### Binaries installation

* Install it

<pre class="language-sh" data-overflow="wrap"><code class="lang-sh"><strong>sudo install -m 0755 -o root -g root -t /usr/local/bin bin/albyhub
</strong></code></pre>

* We need to copy this library to the system’s default library directory and update the system’s shared library cache so that the service starts correctly

<pre class="language-sh" data-overflow="wrap"><code class="lang-sh"><strong>sudo cp lib/libldk_node.so /usr/local/lib/
</strong><strong>sudo ldconfig
</strong></code></pre>

* **(Optional)** Delete installation files of the `tmp` folder to be ready for the next installation

{% code overflow="wrap" %}
```bash
sudo rm -rf albyhub-Server-Linux-x86_64.tar.bz2 manifest.txt manifest.txt.asc bin lib
```
{% endcode %}

#### Create the albyhub user & group

We do not want to run AlbyHub code alongside bitcoind and lnd because of security reasons. For that, we will create a separate user and run the code as the new user.

* Create the `albyhub` user and group

```bash
sudo adduser --gecos "" --disabled-password albyhub
```

* Add albyhub user to the lnd group to allow to the user albyhub reading the admin.macaroon and tls.cert files

```bash
sudo adduser albyhub lnd
```

#### Create data folder

* Create the albyhub data folder

```sh
sudo mkdir /data/albyhub
```

* Assign the owner to the `albyhub` user

```sh
sudo chown -R albyhub:albyhub /data/albyhub
```

* Change to the `albyhub` user

```bash
sudo su - albyhub
```

* Create the symbolic link pointing to the albyhub data directory

```sh
ln -s /data/albyhub /home/albyhub/.albyhub
```

* Check that the symbolic link has been created correctly

```bash
ls -la .albyhub
```

Expected output:

```
lrwxrwxrwx 1 lnd lnd 13 Jul 21  2023 .albyhub -> /data/albyhub
```

* Exit the `albyhub` user session to return to the "admin" user session

```sh
exit
```

### Configuration

* Create the AlbyHub configuration file

```sh
nano /data/albyhub/.env
```

* Paste the following content. Save and exit.

```
# MiniBolt: AlbyHub configuration
# /data/albyhub/.env

# WORKING DIRECTORY
WORK_DIR=/data/albyhub

#SERVICE PORT
PORT=8090

# LND CONNECTION
LN_BACKEND_TYPE=LND
LND_ADDRESS=localhost:10009
LND_CERT_FILE=/data/lnd/tls.cert
LND_MACAROON_FILE=/data/lnd/data/chain/bitcoin/mainnet/admin.macaroon

#LOGS
LOG_EVENTS=true
```

#### Create systemd service

Now, let's configure LND to start automatically on system startup.

* As user `admin`, create LND systemd unit

```sh
sudo nano /etc/systemd/system/albyhub.service
```

* Enter the following content. Save and exit

```
# MiniBolt: systemd unit for AlbyHub
# /etc/systemd/system/albyhub.service

[Unit]
Description=AlbyHub
Requires=lnd.service
After=lnd.service

[Service]
WorkingDirectory=/data/albyhub
ExecStart=/usr/local/bin/albyhub
EnvironmentFile=/data/albyhub/.env

User=albyhub
Group=albyhub

# Process management
####################
Type=simple
TimeoutSec=300

# Hardening Measures
####################
PrivateTmp=true
ProtectSystem=full
NoNewPrivileges=true
PrivateDevices=true

[Install]
WantedBy=multi-user.target
```

* Enable autoboot **(optional)**

```sh
sudo systemctl enable albyhub
```

* Now, the daemon information is no longer displayed on the command line but is written into the system journal. You can check on it using the following command. You can exit monitoring at any time with `Ctrl-C`

```sh
journalctl -fu albyhub
```

### Run

To keep an eye on the software movements, start your SSH program (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`

* Start the service

```sh
sudo systemctl start albyhub
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>journalctl -fu lnd</code> ⬇️</summary>

```
nov 16 11:21:02 minibolt systemd[1]: Started AlbyHub.
nov 16 11:21:02 minibolt albyhub[1440537]: time="2025-11-16T11:21:02Z" level=info msg="AlbyHub Starting in HTTP mode"
nov 16 11:21:02 minibolt albyhub[1440537]: {"level":"info","msg":"AlbyHub v1.20.0","time":"2025-11-16T11:21:02Z"}
nov 16 11:21:02 minibolt albyhub[1440537]: {"level":"info","msg":"Generated new JWT secret","time":"2025-11-16T11:21:02Z"}
nov 16 11:21:02 minibolt albyhub[1440537]: ⇨ http server started on [::]:8090

```

</details>

#### Validation

* Ensure the service is working and listening on the default `8090` port and the HTTPS `3003` port

```bash
sudo ss -tulpn | grep -v 'dotnet' | grep -E '(:3003|:8090)'
```

Expected output:

<pre><code><strong>tcp   LISTEN 0      511          0.0.0.0:3003       0.0.0.0:*    users:(("nginx",pid=745,fd=6),("nginx",pid=744,fd=6),("nginx",pid=743,fd=6),("nginx",pid=742,fd=6),("nginx",pid=741,fd=6))
</strong>tcp   LISTEN 0      4096               *:8090             *:*    users:(("albyhub",pid=1038,fd=8))
</code></pre>

{% hint style="info" %}
> Your browser will display a warning because we use a self-signed SSL certificate. We can do nothing about that because we would need a proper domain name (e.g., https://yournode.com) to get an official certificate that browsers recognize. Click on "Advanced" and proceed to the AlbyHub web interface

> Now point your browser to `https://minibolt.local:3003` or the IP address (e.g. `https://192.168.x.xxx:3003`). You should see the home page of AlbyHub
{% endhint %}

{% hint style="success" %}
Congrat&#x73;**!** You now have AlbyHub up and running
{% endhint %}

### Extras (optional)

#### Remote access over Tor

* With the user `admin`, edit the `torrc` file

```sh
sudo nano +63 /etc/tor/torrc --linenumbers
```

* Add the following lines in the "location hidden services" section, below "`## This section is just for location-hidden services ##`". Save and exit

```
# Hidden Service AlbyHub
HiddenServiceDir /var/lib/tor/hidden_service_albyhub/
HiddenServiceVersion 3
HiddenServicePoWDefensesEnabled 1
HiddenServicePort 80 127.0.0.1:3003
```

* Reload Tor to apply changes

```sh
sudo systemctl reload tor
```

* Get your Onion address

```sh
sudo cat /var/lib/tor/hidden_service_albyhub/hostname
```

Expected output:

```
abcdefg..............xyz.onion
```

* With the [Tor browser](https://www.torproject.org), you can access this onion address from any device

### Upgrade

Follow the complete Installation section until the Binaries installation section (included).

* Restart the service to apply the changes

```sh
sudo systemctl restart albyhub
```

* Check logs and pay attention to the next log

```sh
journalctl -fu albyhub
```

**Example** of expected output:

```
[...]
nov 16 11:21:02 minibolt albyhub[1440537]: ⇨ http server started on [::]:8090 ...
[...]
```

### Uninstall

#### Uninstall service

* Ensure you are logged in as the user `admin`, stop albyhub

```sh
sudo systemctl stop albyhub
```

* Disable autoboot (if enabled)

```sh
sudo systemctl disable albyhub
```

* Delete the service

```sh
sudo rm /etc/systemd/system/albyhub.service
```

#### Delete user & group

* Delete the albyhub user.

```sh
sudo userdel -rf albyhub
```

#### Delete data directory

* Delete albyhub directory

```sh
sudo rm -rf /data/albyhub/
```

#### Uninstall binaries

* Delete the binaries installed

```bash
sudo rm /usr/local/bin/albyhub
```

#### Uninstall Tor hidden service

* Ensure that you are logged in as the user `admin` and delete or comment the following lines in the "location hidden services" section, below "`## This section is just for location-hidden services ##`" in the torrc file. Save and exit

```sh
sudo nano +63 /etc/tor/torrc --linenumbers
```

```
# Hidden Service AlbyHub
HiddenServiceDir /var/lib/tor/hidden_service_albyhub/
HiddenServiceVersion 3
HiddenServicePoWDefensesEnabled 1
HiddenServicePort 80 127.0.0.1:3003
```

* Reload the torrc config

```sh
sudo systemctl reload tor
```

#### Uninstall FW configuration

* Ensure you are logged in as the user `admin`, display the UFW firewall rules, and note the number of the rule for AlbyHub (e.g., X below)

```sh
sudo ufw status numbered
```

Expected output:

```
[X] 3003/tcp                   ALLOW IN    Anywhere                   # allow AlbyHub SSL from anywhere
```

* Delete the rule with the correct number and confirm with "`yes`"

```sh
sudo ufw delete X
```

### Port reference

<table><thead><tr><th align="center">Port</th><th width="100">Protocol<select><option value="K1YTaXNgK9iY" label="TCP" color="blue"></option><option value="rBwkQwPZUMt0" label="SSL" color="blue"></option><option value="zQnHZmzcUdq4" label="UDP" color="blue"></option></select></th><th align="center">Use</th></tr></thead><tbody><tr><td align="center">8090</td><td><span data-option="K1YTaXNgK9iY">TCP</span></td><td align="center">Default HTTP port</td></tr><tr><td align="center">3003</td><td><span data-option="rBwkQwPZUMt0">SSL</span></td><td align="center">HTTPS port (encrypted)</td></tr></tbody></table>
