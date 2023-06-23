---
title: BitBoxApp
parent: + Bitcoin
grand_parent: Bonus Section
nav_exclude: true
has_children: false
has_toc: false
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

# BitBoxApp

The [BitBoxApp](https://shiftcrypto.ch/app/) is a beginner-friendly companion app to the BitBox02 hardware wallet by Shift Crypto.

{% hint style="success" %}
Difficulty: Easy
{% endhint %}

{% hint style="warning" %}
Status: Not tested MiniBolt
{% endhint %}

![](../../images/electrum\_BitBoxApp.png)

## Connect BitBoxApp

### General

On your regular computer, configure the BitBoxApp to use your MiniBolt:

* In the sidebar, select `Settings` > `Connect your own full node`
* In the field "Enter the endpoint" enter the hostname or IP address and the port, e.g. `minibolt.local:50002`
* Click on "Download remote certificate"
* Click "Check", and you should be prompted with the message "Successfully established a connection"
* Click "Add" to add your server to the list at the top
* Remove the Shift servers to only connect to your own server

### Tor

If you have Tor installed on your computer, you can access your MiniBolt remotely over Tor.

* In the sidebar, select `Settings` > `Enable tor proxy`
* Enable it and confirm the proxy address (usually the default `127.0.0.1:9050`)
* When adding your RaspiBolt full node as described above, use your Tor address (e.g. `gwdllz5g7vky2q4gr45zGuvopjzf33czreca3a3exosftx72ekppkuqd.onion:50002`)
