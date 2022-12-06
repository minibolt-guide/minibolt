---
layout: default
title: Blockchain explorer
nav_order: 40
parent: Bitcoin
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD036 MD040 -->

# Blockchain explorer: BTC RPC Explorer

{: .no_toc }

---

Run your own private blockchain explorer with [BTC RPC Explorer](https://github.com/janoside/btc-rpc-explorer){:target="_blank"}. Trust your node, not some external services.

![BTC RPC Explorer home screen with dark theme](../../images/btcrpcexplorer-homepage.png)

---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Run your own blockchain explorer

After the MiniBolt runs your own fully validated node, and even acts as a backend for your hardware wallet with Fulcrum, the last important puzzle piece to improve privacy and financial sovereignty is your own Blockchain Explorer.
It lets you query transactions, addresses, and blocks of your choice.
You no longer need to leak information by querying a third-party blockchain explorer that can be used to get your location and cluster addresses.

[BTC RPC Explorer](https://github.com/janoside/btc-rpc-explorer){:target="_blank"} provides a lightweight and easy to use web interface to accomplish just that.
It's a database-free, self-hosted Bitcoin blockchain explorer, querying Bitcoin Core and Fulcrum via RPC.

## Preparations

### Install Node.js

* Add the [Node.js](https://nodejs.org){:target="_blank"} package repository from user "admin".
  We'll use version 16, which is the latest stable version.

  ```sh
  $ curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
  ```

* Install Node.js using the apt package manager.

  ```sh
  $ sudo apt install nodejs
  ```

### Reverse proxy & Firewall

In the [Security section](../system/security.md#prepare-nginx-reverse-proxy), we set up NGINX as a reverse proxy.
Now we can add the BTC RPC Explorer configuration.

* Enable NGINX reverse proxy to route external encrypted HTTPS traffic internally to the BTC RPC Explorer

  ```sh
  $ sudo nano /etc/nginx/streams-enabled/btcrpcexplorer-reverse-proxy.conf
  ```

  ```nginx
  upstream btcrpcexplorer {
    server 127.0.0.1:3002;
  }
  server {
    listen 4000 ssl;
    proxy_pass btcrpcexplorer;
  }
  ```

* Test and reload NGINX configuration

  ```sh
  $ sudo nginx -t
  $ sudo systemctl reload nginx
  ```

* Configure the firewall to allow incoming HTTPS requests

  ```sh
  $ sudo ufw allow from 192.168.0.0/16 to any port 4000 proto tcp comment 'allow BTC RPC Explorer SSL from local network'
  ```

## BTC RPC Explorer

### Installation

For improved security, we create the new user "btcrpcexplorer" that will run the block explorer.
Using a dedicated user limits potential damage in case there's a security vulnerability in the code.
An attacker would not be able to do much within this user's permission settings.

* Create a new user, assign it to the "bitcoin" group, and open a new session

  ```sh
  $ sudo adduser --disabled-password --gecos "" btcrpcexplorer
  $ sudo adduser btcrpcexplorer bitcoin
  $ sudo su btcrpcexplorer
  ```

* Download the source code directly from GitHub and install all dependencies using the Node Package Manager (NPM).

  ```sh
  $ git clone --branch v3.3.0 https://github.com/janoside/btc-rpc-explorer.git
  $ cd btc-rpc-explorer
  $ npm install
  ```

Installation can take some time, up to 20 minutes.
There might be a lot of confusing output, but if you see something similar to the following, the installation was successful:

  ```sh
  > Installed to /home/btcrpcexplorer/btc-rpc-explorer/node_modules/node-sass/vendor/linux-amd64-83/binding.node
  > added 480 packages from 307 contributors and audited 482 packages in 570.14s
  > 
  > 43 packages are looking for funding
  >   run `npm fund` for details
  > 
  > found 12 vulnerabilities (8 moderate, 4 high)
  >   run `npm audit fix` to fix them, or `npm audit` for details
  ```

### Configuration

* Copy and edit the configuration template (skip this step when updating).
  Activate any setting by removing the `#` at the beginning of the line.

  ```sh
  $ cp .env-sample .env
  $ nano .env
  ```

* Instruct BTC RPC Explorer to connect to local Bitcoin Core

  ```sh
  BTCEXP_BITCOIND_HOST=127.0.0.1
  BTCEXP_BITCOIND_PORT=8332
  BTCEXP_BITCOIND_COOKIE=/data/bitcoin/.cookie
  ```

* To get address balances, either an Electrum server or an external service is necessary.
  Your local Fulcrum server can provide address transaction lists, balances, and more.

  ```sh
  BTCEXP_ADDRESS_API=electrum
  BTCEXP_ELECTRUM_SERVERS=tls://127.0.0.1:50002
  ```

* Uncomment this line

  ```sh
  BTCEXP_SLOW_DEVICE_MODE=false
  ```

#### Optional

* You can decide whether you want to optimize for more information or for more privacy.

  * More information mode, including Bitcoin exchange rates:

    ```sh
    BTCEXP_PRIVACY_MODE=false
    BTCEXP_NO_RATES=false
    ```

  * More privacy mode, no external queries:

    ```sh
    BTCEXP_PRIVACY_MODE=true
    BTCEXP_NO_RATES=true
    ```

* If you don't use Nginx reverse proxy configuration to receive and send the request to the browser, you will need to open BTC RPC Explorer to connect from the local network, uncomment and replace this line and configure FW accordingly (not recommended)

  ```sh
  BTCEXP_HOST=0.0.0.0
  ```

* You can add password protection to the web interface.
  Simply add password [D] for the following option, for which the browser will then prompt you.
  You can enter any user name; only the password is checked.

  ```sh
  BTCEXP_BASIC_AUTH_PASSWORD=YourPassword[D]
  ```

* Decide whether you prefer a `light` or `dark` theme by default

  ```sh
  BTCEXP_UI_THEME=dark
  ```

* Save and exit

* Exit "btcrpcexplorer" user session to return to "admin" user session

  ```sh
  $ exit
  ```

### Autostart on boot

Now we'll make sure our blockchain explorer starts as a service on the Raspberry Pi so that it's always running.
In order to do that, we create a systemd unit that starts the service on boot directly after Bitcoin Core.

* As user "admin", create the service file

  ```sh
  $ sudo nano /etc/systemd/system/btcrpcexplorer.service
  ```

* Paste the following configuration. Save and exit

  ```sh
  # MiniBolt: systemd unit for BTC RPC Explorer
  # /etc/systemd/system/btcrpcexplorer.service

  [Unit]
  Description=BTC RPC Explorer
  After=bitcoind.service fulcrum.service
  PartOf=bitcoind.service

  [Service]
  WorkingDirectory=/home/btcrpcexplorer/btc-rpc-explorer
  ExecStart=/usr/bin/npm start
  User=btcrpcexplorer
  Restart=always
  RestartSec=30

  [Install]
  WantedBy=multi-user.target
  ```

* Enable the service

  ```sh
  $ sudo systemctl enable btcrpcexplorer

* Prepare "btcrpcexplorer" monitoring by the systemd journal and check log logging output. You can exit monitoring at any time by with `Ctrl-C`

  ```sh
  $ sudo journalctl -f -u btcrpcexplorer
  ```

## Run BTC RPC Explorer

[Start your SSH program](../system/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the PC and log in as "admin".
Commands for the **second session** start with the prompt `$2` (which must not be entered).

* Start the service.

  ```sh
  $2 sudo systemctl start btcrpcexplorer
  ```

Now point your browser to the secure access point provided by the NGINX web proxy, for example <https://minibolt.local:4000> (or your nodes IP address like <https://192.168.0.20:4000>). You should see the home page of BTC RPC Explorer.

Your browser will display a warning because we use a self-signed SSL certificate.
We can do nothing about that because we would need a proper domain name (e.g., https://yournode.com) to get an official certificate that browsers recognize.
Click on "Advanced" and proceed to the Block Explorer web interface.

* If you see a lot of errors on the MiniBolt command line, then Bitcoin Core might still be indexing the blockchain.
  You need to wait until reindexing is done before using the BTC RPC Explorer.

**Congratulations!**
You now have the BTC RPC Explorer running to check the Bitcoin network information directly from your node.

## Extras

### Slow device mode

* With user `admin`, change to the `btcrpcexplorer` user

  ```sh
  $ sudo su btcrpcexplorer
  ```

* Edit `.env` configuration file

  ```sh
  $ nano /home/btcrpcexplorer/btc-rpc-explorer/.env
  ```

* Extend the timeout period due to the limited resources of your possible PC

  ```sh
  BTCEXP_BITCOIND_RPC_TIMEOUT=10000
  ```

* Comment this line if it is uncommented

  ```sh
  #BTCEXP_SLOW_DEVICE_MODE=false
  ```

### Sharing your Explorer

You may want to share your BTC RPC Explorer **onion** address with confident people and limited Bitcoin Core RPC access requests (sensitive data requests will be kept disabled, don't trust, [verify](https://github.com/janoside/btc-rpc-explorer/blob/fc0c175e006dd7ff415f17a7b0e200f8a4cd5cf0/app/config.js#L131-L204). Enabling "DEMO" mode, you will not have to provide password and RPC requests will be allowed (discarding rpcBlacklist commands).

  ```sh
  BTCEXP_DEMO=true
  ```

💡 Remember to give them the `password [D]` if you added password protection in the reference step.

### Remote access over Tor (optional)

Do you want to access your personal blockchain explorer remotely?
You can easily do so by adding a Tor hidden service on the MiniBolt and accessing the BTC RPC Explorer with the Tor browser from any device.

* Add the following three lines in the "location-hidden services" section in the `torrc` file.
  Save and exit.

  ```sh
  $ sudo nano /etc/tor/torrc
  ```

  ```sh
  ############### This section is just for location-hidden services ###
  # Hidden Service BTC RPC Explorer
  HiddenServiceDir /var/lib/tor/hidden_service_btcrpcexplorer/
  HiddenServiceVersion 3
  HiddenServicePort 80 127.0.0.1:3002
  ```

* Reload Tor configuration and get your connection address.

  ```sh
  $ sudo systemctl reload tor
  $ sudo cat /var/lib/tor/hidden_service_btcrpcexplorer/hostname
  > abcdefg..............xyz.onion
  ```

* With the [Tor browser](https://www.torproject.org){:target="_blank"}, you can access this onion address from any device.

## For the future: BTC RPC Explorer update

Updating to a [new release](https://github.com/janoside/btc-rpc-explorer/releases){:target="_blank"} is straight-forward, but make sure to check out the [change log](https://github.com/janoside/btc-rpc-explorer/blob/master/CHANGELOG.md){:target="_blank"} first.

* From user "admin", stop the service and open a "btcrpcexplorer" user session.

  ```sh
  $ sudo systemctl stop btcrpcexplorer
  $ sudo su btcrpcexplorer
  ```

* Fetch the latest GitHub repository information, display the release tags (use the latest `v3.3.0` in this example), and update:

  ```sh
  $ cd /home/btcrpcexplorer/btc-rpc-explorer
  $ git fetch
  $ git reset --hard HEAD
  $ git tag
  $ git checkout v3.3.0
  $ npm install
  $ exit
  ```

* Start the service again.

  ```sh
  $ sudo systemctl start btcrpcexplorer
  ```

<br /><br />

---

Next: [Lightning >>](../lightning/index.md)
