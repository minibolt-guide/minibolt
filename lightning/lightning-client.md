---
title: Lightning client
nav_order: 10
parent: Lightning
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

# 3.1 Lightning client: LND

We set up [LND](https://github.com/lightningnetwork/lnd), the Lightning Network Daemon, by [Lightning Labs](https://lightning.engineering/).

<div align="center"><img src="../.gitbook/assets/lightning-network-daemon-logo.png" alt=""></div>

## Requirements

* [Bitcoin Core](../bitcoin/bitcoin/bitcoin-client.md)
* Others
  * [PostgreSQL](../bonus-guides/system/postgresql.md) (optional)

## Preparations

The installation of LND is straightforward, but the application is quite powerful and capable of things not explained here. Check out their [GitHub repository](https://github.com/lightningnetwork/lnd/) for a wealth of information about their open-source project and Lightning in general.

### Configure Bitcoin Core

Before running LND, we need to configure settings in the Bitcoin Core configuration file to enable the LND RPC connection.

* Log in as user `admin`, edit the `bitcoin.conf` file

```sh
sudo nano /data/bitcoin/bitcoin.conf
```

* Add the following lines. Save and exit

```
# Enable ZMQ raw notification (for LND)
zmqpubrawblock=tcp://127.0.0.1:28332
zmqpubrawtx=tcp://127.0.0.1:28333
```

* Restart Bitcoin Core to apply changes

```sh
sudo systemctl restart bitcoind
```

* Check Bitcoin Core is enabled `zmqpubrawblock` and `zmqpubrawtx` on the `28332` and `28333` port

```bash
sudo ss -tulpn | grep bitcoind | grep 2833
```

Expected output:

<pre><code>tcp   LISTEN 0      100        127.0.0.1:<a data-footnote-ref href="#user-content-fn-1">28332</a>      0.0.0.0:*    users:(("bitcoind",pid=773834,fd=20))
tcp   LISTEN 0      100        127.0.0.1:<a data-footnote-ref href="#user-content-fn-2">28333</a>      0.0.0.0:*    users:(("bitcoind",pid=773834,fd=22))
</code></pre>

### Install PostgreSQL

{% hint style="warning" %}
You may want to use the bbolt database backend instead of PostgreSQL (easier installation/configuration, lower performance, see more [here](https://github.com/minibolt-guide/minibolt/pull/93)). If yes, jump to the [next step](lightning-client.md#installation) and follow the [Use the default bbolt database backend](lightning-client.md#use-the-default-bbolt-database-backend) section, and remember to create the `lnd.conf` properly with this configuration when you arrive at the [configuration section](lightning-client.md#configuration)
{% endhint %}

* With user `admin`, check if you already have PostgreSQL installed

```bash
psql -V
```

**Example** of expected output:

```
psql (PostgreSQL) 15.3 (Ubuntu 15.3-1.pgdg22.04+1)
```

{% hint style="info" %}
If you obtain "**command not found**" outputs, you need to follow the [PostgreSQL bonus guide installation process](../bonus-guides/system/postgresql.md#installation) to install it, and then return to continue with the guide
{% endhint %}

#### Create PostgreSQL database

* With user `admin`, create a new database with the `postgres` user and assign it as the owner to the `admin` user

{% code overflow="wrap" %}
```bash
sudo -u postgres createdb -O admin lndb
```
{% endcode %}

## Installation

### Download binaries

* We'll download, verify, and install LND. Navigate to the temporary directory

```sh
cd /tmp
```

* Set a temporary version environment variable for the installation

```sh
VERSION=0.20.1
```

* Download the application, checksums, and signature

{% code overflow="wrap" %}
```sh
wget https://github.com/lightningnetwork/lnd/releases/download/v$VERSION-beta/lnd-linux-amd64-v$VERSION-beta.tar.gz
```
{% endcode %}

{% code overflow="wrap" %}
```bash
wget https://github.com/lightningnetwork/lnd/releases/download/v$VERSION-beta/manifest-v$VERSION-beta.txt.ots
```
{% endcode %}

{% code overflow="wrap" %}
```bash
wget https://github.com/lightningnetwork/lnd/releases/download/v$VERSION-beta/manifest-v$VERSION-beta.txt
```
{% endcode %}

{% code overflow="wrap" %}
```bash
wget https://github.com/lightningnetwork/lnd/releases/download/v$VERSION-beta/manifest-roasbeef-v$VERSION-beta.sig.ots
```
{% endcode %}

{% code overflow="wrap" %}
```sh
wget https://github.com/lightningnetwork/lnd/releases/download/v$VERSION-beta/manifest-roasbeef-v$VERSION-beta.sig
```
{% endcode %}

### Checksum check

* Verify the signed checksum against the actual checksum of your download

```sh
sha256sum --check manifest-v$VERSION-beta.txt --ignore-missing
```

**Example** of expected output:

```
lnd-linux-amd64-v0.16.3-beta.tar.gz: OK
```

### Signature check

Now that we've verified the integrity of the downloaded binary, we need to check the authenticity of the manifest file we just used, starting with its signature.

* Get the public key from a LND developer who signed the manifest file, and add it to your GPG keyring

{% code overflow="wrap" %}
```bash
curl https://raw.githubusercontent.com/lightningnetwork/lnd/master/scripts/keys/roasbeef.asc | gpg --import
```
{% endcode %}

Expected output:

<pre data-full-width="false"><code>  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1306  100  1306    0     0   2958      0 --:--:-- --:--:-- --:--:--  2961
gpg: /home/admin/.gnupg/trustdb.gpg: trustdb created
gpg: key DC42612E89237182: public key "Olaoluwa Osuntokun &#x3C;laolu32@gmail.com>" <a data-footnote-ref href="#user-content-fn-3">imported</a>
gpg: Total number processed: 1
gpg:               imported: 1
</code></pre>

* Verify the signature of the text file containing the checksums for the application

```sh
gpg --verify manifest-roasbeef-v$VERSION-beta.sig manifest-v$VERSION-beta.txt
```

**Example** of expected output:

<pre><code>gpg: Signature made Wed 18 Dec 2024 07:56:51 PM UTC
gpg:                using EDDSA key 296212681AADF05656A2CDEE90525F7DEEE0AD86
gpg: <a data-footnote-ref href="#user-content-fn-3">Good signature</a> from "Olaoluwa Osuntokun &#x3C;laolu32@gmail.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: A5B6 1896 952D 9FDA 83BC  054C DC42 612E 8923 7182
     Subkey fingerprint: 2962 1268 1AAD F056 56A2  CDEE 9052 5F7D EEE0 AD86
</code></pre>

### Timestamp check

We can also check that the manifest file was in existence around the time of the release using its timestamp.

* Let's verify the timestamp of the file matches the release date

{% code overflow="wrap" %}
```bash
ots --no-cache verify manifest-roasbeef-v$VERSION-beta.sig.ots -f manifest-roasbeef-v$VERSION-beta.sig
```
{% endcode %}

**Example** of expected output:

<pre><code>Got 1 attestation(s) from https://alice.btc.calendar.opentimestamps.org
Got 1 attestation(s) from https://btc.calendar.catallaxy.com
Got 1 attestation(s) from https://finney.calendar.eternitywall.com
Got 1 attestation(s) from https://bob.btc.calendar.opentimestamps.org
<a data-footnote-ref href="#user-content-fn-3">Success!</a> Bitcoin block <a data-footnote-ref href="#user-content-fn-4">765521 attests existence as of 2022-12-01 UTC</a>
</code></pre>

{% code overflow="wrap" %}
```bash
ots --no-cache verify manifest-v$VERSION-beta.txt.ots -f manifest-v$VERSION-beta.txt
```
{% endcode %}

**Example** of expected output:

<pre><code>Got 1 attestation(s) from https://alice.btc.calendar.opentimestamps.org
Got 1 attestation(s) from https://btc.calendar.catallaxy.com
Got 1 attestation(s) from https://finney.calendar.eternitywall.com
Got 1 attestation(s) from https://bob.btc.calendar.opentimestamps.org
<a data-footnote-ref href="#user-content-fn-3">Success!</a> Bitcoin block <a data-footnote-ref href="#user-content-fn-4">829257 attests existence as of 2024-02-06 UTC</a>
</code></pre>

{% hint style="info" %}
Check that the date of the timestamp is close to the [release date](https://github.com/lightningnetwork/lnd/releases) of the LND binary
{% endhint %}

* Having verified the integrity and authenticity of the release binary, we can safely proceed

```sh
tar -xzvf lnd-linux-amd64-v$VERSION-beta.tar.gz
```

**Example** of expected output:

```
lnd-linux-amd64-v0.17.1-beta/lnd
lnd-linux-amd64-v0.17.1-beta/lncli
lnd-linux-amd64-v0.17.1-beta/
```

### Binaries installation

* Install it

{% code overflow="wrap" %}
```sh
sudo install -m 0755 -o root -g root -t /usr/local/bin lnd-linux-amd64-v$VERSION-beta/lnd lnd-linux-amd64-v$VERSION-beta/lncli
```
{% endcode %}

* Verify installation by running the version command

```sh
lnd --version
```

**Example** of expected output:

```
lnd version 0.16.3-beta commit=v0.16.3-beta
```

* **(Optional)** Clean the LND files of the `tmp` folder

<pre class="language-bash" data-overflow="wrap"><code class="lang-bash"><strong>sudo rm -r lnd-linux-amd64-v$VERSION-beta lnd-linux-amd64-v$VERSION-beta.tar.gz manifest-roasbeef-v$VERSION-beta.sig manifest-roasbeef-v$VERSION-beta.sig.ots manifest-v$VERSION-beta.txt manifest-v$VERSION-beta.txt.ots
</strong></code></pre>

{% hint style="info" %}
If you come to [update](lightning-client.md#upgrade) this is the final step
{% endhint %}

### Create the lnd user & group

* Create the `lnd` user and group

```sh
sudo adduser --disabled-password --gecos "" lnd
```

* Add the `lnd` user to the groups "bitcoin" and "debian-tor", allowing the `lnd` user to read the bitcoind `.cookie` file and to use the control port to configure Tor directly

```sh
sudo usermod -a -G bitcoin,debian-tor lnd
```

* Add the user `admin` to the group "lnd"

```sh
sudo adduser admin lnd
```

### Create data folder

* Create the LND data folder

```sh
sudo mkdir /data/lnd
```

* Assign the `lnd` user as owner

```sh
sudo chown -R lnd:lnd /data/lnd
```

* Open a `lnd` user session

```sh
sudo su - lnd
```

* Create symbolic links pointing to the lnd and bitcoin data directories

```sh
ln -s /data/lnd /home/lnd/.lnd && ln -s /data/bitcoin /home/lnd/.bitcoin
```

* Check that symbolic links have been created correctly

```bash
ls -la .lnd .bitcoin
```

Expected output:

<pre><code>lrwxrwxrwx 1 lnd lnd 13 Jul 21  2023 <a data-footnote-ref href="#user-content-fn-3">.bitcoin -> /data/bitcoin</a>
lrwxrwxrwx 1 lnd lnd  9 Jul 21  2023 <a data-footnote-ref href="#user-content-fn-3">.lnd -> /data/lnd</a>
</code></pre>

### Wallet password

{% hint style="info" %}
This section is not needed if you want to unlock the LND wallet manually, and the lines in lnd.conf behind: `"# Automatically unlock wallet with the password in this file"` section. Follow the [Unlock the LND wallet manually](lightning-client.md#unlock-the-lnd-wallet-manually) extra section for instructions
{% endhint %}

LND includes a Bitcoin wallet that manages your onchain and Lightning coins. It is password protected and must be unlocked when LND starts. This creates the dilemma that you either manually unlock LND after each restart of your node or store the password somewhere on the node.

For this initial setup, we choose the easy route: we store the password in a file that allows LND to unlock the wallet automatically.

* Still as user `lnd`, create a text file and enter your LND wallet `password [C]`. **The password should have at least 8 characters.** Save and exit

```sh
nano /data/lnd/password.txt
```

* Tighten access privileges to make the file readable only for the user `lnd`

```sh
chmod 600 /data/lnd/password.txt
```

## Configuration

* Create the LND configuration file

```sh
nano /data/lnd/lnd.conf
```

* Paste the following content. Save and exit

{% hint style="warning" %}
-> Replace `<YOUR_FANCY_ALIAS>` with your preferred alias e.g: `SatoshiLNnode`⚡. Up to 32 UTF-8 characters, accepts emojis i.e ⚡🧡​ [https://emojikeyboard.top/](https://emojikeyboard.top/)

-> Replace `#ff9900` with your preferred color. You can choose the color you want at [https://www.color-hex.com/](https://www.color-hex.com/)

-> Uncomment and replace #minchansize=20000[^5] with your preferred minimum incoming channel size

-> Uncomment and replace #bitcoin.feerate=1[^5] / #bitcoin.basefee=1000[^5] with your preferred channels fees
{% endhint %}

<pre><code># MiniBolt: lnd configuration
# /data/lnd/lnd.conf

[Application Options]
# The alias your node will use, which can be up to 32 UTF-8 characters in length
alias=<a data-footnote-ref href="#user-content-fn-6">&#x3C;YOUR_FANCY_ALIAS></a>

# The color of the node in hex format, used to customize node appearance in 
# intelligence services
color=<a data-footnote-ref href="#user-content-fn-6">#ff9900</a>

<a data-footnote-ref href="#user-content-fn-7"># Automatically unlock wallet with the password in this file</a>
<a data-footnote-ref href="#user-content-fn-7">wallet-unlock-password-file=/data/lnd/password.txt</a>
<a data-footnote-ref href="#user-content-fn-7">wallet-unlock-allow-create=true</a>

# Do not archive the history of the channel.backup file
no-backup-archive=true

# The maximum number of incoming pending channels permitted per peer
maxpendingchannels=5

# The TLS private key will be encrypted to the node's seed
tlsencryptkey=true

# Automatically regenerate certificate when near expiration
tlsautorefresh=true

# Do not include the interface IPs or the system hostname in TLS certificate
tlsdisableautofill=true

## Channel settings
# (Optional) Minimum channel size. Uncomment and set to your preference
# (default: 20000 sats)
<a data-footnote-ref href="#user-content-fn-5">#minchansize=20000</a>

## (Optional) High fee environment settings
<a data-footnote-ref href="#user-content-fn-8">#max-commit-fee-rate-anchors=</a><a data-footnote-ref href="#user-content-fn-8">10</a>
<a data-footnote-ref href="#user-content-fn-9">#max-channel-fee-allocation=</a><a data-footnote-ref href="#user-content-fn-9">0.5</a>

## Communication
accept-keysend=true
accept-amp=true

## Rebalancing
allow-circular-route=true

## Performance
gc-canceled-invoices-on-startup=true
gc-canceled-invoices-on-the-fly=true
ignore-historical-gossip-filters=true

[Bitcoin]
bitcoin.mainnet=true
bitcoin.node=bitcoind

# Fee settings - default LND base fee = 1000 (mSat), fee rate = 1 (ppm)
# You can choose whatever you want e.g ZeroFeeRouting (0,0) or ZeroBaseFee (0,X)
<a data-footnote-ref href="#user-content-fn-5">#bitcoin.basefee=1000</a>
<a data-footnote-ref href="#user-content-fn-5">#bitcoin.feerate=1</a>

# (Optional) Specify the CLTV delta we will subtract from a forwarded HTLC's timelock value
# (default: 80)
<a data-footnote-ref href="#user-content-fn-10">#bitcoin.timelockdelta=8</a><a data-footnote-ref href="#user-content-fn-11">0</a>

[protocol]
protocol.wumbo-channels=true
protocol.option-scid-alias=true
protocol.simple-taproot-chans=true
protocol.zero-conf=true
protocol.rbf-coop-close=true

[wtclient]
## Watchtower client settings
wtclient.active=true

# (Optional) Specify the fee rate with which justice transactions will be signed
# (default: 10 sat/byte)
<a data-footnote-ref href="#user-content-fn-5">#wtclient.sweep-fee-rate=10</a>

[watchtower]
## Watchtower server settings
watchtower.active=true

[routing]
routing.strictgraphpruning=true

[db]
## Database selection
db.backend=postgres

# Use native SQL instead of KV emulation (only for db.backend=postgres)
db.use-native-sql=true

[postgres]
db.postgres.dsn=postgresql://admin:admin@127.0.0.1:5432/lndb?sslmode=disable
db.postgres.timeout=0

## (Optional) High fee environment settings
# (default: CONSERVATIVE) Uncomment the next 2 lines
#[Bitcoind]
<a data-footnote-ref href="#user-content-fn-12">#bitcoind.estimatemode=ECONOMICAL</a>

[tor]
tor.active=true
tor.v3=true
tor.streamisolation=true
tor.encryptkey=true
</code></pre>

{% hint style="info" %}
This is a standard configuration. Check the official LND [sample-lnd.conf](https://github.com/lightningnetwork/lnd/blob/master/sample-lnd.conf) for all possible options if you want to add something special
{% endhint %}

* Exit of the `lnd` user session to return to the `admin` user session

```sh
exit
```

### Create systemd service

Now, let's configure LND to start automatically on system startup.

* As user `admin`, create LND systemd unit

```sh
sudo nano /etc/systemd/system/lnd.service
```

* Enter the following content. Save and exit

```
# MiniBolt: systemd unit for lnd
# /etc/systemd/system/lnd.service

[Unit]
Description=Lightning Network Daemon
Requires=bitcoind.service postgresql.service
After=bitcoind.service postgresql.service

[Service]
ExecStart=/usr/local/bin/lnd
ExecStop=/usr/local/bin/lncli stop

# Process management
####################
Restart=on-failure
RestartSec=60
Type=notify
TimeoutStartSec=1200
TimeoutStopSec=3600

# Directory creation and permissions
####################################
User=lnd
Group=lnd

# Hardening Measures
####################
ProtectSystem=full
NoNewPrivileges=true
PrivateDevices=true
MemoryDenyWriteExecute=true

[Install]
WantedBy=multi-user.target
```

* Enable autoboot **(optional)**

```sh
sudo systemctl enable lnd
```

* Now, the daemon information is no longer displayed on the command line but is written into the system journal. You can check on it using the following command. You can exit monitoring at any time with `Ctrl-C`

```sh
journalctl -fu lnd
```

## Run

To keep an eye on the software movements, [start your SSH program](../index-1/remote-access.md#access-with-secure-shell) (eg, PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`

* Start the service

```sh
sudo systemctl start lnd
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>journalctl -fu lnd</code> ⬇️</summary>

```
Apr 10 16:06:29 minibolt lnd[74621]: Attempting automatic RPC configuration to bitcoind
Apr 10 16:06:29 minibolt lnd[74621]: Automatically obtained bitcoind's RPC credentials
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.405 [INF] LTND: Version Info rev=848b72 version=0.20.1-beta commit=v0.20.1-beta debuglevel=production logging=info
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.405 [INF] LTND: Network Info rev=848b72 active_chain=Bitcoin network=mainnet
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.405 [INF] RPCS: Generating ephemeral TLS certificates...
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.406 [INF] RPCS: Done generating ephemeral TLS certificates
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.407 [INF] RPCS: RPC server listening on 127.0.0.1:10009
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.416 [INF] RPCS: gRPC proxy started at 127.0.0.1:8080
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.416 [INF] LTND: Opening the main database, this might take a few minutes...
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.458 [INF] SQLD: Using SQL database 'postgresql://admin:***@127.0.0.1:5432/lndb?sslmode=disable'
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.468 [INF] LTND: Using remote postgres database! Creating graph and channel state DB instances
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.477 [INF] CHDB: Checking for schema update: latest_version=33, db_version=33
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.478 [INF] CHDB: Applying 2 optional migrations
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.478 [INF] CHDB: Checking for optional update: name=prune_revocation_log
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.478 [INF] CHDB: Checking for optional update: name=gc_decayed_log
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.478 [INF] CHDB: Performing database optional migration: gc_decayed_log
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.478 [INF] CHDB: Migrating decayed log...
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.479 [INF] CHDB: Decayed log migrated successfully
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.481 [INF] CHDB: Successfully applied optional migration: gc_decayed_log
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.488 [INF] SQLD: No database version found, using schema version -1 (dirty=false) as base version
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.488 [INF] SQLD: Migrating SQL schema to version 1
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.501 [INF] SQLD: Applying migrations from version=0
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.539 [INF] SQLD: 1/u invoices (36.842332ms)
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.558 [INF] SQLD: Migrating SQL schema to version 2
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.563 [INF] SQLD: Applying migrations from version=1
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.606 [INF] SQLD: 2/u amp_invoices (41.74955ms)
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.615 [INF] SQLD: Migrating SQL schema to version 3
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.620 [INF] SQLD: Applying migrations from version=2
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.637 [INF] SQLD: 3/u invoice_events (16.934438ms)
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.648 [INF] SQLD: Migrating SQL schema to version 4
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.653 [INF] SQLD: Applying migrations from version=3
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.660 [INF] SQLD: 4/u invoice_expiry_fix (6.981243ms)
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.670 [INF] SQLD: Migrating SQL schema to version 5
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.675 [INF] SQLD: Applying migrations from version=4
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.682 [INF] SQLD: 5/u migration_tracker (6.33184ms)
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.692 [INF] SQLD: Migrating SQL schema to version 6
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.697 [INF] SQLD: Applying migrations from version=5
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.710 [INF] SQLD: 6/u invoice_migration (12.431129ms)
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.722 [INF] SQLD: Migrating SQL schema to version 6
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.727 [INF] SQLD: Applying migrations from version=6
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.735 [INF] SQLD: Applying custom migration 'kv_invoice_migration' (version 7) to schema version 6
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.735 [INF] INVC: Starting migration of invoices from KV to SQL
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.737 [INF] INVC: All invoices migrated. Total: 0
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.738 [INF] INVC: Migration of 0 invoices from KV to SQL completed
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.741 [INF] SQLD: Migration 'kv_invoice_migration' (version 7) applied
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.743 [INF] SQLD: Migrating SQL schema to version 7
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.747 [INF] SQLD: Applying migrations from version=6
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.755 [INF] SQLD: 7/u invoice_add_settled_index (7.548522ms)
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.765 [INF] SQLD: Migrating SQL schema to version 8
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.770 [INF] SQLD: Applying migrations from version=7
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.800 [INF] SQLD: 8/u graph (29.720612ms)
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.813 [INF] SQLD: Migrating SQL schema to version 8
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.819 [INF] SQLD: Applying migrations from version=8
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.827 [INF] SQLD: Applying custom migration 'kv_graph_migration' (version 10) to schema version 8
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.827 [INF] GRDB: Starting migration of the graph store from KV to SQL
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.828 [INF] GRDB: No graph found in KV store, skipping the migration
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.828 [INF] SQLD: Migration 'kv_graph_migration' (version 10) applied
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.855 [INF] LTND: Database(s) now open (time_to_open=438.225783ms)!
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.856 [INF] LTND: Systemd was notified about our readiness
Apr 10 16:06:29 minibolt lnd[74621]: 2026-04-10 16:06:29.856 [INF] LTND: Waiting for wallet encryption password. Use `lncli create` to create a wallet, `lncli unlock` to unlock an existing wallet, or `lncli changepassword` to change the password of an existing wallet and unlock it.
Apr 10 16:06:29 minibolt systemd[1]: Started Lightning Network Daemon.
```

</details>

### Wallet setup

Once LND is started, the process waits for us to create the integrated Bitcoin onchain wallet.

* Change to the `lnd` user

```sh
sudo su - lnd
```

* Create the LND wallet

```sh
lncli --tlscertpath /data/lnd/tls.cert.tmp create
```

Expected output:

```
Input wallet password:
Confirm password:
```

{% hint style="info" %}
Enter your `password [C]` as wallet password 2 times (it must be the same one you stored in `password.txt` on the [Wallet password](lightning-client.md#wallet-password) step)
{% endhint %}

Expected output

```
Do you have an existing cipher seed mnemonic or extended master root key you want to use?
Enter 'y' to use an existing cipher seed mnemonic, 'x' to use an extended master root key
or 'n' to create a new seed (Enter y/x/n):
```

{% hint style="info" %}
-> Now, you could have 2 possible scenarios, follow the proper steps depending on your case⬇️
{% endhint %}

{% tabs %}
{% tab title="Scenery 1" %}
<mark style="color:green;">**If you are creating a new node and you wish to create a new seed**</mark>

* Press `n` and enter

{% hint style="info" %}
If you choose this option, the next step will be selecting the passphrase (**optional** - press enter to proceed without a cipher seed passphrase)
{% endhint %}

Expected output:

<pre><code><strong>Your cipher seed can optionally be encrypted.
</strong>Input your passphrase if you wish to encrypt it (or press enter to proceed without a cipher seed passphrase):
</code></pre>

* Type the passphrase and press enter \[the prompt will request you to enter your `password [C]` one more time (`Confirm password:`)] or if you choose not to use the passphrase press simply enter

**Example** of expected output:

```
Generating fresh cipher seed...

!!!YOU MUST WRITE DOWN THIS SEED TO BE ABLE TO RESTORE THE WALLET!!!

---------------BEGIN LND CIPHER SEED---------------
 1. ability   2. soap    3. album    4. resource
 5. plate     6. fiber   7. immune   8. fringe
[...]

!!!YOU MUST WRITE DOWN THIS SEED TO BE ABLE TO RESTORE THE WALLET!!!

lnd successfully initialized!
```

{% hint style="warning" %}
These 24 words are all that you need (and the `channel.backup` file in case of disaster recovery) to restore the Bitcoin onchain wallet and possibly blocked UTXOs

**Write these 24 words down manually on a piece of paper and store them in a safe place**

You can use a simple piece of paper, write them on the custom-themed [Shiftcrypto backup card](https://shiftcrypto.ch/backupcard/backupcard_print.pdf), or even [stamp the seed words into metal](../bonus/bitcoin/safu-ninja.md)
{% endhint %}

{% hint style="danger" %}
This piece of paper is all an attacker needs to empty your on-chain wallet!

🚫 **Do not store it on a computer**

🚫 **Do not take a picture with your mobile phone**

🚫 **This information should never be stored anywhere in digital form**

This information must be kept secret at all times
{% endhint %}

**Return to the first terminal with `journalctl -fu lnd`. Example of expected output ⬇️**

```
[...]
Apr 10 16:13:57 minibolt lnd[74621]: 2026-04-10 16:13:57.767 [INF] BTWL: Opened wallet
Apr 10 16:13:57 minibolt lnd[74621]: 2026-04-10 16:13:57.839 [INF] RPCC: Established connection to RPC server localhost:8332
Apr 10 16:13:57 minibolt lnd[74621]: 2026-04-10 16:13:57.839 [INF] RPCC: Established connection to RPC server localhost:8332
Apr 10 16:13:57 minibolt lnd[74621]: 2026-04-10 16:13:57.851 [INF] CHRE: Initializing bitcoind backed fee estimator in CONSERVATIVE mode
Apr 10 16:13:57 minibolt lnd[74621]: 2026-04-10 16:13:57.851 [INF] BTWL: Started listening for bitcoind block notifications via ZMQ on 127.0.0.1:28332
Apr 10 16:13:57 minibolt lnd[74621]: 2026-04-10 16:13:57.851 [INF] RPCC: Established connection to RPC server localhost:8332
Apr 10 16:13:57 minibolt lnd[74621]: 2026-04-10 16:13:57.851 [INF] BTWL: Started listening for bitcoind transaction notifications via ZMQ on 127.0.0.1:28333
Apr 10 16:13:57 minibolt lnd[74621]: 2026-04-10 16:13:57.851 [INF] RPCC: Established connection to RPC server localhost:8332
Apr 10 16:13:58 minibolt lnd[74621]: 2026-04-10 16:13:58.704 [INF] BTWL: The wallet has been unlocked without a time limit
Apr 10 16:13:59 minibolt lnd[74621]: 2026-04-10 16:13:59.943 [INF] CHRE: LightningWallet opened
[...]
Apr 10 16:14:00 minibolt lnd[74621]: 2026-04-10 16:14:00.057 [INF] RPCS: Generating TLS certificates...
Apr 10 16:14:00 minibolt lnd[74621]: 2026-04-10 16:14:00.062 [INF] RPCS: Done generating TLS certificates
Apr 10 16:14:00 minibolt lnd[74621]: 2026-04-10 16:14:00.066 [INF] NTFR: Baking macaroons for ChainNotifier RPC Server at: /home/lnd/.lnd/data/chain/bitcoin/mainnet/chainnotifier.macaroon
Apr 10 16:14:00 minibolt lnd[74621]: 2026-04-10 16:14:00.067 [INF] IRPC: Baking macaroons for invoices RPC Server at: /home/lnd/.lnd/data/chain/bitcoin/mainnet/invoices.macaroon
Apr 10 16:14:00 minibolt lnd[74621]: 2026-04-10 16:14:00.067 [INF] RRPC: Making macaroons for Router RPC Server at: /home/lnd/.lnd/data/chain/bitcoin/mainnet/router.macaroon
Apr 10 16:14:00 minibolt lnd[74621]: 2026-04-10 16:14:00.068 [INF] SGNR: Making macaroons for Signer RPC Server at: /home/lnd/.lnd/data/chain/bitcoin/mainnet/signer.macaroon
Apr 10 16:14:00 minibolt lnd[74621]: 2026-04-10 16:14:00.069 [INF] WLKT: Baking macaroons for WalletKit RPC Server at: /home/lnd/.lnd/data/chain/bitcoin/mainnet/walletkit.macaroon
Apr 10 16:14:00 minibolt lnd[74621]: 2026-04-10 16:14:00.070 [INF] LTND: Systemd was notified about our readiness
Apr 10 16:14:00 minibolt lnd[74621]: 2026-04-10 16:14:00.071 [INF] LTND: Waiting for chain backend to finish sync rev=848b72 start_height=944487
Apr 10 16:14:00 minibolt lnd[74621]: 2026-04-10 16:14:00.995 [INF] BTWL: Started rescan from block 00000000000000000001eff0d57f1f698ac4e9a6e7a99024099797203d45646d (height 944082) for 0 addrs, 0 outpoints
[...]
```
{% endtab %}

{% tab title="Scenery 2" %}
<mark style="color:orange;">**If you had an old node and an existing cipher seed**</mark>

* Press `y` and enter to recover it

If you choose this option, the next step will be to enter the **seed words of your old node**

Expected output:

```
Input your 24-word mnemonic separated by spaces:
```

* Type your 24-word mnemonic separated by spaces and press enter

Expected output:

```
Input your cipher seed passphrase (press enter if your seed doesn't have a passphrase):
```

* If you used a passphrase, enter it; if not, press Enter again directly

{% hint style="info" %}
If you entered the passphrase incorrectly, don't worry, LND shows you the following log and will not run: `[lncli] rpc error: code = Unknown desc = invalid passphrase`. Recheck, and try again. If not, the prompt shows you the following
{% endhint %}

Expected output:

```
Input an optional address look-ahead used to scan for used keys (default 2500):
```

{% hint style="success" %}
Now the LND will enable the RECOVERY MODE
{% endhint %}

* **Press enter again** when the prompt above asks you, the default windows recovery is enough

**Example** of expected output:

```
Generating fresh cipher seed...

!!!YOU MUST WRITE DOWN THIS SEED TO BE ABLE TO RESTORE THE WALLET!!!

---------------BEGIN LND CIPHER SEED---------------
 1. ability   2. soap    3. album    4. resource
 5. plate     6. fiber   7. immune   8. fringe
[...]

!!!YOU MUST WRITE DOWN THIS SEED TO BE ABLE TO RESTORE THE WALLET!!!

lnd successfully initialized!
```

Return to the first terminal with `journalctl -f -u lnd`. Locate the following lines to verify LND properly enabled RECOVERY MODE ⬇️

<pre><code><strong>[...]
</strong>Jun 05 15:05:16 minibolt lnd[124224]: 2024-06-05 15:05:16.248 [INF] LNWL: Opened wallet
Jun 05 15:05:16 minibolt lnd[124224]: 2024-06-05 15:05:16.249 [INF] LTND: Wallet recovery mode enabled with address lookahead of 2500 addresses
Jun 05 15:05:16 minibolt lnd[124224]: 2024-06-05 15:05:16.442 [INF] LNWL: Started listening for bitcoind block notifications via ZMQ on 127.0.0.1:28332
Jun 05 15:05:16 minibolt lnd[124224]: 2024-06-05 15:05:16.442 [INF] LNWL: Started listening for bitcoind transaction notifications via ZMQ on 127.0.0.1:28333
Jun 05 15:05:16 minibolt lnd[124224]: 2024-06-05 15:05:16.442 [INF] CHRE: Initializing bitcoind backed fee estimator in CONSERVATIVE mode
Jun 05 15:05:18 minibolt lnd[124224]: 2024-06-05 15:05:18.762 [INF] LNWL: The wallet has been unlocked without a time limit
Jun 05 15:05:21 minibolt lnd[124224]: 2024-06-05 15:05:21.066 [INF] CHRE: LightningWallet opened
<strong>[...]
</strong><strong>Jun 05 19:47:08 minibolt lnd[124224]: 2023-11-26 19:47:08.642 [INF] LNWL: RECOVERY MODE ENABLED -- rescanning for used addresses with recovery_window=2500
</strong>Jun 05 19:47:08 minibolt lnd[124224]: 2023-11-26 19:47:08.685 [INF] LNWL: Seed birthday surpassed, starting recovery of wallet from height=2540246 hash=00000000000000178484e446a4fb5c966b5fd5db76121421bfa470c7c879ff05 with recovery-window=2500
Jun 05 19:47:09 minibolt lnd[124224]: 2023-11-26 19:47:09.859 [INF] LNWL: Scanning 311 blocks for recoverable addresses
Jun 05 19:48:36 minibolt lnd[124224]: 2023-11-26 19:48:36.328 [INF] LNWL: Recovered addresses from blocks 2540246-2540556
Jun 05 19:48:36 minibolt lnd[124224]: 2023-11-26 19:48:36.338 [INF] LNWL: Started rescan from block 000000000000001e297a052a69708908dbe9769d834a07447d85e446b6b4b2a0 (height 2540556) for 0 addresses
Jun 05 19:48:36 minibolt lnd[124224]: 2023-11-26 19:48:36.360 [INF] LNWL: Catching up block hashes to height 2540557, this might take a while
Jun 05 19:48:36 minibolt lnd[124224]: 2023-11-26 19:48:36.361 [INF] LNWL: Done catching up block hashes
Jun 05 19:48:36 minibolt lnd[124224]: 2023-11-26 19:48:36.361 [INF] LNWL: Finished rescan for 0 addresses (synced to block 00000000443337ee5135e26cc7611c570f0cfface2823516a59fee41fc9750b0, height 2540557)
[...]
</code></pre>
{% endtab %}
{% endtabs %}

{% hint style="info" %}
However, the current state of your channels cannot be recreated from this seed. For this, the Static Channel Backup is stored at `/data/lnd/data/chain/bitcoin/mainnet/channel.backup` and updated for each channel opening and closing

There is a dedicated [guide](channel-backup.md) for generating an automatic backup
{% endhint %}

* Return to the `admin` user

```sh
exit
```

{% hint style="info" %}
Remember that if you followed the [Unlock the LND wallet manually extra section](lightning-client.md#unlock-the-lnd-wallet-manually), you will need to manually type the `[ C ] LND wallet password` after entering the next command:

```bash
lncli --tlscertpath /data/lnd/tls.cert.tmp unlock
```
{% endhint %}

### Validation

* Check that LND is running and the related ports are listening

```bash
sudo ss -tulpn | grep lnd
```

Expected output:

```
tcp   LISTEN 0      4096       127.0.0.1:10009      0.0.0.0:*    users:(("lnd",pid=386562,fd=8))
tcp   LISTEN 0      4096       127.0.0.1:8080       0.0.0.0:*    users:(("lnd",pid=386562,fd=29))
tcp   LISTEN 0      4096       127.0.0.1:9735       0.0.0.0:*    users:(("lnd",pid=386562,fd=45))
tcp   LISTEN 0      4096               *:9911             *:*    users:(("lnd",pid=386562,fd=44))
```

### Allow user "admin" to work with LND

We interact with LND using the application `lncli`. At the moment, only the user `lnd` has the necessary access privileges. To make the user "admin" the main administrative user, we make sure it can interact with LND as well.

* As user `admin`, link the LND data directory in the user `admin` home. As a member of the group `lnd`, the `admin` user has read-only access to certain files

```sh
ln -s /data/lnd /home/admin/.lnd
```

* Check that the symbolic link has been created correctly

```bash
ls -la /home/admin
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

<pre><code>total 96
drwxr-x--- 10 admin admin  4096 Jul 18 07:10 .
drwxr-xr-x  8 root  root   4096 Jul 16 09:28 ..
-rw-rw-r--  1 admin admin 13901 Jul 12 15:54 .bash_aliases
-rw-------  1 admin admin 13993 Jul 18 06:31 .bash_history
-rw-r--r--  1 admin admin   220 Jul 11 20:25 .bash_logout
-rw-r--r--  1 admin admin  3792 Jul 12 07:56 .bashrc
lrwxrwxrwx  1 admin admin    13 Jul 12 10:41 .bitcoin -> /data/bitcoin
drwx------  2 admin admin  4096 Jul 11 20:27 .cache
drwxrwxr-x  5 admin admin  4096 Jul 12 07:57 .cargo
drwxrwxr-x  3 admin admin  4096 Jul 11 20:32 .config
drwx------  3 admin admin  4096 Jul 15 20:54 .gnupg
-rw-------  1 admin admin    20 Jul 11 22:09 .lesshst
lrwxrwxrwx  1 admin admin     9 Jul 18 07:10 <a data-footnote-ref href="#user-content-fn-13">.lnd -> /data/lnd</a>
drwxrwxr-x  3 admin admin  4096 Jul 12 09:15 .local
drwxrwxr-x  3 admin admin  4096 Jul 16 09:23 .npm
-rw-r--r--  1 admin admin   828 Jul 12 07:56 .profile
drwxrwxr-x  6 admin admin  4096 Jul 12 07:56 .rustup
drwx------  2 admin admin  4096 Jul 11 20:47 .ssh
-rw-r--r--  1 admin admin     0 Jul 11 20:27 .sudo_as_admin_successful
-rw-rw-r--  1 admin admin   293 Jul 15 20:53 .wget-hsts
-rw-------  1 admin admin   228 Jul 18 07:04 .Xauthority
</code></pre>

</details>

* Make all directories browsable for the group

```sh
sudo chmod -R g+X /data/lnd/data/
```

* And allow it to read the file `admin.macaroon`

```bash
sudo chmod g+r /data/lnd/data/chain/bitcoin/mainnet/admin.macaroon
```

* Check if you can use `lncli` with the `admin` user by querying LND for information

```sh
lncli getinfo | grep -A2 '"uris":'
```

Example of expected output:

```
"uris":  [
        "030f289f0f921cd33cc3435dc5f5tc2a6a65bb0297327d43e82562aded20df74b7@zscl5v323mngmeyu33wyrlkqyc3emaiv7pdezxjfrtu5qegedvmrtpud.onion:9735"
    ],
```

## LND in action

{% hint style="success" %}
Now your Lightning node is ready. This is also the point of no return. Up until now, you could just start over. Once you send real Bitcoin to your MiniBolt, you have "skin in the game"
{% endhint %}

{% hint style="info" %}
Subsequent commands can be entered in new sessions without needing to keep this terminal open for logs. However, retaining this session is recommended in case logs provide additional context for the preceding command
{% endhint %}

### Watchtower client

Lightning channels need to be monitored to prevent malicious behavior by your channel peers. If your MiniBolt goes down for a longer time, for instance, due to a hardware problem, a node on the other side of one of your channels might try to close the channel with an earlier channel balance that is better for them.

Watchtowers are other Lightning nodes that can monitor your channels for you. If they detect such bad behavior, they can react on your behalf by sending a punishing transaction to close this channel. In this case, all channel funds will be sent to your LND on-chain wallet.

A watchtower can only send such a punishing transaction to your wallet, so you don't have to trust them. It's good practice to add a few watchtowers, just to be on the safe side.

* With user `admin`, add any Watchtower Server address that someone gives you

<pre class="language-bash" data-overflow="wrap"><code class="lang-bash">lncli wtclient add <a data-footnote-ref href="#user-content-fn-14">pubkey</a>@<a data-footnote-ref href="#user-content-fn-14">address</a>:9911
</code></pre>

* If you want to list your towers and active watchtowers

```sh
lncli wtclient towers
```

Example of expected output:

```
{
    "towers": [
        {
            "pubkey": "03ad48b4e41cfce258e2db8d7ec9a194570ca29bebo2897970d1ecc7d1c9a2726c",
            "addresses": [
                "zm32w2qs2lf6xljnvqnmv6o2xlufsf4g6vfjihyydg4yhxph4fnqcvyd.onion:9911"
            ],
            "active_session_candidate": true,
            "num_sessions": 0,
            "sessions": [
            ]
        },
    ]
}
```

* If you want to remove an active tower

```sh
lncli wtclient remove <pubkey>
```

{% hint style="info" %}
Monitor logs with `journalctl -fu lnd` to verify the watchtower client is working correctly. The following logs should be shown after some time ⬇️
{% endhint %}

<figure><img src="../.gitbook/assets/lnd-watchtower_log.PNG" alt=""><figcaption></figcaption></figure>

### Watchtower server

Similarly, you can connect as a watchtower client to other watchtower servers, and you could provide the same service by running an altruistic watchtower server. **This was previously activated** in the `lnd.conf`, and you can see the information about it by typing the following command and sharing it with your peers.

```sh
lncli tower info
```

**Example** of expected output:

```
{
  "pubkey": "03ad48b4e41cfce258e2db8d7ec9a194570ca29bebo2897970d1ecc7d1c9a2726c",
  "listeners": [
      "[::]:9911"
  ],
  "uris": [
      "zm32w2qs2lf6xljnvqnmv6o2xlufsf4g6vfjihyydg4yhxph4fnqcvyd.onion:9911"
  ]
}
```

{% hint style="warning" %}
This watchtower server service is not recommended to activate if you have a slow device without high-performance features. If so, consider disabling it by commenting or deleting the line `watchtower.active=true` in the `lnd.conf` file
{% endhint %}

{% hint style="info" %}
Almost all of the following steps can be run with the [mobile](mobile-app.md) | [web](web-app.md) app guides. We strongly recommend using these applications with an intuitive and visual UI to manage the Lightning Node, instead of using the command line. If you still want to explore the use of `lncli`, there are some useful commands in the[ extra section](lightning-client.md#some-useful-lncli-commands)
{% endhint %}

## Extras (optional)

### Use the default bbolt database backend

Once you have skipped the previous section of the [PostgreSQL installation](lightning-client.md#install-postgresql), and when you arrive at the [Configuration section](lightning-client.md#configuration), modify `lnd.conf` file

* With user `lnd`, edit `lnd.conf`

```bash
nano /data/lnd/lnd.conf
```

* Replace `# Database` section about the PostgreSQL database backend

```
[db]
## Database
db.backend=postgres

[postgres]
db.postgres.dsn=postgresql://admin:admin@127.0.0.1:5432/lndb?sslmode=disable
db.postgres.timeout=0
```

* To this

```
[bolt]
## Database
# Set the next value to false to disable auto-compact DB
# and fast boot and comment the next line
db.bolt.auto-compact=true
# Uncomment to do DB compact at every LND reboot (default: 168h)
#db.bolt.auto-compact-min-age=0h
```

* Return to the `admin` user

```bash
exit
```

{% hint style="info" %}
Continue with the guide in the [Create systemd service](lightning-client.md#create-systemd-service) section
{% endhint %}

### Migrate an existing bbolt database to PostgreSQL

{% hint style="danger" %}
Attention: It is recommended to start from scratch by closing all existing channels, rather than a migration, to ensure we don't lose anything because it is not possible to come back to the old bbolt database once migrated
{% endhint %}

#### Install lndinit

{% hint style="info" %}
After all, check if you have chantools installed:

* With user `admin`, check if you have already installed chantools

{% code overflow="wrap" %}
```bash
lndinit -h
```
{% endcode %}

-> If you obtain this **example** of expected output, you can move to the next section.:

```
2026-03-25 18:23:46.009 [INF]: LNDINIT Version 0.1.33-beta commit=v0.1.33-beta, debuglevel=
Usage:
  lndinit [OPTIONS] <command>

Application Options:
  -e, --error-on-existing  Exit with code EXIT_CODE_TARGET_EXISTS (128) instead of 0 if the result of an action is already present
  -d, --debuglevel=        Set the log level (Off, Critical, Error, Warn, Info, Debug, Trace)
  -v, --verbose            Turn on logging to stderr
  [...]
```

-> If lndinit is not installed (`-bash: lndinit: command not found`), follow the [lndinit bonus guide](../bonus-guides/lightning/lndinit.md) to get instructions to install or use only [lndinit](https://github.com/lightninglabs/lndinit)
{% endhint %}

#### Migrate bbolt database to PostgreSQL

* With user `admin`, stop lnd

```bash
sudo systemctl stop lnd
```

* Confirm and ensure that LND is stopped successfully by monitoring the logs

```bash
journalctl -fu lnd
```

Expected output:

<pre><code>May 30 20:44:36 minibolt lnd[314082]: 2024-05-30 20:44:36.840 [INF] INVC: Cancelling invoice subscription for client=1
May 30 20:44:36 minibolt lnd[314082]: 2024-05-30 20:44:36.855 [ERR] RPCS: [/routerrpc.Router/SubscribeHtlcEvents]: context canceled
May 30 20:44:36 minibolt lnd[314082]: 2024-05-30 20:44:36.861 [ERR] RPCS: [/routerrpc.Router/SubscribeHtlcEvents]: context canceled
May 30 20:44:48 minibolt lnd[314082]: 2024-05-30 20:44:48.927 [INF] CRTR: Processed channels=0 updates=21 nodes=0 in last 1m0.000123683s
May 30 20:45:02 minibolt systemd[1]: Stopping Lightning Network Daemon...
May 30 20:45:02 minibolt lnd[314082]: 2024-05-30 20:45:02.606 [INF] LTND: Received shutdown request.
May 30 20:45:02 minibolt lnd[314082]: 2024-05-30 20:45:02.609 [INF] LTND: Shutting down...
May 30 20:45:02 minibolt lnd[314082]: 2024-05-30 20:45:02.612 [INF] LTND: Systemd was notified about stopping
May 30 20:45:02 minibolt lnd[314082]: 2024-05-30 20:45:02.612 [INF] LTND: Gracefully shutting down.
May 30 20:45:02 minibolt lnd[314082]: 2024-05-30 20:45:02.615 [INF] WTWR: Stopping watchtower
May 30 20:45:02 minibolt systemd[1]: lnd.service: Succeeded.
May 30 20:45:02 minibolt systemd[1]: <a data-footnote-ref href="#user-content-fn-3">Stopped Lightning Network Daemon.</a>
May 30 20:45:02 minibolt systemd[1]: lnd.service: Consumed 12h 11min 606ms CPU time.
</code></pre>

* Previously followed:
  1. [Install PostgreSQL section](lightning-client.md#install-postgresql)
  2. [Create PostgreSQL database section](lightning-client.md#create-postgresql-database)
* Depending on whether you selected in the [lndinit bonus guide](../bonus-guides/lightning/lndinit.md) the [option 1](../bonus-guides/lightning/lndinit.md#id-1.-temporary-use-recommended) or [option 2](../bonus-guides/lightning/lndinit.md#id-2.-permanent-installation):

{% tabs %}
{% tab title="1. For temporary use option (recommended)" %}
- Go to the `lndinit` folder

```bash
cd lndinit-linux-amd64-v$VERSION-beta
```

* Execute the migration and wait for completion

```bash
sudo ./lndinit --debuglevel info migrate-db \
      --chunk-size=200000000 \
      --force-verify-db \
      --source.bolt.data-dir /home/admin/.lnd/data \
      --source.bolt.tower-dir /home/admin/.lnd/data \
      --dest.postgres.dsn=postgresql://admin:admin@127.0.0.1:5432/lndb?sslmode=disable \
      --dest.postgres.timeout=0
```

{% hint style="info" %}
This process could take a few minutes, depending on the database size. The prompt returns after the logs indicate a successful migration
{% endhint %}
{% endtab %}

{% tab title="2. For permanent installation option" %}
* Execute the migration and wait for it to finish

```bash
sudo lndinit --debuglevel info migrate-db \
      --chunk-size=200000000 \
      --force-verify-db \
      --source.bolt.data-dir /home/admin/.lnd/data \
      --source.bolt.tower-dir /home/admin/.lnd/data \
      --dest.postgres.dsn=postgresql://admin:admin@127.0.0.1:5432/lndb?sslmode=disable \
      --dest.postgres.timeout=0
```

{% hint style="info" %}
This process could take a few minutes, depending on the database size. The prompt returns after the logs indicate a successful migration
{% endhint %}
{% endtab %}
{% endtabs %}

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
2025-04-19 15:36:04.541 [INF]: LNDINIT Version 0.1.26-beta commit=v0.1.26-beta, debuglevel=info
2025-04-19 15:36:04.543 [INF]: LNDINIT Attempting to migrate DB with prefix `channeldb`
2025-04-19 15:36:04.543 [INF]: LNDINIT Opening bolt backend at /home/admin/.lnd/data/graph/mainnet/channel.db for prefix 'channeldb'
2025-04-19 15:36:04.544 [INF]: LNDINIT Opened source DB with prefix `channeldb` successfully
2025-04-19 15:36:04.544 [INF]: LNDINIT Opening postgres backend at `postgresql://admin:admin@127.0.0.1:5432/lndb?sslmode=disable` with prefix `channeldb`
2025-04-19 15:36:04.621 [INF]: LNDINIT Opened destination DB with prefix `channeldb` successfully
2025-04-19 15:36:04.621 [INF]: LNDINIT Checking tombstone marker on source DB and migrated marker on destination DB with prefix `channeldb`
2025-04-19 15:36:04.629 [INF]: LNDINIT Checking DB version of source DB (channel.db)
2025-04-19 15:36:04.644 [INF]: LNDINIT Opened meta db at path: /home/admin/.lnd/data/channeldb-migration-meta.db
2025-04-19 15:36:04.644 [INF] MIGKV-channeldb: LNDINIT Migrating database with prefix `channeldb`
2025-04-19 15:36:04.644 [INF] MIGKV-channeldb: LNDINIT No previous migration state found, starting fresh
2025-04-19 15:36:04.649 [INF] MIGKV-channeldb: LNDINIT Migrating root bucket: 0x43f08bdab050e35b567c864b91f47f50ae725ae2de53bcfbbaf284da00000000741137146110d360c09ed86c73d235f57b93a6b7ad050dd431f9603d9e28112800000001
2025-04-19 15:36:04.653 [INF] MIGKV-channeldb: LNDINIT Migrating root bucket: alias-alloc-bucket
2025-04-19 15:36:04.655 [INF] MIGKV-channeldb: LNDINIT Migrating root bucket: alias-bucket
2025-04-19 15:36:04.659 [INF] MIGKV-channeldb: LNDINIT Migrating root bucket: base-bucket
2025-04-19 15:36:04.663 [INF] MIGKV-channeldb: LNDINIT Migrating root bucket: chan-id-bucket
2025-04-19 15:36:04.666 [INF] MIGKV-channeldb: LNDINIT Migrating root bucket: channelOpeningState
2025-04-19 15:36:04.667 [INF] MIGKV-channeldb: LNDINIT Migrating root bucket: circuit-adds
2025-04-19 15:36:04.668 [INF] MIGKV-channeldb: LNDINIT Migrating root bucket: circuit-fwd-log
2025-04-19 15:36:04.669 [INF] MIGKV-channeldb: LNDINIT Migrating root bucket: circuit-keystones
[...]
2025-04-19 16:05:44.288 [INF]: LNDINIT Attempting to migrate DB with prefix `neutrinodb`
2025-04-19 16:05:44.288 [INF]: LNDINIT Opening bolt backend at /home/admin/.lnd/data/chain/bitcoin/mainnet/neutrino.db for prefix 'neutrinodb'
2025-04-19 16:05:44.288 [WRN]: LNDINIT Skipping optional DB neutrinodb: not found
2025-04-19 16:05:44.288 [INF]: LNDINIT !!!Migration of all mandatory db parts completed successfully!!!
2025-04-19 16:05:44.288 [INF]: LNDINIT Migrated DBs: [channeldb macaroondb decayedlogdb towerclientdb towerserverdb walletdb]
```

</details>

* **(Optional)** If you used the [1. For temporary use](lightning-client.md#id-1.-for-temporary-use-recommended) option, clean the `lndinit` files in the `tmp` folder

<pre class="language-bash" data-overflow="wrap"><code class="lang-bash"><strong>sudo rm -r /tmp/lndinit-linux-amd64-v$VERSION-beta &#x26;&#x26; sudo rm /tmp/lndinit-linux-amd64-v$VERSION-beta.tar.gz &#x26;&#x26; sudo rm /tmp/manifest-v$VERSION-beta.sig &#x26;&#x26; sudo rm /tmp/manifest-v$VERSION-beta.txt &#x26;&#x26; sudo rm /tmp/manifest-v$VERSION-beta.sig.ots
</strong></code></pre>

* Now, edit the `lnd.conf` configuration file to use the PostgreSQL database as the backend

```bash
sudo nano /data/lnd/lnd.conf
```

* Replace or comment with "`#`" the `# Database` section about the bbolt database backend

```
#[bolt]
# Set the next value to false to disable auto-compact DB
# and fast boot and comment the next line
#db.bolt.auto-compact=true
# Uncomment to do DB compact at every LND reboot (default: 168h)
#db.bolt.auto-compact-min-age=0h
```

* To this

```
[db]
db.backend=postgres

[postgres]
db.postgres.dsn=postgresql://admin:admin@127.0.0.1:5432/lndb?sslmode=disable
db.postgres.timeout=0
```

* Edit the [systemd service file](lightning-client.md#create-systemd-service)

```bash
sudo nano /etc/systemd/system/lnd.service
```

* Replace the following lines to include the `postgres.service` dependency

```
Requires=bitcoind.service postgresql.service
After=bitcoind.service postgresql.service
```

* Reload the systemd daemon

```bash
sudo systemctl daemon-reload
```

* Start LND again

```bash
sudo systemctl start lnd
```

* Monitor the LND logs to ensure all is working correctly with the new, successfully migrated PostgreSQL database backend

```bash
journalctl -fu lnd
```

{% hint style="info" %}
-> The `[WRN]` logs indicate that LND has detected an existing, old bbolt database, and it will not be migrated to PostgreSQL automatically, but we already migrated it before 😏

```
[...]
[WRN] LTND: Found existing bbolt database file in /home/lnd/.lnd/data/chain/bitcoin/mainnet/wallet.db while using database type postgres. Existing data will NOT be migrated to postgres automatically!
[WRN] LTND: Found existing bbolt database file in /home/lnd/.lnd/data/graph/mainnet/channel.db while using database type postgres. Existing data will NOT be migrated to postgres automatically!
[...]
```

-> You can delete these logs by following the [next section](lightning-client.md#optional-delete-old-bbolt-files-database)

-> Pay attention to this significant `[INF]` log to confirm you are now using PostgreSQL

```
[...]
[INF] LTND: Using remote postgres database! Creating graph and channel state DB instances
[...]
```
{% endhint %}

{% hint style="info" %}
Ensure you still have your node in the same situation before the migration using the [Web app: ThunderHub](web-app.md), or using `lncli` with commands like `lncli listchannels / lncli listunspent / lncli wtclient towers` and see if everything is as you left it before the migration
{% endhint %}

#### **(Optional)** Delete old bbolt files database

* With user `admin`, detele the old bbolt database files

{% code overflow="wrap" %}
```bash
sudo rm /data/lnd/data/chain/bitcoin/mainnet/macaroons.db && sudo rm /data/lnd/data/chain/bitcoin/mainnet/macaroons.db* && sudo rm /data/lnd/data/chain/bitcoin/mainnet/wallet.db && sudo rm /data/lnd/data/chain/bitcoin/mainnet/wallet.db* && sudo rm /data/lnd/data/graph/mainnet/* && sudo rm /data/lnd/data/watchtower/bitcoin/mainnet/*
```
{% endcode %}

### Some useful lncli commands

Quick reference with special commands to play around with:

#### -> Create your own Re-Usable Static AMP invoice

{% code overflow="wrap" %}
```bash
lncli addinvoice --memo "your memo here" --amt <amount in sats> --expiry <time in seconds> --amp
```
{% endcode %}

{% hint style="info" %}
The flags `--memo` |`--amt` & `--expiry` are optional. The default expiry time will be 30 days by default and the rest can be empty

Copy the output `[lnbc...]` of the "payment\_request": "`lnbc...`". Transform your output payment request into a QR code, embed it on your website, or add it to your social media. LibreOffice has built-in functionality, and there are plenty of freely available online tools
{% endhint %}

#### -> Pay an AMP invoice (both sender and receiver nodes need to have AMP enabled)

```sh
lncli payinvoice --amt <amount> <amp invoice>
```

#### -> Send payment to the node without invoice using AMP invoice (both sender and receiver nodes need to have AMP enabled)

```sh
lncli sendpayment --dest <destination public key> --amt <amount> --amp
```

**Example** of expected output:

```
// Some code+------------+--------------+--------------+--------------+-----+----------+---------------------+--------------------+
| HTLC_STATE | ATTEMPT_TIME | RESOLVE_TIME | RECEIVER_AMT | FEE | TIMELOCK | CHAN_OUT            | ROUTE              |
+------------+--------------+--------------+--------------+-----+----------+---------------------+--------------------+
| SUCCEEDED  |        0.017 |        4.789 | 10000        | 0   |  2819586 | 3100070835543670784 | 2FakTor⚡Testnet🧪 |
+------------+--------------+--------------+--------------+-----+----------+---------------------+--------------------+
Amount + fee:   10000 + 0 sat
Payment hash:   466351a225dfff6b7205c1397c2c19d803c87e888baa0d845050498ade44f4fe
Payment status: SUCCEEDED, preimage: 7c7c34c655eaea4f683db53f22ca2f5256758eb260f2c355d815b71977e3308f
```

{% hint style="info" %}
If you want to send a circular payment to yourself, add this flag at the end of the command:`--allow_self_payment`
{% endhint %}

#### -> Extract the SegWit and Taproot master public key of your onchain LND wallet

{% code overflow="wrap" %}
```bash
lncli wallet accounts list | grep -A 3 "TAPROOT" && echo "------------------------" && \
lncli wallet accounts list | grep -B 3 "m/84"
```
{% endcode %}

Example of expected output:

<pre><code>            "address_type":  "TAPROOT_PUBKEY",
            "extended_public_key":  "<a data-footnote-ref href="#user-content-fn-15">xpub........</a>",
            "master_key_fingerprint":  "",
            "derivation_path":  "m/86'/0'/0'",
------------------------
            "address_type":  "WITNESS_PUBKEY_HASH",
            "extended_public_key":  "<a data-footnote-ref href="#user-content-fn-16">zpub.........</a>",
            "master_key_fingerprint":  "",
            "derivation_path":  "m/84'/0'/0'",
</code></pre>

#### -> Delete all failed HTLC payment attempts

{% code overflow="wrap" %}
```bash
lncli deletepayments --all --failed_htlcs_only
```
{% endcode %}

**Example** of expected output:

{% code overflow="wrap" %}
```
Removing failed HTLCs from failed payments, this might take a while...
{
    "status": "0 payments deleted, failed_htlcs_only=true"
}
```
{% endcode %}

#### -> Delete ALL payments, not just the failed ones

```bash
lncli deletepayments --all --include_non_failed
```

**Example** of expected output:

```
Removing all payments, this might take a while...
{
    "status": "7 payments deleted, failed_htlcs_only=false"
}
```

#### -> Open multiple channels in a single transaction

{% hint style="info" %}
It is recommended to connect to the peer previously with the next command:

{% code overflow="wrap" %}
```bash
lncli connect <peer_node_public_key>@host:port
```
{% endcode %}

Replace:

> `<peer_node_public_key>@host:port` with the desired peer node, ask to your peer about this information obtained with `lncli getinfo | grep -A2 '"uris":'` command

-> Repeat this action with each peer you desire to open a channel with.
{% endhint %}

```bash
lncli batchopenchannel --sat_per_vbyte=X '[{
  "node_pubkey": "<peer1_node_public_key>",
  "local_funding_amount": <amount_in_sats>,
  "private": <true>,
  "close_address": "bc1p..."
}, {
  "node_pubkey": "<peer2_node_public_key>",
  "local_funding_amount": <amount_in_sats>,
  "private": <false>,
  "close_address": "bc1p..."
}]'
```

{% hint style="info" %}
Replace:

> `-sat_per_vbyte=X` with the desired fee e.g. `--sat_per_vbyte=1`

> `<peer1_node_public_key>` with the desired peer node e.g. `039a53a85abd18ae5087e8fc99d2f2b09543bfd8e68072810f6900541e279c7615`

> `<peer2_node_public_key>` with the desired peer node e.g. `02f0bf82f730d2e68453cc612c3e7ca5e021eaa1ead8250a6380c551d1d43bdc1b`

> `<amount_in_sats>` with the desired channel capacity e.g `500000`

> `<true>` / `<false>` depending if you want to open a private or public channel. **Optional**: if you want to open a public channel, you can delete this parameter. Default is `false`

> `bc1p...` with the desired close adresss. **Optional**: if this parameter is not specified, LND will choose an address in its own onchain wallet.
{% endhint %}

**Example** of a completed command that opens **2 channels**: one private and one public, each with a capacity of 500.000 sats, using an opening fee of 1 sat/vbyte, and specifying a closing address for the private channel:

```bash
lncli batchopenchannel --sat_per_vbyte=1 '[{
  "node_pubkey": "039a53a85abd18ae5087e8fc99d2f2b09543bfd8e68072810f6900541e279c7615",
  "local_funding_amount": 500000,
  "private": true,
  "close_address": "bc1qe57rkj0c0yllxl3n60qjg7s3urwd0vrhw8t3s7"
}, {
  "node_pubkey": "02f0bf82f730d2e68453cc612c3e7ca5e021eaa1ead8250a6380c551d1d43bdc1b",
  "local_funding_amount": 500000,
  "private": false
}]'
```

**Example** of a completed command that opens **3 channels**: **one private** channel with a capacity of 1.000.000 sats and a specified closing address, and two public channels with capacities of 500.000 sats and 1.000.000 sats respectively, using an opening fee of 5 sat/vbyte:

```bash
lncli batchopenchannel --sat_per_vbyte=5 '[{
  "node_pubkey": "03f760285d9ee0848d333995ac8a48e0a6d15d7f5981877be25311e20b0be39c33",
  "local_funding_amount": 1000000,
  "private": true,
  "close_address": "bc1qe57rkj0c0yllxl3n60qjg7s3urwd0vrhw8t3s7"
}, {
  "node_pubkey": "039a53a85abd18ae5087e8fc99d2f2b09543bfd8e68072810f6900541e279c7615",
  "local_funding_amount": 500000,
}, {
  "node_pubkey": "02f0bf82f730d2e68453cc612c3e7ca5e021eaa1ead8250a6380c551d1d43bdc1b",
  "local_funding_amount": 1000000
}]'
```

### Unlock the LND wallet manually

Storing a password in plain text is not secure; that's why it is recommended to unlock LND manually. Follow the next steps to get that:

* With user `admin`, stop `lnd`

```bash
sudo systemctl stop lnd
```

* Edit the `lnd.conf` file

```bash
sudo nano /data/lnd/lnd.conf
```

* Comment or delete the next lines in `# Automatically unlock wallet`... section

```
#wallet-unlock-password-file=/data/lnd/password.txt
#wallet-unlock-allow-create=true
```

* Start `lnd` again

```bash
sudo systemctl start lnd
```

* Unlock the wallet manually with the next command. Enter your `[ C ] LND wallet password` and press enter

```bash
lncli --tlscertpath /data/lnd/tls.cert.tmp unlock
```

Expected output:

<pre><code>Input wallet password: &#x3C;<a data-footnote-ref href="#user-content-fn-17">[ C ] LND wallet password</a>>
</code></pre>

After unlock:

```
lnd successfully unlocked!
```

* Monitor the logs by using `journalctl -fu lnd` to ensure LND started successfully

```bash
journalctl -fu lnd
```

<details>

<summary><strong>Example</strong> of expected output with <code>journalctl -fu lnd</code> ⬇️</summary>

<pre><code>Mar 01 13:27:24 minibolt systemd[1]: Starting lnd.service - Lightning Network Daemon...
Mar 01 13:27:25 minibolt lnd[435474]: Attempting automatic RPC configuration to bitcoind
Mar 01 13:27:25 minibolt lnd[435474]: Automatically obtained bitcoind's RPC credentials
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.071 [INF] LTND: Version Info rev=848b72 version=0.20.1-beta commit=v0.20.1-beta debuglevel=production logging=info
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.071 [INF] LTND: Network Info rev=848b72 active_chain=Bitcoin network=testnet4
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.071 [INF] RPCS: Generating ephemeral TLS certificates...
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.072 [INF] RPCS: Done generating ephemeral TLS certificates
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.075 [INF] RPCS: RPC server listening on 127.0.0.1:10009
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.106 [INF] RPCS: gRPC proxy started at 127.0.0.1:8080
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.106 [INF] LTND: Opening the main database, this might take a few minutes...
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.144 [INF] SQLD: Using SQL database 'postgresql://admin:***@127.0.0.1:5432/lndb?sslmode=disable'
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.164 [INF] LTND: Using remote postgres database! Creating graph and channel state DB instances
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.175 [INF] CHDB: Checking for schema update: latest_version=33, db_version=33
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.176 [INF] CHDB: Applying 2 optional migrations
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.176 [INF] CHDB: Checking for optional update: name=prune_revocation_log
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.176 [INF] CHDB: Checking for optional update: name=gc_decayed_log
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.179 [INF] SQLD: Skipping migration '000001_invoices' (version 1) as it has already been applied
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.179 [INF] SQLD: Skipping migration '000002_amp_invoices' (version 2) as it has already been applied
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.179 [INF] SQLD: Skipping migration '000003_invoice_events' (version 3) as it has already been applied
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.179 [INF] SQLD: Skipping migration '000004_invoice_expiry_fix' (version 4) as it has already been applied
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.179 [INF] SQLD: Skipping migration '000005_migration_tracker' (version 5) as it has already been applied
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.179 [INF] SQLD: Skipping migration '000006_invoice_migration' (version 6) as it has already been applied
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.179 [INF] SQLD: Skipping migration 'kv_invoice_migration' (version 7) as it has already been applied
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.179 [INF] SQLD: Skipping migration '000007_invoice_add_settled_index' (version 8) as it has already been applied
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.179 [INF] SQLD: Skipping migration '000008_graph' (version 9) as it has already been applied
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.179 [INF] SQLD: Skipping migration 'kv_graph_migration' (version 10) as it has already been applied
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.204 [INF] LTND: Database(s) now open (time_to_open=98.408847ms)!
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.207 [INF] LTND: Systemd was notified about our readiness
Mar 01 13:27:25 minibolt lnd[435474]: 2026-03-01 13:27:25.208 [INF] LTND: Waiting for wallet encryption password. Use `lncli create` to create a wallet, `lncli unlock` to unlock an existing wallet, or `lncli changepassword` to change the password of an existing wallet and unlock it.
Mar 01 13:27:25 minibolt systemd[1]: Started lnd.service - Lightning Network Daemon.
[Waiting to unlock manually with the proper command]
Mar 01 13:32:37 minibolt lnd[435474]: 2026-03-01 13:32:37.468 [INF] BTWL: <a data-footnote-ref href="#user-content-fn-3">Opened wallet</a>
Mar 01 13:32:37 minibolt lnd[435474]: 2026-03-01 13:32:37.615 [INF] RPCC: Established connection to RPC server localhost:48332
Mar 01 13:32:37 minibolt lnd[435474]: 2026-03-01 13:32:37.615 [INF] RPCC: Established connection to RPC server localhost:48332
Mar 01 13:32:37 minibolt lnd[435474]: 2026-03-01 13:32:37.639 [INF] BTWL: Started listening for bitcoind block notifications via ZMQ on 127.0.0.1:28332
Mar 01 13:32:37 minibolt lnd[435474]: 2026-03-01 13:32:37.639 [INF] BTWL: Started listening for bitcoind transaction notifications via ZMQ on 127.0.0.1:28333
Mar 01 13:32:37 minibolt lnd[435474]: 2026-03-01 13:32:37.639 [INF] CHRE: Initializing bitcoind backed fee estimator in CONSERVATIVE mode
Mar 01 13:32:37 minibolt lnd[435474]: 2026-03-01 13:32:37.639 [INF] RPCC: Established connection to RPC server localhost:48332
Mar 01 13:32:37 minibolt lnd[435474]: 2026-03-01 13:32:37.639 [INF] RPCC: Established connection to RPC server localhost:48332
Mar 01 13:32:39 minibolt lnd[435474]: 2026-03-01 13:32:39.784 [INF] BTWL: The wallet has been unlocked without a time limit
Mar 01 13:32:39 minibolt lnd[435474]: 2026-03-01 13:32:39.974 [INF] CHRE: LightningWallet opened
Mar 01 13:32:39 minibolt lnd[435474]: 2026-03-01 13:32:39.986 [INF] SRVR: Proxying all network traffic via Tor! NOTE: Ensure the backend node is proxying over Tor as well rev=848b72 stream_isolation=true
Mar 01 13:32:39 minibolt lnd[435474]: 2026-03-01 13:32:39.991 [INF] TORC: Starting tor controller
[...]
</code></pre>

</details>

{% hint style="info" %}
**(Optional)** Now you can delete the `password.txt` file from your LND folder by typing with the user `admin`:

```bash
sudo rm /data/lnd/password.txt
```

⚠️Remember to back up your `[ C ] LND wallet password` in a secure location
{% endhint %}

### Open a Channel with External Funding

**lncli**

* With user `admin`, type the next command

{% hint style="info" %}
It is recommended to connect to the peer previously with the next command:

{% code overflow="wrap" %}
```bash
lncli connect <peer_node_public_key>@host:port
```
{% endcode %}

Replace:

> `<peer_node_public_key>@host:port` with the desired peer node, ask to your peer about this information obtained with `lncli getinfo | grep -A2 '"uris":'` command
{% endhint %}

<pre class="language-bash" data-overflow="wrap"><code class="lang-bash">lncli openchannel --node_key <a data-footnote-ref href="#user-content-fn-14">&#x3C;peer_node_public_key></a> --local_amt <a data-footnote-ref href="#user-content-fn-14">&#x3C;amount_in_sats></a> --psbt
</code></pre>

{% hint style="info" %}
Replace:

> `<peer_node_public_key>`: public key of yout peer node, ask to your peer about this information obtained with `lncli getinfo | grep -A2 '"uris":'` command
>
> `<amount_in_sats>`: desired channel capacity, e.g 1000000 sats
{% endhint %}

**Example** of expected output:

<pre data-overflow="wrap"><code>Starting PSBT funding flow with pending channel ID <a data-footnote-ref href="#user-content-fn-18">693ddd43693ed8d620547ee77b729fcd68bb09853ff1bfec0e247514588c44aa</a>.
PSBT funding initiated with peer <a data-footnote-ref href="#user-content-fn-18">039a53a85abd18ae5087e8fc99d2f2b09543bfd8e68072810f6900541e279c7615</a>.
Please create a PSBT that sends <a data-footnote-ref href="#user-content-fn-18">0.01000000</a> BTC (<a data-footnote-ref href="#user-content-fn-18">1000000</a> satoshi) to the funding address <a data-footnote-ref href="#user-content-fn-18">tb1qaxpkscscpe3nqnjkvlv3msww2hs2mtflgdeknam79efdxdj88rzq50wes4</a>.

Note: The whole process should be completed within 10 minutes, otherwise there
is a risk of the remote node timing out and canceling the funding process.

Example with bitcoind:
        bitcoin-cli walletcreatefundedpsbt [] '[{"<a data-footnote-ref href="#user-content-fn-18">tb1qaxpkscscpe3nqnjkvlv3msww2hs2mtflgdeknam79efdxdj88rzq50wes4</a>":<a data-footnote-ref href="#user-content-fn-18">0.01000000</a>}]'

If you are using a wallet that can fund a PSBT directly (currently not possible
with bitcoind), you can use this PSBT that contains the same address and amount:
<a data-footnote-ref href="#user-content-fn-18">cHNidP8BADUCAAAAAAFAQg8AAAAAACIAIOmDaGIYDmMwTlZn2R3BzlXgra0/Q3Np934uUtM2RzjEAAAAAAAA</a>

!!! WARNING !!!
DO NOT PUBLISH the finished transaction by yourself or with another tool.
lnd MUST publish it in the proper funding flow order OR THE FUNDS CAN BE LOST!

Paste the funded PSBT here to continue the funding flow.
If your PSBT is very long (specifically, more than 4096 characters), please save
it to a file and paste the full file path here instead as some terminals will
truncate the pasted text if it's too long.
Base64 encoded PSBT (or path to file):
</code></pre>

{% hint style="info" %}
Keep the terminal open and go to [Sparrow wallet](../bitcoin/bitcoin/desktop-signing-app-sparrow.md) on your regular computer
{% endhint %}

**Sparrow**

* Open your new or existing external wallet (hotwallet or hardware wallet)

> - File > **Open Wallet / Create wallet**

> * Create TX (Push the **\[Send]** button) with the next information:
>
> > `<address>`: provided by LND (in the previous **example** expected output: tb1qaxpkscscpe3nqnjkvlv3msww2hs2mtflgdeknam79efdxdj88rzq50wes4[^18])
>
> > `<amount>`: \<exact\_amount\_in\_sats> (in the previous example expected output: 1000000[^18])
>
> > `<fee>`: free selection (minimun reccomended: 1 sat/vB)

<figure><img src="../.gitbook/assets/sparrow_external_funding_1.png" alt="" width="563"><figcaption></figcaption></figure>

> * Push on **\[Create Transaction]** button

<figure><img src="../.gitbook/assets/sparrow_external_funding_2.png" alt=""><figcaption></figcaption></figure>

> * Go to File > Save PSBT > To clipboard > Push on **\[As Base64]**

<figure><img src="../.gitbook/assets/sparrow_external_funding_3.png" alt=""><figcaption></figcaption></figure>

**lncli**

* Come back to the terminal, paste the Base64 encoded PSBT, and press `Enter`

<pre data-overflow="wrap"><code>[...]
Paste the funded PSBT here to continue the funding flow.
If your PSBT is very long (specifically, more than 4096 characters), please save
it to a file and paste the full file path here instead as some terminals will
truncate the pasted text if it's too long.
Base64 encoded PSBT (or path to file):<a data-footnote-ref href="#user-content-fn-18">cHNidP8BAH0CAAAAAWWHmb3fTdrJxma/TCGvtbvApOVoi6G95w4UaHRGfDMhAAAAAAD9////AlLkZwUAAAAAFgAUX9ew44+OB8+kwpgG6iF70MmfcLhAQg8AAAAAACIAIOmDaGIYDmMwTlZn2R3BzlXgra0/Q3Np934uUtM2RzjEj+kBAE8BBDWHzwNnHxQdgAAAAJQLvJjmRynKxf0gEGTPjTNFfZihcWaKxdg80bFuZwx9A4ic/HW3i2wsi7DzQpgp3XU35GRAZE7/6xtlSU2q40k9EDJZn0RUAACAAQAAgAAAAIAAAQB9AgAAAAEuAdCdlVbd1FfBgq2pPg9M66oDLOhlqx7q4j/fmcpHgQAAAAAA/f///wIqJ3cFAAAAABYAFMa73Oh+0Y0qatXicTjbtvwoTfsSQEIPAAAAAAAiUSCpAIClp6Lhu5buI2JpHZh4EPu4FsNf0wGveMloyahvq7foAQABAR8qJ3cFAAAAABYAFMa73Oh+0Y0qatXicTjbtvwoTfsSAQMEAQAAACIGAmcWxbzjatOXumEFVjOtKLrmnBDxGLlTfWngNx5qOdRMGDJZn0RUAACAAQAAgAAAAIABAAAAEAAAAAAiAgM8w/U1eexTj+OBYiFuSuTNcIAdRgzC7GxJ/2YejuPWehgyWZ9EVAAAgAEAAIAAAACAAQAAABEAAAAAAA==</a>
</code></pre>

Expected output:

{% code overflow="wrap" %}
```
PSBT verified by lnd, please continue the funding flow by signing the PSBT by
all required parties/devices. Once the transaction is fully signed, paste it
again here either in base64 PSBT or hex encoded raw wire TX format.

Signed base64 encoded PSBT or hex encoded raw wire TX (or path to file):
```
{% endcode %}

{% hint style="info" %}
Keep the terminal open and go back to [Sparrow wallet](../bitcoin/bitcoin/desktop-signing-app-sparrow.md) on your regular computer
{% endhint %}

**Sparrow**

* Go back to Sparrow

> - Push the **\[Finalize transaction for signing]** button

<figure><img src="../.gitbook/assets/sparrow_external_funding_4.png" alt="" width="533"><figcaption></figcaption></figure>

{% hint style="danger" %}
DO NOT PUSH THE **\[BROADCAST TRANSACTION]** BUTTON!!
{% endhint %}

> * Follow the sign process, push the **\[Sign]** button (depending on your case follow the proper signing process of your Hardware Wallet)

<figure><img src="../.gitbook/assets/sparrow_external_funding_5.png" alt="" width="563"><figcaption></figcaption></figure>

{% hint style="danger" %}
DO NOT PUSH THE **\[BROADCAST TRANSACTION]** BUTTON!!
{% endhint %}

> * Push on the **\[View Final Transaction]** button

<figure><img src="../.gitbook/assets/sparrow_external_funding_6.png" alt=""><figcaption></figcaption></figure>

> * Go to the Code Down hex encoded raw wire TX and Select All code (double click) > (Right click) > Push on (Copy All) banner

<figure><img src="../.gitbook/assets/sparrow_external_funding_7.png" alt=""><figcaption></figcaption></figure>

{% hint style="danger" %}
DO NOT PUSH THE **\[BROADCAST TRANSACTION]** BUTTON!!
{% endhint %}

**lncli**

* Come back to the terminal, paste the **hex encoded raw wire TX**, and press `Enter`

<pre data-overflow="wrap"><code>PSBT verified by lnd, please continue the funding flow by signing the PSBT by
all required parties/devices. Once the transaction is fully signed, paste it
again here either in base64 PSBT or hex encoded raw wire TX format.

Signed base64 encoded PSBT or hex encoded raw wire TX (or path to file):<a data-footnote-ref href="#user-content-fn-18">02000000000101658799bddf4ddac9c666bf4c21afb5bbc0a4e5688ba1bde70e146874467c33210000000000fdffffff0252e46705000000001600145fd7b0e38f8e07cfa4c29806ea217bd0c99f70b840420f0000000000220020e9836862180e63304e5667d91dc1ce55e0adad3f437369f77e2e52d3364738c40247304402207fe76b5b1632d75c5ed2376857efaef0bed28caf2345e5bb9c9adff83da34dc802207b91f19360e2f5eef1f598d5a8d1f52612606d49226ea89558d25da30da51e760121026716c5bce36ad397ba61055633ad28bae69c10f118b9537d69e0371e6a39d44c8fe90100</a>
</code></pre>

**Example** of expected output:

{% code overflow="wrap" %}
```
{
    "funding_txid": "792b8995b76f73cbd256e08dce8d7b1444adc66693bad5b77b4dc9f7f536eec6"
}

Error received: got error from server: rpc error: code = Canceled desc = context canceled
```
{% endcode %}

{% hint style="info" %}
Check the successful open channel via [ThunderHub](web-app.md), [Zeus](mobile-app.md), or lncli
{% endhint %}

### Recover the BIP32 Master Extended Private Key

{% hint style="danger" %}
**PSA:** It is not safe to externally manage the on-chain funds of LND wallet with standard tools like Sparrow Wallet or Electrum Wallet.\
There are advanced scripts involving other parties on Lightning channels, and you may make those funds unrecoverable.

**ATTENTION:** USE ONLY FOR DISASTER RECOVERY OR TO CHECK EXTERNALLY SEEDS IN VIEW-ONLY MODE!
{% endhint %}

After all, check if you have chantools installed:

* With user `admin`, check if you have already installed chantools

```bash
chantools -v
```

**Example** of expected output:

```
chantools version v0.14.1, commit
```

{% hint style="info" %}
\> If the `chantools -v` output is the previous output; you can move to the next section.

-> If `chantools` is not installed (`chantools: command not found`), follow this [chantools bonus guide](../bonus-guides/lightning/chantools.md) to install it or to use
{% endhint %}

* Depending on whether you selected in the [chantools bonus guide](../bonus-guides/lightning/chantools.md) the [option 1](../bonus-guides/lightning/chantools.md#id-1.-temporary-use-recommended) or [option 2](../bonus-guides/lightning/chantools.md#id-2.-permanent-installation):

{% tabs %}
{% tab title="1. For temporary use option (recommended)" %}
**Extract the private key of your LND**

* Go to the `chantools` folder

```bash
cd chantools-linux-amd64-v$VERSION
```

* With user `admin`, enter the next command

```bash
./chantools showrootkey
```

Expected output:

```
Input your 12 to 24 word mnemonic separated by spaces:
```

* Type your 12 to 24 word mnemonic separated by spaces and press `Enter`

Expected output:

```
Input your cipher seed passphrase (press enter if your seed doesn't have a passphrase):
```

* Type your cipher seed passphrase (press enter without putting anything if your seed doesn't have a passphrase)

**Example** of expected output:

```
Your BIP32 HD root key is: xprv...
```

**Extract the private key of your Hardware Wallet**

{% hint style="danger" %}
ATTENTION: USE ONLY IN A SECURE AND OFFLINE DEVICE!
{% endhint %}

* With user `admin`, enter the next command

```bash
./chantools showrootkey --bip39
```

Expected output:

```
Input your 12 to 24 word mnemonic separated by spaces:
```

* Type your 12 to 24 word mnemonic separated by spaces and press `Enter`

Expected output:

```
Input your cipher seed passphrase (press enter if your seed doesn't have a passphrase):
```

* Type your cipher seed passphrase and press `Enter` (press `Enter` without putting anything if your seed doesn't have a passphrase)

**Example** of expected output:

```
Your BIP32 HD root key is: xprv...
```

{% hint style="info" %}
Now, if you want to check, you can use the Sparrow wallet to import the BIP32 HD master private key
{% endhint %}
{% endtab %}

{% tab title="2. For permanent installation option" %}
**Extract the private key of your LND**

* With user `admin`, enter the next command

```bash
chantools showrootkey
```

Expected output:

```
Input your 12 to 24 word mnemonic separated by spaces:
```

* Type your 12 to 24 word mnemonic separated by spaces and press `Enter`

Expected output:

```
Input your cipher seed passphrase (press enter if your seed doesn't have a passphrase):
```

* Type your cipher seed passphrase (press enter without putting anything if your seed doesn't have a passphrase)

**Example** of expected output:

```
Your BIP32 HD root key is: xprv...
```

**Extract the private key of your Hardware Wallet**

* With user `admin`, enter the next command

```bash
chantools showrootkey --bip39
```

Expected output:

```
Input your 12 to 24 word mnemonic separated by spaces:
```

* Type your 12 to 24 word mnemonic separated by spaces and press `Enter`

Expected output:

```
Input your cipher seed passphrase (press enter if your seed doesn't have a passphrase):
```

* Type your cipher seed passphrase and press `Enter` (press `Enter` without putting anything if your seed doesn't have a passphrase)

**Example** of expected output:

```
Your BIP32 HD root key is: xprv...
```

{% hint style="info" %}
Now, if you want to check, you can use the Sparrow wallet to import the BIP32 HD master private key
{% endhint %}
{% endtab %}
{% endtabs %}

{% hint style="info" %}
Go to [Sparrow wallet](../bitcoin/bitcoin/desktop-signing-app-sparrow.md) on your regular computer
{% endhint %}

**Sparrow**

* Go to File > **New wallet**

<figure><img src="../.gitbook/assets/sparrow_bip32_mast_priv_key_1.png" alt=""><figcaption></figcaption></figure>

* Type your desired name

<figure><img src="../.gitbook/assets/sparrow_bip32_mast_priv_key_2.png" alt=""><figcaption></figcaption></figure>

* If you created your LND node recently, select the Script Type > \[**Taproot (P2TR)**]. If you created your LND node a long time ago, select the Script Type > \[**Native Segwit(P2WPKH)**]

<figure><img src="../.gitbook/assets/sparrow_bip32_mast_priv_key_3.png" alt=""><figcaption></figcaption></figure>

* Push on the **\[New or Imported Software Wallet]** button

<figure><img src="../.gitbook/assets/sparrow_bip32_mast_priv_key_4.png" alt="" width="563"><figcaption></figcaption></figure>

* Push on the **\[Enter Private Key]** in the **Master Private Key (BIP32)**

<figure><img src="../.gitbook/assets/sparrow_bip32_mast_priv_key_5.png" alt="" width="494"><figcaption></figcaption></figure>

* Type the Master Private Key previously extracted from your LND and push the **\[Import]** button

<figure><img src="../.gitbook/assets/sparrow_bip32_mast_priv_key_6.png" alt="" width="493"><figcaption></figcaption></figure>

* Push on the **\[Import Keystore]** button

<figure><img src="../.gitbook/assets/sparrow_bip32_mast_priv_key_7.png" alt="" width="488"><figcaption></figcaption></figure>

* Finally, push on the **\[Apply]** button

<figure><img src="../.gitbook/assets/sparrow_bip32_mast_priv_key_8.png" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
Check the balance on the **\[Transactions]** and **\[UTXOs]** section if you already have movements in your LND on-chain wallet

<img src="../.gitbook/assets/sparrow_bip32_mast_priv_key_9.png" alt="" data-size="original"><img src="../.gitbook/assets/sparrow_bip32_mast_priv_key_10.png" alt="" data-size="original">
{% endhint %}

* **(Optional)** Delete the chantools files from the temporary folder

{% code overflow="wrap" %}
```bash
cd.. && rm -r chantools-linux-amd64-v$VERSION && rm -r chantools-linux-amd64-v$VERSION.tar.gz && rm manifest-v$VERSION.txt && rm manifest-v$VERSION.sig
```
{% endcode %}

## Upgrade

Upgrading LND can cause issues. **Always** read the [LND release notes](https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/) completely to understand the changes. These also cover many additional topics and new features not mentioned here.

* Check your current LND version

```sh
lnd --version
```

* Download, verify, and install the latest LND binaries as described in the [Installation section](lightning-client.md#installation) of this guide, replacing the environment variable `"VERSION=x.xx"` value to the latest if it has not already been changed in this guide **(acting behind your responsibility)**
* Restart LND to apply the new version

```sh
sudo systemctl restart lnd
```

## Uninstall

{% hint style="danger" %}
Warning: This section removes the installation. Only run these commands if you intend to uninstall
{% endhint %}

### Uninstall service

* With user `admin` , stop lnd

```bash
sudo systemctl stop lnd
```

* Disable autoboot (if enabled)

```bash
sudo systemctl disable lnd
```

* Delete the service

```bash
sudo rm /etc/systemd/system/lnd.service
```

### Delete user & group

* Delete lnd user's group

{% code overflow="wrap" %}
```bash
sudo gpasswd -d admin lnd; sudo gpasswd -d thunderhub lnd; sudo gpasswd -d btcpay lnd
```
{% endcode %}

* Delete the `lnd` user. Don't worry about `userdel: lnd mail spool (/var/mail/lnd) not found` output, the uninstall has been successful

```bash
sudo userdel -rf lnd
```

* Delete the lnd group

```bash
sudo groupdel lnd
```

### Delete the data directory

* Delete the complete `lnd` directory

```bash
sudo rm -rf /data/lnd/
```

### Delete the PostgreSQL database [(if used)](lightning-client.md#install-postgresql)

* Delete the `lndb` database

```bash
sudo -u postgres psql -c "DROP DATABASE lndb;"
```

### Uninstall binaries

* Delete the binaries installed

```bash
sudo rm /usr/local/bin/lnd && sudo rm /usr/local/bin/lncli
```

## Port reference

<table><thead><tr><th align="center">Port</th><th width="100">Protocol<select><option value="7Up5aFCtAhTE" label="TCP" color="blue"></option><option value="lN0Rb1BwaZr0" label="SSL" color="blue"></option><option value="Wo2y5caRH1ZO" label="UDP" color="blue"></option></select></th><th align="center">Use</th></tr></thead><tbody><tr><td align="center">9735</td><td><span data-option="7Up5aFCtAhTE">TCP</span></td><td align="center">Default P2P port</td></tr><tr><td align="center">10009</td><td><span data-option="7Up5aFCtAhTE">TCP</span></td><td align="center">Default gRPC port</td></tr><tr><td align="center">9911</td><td><span data-option="7Up5aFCtAhTE">TCP</span></td><td align="center">Default Watchtower server port</td></tr></tbody></table>

[^1]: zmqpubrawblock port

[^2]: zmqpubrawtx port

[^3]: Check this

[^4]: (**Example)**

[^5]: (Uncomment and customize the value)

[^6]: (Customize)

[^7]: Not necessary for manually unlock

[^8]: This is the maximum fee rate in sat/vbyte that will be used for commitments of channels of the anchors type. Increasing your commit fee for anchor channels can help get these transactions propagated. While it is always possible to bump the transaction fees of such commitment transactions later using CPFP, a low maximum commit fee may prevent these transactions from being propagated in the first place. **Uncomment and adjust to your criteria** (default: 10 sat/byte)

[^9]: The maximum percentage of total funds that can be allocated to a channel's commitment fee. This only applies for the initiator of the channel. Valid values are within \[0.1, 1]. **Uncomment and adjust to your criteria** (default 0.5)

[^10]: Set this to 144, allows you up to 24h to resolve issues related to your node before HTLCs are resolved on chain. Allowing for fewer HTLCs per channel can mitigate the potential fallout of a force closure, but can also cause the channel to be unusable when all HTLC slots are used up. **Adjust to your convenience** (default 80)

[^11]: Set this to 144, allows you up to 24h to resolve issues related to your node before HTLCs are resolved onchain. Allowing for fewer HTLCs per channel can mitigate the potential fallout of a force closure, but can also cause the channel to be unusable when all HTLC slots are used up. **Adjust to your convenience** (default 80)

[^12]: Setting the fee estimate mode to ECONOMICAL and increasing the target confirmations for onchain transactions can also help save on fees, but with the risk that some transactions may not confirm in time, requiring more manual monitoring and eventual intervention. **Uncomment and customize the value** (default: CONSERVATIVE)

[^13]: Symbolic link

[^14]: Replace

[^15]: Your Taproot master public key

[^16]: Your SegWit master public key

[^17]: Type your \[ C ] LND wallet password

[^18]: Example
