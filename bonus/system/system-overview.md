---
title: System overview
parent: + System
grand_parent: Bonus Section
nav_exclude: true
has_toc: false
---

# System overview

To get a quick overview of the system status, you can use [a shell script](https://github.com/raspibolt/raspibolt/blob/master/resources/20-raspibolt-welcome) that gathers the most relevant data. You can configure it to be shown on each login.

{% hint style="warning" %}
Status: Not tested MiniBolt
{% endhint %}

![](../../images/system-overview.png)

## Installation

This script can be run by the user "admin" without root privileges, but you should still check it yourself.

*   Install necessary software packages

    ```sh
    $ sudo apt install jq net-tools netcat
    ```
*   Enter `tmp` folder and download the script

    ```sh
    $ cd /tmp/
    $ wget https://raw.githubusercontent.com/minibolt-guide/minibolt/main/resources/20-raspibolt-welcome
    ```
*   Inspect the script to make sure it does not do bad things. Exit with `Ctrl`-`X`

    ```sh
    $ nano 20-raspibolt-welcome --linenumbers
    ```
*   Show your network device name typing `tcpdump --list-interfaces` go to line 19 and change `wlan0` to the correct one name interface that you show "\[Up, Running, Connected]". Save with `Ctrl`-`O`and exit `nano` with `Ctrl`-`X`.

    ```sh
    # set to network device name (usually "eth0" for ethernet, and "wlan0" for wifi)
    network_name="eth0"
    ```
*   Install the script and make it executable

    ```sh
    $ sudo mv 20-raspibolt-welcome /usr/local/bin/raspibolt
    $ sudo chmod +x /usr/local/bin/raspibolt
    ```
*   You can now run the script with the user "admin"

    ```sh
    $ raspibolt
    ```

## Show on login (optional)

You can run the welcome script automatically every time you log in. If you're in a hurry, you can always press `Ctrl`-`C` to skip the script.

*   As user "admin", add the `raspibolt` command to the end of your `.bashrc` file

    ```sh
    $ echo "raspibolt" >> ~/.bashrc
    ```

In case you are upgrading from a previous version of the script, you need to disable the old script to avoid seeing both on startup. In earlier versions, the script was executed by the "Message of the day" mechanism.

*   To get rid of all MOTD output, simply rename the following directory:

    ```sh
    $ sudo mv /etc/update-motd.d /etc/update-motd.d.backup
    ```
