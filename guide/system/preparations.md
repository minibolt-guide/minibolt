---
layout: default
title: Preparations
nav_order: 10
parent: System
---
<!-- markdownlint-disable MD014 MD022 MD025 MD040 -->

{% include include_metatags.md %}

# Preparations

{: .no_toc }

---

Let's get all the necessary hardware parts and prepare some passwords.

Status: Tested MiniBolt
{: .label .label-blue }

---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Personal computer

This guide builds on the readily available personal computer.

While a personal computer is the best choice for most, this guide also works with other computing platforms, clouds servers, or virtual machines that run Debian.
It only uses standard Debian instructions.

## Hardware requirements

You need the following hardware:

* Personal Computer with Intel/AMD processor, with 2+ GB RAM, a 4+ GB RAM is recommended
* Internal storage: 1+ TB, a SSD is recommended
* Pen drive 4+ GB
* Temporary monitor screen or television
* Temporary keyboard USB/PS2

The complete Bitcoin blockchain must be stored locally to run a Lightning node, currently about 430 GB and growing.

You might also want to get this optional hardware:

* UPS (uninterruptible power supply)

---

## Write down your passwords

You will need several passwords, and it's easiest to write them all down in the beginning, instead of bumping into them throughout the guide.
They should be unique and very secure, at least 12 characters in length. Do **not use uncommon special characters**, spaces, or quotes (‘ or “).

```sh
[ A ] Master user password
[ B ] Bitcoin RPC password
[ C ] LND wallet password
[ D ] BTC-RPC-Explorer password (optional)
[ E ] Ride The Lightning password
```

![xkcd: Password Strength](../../images/preparations_xkcd.png)

If you need inspiration for creating your passwords: the [xkcd: Password Strength](https://xkcd.com/936/){:target="_blank"} comic is funny and contains a lot of truth.
Store a copy of your passwords somewhere safe (preferably in an open-source password manager like [KeePassXC](https://keepassxc.org/){:target="_blank"}), or whaterver password manager you're already using, and keep your original notes out of sight once your system is up and running.

---

## Secure your home network and devices

While the guide will show you how to secure your node, you will interact with it from your computer and mobile phone and using your home internet network. Before building your MiniBolt, it is recommended to secure your home network and devices.

* Follow Part 1 and 2 of this ["How to Secure Your Home Network Against Threats"](https://restoreprivacy.com/secure-home-network/){:target="_blank"} tutorial by Heinrich Long, and try to implement as many points as possible (some might not apply to your router/device).

<br /><br />

---

Next: [Operating system >>](operating-system.md)
