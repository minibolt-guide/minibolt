---
layout:
  width: default
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
  metadata:
    visible: true
  tags:
    visible: true
---

# Bitcoin Knots

[Bitcoin Knots](https://bitcoinknots.org/) is a community-driven fork of Bitcoin Core that offers advanced features, experimental options, and enhanced configurability. It includes additional consensus and networking parameters—such as stronger spam filtering and custom block processing rules — designed for power users and developers seeking deeper control over their Bitcoin node.

{% hint style="warning" %}
Difficulty: Medium
{% endhint %}

<div data-full-width="false"><figure><img src="../../.gitbook/assets/Bitcoin-Knots-Logo.png" alt=""><figcaption></figcaption></figure></div>

### Preparations

* With `admin` user, update, and upgrade your OS:

```sh
sudo apt update && sudo apt full-upgrade
```

### Option 1: Using precompiled binaries

{% hint style="info" %}
**Option recommended for non-advanced users.**
{% endhint %}

#### Installation

* Go to the temporary folder:

```bash
cd /tmp
```

* Set the next environment variables:

```sh
VERSION=29.3.knots20260508 && BRANCH=29.x
```

* Get the latest binaries and signatures:

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

* Check that the reference checksum in the file `SHA256SUMS` matches the checksum calculated by you:

```sh
sha256sum --ignore-missing --check SHA256SUMS
```

**Example** of expected output:

```
bitcoin-28.1.knots20250305.tar.gz: OK
```

#### **Signature check**

Bitcoin releases are signed by several individuals, each using their key. To verify the validity of these signatures, you must first import the corresponding public keys into your GPG key database.

* The next command downloads and automatically imports all signatures from [the Bitcoin Knots release attestations (Guix) repository](https://github.com/bitcoinknots/guix.sigs):

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

* Verify that the checksums file is cryptographically signed by the release signing keys. The following command prints signature checks for each of the public keys that signed the checksums:

```sh
gpg --verify SHA256SUMS.asc SHA256SUMS
```

* Check that at least a few signatures show the following text:

<pre><code>gpg: <a data-footnote-ref href="#user-content-fn-1">Good signature</a> from ...
Primary key fingerprint: ...
[...]
</code></pre>

* If you're satisfied with the checksum, signature, and timestamp checks, extract the Bitcoin Knots source code, install it, and check the version:

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

* Install it:

<pre class="language-sh" data-overflow="wrap"><code class="lang-sh"><strong>sudo install -m 0755 -o root -g root -t /usr/local/bin bitcoin-$VERSION/bin/bitcoin-cli bitcoin-$VERSION/bin/bitcoind
</strong></code></pre>

* Check the correct installation by requesting the output of the version:

```sh
bitcoin-cli --version
```

The following output is just an **example** of one of the versions:

```
Bitcoin Knots daemon version v28.1.knots20250305
Copyright (C) 2009-2025 The Bitcoin Knots developers
Copyright (C) 2009-2025 The Bitcoin Core developers
[...]
```

* **(Optional)** Delete installation files of the `tmp` folder to be ready for the next installation:

{% code overflow="wrap" %}
```bash
sudo rm -r bitcoin-$VERSION bitcoin-$VERSION-x86_64-linux-gnu.tar.gz SHA256SUMS SHA256SUMS.asc
```
{% endcode %}

{% hint style="info" %}
If you want to signal support for the RDTS (BIP110) soft fork, follow the [Enable RDTS (BIP110) consensus rules](bitcoin-knots.md#enable-rdts-bip110-consensus-rules) extra section.

More info: [bip110.org](https://bip110.org/)
{% endhint %}

If you want to signal support for RDTS (BIP110), follow the additional section:

### Option 2: Compiling from source code

{% hint style="info" %}
**Option recommended for advanced users and users who want to improve the censorship resistance of their Bitcoin Knots.**
{% endhint %}

* Install the next dependency packages. Press "**y**" and `enter` or directly `enter` when the prompt asks you:

{% code overflow="wrap" %}
```shell
sudo apt install build-essential cmake pkg-config --no-install-recommends
```
{% endcode %}

#### Installation

* Change to the temporary directory, which is cleared on reboot:

```sh
cd /tmp
```

* Set the next environment variables:

```sh
VERSION=29.3.knots20260508 && BRANCH=29.x
```

* Get the latest source code, the list of cryptographic checksums, and the signatures attesting to the validity of the checksums:

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

* Check that the reference checksum in the file `SHA256SUMS` matches the checksum calculated by you:

```sh
sha256sum --ignore-missing --check SHA256SUMS
```

**Example** of expected output:

```
bitcoin-28.1.knots20250305.tar.gz: OK
```

#### **Signature check**

Bitcoin releases are signed by several individuals, each using their key. To verify the validity of these signatures, you must first import the corresponding public keys into your GPG key database.

* The next command downloads and automatically imports all signatures from [the Bitcoin Knots release attestations (Guix) repository](https://github.com/bitcoinknots/guix.sigs).

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

* Verify that the checksums file is cryptographically signed by the release signing keys. The following command prints signature checks for each of the public keys that signed the checksums:

```sh
gpg --verify SHA256SUMS.asc SHA256SUMS
```

* Check that at least a few signatures show the following text:

<pre><code>gpg: <a data-footnote-ref href="#user-content-fn-1">Good signature</a> from ...
Primary key fingerprint: ...
[...]
</code></pre>

* If you're satisfied with the checksum, signature, and timestamp checks, extract the Bitcoin Knots source code, install it, and check the version:

```sh
tar -xzvf bitcoin-$VERSION.tar.gz
```

**Example** of expected output:

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

* Enter the source code folder:

```sh
cd bitcoin-$VERSION
```

* Build all Bitcoin Knots dependencies:

{% code overflow="wrap" %}
```sh
make -C depends HOST=x86_64-pc-linux-gnu -j$(nproc) NO_QR=1 NO_QT=1 NO_NATPMP=1 NO_UPNP=1 NO_USDT=1
```
{% endcode %}

**Example** of expected output:

```
make: Entering directory '/tmp/bitcoin-29.3.knots20260210/depends'
Fetching boost_1_81_0.tar.gz from https://archives.boost.io/release/1.81.0/source/
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  133M  100  133M    0     0  1277k      0  0:01:47  0:01:47 --:--:-- 1487k
/tmp/bitcoin-29.3.knots20260210/depends/work/download/boost-1.81.0/boost_1_81_0.tar.gz.temp: OK
Extracting boost...
/tmp/bitcoin-29.3.knots20260210/depends/sources/boost_1_81_0.tar.gz: OK
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
100 1075k  100 1075k    0     0  1330k      0 --:--:-- --:--:-- --:--:-- 1330k
/tmp/bitcoin-29.3.knots20260210/depends/work/download/libevent-2.1.12-stable/libevent-2.1.12-stable.tar.gz.temp: OK
Extracting libevent...
/tmp/bitcoin-29.3.knots20260210/depends/sources/libevent-2.1.12-stable.tar.gz: OK
[...]
```

* Pre-configure the installation, we will discard some features and include others. Enter the complete next command in the terminal and press `Enter`:

```sh
BITCOIN_GENBUILD_NO_GIT=1 cmake -B build \
  -DBUILD_TESTS=OFF \
  -DBUILD_TX=OFF \
  -DBUILD_UTIL=OFF \
  -DBUILD_WALLET_TOOL=OFF \
  -DINSTALL_MAN=OFF \
  -DWITH_ZMQ=ON \
  -DRDTS_CONSENT=RUNTIME_WARN \
  -DCMAKE_TOOLCHAIN_FILE=depends/x86_64-pc-linux-gnu/toolchain.cmake
```

#### **Apply the UA patch (optional)**

{% hint style="info" %}
This patch removes the Bitcoin Knots reference from the **user agent** to make it look like Bitcoin Core, improving its censorship resistance.
{% endhint %}

{% hint style="info" %}
Skip this step if you want only to build Bitcoin Knots from the source code, but not apply the user agent patch.
{% endhint %}

* Create the UA patch:

```sh
nano mod-ua-knots.patch
```

* Enter the next content. Save and exit.

```cpp
diff --git a/src/clientversion.cpp b/src/clientversion.cpp
index 6bf7ef6406..9445e3b6f5 100644
--- a/src/clientversion.cpp
+++ b/src/clientversion.cpp
@@ -66,15 +66,7 @@ std::string FormatSubVersion(const std::string& name, int nClientVersion, const
 {
     std::string comments_str;
     if (!comments.empty()) comments_str = strprintf("(%s)", Join(comments, "; "));
-    std::string ua = strprintf("/%s:%s%s/", name, FormatVersion(nClientVersion), comments_str);
-    if (!base_name_only) {
-        static const auto ua_knots = []() -> std::string {
-            const auto pos{CLIENT_BUILD.find(".knots")};
-            return "Knots:" + CLIENT_BUILD.substr(pos + 6) + "/";
-        }();
-        ua += ua_knots;
-    }
-    return ua;
+    return strprintf("/%s:%s%s/", name, FormatVersion(nClientVersion), comments_str);
 }

 std::string CopyrightHolders(const std::string& strPrefix)
```

* Apply the patch:

```sh
git apply mod-ua-knots.patch
```

#### **Build**

* Enter the command to compile:

```sh
cmake --build build -j $(nproc)
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
[  0%] Generating bitcoin-build-info.h
[  1%] Building CXX object src/CMakeFiles/bitcoin_consensus.dir/arith_uint256.cpp.o
[  1%] Building CXX object src/CMakeFiles/crc32c.dir/crc32c/src/crc32c.cc.o
[  1%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/db/builder.cc.o
[  1%] Built target generate_build_info
[  2%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/db/c.cc.o
[  2%] Building CXX object src/CMakeFiles/crc32c.dir/crc32c/src/crc32c_portable.cc.o
[  3%] Building CXX object src/CMakeFiles/crc32c.dir/crc32c/src/crc32c_sse42.cc.o
[  3%] Linking CXX static library libcrc32c.a
[  3%] Built target crc32c
[  3%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/db/db_impl.cc.o
[  3%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/db/db_iter.cc.o
[  3%] Building CXX object src/CMakeFiles/bitcoin_consensus.dir/consensus/merkle.cpp.o
[  3%] Building CXX object src/CMakeFiles/bitcoin_consensus.dir/consensus/tx_check.cpp.o
[  4%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/db/dbformat.cc.o
[  5%] Building CXX object src/CMakeFiles/bitcoin_consensus.dir/hash.cpp.o
[  5%] Building CXX object src/CMakeFiles/bitcoin_consensus.dir/primitives/block.cpp.o
[  5%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/db/dumpfile.cc.o
[  5%] Building CXX object src/CMakeFiles/bitcoin_consensus.dir/primitives/transaction.cpp.o
[  5%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/db/filename.cc.o
[  6%] Building CXX object src/CMakeFiles/bitcoin_consensus.dir/pubkey.cpp.o
[  6%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/db/log_reader.cc.o
[  7%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/db/log_writer.cc.o
[  7%] Building CXX object src/CMakeFiles/bitcoin_consensus.dir/script/script.cpp.o
[  7%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/db/memtable.cc.o
[  7%] Building CXX object src/CMakeFiles/bitcoin_consensus.dir/script/script_error.cpp.o
[  7%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/db/repair.cc.o
[  8%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/db/table_cache.cc.o
[  9%] Building CXX object src/CMakeFiles/bitcoin_consensus.dir/uint256.cpp.o
[  9%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/db/version_edit.cc.o
[  9%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/db/version_set.cc.o
[ 10%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/db/write_batch.cc.o
[ 10%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/table/block.cc.o
[ 10%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/table/block_builder.cc.o
[ 10%] Linking CXX static library ../lib/libbitcoin_consensus.a
[ 10%] Built target bitcoin_consensus
[ 10%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/table/filter_block.cc.o
[ 11%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/table/format.cc.o
[ 11%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/table/iterator.cc.o
[ 11%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/table/merger.cc.o
[ 12%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/table/table.cc.o
[ 12%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/table/table_builder.cc.o
[ 12%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/table/two_level_iterator.cc.o
[ 13%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/util/arena.cc.o
[ 13%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/util/bloom.cc.o
[ 13%] Building CXX object src/CMakeFiles/leveldb.dir/leveldb/util/cache.cc.o
[...]
```

</details>

{% hint style="info" %}
This process can take quite **a long time**, 10-15 minutes or more, depending on the performance of your device. Please be patient until the prompt shows again. You can use [Tmux](https://github.com/tmux/tmux) to leave it in the background.
{% endhint %}

#### **Install**

* Enter the next command to install the new binaries precompiled for yourself on the OS:

```sh
sudo cmake --install build
```

Expected output:

```
-- Install configuration: "RelWithDebInfo"
-- Installing: /usr/local/bin/bitcoind
-- Installing: /usr/local/bin/bitcoin-cli
```

* Check the correct installation by requesting the output of the version:

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
Now you can continue with the installation process of the Bitcoin Client: Bitcoin Core, by following the [Create the bitcoin user](../../bitcoin/bitcoin/bitcoin-client.md#create-the-bitcoin-user) section from now on, or if you already have it installed, only continue with the next steps.
{% endhint %}

* Return to the `tmp` folder:

```bash
cd ..
```

* **(Optional)** Clean the installation files to be ready for the next update:

{% code overflow="wrap" %}
```bash
sudo rm -r bitcoin-$VERSION bitcoin-$VERSION.tar.gz SHA256SUMS SHA256SUMS.asc
```
{% endcode %}

{% hint style="info" %}
**(Optional)** If you have an existing Bitcoin Knots installation without the UA patch applied, restart it using systemd and start a new instance with the UA patch applied:

```bash
sudo systemctl restart bitcoind
```
{% endhint %}

* Monitor the systemd journal and check the logging output. You can exit monitoring at any time with `Ctrl+ C` and continue:

```sh
journalctl -fu bitcoind
```

{% hint style="info" %}
If you want to signal support for the RDTS (BIP110) soft fork, follow the [Enable RDTS (BIP110) consensus rules](bitcoin-knots.md#enable-rdts-bip110-consensus-rules) extra section.

More info: [bip110.org](https://bip110.org/)
{% endhint %}

## Extras (optional)

### Enable RDTS (BIP110) consensus rules

{% hint style="info" %}
Enable the RDTS (BIP110) consensus rules in Bitcoin Knots to participate in the deployment and enforce the new reduced-data transaction validation rules once activated by the network.
{% endhint %}

* With the user admin, edit the `bitcoin.conf` file:

```bash
sudo nano /data/bitcoin/bitcoin.conf
```

* Add the next parameters to the end of the file. Save and exit.

{% code overflow="wrap" %}
```
# Enable BIP110/RDTS consensus rules
consensusrules=rdts
```
{% endcode %}

* Restart Bitcoin Knots to apply changes:

```bash
sudo systemctl restart bitcoind
```

### Enforce spam and arbitrary data rejection

{% hint style="info" %}
Configuring `bitcoin.conf` with targeted Bitcoin Knots parameters, enhance the network’s ability to block spam and arbitrary data.
{% endhint %}

* With the user admin, edit the `bitcoin.conf` file:

```bash
sudo nano /data/bitcoin/bitcoin.conf
```

* Add the next parameters to the end of the file. Save and exit.

<pre><code><strong># No relay or mine data carrier transactions
</strong>datacarrier=0

# Refuse to relay or mine transactions involving non-bitcoin tokens
rejecttokens=1

# Fee rate (in BTC/kvB) used to define dust
dustrelayfee=0.00010
</code></pre>

* Restart Bitcoin Knots to apply changes:

```bash
sudo systemctl restart bitcoind
```

### Add an external fee estimator to the LND

By applying a spam and arbitrary data filter to our node, we can have a different version of the mempool compared to the rest of the network, and with it, the estimation of the fees. It is possible to point the fee estimator to another node without a spam or arbitrary data filter applied.

* With the user admin, stop LND if you have installed it:

```bash
sudo systemctl stop lnd
```

* Edit `lnd.conf`:

```bash
sudo nano /data/lnd/lnd.conf
```

* Add the next lines at the end of the file:

<pre><code><strong>[fee]
</strong># Use external fee estimator
fee.url=https://nodes.lightning.computer/fees/v1/btc-fee-estimates.json
</code></pre>

* Start LND again:

```bash
sudo systemctl start lnd
```

## Upgrade

The latest release can be found on the [GitHub page](https://github.com/bitcoinknots/bitcoin) of the Bitcoin Knots project. Always read the [RELEASE NOTES](https://github.com/bitcoinknots/bitcoin/tree/28.x-knots/doc/release-notes) first! When upgrading, there might be breaking changes or changes in the data structure that need special attention.

Go to the **Option 1**: Using precompiled binaries - [Installation section](bitcoin-knots.md#installation), or **Option 2**: Compiling from source code - [Installation section](bitcoin-knots.md#installation-1), depending on the selected option, and replace the environment variables `"VERSION=x.xx"` and `"BRANCH="x.xx"` values for the latest version and branch, if they have not already been changed in this guide. Continue until you complete the entire Installation section.

{% hint style="info" %}
Remember to restart the Bitcoin Knots to apply the new version with: `sudo systemctl restart bitcoind`
{% endhint %}

## Uninstall

{% hint style="danger" %}
Warning: This section removes the installation. Only run these commands if you intend to uninstall.
{% endhint %}

To uninstall Bitcoin Knots, follow the entire [Bitcoin Client: Bitcoin Core uninstall section](../../bitcoin/bitcoin/bitcoin-client.md#uninstall).

## Port reference

Same as the [Bitcoin Client: Bitcoin Core section](../../bitcoin/bitcoin/bitcoin-client.md#port-reference).

[^1]: Check this
