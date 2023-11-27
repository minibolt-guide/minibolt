---
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

# 1.1 Preparations

Let's get all the necessary hardware parts and prepare some passwords.

<figure><img src="../.gitbook/assets/preparations.jpg" alt="" width="375"><figcaption></figcaption></figure>

## Personal computer

This guide builds on the readily available personal computer.

While a personal computer is the best choice for most, this guide also works with other computing platforms, cloud servers, or virtual machines that run Debian. It only uses standard Debian instructions.

## Hardware requirements

You need the following hardware:

* Personal Computer with Intel/AMD processor (2010+ gen), with 2+ GB RAM (only Bitcoin), a 4+ GB RAM is recommended (Bitcoin + Lightning + bonus)
* Internal storage: 1+ TB, an SSD is recommended
* Pen drive: 4+ GB
* Temporary monitor screen or television
* Temporary keyboard USB/PS2

You might also want to get this optional hardware:

* UPS (uninterruptible power supply)

## Write down your passwords

You will need several passwords, and it's easiest to write them all down in the beginning, instead of bumping into them throughout the guide. They should be unique and very secure, at least 12 characters in length. Do **not use uncommon special characters**, spaces, or quotes (‘ or “).

```
[ A ] Master user password
[ B ] Bitcoin RPC password
[ C ] LND wallet password
[ D ] BTC-RPC-Explorer password (optional)
[ E ] ThunderHub password
```

![](../images/preparations\_xkcd.png)

If you need inspiration for creating your passwords: the [xkcd: Password Strength](https://xkcd.com/936/) comic is funny and contains a lot of truth. Store a copy of your passwords somewhere safe (preferably in an open-source password manager like [KeePassXC](https://keepassxc.org/)), or whatever password manager you're already using, and keep your original notes out of sight once your system is up and running.

## Secure your home network and devices

While the guide will show you how to secure your node, you will interact with it from your computer and mobile phone and use your home internet network. Before building your MiniBolt, it is recommended to secure your home network and devices. Follow Parts 1 and 2 of this ["How to Secure Your Home Network Against Threats"](https://restoreprivacy.com/secure-home-network/) tutorial by Heinrich Long, and try to implement as many points as possible (some might not apply to your router/device).
