---
title: lnbalance script
parent: + Lightning
grand_parent: Bonus Section
nav_exclude: true
has_toc: false
---

# lnbalance

The following script was created by [RobClark56](https://github.com/robclark56) and helps to get a better system overview.

{% hint style="success" %}
Difficulty: Easy
{% endhint %}

{% hint style="warning" %}
Status: Not tested MiniBolt
{% endhint %}

![](../../images/60\_balance.png)

## Install the script

*   As user “admin”, download the script

    ```sh
    $ cd /tmp
    $ wget https://raw.githubusercontent.com/raspibolt/raspibolt/master/resources/lnbalance
    ```
*   You can investigate the content of the script to ensure that there is no malicious code in it. Once done press q to quit.

    ```sh
    $ less lnbalance
    > #!/bin/bash
    > # RaspiBolt channel balance display, by robclark56
    > [...]
    ```
*   Make the script executable (check by displaying the file name, it should have become green)

    ```sh
    $ chmod +x lnbalance
    $ ls -la
    ```
*   Move the file to the global binaries folder

    ```sh
    $ sudo mv lnbalance /usr/local/bin
    $ cd
    ```

### lnbalance in action

*   With the "admin" user, run `lnbalance`

    ```sh
    $ lnbalance
    > mainnet (sat)        |       Local|      Remote|Commitment Fees|
    > Wallet               |      122236|            |               |
    > Active Channels    12|      919850|      822047|           5655|
    > Inactive Channels   0|           0|           0|              0|
    > Total              12|     1042086|      822047|           5655|
    ```

### Uninstall

*   To uninstall `lnbalance`

    ```sh
    $ sudo rm /usr/local/bin/lnbalance
    $ cd
    ```
