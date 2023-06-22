---
title: LNTOP terminal dashboard
parent: + Lightning
grand_parent: Bonus Section
nav_exclude: true
has_toc: false
---

# LNTOP terminal dashboard

[lntop](https://github.com/edouardparis/lntop) is an interactive text-mode channels viewer for Unix systems.

{% hint style="success" %}
Difficulty: Easy
{% endhint %}

{% hint style="success" %}
Status: Tested MiniBolt
{% endhint %}

![](../../images/74\_lntop.png)

## Install lntop

*   Login as "admin" and change to a temporary directory which is cleared on reboot

    ```sh
    $ cd /tmp
    ```
*   Download the application

    ```sh
    $ wget https://github.com/edouardparis/lntop/releases/download/v0.4.0/lntop-v0.4.0_Linux_x86_64.tar.gz
    ```
*   Extract the package

    ```sh
    $ tar -xvf lntop-v0.4.0_Linux_x86_64.tar.gz
    ```
*   Install the application

    ```sh
    $ sudo install -m 0755 -o root -g root -t /usr/local/bin release-v0.4.0-Linux-x86_64/lntop
    ```
*   Check the correct installation

    ```sh
    $ lntop --version
    ```

**Example** of expected output:

```
> lntop version v0.4.0
```

### Run lntop

*   Depending on the size of your LND channel database, lntop can take quite a while to start.

    ```sh
    $ lntop
    ```

### lntop in action

To use all the functionalities of lntop, use the following keys:

* **F1 (or h)** = Display an "About" page and a list of keyboard keys to use (press F1 again to exit this screen)
* **F2 (or m)** = Display a Menu bar on the left
  1. Navigate the Menu with the up and down keys (see below); there are three options:
  2. CHANNEL = (the home page/default view), a table of all channels
  3. TRANSAC = a table of lightning transactions
  4. ROUTING = a table of routing event as they happen (no historical events shown, and any displayed event will be deleted if you quit lntop)
  5. Press Enter to see the desired view
  6. Press F2 to enter the desired view and exit the left Menu bar
* **Arrow keys: ←, →, ↑, ↓** =
  * _when the left Menu bar is active_ = Navigate the Menu options (up and down only)
  * _when the left Menu bar is inactive_ = Navigate the colmuns (left, right) and/or the lines (up, down) of the displayed table (CHANNEL, TRANSAC or ROUTING)
* **Home** = Navigate to the first line of the table
* **End** = Navigate to the last line of the table
* **Enter** =
  * _when the left Menu bar is active_: See the content of the desired Menu entry
  * _when the left Menu bar is inactive_: Displays additional information on a channel or transaction, depending on the table being viewed:
    * CHANNEL = Display detailed information about a channel
    * TRANSAC = Display detailed information about a transaction
    * ROUTING = Display detailed information about a forwarded payment
* **a** = Sort out column, ascending order
* **d** = Sort out column, descending order
* **F10 (or q or Ctrl+C)** = Quit lntop

## Update

*   With user "admin", check the version of lntop that is installed on your node

    ```sh
    $ lntop --version
    ```

**Example** of expected output:

```
> lntop version v0.4.0
```

* Check the lntop repository for [new releases](https://github.com/edouardparis/lntop/releases).
* Follow the [installation guidelines](lntop.md#install-lntop) while making sure to replace the file names to match the latest version if necessary.

## Uninstall

*   To remove lntop, simply delete the installed binary

    ```sh
    $ sudo rm /usr/local/bin/lntop
    ```
