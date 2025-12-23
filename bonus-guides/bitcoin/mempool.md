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

# Mempool

[Mempool](https://mempool.space/) is the fully-featured mempool visualizer, explorer, and API service.

{% hint style="warning" %}
Difficulty: Medium
{% endhint %}

<figure><img src="../../.gitbook/assets/mempool.png" alt=""><figcaption></figcaption></figure>

## Requirements

* [Bitcoin Core](../../bitcoin/bitcoin/bitcoin-client.md)
* [LND](../../lightning/lightning-client.md) (optional)
* Electrum server ([Fulcrum](../../bitcoin/bitcoin/electrum-server.md) or [Electrs](../../bonus/bitcoin/electrs.md))
* Others
  * [Node + NPM](../../bonus/system/nodejs-npm.md)
  * [Rustup + Cargo](../system/rustup-+-cargo.md)

## Preparations

### Check Node + NPM

* With the user `admin`, check the Node version

```bash
node -v
```

**Example** of expected output:

```
v16.14.2
```

* Check the NPM version

```bash
npm -v
```

**Example** of expected output:

```
8.19.3
```

{% hint style="info" %}
-> If the "`node -v"` output is **`>=20`** and the "`npm -v"` output is **`>=9`**, you can move to the next section.

-> If Nodejs is not installed (`-bash: /usr/bin/node: No such file or directory`), follow this [Node + NPM bonus guide](../../bonus/system/nodejs-npm.md) to install it
{% endhint %}

### Check Rustup + Cargo

* Check if you already have Rustup installed

```bash
rustc --version
```

**Example** of expected output:

```
rustc 1.71.0 (8ede3aae2 2023-07-12)
```

* Also Cargo

```bash
cargo -V
```

**Example** of expected output:

```
cargo 1.71.0 (cfd3bbd8f 2023-06-08)
```

{% hint style="info" %}
If you obtain "**command not found**" output, you need to follow the[ Rustup + Cargo bonus guide](../system/rustup-+-cargo.md) to install it and then come back to continue with the guide
{% endhint %}

### Check MariaDB and create the database

* Check if you already have MariaDB installed

```bash
mariadb --version
```

**Example** of expected output:

```
mariadb from 12.2.1-MariaDB, client 15.2 for debian-linux-gnu (x86_64) using  EditLine wrapper
```

{% hint style="info" %}
If you obtain "**command not found**" output, you need to follow the [MariaDB bonus guide](../system/rustup-+-cargo.md) to install it and then come back to continue with the guide
{% endhint %}

* Now, open the MariaDB shell.

```sh
sudo mysql
> Welcome to the MariaDB monitor.  Commands end with ; or \g.
> [...]
> MariaDB [(none)]>
```

* Enter the following commands in the shell and exit. The instructions to enter in the MariaDB shell start with "MDB$".

```sql
MDB$ create database mempool;
> Query OK, 1 row affected (0.001 sec)
MDB$ grant all privileges on mempool.* to 'mempool'@'localhost' identified by 'Password[G]';
> Query OK, 0 rows affected (0.012 sec)
MDB$ exit
```

{% hint style="info" %}
Replace **`Password[G]`** to your one, keeping quotes \[' ']
{% endhint %}

### Reverse proxy & Firewall

In the [security section](../../index-1/security.md#nginx), we set up Nginx as a reverse proxy. Now we can add the Mempool configuration.

* Check your Nginx configuration file

```bash
sudo nano +17 -l /etc/nginx/nginx.conf
```

* Check that you have these two lines below the line `17 "include /etc/nginx/sites-enabled/*.conf;"` If not, add them, save, and exit.

```nginx
include /etc/nginx/mime.types;
default_type application/octet-stream;
```

{% hint style="info" %}
Watch your indentation! To see the differences between the two configurations more clearly, check this [diff](https://www.diffchecker.com/7ksp6t5T/).
{% endhint %}

Enable the Nginx reverse proxy to route external encrypted HTTPS traffic internally to Mempool. The `error_page 497` directive instructs browsers that send HTTP requests to resend them over HTTPS.

* With user `admin`, create the reverse proxy configuration

```sh
sudo nano /etc/nginx/sites-available/mempool-reverse-proxy.conf
```

* Paste the following complete configuration. Save and exit

```nginx
proxy_read_timeout 300;
proxy_connect_timeout 300;
proxy_send_timeout 300;
 
map $http_accept_language $header_lang {
    default en-US;
    ~*^en-US en-US;
    ~*^en en-US;
    ~*^ar ar;
    ~*^ca ca;
    ~*^cs cs;
    ~*^de de;
    ~*^es es;
    ~*^fa fa;
    ~*^fr fr;
    ~*^ko ko;
    ~*^it it;
    ~*^he he;
    ~*^ka ka;
    ~*^hu hu;
    ~*^mk mk;
    ~*^nl nl;
    ~*^ja ja;
    ~*^nb nb;
    ~*^pl pl;
    ~*^pt pt;
    ~*^ro ro;
    ~*^ru ru;
    ~*^sl sl;
    ~*^fi fi;
    ~*^sv sv;
    ~*^th th;
    ~*^tr tr;
    ~*^uk uk;
    ~*^vi vi;
    ~*^zh zh;
    ~*^hi hi;
}
 
map $cookie_lang $lang {
    default $header_lang;
    ~*^en-US en-US;
    ~*^en en-US;
    ~*^ar ar;
    ~*^ca ca;
    ~*^cs cs;
    ~*^de de;
    ~*^es es;
    ~*^fa fa;
    ~*^fr fr;
    ~*^ko ko;
    ~*^it it;
    ~*^he he;
    ~*^ka ka;
    ~*^hu hu;
    ~*^mk mk;
    ~*^nl nl;
    ~*^ja ja;
    ~*^nb nb;
    ~*^pl pl;
    ~*^pt pt;
    ~*^ro ro;
    ~*^ru ru;
    ~*^sl sl;
    ~*^fi fi;
    ~*^sv sv;
    ~*^th th;
    ~*^tr tr;
    ~*^uk uk;
    ~*^vi vi;
    ~*^zh zh;
    ~*^hi hi;
}
 
server {
    listen 4081 ssl;
    error_page 497 =301 https://$host:$server_port$request_uri; 
 
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
 
    server_tokens off;
    server_name_in_redirect off;
 
    default_type application/octet-stream;
 
    reset_timedout_connection on;
    client_body_timeout 10s;
    client_header_timeout 10s;
    keepalive_timeout 69s;
    send_timeout 69s;
 
    keepalive_requests 1337;
 
    gzip on;
    gzip_vary on;
    gzip_comp_level 6;
    gzip_min_length 1000;
    gzip_proxied expired no-cache no-store private auth;
    gzip_types application/javascript application/json application/ld+json application/manifest+json application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard;
 
    client_max_body_size 10m;
 
    proxy_cache off;
    types_hash_max_size 2048;
 
    root /var/www/mempool/browser;
    index index.html;
 
    add_header Cache-Control "public, no-transform";
    add_header Vary Accept-Language;
    add_header Vary Cookie;
 
    location / {
        try_files /$lang/$uri /$lang/$uri/ $uri $uri/ /en-US/$uri @index-redirect;
        expires 10m;
    }
 
    location /resources {
        try_files $uri @index-redirect;
        expires 1h;
    }
 
    location /resources/config.* {
        try_files $uri =404;
        expires 5m;
    }
 
    location /resources/customize.* {
        try_files $uri =404;
        expires 5m;
    }
 
    location @index-redirect {
        rewrite (.*) /$lang/index.html;
    }
 
    location ~ ^/(ar|bg|bs|cs|da|de|et|el|es|eo|eu|fa|fr|gl|ko|hr|id|it|he|ka|lv|lt|hu|mk|ms|nl|ja|nb|nn|pl|pt|pt-BR|ro|ru|sk|sl|sr|sh|fi|sv|th|tr|uk|vi|zh|hi)/ {
        try_files $uri $uri/ /$1/index.html =404;
    }
 
    location = /api {
        try_files $uri $uri/ /en-US/index.html =404;
    }
 
    location = /api/ {
        try_files $uri $uri/ /en-US/index.html =404;
    }
 
    location /api/v1/ws {
        proxy_pass http://127.0.0.1:8999/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
    }
 
    location /api/v1 {
        proxy_pass http://127.0.0.1:8999/api/v1;
    }
 
    location /api/ {
        proxy_pass http://127.0.0.1:8999/api/v1/;
    }
 
    location /ws {
        proxy_pass http://127.0.0.1:8999/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
    }
}
```

* Create the symbolic link that points to the directory `sites-enabled`

{% code overflow="wrap" %}
```bash
sudo ln -s /etc/nginx/sites-available/mempool-reverse-proxy.conf /etc/nginx/sites-enabled/
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

```bash
sudo systemctl reload nginx
```

* Configure the firewall to allow incoming HTTPS requests from anywhere to the web server

```sh
sudo ufw allow 4081/tcp comment 'allow Mempool Space SSL from anywhere'
```

## Installation

### **Create the mempool user & group**

We do not want to run Mempool Space code alongside bitcoind and lnd because of security reasons. For that, we will create a separate user and run the code as the new user.

* Create the `mempool` user and group

```bash
sudo adduser --gecos "" --disabled-password mempool
```

Expected output:

```
Adding user `mempool' ...
Adding new group `mempool' (1007) ...
Adding new user `mempool' (1007) with group `mempool' ...
Creating home directory `/home/mempool' ...
Copying files from `/etc/skel' ...
```

Add `mempool` user to the `bitcoin` and `lnd` groups to allow to the user mempool reading the bitcoin .cookie file and lnd certs files.

```bash
sudo usermod -aG bitcoin,lnd mempool
```

* Exit `mempool` user session to return to the `admin` user session

```bash
exit
```

### Download the source code

* With user `admin`, go to the temporary folder

```bash
cd /tmp
```

* Set a temporary version environment variable for the installation

```bash
VERSION=3.2.1
```

* Import the GPG key of the developer

```bash
curl https://github.com/wiz.gpg | gpg --import
```

**Example** of expected output:

```
gpg: directory '/home/mempool/.gnupg' created
gpg: keybox '/home/mempool/.gnupg/pubring.kbx' created
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  4608  100  4608    0     0  15283      0 --:--:-- --:--:-- --:--:-- 15308
gpg: /home/mempool/.gnupg/trustdb.gpg: trustdb created
gpg: key A394E332255A6173: public key "J. Maurice (wiz) <j@wiz.biz>" imported
gpg: Total number processed: 1
gpg:               imported: 1
```

* Download the source code directly from GitHub, select the latest release branch associated, and go to the `mempool` folder

{% code overflow="wrap" %}
```bash
git clone --branch v$VERSION https://github.com/mempool/mempool.git && cd mempool
```
{% endcode %}

* Verify the release

```bash
git verify-tag v$VERSION
```

**Example** of expected output:

```
gpg: Signature made Mon 14 abr 2025 04:24:51 CEST
gpg:                using RSA key 913C5FF1F579B66CA10378DBA394E332255A6173
gpg: Good signature from "J. Maurice (wiz) <j@wiz.biz>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 913C 5FF1 F579 B66C A103  78DB A394 E332 255A 6173
```

### Install the backend

* Change to the backend directory

```bash
cd backend
```

* Install all dependencies and the necessary modules using NPM

{% hint style="warning" %}
**Not to run** the `npm audit fix` command, which could break the original code!!
{% endhint %}

```bash
npm ci --omit=dev --omit=optional
```

<details>

<summary>Example of expected output ⬇️</summary>

```
[...]
3 high severity vulnerabilities

To address all issues, run:
  npm audit fix

Run `npm audit` for details.
```

</details>

* Build it

```bash
npm run package
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
```

</details>

* Create the folder for the executable

```bash
mkdir package/bin
```

* Create a new `cli.sh` file

```sh
sudo nano package/bin/cli.sh
```

* Copy and paste the following information, save and exit

```yaml
#!/bin/sh
node /var/lib/mempool/index.js
```

* Make the file executable

```yaml
chmod +x package/bin/cli.sh
```

* Copy the necessary files into the system

```yaml
sudo mv -f /tmp/mempool/backend/package /var/lib/mempool
```

* Create the corresponding symbolic links

```yaml
sudo ln -s /var/lib/mempool /usr/lib/node_modules/mempool && sudo ln -s /usr/lib/node_modules/mempool/bin/cli.sh /usr/bin/mempool
```

* Create the configuration file

```bash
sudo nano /home/mempool/mempool-config.json
```

* Paste the following lines.

```
{
  "MEMPOOL": {
    "NETWORK": "mainnet",
    "BACKEND": "electrum",
    "HTTP_PORT": 8999,
    "SPAWN_CLUSTER_PROCS": 0,
    "API_URL_PREFIX": "/api/v1/",
    "POLL_RATE_MS": 2000,
    "CACHE_DIR": "./cache",
    "CLEAR_PROTECTION_MINUTES": 20,
    "RECOMMENDED_FEE_PERCENTILE": 50,
    "BLOCK_WEIGHT_UNITS": 4000000,
    "INITIAL_BLOCKS_AMOUNT": 8,
    "MEMPOOL_BLOCKS_AMOUNT": 8,
    "PRICE_FEED_UPDATE_INTERVAL": 3600,
    "USE_SECOND_NODE_FOR_MINFEE": false,
    "EXTERNAL_ASSETS": []
  },
  "CORE_RPC": {
    "HOST": "127.0.0.1",
    "PORT": 8332,
    "COOKIE": true,
    "COOKIE_PATH": "/data/bitcoin/.cookie"
  },
  "ELECTRUM": {
    "HOST": "127.0.0.1",
    "PORT": 50002,
    "TLS_ENABLED": true
  },
  "DATABASE": {
    "ENABLED": true,
    "HOST": "127.0.0.1",
    "PORT": 3306,
    "USERNAME": "mempool",
    "PASSWORD": "Password[G]",
    "DATABASE": "mempool"
  },
  "LIGHTNING": {
    "ENABLED": true,
    "BACKEND": "lnd",
    "STATS_REFRESH_INTERVAL": 600,
    "GRAPH_REFRESH_INTERVAL": 600,
    "LOGGER_UPDATE_INTERVAL": 30,
    "FORENSICS_INTERVAL": 43200,
    "FORENSICS_RATE_LIMIT": 20
  },
  "LND": {
    "TLS_CERT_PATH": "/data/lnd/tls.cert",
    "MACAROON_PATH": "/data/lnd/data/chain/bitcoin/mainnet/readonly.macaroon",
    "REST_API_URL": "https://localhost:10009",
    "TIMEOUT": 10000
  },
  "SOCKS5PROXY": {
    "ENABLED": true,
    "USE_ONION": true,
    "HOST": "127.0.0.1",
    "PORT": 9050
  },
  "PRICE_DATA_SERVER": {
    "TOR_URL": "http://wizpriceje6q5tdrxkyiazsgu7irquiqjy2dptezqhrtu7l2qelqktid.onion/getAllMarketPrices"
  }
}
```

{% hint style="info" %}
Replace **`Password[G]`** to your one, keeping quotes \[" "]
{% endhint %}

* Restrict reading access to the configuration file by user "mempool" only.

```bash
sudo chmod 600 /home/mempool/mempool/backend/mempool-config.json
```

### Install the frontend

* Change to the frontend directory

```bash
cd /tmp/mempool/frontend
```

* Install all dependencies and the necessary modules using NPM

{% hint style="warning" %}
**Not to run** the `npm audit fix` command, which could break the original code!!
{% endhint %}

```bash
npm ci --omit=dev --omit=optional
```

<details>

<summary>Example of expected output ⬇️</summary>

```
16 vulnerabilities (2 low, 4 moderate, 10 high)

To address issues that do not require attention, run:
  npm audit fix

To address all issues (including breaking changes), run:
  npm audit fix --force

Run `npm audit` for details.
```

</details>

* Build it

```bash
npm run build
```

* Copy the necessary files into the system

```yaml
sudo mv -f dist/mempool /var/www/
```

### **Create systemd service**

* As user `admin`, create the service file

```bash
sudo nano /etc/systemd/system/mempool.service
```

* Paste the following configuration. Save and exit

<pre><code># MiniBolt: systemd unit for Mempool
# /etc/systemd/system/mempool.service

[Unit]
Description=Mempool
<strong>Requires=bitcoind.service fulcrum.service mariadb.service
</strong>After=bitcoind.service fulcrum.service mariadb.service

[Service]
WorkingDirectory=/var/lib/mempool
Environment=MEMPOOL_CONFIG_FILE=/home/mempool/mempool-config.json
Environment=NODE_OPTIONS=--max-old-space-size=2048

User=mempool
Group=mempool

# Process management
####################
TimeoutSec=300

# Hardening Measures
####################
PrivateTmp=true
ProtectSystem=full
NoNewPrivileges=true
PrivateDevices=true

[Install]
WantedBy=multi-user.target
</code></pre>

* Enable autoboot **(optional)**

```bash
sudo systemctl enable mempool
```

* Prepare “mempool” monitoring by the systemd journal and check the logging output. You can exit monitoring at any time with Ctrl-C

```bash
journalctl -fu mempool
```

### **Run**

To keep an eye on the software movements, [start your SSH program](../../index-1/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`

* Start mempool

```bash
sudo systemctl start mempool
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>journalctl -fu mempool</code> ⬇️</summary>

```
```

</details>

#### Validation

* Ensure the service is working and listening on the default HTTP `8999` port and SSL `4081` port

```bash
sudo ss -tulpn | grep -v 'dotnet' | grep -E '(:8999|:4081)'
```

Expected output:

```
tcp   LISTEN 0      511          0.0.0.0:4081       0.0.0.0:*    users:(("nginx",pid=827,fd=10),("nginx",pid=826,fd=10),("nginx",pid=825,fd=10),("nginx",pid=824,fd=10),("nginx",pid=823,fd=10))
tcp   LISTEN 0      511                *:8999             *:*    users:(("node",pid=1083,fd=25))
```

{% hint style="info" %}
> Your browser will display a warning because we use a self-signed SSL certificate. We can do nothing about that because we would need a proper domain name (e.g., https://yournode.com) to get an official certificate that browsers recognize. Click on "Advanced" and proceed to the Mempool web interface

> Now point your browser to `https://minibolt.local:4081` or the IP address (e.g. `https://192.168.x.xxx:4081`). You should see the home page of Mempool Space
{% endhint %}

{% hint style="success" %}
Congrat&#x73;**!** You now have Mempool up and running
{% endhint %}

### Extras (optional)

#### Remote access over Tor

* With the user `admin`, edit the `torrc` file

```bash
sudo nano +63 /etc/tor/torrc --linenumbers
```

* Add the following lines in the "location hidden services" section, below "`## This section is just for location-hidden services ##`". Save and exit

```
# Hidden Service Mempool
HiddenServiceDir /var/lib/tor/hidden_service_mempool/
HiddenServiceVersion 3
HiddenServicePoWDefensesEnabled 1
HiddenServicePort 443 127.0.0.1:4081
```

* Reload Tor to apply changes

```bash
sudo systemctl reload tor
```

* Get your Onion address

```bash
sudo cat /var/lib/tor/hidden_service_mempool/hostname
```

Expected output:

```
abcdefg..............xyz.onion
```

* With the [Tor browser](https://www.torproject.org), you can access this onion address from any device

## Upgrade

Follow the complete [Download](mempool.md#download-the-source-code), [Backend](mempool.md#install-the-backend) and [Frontend](mempool.md#install-the-frontend) sections replacing the environment variable `"VERSION=x.xx"` value to the latest if it has not already been changed in this guide **(acting behind your responsibility)**.

* Restart the service to apply the changes

```shellscript
sudo systemctl restart mempool
```

* Check the logs, and pay attention to the next log

```shellscript
journalctl -fu mempool
```

**Example** of expected output:

```
```

## Uninstall

### Uninstall service

* Ensure you are logged in as the user `admin`, stop Mempool

```shellscript
sudo systemctl stop mempool
```

* Disable autoboot (if enabled)

```shellscript
sudo systemctl disable mempool
```

* Delete the service

```shellscript
sudo rm /etc/systemd/system/mempool.service
```

### Delete user & group

* Delete the mem`pool` user.

```shellscript
sudo userdel -rf mempool
```

### Delete all Mempool files

* Remove the corresponding symbolic links and files

```bash
sudo rm /usr/lib/node_modules/mempool && sudo rm /usr/bin/mempool && sudo rm -rf /var/lib/mempool
```

* Delete the nginx server files.

```shellscript
sudo rm -rf /var/www/mempool
```

#### Uninstall Tor hidden service

* Ensure that you are logged in as the user `admin` and delete or comment the following lines in the "location hidden services" section, below "`## This section is just for location-hidden services ##`" in the torrc file. Save and exit

```bash
sudo nano +63 /etc/tor/torrc --linenumbers
```

```
# Hidden Service Mempool
HiddenServiceDir /var/lib/tor/hidden_service_mempool/
HiddenServiceVersion 3
HiddenServicePoWDefensesEnabled 1
HiddenServicePort 80 127.0.0.1:4081
```

* Reload the torrc config

```bash
sudo systemctl reload tor
```

#### Uninstall FW configuration

* Ensure you are logged in as the user `admin`, display the UFW firewall rules, and note the number of the rule for AlbyHub (e.g., X below)

```bash
sudo ufw status numbered
```

Expected output:

```
[X] 4081/tcp                   ALLOW IN    Anywhere                   # allow Mempool SSL from anywhere
```

* Delete the rule with the correct number and confirm with "`yes`"

```bash
sudo ufw delete X
```

### Port reference

<table><thead><tr><th align="center">Port</th><th width="100">Protocol<select><option value="K1YTaXNgK9iY" label="TCP" color="blue"></option><option value="rBwkQwPZUMt0" label="SSL" color="blue"></option><option value="zQnHZmzcUdq4" label="UDP" color="blue"></option></select></th><th align="center">Use</th></tr></thead><tbody><tr><td align="center">8999</td><td><span data-option="K1YTaXNgK9iY">TCP</span></td><td align="center">Default HTTP port</td></tr><tr><td align="center">4081</td><td><span data-option="rBwkQwPZUMt0">SSL</span></td><td align="center">Default SSL port</td></tr></tbody></table>
