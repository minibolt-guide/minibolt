---
description: >-
  Build your own "DIY" Bitcoin & Lightning node, and other stuff on a personal
  computer. No need to trust anyone else.
---

# MiniBolt

<figure><img src=".gitbook/assets/minibolt-home-screen-og.png" alt=""><figcaption></figcaption></figure>

Build your own "do-everything-yourself" Bitcoin & Lightning node, and other stuff on a personal computer, making you sovereign.

No need to trust anyone else. Don't trust, verify!

## What is the MiniBolt?

With this guide, you can set up a Bitcoin, Lightning node, and other stuff on a personal computer, doing everything yourself. You will learn about Linux, Bitcoin, Lightning, and much more.

<figure><img src=".gitbook/assets/tgfoss-build-under-win.gif" alt=""><figcaption></figcaption></figure>

There are many reasons why you should run your own Bitcoin node:

👥 **Keep Bitcoin decentralized:** use your node to help enforce your Bitcoin consensus rules.

🗽 **Take back your sovereignty:** let your node validate your Bitcoin transactions. No need to ask someone else to tell you what's happening in the Bitcoin network.

🥷🏽 **Improve your privacy:** connect your wallets to your node so you no longer need to reveal their financial history to external servers.

⚡️ **Be part of Lightning:** run your Lightning node for everyday payments and help build a robust and decentralized Lightning network.

## MiniBolt overview

This guide explains setting up your own Bitcoin node on a personal computer. However, it works on most hardware platforms because it only uses standard Debian-based Linux commands.

### Features

Your Bitcoin node will offer the following functionality:

🟠 **Bitcoin**: direct and trustless participation in the Bitcoin peer-to-peer network, full validation of blocks and transactions.

⚛️ **Electrum server**: connect your compatible wallets (including hardware wallets) to your node.

⛓️ **Blockchain Explorer**: web-based Explorer to privately look up transactions, blocks, and more.

⚡ **Lightning**: full client with stable long-term channels and web-based and mobile-based management interfaces.

🔋 **Always on**: services are constantly synced and available 24/7.

🌐 **Reachable from anywhere**: connect to all your services through the Tor network and Wireguard VPN.

### Target audience

* [x] We strive to give foolproof instructions. But the goal is also to do everything ourselves.
* [x] Shortcuts that involve trusting someone else are not allowed. This makes this guide quite technical, but we try to make it as straightforward as possible.
* [x] You'll gain a basic understanding of the how and why.
* [x] If you want to learn about Linux, Bitcoin, and Lightning, this guide is for you.

### Structure

We aim to keep the core of this guide well-maintained and up-to-date:

<table data-view="cards" data-full-width="false"><thead><tr><th></th><th></th><th align="center"></th><th data-type="content-ref"></th><th data-type="content-ref"></th><th data-type="content-ref"></th><th data-hidden data-card-target data-type="content-ref"></th><th data-hidden data-card-cover data-type="files"></th></tr></thead><tbody><tr><td><ol><li><a href="broken-reference"><strong>System</strong></a> <strong>🖥️</strong></li></ol></td><td>Prepare the hardware and set up the operating system</td><td align="center"></td><td><a href="index-1/operating-system.md">operating-system.md</a></td><td><a href="index-1/remote-access.md">remote-access.md</a></td><td></td><td><a href="system/">system</a></td><td><a href=".gitbook/assets/operating-system.gif">operating-system.gif</a></td></tr><tr><td><ol start="2"><li><a href="broken-reference"><strong>₿itcoin</strong></a> <strong>🟠</strong></li></ol></td><td>Sync your own Bitcoin full node, Electrum server, Blockchain Explorer, and connect a desktop wallet to the Electrum server</td><td align="center"></td><td><a href="bitcoin/bitcoin/electrum-server.md">electrum-server.md</a></td><td><a href="bitcoin/bitcoin/blockchain-explorer.md">blockchain-explorer.md</a></td><td></td><td><a href="bitcoin/bitcoin/">bitcoin</a></td><td><a href=".gitbook/assets/core_logo.png">core_logo.png</a></td></tr><tr><td><ol start="3"><li><a href="broken-reference"><strong>Lightning</strong></a> <strong>⚡</strong></li></ol></td><td>Run your Lightning client with web-based node management, connect a mobile app, and save safely your SCB backup</td><td align="center"></td><td><a href="lightning/channel-backup.md">channel-backup.md</a></td><td><a href="lightning/web-app.md">web-app.md</a></td><td></td><td><a href="lightning/">lightning</a></td><td><a href="images/lightning-network-daemon-logo.png">lightning-network-daemon-logo.png</a></td></tr><tr><td>➕ <a href="broken-reference"><strong>Bonus guide</strong></a></td><td>The bonus section contains more specific guides that build on top of the main section. More fun, lots of knowledge, but with lesser maintenance guarantees. Everything is optional.</td><td align="center"></td><td><a href="bonus/system/">system</a></td><td><a href="bonus/bitcoin/">bitcoin</a></td><td><a href="bonus-guides/nostr/">nostr</a></td><td><a href="broken-reference">Broken link</a></td><td><a href=".gitbook/assets/bonus-logo.png">bonus-logo.png</a></td></tr></tbody></table>

