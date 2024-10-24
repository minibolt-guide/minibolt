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

<figure><img src="../.gitbook/assets/Starting_MiniBolt.gif" alt=""><figcaption></figcaption></figure>

## Personal computer

This guide builds on the readily available personal computer.

While a personal computer is the best choice, this guide works with other computing platforms, cloud servers, or virtual machines.

## Hardware requirements

You need the following hardware:

* CPU Intel/AMD processor (2010+ gen)
* 2+ GB RAM (only Bitcoin), 4+ GB RAM is recommended (Bitcoin + Lightning + bonus)
* Internal storage: SSD 2+ TB is recommended
* Pen drive USB/SD drive: 4+ GB
* Temporary monitor screen or TV
* Temporary keyboard USB/PS2

You might also want to get this optional hardware:

* UPS (uninterruptible power supply)
* A small USB thumb drive or microSD card to create regular local backups of your Lightning channels

## Write down your passwords

You will need several passwords, and it's easiest to write them all down in the beginning, instead of bumping into them throughout the guide. They should be unique and secure, at least 12 characters. Do **not use uncommon special characters**, spaces, or quotes (‘ or “).

```
[ A ] Master admin user password
[ B ] Bitcoin RPC password
[ C ] LND wallet password
[ D ] BTC-RPC-Explorer password (optional)
[ E ] ThunderHub password
[ F ] i2pd webconsole password (optional)
```

![](../.gitbook/assets/password\_strength.png)

If you need inspiration for creating your passwords: the [xkcd: Password Strength](https://xkcd.com/936/) comic is funny and contains a lot of truth. Store a copy of your passwords somewhere safe (preferably in an open-source password manager like [KeePassXC](https://keepassxc.org/)), or whatever password manager you're already using, and keep your original notes out of sight once your system is up and running.

## Secure your home network and devices

While the guide will show you how to secure your node, you will interact with it from your computer and mobile phone and use your home internet network. Before building your MiniBolt, it is recommended to secure your home network and devices. Follow Parts 1 and 2 of this ["How to Secure Your Home Network Against Threats"](https://restoreprivacy.com/secure-home-network/) tutorial by Heinrich Long, and try to implement as many points as possible (some might not apply to your router/device).
