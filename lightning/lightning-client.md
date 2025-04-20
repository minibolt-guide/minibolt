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

We set up [LND](https://github.com/lightningnetwork/lnd), the Lightning Network Daemon, by [Lightning Labs](https://lightning.engineering/).

<div align="center"><img src="../images/lightning-network-daemon-logo.png" alt=""></div>

## Requirements

* [Bitcoin Core](../bitcoin/bitcoin/bitcoin-client.md)
* Others
  * [PostgreSQL](../bonus-guides/system/postgresql.md)

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
sudo ss -tulpn | grep bitcoind | grep 2833
```

Expected output:

<pre><code>tcp   LISTEN 0      100        127.0.0.1:<a data-footnote-ref href="#user-content-fn-1">28332</a>      0.0.0.0:*    users:(("bitcoind",pid=773834,fd=20))
tcp   LISTEN 0      100        127.0.0.1:<a data-footnote-ref href="#user-content-fn-2">28333</a>      0.0.0.0:*    users:(("bitcoind",pid=773834,fd=22))
</code></pre>

### Install PostgreSQL

{% hint style="warning" %}
You may want to use the bbolt database backend instead of PostgreSQL (easier installation/configuration, lower performance, see more [here](https://github.com/minibolt-guide/minibolt/pull/93)), if yes, jump to the [next step](lightning-client.md#installation) and follow the [Use the default bbolt database backend](lightning-client.md#use-the-default-bbolt-database-backend) section, and remember to create the `lnd.conf` properly with this configuration when you arrive at the [configuration section](lightning-client.md#configuration)
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
VERSION=0.18.5
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

* Get the public key from a LND developer, who signed the manifest file, and add it to your GPG keyring

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

* Having verified the integrity and authenticity of the release binary, we can safely

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

* Ensure you are installed by running the version command

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

* Add the `lnd` user to the groups "bitcoin" and "debian-tor", allowing the `lnd` user reads the bitcoind `.cookie` file and to use the control port to configure Tor directly

```sh
sudo usermod -a -G bitcoin,debian-tor lnd
```

* Add the user `admin` to the group "lnd"

```sh
sudo adduser admin lnd
```

Expected output:

```
Adding user `admin' to group `lnd' ...
Done.
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

LND includes a Bitcoin wallet that manages your onchain and Lightning coins. It is password protected and must be unlocked when LND starts. This creates the dilemma that you either manually unlock LND after each restart of your PC, or store the password somewhere on the node.

For this initial setup, we choose the easy route: we store the password in a file that allows LND to unlock the wallet automatically.

* Still as user `lnd`, create a text file and enter your LND wallet `password [C]`. **Password should have at least 8 characters.** Save and exit

```sh
nano /data/lnd/password.txt
```

* Tighten access privileges and make the file readable only for the user `lnd`

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
<a data-footnote-ref href="#user-content-fn-5">#minchansize=20000</a>

## (Optional) High fee environment settings
<a data-footnote-ref href="#user-content-fn-7">#max-commit-fee-rate-anchors=</a><a data-footnote-ref href="#user-content-fn-7">10</a>
<strong><a data-footnote-ref href="#user-content-fn-8">#max-channel-fee-allocation=</a><a data-footnote-ref href="#user-content-fn-8">0.5</a>
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
<a data-footnote-ref href="#user-content-fn-5">#bitcoin.basefee=1000</a>
<a data-footnote-ref href="#user-content-fn-5">#bitcoin.feerate=1</a>

# (Optional) Specify the CLTV delta we will subtract from a forwarded HTLC's timelock value
# (default: 80)
<a data-footnote-ref href="#user-content-fn-9">#bitcoin.timelockdelta=8</a><a data-footnote-ref href="#user-content-fn-10">0</a>

[protocol]
protocol.wumbo-channels=true
protocol.option-scid-alias=true
protocol.simple-taproot-chans=true

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

[postgres]
db.postgres.dsn=postgresql://admin:admin@127.0.0.1:5432/lndb?sslmode=disable
db.postgres.timeout=0

## (Optional) High fee environment settings
# (default: CONSERVATIVE) Uncomment the next 2 lines
#[Bitcoind]
<a data-footnote-ref href="#user-content-fn-11">#bitcoind.estimatemode=ECONOMICAL</a>

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
These 24 words are all that you need (and the `channel.backup` file in case of disaster recovery) to restore the Bitcoin onchain wallet and possibly UTXOs blocked

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
However, the current state of your channels, cannot be recreated from this seed. For this, the Static Channel Backup is stored `/data/lnd/data/chain/bitcoin/mainnet/channel.backup` is updated for each channel opening and closing

There is a dedicated [guide](channel-backup.md) to making an automatic backup
{% endhint %}

* Return to the `admin` user

```sh
exit
```

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
lrwxrwxrwx  1 admin admin     9 Jul 18 07:10 <a data-footnote-ref href="#user-content-fn-12">.lnd -> /data/lnd</a>
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
The next commands can be entered in any new session without keeping a specific terminal open with logs, but I recommend keeping this just in case any log could give extra information about the command you just entered
{% endhint %}

### Watchtower client

Lightning channels need to be monitored to prevent malicious behavior by your channel peers. If your MiniBolt goes down for a longer time, for instance, due to a hardware problem, a node on the other side of one of your channels might try to close the channel with an earlier channel balance that is better for them.

Watchtowers are other Lightning nodes that can monitor your channels for you. If they detect such bad behavior, they can react on your behalf and send a punishing transaction to close this channel. In this case, all channel funds will be sent to your LND on-chain wallet.

A watchtower can only send such a punishing transaction to your wallet, so you don't have to trust them. It's good practice to add a few watchtowers, just to be on the safe side.

* With user `admin`, add the Tor address of the [official MiniBolt Watchtower Server](../#free-services) as a first example

{% code overflow="wrap" %}
```bash
lncli wtclient add 02ad47b4e41cfce258e2db8d7eb9a194570ca29beba2897970d1ecc7d1c9a2726b@zm32w2qs2lf6xljnvqnmv6o2xlufsf4g6vfjihyydg4yhxph4fnqcvyd.onion:9911
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
            "pubkey": "02ad47b4e41cfce258e2db8d7eb9a194570ca29beba2897970d1ecc7d1c9a2726b",
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

* If you want to deactivate an active tower

```sh
lncli wtclient remove <pubkey>
```

{% hint style="info" %}
Monitor logs with `journalctl -fu lnd` to check the watchtower client is working fine, it should show you after a while, the next logs ⬇️
{% endhint %}

<figure><img src="../.gitbook/assets/lnd-watchtower_log.PNG" alt=""><figcaption></figcaption></figure>

### Watchtower server

Same you can connect as a watchtower client to other watchtower servers, and you could give the same service by running an altruistic watchtower server. **This was previously activated** in the `lnd.conf`, and you can see the information about it by typing the following command and sharing it with your peers.

```sh
lncli tower info
```

**Example** of expected output:

```
{
  "pubkey": "02ad47b4e41cfce258e2db8d7eb9a194570ca29beba2897970d1ecc7d1c9a2726b",
  "listeners": [
      "[::]:9911"
  ],
  "uris": [
      "zm32w2qs2lf6xljnvqnmv6o2xlufsf4g6vfjihyydg4yhxph4fnqcvyd.onion:9911"
  ]
}
```

{% hint style="warning" %}
This watchtower server service is not recommended to activate if you have a slow device without high-performance features. If yes, consider disabling it by commenting or deleting the line `watchtower.active=true` of the `lnd.conf` file
{% endhint %}

{% hint style="info" %}
Almost all of the following steps could be run with the [mobile](mobile-app.md) | [web](web-app.md) app guides. We strongly recommend using these applications with intuitive and visual UI to manage the Lightning Node, instead of using the command line. Anyway, if you want to explore the `lncli`, you have some useful commands in the[ extra section](lightning-client.md#some-useful-lncli-commands)
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
Attention:  It is recommended to start from scratch by closing all existing channels, rather than a migration, to ensure we don't lose anything because it is not possible to come back to the old bbolt database once migrated
{% endhint %}

#### Install lndinit

* We'll download, verify, and install `lndinit`. With the user `admin`, navigate to the temporary directory

```bash
cd /tmp
```

* Set a temporary version environment variable for the installation

```bash
VERSION=0.1.26
```

* Download the application, checksums, and signature

{% code overflow="wrap" %}
```bash
wget https://github.com/lightninglabs/lndinit/releases/download/v$VERSION-beta/lndinit-linux-amd64-v$VERSION-beta.tar.gz
```
{% endcode %}

{% code overflow="wrap" %}
```bash
wget https://github.com/lightninglabs/lndinit/releases/download/v$VERSION-beta/manifest-v$VERSION-beta.txt
```
{% endcode %}

{% code overflow="wrap" %}
```bash
wget https://github.com/lightninglabs/lndinit/releases/download/v$VERSION-beta/manifest-v$VERSION-beta.sig.ots
```
{% endcode %}

{% code overflow="wrap" %}
```bash
wget https://github.com/lightninglabs/lndinit/releases/download/v$VERSION-beta/manifest-v$VERSION-beta.sig
```
{% endcode %}

#### Checksum check <a href="#checksum-check" id="checksum-check"></a>

* Verify the signed checksum against the actual checksum of your download

```bash
sha256sum --check manifest-v$VERSION-beta.txt --ignore-missing
```

**Example** of expected output:

```
lndinit-linux-amd64-v0.1.26-beta.tar.gz: OK
```

#### Signature check <a href="#signature-check" id="signature-check"></a>

Now that we've verified the integrity of the downloaded binary, we need to check the authenticity of the manifest file we just used, starting with its signature.

* Get the public key from a LND developer, who signed the manifest file, and add it to your GPG keyring

```bash
curl https://keybase.io/guggero/pgp_keys.asc | gpg --import
```

Expected output:

<pre><code>  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 19417  100 19417    0     0   1799      0  0:00:10  0:00:10 --:--:--  4130
gpg: key 8E4256593F177720: 1 signature not checked due to a missing key
gpg: key 8E4256593F177720: "Oliver Gugger &#x3C;gugger@gmail.com>" <a data-footnote-ref href="#user-content-fn-3">imported</a>
gpg: Total number processed: 1
gpg:              unchanged: 1
</code></pre>

* Verify the signature of the text file containing the checksums for the application

```bash
gpg --verify manifest-v$VERSION-beta.sig manifest-v$VERSION-beta.txt
```

**Example** of expected output:

<pre><code>gpg: Signature made Tue 15 Apr 2025 05:16:09 PM UTC
gpg:                using RSA key F4FC70F07310028424EFC20A8E4256593F177720
gpg: <a data-footnote-ref href="#user-content-fn-3">Good signature</a> from "Oliver Gugger &#x3C;gugger@gmail.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: F4FC 70F0 7310 0284 24EF  C20A 8E42 5659 3F17 7720
</code></pre>

#### Timestamp check <a href="#timestamp-check" id="timestamp-check"></a>

We can also check that the manifest file was in existence around the time of the release using its timestamp.

* Let's verify that the timestamp of the file matches the release date

```bash
ots --no-cache verify manifest-v$VERSION-beta.sig.ots -f manifest-v$VERSION-beta.sig
```

**Example** of expected output:

<pre><code>Got 1 attestation(s) from https://alice.btc.calendar.opentimestamps.org
Got 1 attestation(s) from https://bob.btc.calendar.opentimestamps.org
Got 1 attestation(s) from https://finney.calendar.eternitywall.com
<a data-footnote-ref href="#user-content-fn-3">Success</a>! Bitcoin block 892581 attests existence as of 2025-04-15 UTC
</code></pre>

{% hint style="info" %}
Check that the date of the timestamp is close to the [release date](https://github.com/lightninglabs/lndinit/releases) of the lndinit binary
{% endhint %}

* Having verified the integrity and authenticity of the release binary, we can safely

```bash
tar -xzvf lndinit-linux-amd64-v$VERSION-beta.tar.gz
```

**Example** of expected output:

```
lndinit-linux-amd64-v0.1.26-beta/lndinit
lndinit-linux-amd64-v0.1.26-beta/
```

#### Binaries installation <a href="#binaries-installation" id="binaries-installation"></a>

-> 2 options, depending on whether you want to use it only once or make a permanent installation:

{% tabs %}
{% tab title="1. Temporary use (recommended)" %}
In this case, only go to [the next step](lightning-client.md#migrate-bbolt-database-to-postgresql)
{% endtab %}

{% tab title="2. Permanent installation" %}
* Install the binaries on the OS

{% code overflow="wrap" %}
```bash
sudo install -m 0755 -o root -g root -t /usr/local/bin lndinit-linux-amd64-v$VERSION-beta/lndinit
```
{% endcode %}

* (Optional) Clean the lndinit files of the `tmp` folder

{% code overflow="wrap" %}
```bash
sudo rm -r lndinit-linux-amd64-v$VERSION-beta && sudo rm lndinit-linux-amd64-v$VERSION-beta.tar.gz && sudo rm manifest-v$VERSION-beta.sig && sudo rm manifest-v$VERSION-beta.txt && sudo rm manifest-v$VERSION-beta.sig.ots
```
{% endcode %}
{% endtab %}
{% endtabs %}

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
* Depending on whether you selected on the [Binaries installation section](lightning-client.md#binaries-installation-1) the [option 1](lightning-client.md#id-1.-temporary-use-recomended) or [2](lightning-client.md#id-2.-permanet-installation):

{% tabs %}
{% tab title="1. For temporary use option (recommended)" %}
- Go to the lndinit folder

```bash
cd lndinit-linux-amd64-v$VERSION-beta
```

* Execute the migration and wait to finish

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
This process could take a few minutes, depending on the database size. When the prompt comes back to show you that the migration is finished successfully
{% endhint %}
{% endtab %}

{% tab title="2. For permanent installation option" %}
* Execute the migration and wait to finish

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
This process could take a few minutes, depending on the database size. When the prompt comes back to show you that the migration is finished successfully
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

* (Optional) If you used the [1. For temporary use](lightning-client.md#id-1.-for-temporary-use-recommended) option, clean the lndinit files of the `tmp` folder

<pre class="language-bash" data-overflow="wrap"><code class="lang-bash"><strong>sudo rm -r /tmp/lndinit-linux-amd64-v$VERSION-beta &#x26;&#x26; sudo rm /tmp/lndinit-linux-amd64-v$VERSION-beta.tar.gz &#x26;&#x26; sudo rm /tmp/manifest-v$VERSION-beta.sig &#x26;&#x26; sudo rm /tmp/manifest-v$VERSION-beta.txt &#x26;&#x26; sudo rm /tmp/manifest-v$VERSION-beta.sig.ots
</strong></code></pre>

* Now, edit the `lnd.conf` configuration file to use the PostgreSQL database as the backend

```bash
sudo nano /data/lnd/lnd.conf
```

* Replace or comment with "`#`" the `# Database` section about the bbolt database backend

```
[bolt]
## Database
# Set the next value to false to disable auto-compact DB
# and fast boot and comment the next line
db.bolt.auto-compact=true
# Uncomment to do DB compact at every LND reboot (default: 168h)
#db.bolt.auto-compact-min-age=0h
```

* To this

```
# Database
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
-> The `[WRN]` logs indicate that LND has detected an existing old bbolt database and it will not be migrated to PostgreSQL automatically, but we already migrated it before 😏

```
[...]
[WRN] LTND: Found existing bbolt database file in /home/lnd/.lnd/data/chain/bitcoin/mainnet/wallet.db while using database type postgres. Existing data will NOT be migrated to postgres automatically!
[WRN] LTND: Found existing bbolt database file in /home/lnd/.lnd/data/graph/mainnet/channel.db while using database type postgres. Existing data will NOT be migrated to postgres automatically!
[...]
```



-> You can delete these logs by following the [next section](lightning-client.md#optional-delete-old-bbolt-files-database)



-> Pay attention to this `[INF]` significant log to confirm you are using PostgreSQL now

```
[...]
[INF] LTND: Using remote postgres database! Creating graph and channel state DB instances
[...]
```
{% endhint %}

{% hint style="info" %}
Ensure you still have your node in the same situation before the migration using the [Web app: ThunderHub](web-app.md), or using `lncli` with commands like `lncli listchannels / lncli listunspent / lncli wtclient towers` and see if everything is as you left it before the migration
{% endhint %}

#### (Optional) Delete old bbolt files database

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

#### -> Pay an AMP invoice (both sender and receiver nodes have to have AMP enabled)

```sh
lncli payinvoice --amt <amount> <amp invoice>
```

#### -> Send payment to node without invoice using AMP invoice (both sender and receiver nodes have to have AMP enabled)

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

#### -> Extract the SegWit and Taproot master public key of your onchain LND wallet

{% code overflow="wrap" %}
```bash
lncli wallet accounts list | grep -A 3 "TAPROOT" && echo "------------------------" && \
lncli wallet accounts list | grep -B 3 "m/84"
```
{% endcode %}

Example of expected output:

<pre><code>            "address_type":  "TAPROOT_PUBKEY",
            "extended_public_key":  "<a data-footnote-ref href="#user-content-fn-13">xpub........</a>",
            "master_key_fingerprint":  "",
            "derivation_path":  "m/86'/0'/0'",
------------------------
            "address_type":  "WITNESS_PUBKEY_HASH",
            "extended_public_key":  "<a data-footnote-ref href="#user-content-fn-14">zpub.........</a>",
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

<table><thead><tr><th align="center">Port</th><th width="100">Protocol<select><option value="7Up5aFCtAhTE" label="TCP" color="blue"></option><option value="lN0Rb1BwaZr0" label="SSL" color="blue"></option><option value="Wo2y5caRH1ZO" label="UDP" color="blue"></option></select></th><th align="center">Use</th></tr></thead><tbody><tr><td align="center">9735</td><td><span data-option="7Up5aFCtAhTE">TCP</span></td><td align="center">Default P2P port</td></tr><tr><td align="center">10009</td><td><span data-option="7Up5aFCtAhTE">TCP</span></td><td align="center">Default gRPC port</td></tr><tr><td align="center">9911</td><td><span data-option="7Up5aFCtAhTE">TCP</span></td><td align="center">Default Watchtower server port</td></tr></tbody></table>

[^1]: zmqpubrawblock port

[^2]: zmqpubrawtx port

[^3]: Check this

[^4]: (**Example)**

[^5]: (Uncomment and customize the value)

[^6]: (Customize)

[^7]: This is the maximum fee rate in sat/vbyte that will be used for commitments of channels of the anchors type. Increasing your commit fee for anchor channels can help get these transactions propagated. While it is always possible to bump the transaction fees of such commitment transactions later using CPFP, a low maximum commit fee may prevent these transactions from being propagated in the first place. **Uncomment and adjust to your criteria** (default: 10 sat/byte)

[^8]: The maximum percentage of total funds that can be allocated to a channel's commitment fee. This only applies for the initiator of the channel. Valid values are within \[0.1, 1]. **Uncomment and adjust to your criteria** (default 0.5)

[^9]: Set this to 144, allows you up to 24h to resolve issues related to your node before HTLCs are resolved on chain. Allowing for fewer HTLCs per channel can mitigate the potential fallout of a force closure, but can also cause the channel to be unusable when all HTLC slots are used up. **Adjust to your convenience** (default 80)

[^10]: Set this to 144, allows you up to 24h to resolve issues related to your node before HTLCs are resolved onchain. Allowing for fewer HTLCs per channel can mitigate the potential fallout of a force closure, but can also cause the channel to be unusable when all HTLC slots are used up. **Adjust to your convenience** (default 80)

[^11]: Setting the fee estimate mode to ECONOMICAL and increasing the target confirmations for onchain transactions can also help save on fees, but with the risk that some transactions may not confirm in time, requiring more manual monitoring and eventual intervention. **Uncomment and customize the value** (default: CONSERVATIVE)

[^12]: Symbolic link

[^13]: Your Taproot master public key

[^14]: Your SegWit master public key
