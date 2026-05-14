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
  tags:
    visible: true
---

# Mempool

[Mempool](https://github.com/mempool/mempool) is the fully-featured mempool visualizer, explorer, and API service.

{% hint style="warning" %}
Difficulty: Medium
{% endhint %}

<figure><img src="../../.gitbook/assets/mempool.png" alt=""><figcaption></figcaption></figure>

## Requirements

* [Bitcoin Core](../../bitcoin/bitcoin/bitcoin-client.md)
* [LND](../../lightning/lightning-client.md) (optional)
* Electrum server ([Fulcrum](../../bitcoin/bitcoin/electrum-server.md) or [Electrs](../../bonus/bitcoin/electrs.md))
* Others
  * [Nginx](../../index-1/security.md#nginx)
  * [MariaDB](../system/mariadb.md)
  * [Rustup + Cargo](../system/rustup-+-cargo.md)
  * [Node + NPM](../../bonus/system/nodejs-npm.md)

## Preparations

### Install dependencies

* With user `admin`, update and upgrade your OS. Press "**y**" and `enter` or directly `enter` when the prompt asks you

```bash
sudo apt update && sudo apt full-upgrade
```

* Install `build-essential` package. Press "**y**" and `enter` or directly `enter` when the prompt asks you

```bash
sudo apt install build-essential
```

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
If you obtain "**command not found**" output, you need to follow the [MariaDB bonus guide](../system/mariadb.md) to install it and then come back to continue with the guide
{% endhint %}

* Now, open the MariaDB shell

```sh
sudo mariadb
```

**Example** of expected output:

```
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 32
Server version: 12.2.1-MariaDB-ubu2204 mariadb.org binary distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]>
```

* Create the `mempool` database. The instructions to enter the MariaDB shell start with: "`MariaDB [(none)]>`"

```sql
CREATE DATABASE mempool;
```

Expected output:

```
Query OK, 1 row affected (0.001 sec)
```

* Create a new admin user and grant privileges to it over the mempool database

```sql
GRANT ALL PRIVILEGES ON mempool.* TO 'admin'@'127.0.0.1' IDENTIFIED BY 'admin';
```

Expected output:

```
Query OK, 0 rows affected (0.001 sec)
```

* Apply changes

{% code overflow="wrap" %}
```sql
FLUSH PRIVILEGES;
```
{% endcode %}

* Exit from MariaDB shell

```sql
exit
```

### Reverse proxy & Firewall

In the [security section](../../index-1/security.md#nginx), we set up Nginx as a reverse proxy. We can now add the Mempool configuration.

* Check your Nginx configuration file

```bash
sudo nano +17 -l /etc/nginx/nginx.conf
```

* Check that you have these two lines below line 17 `"include /etc/nginx/sites-enabled/*.conf;"` If not, add them, save, and exit

```nginx
include /etc/nginx/mime.types;
default_type application/octet-stream;
```

{% hint style="info" %}
Watch your indentation! To see the differences between the two configurations more clearly, check this [diff](https://www.diffchecker.com/7ksp6t5T/)
{% endhint %}

Enable the Nginx reverse proxy to route external encrypted HTTPS traffic internally to Mempool. The `error_page 497` directive instructs browsers that send HTTP requests to resend them over HTTPS.

* With user `admin`, create the reverse proxy configuration

```sh
sudo nano /etc/nginx/sites-available/mempool-reverse-proxy.conf
```

<details>

<summary>Paste the following complete configuration. Save and exit. <strong>Expandable</strong>, push on ⬇️</summary>

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

server {
    listen 127.0.0.1:8001;
    server_name _;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    server_tokens off;
    server_name_in_redirect off;
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

server {
    listen 4081 ssl;
    http2 on;
    error_page 497 =301 https://$host:$server_port$request_uri;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    server_tokens off;
    server_name_in_redirect off;
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

</details>

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
sudo ufw allow 4081/tcp comment 'allow Mempool SSL from anywhere'
```

## Installation

### **Create the mempool user & group**

We do not want to run Mempool code alongside other services for security reasons. To do that, we will create a separate user and run the code as that user.

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

* Add the mempool user to the bitcoin and lnd groups to allow the `mempool` user to read the Bitcoin Core `.cookie` and the [LND](../../lightning/lightning-client.md) certificate files

```bash
sudo usermod -aG bitcoin,lnd mempool
```

### Install Rustup + Cargo

* With user `admin`, change to the `mempool` user home folder

```bash
sudo su - mempool
```

{% hint style="warning" %}
Pay attention to the next step!
{% endhint %}

* Important!! Follow the [Rustup + Cargo installation guide](../system/rustup-+-cargo.md#installation) to install it for the user mempool, and then come back to continue with the guide

### Download and verify the source code

* Set a temporary version environment variable

```bash
VERSION=3.3.1
```

* Import the GPG key of the developer

```bash
curl https://github.com/mononaut.gpg | gpg --import
```

**Example** of expected output:

```
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0gpg: directory '/home/mempool/.gnupg' created
gpg: keybox '/home/mempool/.gnupg/pubring.kbx' created
100  7188  100  7188    0     0  22889      0 --:--:-- --:--:-- --:--:-- 22891
gpg: /home/mempool/.gnupg/trustdb.gpg: trustdb created
gpg: key 61B952CAF4838F94: public key "Mononaut <github@monospace.live>" imported
gpg: key A3F058E41374C04E: public key "Mononaut (Github signing keys) <github@monospace.live>" imported
gpg: key BFD16BE592A9CD8D: public key "mononaut <mononaut@mempool.space>" imported
gpg: Total number processed: 3
gpg:               imported: 3
```

* Download the source code directly from GitHub, select the latest release branch associated with it, and go to the `mempool` folder

{% code overflow="wrap" %}
```bash
git clone --branch v$VERSION https://github.com/mempool/mempool && cd mempool
```
{% endcode %}

* Verify the release

```bash
git verify-tag v$VERSION
```

Expected output:

<pre><code>gpg: Signature made Tue 14 Apr 2026 10:31:06 AM UTC
gpg:                using RSA key 523B596A78BB8495AA2EC45ABFD16BE592A9CD8D
gpg: <a data-footnote-ref href="#user-content-fn-1">Good signature</a> from "mononaut &#x3C;mononaut@mempool.space>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 523B 596A 78BB 8495 AA2E  C45A BFD1 6BE5 92A9 CD8D
</code></pre>

### Install the backend

* Change to the backend directory

```bash
cd backend
```

* Create the configuration file

```bash
nano mempool-config.json
```

* Paste the following lines. Save and exit

{% hint style="info" %}
- If you want to have the Lightning tab enabled and connect to your internal [LND](../../lightning/lightning-client.md) node, follow the [Enable Lightning with a local LND node](mempool.md#enable-lightning-with-a-local-lnd-node) extra section and come back to continue with the next step. **Keep in mind:** you need to have a [LND](../../lightning/lightning-client.md) node already running and synchronized, and for a better experience with a public channel, at least
- If you want to use [Electrs](../../bonus/bitcoin/electrs.md) instead of [Fulcrum](../../bitcoin/bitcoin/electrum-server.md), you need to use: `"PORT": 50021`
{% endhint %}

<pre><code>{
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
    "PORT": <a data-footnote-ref href="#user-content-fn-2">50001</a>,
    "TLS_ENABLED": false
  },
  "DATABASE": {
    "ENABLED": true,
    "HOST": "127.0.0.1",
    "PORT": 3306,
    "USERNAME": "admin",
    "PASSWORD": "admin",
    "DATABASE": "mempool"
  }
}
</code></pre>

* Install all dependencies and the necessary modules using NPM

```bash
npm install --omit=dev --omit=optional
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```

> mempool-backend@3.3.0 preinstall
> cd ../rust/gbt && npm run build-release && npm run to-backend


> gbt@3.0.1 build-release
> npm run build -- --release --strip


> gbt@3.0.1 build
> npm install --no-save @napi-rs/cli@2.18.0 && npm run check-cargo-version && napi build --platform --release --strip


added 1 package, and audited 2 packages in 941ms

1 package is looking for funding
  run `npm fund` for details

found 0 vulnerabilities

> gbt@3.0.1 check-cargo-version
> VER=$(cat rust-toolchain) ; if ! cargo version | grep "cargo $VER" >/dev/null ; then echo -e "\033[1;35m[[[[WARNING]]]]: cargo version mismatch with ./rust-toolchain version ($VER)!!!\033[0m" >&2; fi
info: syncing channel updates for 1.84-x86_64-unknown-linux-gnu
info: latest update on 2025-01-30 for version 1.84.1 (e71f9a9a9 2025-01-27)
info: downloading 3 components
   Compiling proc-macro2 v1.0.93
   Compiling unicode-ident v1.0.15
   Compiling once_cell v1.20.2
   Compiling memchr v2.7.4
   Compiling regex-syntax v0.8.5
[...]
    Building [=========================> ] 55/56: gbt
   Compiling napi v2.16.13
    Finished `release` profile [optimized] target(s) in 38.36s

> gbt@3.0.1 to-backend
> FD=${FD:-../../backend/rust-gbt/} ; rm -rf $FD && mkdir $FD && cp index.js index.d.ts package.json *.node $FD


added 134 packages, and audited 137 packages in 1m

21 packages are looking for funding
  run `npm fund` for details

2 vulnerabilities (1 moderate, 1 critical)

To address issues that do not require attention, run:
  npm audit fix

To address all issues, run:
  npm audit fix --force

Run `npm audit` for details.
npm notice
npm notice New major version of npm available! 10.9.7 -> 11.12.1
npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.12.1
npm notice To update run: npm install -g npm@11.12.1
npm notice
```

</details>

{% hint style="warning" %}
**Not to run** the `npm audit fix` command, which could break the original code!!
{% endhint %}

* Build it

```bash
npm run build
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```

> mempool-backend@3.3.0 build
> npm run tsc && npm run create-resources


> mempool-backend@3.3.0 tsc
> ./node_modules/typescript/bin/tsc -p tsconfig.build.json


> mempool-backend@3.3.0 create-resources
> cp ./src/tasks/price-feeds/mtgox-weekly.json ./dist/tasks && node dist/api/fetch-version.js

```

</details>

### Install the frontend

* Change to the frontend directory

```bash
cd /home/mempool/mempool/frontend
```

* Create a `mempool-frontend` configuration file

{% code overflow="wrap" %}
```bash
nano mempool-frontend-config.json
```
{% endcode %}

* Type the next context. Save and exit

{% hint style="info" %}
If you want to have the Lightning explorer connected to your internal [LND](../../lightning/lightning-client.md) node and you followed the [Enable Lightning with a local LND node](mempool.md#enable-lightning-with-a-local-lnd-node) extra section, change the parameter `"LIGHTNING": false,`  to -> true ( `"LIGHTNING": true,`).

**Keep in mind:** you need to have a [LND](../../lightning/lightning-client.md) node already running and synchronized, and for a better experience with a public channel, at least.
{% endhint %}

<pre data-overflow="wrap"><code>{
  "TESTNET_ENABLED": false,
  "TESTNET4_ENABLED": false,
  "SIGNET_ENABLED": false,
  "REGTEST_ENABLED": false,
  "LIQUID_ENABLED": false,
  "LIQUID_TESTNET_ENABLED": false,
  "MAINNET_ENABLED": true,
  "ITEMS_PER_PAGE": 10,
  "KEEP_BLOCKS_AMOUNT": 8,
  "NGINX_PROTOCOL": "http",
  "NGINX_HOSTNAME": "127.0.0.1",
  "NGINX_PORT": "8001",
  "BLOCK_WEIGHT_UNITS": 4000000,
  "MEMPOOL_BLOCKS_AMOUNT": 8,
  "BASE_MODULE": "mempool",
  "ROOT_NETWORK": "",
  "MEMPOOL_WEBSITE_URL": "https://mempool.space",
  "LIQUID_WEBSITE_URL": "https://liquid.network",
  "MINING_DASHBOARD": true,
  "AUDIT": false,
  "MAINNET_BLOCK_AUDIT_START_HEIGHT": 0,
  "TESTNET_BLOCK_AUDIT_START_HEIGHT": 0,
  "SIGNET_BLOCK_AUDIT_START_HEIGHT": 0,
  "REGTEST_BLOCK_AUDIT_START_HEIGHT": 0,
  "TESTNET4_BLOCK_AUDIT_START_HEIGHT": 0,
  "MAINNET_TX_FIRST_SEEN_START_HEIGHT": 0,
  "TESTNET_TX_FIRST_SEEN_START_HEIGHT": 0,
  "TESTNET4_TX_FIRST_SEEN_START_HEIGHT": 0,
  "SIGNET_TX_FIRST_SEEN_START_HEIGHT": 0,
  "REGTEST_TX_FIRST_SEEN_START_HEIGHT": 0,
  "LIGHTNING": <a data-footnote-ref href="#user-content-fn-3">false</a>,
  "HISTORICAL_PRICE": true,
  "ADDITIONAL_CURRENCIES": false,
  "ACCELERATOR": false,
  "ACCELERATOR_BUTTON": true,
  "PUBLIC_ACCELERATIONS": false,
  "STRATUM_ENABLED": false,
  "SERVICES_API": "https://mempool.space/api/v1/services"
}
</code></pre>

* Install all dependencies and the necessary modules using NPM:

```bash
npm install --omit=dev --omit=optional
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
npm warn deprecated popper.js@1.16.1: You can find the new Popper v2 at @popperjs/core, this package is dedicated to the legacy v1

added 956 packages, and audited 957 packages in 14s

169 packages are looking for funding
  run `npm fund` for details

6 vulnerabilities (5 moderate, 1 high)

To address all issues, run:
  npm audit fix

Run `npm audit` for details.
```

</details>

{% hint style="warning" %}
**Not to run** the `npm audit fix` command, which could break the original code!!
{% endhint %}

* Build it:

{% code overflow="wrap" %}
```bash
npm run generate-themes && npm run generate-config && npm run ng -- build --configuration production --localize && npm run sync-assets
```
{% endcode %}

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```

> mempool-frontend@3.3.0 generate-themes
> node generate-themes.js

Built contrast.css and contrast.d2a06292969697ac.css
Built softsimon.css and softsimon.3317e60f53003eb7.css
Built bukele.css and bukele.37cb79c4a707eaa5.css
Theme manifest written to theme-manifest.json

> mempool-frontend@3.3.0 generate-config
> node generate-config.js

mempool-frontend-config.json file found, using provided config
Copied src/index.mempool.html to src/index.html
Injected theme manifest into src/index.html: {
  contrast: 'contrast.d2a06292969697ac.css',
  softsimon: 'softsimon.3317e60f53003eb7.css',
  bukele: 'bukele.37cb79c4a707eaa5.css'
}
mempool version 3.3.0
mempool revision e64b363ee
src/resources/config.js file not found, creating new config file
CONFIG:  (function (window) {
  window.__env = window.__env || {};
    window.__env.TESTNET_ENABLED = false;
    window.__env.TESTNET4_ENABLED = false;
    window.__env.SIGNET_ENABLED = false;
    window.__env.REGTEST_ENABLED = false;
    window.__env.LIQUID_ENABLED = false;
    window.__env.LIQUID_TESTNET_ENABLED = false;
    window.__env.MAINNET_ENABLED = true;
    window.__env.ITEMS_PER_PAGE = 10;
    window.__env.KEEP_BLOCKS_AMOUNT = 8;
    window.__env.NGINX_PROTOCOL = 'http';
    window.__env.NGINX_HOSTNAME = '127.0.0.1';
    window.__env.NGINX_PORT = '8001';
    window.__env.BLOCK_WEIGHT_UNITS = 4000000;
    window.__env.MEMPOOL_BLOCKS_AMOUNT = 8;
    window.__env.BASE_MODULE = 'mempool';
    window.__env.ROOT_NETWORK = '';
    window.__env.MEMPOOL_WEBSITE_URL = 'https://mempool.space';
    window.__env.LIQUID_WEBSITE_URL = 'https://liquid.network';
    window.__env.MINING_DASHBOARD = true;
    window.__env.AUDIT = false;
[...]
    window.__env.SIGNET_TX_FIRST_SEEN_START_HEIGHT = 0;
    window.__env.REGTEST_TX_FIRST_SEEN_START_HEIGHT = 0;
    window.__env.LIGHTNING = true;
[...]
⠋ Generating browser application bundles (phase: setup)...    TypeScript compiler options "target" and "useDefineForClassFields" are set to "ES2022" and "false" respectively by the Angular CLI. To control ECMA version and features use the Browserslist configuration. For more information, see https://angular.dev/tools/cli/build#configuring-browser-compatibility
    NOTE: You can set the "target" to "ES2022" in the project's tsconfig to remove this warning.
⠧ Generating browser application bundles (phase: building)...
[...]
⠋ Generating localized bundles...
[...]
No translation found for "4737378996440967882" ["c4221ec405e432a0dac150a4c48c9100eac712bd", "4253114395798936977"] (" Values were capped at the max supply of 21M BTC " - "calculator.max-supply-warning").
No translation found for "4737378996440967882" ["c4221ec405e432a0dac150a4c48c9100eac712bd", "4253114395798936977"] (" Values were capped at the max supply of 21M BTC " - "calculator.max-supply-warning").
No translation found for "4737378996440967882" ["c4221ec405e432a0dac150a4c48c9100eac712bd", "4253114395798936977"] (" Values were capped at the max supply of 21M BTC " - "calculator.max-supply-warning").
No translation found for "4737378996440967882" ["c4221ec405e432a0dac150a4c48c9100eac712bd", "4253114395798936977"] (" Values were capped at the max supply of 21M BTC " - "calculator.max-supply-warning").
No translation found for "4737378996440967882" ["c4221ec405e432a0dac150a4c48c9100eac712bd", "4253114395798936977"] (" Values were capped at the max supply of 21M BTC " - "calculator.max-supply-warning").
No translation found for "4737378996440967882" ["c4221ec405e432a0dac150a4c48c9100eac712bd", "4253114395798936977"] (" Values were capped at the max supply of 21M BTC " - "calculator.max-supply-warning").
[...]
✔ Localized bundle generation complete.
✔ Copying assets complete.
✔ Index html generation complete.

Initial chunk files           | Names                                               |  Raw size | Estimated transfer size
main.377570c998a82448.js      | main                                                |   1.48 MB |               355.24 kB
styles.5360fdbcf9ef97cb.css   | styles                                              | 181.76 kB |                22.66 kB
polyfills.d86fbf1f9931c85b.js | polyfills                                           |  34.89 kB |                11.34 kB
[...]
354.a645b30dd813fade.js       | components-block-block-module                       |   1.04 kB |               536 bytes
815.895a7d339cfe8baf.js       | app-liquid-liquid-graphs-module                     | 712 bytes |               353 bytes

Build at: 2026-04-16T07:17:16.326Z - Hash: 5f7832d17e4854a2 - Time: 91955ms

Warning: /home/mempool/mempool/frontend/src/app/components/about/about.component.scss exceeded maximum budget. Budget 6.00 kB was not met by 1.71 kB with a total of 7.71 kB.

Warning: /home/mempool/mempool/frontend/src/app/components/acceleration-timeline/acceleration-timeline.component.scss exceeded maximum budget. Budget 6.00 kB was not met by 820 bytes with a total of 6.82 kB.

Warning: /home/mempool/mempool/frontend/src/app/components/custom-dashboard/custom-dashboard.component.scss exceeded maximum budget. Budget 6.00 kB was not met by 1.65 kB with a total of 7.65 kB.

[...]
> mempool-frontend@3.3.0 sync-assets
> npm run copy-themes && rsync -av ./src/resources ./dist/mempool/browser && node sync-assets.js 'dist/mempool/browser/resources/'


> mempool-frontend@3.3.0 copy-themes
> node generate-themes.js copy

Copied 6 theme files to all locale directories
sending incremental file list
resources/
resources/.gitkeep
resources/apple-pay.png
resources/bimi.svg
resources/bitblogo.svg
resources/bitcoin-btc-logo-full.svg
resources/bitcoin-logo.png
resources/cash-app.svg
resources/config.js
resources/config.template.js
resources/cubo.svg
resources/customize.js
resources/elsalvador-flag.svg
resources/elsalvador.svg
resources/google-pay.png
[...]
sent 15,106,356 bytes  received 3,764 bytes  30,220,240.00 bytes/sec
total size is 15,089,079  speedup is 1.00
[sync-assets] using ASSETS_PATH /home/mempool/mempool/frontend/dist/mempool/browser/resources
[sync-assets] mempool-frontend-config.json file found, using provided config
[sync-assets]   Checking if mining pool logos needs downloading or updating...
[sync-assets]           .gitignore is missing, downloading...
[sync-assets]           1thash.svg is missing, downloading...
[sync-assets]           antpool.svg is missing, downloading...
[sync-assets]           arkpool.svg is missing, downloading...
[sync-assets]           binancepool.svg is missing, downloading...
[sync-assets]           bitcoincom.svg is missing, downloading...
[sync-assets]           bitfufupool.svg is missing, downloading...
[sync-assets]           bitfury.svg is missing, downloading...
[sync-assets]           braiinspool.svg is missing, downloading...
[sync-assets]           braiinssolo.svg is missing, downloading...
[...]
[sync-assets]           whitepool.svg is missing, downloading...
[sync-assets]           wiz.svg is missing, downloading...
[sync-assets]           Downloaded 62 and skipped 1 existing mining pool logos
[sync-assets]   Checking if promo video subtitles needs downloading or updating...
[sync-assets]           cs.vtt is missing, downloading...
[...]
[sync-assets]           sv.vtt is missing, downloading...
[sync-assets]           zh.vtt is missing, downloading...
[sync-assets] Downloaded 15 and skipped 0 existing video subtitles
[sync-assets]   Checking if promo video needs downloading or updating...
[sync-assets]           mempool-promo.mp4 is missing, downloading...
[sync-assets] Asset synchronization complete
```

</details>

* Come back to the `admin` user:

{% code overflow="wrap" %}
```bash
exit
```
{% endcode %}

* Sync the frontend files with the system and enforce secure ownership and permissions:

{% code overflow="wrap" %}
```sh
sudo install -d -o root -g www-data -m 750 /var/www/mempool && sudo rsync -av --delete --chown=root:www-data --chmod=Du=rwx,Dg=rx,Do=,Fu=rw,Fg=r,Fo= /home/mempool/mempool/frontend/dist/mempool/ /var/www/mempool/
```
{% endcode %}

**Example** of expected output:

```
sending incremental file list
./
browser/
browser/ar/
browser/ar/145.402fa264d97bba59.js
browser/ar/157.2df7772ae29172f4.js
browser/ar/182.4e706d686573f1fd.js
browser/ar/186.72c3aaea3ccb7da7.js
browser/ar/234.af0279b522d98205.js
browser/ar/250.fe095df6f76279e9.js
browser/ar/26.8b1eb37670b55331.js
browser/ar/261.77e664b654fa24cb.js
browser/ar/302.adf628dedcbb03a0.js
browser/ar/354.a645b30dd813fade.js
browser/ar/371.72bde6d9e427ae99.js
browser/ar/3rdpartylicenses.txt
browser/ar/43.a270c58959454271.js
browser/ar/463.7ad9cb9dd13df7b9.js
browser/ar/559.f762aee258dd47cb.js
browser/ar/596.69798d4b991d0eb5.js
browser/ar/61.0162bed7f92ccc54.js
[...]
browser/zh/softsimon.3317e60f53003eb7.css
browser/zh/softsimon.css
browser/zh/styles.5360fdbcf9ef97cb.css

sent 203,394,210 bytes  received 34,025 bytes  135,618,823.33 bytes/sec
total size is 203,208,811  speedup is 1.00
```

## **Configuration**

### **Create systemd service**

* As user `admin`, create the service file:

```bash
sudo nano /etc/systemd/system/mempool.service
```

* Paste the following configuration. Save and exit.

```
# MiniBolt: systemd unit for Mempool
# /etc/systemd/system/mempool.service

[Unit]
Description=Mempool - a Bitcoin blockchain mempool visualizer
Requires=mariadb.service bitcoind.service fulcrum.service
After=mariadb.service bitcoind.service fulcrum.service

[Service]
WorkingDirectory=/home/mempool/mempool/backend
ExecStart=/usr/bin/node --max-old-space-size=2048 dist/index.js

User=mempool
Group=mempool

# Process management
####################
TimeoutSec=300
KillSignal=SIGINT

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

```bash
sudo systemctl enable mempool
```

* Prepare “mempool” monitoring by the systemd journal and check the logging output. You can exit monitoring at any time with `Ctrl-C`

```bash
journalctl -fu mempool
```

## **Run**

To keep an eye on the software movements, [start your SSH program](../../index-1/remote-access.md) (eg, PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`

* Start mempool:

```bash
sudo systemctl start mempool
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>journalctl -fu mempool</code> ⬇️</summary>

```
Apr 13 12:14:57 [589760] NOTICE: Starting Mempool Server... (e150a00)
Apr 13 12:14:57 [589760] INFO: Connected to Electrum Server at 127.0.0.1:50001 (["Fulcrum 2.1.0","1.4"])
Apr 13 12:14:57 [589760] INFO: Database connection established.
Apr 13 12:14:57 [589760] DEBUG: MIGRATIONS: Running migrations
Apr 13 12:14:57 [589760] DEBUG: MIGRATIONS: Database engine version '10.6.25-MariaDB-ubu2204'
Apr 13 12:14:57 [589760] DEBUG: MIGRATIONS: `state` table does not exist. Creating it.
Apr 13 12:14:57 [589760] DEBUG: MIGRATIONS: Execute query:
CREATE TABLE IF NOT EXISTS state (
      name varchar(25) NOT NULL,
      number int(11) NULL,
      string varchar(100) NULL,
      CONSTRAINT name_unique UNIQUE (name)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
Apr 13 12:14:57 [589760] DEBUG: MIGRATIONS: Execute query:
INSERT INTO state VALUES('schema_version', 0, NULL);
Apr 13 12:14:57 [589760] DEBUG: MIGRATIONS: Execute query:
INSERT INTO state VALUES('last_elements_block', 0, NULL);
Apr 13 12:14:57 [589760] DEBUG: MIGRATIONS: `state` table initialized.
Apr 13 12:14:57 [589760] INFO: Initializing database (first run, clean install)
Apr 13 12:14:57 [589760] NOTICE: 'blocks' table has been truncated.
Apr 13 12:14:57 [589760] NOTICE: 'hashrates' table has been truncated.
Apr 13 12:14:57 [589760] DEBUG: MIGRATIONS: Current state.schema_version 0
Apr 13 12:14:57 [589760] DEBUG: MIGRATIONS: Latest DatabaseMigration.version is 109
Apr 13 12:14:57 [589760] DEBUG: MIGRATIONS: `statistics.added` is not indexed
Apr 13 12:14:57 [589760] DEBUG: MIGRATIONS: Execute query:
CREATE TABLE IF NOT EXISTS elements_pegs (
      block int(11) NOT NULL,
      datetime int(11) NOT NULL,
      amount bigint(20) NOT NULL,
      txid varchar(65) NOT NULL,
      txindex int(11) NOT NULL,
      bitcoinaddress varchar(100) NOT NULL,
      bitcointxid varchar(65) NOT NULL,
      bitcoinindex int(11) NOT NULL,
      final_tx int(11) NOT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
Apr 13 12:14:57 [589760] DEBUG: MIGRATIONS: Execute query:
CREATE TABLE IF NOT EXISTS statistics (
      id int(11) NOT NULL AUTO_INCREMENT,
      added datetime NOT NULL,
      unconfirmed_transactions int(11) UNSIGNED NOT NULL,
      tx_per_second float UNSIGNED NOT NULL,
      vbytes_per_second int(10) UNSIGNED NOT NULL,
      mempool_byte_weight int(10) UNSIGNED NOT NULL,
      fee_data longtext NOT NULL,
      total_fee double UNSIGNED NOT NULL,
      vsize_1 int(11) NOT NULL,
[...]
Apr 13 12:15:02 [589760] NOTICE: MIGRATIONS: OK. Database schema has been properly initialized to version 109 (latest version)
Apr 13 12:15:02 [589760] DEBUG: [PoolsUpdater] pools-v2.json sha | Current: null | Github: 6cf5390bd0cd84323f9043daf4ab78e7438965b6
Apr 13 12:15:02 [589760] INFO: [PoolsUpdater] Downloading pools-v2.json for the first time from https://raw.githubusercontent.com/mempool/mining-pools/master/pools-v2.json over clearnet
Apr 13 12:15:03 [589760] DEBUG: Inserting new mining pool BlockFills
Apr 13 12:15:03 [589760] DEBUG: Inserting new mining pool ULTIMUSPOOL
Apr 13 12:15:03 [589760] DEBUG: Inserting new mining pool Terra Pool
Apr 13 12:15:03 [589760] DEBUG: Inserting new mining pool Luxor
Apr 13 12:15:03 [589760] DEBUG: Inserting new mining pool 1THash
Apr 13 12:15:03 [589760] DEBUG: Inserting new mining pool BTC.com
Apr 13 12:15:03 [589760] DEBUG: Inserting new mining pool Bitfarms
Apr 13 12:15:03 [589760] DEBUG: Inserting new mining pool Huobi.pool
Apr 13 12:15:03 [589760] WARN: Mining pool WAYI.CN has no 'addresses' defined.
Apr 13 12:15:03 [589760] DEBUG: Inserting new mining pool WAYI.CN
Apr 13 12:15:03 [589760] DEBUG: Inserting new mining pool CanoePool
Apr 13 12:15:03 [589760] DEBUG: Inserting new mining pool BTC.TOP
Apr 13 12:15:03 [589760] WARN: Mining pool Bitcoin.com has no 'addresses' defined.
[...]
Apr 13 12:30:36 [589760] DEBUG: [Mining] Indexing block #934708 | ~9.54 blocks/sec | total: 10817/11000 (98.34%) | elapsed: 890.05 seconds
Apr 13 12:30:41 [589760] DEBUG: [Mining] Indexing block #934755 | ~9.33 blocks/sec | total: 10864/11000 (98.76%) | elapsed: 895.09 seconds
Apr 13 12:30:46 [589760] DEBUG: [Mining] Indexing block #934795 | ~7.93 blocks/sec | total: 10904/11000 (99.13%) | elapsed: 900.14 seconds
Apr 13 12:30:49 [589760] DEBUG: Updating mempool...
Apr 13 12:30:49 [589760] DEBUG: fetched 74 transactions
Apr 13 12:30:49 [589760] DEBUG: 0 websocket clients | 0 connected | 0 disconnected | (+0)
Apr 13 12:30:49 [589760] DEBUG: websocket subscriptions: track-tx: 0, track-txs: 0, track-mempool-block: 0 track-rbf: 0
Apr 13 12:30:49 [589760] DEBUG: RUST updateBlockTemplates returned 708 txs out of 708 candidates, 0 were unmineable
Apr 13 12:30:49 [589760] DEBUG: RUST updateBlockTemplates completed in 0.007 seconds
Apr 13 12:30:49 [589760] DEBUG: Mempool updated in 0.053 seconds. New size: 708 (+73)
Apr 13 12:30:51 [589760] DEBUG: [Mining] Indexing block #934839 | ~8.65 blocks/sec | total: 10948/11000 (99.53%) | elapsed: 905.22 seconds
Apr 13 12:30:56 [589760] NOTICE: [Mining] Block indexing completed: indexed 10991 blocks
Apr 13 12:30:56 [589760] DEBUG: validated best chain of 944892 blocks in 56 ms
Apr 13 12:30:56 [589760] DEBUG: [Mining] Blocks prices indexer will run now
Apr 13 12:30:56 [589760] DEBUG: [Mining] Linking 10991 blocks to their closest price
Apr 13 12:30:56 [589760] INFO: [Mining] Indexed 5 difficulty adjustments
Apr 13 12:30:56 [589760] NOTICE: hashrates will now be re-indexed
Apr 13 12:30:56 [589760] DEBUG: [Mining] Indexing daily network hashrate
Apr 13 12:30:56 [589760] INFO: [Mining] Indexing blocks prices completed. Indexed 10991
Apr 13 12:30:57 [589760] INFO: [Mining] Daily network hashrate indexing completed: indexed 77 days
Apr 13 12:30:57 [589760] DEBUG: [Mining] Indexing weekly mining pool hashrate
Apr 13 12:30:57 [589760] INFO: [Mining] Weekly mining pools hashrates indexing completed: indexed 11 weeks
Apr 13 12:30:57 [589760] INFO: migrated 0 audits to version 1
Apr 13 12:30:57 [589760] NOTICE: Migrating blocks to version 1 completed: migrated 0 blocks
Apr 13 12:30:57 [589760] DEBUG: Indexing completed. Next run planned at Mon, 13 Apr 2026 13:30:57 GMT
Apr 13 12:31:00 [589760] DEBUG: Running statistics
Apr 13 12:31:00 [589760] DEBUG: 0 websocket clients | 0 connected | 0 disconnected | (+0)
Apr 13 12:31:00 [589760] DEBUG: websocket subscriptions: track-tx: 0, track-txs: 0, track-mempool-block: 0 track-rbf: 0
Apr 13 12:31:07 [589760] DEBUG: Memory usage: 0.17 GB / 2.05 GB
Apr 13 12:31:09 [589760] DEBUG: Updating mempool...
Apr 13 12:31:09 [589760] DEBUG: fetched 6 transactions
[...]
```

</details>

{% hint style="info" %}
* During the first startup, Mempool performs an initial indexing process of recent blockchain data required for mining statistics and historical analysis. You may see logs such as:

```
[Mining] Indexing block #936864 | ~7.61 blocks/sec | total: 1676/11000 (15.24%)
```

* This process can take **from several minutes up to a few hours**, depending on your hardware. Mempool will continue running and remains accessible during this phase; however, full functionality is not available until indexing is complete. While **you can proceed with the installation and use the interface**, some data (such as mining metrics and historical insights) may be incomplete until the process finishes.
* These logs indicate that the initial indexing process has finished:

```
[...]
Apr 15 15:52:30 minibolt node[1670485]: Apr 15 15:52:30 [1670485] NOTICE: [Mining] Block indexing completed: indexed 10991 blocks
Apr 15 15:52:30 minibolt node[1670485]: Apr 15 15:52:30 [1670485] DEBUG: validated best chain of 945200 blocks in 64 ms
Apr 15 15:52:30 minibolt node[1670485]: Apr 15 15:52:30 [1670485] DEBUG: [Mining] Blocks prices indexer will run now
Apr 15 15:52:31 minibolt node[1670485]: Apr 15 15:52:31 [1670485] INFO: [Mining] Indexed 5 difficulty adjustments
Apr 15 15:52:31 minibolt node[1670485]: Apr 15 15:52:31 [1670485] NOTICE: hashrates will now be re-indexed
Apr 15 15:52:31 minibolt node[1670485]: Apr 15 15:52:31 [1670485] DEBUG: [Mining] Linking 10994 blocks to their closest price
Apr 15 15:52:31 minibolt node[1670485]: Apr 15 15:52:31 [1670485] DEBUG: [Mining] Indexing daily network hashrate
Apr 15 15:52:31 minibolt node[1670485]: Apr 15 15:52:31 [1670485] INFO: [Mining] Daily network hashrate indexing completed: indexed 76 days
Apr 15 15:52:31 minibolt node[1670485]: Apr 15 15:52:31 [1670485] DEBUG: [Mining] Indexing weekly mining pool hashrate
Apr 15 15:52:31 minibolt node[1670485]: Apr 15 15:52:31 [1670485] INFO: [Mining] Indexing blocks prices completed. Indexed 10994
Apr 15 15:52:31 minibolt node[1670485]: Apr 15 15:52:31 [1670485] INFO: [Mining] Weekly mining pools hashrates indexing completed: indexed 11 weeks
Apr 15 15:52:31 minibolt node[1670485]: Apr 15 15:52:31 [1670485] INFO: migrated 0 audits to version 1
Apr 15 15:52:31 minibolt node[1670485]: Apr 15 15:52:31 [1670485] NOTICE: Migrating blocks to version 1 completed: migrated 0 blocks
Apr 15 15:52:31 minibolt node[1670485]: Apr 15 15:52:31 [1670485] DEBUG: Indexing completed. Next run planned at Wed, 15 Apr 2026 16:52:31 GMT
Apr 15 15:52:39 minibolt node[1670485]: Apr 15 15:52:39 [1670485] DEBUG: Updating mempool...
Apr 15 15:52:39 minibolt node[1670485]: Apr 15 15:52:39 [1670485] DEBUG: fetched 76 transactions
Apr 15 15:52:39 minibolt node[1670485]: Apr 15 15:52:39 [1670485] DEBUG: 0 websocket clients | 0 connected | 0 disconnected | (+0)
[...]
```
{% endhint %}

***

<details>

<summary>The previous output is related to the first run (index process), next times should be like this, with <code>journalctl -fu mempool</code> ⬇️</summary>

```
pr 15 10:23:36 minibolt systemd[1]: Started Mempool - a Bitcoin blockchain mempool visualizer.
Apr 15 10:23:36 minibolt node[1564876]: Apr 15 10:23:36 [1564876] NOTICE: Starting Mempool Server... (e150a00)
Apr 15 10:23:36 minibolt node[1564876]: Apr 15 10:23:36 [1564876] INFO: Connected to Electrum Server at 127.0.0.1:50001 (["Fulcrum 2.1.0","1.4"])
Apr 15 10:23:36 minibolt node[1564876]: Apr 15 10:23:36 [1564876] INFO: Database connection established.
Apr 15 10:23:36 minibolt node[1564876]: Apr 15 10:23:36 [1564876] DEBUG: MIGRATIONS: Running migrations
Apr 15 10:23:36 minibolt node[1564876]: Apr 15 10:23:36 [1564876] DEBUG: MIGRATIONS: Database engine version '10.6.25-MariaDB-ubu2204'
Apr 15 10:23:36 minibolt node[1564876]: Apr 15 10:23:36 [1564876] DEBUG: MIGRATIONS: Current state.schema_version 109
Apr 15 10:23:36 minibolt node[1564876]: Apr 15 10:23:36 [1564876] DEBUG: MIGRATIONS: Latest DatabaseMigration.version is 109
Apr 15 10:23:36 minibolt node[1564876]: Apr 15 10:23:36 [1564876] DEBUG: MIGRATIONS: Nothing to do.
Apr 15 10:23:36 minibolt node[1564876]: Apr 15 10:23:36 [1564876] DEBUG: [PoolsUpdater] pools-v2.json sha | Current: 6cf5390bd0cd84323f9043daf4ab78e7438965b6 | Github: 6cf5390bd0cd84323f9043daf4ab78e7438965b6
Apr 15 10:23:37 minibolt node[1564876]: Apr 15 10:23:37 [1564876] INFO: Restoring mempool and blocks data from disk cache
Apr 15 10:23:37 minibolt node[1564876]: Apr 15 10:23:37 [1564876] INFO: Loaded mempool from disk cache in 585 ms
Apr 15 10:23:37 minibolt node[1564876]: Apr 15 10:23:37 [1564876] DEBUG: 0 websocket clients | 0 connected | 0 disconnected | (+0)
Apr 15 10:23:37 minibolt node[1564876]: Apr 15 10:23:37 [1564876] DEBUG: websocket subscriptions: track-tx: 0, track-txs: 0, track-mempool-block: 0 track-rbf: 0
Apr 15 10:23:37 minibolt node[1564876]: Apr 15 10:23:37 [1564876] DEBUG: RUST updateBlockTemplates returned 3925 txs out of 3925 in the mempool, 0 were unmineable
Apr 15 10:23:37 minibolt node[1564876]: Apr 15 10:23:37 [1564876] DEBUG: RUST makeBlockTemplates completed in 0.049 seconds
Apr 15 10:23:37 minibolt node[1564876]: Apr 15 10:23:37 [1564876] INFO: Restoring rbf data from disk cache
Apr 15 10:23:38 minibolt node[1564876]: Apr 15 10:23:38 [1564876] DEBUG: loaded 9591 txs, 3620 trees into rbf cache, 9514 due to expire, 0 were stale
Apr 15 10:23:38 minibolt node[1564876]: Apr 15 10:23:38 [1564876] DEBUG: rbf cache contains 9163 txs, 3486 trees, 9122 due to expire (42 newly expired)
Apr 15 10:23:38 minibolt node[1564876]: Apr 15 10:23:38 [1564876] INFO: Starting statistics service
Apr 15 10:23:38 minibolt node[1564876]: Apr 15 10:23:38 [1564876] DEBUG: [Mining] Inserted 0 MtGox USD weekly price history into db
Apr 15 10:23:38 minibolt node[1564876]: Apr 15 10:23:38 [1564876] DEBUG: Updated orphaned blocks cache. Fetched 1 new orphaned blocks. Total 1
Apr 15 10:23:38 minibolt node[1564876]: Apr 15 10:23:38 [1564876] NOTICE: Mempool Server is running on port 8999
Apr 15 10:23:38 minibolt node[1564876]: Apr 15 10:23:38 [1564876] DEBUG: Initial difficulty adjustment data set.
Apr 15 10:23:38 minibolt node[1564876]: Apr 15 10:23:38 [1564876] DEBUG: Updating mempool...
Apr 15 10:23:38 minibolt node[1564876]: Apr 15 10:23:38 [1564876] DEBUG: [Mining] Fetching daily price history from exchanges and saving missing ones into the database
Apr 15 10:23:39 minibolt node[1564876]: Apr 15 10:23:39 [1564876] DEBUG: fetched 151 transactions
Apr 15 10:23:39 minibolt node[1564876]: Apr 15 10:23:39 [1564876] DEBUG: 0 websocket clients | 0 connected | 0 disconnected | (+0)
Apr 15 10:23:39 minibolt node[1564876]: Apr 15 10:23:39 [1564876] DEBUG: websocket subscriptions: track-tx: 0, track-txs: 0, track-mempool-block: 0 track-rbf: 0
[...]
Apr 15 10:24:04 minibolt node[1564876]: Apr 15 10:24:04 [1564876] DEBUG: RUST updateBlockTemplates returned 1246 txs out of 1246 candidates, 0 were unmineable
Apr 15 10:24:04 minibolt node[1564876]: Apr 15 10:24:04 [1564876] DEBUG: RUST updateBlockTemplates completed in 0.007 seconds
Apr 15 10:24:04 minibolt node[1564876]: Apr 15 10:24:04 [1564876] DEBUG: Mempool updated in 0.011 seconds. New size: 1246 (+3)
Apr 15 10:24:06 minibolt node[1564876]: Apr 15 10:24:06 [1564876] DEBUG: Updating mempool...
Apr 15 10:24:06 minibolt node[1564876]: Apr 15 10:24:06 [1564876] DEBUG: fetched 11 transactions
Apr 15 10:24:06 minibolt node[1564876]: Apr 15 10:24:06 [1564876] DEBUG: 0 websocket clients | 0 connected | 0 disconnected | (+0)
Apr 15 10:24:06 minibolt node[1564876]: Apr 15 10:24:06 [1564876] DEBUG: websocket subscriptions: track-tx: 0, track-txs: 0, track-mempool-block: 0 track-rbf: 0
Apr 15 10:24:06 minibolt node[1564876]: Apr 15 10:24:06 [1564876] DEBUG: RUST updateBlockTemplates returned 1257 txs out of 1257 candidates, 0 were unmineable
Apr 15 10:24:06 minibolt node[1564876]: Apr 15 10:24:06 [1564876] DEBUG: RUST updateBlockTemplates completed in 0.008 seconds
Apr 15 10:24:06 minibolt node[1564876]: Apr 15 10:24:06 [1564876] DEBUG: Mempool updated in 0.018 seconds. New size: 1257 (+11)
Apr 15 10:24:08 minibolt node[1564876]: Apr 15 10:24:08 [1564876] DEBUG: Updating mempool...
Apr 15 10:24:08 minibolt node[1564876]: Apr 15 10:24:08 [1564876] DEBUG: fetched 6 transactions
Apr 15 10:24:08 minibolt node[1564876]: Apr 15 10:24:08 [1564876] DEBUG: 0 websocket clients | 0 connected | 0 disconnected | (+0)
[...]
```

</details>

### Validation

* Ensure the service is working and listening on the default HTTP port `8999` and SSL `4081` port

```bash
sudo ss -tulpn | grep -v 'dotnet' | grep -E '(:8001|:8999|:4081)'
```

Expected output:

```
tcp   LISTEN 0      511          0.0.0.0:4081       0.0.0.0:*    users:(("nginx",pid=682516,fd=20),("nginx",pid=682515,fd=20),("nginx",pid=682514,fd=20),("nginx",pid=682513,fd=20),("nginx",pid=682512,fd=20),("nginx",pid=682511,fd=20),("nginx",pid=65839,fd=20))
tcp   LISTEN 0      511        127.0.0.1:8001       0.0.0.0:*    users:(("nginx",pid=682516,fd=21),("nginx",pid=682515,fd=21),("nginx",pid=682514,fd=21),("nginx",pid=682513,fd=21),("nginx",pid=682512,fd=21),("nginx",pid=682511,fd=21),("nginx",pid=65839,fd=21))
tcp   LISTEN 0      511                *:8999             *:*    users:(("node",pid=627565,fd=27))
```

{% hint style="info" %}
> Your browser will display a warning because we use a self-signed SSL certificate. We can do nothing about that because we would need a proper domain name (e.g., https://yournode.com) to get an official certificate that browsers recognize. Click on "Advanced" and proceed to the Mempool web interface.

> Now point your browser to `https://minibolt.local:4081` or the IP address (e.g. `https://192.168.x.xxx:4081`). You should see the home page of Mempool.
{% endhint %}

{% hint style="success" %}
Congrat&#x73;**!** You now have Mempool up and running.
{% endhint %}

## Extras (optional)

### Enable Lightning with a local LND node

{% hint style="info" %}
**Keep in mind:** you need to have a [LND](../../lightning/lightning-client.md) node already running and synchronized, and for a better experience with a public channel, at least.
{% endhint %}

#### Backend

{% hint style="info" %}
Unlike the [frontend](mempool.md#frontend), the backend configuration can be changed at any time after installation, just like the systemd service.
{% endhint %}

* Stop the mempool service:

{% code overflow="wrap" %}
```bash
sudo systemctl stop mempool
```
{% endcode %}

* Change to the user mempool:

{% code overflow="wrap" %}
```bash
sudo su - mempool
```
{% endcode %}

* Create the GeoIP folder:

{% code overflow="wrap" %}
```bash
mkdir -p /home/mempool/mempool/backend/GeoIP
```
{% endcode %}

* Download `GeoLite2-City` and `GeoLite2-ASN` databases:

{% code overflow="wrap" %}
```bash
wget -P mempool/backend/GeoIP https://raw.githubusercontent.com/mempool/geoip-data/master/GeoLite2-City.mmdb
```
{% endcode %}

{% code overflow="wrap" %}
```bash
wget -P mempool/backend/GeoIP https://raw.githubusercontent.com/mempool/geoip-data/master/GeoLite2-ASN.mmdb
```
{% endcode %}

* Edit the `mempool-config.json` file:

```bash
nano /home/mempool/mempool/backend/mempool-config.json
```

* Replace the complete config with this or add the "`MAXMIND`", "`LIGHTNING`" and "`LND`" sections at the end of the file. Save and exit.

<pre data-overflow="wrap"><code>{
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
    "PORT": 50001,
    "TLS_ENABLED": false
  },
  "DATABASE": {
    "ENABLED": true,
    "HOST": "127.0.0.1",
    "PORT": 3306,
    "USERNAME": "admin",
    "PASSWORD": "admin",
    "DATABASE": "mempool"
  },
  "<a data-footnote-ref href="#user-content-fn-4">MAXMIND</a>": {
    "ENABLED": true,
    "GEOLITE2_CITY": "/home/mempool/mempool/backend/GeoIP/GeoLite2-City.mmdb",
    "GEOLITE2_ASN": "/home/mempool/mempool/backend/GeoIP/GeoLite2-ASN.mmdb"
  },
  "<a data-footnote-ref href="#user-content-fn-4">LIGHTNING</a>": {
    "ENABLED": true,
    "BACKEND": "lnd",
    "STATS_REFRESH_INTERVAL": 600,
    "GRAPH_REFRESH_INTERVAL": 600,
    "LOGGER_UPDATE_INTERVAL": 30,
    "FORENSICS_INTERVAL": 43200,
    "FORENSICS_RATE_LIMIT": 20
  },
  "<a data-footnote-ref href="#user-content-fn-4">LND</a>": {
    "TLS_CERT_PATH": "/data/lnd/tls.cert",
    "MACAROON_PATH": "/data/lnd/data/chain/bitcoin/mainnet/readonly.macaroon",
    "REST_API_URL": "https://localhost:8080",
    "TIMEOUT": 10000
  }
}
</code></pre>

* Come back to the `admin` user:

{% code overflow="wrap" %}
```bash
exit
```
{% endcode %}

#### Systemd service

* Edit the `mempool.service` file

{% code overflow="wrap" %}
```bash
sudo nano /etc/systemd/system/mempool.service
```
{% endcode %}

* Add the new `lnd.service` dependence in these lines. Save and exit

<pre data-overflow="wrap"><code>Requires=mariadb.service bitcoind.service fulcrum.service <a data-footnote-ref href="#user-content-fn-5">lnd.service</a>
After=mariadb.service bitcoind.service fulcrum.service <a data-footnote-ref href="#user-content-fn-5">lnd.service</a>
</code></pre>

* Reload the systemctl daemon to apply changes

{% code overflow="wrap" %}
```bash
sudo systemctl daemon-reload
```
{% endcode %}

* Start mempool again

{% code overflow="wrap" %}
```bash
sudo systemctl start mempool
```
{% endcode %}

* (Optional) Check if all is running fine again

{% code overflow="wrap" %}
```bash
journalctl -fu mempool
```
{% endcode %}

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
Apr 15 10:15:03 minibolt systemd[1]: Started Mempool - a Bitcoin blockchain mempool visualizer.
Apr 15 10:15:04 minibolt node[1561962]: Apr 15 10:15:04 [1561962] NOTICE: <lightning> Starting Mempool Server... (e150a00)
Apr 15 10:15:04 minibolt node[1561962]: Apr 15 10:15:04 [1561962] INFO: <lightning> Connected to Electrum Server at 127.0.0.1:50001 (["Fulcrum 2.1.0","1.4"])
Apr 15 10:15:04 minibolt node[1561962]: Apr 15 10:15:04 [1561962] INFO: <lightning> Database connection established.
Apr 15 10:15:04 minibolt node[1561962]: Apr 15 10:15:04 [1561962] DEBUG: <lightning> MIGRATIONS: Running migrations
Apr 15 10:15:04 minibolt node[1561962]: Apr 15 10:15:04 [1561962] DEBUG: <lightning> MIGRATIONS: Database engine version '10.6.25-MariaDB-ubu2204'
Apr 15 10:15:04 minibolt node[1561962]: Apr 15 10:15:04 [1561962] DEBUG: <lightning> MIGRATIONS: Current state.schema_version 109
Apr 15 10:15:04 minibolt node[1561962]: Apr 15 10:15:04 [1561962] DEBUG: <lightning> MIGRATIONS: Latest DatabaseMigration.version is 109
Apr 15 10:15:04 minibolt node[1561962]: Apr 15 10:15:04 [1561962] DEBUG: <lightning> MIGRATIONS: Nothing to do.
Apr 15 10:15:05 minibolt node[1561962]: Apr 15 10:15:05 [1561962] DEBUG: <lightning> [PoolsUpdater] pools-v2.json sha | Current: 6cf5390bd0cd84323f9043daf4ab78e7438965b6 | Github: 6cf5390bd0cd84323f9043daf4ab78e7438965b6
Apr 15 10:15:05 minibolt node[1561962]: Apr 15 10:15:05 [1561962] INFO: <lightning> Restoring mempool and blocks data from disk cache
Apr 15 10:15:06 minibolt node[1561962]: Apr 15 10:15:06 [1561962] INFO: <lightning> Loaded mempool from disk cache in 576 ms
Apr 15 10:15:06 minibolt node[1561962]: Apr 15 10:15:06 [1561962] DEBUG: <lightning> 0 websocket clients | 0 connected | 0 disconnected | (+0)
Apr 15 10:15:06 minibolt node[1561962]: Apr 15 10:15:06 [1561962] DEBUG: <lightning> websocket subscriptions: track-tx: 0, track-txs: 0, track-mempool-block: 0 track-rbf: 0
Apr 15 10:15:06 minibolt node[1561962]: Apr 15 10:15:06 [1561962] DEBUG: <lightning> RUST updateBlockTemplates returned 2350 txs out of 2350 in the mempool, 0 were unmineable
Apr 15 10:15:06 minibolt node[1561962]: Apr 15 10:15:06 [1561962] DEBUG: <lightning> RUST makeBlockTemplates completed in 0.033 seconds
Apr 15 10:15:06 minibolt node[1561962]: Apr 15 10:15:06 [1561962] INFO: <lightning> Restoring rbf data from disk cache
Apr 15 10:15:07 minibolt node[1561962]: Apr 15 10:15:07 [1561962] DEBUG: <lightning> loaded 9531 txs, 3596 trees into rbf cache, 9464 due to expire, 0 were stale
Apr 15 10:15:07 minibolt node[1561962]: Apr 15 10:15:07 [1561962] DEBUG: <lightning> rbf cache contains 9531 txs, 3596 trees, 9478 due to expire (55 newly expired)
Apr 15 10:15:07 minibolt node[1561962]: Apr 15 10:15:07 [1561962] INFO: <lightning> Starting statistics service
Apr 15 10:15:07 minibolt node[1561962]: Apr 15 10:15:07 [1561962] DEBUG: <lightning> [Mining] Inserted 0 MtGox USD weekly price history into db
Apr 15 10:15:07 minibolt node[1561962]: Apr 15 10:15:07 [1561962] DEBUG: <lightning> Updated orphaned blocks cache. Fetched 1 new orphaned blocks. Total 1
Apr 15 10:15:07 minibolt node[1561962]: Apr 15 10:15:07 [1561962] NOTICE: <lightning> Mempool Server is running on port 8999
Apr 15 10:15:07 minibolt node[1561962]: Apr 15 10:15:07 [1561962] DEBUG: <lightning> [Lightning] Imported 51086 funding tx amount from the disk cache
Apr 15 10:15:07 minibolt node[1561962]: Apr 15 10:15:07 [1561962] INFO: <lightning> [Lightning] Starting lightning network sync service
Apr 15 10:15:07 minibolt node[1561962]: Apr 15 10:15:07 [1561962] DEBUG: <lightning> [Lightning] Updating nodes and channels
Apr 15 10:15:07 minibolt node[1561962]: Apr 15 10:15:07 [1561962] DEBUG: <lightning> Initial difficulty adjustment data set.
[...]
Apr 15 10:16:25 minibolt node[1561962]: Apr 15 10:16:25 [1561962] DEBUG: <lightning> [Lightning] 44255 channels updated
Apr 15 10:16:26 minibolt node[1561962]: Apr 15 10:16:26 [1561962] DEBUG: <lightning> [Lightning] Marked 10 channels as inactive because they are not in the graph
Apr 15 10:16:26 minibolt node[1561962]: Apr 15 10:16:26 [1561962] DEBUG: <lightning> [Lightning] Find channels which nodes are offline
Apr 15 10:16:26 minibolt node[1561962]: Apr 15 10:16:26 [1561962] DEBUG: <lightning> [Lightning] Running channel creation date lookup
Apr 15 10:16:26 minibolt node[1561962]: Apr 15 10:16:26 [1561962] DEBUG: <lightning> [Lightning] Updated 1 channels' creation date
Apr 15 10:16:27 minibolt node[1561962]: Apr 15 10:16:27 [1561962] DEBUG: <lightning> [Lightning] Starting closed channels scan for the first time
[...]
Apr 15 10:16:39 minibolt node[1561962]: Apr 15 10:16:39 [1561962] DEBUG: <lightning> [Lightning] Checking if channel has been closed 6500/50721
```

</details>

#### Frontend

{% hint style="info" %}
If you want to have the mempool Lightning explorer and tab-associated enabled and connected to your internal LND node, for the frontend, you need to repeat the complete [Install frontend](mempool.md#install-the-frontend) installation section, keeping in mind to modify the parameter `"LIGHTNING": false,` to -> true ( `"LIGHTNING": true,`) in `mempool-frontend-config.json` file
{% endhint %}

### Use Electrs like Electrum server

If you followed the [Electrs](../../bonus/bitcoin/electrs.md) instead of the [Fulcrum](../../bitcoin/bitcoin/electrum-server.md) guide, you need to do the next steps

* As user `admin`, stop the mempool service

```bash
sudo systemctl stop mempool
```

* Edit the mempool service

```sh
sudo nano /etc/systemd/system/mempool.service
```

* Replace the `fulcrum.service` with the `electrs.service`. Save and exit

<pre><code>Requires=mariadb.service bitcoind.service <a data-footnote-ref href="#user-content-fn-6">electrs.service</a> <a data-footnote-ref href="#user-content-fn-7">lnd.service</a>
After=mariadb.service bitcoind.service <a data-footnote-ref href="#user-content-fn-6">electrs.service</a> <a data-footnote-ref href="#user-content-fn-7">lnd.service</a>
</code></pre>

* Reload the systemctl daemon to apply changes

```bash
sudo systemctl daemon-reload
```

* Start the mempool service again

```sh
sudo systemctl start mempool
```

* (Optional) Check if all is running fine with

{% code overflow="wrap" %}
```bash
journalctl -fu mempool
```
{% endcode %}

### Remote access over Tor

* With the user `admin`, edit the `torrc` file

```bash
sudo nano +63 /etc/tor/torrc --linenumbers
```

* Add the following lines in the "location hidden services" section, below "`## This section is just for location-hidden services ##`". Save and exit

```
# Hidden Service Mempool
HiddenServiceDir /var/lib/tor/hidden_service_mempool/
HiddenServiceEnableIntroDoSDefense 1
HiddenServicePoWDefensesEnabled 1
HiddenServicePort 80 127.0.0.1:8001
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

### Use Cloudflare tunnel to expose publicly

You may want to expose your Mempool publicly using a clearnet address. To do this, follow the next steps:

* Follow the [Cloudflare tunnel](../networking/cloudflare-tunnel.md) guide to install and create the Cloudflare tunnel from your MiniBolt to Cloudflare
* When you finish the [Create a tunnel and give it a name](../networking/cloudflare-tunnel.md#id-3-create-a-tunnel-and-give-it-a-name) section, you can skip the [Start routing traffic](../networking/cloudflare-tunnel.md#id-5-start-routing-traffic) section and go to your [Cloudflare account](https://dash.cloudflare.com/login) -> From the left sidebar, select **Websites,** click on your site, and again from the new left sidebar, click on **DNS -> Records**
* Click on the **\[+ Add record]** button

<figure><img src="../../.gitbook/assets/add_new_cname_tunnel_cloudflare.png" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
> Select the **CNAME** type

> Type the selected subdomain (i.e service name "mempool") as the **Name** field

> Type the tunnel `<UUID>` of your previously obtained in the [Create a tunnel and give it a name](../networking/cloudflare-tunnel.md#id-3-create-a-tunnel-and-give-it-a-name) section as the **Target** field

> Ensure you enable the switch on the `Proxy status` field to be "Proxied"

Click on the \[Save] button to save the new DNS registry
{% endhint %}

* If you didn't follow before, continue with the [Configuration](../networking/cloudflare-tunnel.md#configuration) section of the [Cloudflare tunnel guide](../networking/cloudflare-tunnel.md) to [Increase the maximum UDP Buffer Sizes](../networking/cloudflare-tunnel.md#increase-the-maximum-udp-buffer-sizes) and [Create systemd service](../networking/cloudflare-tunnel.md#create-systemd-service)
* Edit the`config.yml`

<pre class="language-bash"><code class="lang-bash"><strong>sudo nano /home/admin/.cloudflared/config.yml
</strong></code></pre>

* Add the next lines to the `config.yml`

<pre><code># Mempool
  - hostname: <a data-footnote-ref href="#user-content-fn-8">&#x3C;subdomain></a>.<a data-footnote-ref href="#user-content-fn-9">&#x3C;domain.com></a>
    service: http://localhost:8001
</code></pre>

{% hint style="info" %}
> You can choose the subdomain you want; the above information is an example, but keep in mind to use the port `8001` and always maintaining the "`- service: http_status:404`" line at the end of the file
{% endhint %}

* Restart Cloudflared to apply changes

```bash
sudo systemctl restart cloudflared
```

{% hint style="info" %}
Try to access the newly created public access to the service by going to the `https://<subdomain>.<domain.com>`, e.g `https://mempool.domain.com`
{% endhint %}

## Upgrade

Follow the complete [Installation section](mempool.md#installation) again, replacing the environment variable `"VERSION=x.xx"` value to the latest if it has not already been changed in this guide **(at your own risk)**.

* Restart the service to apply the changes

```shellscript
sudo systemctl restart mempool
```

* Check the logs with

```shellscript
journalctl -fu mempool
```

## Uninstall

{% hint style="danger" %}
Warning: This section removes the installation. Only run these commands if you intend to uninstall
{% endhint %}

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

* Delete the `mempool` user

```shellscript
sudo userdel -rf mempool
```

Expected output:

```
userdel: mempool mail spool (/var/mail/mempool) not found
```

### Delete all Mempool files

* Delete the frontend files

```shellscript
sudo rm -rf /var/www/mempool
```

### Uninstall Tor hidden service

* Ensure that you are logged in as the user `admin` and delete or comment the following lines in the "location hidden services" section, below "`## This section is just for location-hidden services ##`" in the torrc file. Save and exit

```bash
sudo nano +63 /etc/tor/torrc --linenumbers
```

<pre><code># Hidden Service Mempool
<strong>#HiddenServiceDir /var/lib/tor/hidden_service_mempool/
</strong>#HiddenServiceEnableIntroDoSDefense 1
#HiddenServicePoWDefensesEnabled 1
#HiddenServicePort 80 127.0.0.1:8001
</code></pre>

* Reload the torrc config

```bash
sudo systemctl reload tor
```

### Uninstall reverse proxy & FW configuration

* Ensure you are logged in as the user `admin`, delete the reverse proxy config file

```bash
sudo rm /etc/nginx/sites-available/mempool-reverse-proxy.conf
```

* Delete the symbolic link

```bash
sudo rm /etc/nginx/sites-enabled/mempool-reverse-proxy.conf
```

* Test the Nginx configuration

```bash
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

* Display the UFW firewall rules, and note the number of the rules for Mempool (e.g., X below)

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

## Port reference

<table><thead><tr><th align="center">Port</th><th width="100">Protocol<select><option value="K1YTaXNgK9iY" label="TCP" color="blue"></option><option value="rBwkQwPZUMt0" label="SSL" color="blue"></option><option value="zQnHZmzcUdq4" label="UDP" color="blue"></option></select></th><th align="center">Use</th></tr></thead><tbody><tr><td align="center">8001</td><td><span data-option="K1YTaXNgK9iY">TCP</span></td><td align="center">HTTP port</td></tr><tr><td align="center">8999</td><td><span data-option="K1YTaXNgK9iY">TCP</span></td><td align="center">Default backend port</td></tr><tr><td align="center">4081</td><td><span data-option="K1YTaXNgK9iY">TCP</span></td><td align="center">HTTPS port</td></tr></tbody></table>

[^1]: Check this

[^2]: Change to 50021 in case you want to use Electrs

[^3]: Change to -> true if you want to enable the Lightning explorer feature (keeping the final comma \[","])

[^4]: Add this section

[^5]: Add this

[^6]: Replace to this

[^7]: Optional, depending if you connected mempool to your internal LND node

[^8]: Replace with the selected name of your service\
    i.e: `explorer`

[^9]: Replace with your domain\
    i.e: `domain.com`