## How to build

* **YouTube list** building MiniBolt in live with Albercoin of [Laboratorio Virtual Bitcoin](https://www.youtube.com/@LaboratorioVirtualBitcoin) (Spanish).

{% embed url="https://youtube.com/playlist?list=PL7-Q40ihLbmP9vXZGdQgEozQnFISzT8ms" %}

## Community

<table data-card-size="large" data-view="cards" data-full-width="false"><thead><tr><th align="center"></th><th></th><th></th></tr></thead><tbody><tr><td align="center">👥 <strong>RRSS</strong> 👥</td><td></td><td><ul><li>Reddit sub: <a href="https://www.reddit.com/r/minibolt/">r/minibolt</a></li><li><a href="https://w3.do/twofaktor@twofaktor-github-io/minibolt_community">Nostr community</a></li><li><p>Telegram Groups:</p><ul><li><a href="https://t.me/minibolt">English</a></li><li><a href="https://t.me/minibolt_es">Spanish</a></li></ul></li><li><p>Telegram Channels (News):</p><ul><li><a href="https://t.me/minibolt_news">English</a></li><li><a href="https://t.me/minibolt_es_noticias">Spanish</a></li></ul></li><li><p>Nostr channels:</p><ul><li><a href="https://www.nostrchat.io/channel/aa64f2ead929ce8417f85bde7d22ebde13cc01ceb4e00145572437eb1ad46249">English</a></li><li><a href="https://www.nostrchat.io/channel/3bd633eaad12242572bfc5ba10d3e52b2c0e152f4207383858993c373d314015">Spanish</a></li></ul></li></ul></td></tr><tr><td align="center"><strong>🛠️</strong> <a href="https://github.com/minibolt-guide/minibolt"><strong>GitHub</strong></a> 🛠️</td><td></td><td><ul><li><a href="https://github.com/minibolt-guide/minibolt/pulls">Pull requests</a></li><li><a href="https://github.com/minibolt-guide/minibolt/issues">Issues / Knowledge base</a></li><li><a href="https://github.com/orgs/minibolt-guide/discussions">Discussions</a></li></ul></td></tr></tbody></table>

{% hint style="info" %}
Feel free to join the many other contributors if you see something that can be improved!
{% endhint %}

## Resources

<table data-view="cards"><thead><tr><th></th><th data-hidden data-card-cover data-type="files"></th><th data-hidden data-card-target data-type="content-ref"></th></tr></thead><tbody><tr><td>🗺️ <a href="https://bit.ly/minibolt-ramix_netmap"><strong>Network map</strong></a></td><td><a href=".gitbook/assets/networkmap_icon.png">networkmap_icon.png</a></td><td><a href="https://bit.ly/minibolt-ramix_netmap">https://bit.ly/minibolt-ramix_netmap</a></td></tr><tr><td><strong>🛣️</strong> <a href="https://github.com/orgs/minibolt-guide/projects/1"><strong>Roadmap</strong></a></td><td><a href=".gitbook/assets/roadmap_icon.png">roadmap_icon.png</a></td><td><a href="https://github.com/orgs/minibolt-guide/projects/1">https://github.com/orgs/minibolt-guide/projects/1</a></td></tr><tr><td>📋 <a href="https://www.reddit.com/r/minibolt/comments/zmrtdk/minibolt_resources_list_of_the_minibolt_corebonus/"><strong>Guides list</strong></a></td><td><a href=".gitbook/assets/list.png">list.png</a></td><td><a href="https://www.reddit.com/r/minibolt/comments/zmrtdk/minibolt_resources_list_of_the_minibolt_corebonus/">https://www.reddit.com/r/minibolt/comments/zmrtdk/minibolt_resources_list_of_the_minibolt_corebonus/</a></td></tr></tbody></table>

## Free services

{% tabs %}
{% tab title="Nostr relay" %}
{% hint style="info" %}
Use a Nostr client to connect
{% endhint %}

<pre class="language-url"><code class="lang-url"><strong>wss://relay.minibolt.info
</strong></code></pre>
{% endtab %}

{% tab title="Electrum server" %}
{% hint style="info" %}
Use a signing app ([Sparrow Wallet](bitcoin/bitcoin/desktop-signing-app-sparrow.md) or [Electrum Wallet desktop](bonus/bitcoin/electrum-wallet-desktop.md)) to connect
{% endhint %}

Fulcrum - mainnet (🧅onion):

```url
tcp://vr4bgiwqlhuweftttc6bj7lm5ijjyafwsr43nmeiu3k4mcgtl4tpozyd.onion:50001
```

Fulcrum - testnet4 (🧅onion):

```url
tcp://bnfpvanrc2g7r5o5kaabbbyjv6ddh46jmasfatrvbbsvjb7cdik5n7ad.onion:40001
```

```url
ssl://bnfpvanrc2g7r5o5kaabbbyjv6ddh46jmasfatrvbbsvjb7cdik5n7ad.onion:40002
```
{% endtab %}

{% tab title="Explorer" %}
BTC RPC Explorer - **mainnet** (🚾clearnet):

&#x20;-> CLICK to access -> [https://explorer.minibolt.info](https://explorer.minibolt.info) <-

BTC RPC Explorer - **mainnet** (🧅onion - Use [Tor browser](https://www.torproject.org/es/download/)):

```url
http://rzcj4r2p6wterkto5prigsplq6iva5bqhcxr7y3d6w4hoc3uwizpp5qd.onion
```
{% endtab %}

{% tab title="Lightning Watchtower (only LND)" %}
{% hint style="info" %}
Use `lncli` to connect to it:

{% code overflow="wrap" %}
```bash
lncli wtclient add 02ad47b4e41cfce258e2db8d7eb9a194570ca29beba2897970d1ecc7d1c9a2726b@zm32w2qs2lf6xljnvqnmv6o2xlufsf4g6vfjihyydg4yhxph4fnqcvyd.onion:9911
```
{% endcode %}
{% endhint %}

Lightning Watchtower server - **mainnet** (🧅onion):

{% code overflow="wrap" %}
```url
02ad47b4e41cfce258e2db8d7eb9a194570ca29beba2897970d1ecc7d1c9a2726b@zm32w2qs2lf6xljnvqnmv6o2xlufsf4g6vfjihyydg4yhxph4fnqcvyd.onion:9911
```
{% endcode %}
{% endtab %}
{% endtabs %}

## Rating

All guides are rated with labels to help you assess their difficulty and whether they are tested against the most recent version of the main guide.

* **Difficulty:** indicates how difficult the bonus guide is in terms of installation procedure or usage

{% hint style="success" %}
Difficulty: Easy
{% endhint %}

{% hint style="warning" %}
Difficulty: Medium
{% endhint %}

{% hint style="danger" %}
Difficulty: Hard
{% endhint %}

* **Cost:** indicates if the service used in the guide is free or paid

{% hint style="warning" %}
Cost: Paid service
{% endhint %}
