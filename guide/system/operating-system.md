---
layout: default
title: Operating system
nav_order: 20
parent: System
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->

{% include include_metatags.md %}

# Operating system

{: .no_toc }

---

We configure the PC and install the Linux operating system.

---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Which operating system to use?

We use Ubuntu Server Operating System, without a graphical user interface, and in the 64-bit version.
This provides the best stability for the Raspberry Pi and makes the initial setup a breeze.

Ubuntu Server is based on the [Debian 11](https://www.debian.org/){:target="_blank"} Linux distribution, which is available for most  hardware platforms.
To make this guide as universal as possible, it uses only standard Debian commands.
As a result, it should work smoothly with a personal computer while still being compatible with most other hardware platforms running Debian.

## Get Ubuntu Server

In order to write the operating system to the external drive, we will use the [Raspberry Pi Imager](https://www.raspberrypi.com/software/){:target="_blank"} application v1.7+.

* Download Ubuntu Server doing click [here](https://softlibre.unizar.es/ubuntu/releases/22.04.1/ubuntu-22.04.1-live-server-amd64.iso)
* Start the Raspberry Pi Imager
* Select "Use custom" > Select Ubuntu Server .iso previously downloaded

## Write the operating system to the pen drive

* Connect pendrive to your regular computer
* Click on "CHOOSE STORAGE"
* Select your Pen Drive
* Click on "WRITE"
* Read the warning carefully and make sure you selected the right drive, then click "YES"

The Raspberry Pi Imager now writes the operating system to your drive and verifies it.
It should display a "Success" message after.

## Start your PC

* Safely eject the Pen Drive from your computer
* Connect it to your Personal Computer
* Start the PC and select pen drive as boot device

<br /><br />

---

Next: [Remote access >>](remote-access.md)
