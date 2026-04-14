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
  * [Nginx](../../index-1/security.md#nginx)
  * MariaDB
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
If you obtain "**command not found**" output, you need to follow the MariaDB bonus guide to install it and then come back to continue with the guide
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

To create a new admin user and grant privileges to it over the mempool database, enter the next command

```sql
GRANT ALL PRIVILEGES ON mempool.* TO 'admin'@'127.0.0.1' IDENTIFIED BY 'admin';
```

Expected output:

```
Query OK, 0 rows affected (0.001 sec)
```

Apply changes

{% code overflow="wrap" %}
```sql
FLUSH PRIVILEGES;
```
{% endcode %}

Exit from MariaDB shell

```bash
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

Add the mempool user to the bitcoin and lnd groups to allow the `mempool` user to read the Bitcoin Core `.cookie` and the lnd certificate files

```bash
sudo usermod -aG bitcoin,lnd mempool
```

### Install Rustup + Cargo

* With user `admin`, change to the mempool user home folder

```bash
sudo su - mempool
```

{% hint style="info" %}
You need to follow the [Rustup + Cargo bonus guide](../system/rustup-+-cargo.md) to install it, and then come back to continue with the guide
{% endhint %}

* Check if you have Rustup installed

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

### Download and verify the source code

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
git clone https://github.com/mempool/mempool.git && cd mempool
```
{% endcode %}

* Verify the release

```bash
git verify-tag v$VERSION
```

Expected output:

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
npm install --omit=dev --omit=optional
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```

> mempool-backend@3.4-dev preinstall
> cd ../rust/gbt && npm run build-release && npm run to-backend


> gbt@3.0.1 build-release
> npm run build -- --release --strip


> gbt@3.0.1 build
> npm install --no-save @napi-rs/cli@2.18.0 && npm run check-cargo-version && napi build --platform --release --strip


added 1 package, and audited 2 packages in 913ms

1 package is looking for funding
  run `npm fund` for details

found 0 vulnerabilities

> gbt@3.0.1 check-cargo-version
> VER=$(cat rust-toolchain) ; if ! cargo version | grep "cargo $VER" >/dev/null ; then echo -e "\033[1;35m[[[[WARNING]]]]: cargo version mismatch with ./rust-toolchain version ($VER)!!!\033[0m" >&2; fi

   Compiling proc-macro2 v1.0.93
   Compiling unicode-ident v1.0.15
   Compiling once_cell v1.20.2
   Compiling memchr v2.7.4
   Compiling semver v1.0.25
   Compiling pin-project-lite v0.2.16
   Compiling regex-syntax v0.8.5
   Compiling tracing-core v0.1.33
   Compiling aho-corasick v1.1.3
   Compiling unicode-segmentation v1.12.0
   Compiling convert_case v0.6.0
   Compiling quote v1.0.38
   Compiling napi-build v2.1.4
   Compiling equivalent v1.0.1
   Compiling hashbrown v0.15.2
   Compiling lazy_static v1.5.0
   Compiling syn v2.0.96
   Compiling cfg-if v1.0.0
   Compiling regex-automata v0.4.9
   Compiling log v0.4.25
   Compiling tracing-log v0.2.0
   Compiling indexmap v2.7.1
   Compiling thread_local v1.1.8
   Compiling sharded-slab v0.1.7
   Compiling gbt v1.0.0 (/tmp/mempool/rust/gbt)
   Compiling tokio v1.51.0
   Compiling matchers v0.2.0
   Compiling napi-sys v2.4.0
   Compiling smallvec v1.13.2
   Compiling regex v1.11.1
   Compiling nu-ansi-term v0.50.3
   Compiling bitflags v2.8.0
   Compiling priority-queue v2.1.1
   Compiling bytes v1.11.1
   Compiling napi-derive-backend v1.0.75
   Compiling bytemuck v1.21.0
   Compiling tracing-attributes v0.1.28
   Compiling ctor v0.2.9
   Compiling napi-derive v2.16.13
   Compiling napi v2.16.13
   Compiling tracing v0.1.41
   Compiling tracing-subscriber v0.3.20
    Finished `release` profile [optimized] target(s) in 39.18s

> gbt@3.0.1 to-backend
> FD=${FD:-../../backend/rust-gbt/} ; rm -rf $FD && mkdir $FD && cp index.js index.d.ts package.json *.node $FD


added 133 packages, and audited 136 packages in 45s

21 packages are looking for funding
  run `npm fund` for details

2 vulnerabilities (1 high, 1 critical)

To address issues that do not require attention, run:
  npm audit fix

To address all issues, run:
  npm audit fix --force

Run `npm audit` for details.
```

</details>

* Build it

```bash
npm run build
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```

> mempool-backend@3.4-dev build
> npm run tsc && npm run create-resources


> mempool-backend@3.4-dev tsc
> ./node_modules/typescript/bin/tsc -p tsconfig.build.json


> mempool-backend@3.4-dev create-resources
> cp ./src/tasks/price-feeds/mtgox-weekly.json ./dist/tasks && node dist/api/fetch-version.js
```

</details>

* Create the configuration file

```bash
nano mempool-config.json
```

* Paste the following lines. Save and exit

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
  }
}
```

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

{% code overflow="wrap" %}
```bash
{
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
  "LIGHTNING": false,
  "HISTORICAL_PRICE": true,
  "ADDITIONAL_CURRENCIES": false,
  "ACCELERATOR": false,
  "ACCELERATOR_BUTTON": true,
  "PUBLIC_ACCELERATIONS": false,
  "STRATUM_ENABLED": false,
  "SERVICES_API": "https://mempool.space/api/v1/services"
}
```
{% endcode %}

* Install all dependencies and the necessary modules using NPM

{% hint style="warning" %}
**Not to run** the `npm audit fix` command, which could break the original code!!
{% endhint %}

```bash
npm ci --omit=dev --omit=optional
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
npm warn deprecated querystring@0.2.0: The querystring API is considered Legacy. new code should use the URLSearchParams API instead.
npm warn deprecated popper.js@1.16.1: You can find the new Popper v2 at @popperjs/core, this package is dedicated to the legacy v1

added 1126 packages, and audited 1127 packages in 26s

145 packages are looking for funding
  run `npm fund` for details

65 vulnerabilities (6 low, 12 moderate, 43 high, 4 critical)

To address issues that do not require attention, run:
  npm audit fix

To address all issues (including breaking changes), run:
  npm audit fix --force

Run `npm audit` for details.
```

</details>

* Build it

{% code overflow="wrap" %}
```bash
npm run generate-themes && npm run generate-config && npm run ng -- build --configuration production --localize && npm run sync-assets
```
{% endcode %}

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
> mempool-frontend@3.2.1 build
> npm run generate-config && npm run ng -- build --configuration production --localize && npm run sync-assets-dev && npm run sync-assets && npm run build-mempool.js


> mempool-frontend@3.2.1 generate-config
> node generate-config.js

mempool-frontend-config.json file not found, using default config
Copied src/index.mempool.html to src/index.html
mempool version 3.2.1
mempool revision 32fadb484
src/resources/config.js file not found, creating new config file
CONFIG:  (function (window) {
  window.__env = window.__env || {};
    window.__env.GIT_COMMIT_HASH = '32fadb484';
    window.__env.PACKAGE_JSON_VERSION = '3.2.1';
  }((typeof global !== 'undefined') ? global : this));
src/resources/config.js file saved

> mempool-frontend@3.2.1 ng
> ./node_modules/@angular/cli/bin/ng.js build --configuration production --localize

⠋ Generating browser application bundles (phase: setup)...    TypeScript compiler options "target" and "useDefineForClassFields" are set to "ES2022" and "false" respectively by the Angular CLI. To control ECMA version and features use the Browserslist configuration. For more information, see https://angular.io/guide/build#configuring-browser-compatibility
    NOTE: You can set the "target" to "ES2022" in the project's tsconfig to remove this warning.
⠴ Generating browser application bundles (phase: sealing)...
✔ Localized bundle generation complete.
✔ Copying assets complete.
✔ Index html generation complete.

Initial chunk files           | Names                                               |  Raw size | Estimated transfer size
main.b586fbf92cad9de2.js      | main                                                |   1.14 MB |               283.14 kB
styles.cf2a69e15c6bcb8f.css   | styles                                              | 178.38 kB |                22.21 kB
polyfills.c41df647371e42d1.js | polyfills                                           |  33.45 kB |                10.77 kB

                              | Initial total                                       |   1.35 MB |               316.13 kB

Lazy chunk files              | Names                                               |  Raw size | Estimated transfer size   
[...]
resources/wallycore/wallycore.js
resources/wallycore/wallycore.wasm

sent 16,744,490 bytes  received 3,063 bytes  33,495,106.00 bytes/sec
total size is 16,729,238  speedup is 1.00
[sync-assets] SKIP_SYNC is set, not checking any assets

> mempool-frontend@3.2.1 build-mempool.js
> npm run build-mempool-js && npm run build-mempool-liquid-js


> mempool-frontend@3.2.1 build-mempool-js
> browserify -p tinyify ./node_modules/@mempool/mempool.js/lib/index.js --standalone mempoolJS > ./dist/mempool/browser/en-US/mempool.js


> mempool-frontend@3.2.1 build-mempool-liquid-js
> browserify -p tinyify ./node_modules/@mempool/mempool.js/lib/index-liquid.js --standalone liquidJS > ./dist/mempool/browser/en-US/liquid.js

```

</details>

* Come back to the admin user

{% code overflow="wrap" %}
```bash
exit
```
{% endcode %}

* Sync the frontend files with the system and enforce secure ownership and permissions

{% code overflow="wrap" %}
```sh
sudo install -d -o root -g www-data -m 750 /var/www/mempool && sudo rsync -av --delete --chown=root:www-data --chmod=Du=rwx,Dg=rx,Do=,Fu=rw,Fg=r,Fo= /home/mempool/mempool/frontend/dist/mempool/ /var/www/mempool/
```
{% endcode %}

## **Configuration**

### **Create systemd service**

* As user `admin`, create the service file

```bash
sudo nano /etc/systemd/system/mempool.service
```

* Paste the following configuration. Save and exit

```
# MiniBolt: systemd unit for Mempool
# /etc/systemd/system/mempool.service

[Unit]
Description=Mempool - a Bitcoin blockchain mempool visualizer
Requires=bitcoind.service fulcrum.service mariadb.service
After=bitcoind.service fulcrum.service mariadb.service

[Service]
WorkingDirectory=/home/mempool/mempool/backend
ExecStart=/usr/bin/npm run start

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
```

* Enable autoboot **(optional)**

```bash
sudo systemctl enable mempool
```

* Prepare “mempool” monitoring by the systemd journal and check the logging output. You can exit monitoring at any time with Ctrl-C

```bash
journalctl -fu mempool
```

## **Run**

To keep an eye on the software movements, [start your SSH program](../../index-1/remote-access.md#access-with-secure-shell) (eg, PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`

* Start mempool

```bash
sudo systemctl start mempool
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>journalctl -fu mempool</code> ⬇️</summary>

```

> mempool-backend@3.4-dev start
> node --max-old-space-size=2048 dist/index.js

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
Apr 13 12:31:09 [589760] DEBUG: fetched 64 transactions
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
> Your browser will display a warning because we use a self-signed SSL certificate. We can do nothing about that because we would need a proper domain name (e.g., https://yournode.com) to get an official certificate that browsers recognize. Click on "Advanced" and proceed to the Mempool web interface

> Now point your browser to `https://minibolt.local:4081` or the IP address (e.g. `https://192.168.x.xxx:4081`). You should see the home page of Mempool
{% endhint %}

{% hint style="success" %}
Congrat&#x73;**!** You now have Mempool up and running
{% endhint %}

## Extras (optional)

### Enable Lightning

{% code overflow="wrap" %}
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
    "REST_API_URL": "https://localhost:8080",
    "TIMEOUT": 10000
  }
}
```
{% endcode %}

`cp mempool-frontend-config.sample.json mempool-frontend-config.json`

`nano mempool-frontend-config.json`

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
  "LIGHTNING": <a data-footnote-ref href="#user-content-fn-1">true</a>,
  "HISTORICAL_PRICE": true,
  "ADDITIONAL_CURRENCIES": false,
  "ACCELERATOR": false,
  "ACCELERATOR_BUTTON": true,
  "PUBLIC_ACCELERATIONS": false,
  "STRATUM_ENABLED": false,
  "SERVICES_API": "https://mempool.space/api/v1/services"
}
</code></pre>

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

## Upgrade

Follow the complete [Download](mempool.md#download-the-source-code), [Backend](mempool.md#install-the-backend), and [Frontend](mempool.md#install-the-frontend) sections, replacing the environment variable `"VERSION=x.xx"` value to the latest if it has not already been changed in this guide **(acting behind your responsibility)**.

* Restart the service to apply the changes

```shellscript
sudo systemctl restart mempool
```

* Check the logs with

```shellscript
journalctl -fu mempool
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

{% code overflow="wrap" %}
```bash
sudo rm /usr/lib/node_modules/mempool && sudo rm /usr/bin/mempool && sudo rm -rf /var/lib/mempool
```
{% endcode %}

* Delete the Nginx server files

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

<table><thead><tr><th align="center">Port</th><th width="100">Protocol<select><option value="K1YTaXNgK9iY" label="TCP" color="blue"></option><option value="rBwkQwPZUMt0" label="SSL" color="blue"></option><option value="zQnHZmzcUdq4" label="UDP" color="blue"></option></select></th><th align="center">Use</th></tr></thead><tbody><tr><td align="center">8001</td><td><span data-option="K1YTaXNgK9iY">TCP</span></td><td align="center">Default HTTP port</td></tr><tr><td align="center">8999</td><td><span data-option="K1YTaXNgK9iY">TCP</span></td><td align="center">Default backend port</td></tr><tr><td align="center">4081</td><td><span data-option="K1YTaXNgK9iY">TCP</span></td><td align="center">Default SSL port</td></tr></tbody></table>

[^1]: 
