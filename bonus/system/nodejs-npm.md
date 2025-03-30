---
title: Install / Update / Uninstall Node.js + NPM
parent: + System
grand_parent: Bonus Section
nav_exclude: true
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

# Node + NPM

[Node.js](https://nodejs.org) is an open-source, cross-platform JavaScript runtime environment. Node.js includes NPM in the installation package as well.

{% hint style="success" %}
Difficulty: Easy
{% endhint %}

![](../../images/nodejs-logo.png) ![](../../images/npm-logo.png)

## Installation

* With user `admin`, update the packages and upgrade to keep up to date with the OS, press "**y**" and "**enter**" when needed

```bash
sudo apt update && sudo apt full-upgrade
```

* Change to a temporary directory that is cleared on reboot

```bash
cd /tmp
```

* Set the environment variable for the version

```bash
VERSION=22
```

* We will use the NodeSource Node.js Binary Distributions [repository](https://github.com/nodesource/distributions) instructions. Download the setup script

{% code overflow="wrap" %}
```sh
curl -fsSL https://deb.nodesource.com/setup_$VERSION.x -o nodesource_setup.sh
```
{% endcode %}

* Run the setup script

```bash
sudo -E bash nodesource_setup.sh
```

* Update the package manager and install Node.js + NPM. Press "**y**" and `enter` or directly `enter` if the prompt asks you

```sh
sudo apt update && sudo apt install nodejs
```

* Check the correct installation of Node.js

```sh
node -v
```

**Example** of expected output:

```
v18.16.0
```

* Check the correct installation of NPM

```sh
npm -v
```

**Example** of expected output:

```
9.5.1
```

* **(Optional)** Delete the setup script

```bash
rm nodesource_setup.sh
```

## Upgrade

* With user `admin`, stop the current dependencies services of the Node + NPM, that are actually BTC RPC Explorer + Thunderhub

```bash
sudo systemctl stop btcrpcexplorer && sudo systemctl stop thunderhub
```

* To upgrade, type this command

```sh
sudo apt update && sudo apt full-upgrade
```

* Check the correct installation of the latest release

```bash
node -v && npm -v
```

* Start BTC RPC Explorer & Thunderhub again

```bash
sudo systemctl start btcrpcexplorer && sudo systemctl start thunderhub
```

### Upgrade to major version

* With user `admin`, stop the current dependencies services of the Node + NPM, that are actually BTC RPC Explorer + Thunderhub

```bash
sudo systemctl stop btcrpcexplorer && sudo systemctl stop thunderhub
```

* Change to a temporary directory that is cleared on reboot

```bash
cd /tmp
```

* Set the environment variable for the version

```bash
VERSION=22
```

{% hint style="info" %}
Here is important that you change the environment variable to the immediately higher LTS version, for example: `20 > 22`
{% endhint %}

* We will use the NodeSource Node.js Binary Distributions [repository](https://github.com/nodesource/distributions) instructions. Download the setup script

{% code overflow="wrap" %}
```sh
curl -fsSL https://deb.nodesource.com/setup_$VERSION.x -o nodesource_setup.sh
```
{% endcode %}

* Run the setup script

```bash
sudo -E bash nodesource_setup.sh
```

* Update the package manager and install Node.js + NPM. Press "**y**" and `enter` or directly `enter` if the prompt asks you

```sh
sudo apt update && sudo apt install nodejs
```

* Check the correct installation of the latest release

```bash
node -v && npm -v
```

* Start BTC RPC Explorer & Thunderhub again

```bash
sudo systemctl start btcrpcexplorer && sudo systemctl start thunderhub
```

## Uninstall

* To uninstall, type this command and press "**y**" and "**enter**" when needed

{% code overflow="wrap" %}
```sh
sudo apt autoremove nodejs --purge && sudo rm /etc/apt/sources.list.d/nodesource.list
```
{% endcode %}
