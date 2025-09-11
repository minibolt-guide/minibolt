---
title: Ordisrespector
parent: + Bitcoin
grand_parent: Bonus Section
nav_exclude: true
has_children: false
has_toc: false
---

# Ordisrespector spam filter

[Ordinals](https://ordinals.com/) is a project created to number sats. It also has a feature called inscriptions, which is the problematic part and what is mainly being touched on in this guide. An inscription is data stored onchain associated with a sat.

{% hint style="warning" %}
Difficulty: Medium
{% endhint %}

![](../../images/ordisrespector-thread.png)

## Context

Why is there an attack on Bitcoin?

First of all, we probably should look at what Bitcoin is:

> A Peer-to-Peer Electronic Cash System [(Bitcoin Whitepaper)](https://bitcoin.org/bitcoin.pdf)

There is no mention of data storage on the chain, and only financial transactions. Ordinals abuse the Bitcoin timechain, which was meant to process financial transaction,s to store data, and this has some issues, such as:

* Pushing out financial transactions, such as ones that need immediate confirmation, such as force closes with pending HTLCs or a sweep-all TX.
* Driving up fee rates for the sole reason of inscribing a JPEG.
* It makes it way more expensive to maintain their node in the long term.
* It makes them liable for any illegal content in their jurisdiction that they store on their disk and broadcast freely.

...while paying 4x less for the same bytes.

[Ordisrespector](https://twitter.com/oomahq/status/1621899175079051264) is a _**spam patch filter**_ that works by detecting the pattern of Ordinals transactions that are entering the mempool of the node and _**rejecting them**_. The original patch was created by Luke Dashjr, you can see it here. [Archive](https://web.archive.org/web/20230207212859/https://gist.github.com/luke-jr/4c022839584020444915c84bdd825831)

{% embed url="https://gist.github.com/luke-jr/4c022839584020444915c84bdd825831" %}

## Preparations

* With `admin` user, update and upgrade your OS. Press "y" and enter, or directly enter when the prompt asks you

```sh
sudo apt update && sudo apt full-upgrade
```

* Install the next dependency packages

{% code overflow="wrap" %}
```shell
sudo apt install build-essential cmake pkg-config --no-install-recommends
```
{% endcode %}

## Installation

* Change to the temporary directory, which is cleared on reboot

```sh
cd /tmp
```

* Set the next environment variable

```sh
VERSION=29.1
```

* Get the latest source code, the list of cryptographic checksums, and the signatures attesting to the validity of the checksums

```sh
wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/bitcoin-$VERSION.tar.gz
```

```sh
wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS
```

```sh
wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS.asc
```

{% hint style="info" %}
If you already had Bitcoin Core installed and the OTS client with the IBD completed, you could do the timestamp check verification
{% endhint %}

* Download the timestamp file

```sh
wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS.ots
```

* Execute the OTS verification command

{% hint style="warning" %}
**Skip this step if you are building a new node**
{% endhint %}

```sh
ots --no-cache verify SHA256SUMS.ots -f SHA256SUMS
```

The following output is just an **example** of one of the versions:

```
Got 1 attestation(s) from https://btc.calendar.catallaxy.com
Got 1 attestation(s) from https://finney.calendar.eternitywall.com
Got 1 attestation(s) from https://bob.btc.calendar.opentimestamps.org
Got 1 attestation(s) from https://alice.btc.calendar.opentimestamps.org
Success! Bitcoin block 766964 attests existence as of 2022-12-11 UTC
```

{% hint style="info" %}
Now, check that the timestamp date is close to the [release](https://github.com/bitcoin/bitcoin/releases) date of the version you're installing

If you obtain this output:

```
Calendar https://btc.calendar.catallaxy.com: Pending confirmation in Bitcoin blockchain
Calendar https://finney.calendar.eternitywall.com: Pending confirmation in Bitcoin blockchain
Calendar https://bob.btc.calendar.opentimestamps.org: Pending confirmation in Bitcoin blockchain
Calendar https://alice.btc.calendar.opentimestamps.org: Pending confirmation in Bitcoin blockchain
```

-> This means that the timestamp is pending confirmation on the Bitcoin blockchain. You can skip this step or wait a few hours/days to perform this verification. It is safe to skip this verification step if you followed the previous ones and continue to the next step
{% endhint %}

### **Signature check**

Bitcoin releases are signed by several individuals, each using its key. To verify the validity of these signatures, you must first import the corresponding public keys into your GPG key database.

* The next command downloads and automatically imports all signatures from the [Bitcoin Core release attestations (Guix)](https://github.com/bitcoin-core/guix.sigs) repository

{% code overflow="wrap" %}
```bash
curl -s "https://api.github.com/repositories/355107265/contents/builder-keys" | grep download_url | grep -oE "https://[a-zA-Z0-9./-]+" | while read url; do curl -s "$url" | gpg --import; done
```
{% endcode %}

**Example** of expected output:

```
[...]
gpg: key 17565732E08E5E41: 29 signatures not checked due to missing keys
gpg: /home/admin/.gnupg/trustdb.gpg: trustdb created
gpg: key 17565732E08E5E41: public key "Andrew Chow <andrew@achow101.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg: no ultimately trusted keys found
[...]
```

* Verify that the checksums file is cryptographically signed by the release signing keys. The following command prints signature checks for each of the public keys that signed the checksums

```sh
gpg --verify SHA256SUMS.asc SHA256SUMS
```

* Check that at least a few signatures show the following text

Expected output:

```
gpg: Good signature from ...
Primary key fingerprint: ...
[...]
```

### **Checksum check**

* Check that the reference checksum in the file `SHA256SUMS` matches the checksum calculated by you (ignore the "lines are improperly formatted" warning)

```sh
sha256sum --ignore-missing --check SHA256SUMS
```

**Example** of expected output:

```
bitcoin-29.0.tar.gz: OK
```

* If you're satisfied with the signature, checksum, and timestamp checks, extract the Bitcoin Core source code, install it, and check the version

```sh
tar -xzvf bitcoin-$VERSION.tar.gz
```

**Example of expected output:**

```
bitcoin-29.0/
bitcoin-29.0/.cirrus.yml
bitcoin-29.0/.editorconfig
bitcoin-29.0/.gitattributes
bitcoin-29.0/.github/
bitcoin-29.0/.github/ISSUE_TEMPLATE/
bitcoin-29.0/.github/ISSUE_TEMPLATE/bug.yml
bitcoin-29.0/.github/ISSUE_TEMPLATE/config.yml
bitcoin-29.0/.github/ISSUE_TEMPLATE/feature_request.yml
bitcoin-29.0/.github/ISSUE_TEMPLATE/good_first_issue.yml
bitcoin-29.0/.github/ISSUE_TEMPLATE/gui_issue.yml
bitcoin-29.0/.github/PULL_REQUEST_TEMPLATE.md
bitcoin-29.0/.github/workflows/
[..]
```

### **Build it from the source code**

* Enter the Bitcoin Core source code folder

```sh
cd bitcoin-$VERSION
```

* Build all Bitcoin Core dependencies

```sh
make -C depends -j$(nproc) NO_QR=1 NO_QT=1 NO_NATPMP=1 NO_UPNP=1 NO_USDT=1
```

**Example** of expected output:

```
make: Entering directory '/tmp/bitcoin-29.0/depends'
Fetching boost_1_81_0.tar.gz from https://archives.boost.io/release/1.81.0/source/
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  133M  100  133M    0     0  39.0M      0  0:00:03  0:00:03 --:--:-- 39.0M
/tmp/bitcoin-29.0/depends/work/download/boost-1.81.0/boost_1_81_0.tar.gz.temp: OK
Extracting boost...
/tmp/bitcoin-29.0/depends/sources/boost_1_81_0.tar.gz: OK
Preprocessing boost...
Configuring boost...
Building boost...
Staging boost...
Postprocessing boost...
Caching boost...
Fetching libevent-2.1.12-stable.tar.gz from https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 1075k  100 1075k    0     0  1117k      0 --:--:-- --:--:-- --:--:-- 3812k
/tmp/bitcoin-29.0/depends/work/download/libevent-2.1.12-stable/libevent-2.1.12-stable.tar.gz.temp: OK
Extracting libevent...
/tmp/bitcoin-29.0/depends/sources/libevent-2.1.12-stable.tar.gz: OK
Preprocessing libevent...
patching file CMakeLists.txt
patching file cmake/AddEventLibrary.cmake
patching file CMakeLists.txt
Configuring libevent...
-- The C compiler identification is GNU 11.4.0
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /usr/bin/gcc - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Found Git: /usr/bin/git (found version "2.34.1") 
fatal: not a git repository (or any of the parent directories): .git
-- Performing Test check_c_compiler_flag__Wall
-- Performing Test check_c_compiler_flag__Wall - Success
-- Performing Test check_c_compiler_flag__Wextra
-- Performing Test check_c_compiler_flag__Wextra - Success
[...]
```

* Pre-configure the installation, we will discard some features and include others. Enter the complete next command in the terminal and press enter

```sh
BITCOIN_GENBUILD_NO_GIT=1 cmake -B build \
  -DBUILD_TESTS=OFF \
  -DBUILD_TX=OFF \
  -DBUILD_UTIL=OFF \
  -DBUILD_WALLET_TOOL=OFF \
  -DINSTALL_MAN=OFF \
  -DWITH_BDB=ON \
  -DWITH_ZMQ=ON \
  --toolchain depends/x86_64-pc-linux-gnu/toolchain.cmake
```

Expected output:

```
-- The CXX compiler identification is GNU 11.4.0
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /usr/bin/g++ - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Setting build type to "RelWithDebInfo" as none was specified
-- Performing Test CXX_SUPPORTS__WERROR
-- Performing Test CXX_SUPPORTS__WERROR - Success
-- Performing Test CXX_SUPPORTS__G3
-- Performing Test CXX_SUPPORTS__G3 - Success
-- Performing Test LINKER_SUPPORTS__G3
-- Performing Test LINKER_SUPPORTS__G3 - Success
-- Performing Test CXX_SUPPORTS__FTRAPV
-- Performing Test CXX_SUPPORTS__FTRAPV - Success
-- Performing Test LINKER_SUPPORTS__FTRAPV
-- Performing Test LINKER_SUPPORTS__FTRAPV - Success
-- Found SQLite3: /tmp/bitcoin-29.0/depends/x86_64-pc-linux-gnu/include (found suitable version "3.46.1", minimum required is "3.7.17") 
-- Found BerkeleyDB: /tmp/bitcoin-29.0/depends/x86_64-pc-linux-gnu/lib/libdb_cxx-4.8.a (found suitable version "4.8.30", minimum required is "4.8") 
-- Found ZeroMQ: /tmp/bitcoin-29.0/depends/x86_64-pc-linux-gnu/lib/cmake/ZeroMQ (found suitable version "4.3.5", minimum required is "4.0.0") 
[...]
```

### **Apply the "Ordisrespector" patch**

{% hint style="info" %}
Skip this step if you want only to build Bitcoin Core from the source code, but not apply the Ordisrespector patch
{% endhint %}

* Download the Ordisrespector patch

{% code overflow="wrap" %}
```bash
wget https://raw.githubusercontent.com/minibolt-guide/minibolt/main/resources/ordisrespector.patch
```
{% endcode %}

* **(Optional)** Inspect `ordisrespector.patch` file to make sure it does not do bad things. If you see all OK, exit with Ctrl-X and continue with the next command

```sh
nano ordisrespector.patch
```

* Apply the patch

```sh
git apply ordisrespector.patch
```

### **Build**

* Enter the command to compile

```sh
cmake --build build -j $(nproc)
```

{% hint style="info" %}
This process can take quite **a long time**, 10-15 minutes or more, depending on the performance of your device. Please be patient until the prompt shows again. You can use [Tmux](https://github.com/tmux/tmux) to leave it in the background
{% endhint %}

### **Install**

* Enter the next command to install the new binaries precompiled for yourself on the OS

```sh
sudo cmake --install build
```

Expected output:

```
-- Install configuration: "RelWithDebInfo"
-- Installing: /usr/local/bin/bitcoind
-- Installing: /usr/local/bin/bitcoin-cli
```

* Check the correct installation by requesting the output of the version

```sh
bitcoin-cli --version
```

The following output is just an **example** of one of the versions:

```
Bitcoin Core version v29.0.0
Copyright (C) 2009-2024 The Bitcoin Core developers
[...]
```

{% hint style="info" %}
Now you can continue with the installation process of the Bitcoin Client following the [Create the bitcoin user](../../bitcoin/bitcoin/bitcoin-client.md#create-the-bitcoin-user) section, or if you already have it installed, only continue with the next steps
{% endhint %}

* Return to the `tmp` folder

```bash
cd ..
```

* **(Optional)** Clean the installation files to be ready for the next update

{% code overflow="wrap" %}
```bash
sudo rm -r bitcoin-$VERSION bitcoin-$VERSION.tar.gz SHA256SUMS SHA256SUMS.asc SHA256SUMS.ots
```
{% endcode %}

* If you have an existing Bitcoin Core installation without Ordisrespector applied, restart it using systemd and start a new instance with the Ordisrespector patch applied

```sh
sudo systemctl restart bitcoind
```

* Monitor the systemd journal and check the logging output. You can exit monitoring at any time with Ctrl+C and continue

```sh
journalctl -fu bitcoind
```

## Extras (optional)

### Add an external fee estimator to the LND

By applying Ordisrespector to our node, we can have a different version of the mempool compared to the rest of the network, and with it, the estimation of the fees. It is possible to point the fee estimator to another node without Ordisrespector applied

* With user admin, stop LND if you have installed

```bash
sudo systemctl stop lnd
```

* Edit `lnd.conf`

```bash
sudo nano /data/lnd/lnd.conf
```

* Add the next lines at the end of the file

<pre><code><strong>[fee]
</strong># Use external fee estimator
fee.url=https://nodes.lightning.computer/fees/v1/btc-fee-estimates.json
</code></pre>

* Start LND again

```bash
sudo systemctl start lnd
```

### Reject other possible data included in transactions

Once you get to the [Configuration section](../../bitcoin/bitcoin/bitcoin-client.md#configuration) of the Bitcoin Client: Bitcoin Core

* With user `bitcoin`, create the `bitcoin.conf` file

```bash
nano /home/bitcoin/.bitcoin/bitcoin.conf
```

* Include with the rest, the next lines at the end of the file. Save and exit

```
# Reject data in transactions
datacarrier=0
permitbaremultisig=0
```

{% hint style="info" %}
[Continue](../../bitcoin/bitcoin/bitcoin-client.md#configuration) with the guide on `Set permissions:..`. step
{% endhint %}

{% hint style="warning" %}
Attention: with the previous configuration, Whirlpool will not work, and is not recommended for mining use
{% endhint %}

## Upgrade

The latest release can be found on the [GitHub page](https://github.com/bitcoin/bitcoin/releases) of the Bitcoin Core project. Always read the [RELEASE NOTES](https://github.com/bitcoin/bitcoin/tree/master/doc/release-notes) first! When upgrading, there might be breaking changes or changes in the data structure that need special attention

Go to the [Installation section](ordisrespector.md#installation), and replace the environment variable `"VERSION=x.xx"` value for the latest version if it has not already been changed in this guide. Continue until you complete the entire [Installation section](ordisrespector.md#installation)

{% hint style="info" %}
Remember to restart the Bitcoin Core to apply the new version with `sudo systemctl restart bitcoind`
{% endhint %}

## Uninstall

To uninstall Bitcoin Core with the Ordisrespector patch applied, follow the entire Bitcoin Core [uninstall section](../../bitcoin/bitcoin/bitcoin-client.md#uninstall)

## Port reference

Same as the [Bitcoin Core section](../../bitcoin/bitcoin/bitcoin-client.md#port-reference)
