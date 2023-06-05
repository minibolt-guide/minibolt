---
layout: default
title: MiniBolt on Testnet
parent: + Bitcoin
grand_parent: Bonus Section
nav_exclude: true
has_children: false
has_toc: false
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->

# Bonus guide: MiniBolt on Testnet

{: .no_toc }

---

You can run your MiniBolt node on testnet to develop and experiment with new applications, without putting real money at risk. This bonus guide highlights all configuration changes compared to the main guide.

Difficulty: Medium
{: .label .label-yellow }

---

## Table of contents
{: .text-delta }

1. TOC
{:toc}

---

# Introduction

Running a testnet node is a great way to get acquainted with the MiniBolt and the suite of Bitcoin-related software typical of these powerful setups. Moreover, testnet empowers users to tinker with the software and its many configurations without the threat of losing funds. Helping bitcoiners run a full testnet setup is a goal worthy of the MiniBolt, and this page should provide you with the knowledge to get there.

The great news is that most of the MiniBolt guide can be used as-is. The small adjustments come in the form of changes to the config files and ports for testnet. You can follow the guide and simply replace the following configurations in the right places as you go.

# Only testnet mode

## Bitcoin

### **Bitcoin client**

Follow the complete guide from the beginning, when you arrive at the [configuration section](../../bitcoin/bitcoin-client.md#configuration), stay tuned to replace and add the next lines on the "bitcoin.conf" file

  ```
  ## Replace
  startupnotify=chmod g+r /home/bitcoin/.bitcoin/testnet3/.cookie
  ## Add
  testnet=1
  ```

The rest of the Bitcoin client guide is completely equal. Note that the seeds nodes of the [privacy mode](../../bitcoin/bitcoin-client.md#privacy-mode) section will be different, being correct those on this [list](https://github.com/bitcoin/bitcoin/blob/master/contrib/seeds/nodes_test.txt). There are only Tor seed nodes, no clearnet or I2P nodes.

### **Fulcrum**

  ```sh
  $ nano /data/fulcrum/fulcrum.conf
  ```

  ```
  # Bitcoin Core settings
  bitcoind = 127.0.0.1:18332
  rpccookie = /data/bitcoin/testnet3/.cookie

  # Fulcrum server general settings
  ssl = 0.0.0.0:60002
  tcp = 0.0.0.0:60001

  # Banner
  banner = /data/fulcrum/fulcrum-banner-testnet.txt
  ```

### **Electrs**

  ```
  # Bitcoin Core settings
  network = "testnet"
  daemon_dir= "/data/bitcoin"
  cookie_file = "/data/bitcoin/testnet3/.cookie"
  daemon_rpc_addr = "127.0.0.1:18332"
  daemon_p2p_addr = "127.0.0.1:18333"

  # Electrs settings
  electrum_rpc_addr = "127.0.0.1:60001"
  db_dir = "/data/electrs/db/"
  server_banner = "Welcome to electrs (Electrum Rust Server) running on a MiniBolt node testnet!"

  # Logging
  log_filters = "INFO"
  timestamp = true
  ```

#### **Nginx**

File location: `/etc/nginx/streams-enabled/electrs-testnet-reverse-proxy.conf`

  ```
  upstream electrs {
    server 127.0.0.1:60001;
  }

  server {
    listen 60002 ssl;
    proxy_pass electrs;
  }
  ```

  ```sh
  $ sudo nginx -t
  ```

  ```sh
  $ sudo systemctl reload nginx
  ```

#### **Firewall**

  ```sh
  $ sudo ufw allow 60001/tcp comment 'allow Electrs TCP Testnet from anywhere'

  ```sh
  $ sudo ufw allow 60002/tcp comment 'allow Electrs SSL Testnet from anywhere'
  ```

#### **Tor**

Create a separate service for testnet over Tor by adding the following lines in the `location-hidden services` section:

File location: `/etc/tor/torrc`

  ```
  ############### This section is just for location-hidden services ###
  # Hidden Service Electrs Testnet TCP & SSL
  HiddenServiceDir /var/lib/tor/hidden_service_electrs_testnet_tcp_ssl/
  HiddenServiceVersion 3
  HiddenServicePort 60001 127.0.0.1:60001
  HiddenServicePort 60002 127.0.0.1:60002
  ```

Once that's done, you'll need to start the service using:

  ```sh
  $ sudo systemctl reload tor
  ```

  ```sh
  $ sudo cat /var/lib/tor/hidden_service_electrs_testnet_tcp_ssl/hostname
  ```

## Lightning

### **LND**

The following are the lines that need changing in the LND configuration file.

File location: `/data/lnd/lnd.conf`

  ```
  [Bitcoin]
  bitcoin.testnet=1
  ```

And the following command gives members of the group `lnd` permission to traverse the LND directories to reach the macaroons

  ```sh
  $ sudo chmod g+r /data/lnd/data/chain/bitcoin/testnet/admin.macaroon
  ```

### Interacting with the LND daemon

Note that when interacting with the LND daemon, you'll need to use the `--network testnet` option like so:

  ```sh
  $ lncli --network testnet walletbalance
  ```

### **ThunderHub**

  ```sh
  $ sudo cp /data/lnd/data/chain/bitcoin/testnet/admin.macaroon /home/thunderhub/admin.macaroon
  ```

---

<< Back: [+ Bitcoin](index.md)
