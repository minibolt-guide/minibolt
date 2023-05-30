---
layout: default
title: Electrs
parent: + Bitcoin
grand_parent: Bonus Section
nav_exclude: true
has_children: false
has_toc: false
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->

# Bonus guide: Electrs

{: .no_toc }

---

We set up [Electrs](https://github.com/romanz/electrs/){:target="_blank"} to serve as a full Electrum server for use with your Bitcoin software or hardware wallets.

Difficulty: Medium
{: .label .label-yellow }

Status: Tested MiniBolt
{: .label .label-blue }

![Electrs logo](../../../images/electrs-logo.png)

---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Preparations

Make sure that you have [reduced the database cache of Bitcoin Core](../../../guide/bitcoin/bitcoin-client.md#activate-mempool--reduce-dbcache-after-a-full-sync) after a full sync.

Electrs is a replacement for a [Fulcrum](../../bitcoin/electrum-server.md), these two services cannot be run at the same time (due to the same standard ports used), remember to stop Fulcrum by doing `"sudo systemctl stop fulcrum"`.

### **Install dependencies**

* Install build tools needed to compile Electrs from the source code

  ```sh
  $ sudo apt install cargo clang cmake build-essential librocksdb-dev
  ```

### **Firewall & reverse proxy**

In the [Security section](../system/security.md), we already set up NGINX as a reverse proxy.
Now we can add the Electrs configuration.

* Enable NGINX reverse proxy to add SSL/TLS encryption to the Electrs communication.
  Create the configuration file and paste the following content

  ```sh
  $ sudo nano /etc/nginx/streams-enabled/electrs-reverse-proxy.conf
  ```

  ```nginx
  upstream electrs {
    server 127.0.0.1:50001;
  }
  server {
    listen 50002 ssl;
    proxy_pass electrs;
  }
  ```

* Test and reload NGINX configuration

  ```sh
  $ sudo nginx -t
  $ sudo systemctl reload nginx
  ```

* Configure the firewall to allow incoming requests

  ```sh
  $ sudo ufw allow 50002/tcp comment 'allow Electrs SSL from anywhere'
  ```

  ```sh
  $ sudo ufw allow 50001/tcp comment 'allow Electrs TCP from anywhere'
  ```

## Electrs

An easy and performant way to run an Electrum server is to use [Electrs](https://github.com/romanz/electrs){:target="_blank"}, the Electrum Server in Rust.
There are no binaries available, so we will compile the application ourselves.

### **Build from source code**

We get the latest release of the Electrs source code, verify it, compile it to an executable binary and install it.

* Download the source code for the latest Electrs release.
  You can check the [release page](https://github.com/romanz/electrs/releases){:target="_blank"} to see if a newer release is available.
  Other releases might not have been properly tested with the rest of the MiniBolt configuration, though.

  ```sh
  $ cd /tmp
  ```

* Set a temporary version environment variable to the installation

  ```sh
  $ VERSION=0.9.13
  ```

  ```sh
  $ git clone --branch v$VERSION https://github.com/romanz/electrs.git
  ```

  ```sh
  $ cd electrs
  ```

* To avoid using bad source code, verify that the release has been properly signed by the main developer [Roman Zeyde](https://github.com/romanz){:target="_blank"}.

  ```sh
  $ curl https://romanzey.de/pgp.txt | gpg --import
  ```

Expected output:

  ```
  >   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
  >                                    Dload  Upload   Total   Spent    Left  Speed
  > 100  1255  100  1255    0     0   3562      0 --:--:-- --:--:-- --:--:--  3555
  > gpg: key 87CAE5FA46917CBB: public key "Roman Zeyde <me@romanzey.de>" imported
  > gpg: Total number processed: 1
  > gpg:               imported: 1
  ```

  ```sh
  $ git verify-tag v$VERSION
  ```

Expected output:

  ```
  > gpg: Signature made Thu 03 Nov 2022 03:37:23 PM UTC
  > gpg:                using ECDSA key 15C8C3574AE4F1E25F3F35C587CAE5FA46917CBB
  > gpg:                issuer "me@romanzey.de"
  > gpg: Good signature from "Roman Zeyde <me@romanzey.de>" [unknown]
  > gpg:                 aka "Roman Zeyde <roman.zeyde@gmail.com>" [unknown]
  > gpg: WARNING: This key is not certified with a trusted signature!
  > gpg:          There is no indication that the signature belongs to the owner.
  > Primary key fingerprint: 15C8 C357 4AE4 F1E2 5F3F  35C5 87CA E5FA 4691 7CBB
  ```

* Now compile the source code into an executable binary and install it. The compilation process can take up to one hour.

  ```sh
  $ ROCKSDB_INCLUDE_DIR=/usr/include ROCKSDB_LIB_DIR=/usr/lib CARGO_NET_GIT_FETCH_WITH_CLI=true cargo build --locked --release
  ```

  ```sh
  $ sudo install -m 0755 -o root -g root -t /usr/local/bin ./target/release/electrs
  ```

* Check the correct installation

  ```sh
  $ electrs --version
  ```

Expected output:

  ```
  > $VERSION
  ```

* Return to the home folder and delete folder `/electrs` to be ready for the next update, if the prompt asks you `rm: remove write-protected regular file...` type `yes` and press `enter`

  ```sh
  $ cd
  ```

  ```sh
  $ rm -r /tmp/electrs
  ```

### **Configuration**

* Create the "electrs" service user, and make it a member of the "bitcoin" group

  ```sh
  $ sudo adduser --disabled-password --gecos "" electrs
  ```

  ```sh
  $ sudo adduser electrs bitcoin
  ```

* Create the Electrs data directory

  ```sh
  $ sudo mkdir /data/electrs
  ```

  ```sh
  $ sudo chown -R electrs:electrs /data/electrs
  ```

* Switch to the "electrs" user and create the config file with the following content

  ```sh
  $ sudo su - electrs
  ```

  ```sh
  $ nano /data/electrs/electrs.conf
  ```

  ```
  # MiniBolt: electrs configuration
  # /data/electrs/electrs.conf

  # Bitcoin Core settings
  network = "bitcoin"
  daemon_dir= "/data/bitcoin"
  cookie_file= "/data/bitcoin/.cookie"
  daemon_rpc_addr = "127.0.0.1:8332"
  daemon_p2p_addr = "127.0.0.1:8333"

  # Electrs settings
  electrum_rpc_addr = "127.0.0.1:50001"
  db_dir = "/data/electrs/db"
  server_banner = "Welcome to electrs (Electrum Rust Server) running on a MiniBolt node!"

  # Logging
  log_filters = "INFO"
  timestamp = true
  ```

* Exit "electrs" user session to return to the "admin" user session

  ```sh
  $ exit
  ```

### **Autostart on boot**

Electrs need to start automatically on system boot.

* As user "admin", create the Electrs systemd unit and copy/paste the following configuration. Save and exit

  ```sh
  $ sudo nano /etc/systemd/system/electrs.service
  ```

  ```
  # MiniBolt: systemd unit for electrs
  # /etc/systemd/system/electrs.service

  [Unit]
  Description=Electrs daemon
  After=bitcoind.service

  [Service]
  ExecStart=/usr/local/bin/electrs --conf /data/electrs/electrs.conf --skip-default-conf-files
  Type=simple
  TimeoutSec=3600
  KillMode=process
  User=electrs
  RuntimeDirectory=electrs
  RuntimeDirectoryMode=0710
  PrivateTmp=true
  ProtectSystem=full
  ProtectHome=true
  PrivateDevices=true
  MemoryDenyWriteExecute=true

  [Install]
  WantedBy=multi-user.target
  ```

* Enable autoboot

  ```sh
  $ sudo systemctl enable electrs
  ```

* Prepare "electrs" monitoring by the systemd journal and check log logging output. You can exit monitoring at any time by with `Ctrl-C`

  ```sh
  $ sudo journalctl -f -u electrs
  ```

## Run Electrs

To keep an eye on the software movements, [Start your SSH program](../system/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node and log in as "admin".
Commands for the **second session** start with the prompt `$2` (which must not be entered).

* Start the service. It will immediately start with the initial indexing of the Bitcoin blocks.

  ```sh
  $2 sudo systemctl start electrs
  ```

Monitor the systemd journal at the first session created to check if everything works fine:

  ```
  Starting electrs $VERSION on x86_64 linux with Config { network: Bitcoin, db_path: "/data/electrs/db/bitcoin", daemon_dir: "/data/bitcoin", daemon_auth: CookieFile("/data/bitcoin/.cookie"), daemon_rpc_addr: 127.0.0.1:8332, daemon_p2p_addr: 127.0.0.1:8333, electrum_rpc_addr: 127.0.0.1:50001, monitoring_addr: 127.0.0.1:4224, wait_duration: 10s, jsonrpc_timeout: 15s, index_batch_size: 10, index_lookup_limit: None, reindex_last_blocks: 0, auto_reindex: true, ignore_mempool: false, sync_once: false, disable_electrum_rpc: false, server_banner: "Welcome to electrs (Electrum Rust Server) running on a MiniBolt node!", args: [] }
  [2021-11-09T07:09:42.744Z INFO  electrs::metrics::metrics_impl] serving Prometheus metrics on 127.0.0.1:4224
  [2021-11-09T07:09:42.744Z INFO  electrs::server] serving Electrum RPC on 127.0.0.1:50001
  [2021-11-09T07:09:42.812Z INFO  electrs::db] "/data/electrs/db/bitcoin": 0 SST files, 0 GB, 0 Grows
  [2021-11-09T07:09:43.174Z INFO  electrs::index] indexing 2000 blocks: [1..2000]
  [2021-11-09T07:09:44.665Z INFO  electrs::chain] chain updated: tip=00000000dfd5d65c9d8561b4b8f60a63018fe3933ecb131fb37f905f87da951a, height=2000
  [2021-11-09T07:09:44.986Z INFO  electrs::index] indexing 2000 blocks: [2001..4000]
  [2021-11-09T07:09:46.191Z INFO  electrs::chain] chain updated: tip=00000000922e2aa9e84a474350a3555f49f06061fd49df50a9352f156692a842, height=4000
  [2021-11-09T07:09:46.481Z INFO  electrs::index] indexing 2000 blocks: [4001..6000]
  [2021-11-09T07:09:47.581Z INFO  electrs::chain] chain updated: tip=00000000dbbb79792303bdd1c6c4d7ab9c21bba0667213c2eca955e11230c5a5, height=6000
  [2021-11-09T07:09:46.481Z INFO  electrs::index] indexing 2000 blocks: [6001..8000]
  [2021-11-09T07:09:47.581Z INFO  electrs::chain] chain updated: tip=00000000dbbb79792303bdd1c6c4d7ab9c21bba0667213c2eca955e11230c5a6, height=8000
  [2021-11-09T07:09:46.481Z INFO  electrs::index] indexing 2000 blocks: [8001..10000]
  [2021-11-09T07:09:47.581Z INFO  electrs::chain] chain updated: tip=00000000dbbb79792303bdd1c6c4d7ab9c21bba0667213c2eca955e11230c5a7, height=10000
  [...]
  [2021-11-09T07:09:46.481Z INFO  electrs::index] indexing 65 blocks: [756001..756065]
  [2021-11-09T07:09:47.581Z INFO  electrs::chain] chain updated: tip=00000000dbbb79792303bdd1c6c4d7ab9c21bba0667213c2eca955e11230c510, height=756065
  [2021-11-09T07:09:47.581Z INFO  electrs::db] starting config compaction
  [2021-11-09T07:09:47.581Z INFO  electrs::db] starting headers compaction
  [2021-11-09T07:09:47.581Z INFO  electrs::db] starting txid compaction
  [2021-11-09T07:09:47.581Z INFO  electrs::db] starting funding compaction
  [2021-11-09T07:09:47.581Z INFO  electrs::db] starting spending compaction
  [...]
  ```

Electrs will now index the whole Bitcoin blockchain so that it can provide all necessary information to wallets.
With this, the wallets you use no longer need to connect to any third-party server to communicate with the Bitcoin peer-to-peer network.

* Ensure electrs service is working and listening at the default `50001` and `50002` ports

  ```sh
  $2 sudo ss -tulpn | grep LISTEN | grep electrs
  ```

💡 Electrs must first fully index the blockchain and compact its database before you can connect to it with your wallets.
This can take a few hours.
Only proceed with the [next section](desktop-wallet.md) once Electrs is ready.

### **Remote access over Tor (optional)**

To use your Electrum server when you're on the go, you can easily create a Tor hidden service.
This way, you can connect the BitBoxApp or Electrum wallet also remotely, or even share the connection details with friends and family.
Note that the remote device needs to have Tor installed as well.

* Ensure are you logged in with user `admin`, add the following three lines in the section for "location-hidden services" in the `torrc` file

  ```sh
  $ sudo nano /etc/tor/torrc
  ```

  ```
  ############### This section is just for location-hidden services ###
  # Hidden Service Electrs TCP & SSL
  HiddenServiceDir /var/lib/tor/hidden_service_electrs_tcp_ssl/
  HiddenServiceVersion 3
  HiddenServicePort 50001 127.0.0.1:50001
  HiddenServicePort 50002 127.0.0.1:50002
  ```

* Reload the Tor configuration, get your connection addresses and take note of these, later you will need them.

  ```sh
  $ sudo systemctl reload tor
  ```

  ```sh
  $ sudo cat /var/lib/tor/hidden_service_electrs_tcp_ssl/hostname
  ```

Expected output:

  ```
  > abcdefg..............xyz.onion
  ```

* You should now be able to connect to your Electrs server remotely via Tor using your hostname and port 50002 (SSL) or 50001 (TCP)

### **Migrate BTC RPC Explorer to Electrs API connection**

To get address balances, either an Electrum server or an external service is necessary. Your local Electrs server can provide address transaction lists, balances, and more.

* As user `admin`, open the `btcrpcexplorer` service

  ```sh
  $ sudo nano /etc/systemd/system/btcrpcexplorer.service
  ```

* Replace the `"After=fulcrum.service"` with the `"After=electrs.service"` parameter. Save and exit

  ```sh
  After=electrs.service
  ```

* Restart the BTC RPC Explorer service to apply the changes

  ```sh
  $ sudo systemctl restart btcrpcexplorer
  ```

## For the future: Electrs upgrade

Updating Electrs is straight-forward.
You can display the current version with the command below and check the Electrs [release page](https://github.com/romanz/electrs/releases){:target="_blank"} to see if a newer version is available.

🚨 **Check the release notes!**
Make sure to check the [release notes](https://github.com/romanz/electrs/blob/master/RELEASE-NOTES.md){:target="_blank"} first to understand if there have been any breaking changes or special upgrade procedures.

* Check the current Electrs version

  ```sh
  $ electrs --version
  ```

Expected output:

  ```
  > $VERSION
  ```

* Download the source code for the latest Electrs release.
  You can check the [release page](https://github.com/romanz/electrs/releases){:target="_blank"} to see if a newer release is available.
  Other releases might not have been properly tested with the rest of the MiniBolt configuration, though.

  ```sh
  $ cd /tmp
  ```

* Replace the environment variable `"VERSION=x.xx"` value for the latest if it has not been already changed in this guide

  ```sh
  $ VERSION=0.9.13
  ```

  ```sh
  $ git clone --branch v$VERSION https://github.com/romanz/electrs.git
  ```

  ```sh
  $ cd electrs
  ```

* To avoid using bad source code, verify that the release has been properly signed by the main developer [Roman Zeyde](https://github.com/romanz){:target="_blank"}.

  ```sh
  $ curl https://romanzey.de/pgp.txt | gpg --import
  ```

Expected output:

  ```
  >   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
  >                                    Dload  Upload   Total   Spent    Left  Speed
  > 100  1255  100  1255    0     0   3562      0 --:--:-- --:--:-- --:--:--  3555
  > gpg: key 87CAE5FA46917CBB: public key "Roman Zeyde <me@romanzey.de>" imported
  > gpg: Total number processed: 1
  > gpg:               imported: 1
  ```

  ```sh
  $ git verify-tag v$VERSION
  ```

Expected output:

  ````
  > gpg: Signature made Thu 03 Nov 2022 03:37:23 PM UTC
  > gpg:                using ECDSA key 15C8C3574AE4F1E25F3F35C587CAE5FA46917CBB
  > gpg:                issuer "me@romanzey.de"
  > gpg: Good signature from "Roman Zeyde <me@romanzey.de>" [unknown]
  > gpg:                 aka "Roman Zeyde <roman.zeyde@gmail.com>" [unknown]
  > gpg: WARNING: This key is not certified with a trusted signature!
  > gpg:          There is no indication that the signature belongs to the owner.
  > Primary key fingerprint: 15C8 C357 4AE4 F1E2 5F3F  35C5 87CA E5FA 4691 7CBB
  ```

* Now compile the source code into an executable binary and install it. The compilation process can take up to one hour.

  ```sh
  $ ROCKSDB_INCLUDE_DIR=/usr/include ROCKSDB_LIB_DIR=/usr/lib CARGO_NET_GIT_FETCH_WITH_CLI=true cargo build --locked --release
  ```

  ```sh
  $ sudo install -m 0755 -o root -g root -t /usr/local/bin ./target/release/electrs
  ```

* Check the correct installation

  ```sh
  $ electrs --version
  ```

Expected output:

  ```
  > v$VERSION
  ```

* Return to the home folder and delete folder `/electrs` to be ready for the next update, if the prompt asks you `rm: remove write-protected regular file...` type `yes` and press `enter`

  ```sh
  $ cd
  ```

  ```sh
  $ rm -r /tmp/electrs
  ```

* Restart Electrs to apply the new version

  ```sh
  $ sudo systemctl restart electrs
  ```

<br /><br />

---

<< Back: [+ Bitcoin](index.md)
