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

* With user `admin`, set the environment variable

```sh
$ VERSION=18
```

* Update the packages and upgrade to keep up to date with the OS

```bash
$ sudo apt update && sudo apt full-upgrade
```

* Add the Node.js package repository

```sh
$ curl -fsSL https://deb.nodesource.com/setup_$VERSION.x | sudo -E bash -
```

* Install Node.js using the apt package manager

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

*   Check the correct installation of NPM

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
$ sudo apt update && sudo apt upgrade
```

### Uninstall

* To uninstall type this command

```sh
$ Sudo apt purge nodejs && rm -r /etc/apt/sources.list.d/nodesource.list
```
