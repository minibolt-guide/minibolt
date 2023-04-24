---
layout: default
title: Install / Update / Uninstall Node.js + NPM
parent: + System
grand_parent: Bonus Section
nav_exclude: true
has_toc: false
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->

## Install / Update / Uninstall Node.js + NPM

{: .no_toc }

Node.js [https://nodejs.org] is an open-source, cross-platform JavaScript runtime environment.

Difficulty: Easy
{: .label .label-green }

Status: Tested MiniBolt
{: .label .label-blue }

![nodejs](../../../images/nodejs-logo.png)

---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Install Node.js + NPM

* With user "admin", set the environment variable

  ```sh
  $ VERSION=18
  ```

* Add the [Node.js](https://nodejs.org){:target="_blank"} package repository

  ```sh
  $ curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  ```

* Install Node.js using the apt package manager

  ```sh
  $ sudo apt install nodejs
  ```

<br /><br />

---

<< Back: [+ System](index.md)
