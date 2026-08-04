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

{% hint style="info" %}
If you are not ready to adopt the RDTS upgrade yet, you can alternatively download this same version of Bitcoin Knots without RDTS support (NOT RECOMMENDED), by setting these environment variables instead:

```bash
VERSION=29.3.knots20260507 && BRANCH=29.x
```

-> More info: [bip110.org](https://bip110.org/)<br>

These logs will appear every hour to notify you; if you know what you're doing, you can ignore them:

```
[...]
bitcoind[172990]: 2026-06-27T14:44:15Z [error] This version does not support the upcoming BIP110/RDTS network upgrade, and is therefore vulnerable to displaying fake or fraudulent transactions.
bitcoind[172990]: 2026-06-27T14:44:15Z [error] For more information, see: https://bitcoinknots.org/learn/2026-rdts
bitcoind[172990]: 2026-06-27T14:44:15Z [error] To adopt this upgrade and remain secure, please update Bitcoin Knots: https://bitcoinknots.org/
[...]
```
{% endhint %}

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

* Import the updated Luke Dashjr GPG key from the keyserver

{% code overflow="wrap" %}
```bash
gpg --recv-keys 1A3E761F19D2CC7785C5502EA291A2C45D0C504A
```
{% endcode %}

Expected output:

{% code overflow="wrap" %}
```
gpg: key A291A2C45D0C504A: "Luke Dashjr (Codesigning) <luke-jr+git@utopios.org>" 3 new signatures
gpg: Total number processed: 1
gpg:         new signatures: 3
```
{% endcode %}

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
Accept RDTS (BIP110) in Bitcoin Knots and acknowledge running a build that implements the RDTS upgrade by following the [Accept RDTS (BIP110) consensus rules](bitcoin-knots.md#accept-rdts-bip110-consensus-rules) extra section.

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

{% hint style="info" %}
If you are not ready to adopt the RDTS upgrade yet, you can alternatively download this same version of Bitcoin Knots without RDTS support (NOT RECOMMENDED) by setting these environment variables instead:

```bash
VERSION=29.3.knots20260507 && BRANCH=29.x
```

More info: [bip110.org](https://bip110.org/)
{% endhint %}

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

* Import the updated Luke Dashjr GPG key from the keyserver

{% code overflow="wrap" %}
```bash
gpg --recv-keys 1A3E761F19D2CC7785C5502EA291A2C45D0C504A
```
{% endcode %}

Expected output:

{% code overflow="wrap" %}
```
gpg: key A291A2C45D0C504A: "Luke Dashjr (Codesigning) <luke-jr+git@utopios.org>" 3 new signatures
gpg: Total number processed: 1
gpg:         new signatures: 3
```
{% endcode %}

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
Accept RDTS (BIP110) in Bitcoin Knots and acknowledge running a build that implements the RDTS upgrade, which will follow the network’s activation of the new reduced-data transaction validation rules.

More info: [bip110.org](https://bip110.org/)

-> **(Recommended)** Change `-DRDTS_CONSENT=RUNTIME_WARN` to `-DRDTS_CONSENT=IMPLICIT` to assume consent at build time, enabling RDTS without runtime prompts or checks, and avoiding following the [Accept RDTS (BIP110) consensus rules](bitcoin-knots.md#accept-rdts-bip110-consensus-rules) extra section. The associated log with this action at the start of Bitcoin Knots is the following:

<pre><code><strong>[...]
</strong><strong>bitcoind[1018092]: 2026-06-27T17:22:29Z User already consented to 'rdts' consensus rules (at installation)
</strong><strong>[...]
</strong></code></pre>

-> Remember to remove this line completely so as not to adopt the RDTS upgrade yet, selecting the previous Knots version in the [Installation](bitcoin-knots.md#installation-1) steps.
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
Accept RDTS (BIP110) in Bitcoin Knots and acknowledge running a build that implements the RDTS upgrade by following the [Accept RDTS (BIP110) consensus rules](bitcoin-knots.md#accept-rdts-bip110-consensus-rules) extra section.

More info: [bip110.org](https://bip110.org/)
{% endhint %}

### Create the bitcoin user & group

The Bitcoin Knots application will run in the background as a daemon and use the separate user “bitcoin” for security reasons. This user does not have admin rights and cannot change the system configuration.

* Create the `bitcoin` user and group:

```bash
sudo adduser --gecos "" --disabled-password bitcoin
```

* Add the user `admin` to the group "bitcoin":

```bash
sudo adduser admin bitcoin
```

* Allow the user `bitcoin` to use the control port and configure Tor directly by adding it to the `debian-tor` group:

```bash
sudo adduser bitcoin debian-tor
```

### Create data folder

Bitcoin Knots uses, by default, the folder `.bitcoin` in the user's home. Instead of creating this directory, we create a data directory in the general data location `/data` and link to it.

* Create the Bitcoin data folder:

```sh
mkdir /data/bitcoin
```

* Assign the owner to the `bitcoin` user:

```sh
sudo chown bitcoin:bitcoin /data/bitcoin
```

* Switch to the user `bitcoin:`

```sh
sudo su - bitcoin
```

* Create the symbolic link `.bitcoin` that points to that directory:

```sh
ln -s /data/bitcoin /home/bitcoin/.bitcoin
```

* Check that the symbolic link has been created correctly:

```bash
ls -la .bitcoin
```

Expected output:

<pre><code>lrwxrwxrwx 1 bitcoin bitcoin   13 Nov  7 19:32 <a data-footnote-ref href="#user-content-fn-1">.bitcoin -> /data/bitcoin</a>
</code></pre>

### Generate access credentials

For other programs to query Bitcoin Knots, they need the proper access credentials. To avoid storing the username and password in a configuration file in plaintext, the password is hashed. This allows Bitcoin Knots to accept a password, hash it, and compare it to the stored hash, while it is not possible to retrieve the original password.

Another option to get access credentials is through the `.cookie` file in the Bitcoin data directory. This is created automatically and can be read by all users who are members of the "bitcoin" group.

Bitcoin Knots provides a simple Python program to generate the configuration line for the config file.

* Enter the bitcoin folder:

```sh
cd .bitcoin
```

* Download the RPCAuth program:

{% code overflow="wrap" %}
```sh
wget https://raw.githubusercontent.com/bitcoin/bitcoin/master/share/rpcauth/rpcauth.py
```
{% endcode %}

* Run the script with the Python3 interpreter, providing the username (`minibolt`) and your `"password [B]"` arguments:

{% hint style="warning" %}
All commands entered are stored in the bash history. But we don't want the password to be stored where anyone can find it. For this, put a space `( )` in front of the command shown below.
{% endhint %}

<pre class="language-sh"><code class="lang-sh"> python3 rpcauth.py minibolt <a data-footnote-ref href="#user-content-fn-3">YourPasswordB</a>
</code></pre>

**Example** of expected output:

<pre><code>String to be appended to bitcoin.conf:
<a data-footnote-ref href="#user-content-fn-4">rpcauth=minibolt:00d8682ce66c9ef3dd9d0c0a6516b10e$c31da4929b3d0e092ba1b2755834889f888445923ac8fd69d8eb73efe0699afa</a>
</code></pre>

* Copy the `rpcauth` line; we'll need to paste it into the Bitcoin Knots config file in the next step.

## Configuration

Now, the configuration file `bitcoind` needs to be created. We'll also set the proper access permissions.

* Still as the user `"bitcoin"` creates the `bitcoin.conf` file:

```bash
nano /home/bitcoin/.bitcoin/bitcoin.conf
```

* Enter the complete configuration below. Save and exit.

{% hint style="danger" %}
**Important!!** Remember to replace the whole line starting with `"rpcauth"` the connection string you just generated
{% endhint %}

{% hint style="warning" %}
Remember to accommodate the "`dbcache`" parameter depending on your hardware. Recommended: dbcache=1/2 x total RAM available, e.g: 4GB RAM -> dbcache=2048.
{% endhint %}

{% hint style="info" %}
**(Optional):**

**-> If you want** to reject other possible data included in transactions apart from **the previous Ordisrespector patch**, follow [the dedicated extra section](bitcoin-knots.md#reject-other-possible-data-included-in-transactions), and continue with the next step.

-> Modify the `"uacomment"` value to your preference if you want.

-> If you have another **full-synced MiniBolt node on the same local network**, you can **accelerate the IBD** by following [the dedicated extra section](bitcoin-knots.md#accelerate-the-ibd).
{% endhint %}

<pre><code># MiniBolt: bitcoind configuration
# /data/bitcoin/bitcoin.conf

# Bitcoin daemon
server=1
txindex=1

# Set OP_RETURN limit to value before v30.0
datacarriersize=83

# Disable cjdns network
onlynet=onion
onlynet=i2p
onlynet=ipv4
onlynet=ipv6

# Append comment to the user agent string
uacomment=<a data-footnote-ref href="#user-content-fn-5">MiniBolt node</a>

# Disable integrated wallet
disablewallet=1

# Additional logs
debug=tor
debug=i2p
## Include peers IP addresses in log output (optional)
<a data-footnote-ref href="#user-content-fn-6">logips=1</a>

# Assign read permission to the Bitcoin group users to the cookie file
rpccookieperms=group

# Disable debug.log
nodebuglogfile=1

# Avoid assuming that a block and its ancestors are valid,
# and potentially skipping their script verification.
# We will set it to 0 to verify all.
assumevalid=0

# Enable all compact filters
blockfilterindex=1

# Serve compact block filters to peers per BIP 157
peerblockfilters=1

# Maintain the coinstats index used by the gettxoutsetinfo RPC
coinstatsindex=1

# Network
listen=1

## P2P bind
bind=127.0.0.1
bind=127.0.0.1=onion

## Proxify clearnet outbound connections using Tor SOCKS5 proxy
proxy=127.0.0.1:9050

## I2P SAM proxy to reach I2P peers and accept I2P connections
i2psam=127.0.0.1:7656

# Connections
<a data-footnote-ref href="#user-content-fn-7">rpcauth=&#x3C;replace with your own auth line generated in the previous step></a>

# Initial block download optimizations
dbcache=<a data-footnote-ref href="#user-content-fn-8">2048</a>
blocksonly=1
</code></pre>

{% hint style="info" %}
This is a standard configuration. Check this [Bitcoin Knots sample bitcoind.conf](https://github.com/bitcoinknots/bitcoin/blob/29.x-knots/share/examples/bitcoin.conf) file with all possible options, or generate one yourself, following the proper [extra section](bitcoin-knots.md#generate-a-full-bitcoin.conf-example-file).
{% endhint %}

* Set permissions so only the user `bitcoin` and members of the `bitcoin` group can read it (needed for LND to read the "`rpcauth`" line):

```sh
chmod 640 /home/bitcoin/.bitcoin/bitcoin.conf
```

* Exit the `bitcoin` user session and return to the user `admin`:

{% code fullWidth="false" %}
```sh
exit
```
{% endcode %}

### Create systemd service

The system needs to run the bitcoin daemon automatically in the background. We use `systemd`, a daemon that controls the startup process using configuration files.

* Create the systemd configuration:

```bash
sudo nano /etc/systemd/system/bitcoind.service
```

* Enter the complete configuration below. Save and exit.

```
# MiniBolt: systemd unit for bitcoind
# /etc/systemd/system/bitcoind.service

[Unit]
Description=Bitcoin Knots Daemon
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/local/bin/bitcoind -pid=/run/bitcoind/bitcoind.pid \
                                  -conf=/home/bitcoin/.bitcoin/bitcoin.conf \
                                  -datadir=/home/bitcoin/.bitcoin \
                                  -startupnotify='systemd-notify --ready' \
                                  -shutdownnotify='systemd-notify --status="Stopping"'
# Process management
####################
Type=notify
NotifyAccess=all
PIDFile=/run/bitcoind/bitcoind.pid

Restart=on-failure
TimeoutStartSec=infinity
TimeoutStopSec=600

# Directory creation and permissions
####################################
User=bitcoin
Group=bitcoin
RuntimeDirectory=bitcoind
RuntimeDirectoryMode=0710
UMask=0027

# Hardening measures
####################
PrivateTmp=true
ProtectSystem=full
NoNewPrivileges=true
PrivateDevices=true
MemoryDenyWriteExecute=true
SystemCallArchitectures=native

[Install]
WantedBy=multi-user.target
```

* Enable autoboot **(optional):**

```sh
sudo systemctl enable bitcoind
```

* Prepare `bitcoind` monitoring by the systemd journal and check the logging output. You can exit monitoring at any time with `Ctrl-C`.

```sh
journalctl -fu bitcoind
```

{% hint style="info" %}
Keep **this terminal open;** you'll need to come back here on the next step to monitor the logs.
{% endhint %}

## Run

To keep an eye on the software movements, [start your SSH program](../../index-1/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`

* Start the service:

```sh
sudo systemctl start bitcoind
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>journalctl -fu bitcoind</code> ⬇️</summary>

<pre><code>2022-11-24T18:08:04Z Bitcoin Knots version v29.3.knots20260508 (release build)
2022-11-24T18:08:04Z InitParameterInteraction: parameter interaction: -proxy set -> setting -upnp=0
2022-11-24T18:08:04Z InitParameterInteraction: parameter interaction: -proxy set -> setting -natpmp=0
2022-11-24T18:08:04Z InitParameterInteraction: parameter interaction: -proxy set -> setting -discover=0
2022-11-24T18:08:04Z Using the 'sse4(1way),sse41(4way),avx2(8way)' SHA256 implementation
2022-11-24T18:08:04Z Using RdRand as an additional entropy source
2022-11-24T18:08:04Z Default data directory /home/bitcoin/.bitcoin
2022-11-24T18:08:04Z Using data directory /home/bitcoin/.bitcoin
2022-11-24T18:08:04Z Config file: /home/bitcoin/.bitcoin/bitcoin.conf
<strong>2022-11-24T18:08:04Z Config file arg: blockfilterindex="1"
</strong>2022-11-24T18:08:04Z Config file arg: coinstatsindex="1"
2022-11-24T18:08:04Z Config file arg: i2pacceptincoming="1"
2022-11-24T18:08:04Z Config file arg: i2psam="127.0.0.1:7656"
2022-11-24T18:08:04Z Config file arg: listen="1"
2022-11-24T18:08:04Z Config file arg: listenonion="1"
2022-11-24T18:08:04Z Config file arg: peerblockfilters="1"
2022-11-24T18:08:04Z Config file arg: peerbloomfilters="1"
2022-11-24T18:08:04Z Config file arg: proxy="127.0.0.1:9050"
2022-11-24T18:08:04Z Config file arg: rpcauth=****
2022-11-24T18:08:04Z Config file arg: server="1"
2022-11-24T18:08:04Z Config file arg: txindex="1"
[...]
2022-11-24T18:09:04Z Synchronizing blockheaders, height: 4000 (~0.56%)
[...]
</code></pre>

</details>

{% hint style="info" %}
Monitor the log file for a few minutes to see if it works. Logs like the next indicate that the initial start-up process has been successful:

```
New block-relay-only v1 peer connected: version: 70016, blocks=2948133, peer=68
[..]
Synchronizing blockheaders, height: 4000 (~0.56%)
[..]
UpdateTip: new best=000000000f8d29fcf9ac45e443706c6f21a6e9cfa615f94794b726d3ba8bdc88 height=2948135 version=0x20000000 log2_work=75.951200 tx=215155316 date='2024-09-18T16:25:12Z' progress=1.000000 cache=20.9MiB(142005txo)
[..]
```
{% endhint %}

* Link the Bitcoin data directory from the `admin` user's home directory as well. This allows `admin` user to work with bitcoind directly, for example, by using the command `bitcoin-cli`:

```sh
ln -s /data/bitcoin /home/admin/.bitcoin
```

* This symbolic link becomes active **only in a new user session**. Log out of SSH by entering the next command:

```sh
exit
```

* Log in again as a user `admin` [opening a new SSH session](../../index-1/remote-access.md#access-with-secure-shell).
* Check that the symbolic link has been created correctly:

```bash
ls -la .bitcoin
```

Expected output:

<pre><code>lrwxrwxrwx 1 admin admin    13 Nov  7 10:41 <a data-footnote-ref href="#user-content-fn-9">.bitcoin -> /data/bitcoin</a>
</code></pre>

{% hint style="warning" %}
**Troubleshooting note:**\
\
If you don't obtain the expected output ([`.bitcoin -> /data/bitcoin`](#user-content-fn-9)[^9]) and you only have (`.bitcoin`), you must follow the next steps to fix that:

1. With user `admin`, delete the failed created symbolic link:

```bash
sudo rm -r .bitcoin
```

2. Create the symbolic link again:

```bash
ln -s /data/bitcoin /home/admin/.bitcoin
```

3. Check the symbolic link has been created correctly this time, and you now have the expected output: [.bitcoin -> /data/bitcoin](#user-content-fn-9)[^9]. If yes, continue with the guide; if not, try again:

```bash
ls -la .bitcoin
```

Expected output:

<pre><code>lrwxrwxrwx 1 admin admin    13 Nov  7 10:41 <a data-footnote-ref href="#user-content-fn-1">.bitcoin -> /data/bitcoin</a>
</code></pre>
{% endhint %}

* Wait a few minutes until Bitcoin Knots starts, and enter the next command to obtain your Tor and I2P addresses. **Take note of them**; later you might need them:

{% code overflow="wrap" %}
```sh
bitcoin-cli getnetworkinfo | grep address.*onion && bitcoin-cli getnetworkinfo | grep address.*i2p
```
{% endcode %}

**Example** of expected output:

```
"address": "vctk9tie5srguvz262xpyukkd7g4z2xxxy5xx5ccyg4f12fzop8hoiad.onion",
"address": "sesehks6xyh31nyjldpyeckk3ttpanivqhrzhsoracwqjxtk3apgq.b32.i2p",
```

### Validation

* Check the correct enablement of the I2P and Tor networks:

```sh
bitcoin-cli -netinfo
```

**Example** of expected output:

```
Bitcoin Knots client v29.3.knots20260508 - server 70016/Satoshi:24.0.1/
          ipv4    ipv6   onion   i2p   total   block
in          0       0      25     2      27
out         7       0       2     1      10       2
total       7       0      27     3      37

Local addresses
xdtk6tie4srguvz566xpyukkd7m3z3vbby5xx5ccyg5f64fzop7hoiab.onion     port   8333    score      4
etehks3xyh55nyjldjdeckk3nwpanivqhrzhsoracwqjxtk8apgk.b32.i2p       port      0    score      4
```

* Ensure bitcoind is listening on the default RPC & P2P ports:

```bash
sudo ss -tulpn | grep bitcoind
```

Expected output:

<pre><code>tcp   LISTEN 0      128        127.0.0.1:<a data-footnote-ref href="#user-content-fn-10">8332</a>       0.0.0.0:*    users:(("bitcoind",pid=773834,fd=11))
tcp   LISTEN 0      4096       127.0.0.1:<a data-footnote-ref href="#user-content-fn-11">8333</a>       0.0.0.0:*    users:(("bitcoind",pid=773834,fd=46))
tcp   LISTEN 0      4096       127.0.0.1:<a data-footnote-ref href="#user-content-fn-12">8334</a>       0.0.0.0:*    users:(("bitcoind",pid=773834,fd=44))
tcp   LISTEN 0      128            [::1]:8332          [::]:*    users:(("bitcoind",pid=773834,fd=10))
</code></pre>

* Please note:
  * When “bitcoind” is still starting, you may get an error message like “verifying blocks”. That’s normal; just give it a few minutes.
  * Among other info, the “verificationprogress” is shown. Once this value reaches almost 1 or near (0.999…), the blockchain is up-to-date and fully validated.

## Bitcoin Knots is syncing

{% hint style="info" %}
This process is called IBD (Initial Block Download). This can take between one day and a week, depending mostly on your PC performance. It's best to wait until the synchronization is complete before going ahead.
{% endhint %}

### Explore bitcoin-cli

If everything is running smoothly, this is the perfect time to familiarize yourself with Bitcoin, the technical aspects of Bitcoin Knots, and play around with `bitcoin-cli` it until the blockchain is up-to-date.

* [The Little Bitcoin Book](https://littlebitcoinbook.com) is a fantastic introduction to Bitcoin, focusing on the "why" and less on the "how."
*   [Mastering Bitcoin](https://bitcoinbook.info) by Andreas Antonopoulos is a great point to start, especially chapter 3 (ignore the first part, how to compile from source code):

    * You definitely need to have a [real copy](https://bitcoinbook.info/) of this book!
    * Read it online on [GitHub](https://github.com/bitcoinbook/bitcoinbook).

    <figure><img src="../../.gitbook/assets/30_mastering_bitcoin_book.jpg" alt=""><figcaption></figcaption></figure>
* [Learning Bitcoin from the Command Line](https://github.com/ChristopherA/Learning-Bitcoin-from-the-Command-Line/blob/master/README.md) by Christopher Allen gives a thorough deep dive into understanding the technical aspects of Bitcoin.
* Also, check out the [bitcoin-cli reference](https://en.bitcoin.it/wiki/Original_Bitcoin_client/API_calls_list).

## Activate mempool & reduce 'dbcache' after a full sync

Once Bitcoin Knots **is fully synced**, we can reduce the size of the database cache. A bigger cache speeds up the initial block download now. We want to reduce memory consumption to allow the Lightning client and Electrum server to run in parallel. We also now want to enable the node to listen to and relay transactions.

{% hint style="info" %}
Bitcoin Knots will then just use the default cache size of 450 MiB instead of your RAM setup. If `blocksonly=1` is left uncommented, it will prevent Electrum Server from receiving RPC fee data and will not work.
{% endhint %}

* As user `admin`, edit the `bitcoin.conf` file:

```sh
sudo nano /home/bitcoin/.bitcoin/bitcoin.conf
```

* Comment or delete the following lines by adding a `#` at the beginning. Save and exit.

```
#dbcache=2048
#blocksonly=1
```

* Restart Bitcoin Knots for the settings to take effect:

```sh
sudo systemctl restart bitcoind
```

## Extras (optional)

### Accept RDTS (BIP110) consensus rules

{% hint style="info" %}
Accept RDTS (BIP110) in Bitcoin Knots and acknowledge running a build that implements the RDTS upgrade, which will follow the network’s activation of the new reduced-data transaction validation rules.

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
# Accept BIP110/RDTS consensus rules
consensusrules=rdts
```
{% endcode %}

* Restart Bitcoin Knots to apply changes:

```bash
sudo systemctl restart bitcoind
```

{% hint style="info" %}
You will see this log in `journalctl -fu bitcoind` logs:

<pre><code><strong>[...]
</strong><strong>2026-06-29T01:53:59Z User already consented to 'rdts' consensus rules (in config)
</strong><strong>[...]
</strong></code></pre>
{% endhint %}

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
<a data-footnote-ref href="#user-content-fn-13">maxconnections</a>=40
## Tries to keep outbound traffic under the given target per 24h
<a data-footnote-ref href="#user-content-fn-14">maxuploadtarget</a>=5000
## Increase the number of threads to service RPC calls (default: 4)
rpcthreads=128
## Increase the depth of the work queue to service RPC calls (default: 16)
rpcworkqueue=256
</code></pre>

* Comment out these lines:

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
  -DRDTS_CONSENT=RUNTIME_WARN \
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

<pre><code>bind=<a data-footnote-ref href="#user-content-fn-15">192.168.x.x</a>
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

<pre><code> connect=<a data-footnote-ref href="#user-content-fn-16">&#x3C;localip></a>:8333
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

<pre><code>addnode=&#x3C;<a data-footnote-ref href="#user-content-fn-17">abcdefg..............xyz.onion</a>>:8333
addnode=&#x3C;<a data-footnote-ref href="#user-content-fn-17">abcdefg..............xyz.b32</a>>.i2p:0
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

The latest release can be found on the [GitHub page](https://github.com/bitcoinknots/bitcoin) of the Bitcoin Knots project. Always read the [RELEASE NOTES](https://github.com/bitcoinknots/bitcoin/tree/29.x-knots/doc/release-notes) first! When upgrading, there might be breaking changes or changes in the data structure that need special attention. Replace the environment variables `"VERSION=x.xx"` and `"BRANCH="x.xx"` values for the latest version and branch, if they have not already been changed in this guide.

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
Bitcoin Knots RPC client version v29.3.knots20260508
Copyright (C) 2009-2026 The Bitcoin Knots developers
Copyright (C) 2009-2026 The Bitcoin Core developers

Please contribute if you find Bitcoin Knots useful. Visit
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
  -DRDTS_CONSENT=<a data-footnote-ref href="#user-content-fn-18">RUNTIME_WARN</a> \
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

### Uninstall service

* Ensure you are logged in as the user `admin`, stop bitcoind:

```bash
sudo systemctl stop bitcoind
```

* Disable autoboot (if enabled):

```bash
sudo systemctl disable bitcoind
```

* Delete the service:

```bash
sudo rm /etc/systemd/system/bitcoind.service
```

### Delete user & group

* Delete bitcoin user's group:

{% code overflow="wrap" %}
```bash
sudo gpasswd -d admin bitcoin; sudo gpasswd -d fulcrum bitcoin; sudo gpasswd -d lnd bitcoin; sudo gpasswd -d btcrpcexplorer bitcoin; sudo gpasswd -d btcpay bitcoin
```
{% endcode %}

* Delete the `bitcoin` user. Don't worry about `userdel: bitcoin mail spool (/var/mail/bitcoin) not found` output; the uninstall has been successful:

```bash
sudo userdel -rf bitcoin
```

* Delete the bitcoin group:

```bash
sudo groupdel bitcoin
```

### Delete data directory

* Delete the complete `bitcoin` directory:

```bash
sudo rm -rf /data/bitcoin/
```

### Uninstall binaries

* Delete the installed binaries:

```bash
sudo rm /usr/local/bin/bitcoin-cli && sudo rm /usr/local/bin/bitcoind
```

### Uninstall FW configuration

If you followed the [Accelerate the IBD](bitcoin-knots.md#accelerate-the-ibd) section or the [Bisq bonus guide](../../bonus/bitcoin/bisq.md), you needed to add an allow rule on UFW to allow the incoming connection to the `8333` port (P2P).

* Ensure you are logged in as the user `admin`, display the UFW firewall rules, and note the numbers of the rules for Bitcoin Core (e.g. "Y" below):

```bash
sudo ufw status numbered
```

Expected output:

```
[Y] 8333       ALLOW IN    Anywhere            # allow Bitcoin Knots P2P from anywhere
```

{% hint style="info" %}
If you don't have any rule matched with this, you don't have to do anything; you are OK.
{% endhint %}

* Delete the rule with the correct number and confirm by typing "`yes`" and enter:

```bash
sudo ufw delete X
```

## Port reference

<table><thead><tr><th align="center">Port</th><th width="100">Protocol<select><option value="ukHb12cRZxp1" label="TCP" color="blue"></option><option value="Xd1yhX3dgwCx" label="SSL" color="blue"></option><option value="DxH2k0YKIhG7" label="UDP" color="blue"></option></select></th><th align="center">Use</th></tr></thead><tbody><tr><td align="center">8332</td><td><span data-option="ukHb12cRZxp1">TCP</span></td><td align="center">Default Bitcoin Knots RPC port</td></tr><tr><td align="center">8333</td><td><span data-option="ukHb12cRZxp1">TCP</span></td><td align="center">Default Bitcoin Knots P2P port</td></tr><tr><td align="center">8334</td><td><span data-option="ukHb12cRZxp1">TCP</span></td><td align="center">Default Bitcoin Knots P2P Tor port</td></tr></tbody></table>

[^1]: Check this

[^2]: Change to IMPLICIT to assume consent at build time, enabling RDTS without runtime prompts or checks. Remember to remove this line completely so as not to adopt the RDTS upgrade yet, selecting the previous Knots version in the [Installation](bitcoin-knots.md#installation-1) steps.

[^3]: Replace

[^4]: Copy this

[^5]: Change for your selection if you want

[^6]: (Optional)

[^7]: Replace with the content copied in the previous step

[^8]: -> Set `dbcache` size in MiB (min 4, default: 450) according to the available RAM of your device.

    -> Recommended: dbcache=1/2 x RAM available e.g: 4GB RAM -> dbcache=2048

    -> Remember to comment or delete this parameter after IBD (Initial Block Download)

[^9]: Symbolic link

[^10]: RPC port

[^11]: P2P main port

[^12]: Default P2P Tor port

[^13]: Default 125 connections to different peers, 11 of which are outbound. You can therefore, have at most 114 inbound connections. Of the 11 outbound peers, there can be 8 full-relay connections, 2 block-relay-only ones and occasionally 1 short-lived feeler or an extra block-relay-only connection.

[^14]: This option can be specified in MiB per day and is turned off by default. \<MiB per day>

[^15]: Replace with your IP

[^16]: Replace with the local IP of the remote node e.g, `192.168.1.43`

[^17]: Replace with the desire address of the peer

[^18]: Change to IMPLICIT to assume consent at build time, enabling RDTS without runtime prompts or checks.
