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

[Public Pool](https://web.public-pool.io/#/) is a NestJS and Typescript Bitcoin stratum mining server. It provides a lightweight and easy to use web interface to accomplish just that, a solo mining pool.&#x20;

{% hint style="warning" %}
Difficulty: Medium
{% endhint %}

<figure><img src="../../.gitbook/assets/public-pool.png" alt=""><figcaption></figcaption></figure>

## Requirements

* [Bitcoin Core](../../bitcoin/bitcoin/bitcoin-client.md)

## Preparations

### Check Node + NPM

Node + NPM should have been installed for the [BTC RPC Explorer](../../bitcoin/bitcoin/blockchain-explorer.md).

* With the user `admin`, check the Node version

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

### Reverse proxy & Firewall

In the [security section](../../index-1/security.md), we set up Nginx as a reverse proxy. Now we can add the Public Pool configuration.

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

Enable the Nginx reverse proxy to route external encrypted HTTPS traffic internally to Public Pool. The `error_page 497` directive instructs browsers that send HTTP requests to resend them over HTTPS.

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

* Configure the firewall to allow incoming HTTP requests from anywhere to the web and stratum servers

```sh
sudo ufw allow 4040/tcp comment 'Allow Public Pool UI SSL from anywhere'
sudo ufw allow 23333/tcp comment 'Allow Public Pool Stratum from anywhere'
```

### Configure Bitcoin Core

We need to set up settings in the Bitcoin Core configuration file - add new lines if they are not present

* Edit `bitcoin.conf` file

```sh
sudo nano /data/bitcoin/bitcoin.conf
```

* Add the following lines to the `"# Connections"` section. Save and exit

```
## Enable ZMQ real time raw block publishing (for Public Pool)
zmqpubrawblock=tcp://127.0.0.1:28332
```

* Restart Bitcoin Core to apply changes

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

<summary>Example of expected output ⬇️</summary>

```
added 988 packages, and audited 989 packages in 26s

153 packages are looking for funding
  run `npm fund` for details

52 vulnerabilities (9 low, 20 moderate, 17 high, 6 critical)

To address issues that do not require attention, run:
  npm audit fix

To address all issues possible (including breaking changes), run:
  npm audit fix --force

Some issues need review, and may require choosing
a different dependency.

Run `npm audit` for details.
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

* Create a new `cli.sh` file

```sh
nano dist/bin/cli.sh
```

* Copy and paste the following information

```yaml
#!/bin/sh
node "$@" /var/lib/public-pool/main
```

* Make the file executable

```yaml
chmod +x dist/bin/cli.sh
```

* Copy the necessary files into the system

```yaml
sudo mv -f /tmp/public-pool/dist /var/lib/public-pool && sudo cp -R node_modules /var/lib/public-pool
```

* Create the corresponding symbolic links

```yaml
sudo ln -s /var/lib/public-pool /usr/lib/node_modules/public-pool && sudo ln -s /usr/lib/node_modules/public-pool/dist/bin/cli.sh /usr/bin/public-pool
```

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

<summary>Example of expected output ⬇️</summary>

```
added 1098 packages, and audited 1099 packages in 21s

182 packages are looking for funding
  run `npm fund` for details

44 vulnerabilities (14 low, 10 moderate, 20 high)

To address issues that do not require attention, run:
  npm audit fix

To address all issues (including breaking changes), run:
  npm audit fix --force

Run `npm audit` for details.
```

</details>

* Edit this configuration file

```sh
nano src/environments/environment.prod.ts
```

* Replace its content with the following lines, save and exit.

```sh
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
Build at: 2025-12-18T07:48:04.184Z - Hash: 6d3320fb7df1ad12 - Time: 46597ms

Warning: /tmp/public-pool-ui/node_modules/chartjs-adapter-moment/dist/chartjs-adapter-moment.esm.js depends on 'moment'. CommonJS or AMD dependencies can cause optimization bailouts.
For more info see: https://angular.dev/tools/cli/build#configuring-commonjs-dependencies


gzipper: 318 files have been compressed. (18s 289.411892ms)
```

</details>

* Move the required files to the nginx server directory

```sh
sudo mv -f dist/public-pool-ui /var/www/
```

* **(Optional)** Delete installation files of the `tmp` folder to be ready for the next installation

{% code overflow="wrap" %}
```bash
cd && sudo rm -rf /tmp/public-pool*
```
{% endcode %}

### Create the public-pool user & group

We do not want to run Public Pool code alongside `bitcoind` because of security reasons. For that, we will create a separate user and run the code as the new user.

* Create a new `public-pool` user and group

```sh
sudo adduser --disabled-password --gecos "" public-pool
```

* Add `public-pool` user to the `bitcoin` group to allow the user `public-pool` reading the `.cookie` file

```sh
sudo adduser public-pool bitcoin
```

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

```sh
# MiniBolt: Public Pool  configuration
# /home/public-pool/public-pool.env

## Bitcoin Core settings
BITCOIN_RPC_URL=http://127.0.0.1
BITCOIN_RPC_PORT=8332
BITCOIN_RPC_COOKIEFILE="/data/bitcoin/.cookie"
BITCOIN_ZMQ_HOST="tcp://127.0.0.1:28332"

## Public Pool  general settings
API_PORT=23334
STRATUM_PORT=23333

POOL_IDENTIFIER="Minibolt"
```

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

To keep an eye on the software movements, [start your SSH program](/broken/pages/vu3zbXeH6ypg3BYajFIc#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`

* Start the service

```sh
sudo systemctl start public-pool
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>journalctl -fu lnd</code> ⬇️</summary>

```
dic 20 06:51:17 minibolt public-pool[808891]: [Nest] 808891  - 20/12/2025, 6:51:17     LOG [RouterExplorer] Mapped {/api/address/settings, PATCH} route +1ms
dic 20 06:51:17 minibolt public-pool[808891]: [Nest] 808891  - 20/12/2025, 6:51:17     LOG [RoutesResolver] ExternalShareController {/api/share}: +0ms
dic 20 06:51:17 minibolt public-pool[808891]: [Nest] 808891  - 20/12/2025, 6:51:17     LOG [RouterExplorer] Mapped {/api/share/top-difficulties, GET} route +0ms
dic 20 06:51:17 minibolt public-pool[808891]: [Nest] 808891  - 20/12/2025, 6:51:17     LOG [RouterExplorer] Mapped {/api/share, POST} route +1ms
dic 20 06:51:17 minibolt public-pool[808891]: Using ZMQ
dic 20 06:51:17 minibolt public-pool[808891]: ZMQ Connected
dic 20 06:51:17 minibolt public-pool[808891]: Bitcoin RPC connected
dic 20 06:51:17 minibolt public-pool[808891]: block height change
dic 20 06:51:17 minibolt public-pool[808891]: [Nest] 808891  - 20/12/2025, 6:51:17     LOG [NestApplication] Nest application successfully started +26ms
dic 20 06:51:17 minibolt public-pool[808891]: API listening on http://0.0.0.0:23334
dic 20 06:51:27 minibolt public-pool[808891]: Stratum server is listening on port 23333

```

</details>

#### Validation

* Ensure the service is working and listening on the stratum `23333` port and the API `23334` port

```shellscript
sudo ss -tulpn | grep -v 'dotnet' | grep -E '(:23333|:23334)'
```

Expected output:

```
tcp   LISTEN 0      511          0.0.0.0:23334      0.0.0.0:*    users:(("node",pid=808891,fd=36))                                                                                                          
tcp   LISTEN 0      511                *:23333            *:*    users:(("node",pid=808891,fd=34))
```

{% hint style="info" %}
> Your browser will display a warning because we use a self-signed SSL certificate. We can do nothing about that because we would need a proper domain name (e.g., `https://yournode.com`) to get an official certificate that browsers recognize. Click on "Advanced" and proceed to the Public Pool web interface

> Now point your browser to `https://minibolt.local:4040` or the IP address (e.g. `https://192.168.x.xxx:4040`). You should see the home page of Public Pool
{% endhint %}

{% hint style="success" %}
Congrat&#x73;**!** You now have Public Pool up and running
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

Follow the complete [Installation section](public-pool.md#installation) until the [Create the public-pool user and group](public-pool.md#binaries-installation) (NOT included).

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
[...]
dic 20 06:51:17 minibolt public-pool[808891]: Using ZMQ
dic 20 06:51:17 minibolt public-pool[808891]: ZMQ Connected
dic 20 06:51:17 minibolt public-pool[808891]: Bitcoin RPC connected
dic 20 06:51:17 minibolt public-pool[808891]: block height change
dic 20 06:51:17 minibolt public-pool[808891]: [Nest] 808891  - 20/12/2025, 6:51:17     LOG [NestApplication] Nest application successfully started +26ms
dic 20 06:51:17 minibolt public-pool[808891]: API listening on http://0.0.0.0:23334
dic 20 06:51:27 minibolt public-pool[808891]: Stratum server is listening on port 23333
[...]
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

* Remove the corresponding symbolic links

```yaml
sudo rm /usr/lib/node_modules/public-pool && sudo rm /usr/bin/public-pool
```

* Delete the nginx server files.

```shellscript
sudo rm -rf /var/www/public-pool-ui
```

* Delete the rest of public pool files.

```shellscript
sudo rm -rf /var/lib/public-pool && sudo rm /usr/bin/public-pool
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
sudo ufw delete X
```

### Port reference

<table><thead><tr><th align="center">Port</th><th width="100">Protocol<select><option value="K1YTaXNgK9iY" label="TCP" color="blue"></option><option value="rBwkQwPZUMt0" label="SSL" color="blue"></option><option value="zQnHZmzcUdq4" label="UDP" color="blue"></option></select></th><th align="center">Use</th></tr></thead><tbody><tr><td align="center">4040</td><td><span data-option="rBwkQwPZUMt0">SSL</span></td><td align="center">HTTPS port (encrypted)</td></tr><tr><td align="center">23333</td><td><span data-option="K1YTaXNgK9iY">TCP</span></td><td align="center">Default API port</td></tr><tr><td align="center">23334</td><td><span data-option="K1YTaXNgK9iY">TCP</span></td><td align="center">Default Stratum Port</td></tr></tbody></table>
