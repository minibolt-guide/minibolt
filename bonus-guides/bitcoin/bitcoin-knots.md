# Bitcoin Knots

[**Bitcoin Knots**](https://bitcoinknots.org/) is a community-driven fork of Bitcoin Core that offers advanced features, experimental options, and enhanced configurability. It includes additional consensus and networking parameters—such as stronger spam filtering and custom block processing rules—designed for power users and developers seeking deeper control over their Bitcoin node.

<div data-full-width="false"><figure><img src="../../.gitbook/assets/Bitcoin-Knots-Logo.png" alt=""><figcaption></figcaption></figure></div>

### Preparations

* With `admin` user, update, and upgrade your OS

```sh
sudo apt update && sudo apt full-upgrade
```

### Option 1: Using precompiled binaries

{% hint style="info" %}
#### Option recommended for non-advanced users
{% endhint %}

#### Installation

* Go to the temporary folder

```bash
cd /tmp
```

* Set the next environment variables

```sh
VERSION=29.1.knots20250903 && BRANCH=29.x
```

* Get the latest binaries and signatures

{% code overflow="wrap" %}
```sh
wget https://bitcoinknots.org/files/$BRANCH/$VERSION/bitcoin-$VERSION-x86_64-linux-gnu.tar.gz
```
{% endcode %}

```sh
wget https://bitcoinknots.org/files/$BRANCH/$VERSION/SHA256SUMS
```

```sh
wget https://bitcoinknots.org/files/$BRANCH/$VERSION/SHA256SUMS.asc
```

#### **Checksum check**

* Check that the reference checksum in the file `SHA256SUMS` matches the checksum calculated by you

```sh
sha256sum --ignore-missing --check SHA256SUMS
```

**Example** of expected output:

```
bitcoin-28.1.knots20250305.tar.gz: OK
```

#### **Signature check**

Bitcoin releases are signed by several individuals, each using their key. To verify the validity of these signatures, you must first import the corresponding public keys into your GPG key database.

* The next command downloads and automatically imports all signatures from [the Bitcoin Knots release attestations (Guix) repository](https://github.com/bitcoinknots/guix.sigs)

{% code overflow="wrap" %}
```bash
curl -s "https://api.github.com/repos/bitcoinknots/guix.sigs/contents/builder-keys?ref=knots" | grep download_url | grep -oE "https://[a-zA-Z0-9./-]+" | while read url; do curl -s "$url" | gpg --import; done
```
{% endcode %}

**Example** of expected output:

```
[...]
gpg: directory '/home/admin/.gnupg' created
gpg: keybox '/home/admin/.gnupg/pubring.kbx' created
gpg: key 2EBB056FD847F8A7: 12 signatures not checked due to missing keys
gpg: /home/admin/.gnupg/trustdb.gpg: trustdb created
gpg: key 2EBB056FD847F8A7: public key "Stephan Oeste (it) <it@oeste.de>" imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg: no ultimately trusted keys found
gpg: key 57FF9BDBCC301009: 54 signatures not checked due to missing keys
gpg: key 57FF9BDBCC301009: public key "Sjors Provoost <sjors@sprovoost.nl>" imported
gpg: Total number processed: 1
gpg:               imported: 1
[...]
```

* Verify that the checksums file is cryptographically signed by the release signing keys. The following command prints signature checks for each of the public keys that signed the checksums

```sh
gpg --verify SHA256SUMS.asc
```

* Check that at least a few signatures show the following text

Expected output:

```
gpg: Good signature from ...
Primary key fingerprint: ...
[...]
```

* If you're satisfied with the checksum, signature, and timestamp checks, extract the Bitcoin Knots source code, install it, and check the version

```sh
tar -xzvf bitcoin-$VERSION-x86_64-linux-gnu.tar.gz
```

**Example of expected output:**

```
bitcoin-28.0/
bitcoin-28.0/.cirrus.yml
bitcoin-28.0/.editorconfig
bitcoin-28.0/.gitattributes
bitcoin-28.0/.github/
bitcoin-28.0/.github/ISSUE_TEMPLATE/
bitcoin-28.0/.github/ISSUE_TEMPLATE/bug.yml
bitcoin-28.0/.github/ISSUE_TEMPLATE/config.yml
bitcoin-28.0/.github/ISSUE_TEMPLATE/feature_request.yml
bitcoin-28.0/.github/ISSUE_TEMPLATE/good_first_issue.yml
bitcoin-28.0/.github/ISSUE_TEMPLATE/gui_issue.yml
bitcoin-28.0/.github/PULL_REQUEST_TEMPLATE.md
bitcoin-28.0/.github/workflows/
[..]
```

#### Binaries installation

* Install it

<pre class="language-sh" data-overflow="wrap"><code class="lang-sh"><strong>sudo install -m 0755 -o root -g root -t /usr/local/bin bitcoin-$VERSION/bin/bitcoin-cli bitcoin-$VERSION/bin/bitcoind
</strong></code></pre>

* Check the correct installation by requesting the output of the version

```sh
bitcoind --version
```

The following output is just an **example** of one of the versions:

```
Bitcoin Knots daemon version v28.1.knots20250305
Copyright (C) 2009-2025 The Bitcoin Knots developers
Copyright (C) 2009-2025 The Bitcoin Core developers
[...]
```

* **(Optional)** Delete installation files of the `tmp` folder to be ready for the next installation

{% code overflow="wrap" %}
```bash
sudo rm -r bitcoin-$VERSION bitcoin-$VERSION-x86_64-linux-gnu.tar.gz SHA256SUMS SHA256SUMS.asc
```
{% endcode %}

### Option 2: Compiling from source code

{% hint style="info" %}
#### Option recommended for advanced users and users who want to improve the censorship resistance of their Bitcoin Knots
{% endhint %}

* Install the next dependency packages. Press "**y**" and `enter` or directly `enter` when the prompt asks you

{% code overflow="wrap" %}
```shell
sudo apt install autoconf automake build-essential libboost-filesystem-dev libboost-system-dev libboost-thread-dev libevent-dev libsqlite3-dev libtool pkg-config libzmq3-dev --no-install-recommends
```
{% endcode %}

#### Installation

* Change to the temporary directory, which is cleared on reboot

```sh
cd /tmp
```

* Set the next environment variables

```sh
VERSION=28.1.knots20250305 && BRANCH=28.x
```

* Get the latest source code, the list of cryptographic checksums, and the signatures attesting to the validity of the checksums

```sh
wget https://bitcoinknots.org/files/$BRANCH/$VERSION/bitcoin-$VERSION.tar.gz
```

```sh
wget https://bitcoinknots.org/files/$BRANCH/$VERSION/SHA256SUMS
```

```sh
wget https://bitcoinknots.org/files/$BRANCH/$VERSION/SHA256SUMS.asc
```

#### **Checksum check**

* Check that the reference checksum in the file `SHA256SUMS` matches the checksum calculated by you

```sh
sha256sum --ignore-missing --check SHA256SUMS
```

**Example** of expected output:

```
bitcoin-28.1.knots20250305.tar.gz: OK
```

#### **Signature check**

Bitcoin releases are signed by several individuals, each using its key. To verify the validity of these signatures, you must first import the corresponding public keys into your GPG key database.

* The next command downloads and automatically imports all signatures from [the Bitcoin Knots release attestations (Guix) repository](https://github.com/bitcoinknots/guix.sigs)

{% code overflow="wrap" %}
```bash
curl -s "https://api.github.com/repos/bitcoinknots/guix.sigs/contents/builder-keys?ref=knots" | grep download_url | grep -oE "https://[a-zA-Z0-9./-]+" | while read url; do curl -s "$url" | gpg --import; done
```
{% endcode %}

**Example** of expected output:

```
[...]
gpg: directory '/home/admin/.gnupg' created
gpg: keybox '/home/admin/.gnupg/pubring.kbx' created
gpg: key 2EBB056FD847F8A7: 12 signatures not checked due to missing keys
gpg: /home/admin/.gnupg/trustdb.gpg: trustdb created
gpg: key 2EBB056FD847F8A7: public key "Stephan Oeste (it) <it@oeste.de>" imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg: no ultimately trusted keys found
gpg: key 57FF9BDBCC301009: 54 signatures not checked due to missing keys
gpg: key 57FF9BDBCC301009: public key "Sjors Provoost <sjors@sprovoost.nl>" imported
gpg: Total number processed: 1
gpg:               imported: 1
[...]
```

* Verify that the checksums file is cryptographically signed by the release signing keys. The following command prints signature checks for each of the public keys that signed the checksums

```sh
gpg --verify SHA256SUMS.asc
```

* Check that at least a few signatures show the following text

Expected output:

```
gpg: Good signature from ...
Primary key fingerprint: ...
[...]
```

* If you're satisfied with the checksum, signature, and timestamp checks, extract the Bitcoin Knots source code, install it, and check the version

```sh
tar -xzvf bitcoin-$VERSION.tar.gz
```

**Example of expected output:**

```
bitcoin-28.0/
bitcoin-28.0/.cirrus.yml
bitcoin-28.0/.editorconfig
bitcoin-28.0/.gitattributes
bitcoin-28.0/.github/
bitcoin-28.0/.github/ISSUE_TEMPLATE/
bitcoin-28.0/.github/ISSUE_TEMPLATE/bug.yml
bitcoin-28.0/.github/ISSUE_TEMPLATE/config.yml
bitcoin-28.0/.github/ISSUE_TEMPLATE/feature_request.yml
bitcoin-28.0/.github/ISSUE_TEMPLATE/good_first_issue.yml
bitcoin-28.0/.github/ISSUE_TEMPLATE/gui_issue.yml
bitcoin-28.0/.github/PULL_REQUEST_TEMPLATE.md
bitcoin-28.0/.github/workflows/
[..]
```

#### **Build it from the source code**

* Enter the bitcoin source code folder

```sh
cd bitcoin-$VERSION
```

* Execute the `autogen.sh` script

```sh
./autogen.sh
```

Expected output:

```
libtoolize: putting auxiliary files in AC_CONFIG_AUX_DIR, 'build-aux'.
libtoolize: copying file 'build-aux/ltmain.sh'
libtoolize: putting macros in AC_CONFIG_MACRO_DIRS, 'build-aux/m4'.
libtoolize: copying file 'build-aux/m4/libtool.m4'
libtoolize: copying file 'build-aux/m4/ltoptions.m4'
libtoolize: copying file 'build-aux/m4/ltsugar.m4'
libtoolize: copying file 'build-aux/m4/ltversion.m4'
libtoolize: copying file 'build-aux/m4/lt~obsolete.m4'
configure.ac:39: installing 'build-aux/ar-lib'
configure.ac:37: installing 'build-aux/compile'
configure.ac:24: installing 'build-aux/config.guess'
configure.ac:24: installing 'build-aux/config.sub'
configure.ac:27: installing 'build-aux/install-sh'
configure.ac:27: installing 'build-aux/missing'
Makefile.am: installing 'build-aux/depcomp'
parallel-tests: installing 'build-aux/test-driver'
libtoolize: putting auxiliary files in AC_CONFIG_AUX_DIR, 'build-aux'.
libtoolize: copying file 'build-aux/ltmain.sh'
[...]
```

* Pre-configure the installation, we will discard some features and include others. Enter the complete next command in the terminal and press enter

```sh
./configure \
  --disable-bench \
  --disable-maintainer-mode \
  --disable-tests \
  --with-gui=no
```

#### **Apply the UA patch (optional)**

{% hint style="info" %}
This patch removes the Bitcoin Knots reference from the **user agent** to make it look like Bitcoin Core, improving its censorship resistance
{% endhint %}

{% hint style="info" %}
Skip this step if you want only to build Bitcoin Knots from the source code, but not apply the user agent patch
{% endhint %}

* Download the UA patch

{% code overflow="wrap" %}
```bash
wget https://raw.githubusercontent.com/minibolt-guide/minibolt/refs/heads/main/resources/mod-ua-knots.patch
```
{% endcode %}

* **(Optional)** Inspect `mod-ua-knots.patch` file to make sure it does not do bad things. If you see all OK, exit with Ctrl-X and continue with the next command

```sh
nano mod-ua-knots.patch
```

* Apply the patch

```sh
git apply mod-ua-knots.patch
```

#### **Build**

* Enter the command to compile

```sh
make -j$(nproc)
```

{% hint style="info" %}
This process can take quite **a long time**, 10-15 minutes or more, depending on the performance of your device. Please be patient until the prompt shows again. You can use [Tmux](https://github.com/tmux/tmux) to leave it in the background
{% endhint %}

#### **Install**

* Enter the next command to install the new binaries precompiled for yourself on the OS

```sh
sudo make install
```

* Check the correct installation by requesting the output of the version

```sh
bitcoin-cli --version
```

The following output is just an **example** of one of the versions:

```
Bitcoin Knots RPC client version v28.1.knots20250305
Copyright (C) 2009-2025 The Bitcoin Knots developers
Copyright (C) 2009-2025 The Bitcoin Core developers
[...]
```

{% hint style="info" %}
Now you can continue with the installation process of the Bitcoin Client: Bitcoin Core, by following the [Create the bitcoin user](../../bitcoin/bitcoin/bitcoin-client.md#create-the-bitcoin-user) section from now on, or if you already have it installed, only continue with the next steps
{% endhint %}

* Return to the `tmp` folder

```bash
cd ..
```

* **(Optional)** Clean the installation files to be ready for the next update

{% code overflow="wrap" %}
```bash
sudo rm -r bitcoin-$VERSION bitcoin-$VERSION.tar.gz SHA256SUMS SHA256SUMS.asc
```
{% endcode %}

* **(Optional)** Delete unnecessary binaries before installing `make install` command

{% code overflow="wrap" %}
```bash
sudo rm /usr/local/bin/bitcoin-tx /usr/local/bin/bitcoin-wallet /usr/local/bin/bitcoin-util
```
{% endcode %}

* If you have an existing Bitcoin Knots installation without the UA patch applied, restart it using systemd and start a new instance with the UA patch applied

```sh
sudo systemctl restart bitcoind
```

* Monitor the systemd journal and check the logging output. You can exit monitoring at any time with `Ctrl+ C` and continue

```sh
journalctl -fu bitcoind
```

## Extras (optional)

### Enforce spam and arbitrary data rejection

{% hint style="info" %}
Configuring `bitcoin.conf` with targeted Bitcoin Knots parameters enhance the network’s ability to block spam and arbitrary data
{% endhint %}

* With the user admin, edit the `bitcoin.conf` file

```bash
sudo nano /data/bitcoin/bitcoin.conf
```

* Add the next parameters to the end of the file. Save and exit

```
# No relay or mine data carrier transactions
datacarrier=0

# Refuse to relay or mine transactions involving non-bitcoin tokens
rejecttokens=1

# Fee rate (in BTC/kvB) used to define dust
dustrelayfee=0.00010
```

* Restart Bitcoin Core to apply changes

```bash
sudo systemctl restart bitcoind
```

### Add an external fee estimator to the LND

By applying a spam and arbitrary data filter to our node, we can have a different version of the mempool compared to the rest of the network, and with it, the estimation of the fees. It is possible to point the fee estimator to another node without a spam or arbitrary data filter applied.

* With the user admin, stop LND if you have installed it

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

## Upgrade

The latest release can be found on the [GitHub page](https://github.com/bitcoinknots/bitcoin) of the Bitcoin Knots project. Always read the [RELEASE NOTES](https://github.com/bitcoinknots/bitcoin/tree/28.x-knots/doc/release-notes) first! When upgrading, there might be breaking changes or changes in the data structure that need special attention

Go to the Option 1: Using precompiled binaries - [Installation section](bitcoin-knots.md#installation), or Option 2: Compiling from source code - [Installation section](bitcoin-knots.md#installation-1), depending on the selected option, and replace the environment variables `"VERSION=x.xx"` and `"BRANCH="x.xx"` values for the latest version and branch, if they have not already been changed in this guide. Continue until you complete the entire Installation section.

{% hint style="info" %}
Remember to restart the Bitcoin Knots to apply the new version with: `sudo systemctl restart bitcoind`
{% endhint %}

## Uninstall

To uninstall Bitcoin Knots, follow the entire Bitcoin Client: Bitcoin Core [uninstall section](../../bitcoin/bitcoin/bitcoin-client.md#uninstall)

## Port reference

Same as the [Bitcoin Client: Bitcoin Core section](../../bitcoin/bitcoin/electrum-server.md#port-reference)
