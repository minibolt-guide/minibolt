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
  actions:
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

{% hint style="info" icon="baby" %}
**Option recommended for non-advanced users.**
{% endhint %}

#### Installation

* Go to the temporary folder:

```bash
cd /tmp
```

* Set the following environment variables:

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

### Option 2: Compiling from source code

{% hint style="info" icon="starfighter-twin-ion-engine-advanced" %}
**Option recommended for advanced users and users who want to improve the censorship resistance of their Bitcoin Knots.**
{% endhint %}

* Install the next dependency packages. Press "**y**" and `enter` or directly `enter` when the prompt asks you:

{% code overflow="wrap" %}
```shell
sudo apt install build-essential cmake pkg-config --no-install-recommends
```
{% endcode %}

#### Installation

* Login as `admin` user and change to the temporary directory, which is cleared on reboot:

```sh
cd /tmp
```

* Set the following environment variables:

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

* Pre-configure the installation; we will discard some features and include others. Enter the complete command below in the terminal and press `Enter`:

{% hint style="info" %}
Enable the RDTS (BIP110) consensus rules in Bitcoin Knots to participate in the deployment and enforce the new reduced-data transaction validation rules once activated by the network.

More info: [bip110.org](https://bip110.org/)

-> Change `-DRDTS_CONSENT=RUNTIME_WARN` to `-DRDTS_CONSENT=IMPLICIT` to assume consent at build time, enabling RDTS without runtime prompts or checks.
{% endhint %}

<pre class="language-sh"><code class="lang-sh">BITCOIN_GENBUILD_NO_GIT=1 cmake -B build \
  -DBUILD_TESTS=OFF \
  -DBUILD_TX=OFF \
  -DBUILD_UTIL=OFF \
  -DBUILD_WALLET_TOOL=OFF \
  -DINSTALL_MAN=OFF \
  -DWITH_ZMQ=ON \
  -DRDTS_CONSENT=<a data-footnote-ref href="#user-content-fn-2">RUNTIME_WARN</a> \
  -DCMAKE_TOOLCHAIN_FILE=depends/x86_64-pc-linux-gnu/toolchain.cmake
</code></pre>

#### **Apply the UA patch (optional)**

{% hint style="info" %}
This patch removes the Bitcoin Knots reference from the **user agent** to make it look like Bitcoin Core, improving its censorship resistance.
{% endhint %}

{% hint style="info" %}
Skip this step if you only want to build Bitcoin Knots from the source code and not apply the user agent patch.
{% endhint %}

* Create the UA patch:

```sh
nano mod-ua-knots.patch
```

* Enter the following content. Save and exit.

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

{% hint style="info" %}
Use `cmake --build build -j3` or `cmake --build build -jX` (replacing `X` with the desired number of build threads). Lower values reduce system load and temperature; higher values compile faster but use more CPU and memory.
{% endhint %}

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

* Enter the next command to install the new precompiled binaries for yourself on the OS:

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

More info: [bip110.org](https://bip110.org/)

This section is not necessary if you followed [Option 2: Compiling from source code](bitcoin-knots.md#option-2-compiling-from-source-code) and set `-DRDTS_CONSENT=IMPLICIT` in the [Build it from the source code](bitcoin-knots.md#build-it-from-the-source-code) section. You will see these logs at the start of Bitcoin Knots:

```
bitcoind[2563]: 2026-06-11T12:52:27Z User already consented to 'rdts' consensus rules (at installation)
```
{% endhint %}

* With the user admin, edit the `bitcoin.conf` file:

```bash
sudo nano /data/bitcoin/bitcoin.conf
```

* Add the following parameters to the end of the file. Save and exit.

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

* Add the following parameters to the end of the file. Save and exit.

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

### Slow device mode

* As user `admin` edit `bitcoin.conf` file:

```sh
sudo nano /home/bitcoin/.bitcoin/bitcoin.conf
```

* Add these lines at the end of the file:

<pre><code># Slow devices optimizations
## Limit the number of max peer connections
<a data-footnote-ref href="#user-content-fn-3">maxconnections</a>=40
## Tries to keep outbound traffic under the given target per 24h
<a data-footnote-ref href="#user-content-fn-4">maxuploadtarget</a>=5000
## Increase the number of threads to service RPC calls (default: 4)
rpcthreads=128
## Increase the depth of the work queue to service RPC calls (default: 16)
rpcworkqueue=256
</code></pre>

* Comment on these lines:

```
#coinstatsindex=1
#assumevalid=0
```

{% hint style="info" %}
Realize that with `maxuploadtarget` parameter enabled, you will need to whitelist the connection to [Electrs](../../bonus/bitcoin/electrs.md) and [Bisq](../../bonus/bitcoin/bisq.md) by adding these parameters to `bitcoin.conf`:

For Electrs:

```
whitelist=download@127.0.0.1
```

For Bisq:

```
whitelist=bloomfilter@192.168.0.0/16
```
{% endhint %}

### Renovate your Bitcoin Knots, Tor, and I2P addresses

* With user `admin`, stop bitcoind and dependencies:

```bash
sudo systemctl stop bitcoind
```

* Delete:

```bash
sudo rm /data/bitcoin/onion_v3_private_key && /data/bitcoin/i2p_private_key
```

* Start bitcoind again:

```bash
sudo systemctl start bitcoind
```

* If you want to monitor the bitcoind logs and the startup progress, type `journalctl -fu bitcoind` in a separate SSH session.
* Wait a minute to identify your newly generated addresses with:

{% code overflow="wrap" %}
```bash
bitcoin-cli getnetworkinfo | grep address.*onion && bitcoin-cli getnetworkinfo | grep address.*i2p
```
{% endcode %}

**Example** of expected output:

```
"address": "vctk9tie5srguvz262xpyukkd7g4z2xxxy5xx5ccyg4f12fzop8hoiad.onion",
"address": "sesehks6xyh31nyjldpyeckk3ttpanivqhrzhsoracwqjxtk3apgq.b32.i2p",
```

### The manual page for bitcoin-cli

* For convenience, it might be useful to have the manual page for `bitcoin-cli` on the same machine, so that they can be consulted offline, and they can be installed from the directory.

{% hint style="info" %}
Follow this section only if you followed [Option 1: Using precompiled binaries](bitcoin-knots.md#option-1-using-precompiled-binaries) and are coming from the [Extract](bitcoin-knots.md#extract) step; if you followed [Option 2: Compiling from source code](bitcoin-knots.md#option-2-compiling-from-source-code), this section is not needed because man pages are installed by default; type directly `man bitcoin-cli` command to see the man pages.
{% endhint %}

```sh
cd bitcoin-$VERSION/share/man/man1
```

```sh
gzip *
```

```sh
sudo cp * /usr/share/man/man1/
```

* Now you can read the docs while doing:

```sh
man bitcoin-cli
```

{% hint style="info" %}
Now come back to the section [Binaries installation](bitcoin-knots.md#binaries-installation) to continue with the Bitcoin Knots installation process, unless you followed [Option 2: Compiling from source code](bitcoin-knots.md#option-2-compiling-from-source-code).
{% endhint %}

### Generate a full bitcoin.conf example file

* Follow all [Installation](bitcoin-knots.md#installation) steps before installing the bitcoind binary on the operating system, regardless of whether you followed [Option 1: Use pre-compiled binaries](bitcoin-knots.md#option-1-using-precompiled-binaries) or [Option 2: Compile from source code](bitcoin-knots.md#option-2-compiling-from-source-code).
* With user `admin`, update and upgrade your OS. Press "y" and enter, or directly enter when the prompt asks you:

```bash
sudo apt update && sudo apt full-upgrade
```

* Install the next dependency packages:

```bash
sudo apt install build-essential cmake pkg-config --no-install-recommends
```

* Go to the temporary folder:

```bash
cd /tmp
```

* Set a temporary version environment variable for the installation:

```bash
VERSION=29.3.knots20260508
```

* Clone the source code from GitHub and enter the bitcoin folder:

```bash
git clone --branch v$VERSION https://github.com/bitcoinknots/bitcoin.git && cd bitcoin
```

* Build all Bitcoin Knots dependencies:

{% code overflow="wrap" %}
```bash
make -C depends HOST=x86_64-pc-linux-gnu -j$(nproc) NO_QR=1 NO_QT=1 NO_NATPMP=1 NO_UPNP=1 NO_USDT=1
```
{% endcode %}

* Pre-configuring the installation, we will discard some features and include others. Enter the complete next command in the terminal and press `ENTER`:

```bash
BITCOIN_GENBUILD_NO_GIT=1 cmake -B build \
  -DBUILD_TESTS=OFF \
  -DBUILD_TX=OFF \
  -DBUILD_UTIL=OFF \
  -DBUILD_WALLET_TOOL=OFF \
  -DINSTALL_MAN=OFF \
  -DWITH_ZMQ=ON \
  -DCMAKE_TOOLCHAIN_FILE=depends/x86_64-pc-linux-gnu/toolchain.cmake
```

* Copy-paste the bitcoind binary file existing on your OS to the source code folder:

```bash
cp /usr/local/bin/bitcoind /tmp/bitcoin/build/bin/
```

* Exec the `gen-bitcoin-conf` script to generate the file:

```bash
sudo ./contrib/devtools/gen-bitcoin-conf.sh
```

Expected output:

```
Generating example bitcoin.conf file in share/examples/
```

* Use `cat` to print it on the terminal to enable a copy-paste:

```bash
cat /tmp/bitcoin/share/examples/bitcoin.conf
```

* Or `nano` to examine the content:

```bash
nano /tmp/bitcoin/share/examples/bitcoin.conf
```

**(Optional)** Delete the `bitcoin` folder from the temporary folder:

{% code overflow="wrap" %}
```bash
cd ..
```
{% endcode %}

```bash
sudo rm -r /tmp/bitcoin
```

### Accelerate the IBD

If you already have another fully-synced MiniBolt node on your local network, connecting directly to it can greatly accelerate synchronization by bypassing Tor’s added latency and bandwidth constraints. Local connections offer lower latency and higher throughput, delivering data — such as blockchain history — more reliably while reducing potential connectivity issues.

{% hint style="info" %}
To get this, you will need a **full-sync** **MiniBolt** node on the same local network.
{% endhint %}

**On the full-sync local MiniBolt node:**

#### Configure Firewall

* Configure the firewall to allow incoming requests to Bitcoin Knots from anywhere:

{% code overflow="wrap" %}
```sh
sudo ufw allow 8333/tcp comment 'allow incoming connections to Bitcoin Knots from anywhere'
```
{% endcode %}

#### Configure Bitcoin Knots

To allow incoming connections from another node in the same local network, follow the next steps:

* With the user `admin`, edit the `bitcoin.conf` file:

```bash
sudo nano /data/bitcoin/bitcoin.conf
```

* **Replace** the `bind=127.0.0.1` line with the following to allow connections from anywhere:

<pre><code><strong>bind=0.0.0.0
</strong></code></pre>

Or **add** under `bind=127.0.0.1` the next line allows **connections only from devices in the same local network** (**recommended option** to improve security):

<pre><code>bind=<a data-footnote-ref href="#user-content-fn-5">192.168.x.x</a>
</code></pre>

{% hint style="info" %}
Remember to replace `192.168.x.x` with your MiniBolt local IP, e.g `192.168.1.43`.
{% endhint %}

* Restart Bitcoin Knots to apply changes:

```bash
sudo systemctl restart bitcoind
```

**On the new MiniBolt node:**

* With the user `admin`, edit the `bitcoin.conf` file:

```bash
sudo nano /data/bitcoin/bitcoin.conf
```

* Attaches and persists the connection **only** to the full-sync local MiniBolt node. Add the next line at the end of the file. Save and exit.

<pre><code> connect=<a data-footnote-ref href="#user-content-fn-6">&#x3C;localip></a>:8333
</code></pre>

{% hint style="info" %}
Remember to replace `<localip>` with the real node IP, e.g: `192.168.1.43`.
{% endhint %}

* Restart Bitcoin Knots to apply changes:

```bash
sudo systemctl restart bitcoind
```

#### Validation

{% hint style="info" %}
Pay attention to the Bitcoin Knots logs (`journalctl -fu bitcoind`), a similar log to this should appear at some point:

```
New outbound-full-relay v2 peer connected: version: 70016, blocks=76637, peer=260
```

-> You can also check this by typing this command:

```bash
bitcoin-cli -netinfo 4 | grep manual
```

**Example** of expected output:

```
out manual onion  2    209    240    5   12   49   99      1016        384 281 mdiwdyjucocysdvx5dk2iyo5wsav3ehyiggegzfk3ezfcce6nstp4nid.onion:8333  70016/Satoshi:28.1.0
out manual   i2p  1    401    939    1   49  418           1019        455 271 axxwcwzsqw42hjbpzupvffvdsjvniyt5apyt53sdxijqy6y6pdha.b32.i2p:0       70016/Satoshi:28.1.0
```
{% endhint %}

### Improve the reliability

Ensuring your node connects to high-uptime, reliable peers is essential for smooth synchronization, faster transaction propagation, and overall stability. By configuring the Bitcoin client with both onion and I2P addnode entries — especially using the trusted official MiniBolt project addresses — you create diverse and robust connection paths that help bypass latency and network issues, reducing the risk of disruptions while enhancing security and efficiency.

{% hint style="info" %}
To get this, you will need a **full-sync** node peer like the official MiniBolt project node (later, it is suggested).
{% endhint %}

#### Configure Bitcoin Knots

* With the user `admin`, edit the `bitcoin.conf` file:

```bash
sudo nano /data/bitcoin/bitcoin.conf
```

* Add at the end of the file the `onion` + `i2p` addresses of the desired peers that you want to add to improve the reliability of your Bitcoin Knots on MiniBolt. Save and exit.

<pre><code>addnode=&#x3C;<a data-footnote-ref href="#user-content-fn-7">abcdefg..............xyz.onion</a>>:8333
addnode=&#x3C;<a data-footnote-ref href="#user-content-fn-7">abcdefg..............xyz.b32</a>>.i2p:0
</code></pre>

{% hint style="info" %}
Remember to replace the `<abcdefg..............xyz.onion>` and `<abcdefg..............xyz.b32>` with the desired addresses of your node peer/s.

**-> Suggestion**: If you want, you can use the next official MiniBolt addresses:

```
addnode=xdtk6tie5srguvz262xpyukkd7m3z3vvvy5xx5ccyg5f64fzop6hoiad.onion:8333
addnode=etehks5xyh32nyjldpyeckk3nwpanivqhrzhsoracwqjxtk5apgq.b32.i2p:0
```
{% endhint %}

* Restart Bitcoin Knots to apply changes:

```bash
sudo systemctl restart bitcoind
```

#### Validation

{% hint style="info" %}
Pay attention to the Bitcoin Knots logs (`journalctl -fu bitcoind`), a similar log to this should appear at some point:

```
New manual v2 peer connected: version: 70016, blocks=79633, peer=4
```

-> You can also check this by typing this command:

```bash
bitcoin-cli -netinfo 4 | grep manual
```

**Example** of expected output:

```
out manual onion  2    209    240    5   12   49   99      1016        384 281 mdiwdyjucocysdvx5dk2iyo5wsav3ehyiggegzfk3ezfcce6nstp4nid.onion:8333 70016/Satoshi:28.1.0
out manual   i2p  1    401    939    1   49  418           1019        455 271 axxwcwzsqw42hjbpzupvffvdsjvniyt5apyt53sdxijqy6y6pdha.b32.i2p:0       70016/Satoshi:28.1.0
```
{% endhint %}

## Upgrade

The latest release can be found on the [GitHub page](https://github.com/bitcoinknots/bitcoin) of the Bitcoin Knots project. Always read the [RELEASE NOTES](https://github.com/bitcoinknots/bitcoin/tree/29.x-knots/doc/release-notes) first! When upgrading, there might be breaking changes or changes in the data structure that need special attention. REeplace the environment variables `"VERSION=x.xx"` and `"BRANCH="x.xx"` values for the latest version and branch, if they have not already been changed in this guide.

**-> 2 options depending on your case:**

#### Case you followed [Option 1: Using precompiled binaries](bitcoin-knots.md#option-1-using-precompiled-binaries)

* Go to the temporary folder:

```bash
cd /tmp
```

* Set the following environment variables:

```sh
VERSION=29.3.knots20260508 && BRANCH=29.x
```

* Get the latest binaries and signatures:

{% code overflow="wrap" %}
```bash
wget https://bitcoinknots.org/files/$BRANCH/$VERSION/bitcoin-$VERSION-x86_64-linux-gnu.tar.gz
```
{% endcode %}

```sh
wget https://bitcoinknots.org/files/$BRANCH/$VERSION/SHA256SUMS
```

```sh
wget https://bitcoinknots.org/files/$BRANCH/$VERSION/SHA256SUMS.asc
```

* Check that the reference checksum in the file `SHA256SUMS` matches the checksum calculated by you:

```sh
sha256sum --ignore-missing --check SHA256SUMS
```

**Example** of expected output:

```
bitcoin-28.1.knots20250305.tar.gz: OK
```

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

* Restart Bitcoin Knots to apply the new version:

```bash
sudo systemctl restart bitcoind
```

* Monitor the systemd journal and check the logging output. You can exit monitoring at any time with `Ctrl+C` and continue:

```bash
journalctl -fu bitcoind
```

{% hint style="info" %}
If you want to signal support for the RDTS (BIP110) soft fork, follow the [Enable RDTS (BIP110) consensus rules](bitcoin-knots.md#enable-rdts-bip110-consensus-rules) extra section.

More info: [bip110.org](https://bip110.org/)
{% endhint %}

#### Case you followed [Option 2: Compiling from source code](bitcoin-knots.md#option-2-compiling-from-source-code)

* Login as `admin` user and change to the temporary directory:

```sh
cd /tmp
```

* Set the following environment variables:

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

* Check that the reference checksum in the file `SHA256SUMS` matches the checksum calculated by you:

```sh
sha256sum --ignore-missing --check SHA256SUMS
```

**Example** of expected output:

```
bitcoin-28.1.knots20250305.tar.gz: OK
```

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

* Pre-configure the installation; we will discard some features and include others. Enter the complete command below in the terminal and press `Enter`:

{% hint style="info" %}
Enable the RDTS (BIP110) consensus rules in Bitcoin Knots to participate in the deployment and enforce the new reduced-data transaction validation rules once activated by the network.

More info: [bip110.org](https://bip110.org/)

-> Change `-DRDTS_CONSENT=RUNTIME_WARN` to `-DRDTS_CONSENT=IMPLICIT` to assume consent at build time, enabling RDTS without runtime prompts or checks.
{% endhint %}

<pre class="language-sh"><code class="lang-sh">BITCOIN_GENBUILD_NO_GIT=1 cmake -B build \
  -DBUILD_TESTS=OFF \
  -DBUILD_TX=OFF \
  -DBUILD_UTIL=OFF \
  -DBUILD_WALLET_TOOL=OFF \
  -DINSTALL_MAN=OFF \
  -DWITH_ZMQ=ON \
  -DRDTS_CONSENT=<a data-footnote-ref href="#user-content-fn-2">RUNTIME_WARN</a> \
  -DCMAKE_TOOLCHAIN_FILE=depends/x86_64-pc-linux-gnu/toolchain.cmake
</code></pre>

**Apply the UA patch (optional)**

{% hint style="info" %}
This patch removes the Bitcoin Knots reference from the **user agent** to make it look like Bitcoin Core, improving its censorship resistance.
{% endhint %}

{% hint style="info" %}
Skip this step if you only want to **build Bitcoin Knots from the source code** and not apply the user agent patch.
{% endhint %}

* Create the UA patch:

```sh
nano mod-ua-knots.patch
```

* Enter the following content. Save and exit.

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

* Enter the command to compile:

{% hint style="info" %}
Use `cmake --build build -j3` or `cmake --build build -jX` (replacing `X` with the desired number of build threads). Lower values reduce system load and temperature; higher values compile faster but use more CPU and memory.
{% endhint %}

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
[...]
```

</details>

{% hint style="info" %}
This process can take quite **a long time**, 10-15 minutes or more, depending on the performance of your device. Please be patient until the prompt shows again. You can use [Tmux](https://github.com/tmux/tmux) to leave it in the background.
{% endhint %}

* Enter the next command to install the new precompiled binaries for yourself on the OS:

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

* Restart Bitcoin Knots to apply the new version:

```bash
sudo systemctl restart bitcoind
```

* Monitor the systemd journal and check the logging output. You can exit monitoring at any time with `Ctrl+C` and continue:

```bash
journalctl -fu bitcoind
```

## Uninstall

{% hint style="danger" %}
Warning: This section removes the installation. Run these commands only if you intend to uninstall.
{% endhint %}

{% hint style="info" %}
To uninstall Bitcoin Knots, follow the entire [Bitcoin Client: Bitcoin Core uninstall section](../../bitcoin/bitcoin/bitcoin-client.md#uninstall).
{% endhint %}

## Port reference

Same as the [Bitcoin Client: Bitcoin Core section](../../bitcoin/bitcoin/bitcoin-client.md#port-reference).

[^1]: Check this

[^2]: Change to IMPLICIT to assume consent at build time, enabling RDTS without runtime prompts or checks.

[^3]: Default 125 connections to different peers, 11 of which are outbound. You can therefore, have at most 114 inbound connections. Of the 11 outbound peers, there can be 8 full-relay connections, 2 block-relay-only ones and occasionally 1 short-lived feeler or an extra block-relay-only connection.

[^4]: This option can be specified in MiB per day and is turned off by default. \<MiB per day>

[^5]: Replace with your IP

[^6]: Replace with the local IP of the remote node e.g, `192.168.1.43`

[^7]: Replace with the desire address of the peer
