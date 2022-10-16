---
layout: default
title: System overview
parent: + System
grand_parent: Bonus Section
nav_exclude: true
has_toc: false
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->

# Bonus guide: System overview

{: .no_toc }

---

To get a quick overview of the system status, you can use [a shell script](https://github.com/raspibolt/raspibolt/blob/master/resources/20-raspibolt-welcome){:target="_blank"} that gathers the most relevant data.
You can configure it to be shown on each login.

Status: Tested RaspiBolt v3
{: .label .label-green }

Status: Not tested MiniBolt
{: .label .label-red }

![MotD system overview](../../../images/system-overview.png)

---

## Table of contents
{: .text-delta }

1. TOC
{:toc}

---

## Installation

This script can be run by user "admin" without root privileges, but you should still check it yourself.

* Install necessary software packages

  ```sh
  $ sudo apt install jq net-tools netcat
  ```

* Enter `tmp` folder and download the script

  ```sh
  $ cd /tmp/
  $ wget https://raw.githubusercontent.com/raspibolt/raspibolt/master/resources/20-raspibolt-welcome
  ```

* Inspect the script to make sure it does not do bad things.
  Exit with `Ctrl`-`X`

  ```sh
  $ nano 20-raspibolt-welcome --linenumbers
  ```

* If you use a network cable instead of a wifi connection, go to line 19 and change `wlan0` to `eth0`.
  Save with `Ctrl`-`O`and exit `nano` with `Ctrl`-`X`.

  ```sh
  # set to network device name (usually "eth0" for ethernet, and "wlan0" for wifi)
  network_name="eth0"
  ```

* Install the script and make it executable

  ```sh
  $ sudo mv 20-raspibolt-welcome /usr/local/bin/raspibolt
  $ sudo chmod +x /usr/local/bin/raspibolt
  ```

* You can now run the script with user "admin"

  ```sh
  $ raspibolt
  ```

---

## Show on login (optional)

You can run the welcome script automatically every time you log in.
If you're in a hurry, you can always press `Ctrl`-`C` to skip the script.

* As user "admin", add the `raspibolt` command to the end of your `.bashrc` file

  ```sh
  $ echo "raspibolt" >> ~/.bashrc
  ```

In case you are upgrading from a previous version of the script, you need to disable the old script to avoid seeing both on startup.
In earlier versions, the script was executed by the "Message of the day" mechanism.

* To get rid of all MOTD output, simply rename the following directory:

  ```sh
  $ sudo mv /etc/update-motd.d /etc/update-motd.d.backup
  ```

<br /><br />

---

<< Back: [+ System](index.md)
