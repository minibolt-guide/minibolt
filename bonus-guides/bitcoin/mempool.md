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

### Install Rustup + Cargo

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
If you obtain "**command not found**" output, you need to follow the [Rustup + Cargo bonus guide](../system/rustup-+-cargo.md) to install it and then come back to continue with the guide
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
create database mempool;
```

Expected output:

```
Query OK, 1 row affected (0.001 sec)
```

Enter the next command

{% hint style="danger" %}
Important!! Replace **`Password[G]`** to your one, keeping quotes \[' ']
{% endhint %}

<pre class="language-sql"><code class="lang-sql">grant all privileges on mempool.* to 'mempool'@'localhost' identified by '<a data-footnote-ref href="#user-content-fn-1">Password[G]</a>';
</code></pre>

Expected output:

```
Query OK, 0 rows affected (0.001 sec)
```

Exit from MariaDB shell

```bash
exit
```

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

We do not want to run Mempool code alongside other services for security reasons. For that, we will create a separate user and run the code as the new user.

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

Add `mempool` user to the `bitcoin` and `lnd` groups to allow to the user mempool reading the bitcoin .cookie file and the lnd certs files

```bash
sudo usermod -aG bitcoin,lnd mempool
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
npm ci --omit=dev --omit=optional
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
> mempool-backend@3.2.1 preinstall
> cd ../rust/gbt && npm run build-release && npm run to-backend


> gbt@3.0.1 build-release
> npm run build -- --release --strip


> gbt@3.0.1 build
> npm install --no-save @napi-rs/cli@2.18.0 && npm run check-cargo-version && napi build --platform --release --strip


up to date, audited 2 packages in 571ms

1 package is looking for funding
  run `npm fund` for details

found 0 vulnerabilities

> gbt@3.0.1 check-cargo-version
> VER=$(cat rust-toolchain) ; if ! cargo version | grep "cargo $VER" >/dev/null ; then echo -e "\033[1;35m[[[[WARNING]]]]: cargo version mismatch with ./rust-toolchain version ($VER)!!!\033[0m" >&2; fi

info: syncing channel updates for '1.84-x86_64-unknown-linux-gnu'
info: latest update on 2025-01-30, rust version 1.84.1 (e71f9a9a9 2025-01-27)
info: downloading component 'cargo'
info: downloading component 'clippy'
info: downloading component 'rust-docs'
info: downloading component 'rust-std'
[...]
   Compiling bytes v1.9.0
   Compiling napi v2.16.13
    Finished `release` profile [optimized] target(s) in 33.40s

> gbt@3.0.1 to-backend
> FD=${FD:-../../backend/rust-gbt/} ; rm -rf $FD && mkdir $FD && cp index.js index.d.ts package.json *.node $FD


added 125 packages, and audited 128 packages in 37s

16 packages are looking for funding
  run `npm fund` for details

9 vulnerabilities (8 high, 1 critical)

To address issues that do not require attention, run:
  npm audit fix

To address all issues, run:
  npm audit fix --force

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
> mempool-backend@3.2.1 package
> ./npm_package.sh


> mempool-backend@3.2.1 build
> npm run tsc && npm run create-resources


> mempool-backend@3.2.1 tsc
> ./node_modules/typescript/bin/tsc -p tsconfig.build.json


> mempool-backend@3.2.1 create-resources
> cp ./src/tasks/price-feeds/mtgox-weekly.json ./dist/tasks && node dist/api/fetch-version.js


> mempool-backend@3.2.1 package-rm-build-deps
> ./npm_package_rm_build_deps.sh

```

</details>

* Create the folder for the executable

```bash
mkdir package/bin
```

* Create a new `cli.sh` file

```sh
nano package/bin/cli.sh
```

* Copy and paste the following information. Save and exit

```
#!/bin/sh
node /var/lib/mempool/index.js
```

* Make the file executable

```bash
chmod +x package/bin/cli.sh
```

* Sync the backend files with the system and enforce secure ownership and permissions

<pre class="language-bash" data-overflow="wrap"><code class="lang-bash"><strong>sudo install -d -o mempool -g mempool -m 750 /var/lib/mempool &#x26;&#x26; sudo rsync -a --delete --chown=mempool:mempool --chmod=Du=rwx,Dg=rx,Do=,Fu=rw,Fg=r,Fo= /tmp/mempool/backend/package/ /var/lib/mempool/package/
</strong></code></pre>

* Create the corresponding symbolic links

{% code overflow="wrap" %}
```bash
sudo ln -s /var/lib/mempool /usr/lib/node_modules/mempool && sudo ln -s /usr/lib/node_modules/mempool/bin/cli.sh /usr/bin/mempool
```
{% endcode %}

* Create the configuration file

```bash
sudo nano /home/mempool/mempool-config.json
```

* Paste the following lines. Save and exit

{% hint style="danger" %}
Important: Replace **`Password[G]`** to your one, keeping quotes \[" "]
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
    "PORT": 50001,
    "TLS_ENABLED": false
  },
  "DATABASE": {
    "ENABLED": true,
    "HOST": "127.0.0.1",
    "PORT": 3306,
    "USERNAME": "mempool",
    "PASSWORD": "<a data-footnote-ref href="#user-content-fn-1">Password[G]</a>",
    "DATABASE": "mempool"
  },
  "LIGHTNING": {
    "_comment": "Enable this option only if LND is installed and fully synchronized."
    "ENABLED": <a data-footnote-ref href="#user-content-fn-2">false</a>,
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
</code></pre>

* Make the user `mempool` the owner of the configuration file

```bash
sudo chown mempool:mempool /home/mempool/mempool-config.json
```

* Restrict reading access to the configuration file for the user `mempool` only

```bash
sudo chmod 600 /home/mempool/mempool-config.json
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

* Export the next variable **(pending research)**

```bash
export SKIP_SYNC=1
export MEMPOOL_CDN=1
```

* Build it

```bash
npm run build
```

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

* Sync the frontend files with the system and enforce secure ownership and permissions

{% code overflow="wrap" %}
```sh
sudo install -d -o root -g www-data -m 750 /var/www/mempool && sudo rsync -av --delete --chown=root:www-data --chmod=Du=rwx,Dg=rx,Do=,Fu=rw,Fg=r,Fo= dist/mempool/ /var/www/mempool/
```
{% endcode %}

* **(Optional)** Delete the `mempool` folder to be ready for the next update

```bash
cd && sudo rm -r /tmp/mempool
```

## **Configuration**

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

## **Run**

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

### Validation

* Ensure the service is working and listening on the default HTTP port `8999` and SSL `4081` port

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

## Extras (optional)

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
#HiddenServicePort 443 127.0.0.1:4081
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

<table><thead><tr><th align="center">Port</th><th width="100">Protocol<select><option value="K1YTaXNgK9iY" label="TCP" color="blue"></option><option value="rBwkQwPZUMt0" label="SSL" color="blue"></option><option value="zQnHZmzcUdq4" label="UDP" color="blue"></option></select></th><th align="center">Use</th></tr></thead><tbody><tr><td align="center">8999</td><td><span data-option="K1YTaXNgK9iY">TCP</span></td><td align="center">Default HTTP port</td></tr><tr><td align="center">4081</td><td><span data-option="rBwkQwPZUMt0">SSL</span></td><td align="center">Default SSL port</td></tr></tbody></table>

[^1]: Replace

[^2]: Change to `true` if you have LND running and fully synchronized
