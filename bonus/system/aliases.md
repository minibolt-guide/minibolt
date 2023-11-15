---
title: Aliases
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

# Aliases

Aliases are shortcuts for commands that can save time and make it easier to execute common and frequent commands. The following aliases do not display information in a fancy way, but they make it easier to execute commands.

{% hint style="success" %}
Difficulty: Easy
{% endhint %}

![](../../images/aliases-demo.PNG)

## Introduction

The following list of aliases was derived from contributions by [RobClark56](https://github.com/robclark56) and [2FakTor](https://github.com/twofaktor).

## Configuration

* With user `admin`, ensure you are on `home` folder and download the aliases list provided for a MiniBolt environment

{% code overflow="wrap" %}
```bash
$ cd /home/admin
```
{% endcode %}

{% code overflow="wrap" %}
```bash
$ wget https://raw.githubusercontent.com/minibolt-guide/minibolt/main/resources/.bash_aliases -O .bash_aliases
```
{% endcode %}

If you want, inspect the list of aliases to make sure it does not do bad things, and modify it with your personal aliases if you want. Exit with Ctrl-X

```sh
$ nano .bash_aliases
```

* Execute a `source` command to register changes of the `.bash_aliases` file in the `.bashrc` file

```sh
$ source /home/admin/.bashrc
```

## Run

* Simply type "alias" to display all available aliases

```sh
[...]
alias enableallmain='sudo systemctl enable bitcoind electrs btcrpcexplorer lnd rtl scb-backup'
alias enablebitcoind='sudo systemctl enable bitcoind'
alias enablebtcrpcexplorer='sudo systemctl enable btcrpcexplorer'
alias enablecircuitbreaker='sudo systemctl enable circuitbreaker'
alias enablecln='sudo systemctl enable cln'
alias enablefulcrum='sudo systemctl enable fulcrum'
[...]
```

* Test some of the aliases to see if it has been installed properly

```sh
$ showmainversion
```

<details>

<summary>Example of expected output ⬇️</summary>

```
> The installed versions of the services are as follows:
> Bitcoin Core version v23.0.0
> lnd version 0.15.3-beta commit=v0.15.3-beta
> BTC RPC Explorer: "version": "3.3.0",
> Electrs: v0.9.9
> RTL: "version": "0.12.3",
> Tor version 0.4.7.10.
> NPM: v8.15.0
> NodeJS: v16.17.1
> htop 3.0.5
> nginx version: nginx/1.18.0 (Ubuntu)
```

</details>

## Upgrade

Follow again the [Set up Aliases](aliases.md#set-up-aliases) section again to overwrite aliases.

{% hint style="info" %}
You can see if the aliases have a recent update by entering [here](https://github.com/minibolt-guide/minibolt/commits/main/resources/.bash\_aliases)
{% endhint %}

## Uninstall

* To remove these special aliases, with the user `admin`, simply deletes the `.bash_aliases` and executes a source command to register changes. The aliases will be gone with the next login

```sh
$ rm ~/.bash_aliases
```

* Execute a source command to register changes to the `.bashrc` file

```sh
$ source /home/admin/.bashrc
```
