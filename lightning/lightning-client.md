---
title: Lightning client
nav_order: 10
parent: Lightning
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

# 3.1 Lightning client: LND

We set up [LND](https://github.com/lightningnetwork/lnd), the Lightning Network Daemon by [Lightning Labs](https://lightning.engineering/).

<div align="center">

<img src="../images/lightning-network-daemon-logo.png" alt="">

</div>

## Requirements

* [Bitcoin Core](../bitcoin/bitcoin/bitcoin-client.md)
* Others
  * [PostgreSQL](../bonus-guides/system/postgresql.md)
  * [Go!](../bonus-guides/system/go.md) **(optional)**

## Preparations

The installation of LND is straightforward, but the application is quite powerful and capable of things not explained here. Check out their [GitHub repository](https://github.com/lightningnetwork/lnd/) for a wealth of information about their open-source project and Lightning in general.

### Configure Bitcoin Core

Before running LND, we need to set up settings in the Bitcoin Core configuration file to enable the LND RPC connection.

* Login as user `admin`, edit the `bitcoin.conf` file

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
sudo ss -tulpn | grep LISTEN | grep bitcoind | grep 2833
```

Expected output:

<pre><code>> tcp   LISTEN 0      100        127.0.0.1:<a data-footnote-ref href="#user-content-fn-1">28332</a>      0.0.0.0:*    users:(("bitcoind",pid=773834,fd=20))
> tcp   LISTEN 0      100        127.0.0.1:<a data-footnote-ref href="#user-content-fn-2">28333</a>      0.0.0.0:*    users:(("bitcoind",pid=773834,fd=22))
</code></pre>

### Install PostgreSQL

{% hint style="warning" %}
You may want to use the bbolt database backend instead of PostgreSQL, if yes, jump to the [next step](lightning-client.md#installation) and follow the [Use bbolt database backend](lightning-client.md#use-the-bbolt-database-backend) section and remember to create the `lnd.conf` properly with this configuration when you arrive at the [configuration section](lightning-client.md#configuration)
{% endhint %}

* With user `admin`, check if you already have PostgreSQL installed

```bash
psql -V
```

**Example** of expected output:

```
> psql (PostgreSQL) 15.3 (Ubuntu 15.3-1.pgdg22.04+1)
```

{% hint style="info" %}
If you obtain "**command not found**" outputs, you need to follow the [PostgreSQL bonus guide installation progress](../bonus-guides/system/postgresql.md#installation) to install it and then come back to continue with the guide
{% endhint %}

#### Create PostgreSQL database

* With user `admin`, create a new database with the `postgres` user and assign as the owner to the `admin` user

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

* Set a temporary version environment variable to the installation

```sh
VERSION=0.18.3
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
> lnd-linux-amd64-v0.16.3-beta.tar.gz: OK
```

### Signature check

Now that we've verified the integrity of the downloaded binary, we need to check the authenticity of the manifest file we just used, starting with its signature.

* Get the public key from a LND developer, who signed the manifest file; and add it to your GPG keyring

{% code overflow="wrap" %}
```bash
curl https://raw.githubusercontent.com/lightningnetwork/lnd/master/scripts/keys/roasbeef.asc | gpg --import
```
{% endcode %}

Expected output:

<pre data-full-width="false"><code><strong>>   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
</strong>>                                  Dload  Upload   Total   Spent    Left  Speed
> 100  6900  100  6900    0     0  19676      0 --:--:-- --:--:-- --:--:-- 19714
> gpg: key 372CBD7633C61696: "Olaoluwa Osuntokun &#x3C;laolu32@gmail.com>" <a data-footnote-ref href="#user-content-fn-3">imported</a>
> gpg: Total number processed: 1
> gpg:              unchanged: 1
</code></pre>

* Verify the signature of the text file containing the checksums for the application

```sh
gpg --verify manifest-roasbeef-v$VERSION-beta.sig manifest-v$VERSION-beta.txt
```

**Example** of expected output:

<pre><code>> gpg: Signature made Mon 13 Nov 2023 11:45:38 PM UTC
> gpg:                using RSA key 60A1FA7DA5BFF08BDCBBE7903BBD59E99B280306
> gpg: <a data-footnote-ref href="#user-content-fn-4">Good signature</a> from "Olaoluwa Osuntokun &#x3C;laolu32@gmail.com>" [unknown]
> gpg: WARNING: This key is not certified with a trusted signature!
> gpg:          There is no indication that the signature belongs to the owner.
> Primary key fingerprint: E4D8 5299 674B 2D31 FAA1  892E 372C BD76 33C6 1696
>      Subkey fingerprint: 60A1 FA7D A5BF F08B DCBB  E790 3BBD 59E9 9B28 0306
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

<pre><code>> Got 1 attestation(s) from https://alice.btc.calendar.opentimestamps.org
> Got 1 attestation(s) from https://btc.calendar.catallaxy.com
> Got 1 attestation(s) from https://finney.calendar.eternitywall.com
> Got 1 attestation(s) from https://bob.btc.calendar.opentimestamps.org
> <a data-footnote-ref href="#user-content-fn-5">Success!</a> Bitcoin block <a data-footnote-ref href="#user-content-fn-6">765521 attests existence as of 2022-12-01 UTC</a>
</code></pre>

{% code overflow="wrap" %}
```bash
ots --no-cache verify manifest-v$VERSION-beta.txt.ots -f manifest-v$VERSION-beta.txt
```
{% endcode %}

**Example** of expected output:

<pre><code>> Got 1 attestation(s) from https://alice.btc.calendar.opentimestamps.org
> Got 1 attestation(s) from https://btc.calendar.catallaxy.com
> Got 1 attestation(s) from https://finney.calendar.eternitywall.com
> Got 1 attestation(s) from https://bob.btc.calendar.opentimestamps.org
> <a data-footnote-ref href="#user-content-fn-7">Success!</a> Bitcoin block <a data-footnote-ref href="#user-content-fn-8">829257 attests existence as of 2024-02-06 UTC</a>
</code></pre>

{% hint style="info" %}
Check that the date of the timestamp is close to the [release date](https://github.com/lightningnetwork/lnd/releases) of the LND binary
{% endhint %}

* Having verified the integrity and authenticity of the release binary, we can safely

```sh
tar -xvf lnd-linux-amd64-v$VERSION-beta.tar.gz
```

**Example** of expected output:

```
> lnd-linux-amd64-v0.17.1-beta/lnd
> lnd-linux-amd64-v0.17.1-beta/lncli
> lnd-linux-amd64-v0.17.1-beta/
```

### Binaries installation

* Install it

{% code overflow="wrap" %}
```sh
sudo install -m 0755 -o root -g root -t /usr/local/bin lnd-linux-amd64-v$VERSION-beta/lnd lnd-linux-amd64-v$VERSION-beta/lncli
```
{% endcode %}

* Ensure you are installed by running the version command

```sh
lnd --version
```

**Example** of expected output:

```
> lnd version 0.16.3-beta commit=v0.16.3-beta
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

* Add the `lnd` user to the groups "bitcoin" and "debian-tor", allowing to the `btcrpcexplorer` user read the bitcoind `.cookie` file and to use the control port configuring Tor directly

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

* Assign as owner the `lnd` user

```sh
sudo chown -R lnd:lnd /data/lnd
```

* Open a `lnd` user session

```sh
sudo su - lnd
```

* Create symbolic links pointing to the LND and bitcoin data directories

```sh
ln -s /data/lnd /home/lnd/.lnd
```

```sh
ln -s /data/bitcoin /home/lnd/.bitcoin
```

* Check symbolic links have been created correctly

```bash
ls -la
```

Expected output:

<pre><code>total 20
drwxr-x--- 2 lnd  lnd  4096 Jul 15 20:57 .
drwxr-xr-x 7 root root 4096 Jul 15 20:54 ..
-rw-r--r-- 1 lnd  lnd   220 Jul 15 20:54 .bash_logout
-rw-r--r-- 1 lnd  lnd  3771 Jul 15 20:54 .bashrc
lrwxrwxrwx 1 lnd  lnd    13 Jul 15 20:57 <a data-footnote-ref href="#user-content-fn-9">.bitcoin -> /data/bitcoin</a>
lrwxrwxrwx 1 lnd  lnd     9 Jul 15 20:56 <a data-footnote-ref href="#user-content-fn-10">.lnd -> /data/lnd</a>
-rw-r--r-- 1 lnd  lnd   807 Jul 15 20:54 .profile
</code></pre>

### Wallet password

LND includes a Bitcoin wallet that manages your onchain and Lightning coins. It is password protected and must be unlocked when LND starts. This creates the dilemma that you either manually unlock LND after each restart of your PC, or store the password somewhere on the node.

For this initial setup, we choose the easy route: we store the password in a file that allows LND to unlock the wallet automatically.

* Still as user `lnd`, create a text file and enter your LND wallet `password [C]`. **Password should have at least 8 characters.** Save and exit

```sh
nano /data/lnd/password.txt
```

* Tighten access privileges and make the file readable only for user `lnd`

```sh
chmod 600 /data/lnd/password.txt
```

## Configuration

* Create the LND configuration file

```sh
nano /data/lnd/lnd.conf
```

* Paste the following content (set your alias `"<YOUR_FANCY_ALIAS>"`, your preferred color `"<#ff9900>"`, your minimum channel size **`"minchansize"`** , and fees). Save and exit

<pre><code># MiniBolt: lnd configuration
# /data/lnd/lnd.conf

[Application Options]
# Up to 32 UTF-8 characters, accepts emojis i.e ⚡🧡​ https://emojikeyboard.top/
alias=<a data-footnote-ref href="#user-content-fn-11">&#x3C;YOUR_FANCY_ALIAS></a>
# You can choose the color you want at https://www.color-hex.com/
color=#ff9900

# Automatically unlock wallet with the password in this file
wallet-unlock-password-file=/data/lnd/password.txt
wallet-unlock-allow-create=true

# The TLS private key will be encrypted to the node's seed
tlsencryptkey=true

# Automatically regenerate certificate when near expiration
tlsautorefresh=true

# Do not include the interface IPs or the system hostname in TLS certificate
tlsdisableautofill=true

## Channel settings
# (Optional) Minimum channel size. Uncomment and set whatever you want
# (default: 20000 sats)
<a data-footnote-ref href="#user-content-fn-12">#minchansize=20000</a>

## (Optional) High fee environment settings
<a data-footnote-ref href="#user-content-fn-13">#max-commit-fee-rate-anchors=</a><a data-footnote-ref href="#user-content-fn-14">10</a>
<strong><a data-footnote-ref href="#user-content-fn-15">#max-channel-fee-allocation=</a><a data-footnote-ref href="#user-content-fn-16">0.5</a>
</strong>
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
<a data-footnote-ref href="#user-content-fn-17">#bitcoin.basefee=1000</a>
<a data-footnote-ref href="#user-content-fn-18">#bitcoin.feerate=1</a>

# (Optional) Specify the CLTV delta we will subtract from a forwarded HTLC's timelock value
# (default: 80)
<a data-footnote-ref href="#user-content-fn-19">#bitcoin.timelockdelta=8</a><a data-footnote-ref href="#user-content-fn-20">0</a>

[protocol]
protocol.wumbo-channels=true
protocol.option-scid-alias=true
protocol.simple-taproot-chans=true

[wtclient]
## Watchtower client settings
wtclient.active=true

# (Optional) Specify the fee rate with which justice transactions will be signed
# (default: 10 sat/byte)
<a data-footnote-ref href="#user-content-fn-21">#wtclient.sweep-fee-rate=10</a>

[watchtower]
## Watchtower server settings
watchtower.active=true

[routing]
routing.strictgraphpruning=true

[db]
## Database
db.backend=postgres

[postgres]
db.postgres.dsn=postgresql://admin:admin@127.0.0.1:5432/lndb?sslmode=disable
db.postgres.timeout=0

## High fee environment (Optional)
# (default: CONSERVATIVE) Uncomment the next 2 lines
#[Bitcoind]
<a data-footnote-ref href="#user-content-fn-22">#bitcoind.estimatemode=ECONOMICAL</a>

[tor]
tor.active=true
tor.v3=true
tor.streamisolation=true
</code></pre>

{% hint style="info" %}
This is a standard configuration. Check the official LND [sample-lnd.conf](https://github.com/lightningnetwork/lnd/blob/master/sample-lnd.conf) with all possible options if you want to add something special
{% endhint %}

* Exit of the `lnd` user session to return to the `admin` user session

```sh
exit
```

### Create systemd service

Now, let's set up LND to start automatically on system startup.

* As user `admin`, create LND systemd unit

```sh
sudo nano /etc/systemd/system/lnd.service
```

* Enter the following complete content. Save and exit

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
RuntimeDirectory=lightningd
RuntimeDirectoryMode=0710
User=lnd
Group=lnd

# Hardening Measures
####################
PrivateTmp=true
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

To keep an eye on the software movements, [start your SSH program](../index-1/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`

* Start the service

```sh
sudo systemctl start lnd
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>journalctl -fu lnd</code> ⬇️</summary>

```
Jun 05 14:58:50 minibolt systemd[1]: Starting Lightning Network Daemon...
Jun 05 14:58:50 minibolt lnd[124224]: Attempting automatic RPC configuration to bitcoind
Jun 05 14:58:50 minibolt lnd[124224]: Automatically obtained bitcoind's RPC credentials
Jun 05 14:58:50 minibolt lnd[124224]: 2024-06-05 14:58:50.368 [INF] LTND: Version: 0.18.0-beta commit=v0.18.0-beta, build=production, logging=default, debuglevel=info
Jun 05 14:58:50 minibolt lnd[124224]: 2024-06-05 14:58:50.369 [INF] LTND: Active chain: Bitcoin (network=mainnet)
Jun 05 14:58:50 minibolt lnd[124224]: 2024-06-05 14:58:50.369 [INF] RPCS: Generating ephemeral TLS certificates...
Jun 05 14:58:50 minibolt lnd[124224]: 2024-06-05 14:58:50.370 [INF] RPCS: Done generating ephemeral TLS certificates
Jun 05 14:58:50 minibolt lnd[124224]: 2024-06-05 14:58:50.372 [INF] RPCS: RPC server listening on 127.0.0.1:10009
Jun 05 14:58:50 minibolt lnd[124224]: 2024-06-05 14:58:50.394 [INF] RPCS: gRPC proxy started at 127.0.0.1:8080
Jun 05 14:58:50 minibolt lnd[124224]: 2024-06-05 14:58:50.395 [INF] LTND: Opening the main database, this might take a few minutes...
Jun 05 14:58:50 minibolt lnd[124224]: 2024-06-05 14:58:50.615 [INF] LTND: Using remote postgres database! Creating graph and channel state DB instances
Jun 05 14:58:50 minibolt lnd[124224]: 2024-06-05 14:58:50.667 [INF] CHDB: Checking for schema update: latest_version=31, db_version=31
Jun 05 14:58:50 minibolt lnd[124224]: 2024-06-05 14:58:50.669 [INF] CHDB: Checking for optional update: prune_revocation_log=false, db_version=empty
Jun 05 14:58:50 minibolt lnd[124224]: 2024-06-05 14:58:50.700 [INF] LTND: Database(s) now open (time_to_open=305.162267ms)!
Jun 05 14:58:50 minibolt lnd[124224]: 2024-06-05 14:58:50.703 [INF] LTND: Systemd was notified about our readiness
Jun 05 14:58:50 minibolt lnd[124224]: 2024-06-05 14:58:50.703 [INF] LTND: Waiting for wallet encryption password. Use `lncli create` to create a wallet, `lncli unlock` to unlock an existing wallet, or `lncli changepassword` to change the password of an existing wallet and unlock it.
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
\-> Now, you could have 2 possible scenarios, follow the proper steps depending on your case⬇️
{% endhint %}

{% tabs %}
{% tab title="Scenery 1" %}
<mark style="color:green;">**If you are creating a new node and you wish to create a new seed**</mark>

* Press `n` and enter

{% hint style="info" %}
If you choose this option, the next step will be choosing the passphrase **(optional -** press enter to proceed without a cipher seed passphrase\*\*)\*\*
{% endhint %}

Expected output:

<pre><code><strong>Your cipher seed can optionally be encrypted.
</strong>Input your passphrase if you wish to encrypt it (or press enter to proceed without a cipher seed passphrase):
</code></pre>

* Type the passphrase and press enter \[the prompt will request you to enter your `password [C]` one more time (`Confirm password:`)] or if you choose not to use the passphrase press enter simply

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
These 24 words are all that you need (and the `channel.backup` file in case of disaster recovery) to restore the Bitcoin onchain wallet and possible UTXOs blocked

**Write these 24 words down manually on a piece of paper and store it in a safe place**

You can use a simple piece of paper, write them on the custom themed [Shiftcrypto backup card](https://shiftcrypto.ch/backupcard/backupcard\_print.pdf), or even [stamp the seed words into metal](../bonus/bitcoin/safu-ninja.md)
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
Nov 26 19:17:38 minibolt lnd[1004]: 2023-11-26 19:17:38.037 [INF] LNWL: Opened wallet
Nov 26 19:17:38 minibolt lnd[1004]: 2023-11-26 19:17:38.204 [INF] CHRE: Primary chain is set to: bitcoin
Nov 26 19:17:38 minibolt lnd[1004]: 2023-11-26 19:17:38.244 [INF] LNWL: Started listening for bitcoind block notifications via ZMQ on 127.0.0.1:28332
Nov 26 19:17:38 minibolt lnd[1004]: 2023-11-26 19:17:38.245 [INF] CHRE: Initializing bitcoind backed fee estimator in CONSERVATIVE mode
Nov 26 19:17:38 minibolt lnd[1004]: 2023-11-26 19:17:38.244 [INF] LNWL: Started listening for bitcoind transaction notifications via ZMQ on 127.0.0.1:28333
Nov 26 19:17:40 minibolt lnd[1004]: 2023-11-26 19:17:40.576 [INF] LNWL: The wallet has been unlocked without a time limit
Nov 26 19:17:40 minibolt lnd[1004]: 2023-11-26 19:17:40.712 [INF] CHRE: LightningWallet opened
Nov 26 19:17:40 minibolt lnd[1004]: 2023-11-26 19:17:40.722 [INF] SRVR: Proxying all network traffic via Tor (stream_isolation=true)! NOTE: Ensure the backend node is proxying over Tor as well
Nov 26 19:17:40 minibolt lnd[1004]: 2023-11-26 19:17:40.723 [INF] TORC: Starting tor controller
Nov 26 19:17:40 minibolt lnd[1004]: 2023-11-26 19:17:40.744 [INF] HSWC: Cleaning circuits from disk for closed channels
Nov 26 19:17:40 minibolt lnd[1004]: 2023-11-26 19:17:40.744 [INF] HSWC: Finished cleaning: no closed channels found, no actions taken.
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

* If you used a passphrase, enter it, if not, press enter again directly

{% hint style="info" %}
If you were wrong with the passphrase, don't worry, LND shows you the next log and will not run: `[lncli] rpc error: code = Unknown desc = invalid passphrase`, recheck, and try again, if not, the prompt shows you the next
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

Return to the first terminal with `journalctl -f -u lnd`. Search to the next lines to ensure LND already entered the RECOVERY MODE and go out of this ⬇️

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
The current state of your channels, however, cannot be recreated from this seed. For this, the Static Channel Backup stored `/data/lnd/data/chain/bitcoin/mainnet/channel.backup` is updated for each channel opening and closing

There is a dedicated [guide](channel-backup.md) to making an automatic backup
{% endhint %}

* Return to the `admin` user

```sh
exit
```

* Check that LND is running and related ports listening

```bash
sudo ss -tulpn | grep LISTEN | grep lnd
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

* Check symbolic link has been created correctly

```bash
ls -la /home/admin
```

<details>

<summary>Expected output ⬇️</summary>

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
lrwxrwxrwx  1 admin admin     9 Jul 18 07:10 <a data-footnote-ref href="#user-content-fn-23">.lnd -> /data/lnd</a>
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

* Check if you can use `lncli` with the `admin` user by querying LND for information

```sh
lncli getinfo
```

## LND in action

💊 Now your Lightning node is ready. This is also the point of no return. Up until now, you can just start over. Once you send real Bitcoin to your MiniBolt, you have "skin in the game"

{% hint style="info" %}
The next commands can be entered in any new session without keeping a specific terminal opened with logs, but I recommend keeping this just in case any log could give extra information about the command you just entered
{% endhint %}

### Watchtower client

Lightning channels need to be monitored to prevent malicious behavior by your channel peers. If your MiniBolt goes down for a longer time, for instance, due to a hardware problem, a node on the other side of one of your channels might try to close the channel with an earlier channel balance that is better for them.

Watchtowers are other Lightning nodes that can monitor your channels for you. If they detect such bad behavior, they can react on your behalf, and send a punishing transaction to close this channel. In this case, all channel funds will be sent to your LND on-chain wallet.

A watchtower can only send such a punishing transaction to your wallet, so you don't have to trust them. It's good practice to add a few watchtowers, just to be on the safe side.

* With user `admin`, add the [Lightning Network+ watchtower](https://lightningnetwork.plus/watchtower) Tor address as a first example

{% code overflow="wrap" %}
```bash
lncli wtclient add 023bad37e5795654cecc69b43599da8bd5789ac633c098253f60494bde602b60bf@iiu4epqzm6cydqhezueenccjlyzrqeruntlzbx47mlmdgfwgtrll66qd.onion:9911
```
{% endcode %}

* Or the clearnet address

{% code overflow="wrap" %}
```bash
lncli wtclient add 023bad37e5795654cecc69b43599da8bd5789ac633c098253f60494bde602b60bf@34.216.52.158:9911
```
{% endcode %}

* If you want to list your towers and active watchtowers

```sh
lncli wtclient towers
```

Expected output:

```
{
    "towers": [
        {
            "pubkey": "023bad37e5795654cecc69b43599da8bd5789ac633c098253f60494bde602b60bf",
            "addresses": [
                "iiu4epqzm6cydqhezueenccjlyzrqeruntlzbx47mlmdgfwgtrll66qd.onion:9911"
            ],
            "active_session_candidate": true,
            "num_sessions": 0,
            "sessions": [
            ]
        },
    ]
}
```

* If you want to deactivate an active tower

```sh
lncli wtclient remove <pubkey>
```

{% hint style="info" %}
Monitor logs with `journalctl -fu lnd` to check the watchtower client is working fine, it should show you after a while, the next logs ⬇️
{% endhint %}

<figure><img src="../.gitbook/assets/lnd-watchtower_log.PNG" alt=""><figcaption></figcaption></figure>

### Watchtower server

Same you can connect as a watchtower client to other watchtower servers, you could give the same service running an altruist watchtower server. **This was previously activated** in the `lnd.conf`, and you can see the information about it by typing the following command and sharing it with your peers.

```sh
lncli tower info
```

Expected output:

```
{
  "pubkey": "023bad37e5795654cecc69b43599da8bd5789ac633c098253f60494bde602b60bf",
  "listeners": [
      "[::]:9911"
  ],
  "uris": [
      "iiu4epqzm6cydqhezueenccjlyzrqeruntlzbx47mlmdgfwgtrll66qd.onion:9911"
  ]
}
```

{% hint style="warning" %}
This watchtower server service is not recommended to activate if you have a slow device without high-performance features, if yes consider disabling it commenting, or deleting the line `watchtower.active=true` of the `lnd.conf` file
{% endhint %}

{% hint style="info" %}
Almost all of the following steps could be run with the [mobile](mobile-app.md) | [web](web-app.md) app guides. We strongly recommend using these applications with intuitive and visual UI to manage the Lightning Node, instead of using the command line. Anyway, if you want to explore the lncli, you have some useful commands in the[ extra section](lightning-client.md#some-useful-lncli-commands)
{% endhint %}

## Extras (optional)

### Use the default bbolt database backend

Once you have skipped the before section of the [PostgreSQL installation](lightning-client.md#install-postgresql), and when you arrive at the [Configuration section](lightning-client.md#configuration), modify `lnd.conf` file

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
Continue with the guide on the [Create systemd service](lightning-client.md#create-systemd-service) section
{% endhint %}

### Migrate an existing bbolt database to PostgreSQL

{% hint style="danger" %}
Attention: this process is very risky, supposedly this [software is in an experimental state](https://github.com/lightninglabs/lndinit/pull/21) which could damage your existing LND database. **Act at your own risk**❗

\-> It is recommended to start from scratch by closing all existing channels, rather than a migration to ensure we don't lose anything because it is not possible to come back to the old bbolt database once migrated
{% endhint %}

#### Install dependencies

* With user `admin`, install the next dependencies packages. Press `enter` when the prompt asks you

```bash
sudo apt install build-essential
```

#### Install Go!

* With user `admin`, verify that you've installed Go by typing the following command

```bash
go version
```

**Example** of expected output:

```
> go version go1.21.10 linux/amd64
```

{% hint style="info" %}
If you obtain "**command not found**" outputs, you need to follow the [Go! bonus guide installation progress](../bonus-guides/system/go.md#installation) to install it and then come back to continue with the guide
{% endhint %}

#### Install lndinit

* With user `admin`, go to the temporary folder

```bash
cd /tmp
```

* Clone the `migrate-db` branch of the lndinit, from the official repository of the Minibolt and enter to the lndinit folder

{% code overflow="wrap" %}
```bash
git clone --branch migrate-db https://github.com/minibolt-guide/lndinit.git && cd lndinit
```
{% endcode %}

* Compile it

```bash
make install
```

{% hint style="info" %}
This process can take quite a long time, 5-10 minutes or more, depending on the performance of your device. Please be patient until the prompt shows again
{% endhint %}

* Install it

```bash
sudo install -m 0755 -o root -g root -t /usr/local/bin /home/admin/go/bin/lndinit
```

* Check the correct installation

```bash
lndinit -v
```

**Example** of expected output:

```
2024-05-30 23:00:15.666 LNDINIT: Version 0.1.4-beta commit=, debuglevel=debug
2024-05-30 23:00:15.668 LNDINIT: Config error: Please specify one command of: gen-password, gen-seed, init-wallet, load-secret, migrate-db, store-secret or wait-ready
```

**(Optional)** Delete the installation files

```bash
sudo rm -r /tmp/lndinit
```

#### Migrate bbolt database to PostgreSQL

* With user `admin`, stop lnd

```bash
sudo systemctl stop lnd
```

* Confirm and ensure that LND is stopped successfully by monitoring logs

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
May 30 20:45:02 minibolt systemd[1]: <a data-footnote-ref href="#user-content-fn-24">Stopped Lightning Network Daemon.</a>
May 30 20:45:02 minibolt systemd[1]: lnd.service: Consumed 12h 11min 606ms CPU time.
</code></pre>

* a Previously followed:
  1. [Install PostgreSQL section](lightning-client.md#install-postgresql)
  2. [Create PostgreSQL database section](lightning-client.md#create-postgresql-database)
* Exec the migration and wait to finish it

```bash
sudo lndinit -v migrate-db \
      --source.bolt.data-dir /home/admin/.lnd/data \
      --source.bolt.tower-dir /home/admin/.lnd/data/watchtower \
      --source.bolt.network=mainnet \
      --dest.backend postgres \
      --dest.postgres.dsn=postgresql://admin:admin@127.0.0.1:5432/lndb?sslmode=disable \
      --dest.postgres.timeout=0
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
2024-04-17 14:07:41.277 LNDINIT: Version 0.1.4-beta commit=, debuglevel=debug
2024-04-17 14:07:41.279 LNDINIT: Migrating DB with prefix channeldb
2024-04-17 14:07:41.279 LNDINIT: Opening bbolt backend at /home/admin/.lnd/data/graph/mainnet/channel.db for prefix 'channeldb'
2024-04-17 14:07:41.370 LNDINIT: Opened source DB
2024-04-17 14:07:41.370 LNDINIT: Opening postgres backend at postgresql://admin:admin@127.0.0.1:5432/lndb?sslmode=disable with prefix 'channeldb'
2024-04-17 14:07:41.394 LNDINIT: Opened destination DB
2024-04-17 14:07:41.394 LNDINIT: Checking tombstone marker on source DB
2024-04-17 14:07:41.394 LNDINIT: Checking if migration was already applied to target DB
2024-04-17 14:07:41.401 LNDINIT: Starting the migration to the target backend
2024-04-17 14:07:41.402 LNDINIT: Copying top-level bucket 'alias-bucket'
2024-04-17 14:07:41.409 LNDINIT: Committing bucket 'alias-bucket'
2024-04-17 14:07:41.411 LNDINIT: Copying top-level bucket 'base-bucket'
2024-04-17 14:07:41.413 LNDINIT: Committing bucket 'base-bucket'
2024-04-17 14:07:41.415 LNDINIT: Copying top-level bucket 'chan-id-bucket'
2024-04-17 14:07:41.417 LNDINIT: Committing bucket 'chan-id-bucket'
2024-04-17 14:07:41.481 LNDINIT: Copying top-level bucket 'circuit-adds'
2024-04-17 14:07:41.483 LNDINIT: Committing bucket 'circuit-adds'
2024-04-17 14:07:41.484 LNDINIT: Copying top-level bucket 'circuit-fwd-log'
2024-04-17 14:07:41.486 LNDINIT: Committing bucket 'circuit-fwd-log'
2024-04-17 14:07:41.487 LNDINIT: Copying top-level bucket 'circuit-keystones'
2024-04-17 14:07:41.489 LNDINIT: Committing bucket 'circuit-keystones'
2024-04-17 14:07:41.490 LNDINIT: Copying top-level bucket 'close-summaries'
2024-04-17 14:07:41.492 LNDINIT: Committing bucket 'close-summaries'
2024-04-17 14:07:41.493 LNDINIT: Copying top-level bucket 'closed-chan-bucket'
2024-04-17 14:07:41.495 LNDINIT: Committing bucket 'closed-chan-bucket'
2024-04-17 14:07:41.496 LNDINIT: Copying top-level bucket 'confirm-hints'
2024-04-17 14:07:41.497 LNDINIT: Committing bucket 'confirm-hints'
2024-04-17 14:07:41.499 LNDINIT: Copying top-level bucket 'edge-index'
2024-04-17 14:07:41.500 LNDINIT: Committing bucket 'edge-index'
2024-04-17 14:07:41.501 LNDINIT: Copying top-level bucket 'fwd-packages'
2024-04-17 14:07:41.503 LNDINIT: Committing bucket 'fwd-packages'
2024-04-17 14:07:41.504 LNDINIT: Copying top-level bucket 'graph-edge'
2024-04-17 14:07:58.418 LNDINIT: Committing bucket 'graph-edge'
2024-04-17 14:08:08.332 LNDINIT: Copying top-level bucket 'graph-meta'
2024-04-17 14:08:08.337 LNDINIT: Committing bucket 'graph-meta'
2024-04-17 14:08:08.834 LNDINIT: Copying top-level bucket 'graph-node'
2024-04-17 14:08:11.346 LNDINIT: Committing bucket 'graph-node'
2024-04-17 14:08:13.710 LNDINIT: Copying top-level bucket 'historical-chan-bucket'
2024-04-17 14:08:13.713 LNDINIT: Committing bucket 'historical-chan-bucket'
2024-04-17 14:08:13.727 LNDINIT: Copying top-level bucket 'invoice-alias-bucket'
2024-04-17 14:08:13.728 LNDINIT: Committing bucket 'invoice-alias-bucket'
2024-04-17 14:08:13.733 LNDINIT: Copying top-level bucket 'invoices'
2024-04-17 14:08:13.737 LNDINIT: Committing bucket 'invoices'
2024-04-17 14:08:13.742 LNDINIT: Copying top-level bucket 'message-store'
2024-04-17 14:08:13.743 LNDINIT: Committing bucket 'message-store'
2024-04-17 14:08:13.748 LNDINIT: Copying top-level bucket 'metadata'
2024-04-17 14:08:13.750 LNDINIT: Committing bucket 'metadata'
2024-04-17 14:08:13.754 LNDINIT: Copying top-level bucket 'missioncontrol-results'
2024-04-17 14:08:13.756 LNDINIT: Committing bucket 'missioncontrol-results'
2024-04-17 14:08:13.760 LNDINIT: Copying top-level bucket 'network-result-store-bucket'
2024-04-17 14:08:13.762 LNDINIT: Committing bucket 'network-result-store-bucket'
2024-04-17 14:08:13.767 LNDINIT: Copying top-level bucket 'next-payment-id-key'
2024-04-17 14:08:13.768 LNDINIT: Committing bucket 'next-payment-id-key'
2024-04-17 14:08:13.773 LNDINIT: Copying top-level bucket 'nib'
2024-04-17 14:08:13.774 LNDINIT: Committing bucket 'nib'
2024-04-17 14:08:13.779 LNDINIT: Copying top-level bucket 'open-chan-bucket'
2024-04-17 14:08:13.780 LNDINIT: Committing bucket 'open-chan-bucket'
2024-04-17 14:08:13.782 LNDINIT: Copying top-level bucket 'outpoint-bucket'
2024-04-17 14:08:13.783 LNDINIT: Committing bucket 'outpoint-bucket'
2024-04-17 14:08:13.784 LNDINIT: Copying top-level bucket 'pay-addr-index'
2024-04-17 14:08:13.786 LNDINIT: Committing bucket 'pay-addr-index'
2024-04-17 14:08:13.787 LNDINIT: Copying top-level bucket 'payments-index-bucket'
2024-04-17 14:08:13.788 LNDINIT: Committing bucket 'payments-index-bucket'
2024-04-17 14:08:13.790 LNDINIT: Copying top-level bucket 'peers-bucket'
2024-04-17 14:08:13.791 LNDINIT: Committing bucket 'peers-bucket'
2024-04-17 14:08:13.792 LNDINIT: Copying top-level bucket 'set-id-index'
2024-04-17 14:08:13.793 LNDINIT: Committing bucket 'set-id-index'
2024-04-17 14:08:13.794 LNDINIT: Copying top-level bucket 'spend-hints'
2024-04-17 14:08:13.796 LNDINIT: Committing bucket 'spend-hints'
2024-04-17 14:08:13.797 LNDINIT: Copying top-level bucket 'sweeper-tx-hashes'
2024-04-17 14:08:13.798 LNDINIT: Committing bucket 'sweeper-tx-hashes'
2024-04-17 14:08:13.803 LNDINIT: Migrating DB with prefix macaroondb
2024-04-17 14:08:13.803 LNDINIT: Opening bbolt backend at /home/admin/.lnd/data/chain/bitcoin/mainnet/macaroons.db for prefix 'macaroondb'
2024-04-17 14:08:13.804 LNDINIT: Opened source DB
2024-04-17 14:08:13.804 LNDINIT: Opening postgres backend at postgresql://admin:admin@127.0.0.1:5432/lndb?sslmode=disable with prefix 'macaroondb'
2024-04-17 14:08:13.878 LNDINIT: Opened destination DB
2024-04-17 14:08:13.878 LNDINIT: Checking tombstone marker on source DB
2024-04-17 14:08:13.878 LNDINIT: Checking if migration was already applied to target DB
2024-04-17 14:08:13.881 LNDINIT: Starting the migration to the target backend
2024-04-17 14:08:13.881 LNDINIT: Copying top-level bucket 'macrootkeys'
2024-04-17 14:08:13.887 LNDINIT: Committing bucket 'macrootkeys'
2024-04-17 14:08:13.900 LNDINIT: Migrating DB with prefix decayedlogdb
2024-04-17 14:08:13.900 LNDINIT: Opening bbolt backend at /home/admin/.lnd/data/graph/mainnet/sphinxreplay.db for prefix 'decayedlogdb'
2024-04-17 14:08:13.900 LNDINIT: Opened source DB
2024-04-17 14:08:13.900 LNDINIT: Opening postgres backend at postgresql://admin:admin@127.0.0.1:5432/lndb?sslmode=disable with prefix 'decayedlogdb'
2024-04-17 14:08:14.762 LNDINIT: Opened destination DB
2024-04-17 14:08:14.762 LNDINIT: Checking tombstone marker on source DB
2024-04-17 14:08:14.762 LNDINIT: Checking if migration was already applied to target DB
2024-04-17 14:08:14.768 LNDINIT: Starting the migration to the target backend
2024-04-17 14:08:14.768 LNDINIT: Copying top-level bucket 'batch-replay'
2024-04-17 14:08:14.776 LNDINIT: Committing bucket 'batch-replay'
2024-04-17 14:08:14.782 LNDINIT: Copying top-level bucket 'shared-hash'
2024-04-17 14:08:14.786 LNDINIT: Committing bucket 'shared-hash'
2024-04-17 14:08:14.811 LNDINIT: Migrating DB with prefix towerclientdb
2024-04-17 14:08:14.811 LNDINIT: Opening bbolt backend at /home/admin/.lnd/data/graph/mainnet/wtclient.db for prefix 'towerclientdb'
2024-04-17 14:08:14.812 LNDINIT: Opened source DB
2024-04-17 14:08:14.812 LNDINIT: Opening postgres backend at postgresql://admin:admin@127.0.0.1:5432/lndb?sslmode=disable with prefix 'towerclientdb'
2024-04-17 14:08:14.956 LNDINIT: Opened destination DB
2024-04-17 14:08:14.956 LNDINIT: Checking tombstone marker on source DB
2024-04-17 14:08:14.956 LNDINIT: Checking if migration was already applied to target DB
2024-04-17 14:08:14.963 LNDINIT: Starting the migration to the target backend
2024-04-17 14:08:14.963 LNDINIT: Copying top-level bucket 'client-channel-detail-bucket'
2024-04-17 14:08:14.970 LNDINIT: Committing bucket 'client-channel-detail-bucket'
2024-04-17 14:08:14.975 LNDINIT: Copying top-level bucket 'client-channel-id-index'
2024-04-17 14:08:14.978 LNDINIT: Committing bucket 'client-channel-id-index'
2024-04-17 14:08:14.983 LNDINIT: Copying top-level bucket 'client-closable-sessions-bucket'
2024-04-17 14:08:14.986 LNDINIT: Committing bucket 'client-closable-sessions-bucket'
2024-04-17 14:08:14.991 LNDINIT: Copying top-level bucket 'client-session-bucket'
2024-04-17 14:08:14.994 LNDINIT: Committing bucket 'client-session-bucket'
2024-04-17 14:08:14.999 LNDINIT: Copying top-level bucket 'client-session-id-index'
2024-04-17 14:08:15.002 LNDINIT: Committing bucket 'client-session-id-index'
2024-04-17 14:08:15.007 LNDINIT: Copying top-level bucket 'client-session-key-index-bucket'
2024-04-17 14:08:15.010 LNDINIT: Committing bucket 'client-session-key-index-bucket'
2024-04-17 14:08:15.015 LNDINIT: Copying top-level bucket 'client-tower-bucket'
2024-04-17 14:08:15.017 LNDINIT: Committing bucket 'client-tower-bucket'
2024-04-17 14:08:15.022 LNDINIT: Copying top-level bucket 'client-tower-index-bucket'
2024-04-17 14:08:15.025 LNDINIT: Committing bucket 'client-tower-index-bucket'
2024-04-17 14:08:15.030 LNDINIT: Copying top-level bucket 'client-tower-to-session-index-bucket'
2024-04-17 14:08:15.032 LNDINIT: Committing bucket 'client-tower-to-session-index-bucket'
2024-04-17 14:08:15.037 LNDINIT: Copying top-level bucket 'metadata-bucket'
2024-04-17 14:08:15.043 LNDINIT: Committing bucket 'metadata-bucket'
2024-04-17 14:08:15.061 LNDINIT: Migrating DB with prefix towerserverdb
2024-04-17 14:08:15.061 LNDINIT: Opening bbolt backend at /home/admin/.lnd/data/watchtower/bitcoin/mainnet/watchtower.db for prefix 'towerserverdb'
2024-04-17 14:08:15.061 LNDINIT: Opened source DB
2024-04-17 14:08:15.061 LNDINIT: Opening postgres backend at postgresql://admin:admin@127.0.0.1:5432/lndb?sslmode=disable with prefix 'towerserverdb'
2024-04-17 14:08:15.144 LNDINIT: Opened destination DB
2024-04-17 14:08:15.144 LNDINIT: Checking tombstone marker on source DB
2024-04-17 14:08:15.144 LNDINIT: Checking if migration was already applied to target DB
2024-04-17 14:08:15.149 LNDINIT: Starting the migration to the target backend
2024-04-17 14:08:15.149 LNDINIT: Copying top-level bucket 'lookout-tip-bucket'
2024-04-17 14:08:15.155 LNDINIT: Committing bucket 'lookout-tip-bucket'
2024-04-17 14:08:15.161 LNDINIT: Copying top-level bucket 'metadata-bucket'
2024-04-17 14:08:15.166 LNDINIT: Committing bucket 'metadata-bucket'
2024-04-17 14:08:15.168 LNDINIT: Copying top-level bucket 'sessions-bucket'
2024-04-17 14:08:15.171 LNDINIT: Committing bucket 'sessions-bucket'
2024-04-17 14:08:15.173 LNDINIT: Copying top-level bucket 'update-index-bucket'
2024-04-17 14:08:15.175 LNDINIT: Committing bucket 'update-index-bucket'
2024-04-17 14:08:15.177 LNDINIT: Copying top-level bucket 'updates-bucket'
2024-04-17 14:08:15.180 LNDINIT: Committing bucket 'updates-bucket'
2024-04-17 14:08:15.192 LNDINIT: Migrating DB with prefix walletdb
2024-04-17 14:08:15.193 LNDINIT: Opening bbolt backend at /home/admin/.lnd/data/chain/bitcoin/mainnet/wallet.db for prefix 'walletdb'
2024-04-17 14:08:15.213 LNDINIT: Opened source DB
2024-04-17 14:08:15.213 LNDINIT: Opening postgres backend at postgresql://admin:admin@127.0.0.1:5432/lndb?sslmode=disable with prefix 'walletdb'
2024-04-17 14:08:15.299 LNDINIT: Opened destination DB
2024-04-17 14:08:15.299 LNDINIT: Checking tombstone marker on source DB
2024-04-17 14:08:15.300 LNDINIT: Checking if migration was already applied to target DB
2024-04-17 14:08:15.304 LNDINIT: Starting the migration to the target backend
2024-04-17 14:08:15.304 LNDINIT: Copying top-level bucket 'waddrmgr'
2024-04-17 14:08:15.809 LNDINIT: Committing bucket 'waddrmgr'
2024-04-17 14:08:15.815 LNDINIT: Copying top-level bucket 'wtxmgr'
2024-04-17 14:08:15.828 LNDINIT: Committing bucket 'wtxmgr'
2024-04-17 14:08:15.833 LNDINIT: Creating 'wallet created' marker
2024-04-17 14:08:15.835 LNDINIT: Committing 'wallet created' marker
```

</details>

{% hint style="info" %}
This process could take a few minutes depending on the size of the database. When the prompt comes back to show you, that the migration is finished successfully
{% endhint %}

* Now follow the [Configured](lightning-client.md#configuration) section `lnd.conf`, to use the PostgreSQL database as the backend, paying attention to the next section

```
# Database
[db]
db.backend=postgres

[postgres]
db.postgres.dsn=postgresql://admin:admin@127.0.0.1:5432/lndb?sslmode=disable
db.postgres.timeout=0
```

* With user admin, edit the [systemd service file](lightning-client.md#create-systemd-service)

```bash
sudo nano /etc/systemd/system/lnd.service
```

* Replace the next lines to include the `postgres.service` dependency

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

* Monitor the LND logs to ensure all is working correctly with the new PostgreSQL database backend successfully migrated

```bash
journalctl -fu lnd
```

{% hint style="info" %}
The `[WRN]` logs indicate that LND has detected an existing old bbolt database and It will not be migrated to postgres automatically, but we already migrated it before 😏

```
[...]
> [WRN] LTND: Found existing bbolt database file in /home/lnd/.lnd/data/chain/bitcoin/mainnet/wallet.db while using database type postgres. Existing data will NOT be migrated to postgres automatically!
> [WRN] LTND: Found existing bbolt database file in /home/lnd/.lnd/data/graph/mainnet/channel.db while using database type postgres. Existing data will NOT be migrated to postgres automatically!
[...]
```

\-> You can delete these logs by following the [next section](lightning-client.md#optional-delete-old-bbolt-files-database)

Pay attention to this `[INF]` significant log to confirm you are using PostgreSQL now

```
[...]
> [INF] LTND: Using remote postgres database! Creating graph and channel state DB instances
[...]
```
{% endhint %}

{% hint style="info" %}
Ensure you still have your node in the same situation before the migration using the [Web app: ThunderHub](web-app.md) or using `lncli` with commands like `lncli listchannels / lncli listunspent / lncli wtclient towers` and see if everything is as you left it before the migration
{% endhint %}

#### (Optional) Delete old bbolt files database

* With user `admin`, change to the `lnd` user

```bash
sudo su - lnd
```

* Detele the old bbolt database files

{% code overflow="wrap" %}
```bash
rm /data/lnd/data/chain/bitcoin/mainnet/macaroons.db && rm /data/lnd/data/chain/bitcoin/mainnet/macaroons.db.last-compacted && rm /data/lnd/data/chain/bitcoin/mainnet/wallet.db && rm /data/lnd/data/graph/mainnet/* && rm /data/lnd/data/watchtower/bitcoin/mainnet/*
```
{% endcode %}

* Return to the `admin` user

```bash
exit
```

### Some useful lncli commands

Quick reference with special commands to play around with:

#### Create your own Re-Usable Static AMP invoice

{% code overflow="wrap" %}
```bash
lncli addinvoice --memo "your memo here" --amt <amount in sats> --expiry <time in seconds> --amp
```
{% endcode %}

{% hint style="info" %}
The flags `--memo` |`--amt` & `--expiry` are optional. The default expiry time will be 30 days by default and the rest can be empty

Copy the output `[lnbc...]` of the "payment\_request": "`lnbc...`". Transform your output payment request into a QR code, embed it on your website, or add it to your social media. LibreOffice has built-in functionality, and there are plenty of freely available online tools
{% endhint %}

#### Pay an AMP invoice (both sender and receiver nodes have to have AMP enabled)

```sh
lncli payinvoice --amt <amount> <amp invoice>
```

#### Send payment to node without invoice using AMP invoice (both sender and receiver nodes have to have AMP enabled)

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
If you want to send a circular payment to yourself, add the next flag at the end of the command:`--allow_self_payment`
{% endhint %}

#### Extract the SegWit and Taproot master public key of your onchain LND wallet

{% code overflow="wrap" %}
```bash
lncli wallet accounts list | grep -A 3 "TAPROOT" && echo "------------------------" && \
lncli wallet accounts list | grep -B 3 "m/84"
```
{% endcode %}

Example of expected output:

<pre><code>            "address_type":  "TAPROOT_PUBKEY",
            "extended_public_key":  "<a data-footnote-ref href="#user-content-fn-25">xpub........</a>",
            "master_key_fingerprint":  "",
            "derivation_path":  "m/86'/0'/0'",
------------------------
            "address_type":  "WITNESS_PUBKEY_HASH",
            "extended_public_key":  "<a data-footnote-ref href="#user-content-fn-26">zpub.........</a>",
            "master_key_fingerprint":  "",
            "derivation_path":  "m/84'/0'/0'",
</code></pre>

## Upgrade

Upgrading LND can lead to some issues. **Always** read the [LND release notes](https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/) completely to understand the changes. These also cover many additional topics and new features not mentioned here.

* Check your current LND version

```sh
lnd --version
```

* Download, verify, and install the latest LND binaries as described in the [Installation section](lightning-client.md#installation) of this guide, replacing the environment variable `"VERSION=x.xx"` value for the latest if it has not been already changed in this guide **(acting behind your responsibility)**
* Restart LND to apply the new version

```sh
sudo systemctl restart lnd
```

## Uninstall

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

### &#x20;Delete user & group&#x20;

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

### Detele the data directory

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

|  Port | Protocol |               Use              |
| :---: | :------: | :----------------------------: |
|  9735 |    TCP   |        Default P2P port        |
| 10009 |    TCP   |        Default gRPC port       |
|  9911 |    TCP   | Default Watchtower server port |

[^1]: zmqpubrawblock port

[^2]: zmqpubrawtx port

[^3]: Check this

[^4]: Check this

[^5]: Check this

[^6]: (**Example)**

[^7]: Check this

[^8]: (**Example)**

[^9]: Symbolic link

[^10]: Symbolic link

[^11]: (Customize)

[^12]: (Uncomment and customize the value)

[^13]: This is the maximum fee rate in sat/vbyte that will be used for commitments of channels of the anchors type. Increasing your commit fee for anchor channels can help get these transactions propagated. While it is always possible to bump the transaction fees of such commitment transactions later using CPFP, a low maximum commit fee may prevent these transactions from being propagated in the first place. **Uncomment and adjust to your criteria** (default: 10 sat/byte)

[^14]: This is the maximum fee rate in sat/vbyte that will be used for commitments of channels of the anchors type. Increasing your commit fee for anchor channels can help get these transactions propagated. While it is always possible to bump the transaction fees of such commitment transactions later using CPFP, a low maximum commit fee may prevent these transactions from being propagated in the first place. **Uncomment and adjust to your criteria** (default: 10 sat/byte)

[^15]: The maximum percentage of total funds that can be allocated to a channel's commitment fee. This only applies for the initiator of the channel. Valid values are within \[0.1, 1]. **Uncomment and adjust to your criteria** (default 0.5)

[^16]: The maximum percentage of total funds that can be allocated to a channel's commitment fee. This only applies for the initiator of the channel. Valid values are within \[0.1, 1]. **Uncomment and adjust to your criteria** (default 0.5)

[^17]: (Uncomment and customize the value)

[^18]: (Uncomment and customize the value)

[^19]: Set this to 144, allows you up to 24h to resolve issues related to your node before HTLCs are resolved on chain. Allowing for fewer HTLCs per channel can mitigate the potential fallout of a force closure, but can also cause the channel to be unusable when all HTLC slots are used up. **Adjust to your convenience** (default 80)

[^20]: Set this to 144, allows you up to 24h to resolve issues related to your node before HTLCs are resolved onchain. Allowing for fewer HTLCs per channel can mitigate the potential fallout of a force closure, but can also cause the channel to be unusable when all HTLC slots are used up. **Adjust to your convenience** (default 80)

[^21]: (Uncomment and customize the value)

[^22]: Setting the fee estimate mode to ECONOMICAL and increasing the target confirmations for onchain transactions can also help save on fees, but with the risk that some transactions may not confirm in time, requiring more manual monitoring and eventual intervention. **Uncomment and customize the value**

[^23]: Symbolic link

[^24]: Check this

[^25]: Your Taproot master public key

[^26]: Your SegWit master public key
