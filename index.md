---
layout: default
title: Home
nav_order: 1
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->
{% include include_metatags.md %}

#### <span style="color:red">⚠️ Attention! This project is a fork under construction, some chapters could not be attached to the reference use case. Pay special attention to the **"Status: Not tested MiniBolt"** tag at the beginning of the guides. Be careful and act at your own risk.</span>

![MiniBolt Logo](images/minibolt-home-screen.png)

Build your own "do-everything-yourself" Bitcoin full node that will make you a sovereign peer in the Bitcoin and Lightning network.
{: .fs-6 }

No need to trust anyone else.
{: .fs-6 }

---

## What is the MiniBolt?

With this guide, you can set up a Bitcoin and Lightning node from scratch, doing everything yourself.
You will learn about Linux, Bitcoin, and Lightning.
As a result, you'll have your very own MiniBolt node, built by you and no one else.

There are many reasons why you should run your own Bitcoin node.

* **Keep Bitcoin decentralized.** Use your node to help enforce your Bitcoin consensus rules.
* **Take back your sovereignty.** Let your node validate your own Bitcoin transactions. No need to ask someone else to tell you what's happening in the Bitcoin network.
* **Improve your privacy.** Connect your wallets to your node so that you no longer need to reveal their whole financial history to external servers.
* **Be part of Lightning.** Run your own Lightning node for everyday payments and help building a robust, decentralized Bitcoin Lightning network.

Did we mention that it's fun, as well?

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

We strive to give foolproof instructions.
But the goal is also to do everything ourselves.
Shortcuts that involve trusting someone else are not allowed.
This makes this guide quite technical, but we try to make it as straightforward as possible.
You'll gain a basic understanding of the how and why.

If you like to learn about Linux, Bitcoin, and Lightning, then this guide is for you.

### Structure

We aim to keep the core of this guide well maintained and up-to-date:

1. [System](guide/system/index.md): prepare the hardware and set up the operating system
1. [Bitcoin](guide/bitcoin/index.md): sync your own Bitcoin full node, Electrum server, and Blockchain Explorer
1. [Lightning](guide/lightning/index.md): run your own Lightning client with web-based node management

The bonus section contains more specific guides that build on top of the main section.
More fun, lots of knowledge, but with lesser maintenance guarantees.
Everything is optional.

* [Bonus guides](guide/bonus/index.md)

---

## Community

This is a community project.
Find help and other MiniBolters on the following platforms:

* [Github Issues / Knowledge Base](https://github.com/twofaktor/minibolt/issues){:target="_blank"}
* Reddit sub: r/minibolt (coming soon..)
* Telegram group: t.me/minibolt (coming soon..)

And feel free to join the many other contributors if you see something that can be improved!

---

## Rating

All guides are rated with labels to help you assess the difficulty of each guide, and if it is tested against the most recent version of the main guide.

* Difficulty: indicates how difficult the bonus guide is in term of installation procedure or usage

Difficulty: Easy
{: .label .label-green }

Difficulty: Medium
{: .label .label-yellow }

Difficulty: Hard
{: .label .label-red }

* Tested: indicates if the guide has been updated and tested on the RaspiBolt v3 and MiniBolt. If this is not the case, you might have to modify part of the guide to make it work on a RaspiBolt v3 ort MiniBolt.

Status: Tested MiniBolt
{: .label .label-blue }

Status: Not tested MiniBolt
{: .label .label-red }

Status: Tested RaspiBolt v3
{: .label .label-green }

Status: Not tested RaspiBolt v3
{: .label .label-yellow }

<br /><br />

---

Get started: [System >>](guide/system/index.md)
