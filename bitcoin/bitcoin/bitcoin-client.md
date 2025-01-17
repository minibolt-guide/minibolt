---
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

# 2.1 Bitcoin client: Bitcoin Core

We install [Bitcoin Core](https://bitcoin.org/en/bitcoin-core/), the reference client implementation of the Bitcoin network.

![](../../images/bitcoin-core-logo-trans.png)

## This may take some time

Bitcoin Core will download the full Bitcoin blockchain, and validate all transactions since 2009. We're talking more than 800'000 blocks with a size of over 465 GB, so this is not an easy task.

## Installation

We download the latest Bitcoin Core binary (the application) and compare this file with the signed and timestamped checksum. This is a precaution to make sure that this is an official release and not a malicious version trying to steal our money.

💡 If you want to install the Ordisrespector patch to reject the Ordinals of your mempool, follow the [Ordisrespector bonus guide](../../bonus/bitcoin/ordisrespector.md) and come back to continue with the ["Create the bitcoin user"](bitcoin-client.md#create-the-bitcoin-user-and-group) section.

💡 If you want to install Bitcoin Core from the source code but without the Ordisrespector patch, follow the [Ordisrespector bonus guide](../../bonus/bitcoin/ordisrespector.md) skipping [Apply the patch “Ordisrespector”](../../bonus/bitcoin/ordisrespector.md#apply-the-ordisrespector-patch) and come back to continue with the ["Create the bitcoin user"](bitcoin-client.md#create-the-bitcoin-user-and-group) section.

### Download binaries

* Login as `admin` and change to a temporary directory which is cleared on reboot

```sh
cd /tmp
```

* Set a temporary version environment variable to the installation

```sh
VERSION=28.1
```

* Get the latest binaries and signatures

{% code overflow="wrap" %}
```sh
wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/bitcoin-$VERSION-x86_64-linux-gnu.tar.gz
```
{% endcode %}

```sh
wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS
```

```sh
wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS.asc
```

### Checksum check

* Check that the reference checksum in the file `SHA256SUMS` matches the checksum calculated by you (ignore the "lines are improperly formatted" warning)

```sh
sha256sum --ignore-missing --check SHA256SUMS
```

**Example** of expected output:

```
bitcoin-25.1-x86_64-linux-gnu.tar.gz: OK
```

### Signature check

Bitcoin releases are signed by several individuals, each using its own key. To verify the validity of these signatures, you must first import the corresponding public keys into your GPG key database.

* The next command downloads and imports automatically all signatures from the [Bitcoin Core release attestations (Guix)](https://github.com/bitcoin-core/guix.sigs) repository

{% code overflow="wrap" %}
```sh
curl -s "https://api.github.com/repositories/355107265/contents/builder-keys" | grep download_url | grep -oE "https://[a-zA-Z0-9./-]+" | while read url; do curl -s "$url" | gpg --import; done
```
{% endcode %}

Expected output:

```
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
gpg --verify SHA256SUMS.asc
```

* Check that at least a few signatures show the following text

<pre><code>gpg: <a data-footnote-ref href="#user-content-fn-1">Good signature from</a>...
Primary key fingerprint:...
</code></pre>

### Timestamp check

* The binary checksum file is also timestamped with the Bitcoin blockchain using the [OpenTimestamps protocol](https://en.wikipedia.org/wiki/Time_stamp_protocol), proving that the file existed before some point in time. Let's verify this timestamp. On your local computer, download the checksums file and its timestamp proof:
  * [Click to download](https://bitcoincore.org/bin/bitcoin-core-28.0/SHA256SUMS.ots) the checksum file
  * [Click to download](https://bitcoincore.org/bin/bitcoin-core-28.0/SHA256SUMS) its timestamp proof
* In your browser, open the [OpenTimestamps website](https://opentimestamps.org/)
* In the "Stamp and verify" section, drop or upload the downloaded `SHA256SUMS.ots` proof file in the dotted box
* In the next box, drop or upload the `SHA256SUMS` file
* If the timestamps are verified, you should see the following message. The timestamp proves that the checksums file existed on the [release date](https://github.com/bitcoin/bitcoin/releases) of the latest Bitcoin Core version

The following screenshot is just an **example** of one of the versions:

![](../../images/bitcoin-ots-check.PNG)

* If you're satisfied with the checksum, signature, and timestamp checks, extract the Bitcoin Core binaries

```sh
tar -xzvf bitcoin-$VERSION-x86_64-linux-gnu.tar.gz
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
bitcoin-27.1/
bitcoin-27.1/README.md
bitcoin-27.1/bin/
bitcoin-27.1/bin/bitcoin-cli
bitcoin-27.1/bin/bitcoin-qt
bitcoin-27.1/bin/bitcoin-tx
bitcoin-27.1/bin/bitcoin-util
bitcoin-27.1/bin/bitcoin-wallet
bitcoin-27.1/bin/bitcoind
bitcoin-27.1/bin/test_bitcoin
bitcoin-27.1/bitcoin.conf
bitcoin-27.1/include/
bitcoin-27.1/include/bitcoinconsensus.h
bitcoin-27.1/lib/
bitcoin-27.1/lib/libbitcoinconsensus.so
bitcoin-27.1/lib/libbitcoinconsensus.so.0
bitcoin-27.1/lib/libbitcoinconsensus.so.0.0.0
bitcoin-27.1/share/
bitcoin-27.1/share/man/
bitcoin-27.1/share/man/man1/
bitcoin-27.1/share/man/man1/bitcoin-cli.1
bitcoin-27.1/share/man/man1/bitcoin-qt.1
bitcoin-27.1/share/man/man1/bitcoin-tx.1
bitcoin-27.1/share/man/man1/bitcoin-util.1
bitcoin-27.1/share/man/man1/bitcoin-wallet.1
bitcoin-27.1/share/man/man1/bitcoind.1
bitcoin-27.1/share/rpcauth/
bitcoin-27.1/share/rpcauth/README.md
bitcoin-27.1/share/rpcauth/rpcauth.py
```

</details>

{% hint style="info" %}
If you want to [generate a full bitcoin.conf file](bitcoin-client.md#generate-a-full-bitcoin.conf-example-file), follow the proper [extra section](bitcoin-client.md#generate-a-full-bitcoin.conf-example-file), and then come back to continue with the [next section](bitcoin-client.md#binaries-installation)

If you want to install the manual page for `bitcoin-cli`, follow [the manual page for the bitcoin-cli extra section](bitcoin-client.md#the-manual-page-for-bitcoin-cli), and then come back to continue with the [next section](bitcoin-client.md#create-the-bitcoin-user-and-group)
{% endhint %}

### Binaries installation

* Install it

<pre class="language-sh" data-overflow="wrap"><code class="lang-sh"><strong>sudo install -m 0755 -o root -g root -t /usr/local/bin bitcoin-$VERSION/bin/bitcoin-cli bitcoin-$VERSION/bin/bitcoind
</strong></code></pre>

* Check the correct installation requesting the output of the version

```sh
bitcoind --version
```

The following output is just an **example** of one of the versions:

```
> Bitcoin Core version v24.1.0
> Copyright (C) 2009-2022 The Bitcoin Core developers
> [...]
```

* **(Optional)** Delete installation files of the `tmp` folder to be ready for the next installation

{% code overflow="wrap" %}
```bash
sudo rm -r bitcoin-$VERSION bitcoin-$VERSION-x86_64-linux-gnu.tar.gz SHA256SUMS SHA256SUMS.asc SHA256SUMS.ots
```
{% endcode %}

### Create the bitcoin user & group

The Bitcoin Core application will run in the background as a daemon and use the separate user “bitcoin” for security reasons. This user does not have admin rights and cannot change the system configuration.

* Create the `bitcoin` user and group

```bash
sudo adduser --gecos "" --disabled-password bitcoin
```

* Add the user `admin` to the group "bitcoin" as well

```bash
sudo adduser admin bitcoin
```

* Allow the user `bitcoin` to use the control port and configure Tor directly by adding it to the "`debian-tor`" group

```bash
sudo adduser bitcoin debian-tor
```

### Create data folder

Bitcoin Core uses by default the folder `.bitcoin` in the user's home. Instead of creating this directory, we create a data directory in the general data location `/data` and link to it.

* Create the Bitcoin data folder

```sh
mkdir /data/bitcoin
```

* Assign as the owner to the `bitcoin` user

```sh
sudo chown bitcoin:bitcoin /data/bitcoin
```

* Switch to the user `bitcoin`

```sh
sudo su - bitcoin
```

* Create the symbolic link `.bitcoin` that points to that directory

```sh
ln -s /data/bitcoin /home/bitcoin/.bitcoin
```

* Check the symbolic link has been created correctly

```bash
ls -la .bitcoin
```

Expected output:

<pre><code>lrwxrwxrwx 1 bitcoin bitcoin   13 Nov  7 19:32 <a data-footnote-ref href="#user-content-fn-2">.bitcoin -> /data/bitcoin</a>
</code></pre>

### Generate access credentials

For other programs to query Bitcoin Core they need the proper access credentials. To avoid storing the username and password in a configuration file in plaintext, the password is hashed. This allows Bitcoin Core to accept a password, hash it, and compare it to the stored hash, while it is not possible to retrieve the original password.

Another option to get access credentials is through the `.cookie` file in the Bitcoin data directory. This is created automatically and can be read by all users who are members of the "bitcoin" group.

Bitcoin Core provides a simple Python program to generate the configuration line for the config file.

* Enter to the bitcoin folder

```sh
cd .bitcoin
```

* Download the RPCAuth program

{% code overflow="wrap" %}
```sh
wget https://raw.githubusercontent.com/bitcoin/bitcoin/master/share/rpcauth/rpcauth.py
```
{% endcode %}

* Run the script with the Python3 interpreter, providing the username (`minibolt`) and your `"password [B]"` arguments

{% hint style="warning" %}
All commands entered are stored in the bash history. But we don't want the password to be stored where anyone can find it. For this, put a space `( )` in front of the command shown below
{% endhint %}

```sh
 python3 rpcauth.py minibolt YourPasswordB
```

**Example** of expected output:

```
String to be appended to bitcoin.conf:
rpcauth=minibolt:00d8682ce66c9ef3dd9d0c0a6516b10e$c31da4929b3d0e092ba1b2755834889f888445923ac8fd69d8eb73efe0699afa
```

* Copy the `rpcauth` line, we'll need to paste it into the Bitcoin config file

## Configuration

Now, the configuration file `bitcoind` needs to be created. We'll also set the proper access permissions.

* Still as the user `"bitcoin"`, creates the `bitcoin.conf` file

```bash
nano /home/bitcoin/.bitcoin/bitcoin.conf
```

* Enter the complete next configuration. Save and exit

{% hint style="danger" %}
Remember to replace the whole line starting with `"rpcauth"` the connection string you just generated
{% endhint %}

{% hint style="warning" %}
Remember to accommodate the "`dbcache`" parameter depending on your hardware. Recommended: dbcache=1/2 x total RAM available, e.g: 4GB RAM -> dbcache=2048
{% endhint %}

{% hint style="info" %}
**(Optional)** Modify the `"uacomment"` value to your preference if you want
{% endhint %}

<pre><code># MiniBolt: bitcoind configuration
# /data/bitcoin/bitcoin.conf

# Bitcoin daemon
server=1
txindex=1

# Append comment to the user agent string
uacomment=MiniBolt node

# Disable integrated wallet
disablewallet=1

# Additional logs
debug=tor
debug=i2p

# Assign to the cookie file read permission to the Bitcoin group users
rpccookieperms=group

# Disable debug.log
nodebuglogfile=1

# Avoid assuming that a block and its ancestors are valid,
# and potentially skipping their script verification.
# We will set it to 0, to verify all.
assumevalid=0

# Enable all compact filters
blockfilterindex=1

# Serve compact block filters to peers per BIP 157
peerblockfilters=1

# Maintain coinstats index used by the gettxoutsetinfo RPC
coinstatsindex=1

# Network
listen=1

## P2P bind
bind=127.0.0.1
bind=127.0.0.1=onion

## Proxify clearnet outbound connections using Tor SOCKS5 proxy
proxy=unix:/run/tor/socks

## I2P SAM proxy to reach I2P peers and accept I2P connections
i2psam=127.0.0.1:7656

# Connections
rpcauth=<a data-footnote-ref href="#user-content-fn-3">&#x3C;replace with your own auth line generated in the previous step></a>

# Initial block download optimizations
dbcache=<a data-footnote-ref href="#user-content-fn-4">2048</a>
blocksonly=1
</code></pre>

{% hint style="info" %}
**(Optional)** If you checked on the [Check IPv6 availability](../../index-1/security.md#check-ipv6-availability) section and you don't have IPv6 available, you can discard `cjdns` of the Bitcoin Core by adding the next lines at the end of the configuration file:

```
# Disable cjdns network
onlynet=onion
onlynet=i2p
onlynet=ipv4
onlynet=ipv6
```

-> This is a standard configuration. Check this [Bitcoin Core sample bitcoind.conf](https://gist.github.com/twofaktor/af6e2226e2861fa86874340f5315aa01) file with all possible options or generate one yourself following the proper [extra section](bitcoin-client.md#generate-a-full-bitcoin.conf-example-file)
{% endhint %}

* Set permissions for only the user `bitcoin` and members of the `bitcoin` group can read it (needed for LND to read the "`rpcauth`" line)

```sh
chmod 640 /home/bitcoin/.bitcoin/bitcoin.conf
```

* Exit the `bitcoin` user session to back to the user `admin`

{% code fullWidth="false" %}
```sh
exit
```
{% endcode %}

### Create systemd service

The system needs to run the bitcoin daemon automatically in the background. We use `systemd`, a daemon that controls the startup process using configuration files

* Create the systemd configuration

```bash
sudo nano /etc/systemd/system/bitcoind.service
```

* Enter the complete next configuration. Save and exit

```
# MiniBolt: systemd unit for bitcoind
# /etc/systemd/system/bitcoind.service

[Unit]
Description=Bitcoin Core Daemon
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

* Enable autoboot **(optional)**

```sh
sudo systemctl enable bitcoind
```

* Prepare “bitcoind” monitoring by the systemd journal and check the logging output. You can exit monitoring at any time with Ctrl-C

```sh
journalctl -fu bitcoind
```

{% hint style="info" %}
Keep **this terminal open,** you'll need to come back here on the next step to monitor the logs
{% endhint %}

## Run

To keep an eye on the software movements, [start your SSH program](../../index-1/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`

* Start the service

```sh
sudo systemctl start bitcoind
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>journalctl -fu bitcoind</code> ⬇️</summary>

<pre><code>2022-11-24T18:08:04Z Bitcoin Core version v24.0.1.0 (release build)
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
Monitor the log file for a few minutes to see if it works. Logs like the next, indicate that the initial start-up process has been successful:

```
New block-relay-only v1 peer connected: version: 70016, blocks=2948133, peer=68
[..]
Synchronizing blockheaders, height: 4000 (~0.56%)
[..]
UpdateTip: new best=000000000f8d29fcf9ac45e443706c6f21a6e9cfa615f94794b726d3ba8bdc88 height=2948135 version=0x20000000 log2_work=75.951200 tx=215155316 date='2024-09-18T16:25:12Z' progress=1.000000 cache=20.9MiB(142005txo)
[..]
```
{% endhint %}

* Link the Bitcoin data directory from the `admin` user's home directory as well. This allows `admin` user to work with bitcoind directly, for example, by using the command `bitcoin-cli`

```sh
ln -s /data/bitcoin /home/admin/.bitcoin
```

* This symbolic link becomes active **only in a new user session**. Log out from SSH by entering the next command

```sh
exit
```

* Log in again as a user `admin` [opening a new SSH session](../../index-1/remote-access.md#access-with-secure-shell)
* Check symbolic link have been created correctly

```bash
ls -la .bitcoin
```

Expected output:

<pre><code>lrwxrwxrwx 1 admin admin    13 Nov  7 10:41 <a data-footnote-ref href="#user-content-fn-5">.bitcoin -> /data/bitcoin</a>
</code></pre>

{% hint style="warning" %}
**Troubleshooting note:**\
\
If you don't obtain the before-expected output ([`.bitcoin -> /data/bitcoin`](#user-content-fn-6)[^6]) and you only have (`.bitcoin`), you must follow the next steps to fix that:

1. With user `admin`, delete the failed created symbolic link

```bash
sudo rm -r .bitcoin
```

2. Try to create the symbolic link again

```bash
ln -s /data/bitcoin /home/admin/.bitcoin
```

3. Check the symbolic link has been created correctly this time and you now have the expected output

```bash
ls -la .bitcoin
```

Expected output:

<pre><code>lrwxrwxrwx 1 admin admin    13 Nov  7 10:41 <a data-footnote-ref href="#user-content-fn-7">.bitcoin -> /data/bitcoin</a>
</code></pre>
{% endhint %}

* Wait a few minutes until Bitcoin Core starts, and enter the next command to obtain your Tor and I2P addresses. **Take note of them**, later you might need it

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

* Check the correct enablement of the I2P and Tor networks

```sh
bitcoin-cli -netinfo
```

**Example** of expected output:

```
Bitcoin Core client v24.0.1 - server 70016/Satoshi:24.0.1/
          ipv4    ipv6   onion   i2p   total   block
in          0       0      25     2      27
out         7       0       2     1      10       2
total       7       0      27     3      37

Local addresses
xdtk6tie4srguvz566xpyukkd7m3z3vbby5xx5ccyg5f64fzop7hoiab.onion     port   8333    score      4
etehks3xyh55nyjldjdeckk3nwpanivqhrzhsoracwqjxtk8apgk.b32.i2p       port      0    score      4
```

* Ensure bitcoind is listening on the default RPC & P2P ports

```bash
sudo ss -tulpn | grep bitcoind
```

Expected output:

<pre><code>tcp   LISTEN 0      128        127.0.0.1:<a data-footnote-ref href="#user-content-fn-8">8332</a>       0.0.0.0:*    users:(("bitcoind",pid=773834,fd=11))
tcp   LISTEN 0      4096       127.0.0.1:<a data-footnote-ref href="#user-content-fn-9">8333</a>       0.0.0.0:*    users:(("bitcoind",pid=773834,fd=46))
tcp   LISTEN 0      4096       127.0.0.1:<a data-footnote-ref href="#user-content-fn-10">8334</a>       0.0.0.0:*    users:(("bitcoind",pid=773834,fd=44))
tcp   LISTEN 0      128            [::1]:8332          [::]:*    users:(("bitcoind",pid=773834,fd=10))
</code></pre>

* Please note:
  * When “bitcoind” is still starting, you may get an error message like “verifying blocks”. That’s normal, just give it a few minutes.
  * Among other info, the “verificationprogress” is shown. Once this value reaches almost 1 or near (0.999…), the blockchain is up-to-date and fully validated.

## Bitcoin Core is syncing

{% hint style="info" %}
This process is called IBD (Initial Block Download). This can take between one day and a week, depending mostly on your PC performance. It's best to wait until the synchronization is complete before going ahead
{% endhint %}

### Explore bitcoin-cli

If everything is running smoothly, this is the perfect time to familiarize yourself with Bitcoin, the technical aspects of Bitcoin Core, and play around with `bitcoin-cli` until the blockchain is up-to-date.

* [The Little Bitcoin Book](https://littlebitcoinbook.com) is a fantastic introduction to Bitcoin, focusing on the "why" and less on the "how"
*   [Mastering Bitcoin](https://bitcoinbook.info) by Andreas Antonopoulos is a great point to start, especially chapter 3 (ignore the first part how to compile from source code):

    * You definitely need to have a [real copy](https://bitcoinbook.info/) of this book!
    * Read it online on [GitHub](https://github.com/bitcoinbook/bitcoinbook)

    <figure><img src="../../images/30_mastering_bitcoin_book.jpg" alt=""><figcaption></figcaption></figure>
* [Learning Bitcoin from the Command Line](https://github.com/ChristopherA/Learning-Bitcoin-from-the-Command-Line/blob/master/README.md) by Christopher Allen gives a thorough deep dive into understanding the technical aspects of Bitcoin
* Also, check out the [bitcoin-cli reference](https://en.bitcoin.it/wiki/Original_Bitcoin_client/API_calls_list)

## Activate mempool & reduce 'dbcache' after a full sync

Once Bitcoin Core **is fully synced**, we can reduce the size of the database cache. A bigger cache speeds up the initial block download, now we want to reduce memory consumption to allow the Lightning client and Electrum server to run in parallel. We also now want to enable the node to listen to and relay transactions.

{% hint style="info" %}
Bitcoin Core will then just use the default cache size of 450 MiB instead of your setting RAM setup. If `blocksonly=1` is left uncommented it will prevent Electrum Server from receiving RPC fee data and will not work
{% endhint %}

* As user `admin`, edit the `bitcoin.conf` file

```sh
sudo nano /home/bitcoin/.bitcoin/bitcoin.conf
```

* Comment the following lines by adding a `#` at the beginning. Save and exit

```
#assumevalid=0
#dbcache=2048
#blocksonly=1
```

* Restart Bitcoin Core for the settings to take effect

```sh
sudo systemctl restart bitcoind
```

## OpenTimestamps client

When we installed Bitcoin Core, we verified the timestamp of the checksum file using the OpenTimestamp website. In the future, you will likely need to verify more timestamps, when installing additional programs (e.g. LND) and when updating existing programs to a newer version. Rather than relying on a third party, it would be preferable (and more fun) to verify the timestamps using your blockchain data. Now that Bitcoin Core is running and synced, we can install the [OpenTimestamp client](https://github.com/opentimestamps/opentimestamps-client) to locally verify the timestamp of the binaries checksums file.

* As user `admin`, install dependencies

```sh
sudo apt install python3-dev python3-pip python3-wheel
```

* Install the OpenTimestamp client

```sh
sudo pip3 install opentimestamps-client
```

* Display the OpenTimestamps client version to check that it is properly installed

```sh
ots --version
```

**Example** of expected output:

<pre><code><strong>v0.7.1
</strong></code></pre>

{% hint style="info" %}
To update the OpenTimestamps client, simply exec `sudo pip3 install --upgrade opentimestamps-client`
{% endhint %}

## Extras (optional)

### Slow device mode

* As user `admin` edit `bitcoin.conf` file

```sh
sudo nano /home/bitcoin/.bitcoin/bitcoin.conf
```

* Add these lines at the end of the file

<pre><code># Slow devices optimizations
## Limit the number of max peer connections
<a data-footnote-ref href="#user-content-fn-11">maxconnections</a>=40
## Tries to keep outbound traffic under the given target per 24h
<a data-footnote-ref href="#user-content-fn-12">maxuploadtarget</a>=5000
## Increase the number of threads to service RPC calls (default: 4)
rpcthreads=128
## Increase the depth of the work queue to service RPC calls (default: 16)
rpcworkqueue=256
</code></pre>

* Comment these lines

```
#coinstatsindex=1
#assumevalid=0
```

{% hint style="info" %}
Realize that with `maxuploadtarget` parameter enabled you will need to whitelist the connection to [Electrs](../../bonus/bitcoin/electrs.md) and [Bisq](../../bonus/bitcoin/bisq.md) by adding these parameters to `bitcoin.conf`:

For Electrs:

```
whitelist=download@127.0.0.1
```

For Bisq:

```
whitelist=bloomfilter@192.168.0.0/16
```
{% endhint %}

### Renovate your Bitcoin Core Tor and I2P addresses

* With user `admin`, stop bitcoind and dependencies

```bash
sudo systemctl stop bitcoind
```

* Delete

```bash
sudo rm /data/bitcoin/onion_v3_private_key && /data/bitcoin/i2p_private_key
```

* Start bitcoind again

```bash
sudo systemctl start bitcoind
```

* If you want to monitor the bitcoind logs and the starting progress, type `journalctl -fu bitcoind` in a separate SSH session
* Wait a minute to identify your newly generated addresses with

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

* For convenience, it might be useful to have the manual page for `bitcoin-cli` in the same machine so that they can be consulted offline, they can be installed from the directory

{% hint style="info" %}
If you followed the [Ordisrespector bonus guide](../../bonus/bitcoin/ordisrespector.md) this section is not needed because man pages are installed by default, type directly `man bitcoin-cli` command to see the man pages
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

* Now you can read the docs doing

```sh
man bitcoin-cli
```

{% hint style="info" %}
Now come back to the section [Binaries installation](bitcoin-client.md#binaries-installation) to continue with the Bitcoin Core installation process, not if you followed the [Ordisrespector bonus guide](../../bonus/bitcoin/ordisrespector.md)
{% endhint %}

### Generate a full bitcoin.conf example file

{% hint style="success" %}
This extra section is valid if you compiled it from the source code using the [Ordisrespector bonus guide](../../bonus/bitcoin/ordisrespector.md)
{% endhint %}

* Follow the complete [Installation progress before](bitcoin-client.md#installation) or the [Ordisrespector installation progress](../../bonus/bitcoin/ordisrespector.md#installation) to install the `bitcoind` binary on the OS
* With user `admin`, go to the temporary folder

```bash
cd /tmp
```

* Clone the source code from GitHub

```bash
git clone https://github.com/bitcoin/bitcoin.git
```

* Copy-paste the bitcoind binary file existing on your OS to the source code folder

```bash
cp /usr/local/bin/bitcoind /tmp/bitcoin/src/
```

* Go to the `devtools` folder

```bash
cd bitcoin/contrib/devtools
```

* Exec the `gen-bitcoin-conf` script to generate the file

```bash
sudo ./gen-bitcoin-conf.sh
```

Expected output:

```
Generating example bitcoin.conf file in share/examples/
```

* Use `cat` to print it on the terminal to enable a copy-paste

```bash
cat /tmp/bitcoin/share/examples/bitcoin.conf
```

* Or `nano` to examine the content

```bash
nano /tmp/bitcoin/share/examples/bitcoin.conf
```

**(Optional)** Delete the `bitcoin` folder from the temporary folder

```bash
sudo rm -r /tmp/bitcoin
```

## Upgrade

The latest release can be found on the [GitHub page](https://github.com/bitcoin/bitcoin/releases) of the Bitcoin Core project. Always read the [RELEASE NOTES](https://github.com/bitcoin/bitcoin/tree/master/doc/release-notes) first! When upgrading, there might be breaking changes or changes in the data structure that need special attention. Replace the environment variable `"VERSION=x.xx"` value for the latest version if it has not already been changed in this guide.

* Login as `admin` user and change to the temporary directory

```sh
cd /tmp
```

* Set a temporary version environment variable to the installation

```sh
VERSION=28.0
```

* Download binary, checksum, signature files, and timestamp file

{% code overflow="wrap" %}
```sh
wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/bitcoin-$VERSION-x86_64-linux-gnu.tar.gz
```
{% endcode %}

{% code overflow="wrap" %}
```sh
wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS
```
{% endcode %}

{% code overflow="wrap" %}
```sh
wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS.asc
```
{% endcode %}

{% code overflow="wrap" %}
```sh
wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS.ots
```
{% endcode %}

* Verify the new version against its checksums

```sh
sha256sum --ignore-missing --check SHA256SUMS
```

**Example** of expected output:

```
bitcoin-25.1-x86_64-linux-gnu.tar.gz: OK
```

* The next command downloads and automatically imports all signatures from the [Bitcoin Core release attestations (Guix)](https://github.com/bitcoin-core/guix.sigs) repository

{% code overflow="wrap" %}
```sh
curl -s "https://api.github.com/repositories/355107265/contents/builder-keys" | grep download_url | grep -oE "https://[a-zA-Z0-9./-]+" | while read url; do curl -s "$url" | gpg --import; done
```
{% endcode %}

Expected output:

```
gpg: key 17565732E08E5E41: 29 signatures not checked due to missing keys
gpg: /home/admin/.gnupg/trustdb.gpg: trustdb created
gpg: key 17565732E08E5E41: public key "Andrew Chow <andrew@achow101.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg: no ultimately trusted keys found
[...]
```

* Verify the checksums file is cryptographically signed using the release signing keys. The following command prints signature checks for each of the public keys that signed the checksums

```sh
gpg --verify SHA256SUMS.asc
```

* Check that at least a few signatures show the following text

```
gpg: Good signature from ...
Primary key fingerprint: ...
```

* If you completed the IBD (Initial Block Download), now you can verify the timestamp with your node. If the prompt shows you `-bash: ots: command not found`, ensure that you are installing the OTS client correctly in the [proper section](bitcoin-client.md#opentimestamps-client)

```sh
ots --no-cache verify SHA256SUMS.ots -f SHA256SUMS
```

{% hint style="info" %}
The following output is just an **example** of one of the versions:

```
Got 1 attestation(s) from https://btc.calendar.catallaxy.com
Got 1 attestation(s) from https://finney.calendar.eternitywall.com
Got 1 attestation(s) from https://bob.btc.calendar.opentimestamps.org
Got 1 attestation(s) from https://alice.btc.calendar.opentimestamps.org
Success! Bitcoin block 766964 attests existence as of 2022-12-11 UTC
```
{% endhint %}

* Now, just check that the timestamp date is close to the [release](https://github.com/bitcoin/bitcoin/releases) date of the version you're installing

{% hint style="info" %}
If you obtain this output:

```
Calendar https://btc.calendar.catallaxy.com: Pending confirmation in Bitcoin blockchain
Calendar https://finney.calendar.eternitywall.com: Pending confirmation in Bitcoin blockchain
Calendar https://bob.btc.calendar.opentimestamps.org: Pending confirmation in Bitcoin blockchain
Calendar https://alice.btc.calendar.opentimestamps.org: Pending confirmation in Bitcoin blockchain
```



-> This means that the timestamp is pending confirmation on the Bitcoin blockchain. You can skip this step or wait a few hours/days to perform this verification. It is safe to skip this verification step if you followed the previous ones and continue to the next ones
{% endhint %}

* If you're satisfied with the checksum, signature, and timestamp checks, extract the Bitcoin Core binaries

```sh
tar -xzvf bitcoin-$VERSION-x86_64-linux-gnu.tar.gz
```

* Install them

{% code overflow="wrap" %}
```sh
sudo install -m 0755 -o root -g root -t /usr/local/bin bitcoin-$VERSION/bin/bitcoin-cli bitcoin-$VERSION/bin/bitcoind
```
{% endcode %}

* Check the new version

```sh
bitcoin-cli --version
```

The following output is just an **example** of one of the versions:

```
Bitcoin Core RPC client version v26.0.0
Copyright (C) 2009-2022 The Bitcoin Core developers
[...]
```

* **(Optional)** Delete installation files of the `/tmp` folder to be ready for the next upgrade

{% code overflow="wrap" %}
```bash
sudo rm -r bitcoin-$VERSION && sudo rm bitcoin-$VERSION-x86_64-linux-gnu.tar.gz && sudo rm SHA256SUMS && sudo rm SHA256SUMS.asc && sudo rm SHA256SUMS.ots
```
{% endcode %}

* Restart the Bitcoin Core to apply the new version

```sh
sudo systemctl restart bitcoind
```

## Uninstall

### Uninstall service

* Ensure you are logged in with the user `admin`, stop bitcoind

```bash
sudo systemctl stop bitcoind
```

* Disable autoboot (if enabled)

```bash
sudo systemctl disable bitcoind
```

* Delete the service

```bash
sudo rm /etc/systemd/system/bitcoind.service
```

### Delete user & group&#x20;

* Delete bitcoin user's group

{% code overflow="wrap" %}
```bash
sudo gpasswd -d admin bitcoin; sudo gpasswd -d fulcrum bitcoin; sudo gpasswd -d lnd bitcoin; sudo gpasswd -d btcrpcexplorer bitcoin; sudo gpasswd -d btcpay bitcoin
```
{% endcode %}

* Delete the `bitcoin` user. Don't worry about `userdel: bitcoin mail spool (/var/mail/bitcoin) not found` output, the uninstall has been successful

```bash
sudo userdel -rf bitcoin
```

* Delete the bitcoin group

```bash
sudo groupdel bitcoin
```

### Detele data directory

* Delete the complete `bitcoin`directory

```bash
sudo rm -rf /data/bitcoin/
```

### Uninstall binaries

* Delete the binaries installed

```bash
sudo rm /usr/local/bin/bitcoin-cli && sudo rm /usr/local/bin/bitcoind
```

### Uninstall FW configuration

If you followed the [Bisq bonus guide](../../bonus/bitcoin/bisq.md), you needed to add an allow rule on UFW to allow the incoming connection to the `8333` port (P2P)

* Ensure you are logged in with the user `admin`, display the UFW firewall rules, and note the numbers of the rules for Bitcoin Core (e.g. "Y" below)

```bash
sudo ufw status numbered
```

Expected output:

```
> [Y] 8333       ALLOW IN    Anywhere            # allow Bitcoin Core from anywhere
```

{% hint style="info" %}
If you don't have any rule matched with this, you don't have to do anything, you are OK
{% endhint %}

* Delete the rule with the correct number and confirm with "`yes`"

```bash
sudo ufw delete X
```

## Port reference

<table><thead><tr><th align="center">Port</th><th width="100">Protocol<select><option value="ukHb12cRZxp1" label="TCP" color="blue"></option><option value="Xd1yhX3dgwCx" label="SSL" color="blue"></option><option value="DxH2k0YKIhG7" label="UDP" color="blue"></option></select></th><th align="center">Use</th></tr></thead><tbody><tr><td align="center">8333</td><td><span data-option="ukHb12cRZxp1">TCP</span></td><td align="center">Default P2P port</td></tr><tr><td align="center">8332</td><td><span data-option="ukHb12cRZxp1">TCP</span></td><td align="center">Default RPC port</td></tr><tr><td align="center">8334</td><td><span data-option="ukHb12cRZxp1">TCP</span></td><td align="center">Default P2P Tor port</td></tr></tbody></table>

[^1]: Check this

[^2]: Check this

[^3]: Replace

[^4]: -> Set `dbcache` size in MiB (min 4, default: 450) according to the available RAM of your device.&#x20;

    -> Recommended: dbcache=1/2 x RAM available e.g: 4GB RAM -> dbcache=2048

    -> Remember to comment or delete this parameter after IBD (Initial Block Download)

[^5]: Symbolic link

[^6]: Symbolic link

[^7]: Check this

[^8]: RPC port

[^9]: P2P main port

[^10]: Default P2P Tor port

[^11]: Default 125 connections to different peers, 11 of which are outbound. You can therefore, have at most 114 inbound connections. Of the 11 outbound peers, there can be 8 full-relay connections, 2 block-relay-only ones and occasionally 1 short-lived feeler or an extra block-relay-only connection.

[^12]: This option can be specified in MiB per day and is turned off by default. \<MiB per day>
