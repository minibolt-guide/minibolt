---
layout: default
title: LNTOP terminal dashboard
parent: + Lightning
grand_parent: Bonus Section
nav_exclude: true
has_toc: false
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->

# Bonus guide: LNTOP terminal dashboard

{: .no_toc }

---

[lntop](https://github.com/edouardparis/lntop){:target="_blank"} is an interactive text-mode channels viewer for Unix systems.

Difficulty: Easy
{: .label .label-green }

Status: Not tested MiniBolt
{: .label .label-red }

![lntop](../../../images/74_lntop.png)

---

## Table of contents
{: .text-delta }

1. TOC
{:toc}

---

## Install lntop

* As user “admin”, download the application

  ```sh
  $ cd /tmp/
  $ wget https://github.com/edouardparis/lntop/releases/download/v0.1.0/lntop_Linux_x86_64.tar.gz
  ```

* Install the application

  ```sh
  $ tar -xvf lntop_Linux_x86_64.tar.gz
  $ sudo install -m 0755 -o root -g root -t /usr/local/bin ./lntop
  ```

* Check the correct installation

  ```sh
  $ lntop --version
  > lntop version v0.1.0
  ```

---

### Run lntop

* Depending on the size of your LND channel database, lntop can take quite a while to start.

  ```sh
  $ lntop
  ```

---

### lntop in action

To use all the functionalities of lntop, use the following keys:

* **F1 (or h)** = Display an "About" page and a list of keyboard keys to use (press F1 again to exit this screen)

* **F2 (or m)** = Display a Menu bar on the left
  1. Navigate the Menu with the up and down keys (see below); there are three options:
  * CHANNEL = (the home page/default view), a table of all channels
  * TRANSAC = a table of lightning transactions
  * ROUTING = a table of routing event as they happen (no historical events shown, and any displayed event will be deleted if you quit lntop)
  1. Press Enter to see the desired view
  1. Press F2 to enter the desired view and exit the left Menu bar

* **Arrow keys: ←, →, ↑, ↓** =
  * *when the left Menu bar is active* = Navigate the Menu options (up and down only)
  * *when the left Menu bar is inactive* = Navigate the colmuns (left, right) and/or the lines (up, down) of the displayed table (CHANNEL, TRANSAC or ROUTING)

* **Home** = Navigate to the first line of the table

* **End** = Navigate to the last line of the table

* **Enter** =
  * *when the left Menu bar is active*: See the content of the desired Menu entry
  * *when the left Menu bar is inactive*: Displays additional information on a channel or transaction, depending on the table being viewed:
    * CHANNEL = Display detailed information about a channel
    * TRANSAC = Display detailed information about a transaction
    * ROUTING = Display detailed information about a forwarded payment

* **a** = Sort out column, ascending order

* **d** = Sort out column, descending order

* **F10 (or q or Ctrl+C)** = Quit lntop

---

## Update

* With user "admin", check the version of lntop that is installed on your node

  ```sh
  $ lntop --version
  > lntop version v...
  ```
  
* Check the lntop repository for [new releases](https://github.com/edouardparis/lntop/releases){:target="_blank"}.

* Follow the [installation guidelines](#install-lntop) while making sure to replace the file names to match the latest version if necessary.

---

## Uninstall

* To remove lntop, simply delete the installed binary

  ```sh
  $ cd /usr/local/bin
  $ rm -r lntop
  ```

<br /><br />

---

<< Back: [+ Lightning](index.md)
