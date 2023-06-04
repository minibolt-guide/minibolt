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

[Go]((https://go.dev)) is an open source programming language that makes it easy to build simple, reliable, and efficient software.

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

* With user "admin, enter the "tmp" folder and download the binary

  ```sh
  $ cd /tmp
  ```

* Set the environment variable

  ```sh
  $ VERSION=1.20.4
  ```

* Download the binary

  ```sh
  $ wget https://go.dev/dl/go$VERSION.linux-amd64.tar.gz
  ```

* Check on the download page what is the SHA256 checksum of the file, e.g. for the above: 698ef3243972a51ddb4028e4a1ac63dc6d60821bf18e59a807e051fee0a385bd. Calculate the SHA256 hash of the downloaded file. It should give an "OK" as an output.

  ```sh
  $ echo "698ef3243972a51ddb4028e4a1ac63dc6d60821bf18e59a807e051fee0a385bd go$VERSION.linux-amd64.tar.gz" | sha256sum --check
  ```

Expected output:

  ```
  > go$VERSION.linux-amd64.tar.gz: OK
  ```

* Extract the binary and install Go in the `/usr/local` directory.

  ```sh
  $ sudo tar -xvf go$VERSION.linux-amd64.tar.gz -C /usr/local
  ```

* Add the binary to `PATH` to not have to type the full path each time you use it. For a global installation of Go (that users other than “admin” can use), open /etc/profile.

  ```sh
  $ sudo nano /etc/profile
  ```

* Add the following line at the end of the file, save and exit.

  ```
  export PATH=$PATH:/usr/local/go/bin
  ```

* To make the changes effective immediately (and not wait for the next login), execute them from the profile using the following command.

  ```sh
  $ source /etc/profile
  ```

* Test that "Go" has been properly installed by checking its version.

  ```sh
  $ go version
  ```

Expected output:

  ```
  > go version go$VERSION linux/amd64
  ```

## Update Go

* Check the currently installed version of Go

  ```sh
  $ go version
  ```

Expected output:

  ```
  > go version go$VERSION linux/amd64
  ```

* Check for the most recent version of Go on their [GitHub releases page](https://github.com/golang/go/tags)

* Remove the current installation.

  ```sh
  sudo rm -rvf /usr/local/go/
  ```

* Download, verify and install the latest Go binaries as described in the [Install Go](go.md#install-go) section of this guide.

## Uninstall Go

* Remove the current installation.

  ```sh
  sudo rm -rvf /usr/local/go/
  ```

<br /><br />

---

<< Back: [+ System](index.md)
