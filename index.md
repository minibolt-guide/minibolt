---
layout: default
title: Home
nav_order: 1
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->
{% include include_metatags.md %}

##### <span style="color:red">⚠️ Attention! This project is a fork under construction, some chapters could not be attached to the reference use case. Pay special attention to the **"Status: Not tested MiniBolt"** tag at the beginning of the guides. Be careful and act at your own risk.</span>

![MiniBolt Logo](images/minibolt-home-screen.png)

Build your own "do-everything-yourself" Bitcoin full node on a personal computer, that will make you a sovereign peer in the Bitcoin and Lightning network.
{: .fs-5 }

No need to trust anyone else. Don't trust, verify!
{: .fs-5 }

---

## What is the MiniBolt?

With this guide, you can set up a Bitcoin and Lightning node on a personal computer from scratch, doing everything yourself.
You will learn about Linux, Bitcoin, and Lightning.
As a result, you'll have your very own Bitcoin node, built by you and no one else.

There are many reasons why you should run your own Bitcoin node:

* **Keep Bitcoin decentralized.** Use your node to help enforce your Bitcoin consensus rules.
* **Take back your sovereignty.** Let your node validate your own Bitcoin transactions. No need to ask someone else to tell you what's happening in the Bitcoin network.
* **Improve your privacy.** Connect your wallets to your node so that you no longer need to reveal their whole financial history to external servers.
* **Be part of Lightning.** Run your own Lightning node for everyday payments and help building a robust, decentralized Bitcoin Lightning network.

![Bitcoin Network](images/bitcoin-network-small.png)

---

## MiniBolt overview

This guide explains how to set up your own Bitcoin node on a Personal Computer.
But it works on most hardware platforms because it only uses standard Debian Linux commands.

### Features

Your Bitcoin node will offer the following functionality:

* **Bitcoin**: direct and trustless participation in the Bitcoin peer-to-peer network, full validation of blocks and transactions
* **Electrum server**: connect your compatible wallets (including hardware wallets) to your own node
* **Blockchain Explorer**: web-based Explorer to privately look up transactions, blocks, and more
* **Lightning**: full client with stable long-term channels and web-based and mobile-based management interfaces
* **Always on**: services are constantly synced and available 24/7
* **Reachable from anywhere**: connect to all your services through the Tor network

### Target audience

We strive to give foolproof instructions. But the goal is also to do everything ourselves.

Shortcuts that involve trusting someone else are not allowed. This makes this guide quite technical, but we try to make it as straightforward as possible.

You'll gain a basic understanding of the how and why.

If you like to learn about Linux, Bitcoin, and Lightning, then this guide is for you.

### Structure

We aim to keep the core of this guide well maintained and up-to-date:

1. [System](guide/system/index.md): prepare the hardware and set up the operating system
1. [Bitcoin](guide/bitcoin/index.md): sync your own Bitcoin full node, Electrum server, Blockchain Explorer, and connect a desktop wallet to the Electrum server
1. [Lightning](guide/lightning/index.md): run your own Lightning client with web-based node management, connect a mobile app, and save safely your SCB backup

The bonus section contains more specific guides that build on top of the main section.
More fun, lots of knowledge, but with lesser maintenance guarantees.
Everything is optional.

* [Bonus guides](guide/bonus/index.md)

---

## Community

* [Github Issues / Knowledge Base](https://github.com/twofaktor/minibolt/issues){:target="_blank"}

And feel free to join the many other contributors if you see something that can be improved!

---

## Rating

All guides are rated with labels to help you assess the difficulty of each guide, and if it is tested against the most recent version of the main guide.

* Difficulty: indicates how difficult the bonus guide is in term of installation procedure or usage.

Difficulty: Easy
{: .label .label-green }

Difficulty: Medium
{: .label .label-yellow }

Difficulty: Hard
{: .label .label-red }

* Tested: indicates if the guide has been updated and tested on the MiniBolt. If this is not the case, you might have to modify part of the guide to make it work on MiniBolt.

Status: Tested MiniBolt
{: .label .label-blue }

Status: Not tested MiniBolt
{: .label .label-red }

* Paid service: indicates if the service used in the guide is a free o a paid service.

Cost: Paid service
{: .label .label-yellow }

Cost: Free service
{: .label .label-green }

---

## Quick start guide

Recommended roadmap for Bitcoin + Lightning essential kit, tested on MiniBolt guide.

* Preparations
  * [Preparations](guide/system/preparations.md)
  * [Operating system](guide/system/operating-system.md)
  * [Remote access](guide/system/remote-access.md)
  * [Configuration](guide/system/configuration.md)
  * [Security](guide/system/security.md)
  * [Privacy](guide/system/privacy.md)

* Bitcoin

  * [Bitcoin client](guide/bitcoin/bitcoin-client.md)
  * [Electrum server](guide/bitcoin/electrum-server.md)
  * [Destop wallet](guide/bitcoin/desktop-wallet.md)
  * [Blockchain explorer](guide/bitcoin/blockchain-explorer.md)

* Lightning

  * [Lightning client](guide/lightning/lightning-client.md)
  * [Web app](guide/bonus/lightning/thunderhub.md)

---

<br /><br />

Get started: [System >>](guide/system/index.md)
