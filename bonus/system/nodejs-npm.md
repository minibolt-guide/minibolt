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

### Install Node.js + NPM

* With user `admin`, update the packages and upgrade to keep up to date with the OS and press "**y**" and enter when needed

```bash
$ sudo apt update && sudo apt full-upgrade
```

* Download and import the Nodesource GPG key

{% code overflow="wrap" %}
```sh
$ curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
```
{% endcode %}

* Set the environment variable of the version

```bash
$ VERSION=18
```

* Create deb repository

{% code overflow="wrap" %}
```bash
$ echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$VERSION.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
```
{% endcode %}

* Run update

```sh
$ sudo apt update
```

* Install Node.js using the apt package manager and press "**y**" and enter when needed

```sh
$ sudo apt install nodejs
```

* Check the correct installation of nodejs

```sh
$ node -v
```

**Example** of expected output:

```
> v18.16.0
```

* Check the correct installation of NPM

```sh
$ npm -v
```

**Example** of expected output:

```
> 9.5.1
```

## For the future: upgrade Node + NPM

* To upgrade simply type this command

```sh
$ sudo apt update && sudo apt full-upgrade
```

### Uninstall

* To uninstall type this command and press "**y**" and enter when needed

{% code overflow="wrap" %}
```sh
$ sudo apt purge nodejs && sudo rm -r /etc/apt/sources.list.d/nodesource.list && sudo rm -r /etc/apt/keyrings/nodesource.gpg
```
{% endcode %}
