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

### Requirements

* [Bitcoin Core](../../bitcoin/bitcoin/bitcoin-client.md)
* [LND](../../lightning/lightning-client.md) (optional)
* Electrum server ([Fulcrum](../../bitcoin/bitcoin/electrum-server.md) or [Electrs](../../bonus/bitcoin/electrs.md))
* Others
  * [Node + NPM](../../bonus/system/nodejs-npm.md)
  * [Rustup + Cargo](../system/rustup-+-cargo.md)

### Preparations

#### Check Node + NPM

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

#### Install Rustup + Cargo

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

#### Install MariaDB

[MariaDB](https://mariadb.org/) is an open source relational database.

* With user "admin", we update the `apt` packages index, install MariaDB on the node and check that it runs properly

```bash
sudo apt update && sudo apt install mariadb-server mariadb-client -y
```

* Secure MariaDB installation:

```bash
sudo mariadb-secure-installation
```

{% hint style="warning" %}
* When the prompt asks you to enter the current password for root, press **enter,**
* When the prompt asks if  you want to switch to unix\_socket authentication, type "n" and press **enter,**
* When the prompt asks if  you want to change the root password, type "n" and press **enter,**
* When the prompt asks if  you want to remove anonymous users, type "y" and press **enter,**
* When the prompt asks if  you want to disallow root login remotely, type "y" and press **enter,**
* When the prompt asks if  you want to remove test database and access to it, type "y" and press **enter,**
* When the prompt asks if  you want to reload privilege tables now type "y" and press **enter.**
{% endhint %}

Expected output:

```
All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

**Create MariaDB database**

* Now, open the MariaDB shell.

```bash
sudo mysql
```

Expected output:

```
Welcome to the MariaDB monitor.  Commands end with ; or \g.
[...]
MariaDB [(none)]>
```

* Enter the following commands in the shell and exit. The instructions to enter in the MariaDB shell start with "MDB$".

```sql
MDB$ create database mempool;
```

Expected output:

```
Query OK, 1 row affected (0.001 sec)
```

{% code overflow="wrap" %}
```sql
MDB$ grant all privileges on mempool.* to 'mempool'@'localhost' identified by 'Password[M]';
```
{% endcode %}

Expected output:

```
Query OK, 0 rows affected (0.012 sec)
```

```sql
MDB$ exit
```

{% hint style="info" %}
Replace **`Password[M]`** to your one, keeping quotes \[' ']
{% endhint %}

### Installation

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

#### Backend

* Change to the backend directory

```bash
cd backend
```

* Install all dependencies and the necessary modules using NPM

{% hint style="warning" %}
**Not to run** the `npm audit fix` command, which could break the original code!!
{% endhint %}

```bash
npm install
```

<details>

<summary>Example of expected output ⬇️</summary>

```
> mempool-backend@3.2.1 preinstall
> cd ../rust/gbt && npm run build-release && npm run to-backend


> gbt@3.0.1 build-release
> npm run build -- --release --strip


> gbt@3.0.1 build
> npm install --no-save @napi-rs/cli@2.18.0 && npm run check-cargo-version && napi build --platform --release --strip


up to date, audited 2 packages in 880ms

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
info: downloading component 'rustc'
info: downloading component 'rustfmt'
info: installing component 'cargo'
info: installing component 'clippy'
info: installing component 'rust-docs'
info: installing component 'rust-std'
info: installing component 'rustc'
info: installing component 'rustfmt'
   Compiling proc-macro2 v1.0.93
   Compiling unicode-ident v1.0.15
   Compiling once_cell v1.20.2
   Compiling memchr v2.7.4
   Compiling pin-project-lite v0.2.16
   Compiling semver v1.0.25
   Compiling regex-syntax v0.8.5
   Compiling tracing-core v0.1.33
   Compiling aho-corasick v1.1.3
   Compiling quote v1.0.38
   Compiling regex-syntax v0.6.29
   Compiling syn v2.0.96
   Compiling regex-automata v0.4.9
   Compiling unicode-segmentation v1.12.0
   Compiling regex v1.11.1
   Compiling convert_case v0.6.0
   Compiling regex-automata v0.1.10
   Compiling tracing-attributes v0.1.28
   Compiling cfg-if v1.0.0
   Compiling hashbrown v0.15.2
   Compiling napi-build v2.1.4
   Compiling log v0.4.25
   Compiling equivalent v1.0.1
   Compiling overload v0.1.1
   Compiling lazy_static v1.5.0
   Compiling sharded-slab v0.1.7
   Compiling indexmap v2.7.1
   Compiling nu-ansi-term v0.46.0
   Compiling tracing-log v0.2.0
   Compiling gbt v1.0.0 (/home/mempool/mempool/rust/gbt)
   Compiling tracing v0.1.41
   Compiling napi-derive-backend v1.0.75
   Compiling thread_local v1.1.8
   Compiling matchers v0.1.0
   Compiling ctor v0.2.9
   Compiling tokio v1.43.0
   Compiling smallvec v1.13.2
   Compiling bitflags v2.8.0
   Compiling napi-sys v2.4.0
   Compiling tracing-subscriber v0.3.19
   Compiling priority-queue v2.1.1
   Compiling bytemuck v1.21.0
   Compiling napi-derive v2.16.13
   Compiling bytes v1.9.0
   Compiling napi v2.16.13
    Finished `release` profile [optimized] target(s) in 48.11s

> gbt@3.0.1 to-backend
> FD=${FD:-../../backend/rust-gbt/} ; rm -rf $FD && mkdir $FD && cp index.js index.d.ts package.json *.node $FD


changed 1 package, and audited 659 packages in 2m

74 packages are looking for funding
  run `npm fund` for details

13 vulnerabilities (1 low, 3 moderate, 8 high, 1 critical)

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
> mempool-backend@3.2.1 build
> npm run tsc && npm run create-resources


> mempool-backend@3.2.1 tsc
> ./node_modules/typescript/bin/tsc -p tsconfig.build.json


> mempool-backend@3.2.1 create-resources
> cp ./src/tasks/price-feeds/mtgox-weekly.json ./dist/tasks && node dist/api/fetch-version.js
```

</details>

**Create the mempool user & group**

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

* Add mempool user to the bitcoin and lnd groups to allow to the user mempool reading the bitcoin .cookie file and lnd certs files.

```bash
sudo usermod -aG bitcoin,lnd mempool
```

* Copy-pase the mempool folder to the home directory of the newly created user

```bash
sudo cp -r /tmp/mempool /home/mempool/
```

* Assign the owner of the mempool folder to the `mempool` user

```bash
sudo chown mempool:mempool -R /home/mempool/mempool
```

* Create the configuration file

```bash
sudo nano /home/mempool/mempool/backend/mempool-config.json
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
    "PASSWORD": "Password[M]",
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
Replace **`Password[M]`** to your one, keeping quotes \[" "]
{% endhint %}

* Restrict reading access to the configuration file by user "mempool" only.

```bash
sudo chmod 600 /home/mempool/mempool/backend/mempool-config.json
```

* **(Optional)** Delete the `mempool` folder to be ready for the next update

```bash
sudo rm -r /tmp/mempool
```

**Create systemd service**

* As user `admin`, create the service file

```bash
sudo nano /etc/systemd/system/mempool.service
```

* Paste the following configuration. Save and exit

<pre><code># MiniBolt: systemd unit for Mempool
# /etc/systemd/system/mempool.service

[Unit]
Description=Mempool
<strong>Requires=bitcoind.service
</strong>After=bitcoind.service

[Service]
WorkingDirectory=/home/mempool/mempool/backend
ExecStart=/usr/bin/node --max-old-space-size=2048 dist/index.js

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

**Run**

To keep an eye on the software movements, start your SSH program (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`

* Start mempool

```bash
sudo systemctl start mempool
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>journalctl -fu mempool</code> ⬇️</summary>

```
PENDING
```

</details>

#### Frontend

* Change to the `mempool` user

```bash
sudo su - mempool
```

* Install the frontend (it will take several minutes)

```bash
cd mempool/frontend
```

```bash
npm install --prod
```

<details>

<summary>Example of expected output ⬇️</summary>

```
npm warn config production Use `--omit=dev` instead.
npm warn deprecated querystring@0.2.0: The querystring API is considered Legacy. new code should use the URLSearchParams API instead.
npm warn deprecated @types/cypress@1.1.3: This is a stub types definition for cypress (https://cypress.io). cypress provides its own type definitions, so you don't need @types/cypress installed!
npm warn deprecated popper.js@1.16.1: You can find the new Popper v2 at @popperjs/core, this package is dedicated to the legacy v1

added 1411 packages, and audited 1412 packages in 1m

160 packages are looking for funding
  run `npm fund` for details

38 vulnerabilities (7 low, 11 moderate, 15 high, 5 critical)

To address issues that do not require attention, run:
  npm audit fix

To address all issues (including breaking changes), run:
  npm audit fix --force

Run `npm audit` for details.
```

</details>

```bash
npm run build
```

<details>

<summary>Example of expected output ⬇️</summary>

```
...
[sync-assets] Downloaded 0 and skipped 15 existing video subtitles
[sync-assets] 	Checking if promo video needs downloading or updating...
[sync-assets] 		mempool-promo.mp4 is already up to date. Skipping.
[sync-assets] Asset synchronization complete
```

</details>

* Exit to the `admin` user

```bash
exit
```

**Frontend web server, reverse proxy and firewall**

We need to create an nginx web server for the mempool frontend website.

* Install the output of the frontend build into the nginx webroot folder

```bash
sudo rsync -av --delete /home/mempool/mempool/frontend/dist/mempool/ /var/www/mempool/
```

* Change its ownership to the "www-data" user

```bash
sudo chown -R www-data:www-data /var/www/mempool
```

* Copy the config file dedicated to the Mempool website in the nginx `snippets` directory

```bash
sudo rsync -av /home/mempool/mempool/nginx-mempool.conf /etc/nginx/snippets
```

#### Reverse proxy, web server & Firewall

In the security section, we set up Nginx only as a reverse proxy. For mempool we need to modify it to use it as a web server too.

* Edit the nginx configuration file

```bash
sudo nano +17 -l /etc/nginx/nginx.conf
```

* Add this 2 lines under the line `17 "include /etc/nginx/sites-enabled/*.conf;"`.

```nginx
include /etc/nginx/mime.types;
default_type application/octet-stream;
```

{% hint style="info" %}
Watch your indentation! To see the differences between the two configurations more clearly, check this [diff](https://www.diffchecker.com/7ksp6t5T/).
{% endhint %}

* With user `admin`, create the mempool configuration

```bash
sudo nano /etc/nginx/sites-available/mempool-reverse-proxy.conf
```

* Paste the following complete configuration. Save and exit

```nginx
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
    listen [::]:4081 ssl;
    server_name _;
  
    include /etc/nginx/snippets/nginx-mempool.conf;

}
```

* Create the symbolic link that points to the directory `sites-enabled`

{% code overflow="wrap" %}
```bash
sudo ln -s /etc/nginx/sites-available/mempool-reverse-proxy.conf /etc/nginx/sites-enabled/
```
{% endcode %}

* Test Nginx configuration

```bash
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

```bash
sudo ufw allow 4081/tcp comment 'allow Mempool Space SSL from anywhere'
```

#### Validation

* Ensure the service is working and listening on the default `8999` , the HTTPS `4081` port and the tor port `4082`

```bash
sudo ss -tulpn | grep -v 'dotnet' | grep -E '(:8999|:4081|:4082)'
```

Expected output:

<pre><code><strong>tcp   LISTEN 0      511          0.0.0.0:4082       0.0.0.0:*    users:(("nginx",pid=827,fd=12),("nginx",pid=826,fd=12),("nginx",pid=825,fd=12),("nginx",pid=824,fd=12),("nginx",pid=823,fd=12))
</strong>tcp   LISTEN 0      511          0.0.0.0:4081       0.0.0.0:*    users:(("nginx",pid=827,fd=10),("nginx",pid=826,fd=10),("nginx",pid=825,fd=10),("nginx",pid=824,fd=10),("nginx",pid=823,fd=10))
tcp   LISTEN 0      511                *:8999             *:*    users:(("node",pid=1083,fd=25))
</code></pre>

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

### Upgrade

* UPDATE MEMPOOL

$ sudo su - mempool

$ cd mempool

$ git pull

$ git checkout TAG

$ git verify-tag TAG

build backend

edit mempool-config.json

build frontend

replace /var/www/mempool

$ sudo systemctl restart nginx.service

### Uninstall

#### Uninstall service

* Ensure you are logged in as the user `admin`, stop mempool

```bash
sudo systemctl stop mempool
```

* Disable autoboot (if enabled)

```bash
sudo systemctl disable mempool
```

* Delete the service

```bash
sudo rm /etc/systemd/system/mempool.service
```

#### Delete user & group

* Delete the mempool user.

```bash
sudo userdel -rf mempool
```

#### Uninstal MariaDB

* Stop the service.

```bash
sudo service mysql stop
```

* Uninstall MariaDB. When prompted, check the packages that will be removed and type “Y” and “Enter”. A blue window will pop up asking if we want to remove all MariaDB databases, select `<Yes>`.

```bash
sudo apt-get --purge remove "mysql*"
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
