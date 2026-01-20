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

# Public Pool

[Public Pool](https://web.public-pool.io/#/) is a NestJS and Typescript Bitcoin stratum mining server. It provides a lightweight and easy to use web interface to accomplish just that, a solo mining pool.

{% hint style="warning" %}
Difficulty: Medium
{% endhint %}

<figure><img src="../../.gitbook/assets/public-pool.png" alt=""><figcaption></figcaption></figure>

## Requirements

* [Bitcoin Core](../../bitcoin/bitcoin/bitcoin-client.md)

Others

* [Node + NPM](../../bonus/system/nodejs-npm.md)

## Preparations

### Check Node + NPM

* With the user `admin`, check if you have already installed Node

```sh
node -v
```

**Example** of expected output:

```
v16.14.2
```

* Check the NPM version

```sh
npm -v
```

**Example** of expected output:

```
8.19.3
```

{% hint style="info" %}
-> If you have `node -v` output, you can move to the next section.

-> If Nodejs is not installed (`-bash: /usr/bin/node: No such file or directory`), follow this [Node + NPM bonus guide](../../bonus/system/nodejs-npm.md) to install it
{% endhint %}

### Reverse proxy & Firewall

In the [security section](../../index-1/security.md), we set up Nginx as a reverse proxy. Now we can add the Public Pool configuration.

* Check your Nginx configuration file

```bash
sudo nano +17 /etc/nginx/nginx.conf -l
```

* Check that you have these two lines below line 17:  `"include /etc/nginx/sites-enabled/*.conf;"`. If not, add them. Save and exit

```nginx
include /etc/nginx/mime.types;
default_type application/octet-stream;
```

* Test this barebone Nginx configuration

```bash
sudo nginx -t
```

Expected output:

```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

* Reload Nginx to apply the configuration

```bash
sudo systemctl reload nginx
```

{% hint style="info" %}
Watch your indentation! To see the differences between the two configurations more clearly, check this [diff](https://www.diffchecker.com/7ksp6t5T/).
{% endhint %}

Enable the Nginx reverse proxy to route external encrypted HTTPS traffic internally to the Public Pool. The `error_page 497` directive instructs browsers that send HTTP requests to resend them over HTTPS.

* With user `admin`, create the reverse proxy configuration

```sh
sudo nano /etc/nginx/sites-available/public-pool-reverse-proxy.conf
```

* Paste the following complete configuration. Save and exit

```nginx
server {
    listen 4040 ssl;
    error_page 497 =301 https://$host:$server_port$request_uri;
 
    root /var/www/public-pool-ui;
 
    index index.html;
 
    location / {
        try_files $uri $uri/ =404;
    }
 
    location ~* ^/api/ {
        proxy_pass http://127.0.0.1:23334;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

* Create the symbolic link that points to the directory `sites-enabled`

{% code overflow="wrap" %}
```bash
sudo ln -s /etc/nginx/sites-available/public-pool-reverse-proxy.conf /etc/nginx/sites-enabled/
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

* Configure the firewall to allow incoming HTTPs requests from anywhere to the web and the Stratum server

{% code overflow="wrap" %}
```sh
sudo ufw allow 4040/tcp comment 'Allow Public Pool UI SSL from anywhere' && sudo ufw allow 23333/tcp comment 'Allow Public Pool Stratum from anywhere'
```
{% endcode %}

### Configure Bitcoin Core

We need to set up settings in the Bitcoin Core configuration file - add new lines if they are not present

* Edit `bitcoin.conf` file

```sh
sudo nano /data/bitcoin/bitcoin.conf
```

* Check that you have this line in the `"# Connections"` section, if not, add it. Save and exit

```
zmqpubrawblock=tcp://127.0.0.1:28332
```

* Restart Bitcoin Core to apply changes (if needed)

```sh
sudo systemctl restart bitcoind
```

* Check if Bitcoin Core has enabled `zmqpubrawblock` on the `28322` port

```bash
sudo ss -tulpn | grep -E '(:28332)'
```

Expected output:

```
tcp   LISTEN 0      100        127.0.0.1:28332      0.0.0.0:*    users:(("bitcoind",pid=805382,fd=23))
```

### Create the public-pool user & group

We do not want to run the Public Pool code alongside `bitcoind` because of security reasons. For that, we will create a separate user and run the code as the new user.

* Create a new `public-pool` user and group

```sh
sudo adduser --disabled-password --gecos "" public-pool
```

* Add `public-pool` user to the `bitcoin` group to allow the user `public-pool` reading the `.cookie` file

```sh
sudo adduser public-pool bitcoin
```

## Installation

### Install the backend

* Still with user `admin` , change to a temporary directory, which is cleared on reboot

```sh
cd /tmp
```

* Download the source code directly from GitHub and change to the Public Pool folder

{% code overflow="wrap" %}
```sh
git clone https://github.com/benjamin-wilson/public-pool.git && cd public-pool
```
{% endcode %}

* Install all dependencies and the necessary modules using NPM

{% hint style="warning" %}
**Not to run** the `npm audit fix` command, which could break the original code!!
{% endhint %}

```sh
npm ci
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
npm warn deprecated uuid@3.4.0: Please upgrade  to version 7 or higher.  Older versions may use Math.random() in certain circumstances, which is known to be problematic.  See https://v8.dev/blog/math-random for details.
npm warn deprecated request-promise-native@1.0.9: request-promise-native has been deprecated because it extends the now deprecated request package, see https://github.com/request/request/issues/3142
npm warn deprecated request-promise@4.2.6: request-promise has been deprecated because it extends the now deprecated request package, see https://github.com/request/request/issues/3142
npm warn deprecated request@2.88.2: request has been deprecated, see https://github.com/request/request/issues/3142
npm warn deprecated har-validator@5.1.5: this library is no longer supported
npm warn deprecated @npmcli/move-file@1.1.2: This functionality has been moved to @npmcli/fs
npm warn deprecated rimraf@2.7.1: Rimraf versions prior to v4 are no longer supported
npm warn deprecated glob@7.2.3: Glob versions prior to v9 are no longer supported

> public-pool@0.0.1 postinstall
> patch-package

patch-package 8.0.0
Applying patches...
rpc-bitcoin@2.0.0 ✔

added 988 packages, and audited 989 packages in 19s

153 packages are looking for funding
  run `npm fund` for details

53 vulnerabilities (9 low, 20 moderate, 18 high, 6 critical)

To address issues that do not require attention, run:
  npm audit fix

To address all issues possible (including breaking changes), run:
  npm audit fix --force

Some issues need review, and may require choosing
a different dependency.

Run `npm audit` for details.
npm notice
npm notice New minor version of npm available! 11.6.2 -> 11.7.0
npm notice Changelog: https://github.com/npm/cli/releases/tag/v11.7.0
npm notice To update run: npm install -g npm@11.7.0
npm notice
```

</details>

* Build it

```sh
npm run build
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
> public-pool@0.0.1 build
> nest build
```

</details>

* Create the folder for the executable

```sh
mkdir -p dist/bin
```

* Create a new file called `cli.sh`

```sh
nano dist/bin/cli.sh
```

* Copy and paste the following information. Save and exit

```
#!/bin/sh
node "$@" /var/lib/public-pool/main
```

* Make the file executable

```sh
chmod +x dist/bin/cli.sh
```

* Create the `public-pool` folder

```sh
sudo install -d -o public-pool -g public-pool /var/lib/public-pool
```

* Sync the necessary files into the system

{% code overflow="wrap" %}
```sh
sudo rsync -av --delete --chown=public-pool:public-pool /tmp/public-pool/dist/ /var/lib/public-pool/ && sudo rsync -av --chown=public-pool:public-pool /tmp/public-pool/node_modules /var/lib/public-pool/
```
{% endcode %}

* Create the corresponding symbolic links

{% code overflow="wrap" %}
```sh
sudo ln -s /var/lib/public-pool /usr/lib/node_modules/public-pool && sudo ln -s /usr/lib/node_modules/public-pool/bin/cli.sh /usr/bin/public-pool
```
{% endcode %}

### Install the frontend

* Still with user `admin` , change the root of the temporary directory again

```sh
cd /tmp
```

* Download the source code directly from GitHub and change to the Public Pool UI folder

{% code overflow="wrap" %}
```sh
git clone https://github.com/benjamin-wilson/public-pool-ui.git && cd public-pool-ui
```
{% endcode %}

* Install all dependencies and the necessary modules using NPM

{% hint style="warning" %}
**Not to run** the `npm audit fix` command, which could break the original code!!
{% endhint %}

```sh
npm ci
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

<pre><code><strong>[...]
</strong><strong>npm warn deprecated tsparticles-interaction-external-attract@2.12.0: starting from tsparticles v3 the packages are now moved to @tsparticles/package-name instead of tsparticles-package-name
</strong>npm warn deprecated tsparticles-updater-rotate@2.12.0: starting from tsparticles v3 the packages are now moved to @tsparticles/package-name instead of tsparticles-package-name
npm warn deprecated tsparticles-updater-out-modes@2.12.0: starting from tsparticles v3 the packages are now moved to @tsparticles/package-name instead of tsparticles-package-name
npm warn deprecated tsparticles-updater-wobble@2.12.0: starting from tsparticles v3 the packages are now moved to @tsparticles/package-name instead of tsparticles-package-name
npm warn deprecated tsparticles-updater-twinkle@2.12.0: starting from tsparticles v3 the packages are now moved to @tsparticles/package-name instead of tsparticles-package-name
npm warn deprecated tsparticles-updater-roll@2.12.0: starting from tsparticles v3 the packages are now moved to @tsparticles/package-name instead of tsparticles-package-name
npm warn deprecated tsparticles-updater-tilt@2.12.0: starting from tsparticles v3 the packages are now moved to @tsparticles/package-name instead of tsparticles-package-name
npm warn deprecated tsparticles-interaction-external-grab@2.12.0: starting from tsparticles v3 the packages are now moved to @tsparticles/package-name instead of tsparticles-package-name
npm warn deprecated tsparticles-interaction-external-connect@2.12.0: starting from tsparticles v3 the packages are now moved to @tsparticles/package-name instead of tsparticles-package-name
npm warn deprecated tsparticles-updater-life@2.12.0: starting from tsparticles v3 the packages are now moved to @tsparticles/package-name instead of tsparticles-package-name
npm warn deprecated tsparticles-interaction-external-repulse@2.12.0: starting from tsparticles v3 the packages are now moved to @tsparticles/package-name instead of tsparticles-package-name
npm warn deprecated tsparticles-plugin-absorbers@2.12.0: starting from tsparticles v3 the packages are now moved to @tsparticles/package-name instead of tsparticles-package-name
npm warn deprecated tsparticles-interaction-external-bubble@2.12.0: starting from tsparticles v3 the packages are now moved to @tsparticles/package-name instead of tsparticles-package-name
npm warn deprecated tsparticles-interaction-particles-links@2.12.0: starting from tsparticles v3 the packages are now moved to @tsparticles/package-name instead of tsparticles-package-name
npm warn deprecated tsparticles-updater-destroy@2.12.0: starting from tsparticles v3 the packages are now moved to @tsparticles/package-name instead of tsparticles-package-name
npm warn deprecated tsparticles-shape-image@2.12.0: starting from tsparticles v3 the packages are now moved to @tsparticles/package-name instead of tsparticles-package-name
npm warn deprecated tsparticles-plugin-emitters@2.12.0: starting from tsparticles v3 the packages are now moved to @tsparticles/package-name instead of tsparticles-package-name
npm warn deprecated uuid@2.0.3: Please upgrade  to version 7 or higher.  Older versions may use Math.random() in certain circumstances, which is known to be problematic.  See https://v8.dev/blog/math-random for details.
npm warn deprecated tsparticles-engine@2.12.0: starting from tsparticles v3 the packages are now moved to @tsparticles/package-name instead of tsparticles-package-name

added 1098 packages, and audited 1099 packages in 22s

182 packages are looking for funding
  run `npm fund` for details

47 vulnerabilities (14 low, 10 moderate, 23 high)

To address issues that do not require attention, run:
  npm audit fix

To address all issues (including breaking changes), run:
  npm audit fix --force

Run `npm audit` for details.
</code></pre>

</details>

* Delete the default configuration file

```sh
rm src/environments/environment.prod.ts
```

* Create the configuration file

```sh
nano src/environments/environment.prod.ts
```

* Paste the following content. Save and exit

```
let path = window.location.origin + window.location.pathname;
path = path.endsWith('/') ? path.slice(0, -1) : path;
let stratumUrl = path.replace(/(^\w+:|^)\/\//, '').replace(/:\d+/, '');

export const environment = {
    production: true,
    API_URL: path,
    STRATUM_URL: stratumUrl + ':23333'
};
```

* Build it

```sh
npm run build
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
> public-pool-ui@0.0.0 build
> ng build --configuration=production && gzipper compress --gzip --brotli ./dist/public-pool-ui/
[...]
⠴ Generating browser application bundles (phase: sealing)...
[...]
✔ Browser application bundle generation complete.
✔ Copying assets complete.
✔ Index html generation complete.

Initial chunk files           | Names         |  Raw size | Estimated transfer size
main.084bbffefffb6801.js      | main          |   1.65 MB |               359.69 kB
styles.b0d752c0b560a327.css   | styles        | 365.93 kB |                22.32 kB
scripts.21e2572554dc843d.js   | scripts       | 165.82 kB |                47.86 kB
polyfills.f2a4ff6f85492da8.js | polyfills     |  34.51 kB |                11.15 kB
runtime.8cc81e121daade11.js   | runtime       |   1.17 kB |               637 bytes

                              | Initial total |   2.22 MB |               441.65 kB

Build at: 2026-01-11T19:00:49.809Z - Hash: 6d3320fb7df1ad12 - Time: 31504ms

Warning: /tmp/public-pool-ui/node_modules/chartjs-adapter-moment/dist/chartjs-adapter-moment.esm.js depends on 'moment'. CommonJS or AMD dependencies can cause optimization bailouts.
For more info see: https://angular.dev/tools/cli/build#configuring-commonjs-dependencies


gzipper: 318 files have been compressed. (11s 973.86641ms)
```

</details>

* Sync the required files to the Nginx server directory

{% code overflow="wrap" %}
```sh
sudo rsync -av --delete --chown=public-pool:public-pool dist/public-pool-ui/ /var/www/public-pool-ui/
```
{% endcode %}

* **(Optional)** Delete the installation files of the `tmp` folder to be ready for the next installation

{% code overflow="wrap" %}
```bash
cd && sudo rm -rf /tmp/public-pool*
```
{% endcode %}

## Configuration

* Change to the `public-pool` user

```sh
sudo su - public-pool
```

* Create the Public Pool configuration file

```sh
nano public-pool.env
```

* Paste the following content. Save and exit

<pre class="language-sh"><code class="lang-sh"># MiniBolt: Public Pool  configuration
# /home/public-pool/public-pool.env

## Bitcoin Core settings
BITCOIN_RPC_URL=http://127.0.0.1
BITCOIN_RPC_PORT=8332
BITCOIN_RPC_COOKIEFILE="/data/bitcoin/.cookie"
BITCOIN_ZMQ_HOST="tcp://127.0.0.1:28332"

## Public Pool  general settings
API_PORT=23334
STRATUM_PORT=23333

POOL_IDENTIFIER="<a data-footnote-ref href="#user-content-fn-1">MiniBolt</a>"
</code></pre>

* Exit of the `public-pool` user session to return to the `admin` user session

```sh
exit
```

### Create systemd service

Now, let's configure Public Pool to start automatically on system startup.

* As user `admin`, create Public Pool systemd unit

```sh
sudo nano /etc/systemd/system/public-pool.service
```

* Enter the following content. Save and exit

```
# MiniBolt: systemd unit for Public Pool
# /etc/systemd/system/public-pool.service

[Unit]
Description=Public-Pool
Requires=bitcoind.service
After=bitcoind.service

StartLimitBurst=2
StartLimitIntervalSec=20

[Service]
WorkingDirectory=/home/public-pool/
ExecStart=/usr/bin/public-pool --env-file=/home/public-pool/public-pool.env
EnvironmentFile=/home/public-pool/public-pool.env

User=public-pool
Group=public-pool

# Process management
####################
Type=simple
KillSignal=SIGINT
TimeoutStopSec=300

[Install]
WantedBy=multi-user.target
```

* Enable autoboot **(optional)**

```sh
sudo systemctl enable public-pool
```

* Now, the daemon information is no longer displayed on the command line but is written into the system journal. You can check on it using the following command. You can exit monitoring at any time with `Ctrl-C`

```sh
journalctl -fu public-pool
```

## Run

To keep an eye on the software movements, [start your SSH program](../../index-1/remote-access.md#access-with-secure-shell) (eg, PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`

* Start the service

```sh
sudo systemctl start public-pool
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>journalctl -fu lnd</code> ⬇️</summary>

```
Jan 19 23:26:03 minibolt systemd[1]: Started public-pool.service - Public-Pool.
Jan 19 23:26:10 minibolt public-pool[540902]: (node:540902) [DEP0056] DeprecationWarning: The `util.isString` API is deprecated.  Please use `typeof arg === "string"` instead.
Jan 19 23:26:10 minibolt public-pool[540902]: (Use `node --trace-deprecation ...` to show where the warning was created)
Jan 19 23:26:10 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:10     LOG [NestFactory] Starting Nest application...
Jan 19 23:26:10 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:10     LOG [InstanceLoader] TypeOrmModule dependencies initialized +266ms
Jan 19 23:26:10 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:10     LOG [InstanceLoader] HttpModule dependencies initialized +2ms
Jan 19 23:26:10 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:10     LOG [InstanceLoader] CacheModule dependencies initialized +0ms
Jan 19 23:26:10 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:10     LOG [InstanceLoader] ConfigHostModule dependencies initialized +1ms
Jan 19 23:26:10 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:10     LOG [InstanceLoader] DiscoveryModule dependencies initialized +0ms
Jan 19 23:26:10 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:10     LOG [InstanceLoader] ConfigModule dependencies initialized +1ms
Jan 19 23:26:10 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:10     LOG [InstanceLoader] ScheduleModule dependencies initialized +3ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [InstanceLoader] TypeOrmCoreModule dependencies initialized +195ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [InstanceLoader] TypeOrmModule dependencies initialized +1ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [InstanceLoader] TypeOrmModule dependencies initialized +0ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [InstanceLoader] TypeOrmModule dependencies initialized +0ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [InstanceLoader] TypeOrmModule dependencies initialized +0ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [InstanceLoader] TypeOrmModule dependencies initialized +1ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [InstanceLoader] TypeOrmModule dependencies initialized +0ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [InstanceLoader] TypeOrmModule dependencies initialized +0ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [InstanceLoader] ClientStatisticsModule dependencies initialized +1ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [InstanceLoader] ClientModule dependencies initialized +0ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [InstanceLoader] AddressSettingsModule dependencies initialized +0ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [InstanceLoader] TelegramSubscriptionsModule dependencies initialized +0ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [InstanceLoader] BlocksModule dependencies initialized +0ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [InstanceLoader] RpcBlocksModule dependencies initialized +0ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [InstanceLoader] ExternalSharesModule dependencies initialized +1ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [InstanceLoader] AppModule dependencies initialized +9ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [RoutesResolver] AppController {/api}: +114ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [RouterExplorer] Mapped {/api/info, GET} route +10ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [RouterExplorer] Mapped {/api/pool, GET} route +5ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [RouterExplorer] Mapped {/api/network, GET} route +2ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [RouterExplorer] Mapped {/api/info/chart, GET} route +2ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [RoutesResolver] ClientController {/api/client}: +1ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [RouterExplorer] Mapped {/api/client/:address, GET} route +4ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [RouterExplorer] Mapped {/api/client/:address/chart, GET} route +2ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [RouterExplorer] Mapped {/api/client/:address/:workerName, GET} route +2ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [RouterExplorer] Mapped {/api/client/:address/:workerName/:sessionId, GET} route +2ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [RoutesResolver] AddressController {/api/address}: +1ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [RouterExplorer] Mapped {/api/address/settings, PATCH} route +3ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [RoutesResolver] ExternalShareController {/api/share}: +0ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [RouterExplorer] Mapped {/api/share/top-difficulties, GET} route +3ms
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [RouterExplorer] Mapped {/api/share, POST} route +1ms
Jan 19 23:26:11 minibolt public-pool[540902]: Using ZMQ
Jan 19 23:26:11 minibolt public-pool[540902]: ZMQ Connected
Jan 19 23:26:11 minibolt public-pool[540902]: Bitcoin RPC connected
Jan 19 23:26:11 minibolt public-pool[540902]: block height change
Jan 19 23:26:11 minibolt public-pool[540902]: [Nest] 540902  - 19/01/2026, 23:26:11     LOG [NestApplication] Nest application successfully started +98ms
Jan 19 23:26:11 minibolt public-pool[540902]: API listening on http://0.0.0.0:23334
Jan 19 23:26:21 minibolt public-pool[540902]: Stratum server is listening on port 23333
```

</details>

#### Validation

* Ensure the service is working and listening on the SSL `4040` port, Stratum `23333` port and the API `23334` port

```sh
sudo ss -tulpn | grep -v 'dotnet' | grep -E '(:4040|:23333|:23334)'
```

Expected output:

```
tcp   LISTEN 0      511          0.0.0.0:4040       0.0.0.0:*    users:(("nginx",pid=86475,fd=22),("nginx",pid=86474,fd=22),("nginx",pid=86473,fd=22),("nginx",pid=86472,fd=22),("nginx",pid=809,fd=22))
tcp   LISTEN 0      511          0.0.0.0:23334      0.0.0.0:*    users:(("node",pid=97483,fd=36))                                                                                                       
tcp   LISTEN 0      511                *:23333            *:*    users:(("node",pid=97483,fd=34))
```

{% hint style="info" %}
> Your browser will display a warning because we use a self-signed SSL certificate. We can do nothing about that because we would need a proper domain name (e.g., https://yournode.com) to get an official certificate that browsers recognize. Click on "Advanced" and proceed to the Public Pool web interface
>
> Now point your browser to `https://minibolt.local:4040` or the IP address (e.g. `https://192.168.x.xxx:4040`). You should see the home page of Public Pool
{% endhint %}

{% hint style="success" %}
Congrats! You now have Public Pool up and running
{% endhint %}

## Extras (optional)

### Remote access over Tor

* With the user `admin`, edit the `torrc` file

```shellscript
sudo nano +63 /etc/tor/torrc --linenumbers
```

* Add the following lines in the "location hidden services" section, below "`## This section is just for location-hidden services ##`". Save and exit

```
# Hidden Service Public Pool
HiddenServiceDir /var/lib/tor/hidden_service_public-pool/
HiddenServiceVersion 3
HiddenServicePoWDefensesEnabled 1
HiddenServicePort 443 127.0.0.1:4040
```

* Reload Tor to apply changes

```shellscript
sudo systemctl reload tor
```

* Get your Onion address

```shellscript
sudo cat /var/lib/tor/hidden_service_public-pool/hostname
```

Expected output:

```
abcdefg..............xyz.onion
```

* With the [Tor browser](https://www.torproject.org), you can access this onion address from any device

## Upgrade

Follow the complete [Installation section](public-pool.md#installation) until the [Create the public-pool user and group](public-pool.md#create-the-public-pool-user-and-group) (NOT included).

* Restart the service to apply the changes

```shellscript
sudo systemctl restart public-pool
```

* Check the logs, and pay attention to the next log

```shellscript
journalctl -fu public-pool
```

**Example** of expected output:

```
dic 20 16:49:40 minibolt public-pool[97483]: Using ZMQ
dic 20 16:49:40 minibolt public-pool[97483]: ZMQ Connected
dic 20 16:49:40 minibolt public-pool[97483]: Bitcoin RPC connected
dic 20 16:49:40 minibolt public-pool[97483]: block height change
dic 20 16:49:40 minibolt public-pool[97483]: [Nest] 97483  - 20/12/2025, 16:49:40     LOG [NestApplication] Nest application successfully started +29ms
dic 20 16:49:40 minibolt public-pool[97483]: API listening on http://0.0.0.0:23334
dic 20 16:49:50 minibolt public-pool[97483]: Stratum server is listening on port 23333
```

## Uninstall

### Uninstall service

* Ensure you are logged in as the user `admin`, stop Pubic Pool

```shellscript
sudo systemctl stop public-pool
```

* Disable autoboot (if enabled)

```shellscript
sudo systemctl disable public-pool
```

* Delete the service

```shellscript
sudo rm /etc/systemd/system/public-pool.service
```

### Delete user & group

* Delete the `public-pool` user.

```shellscript
sudo userdel -rf public-pool
```

### Delete all Public Pool files

* Remove the corresponding symbolic links and files

{% code overflow="wrap" %}
```bash
sudo rm /usr/lib/node_modules/public-pool && sudo rm /usr/bin/public-pool && sudo rm -rf /var/lib/public-pool
```
{% endcode %}

* Delete the nginx server files.

```shellscript
sudo rm -rf /var/www/public-pool-ui
```

### Uninstall Tor hidden service

* Ensure that you are logged in as the user `admin` and delete or comment the following lines in the "location hidden services" section, below "`## This section is just for location-hidden services ##`" in the torrc file. Save and exit

```shellscript
sudo nano +63 /etc/tor/torrc --linenumbers
```

```
# Hidden Service Public Pool
HiddenServiceDir /var/lib/tor/hidden_service_public-pool/
HiddenServiceVersion 3
HiddenServicePoWDefensesEnabled 1
HiddenServicePort 443 127.0.0.1:4040
```

* Reload the torrc config

```shellscript
sudo systemctl reload tor
```

### Uninstall reverse proxy & FW configuration

* Ensure you are logged in as the user `admin`, delete the reverse proxy config file

```bash
sudo rm /etc/nginx/sites-available/public-pool-reverse-proxy.conf
```

* Delete the symbolic link

```bash
sudo rm /etc/nginx/sites-enabled/public-pool-reverse-proxy.conf
```

* Test Nginx configuration

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

* Display the UFW firewall rules, and note the number of the rules for Public Pool (e.g., X and Y below)

```shellscript
sudo ufw status numbered
```

Expected output:

```
[X] 4040/tcp     ALLOW IN    Anywhere       # Allow Public Pool UI SSL from anywhere
[Y] 23333/tcp    ALLOW IN    Anywhere       # Allow Public Pool Stratum from anywhere
```

* Delete the rule with the correct number and confirm with "`yes`"

```shellscript
sudo ufw delete X
sudo ufw delete Y
```

### Port reference

<table><thead><tr><th align="center">Port</th><th width="100">Protocol<select><option value="K1YTaXNgK9iY" label="TCP" color="blue"></option><option value="rBwkQwPZUMt0" label="SSL" color="blue"></option><option value="zQnHZmzcUdq4" label="UDP" color="blue"></option></select></th><th align="center">Use</th></tr></thead><tbody><tr><td align="center">4040</td><td><span data-option="rBwkQwPZUMt0">SSL</span></td><td align="center">HTTPS port (encrypted)</td></tr><tr><td align="center">23333</td><td><span data-option="K1YTaXNgK9iY">TCP</span></td><td align="center">Default API port</td></tr><tr><td align="center">23334</td><td><span data-option="K1YTaXNgK9iY">TCP</span></td><td align="center">Default Stratum Port</td></tr></tbody></table>

[^1]: Change for your selection if you want
