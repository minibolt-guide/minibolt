---
title: + Lightning
nav_order: 3000
parent: Bonus Section
has_children: false
has_toc: false
---

# Lightning

## Bonus Section: Lightning guides

### Lightning clients

* [**Core Lightning (CLN)**](cln.md) - An alternative lightning client to LND or if you want to run a Core Lightning node alongside your LND node.

### Maintenance

* [**Use lncli on a different computer**](remote-lncli.md) - control your Lightning node from a different computer within your network, eg. from a Windows machine

### Security

* [**Circuit Breaker**](circuit-breaker.md) - a lightning firewall to protect your node against HTLC flooding attacks

### Monitoring

* [**AmbossPing**](ambossping.md) - easy to use script to send heartbeat pings to the amboss.space monitoring service

### Dashboards & Wallets

#### _CLI-only_

* [**lntop**](lntop.md) - lntop is an interactive text-mode channels viewer for Unix systems
* [**lnbalance**](lnbalance.md) - a simple node balances viewer
* [**lnchannels**](lnchannels.md) - a simple channels viewer

#### _GUI - Desktop_

* [**Zap**](zap-desktop.md) - a cross platform Lightning Network wallet focused on user experience and ease of use

#### _GUI - Mobile_

* [**Zap (iOS)**](zap-ios.md) - a neat interface to manage peers & channels, make payments and create invoices

#### _GUI, API - Web_

* [**LNBits**](lnbits.md) - a lightning wallet/accounts system
* [**LNDg**](lndg.md) - a simple web GUI for power users to automate the management of routing nodes
* [**Ride the Lightning**](ride-the-lightning.md) - a full function web browser app for LND, C-Lightning and Eclair

### Liquidity management

* [**Balance of Satoshis**](balance-of-satoshis.md) - a tool to rebalance your channels and set up a LN node monitoring Telegram bot
* [**Lightning Terminal**](lightning-terminal.md) - a browser-based GUI for managing channel liquidity with Loop and Pool
* [**rebalance-lnd**](rebalance-lnd.md) - a simple script to manage your channel liquidity by doing circular rebalancing
* [**CLBoss**](clboss.md) - an automated node management tool for CLN
* [**regolancer**](regolancer.md) - light, quick and efficient LND rebalancer written in Go

### Fee management

* [**charge-lnd**](charge-lnd.md) - a simple policy-based fee manager for LND

### Hybrid Mode - Clearnet over VPN

* [**Tunnel⚡️Sats**](tunnelsats.md) - enable hybrid mode: Tor and clearnet over VPN (**paid service**)

### Even more Extras

#### [RaspiBolt/MiniBolt Extras by Rob Clark](https://github.com/robclark56/RaspiBolt-Extras/blob/master/README.md)

* [**Lights-Out**](https://github.com/robclark56/RaspiBolt-Extras/#the-lights-out-raspibolt) - automatic unlocking of wallet and dynamic IP
* [**RaspiBoltDuo**](https://github.com/robclark56/RaspiBolt-Extras/#raspiboltduo) - testnet & mainnet running simultaneously
* [**Using REST access**](https://github.com/robclark56/RaspiBolt-Extras/#using-rest-access) - to enable and demonstrate using the REST interface instead of rpc/lncli
* [**Receiving Lightning payments**](https://github.com/robclark56/RaspiBolt-Extras/#receive-ln-payments) - automatically create invoices / QR codes
