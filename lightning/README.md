---
title: Lightning
nav_order: 40
has_children: true
layout:
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
---

# 3. Lightning

<figure><img src="../.gitbook/assets/lightning.jpg" alt="" width="375"><figcaption></figcaption></figure>

Now you're all set up for Bitcoin. But Bitcoin is not primarily designed for fast and cheap payments. The blockchain that records all transactions cannot grow without limit if we want to keep the whole system decentralized and nodes like this RaspiBolt feasible.

Building on top of the Bitcoin base layer, the Lightning Network enables instant and cheap everyday payments. Your coffee purchase doesn't necessarily need to be validated and recorded by all Bitcoin nodes worldwide if you think about it.

Check out [Understanding the Lightning Network](https://bitcoinmagazine.com/technical/understanding-the-lightning-network-part-building-a-bidirectional-payment-channel-1464710791) from Bitcoin Magazine to learn more about how it works.

To enable the Lightning Network on your MiniBolt, we install LND, the "Lightning Network Daemon". We then set up an automatic Static Channel Backup to protect ourselves in case of failure of the SSD drives. We'll then add "ThunderHub", a web-based node management tool. Finally, we'll install the Zeus mobile app to make on-chain and LN payments and manage our node while we're on the go. Together, they make operating your node a breeze.
