---
title: Sparrow Server
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

# Sparrow Server

Sparrow Server is a stripped down version of Sparrow that can be run on systems without displays. It's primarily intended as a configuration utility for running Sparrow as a server daemon.

{% hint style="warning" %}
Difficulty: Medium
{% endhint %}

![](../../images/sparrow-server-logo.png)

## Requirements

* [Bitcoin Core](../../index-2/bitcoin-client.md)
* Electrum server: [Fulcrum](../../bitcoin/electrum-server.md) or [Electrs](electrs.md)

## Installation

#### Download Sparrow Server

* Login as `admin` and change to a temporary directory which is cleared on reboot

```sh
$ cd /tmp
```

* Set a temporary version environment variable to the installation

```sh
$ VERSION=1.9.0
```

* Download the application, checksums, and signature

{% code overflow="wrap" %}
```bash
$ wget https://github.com/sparrowwallet/sparrow/releases/download/$VERSION/sparrow-server-$VERSION-x86_64.tar.gz
```
{% endcode %}

{% code overflow="wrap" %}
```bash
$ wget https://github.com/sparrowwallet/sparrow/releases/download/$VERSION/sparrow-$VERSION-manifest.txt.asc
```
{% endcode %}

{% code overflow="wrap" %}
```bash
$ wget https://github.com/sparrowwallet/sparrow/releases/download/$VERSION/sparrow-$VERSION-manifest.txt
```
{% endcode %}

* Import keys that signed the release

```sh
$ curl https://keybase.io/craigraw/pgp_keys.asc | gpg --import
```

* Verify the release

```sh
$ gpg --verify sparrow-$VERSION-manifest.txt.asc
```

**Example** of expected output:

```
> gpg: assuming signed data in 'sparrow-1.8.4-manifest.txt'
> gpg: Signature made Thu Mar  7 16:47:57 2024 UTC
> gpg:                using RSA key D4D0D3202FC06849A257B38DE94618334C674B40
> gpg: Good signature from "Craig Raw <craig@sparrowwallet.com>" [unknown]
> gpg: WARNING: This key is not certified with a trusted signature!
> gpg:          There is no indication that the signature belongs to the owner.
> Primary key fingerprint: D4D0 D320 2FC0 6849 A257  B38D E946 1833 4C67 4B40
```

```sh
$ sha256sum --check sparrow-$VERSION-manifest.txt --ignore-missing
```

Expected output:

```
> sparrow-server-$VERSION-x86_64.tar.gz: OK
```

* If everything is correct, unpack Sparrow

```sh
$ tar -xvf sparrow-server-$VERSION-x86_64.tar.gz
```

* Move data files to the home `admin` user

```sh
$ sudo cp -r Sparrow /home/admin/
```

* Clean the remaining installation files from the `tmp` folder to avoid problems for the next update

```sh
$ sudo rm -r Sparrow && rm sparrow-server-$VERSION-x86_64.tar.gz
```

{% hint style="info" %}
If you come to update, this is the final step. Check the correct update by entering the "`$ Sparrow --version"` command, skip the next step, and jump directly to the [Run Sparrow](sparrow-server.md#run) section to start Sparrow server again with the new version.
{% endhint %}

* Add the Sparrow executable to your PATH by creating a symlink to it within `/usr/local/bin`, which is already part of the PATH

```sh
$ sudo ln -s /home/admin/Sparrow/bin/Sparrow /usr/local/bin/Sparrow
```

* Check the correct installation by reclaiming the version output

```sh
$ Sparrow --version
```

**Example** of expected output:

```
> Sparrow Wallet 1.7.6
```

## Run

* You can run Sparrow with the following command

```sh
$ Sparrow
```

![](../../images/sparrow-server.png)

{% hint style="danger" %}
Sparrow Server doesn't work on MobaXterm with X11-Forwarding enabled in the SSH connection.
{% endhint %}

* In the "wallet" tab you can create or restore your wallet

#### Connect Sparrow to your backend (optional)

* Open Sparrow Wallet

```sh
$ Sparrow
```

* Go to `Preferences > Server > Private Electrum > Continue`
* Set values according to your Electrum Server protocol implementation and test connection

```
# For Fulcrum (TCP)
URL: 127.0.0.1:50001
Use SSL?: No

# For Fulcrum (SSL)
URL: 127.0.0.1:50002
Use SSL?: Yes
```

* You are now connected to your own Electrum Server

![](../../images/sparrow-server-terminal.png)

### Mix Bitcoin with Sparrow Terminal

#### Launch Sparrow using tmux

* Start a new tmux session called "Sparrow"

```sh
$ tmux new -s sparrowserver
```

* Launch Sparrow Terminal

```sh
$ Sparrow
```

* Connect Sparrow Terminal to your own Electrum Server implementation according to the steps above if not already done

#### Create/import wallet

* Go to `Wallets > Create Wallet`
* Paste the seed words of the hot wallet you will mix bitcoin with. If you use for example Samourai Wallet - do not forget to paste the SW passphrase as well
* Create a strong password for the Sparrow Terminal wallet to prevent loss of funds in case someone gets access to your node/wallet
* Open your Wallet

#### Start mixing

* Send Bitcoin to your hot wallet if not already done
* Go to "UTXOs" and select the UTXOs you want to mix. Set Premix priority or fee rate
* Choose the pool you desire. If not sure, you can calculate which pool to use based on fees you will pay using [Whirlpoolfees](https://bitcoiner.guide/wpfees/). It is recommended to use the most economical solution
* Enter SCODE if available, and you will get a discount on the pool fee. You can monitor SCODEs by following the Samourai Wallets RRSS. SCODEs are shared occasionally at random by the Samourai Wallet developer team to give Whirpool participants discounted mixing fees
* Mix selected funds
* Once confirmed, go to `Accounts > Postmix > UTXOs > Mix To`
* You can mix to cold storage if desired. Select the value for minimum mixes before sending them to cold storage
* If you use Whirlpool with Dojo as well - set the Postmix index range to "odd". This way you improve your chances of getting into a mix by running two separate mixing clients at the same time, using different index ranges to prevent mix failures

#### Detaching a session

* Detach tmux session to run Sparrow Server in the background

1. Press `Ctrl + b` once
2. Press `d` once

Closing or logging out from your node without detaching would cause mixing to stop. Sparrow Server now runs as a separate process regardless of your disconnecting from the node

* You can view tmux sessions using the following command

```sh
$ tmux ls
```

* You can get back in sessions using

```sh
$ tmux a
```

* Or use this if you have other sessions opened

```sh
$ tmux a -t sparrowserver
```

* You can leave and delete the tmux session by pressing `Ctrl + d`

## Upgrade

Follow the complete [Installation](sparrow-server.md#installation) section replacing the environment variable `"VERSION=x.xx"` value for the latest if it has not been already changed in this guide.

## Uninstall

* Delete Sparrow symlinks & directory

```bash
$ sudo rm /usr/local/bin/Sparrow
```

```bash
$ sudo rm -r /home/admin/Sparrow
```
