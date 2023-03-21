---
layout: default
title: Install / Update / Uninstall Go
parent: + System
grand_parent: Bonus Section
nav_exclude: true
has_toc: false
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->

## Install / Update / Uninstall Go
{: .no_toc }

Difficulty: Easy
{: .label .label-green }

Status: Tested MiniBolt
{: .label .label-blue }

![go](../../../images/go.png)

---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Install Go

* Enter to the "tmp" folder and download the binary

  ```sh
  $ cd /tmp
  $ wget https://go.dev/dl/go1.19.3.linux-amd64.tar.gz
  ```

* Check on the download page what is the SHA256 checksum of the file, e.g. for the above: 74b9640724fd4e6bb0ed2a1bc44ae813a03f1e72a4c76253e2d5c015494430ba. Calculate the SHA256 hash of the downloaded file. It should give an "OK" as an output.

  ```sh
  $ echo "74b9640724fd4e6bb0ed2a1bc44ae813a03f1e72a4c76253e2d5c015494430ba  go1.19.3.linux-amd64.tar.gz" | sha256sum --check
  > go1.19.3.linux-amd64.tar.gz: OK
  ```

* Install Go in the `/usr/local` directory.

  ```sh
  $ sudo tar -xvf go1.19.3.linux-amd64.tar.gz -C /usr/local
  $ rm go1.19.3.linux-amd64.tar.gz
  ```

* Add the binary to `PATH` to not have to type the full path each time you use it. For a global installation of Go (that users other than “admin” can use), open /etc/profile.

  ```sh
  $ sudo nano /etc/profile
  ```

* Add the following line at the end of the file, save and exit.

  ```ini
  export PATH=$PATH:/usr/local/go/bin
  ```

* To make the changes effective immediately (and not wait for the next login), execute them from the profile using the following command.

  ```sh
  $ source /etc/profile
  ```

* Test that Go has been properly installed by checking its version.

  ```sh
  $ go version
  > go version go1.19.3 linux/amd64
  ```

## Update Go

* Check the currently installed version of GO.

  ```sh
  $ go version
  > go version go1.19.3 linux/amd64
  ```

* Check for the most recent version of Go on their site [Downloads](https://go.dev/dl/) section.

* Remove the current installation.

  ```sh
  sudo rm -rvf /usr/local/go/
  ```

* Download, verify and install the latest Go binaries as described in the [Install Go](go.md#install-go) section of this guide.

## Remove Go

* Remove the current installation.

  ```sh
  sudo rm -rvf /usr/local/go/
  ```

<br /><br />

---

<< Back: [+ System](index.md)
