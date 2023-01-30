---
layout: default
title: Lightning client
nav_order: 10
parent: Lightning
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->

# Lightning client: LND

{: .no_toc }

---

We set up [LND](https://github.com/lightningnetwork/lnd/blob/master/README.md){:target="_blank"}, the Lightning Network Daemon by [Lightning Labs](https://lightning.engineering/){:target="_blank"}.

![Lightning Network Daemon logo](../../images/lightning-network-daemon-logo.png)

---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Preparations

The installation of LND is straight-forward, but the application is quite powerful and capable of things not explained here. Check out their [GitHub repository](https://github.com/lightningnetwork/lnd/){:target="_blank"} for a wealth of information about their open-source project and Lightning in general.

### Configure Bitcoin Core

Before running LND, we need to set up settings in the Bitcoin Core configuration file to enable LND RPC connection - add new lines if they are not present

* Login as "admin" edit `bitcoin.conf`, and add the following lines. Save and exit

  ```sh
  $ sudo nano /data/bitcoin/bitcoin.conf
  ```

  ```sh
  # LND RPC connection
  zmqpubrawblock=tcp://127.0.0.1:28332
  zmqpubrawtx=tcp://127.0.0.1:28333
  ```

* Restart Bitcoin Core to apply the changes

  ```sh
  $ sudo systemctl restart bitcoind
  ```

### Download

* Login as "admin" and change to a temporary directory which is cleared on reboot.

  ```sh
  $ cd /tmp
  ```

* Set a temporary version environment variable to the installation

  ```sh
  $ VERSION=v0.15.5
  ```

* Download

  ```sh
  $ wget https://github.com/lightningnetwork/lnd/releases/download/$VERSION-beta/lnd-linux-amd64-$VERSION-beta.tar.gz
  $ wget https://github.com/lightningnetwork/lnd/releases/download/$VERSION-beta/manifest-$VERSION-beta.txt
  $ wget https://github.com/lightningnetwork/lnd/releases/download/$VERSION-beta/manifest-roasbeef-$VERSION-beta.sig.ots
  $ wget https://github.com/lightningnetwork/lnd/releases/download/$VERSION-beta/manifest-roasbeef-$VERSION-beta.sig
  ```

### Checksum check

* Verify the signed checksum against the actual checksum of your download

  ```sh
  $ sha256sum --check manifest-$VERSION-beta.txt --ignore-missing

Expected output

  ```sh
  > lnd-linux-amd64-$VERSION-beta.tar.gz: OK
  ```

### Signature check

Now that we've verified the integrity of the downloaded binary, we need to check the authenticity of the manifest file we just used, starting with its signature.

* Get the public key from the LND developer, [Olaoluwa Osuntokun](https://keybase.io/roasbeef){:target="_blank"}, who signed the manifest file; and add it to your GPG keyring

  ```sh
  $ curl https://raw.githubusercontent.com/lightningnetwork/lnd/master/scripts/keys/roasbeef.asc | gpg --import
  ```

Expected output

  ```sh
  > ...
  > gpg: key 372CBD7633C61696: "Olaoluwa Osuntokun <laolu32@gmail.com>"
  > ...
  ```

* Verify the signature of the text file containing the checksums for the application

  ```sh
  $ gpg --verify manifest-roasbeef-$VERSION-beta.sig manifest-$VERSION-beta.txt
  ```

Expected output

  ```sh
  > gpg: Signature made Thu Dec  1 19:20:10 2022 UTC
  > gpg:                using RSA key 60A1FA7DA5BFF08BDCBBE7903BBD59E99B280306
  > gpg: Good signature from "Olaoluwa Osuntokun <laolu32@gmail.com>" [unknown]
  > gpg: WARNING: This key is not certified with a trusted signature!
  > gpg:          There is no indication that the signature belongs to the owner.
  > Primary key fingerprint: E4D8 5299 674B 2D31 FAA1  892E 372C BD76 33C6 1696
  >      Subkey fingerprint: 60A1 FA7D A5BF F08B DCBB  E790 3BBD 59E9 9B28 0306
  ```

### Timestamp check

We can also check that the manifest file was in existence around the time of the release using its timestamp.

* Let's verify the timestamp of the file matches the release date.

  ```sh
  $ ots --no-cache verify manifest-roasbeef-$VERSION-beta.sig.ots -f manifest-roasbeef-$VERSION-beta.sig

The following output is just an example of one of the versions

  ```sh
  > Got 1 attestation(s) from https://alice.btc.calendar.opentimestamps.org
  > Got 1 attestation(s) from https://btc.calendar.catallaxy.com
  > Got 1 attestation(s) from https://finney.calendar.eternitywall.com
  > Got 1 attestation(s) from https://bob.btc.calendar.opentimestamps.org
  > Success! Bitcoin block 765521 attests existence as of 2022-12-01 UTC
  ```

Check that the date of the timestamp (here 2022-12-01) is close to the [release date](https://github.com/lightningnetwork/lnd/releases){:target="_blank"} of the LND binary (2022-12-02).

## Installation

Having verified the integrity and authenticity of the release binary, we can safely proceed to install it

  ```sh
  $ tar -xzf lnd-linux-amd64-$VERSION-beta.tar.gz
  $ sudo install -m 0755 -o root -g root -t /usr/local/bin lnd-linux-amd64-$VERSION-beta/*
  $ lnd --version
  > lnd version $VERSION-beta commit=$VERSION-beta
  ```

### Data directory

Now that LND is installed, we need to configure it to work with Bitcoin Core and run automatically on startup.

* Create the "lnd" service user, and add it to the groups "bitcoin" and "debian-tor"

  ```sh
  $ sudo adduser --disabled-password --gecos "" lnd
  $ sudo usermod -a -G bitcoin,debian-tor lnd
  ```

* Add the user "admin" to the group "lnd"

  ```sh
  $ sudo adduser admin lnd
  ```

* Create the LND data directory

  ```sh
  $ sudo mkdir /data/lnd
  $ sudo chown -R lnd:lnd /data/lnd
  ```

* Open a "lnd" user session

  ```sh
  $ sudo su - lnd
  ```

* Create symbolic links pointing to the LND and bitcoin data directories

  ```sh
  $ ln -s /data/lnd /home/lnd/.lnd
  $ ln -s /data/bitcoin /home/lnd/.bitcoin
  ```

### Wallet password

LND includes a Bitcoin wallet that manages your on-chain and Lightning coins.
It is password protected and must be unlocked when LND starts.
This creates the dilemma that you either manually unlock LND after each restart of your PC, or you store the password somewhere on the node.

For this initial setup, we choose the easy route: we store the password in a file that allows LND to unlock the wallet automatically.
This is not the most secure setup, but you can improve it later if you want, with the bonus guides linked below.
To give some perspective: other Lightning implementations like c-lightning or Eclair don't even have a password.

* As user "lnd", create a text file and enter your LND wallet `password [C]`. Save and exit.

  ```sh
  $ nano /data/lnd/password.txt
  ```

* Tighten access privileges and make the file readable only for user "lnd"

  ```sh
  $ chmod 600 /data/lnd/password.txt
  ```

### Configuration

#### Configure LND

* Create the LND configuration file and paste the following content ***(adjust to your alias, your color, your minimum channel size and fees)***.
  Save and exit.

  ```sh
  $ nano /data/lnd/lnd.conf
  ```

  ```sh
  # MiniBolt: lnd configuration
  # /data/lnd/lnd.conf

  [Application Options]
  # Alias accepts emojis i.e ⚡🧡​ https://emojikeyboard.top/
  alias=YOUR_FANCY_ALIAS
  # You can choose the color you want at https://www.color-hex.com/
  color=#ff9900
  listen=localhost
  nat=false
  debuglevel=info

  # Password: automatically unlock wallet with the password in this file
  # -- comment out to manually unlock wallet, and see MiniBolt guide for more secure options
  wallet-unlock-password-file=/data/lnd/password.txt
  wallet-unlock-allow-create=true

  # Automatically regenerate certificate when near expiration
  tlsautorefresh=true
  # Do not include the interface IPs or the system hostname in TLS certificate.
  tlsdisableautofill=true

  # Channel settings
  # Fee settings - default LND base fee = 1000 (mSat), default LND fee rate = 1 (ppm)
  # You can choose whatever you want e.g ZeroFeeRouting (0,0)
  #bitcoin.basefee=0
  #bitcoin.feerate=0

  # Minimum channel size (in satoshis, default and minimun from source code is 20,000 sats) # You can choose whatever you want
  #minchansize=20000
  maxpendingchannels=5
  accept-keysend=true
  accept-amp=true
  protocol.wumbo-channels=true
  protocol.no-anchors=false
  coop-close-target-confs=24

  # Watchtower client
  wtclient.active=true
  # Specify the fee rate with which justice transactions will be signed. The default is 10 sat/byte.
  #wtclient.sweep-fee-rate=10

  # Watchtower server
  watchtower.active=1

  # Performance
  gc-canceled-invoices-on-startup=true
  gc-canceled-invoices-on-the-fly=true
  ignore-historical-gossip-filters=1
  stagger-initial-reconnect=true
  routing.strictgraphpruning=true

  # Database
  [bolt]
  # Set the next value to false to disable auto-compact DB and fast boot and comment the next line
  db.bolt.auto-compact=true
  # Uncomment and set the next value to "0" to do DB compact at every LND reboot (default: 168h)
  #db.bolt.auto-compact-min-age=168h

  [Bitcoind]
  bitcoind.estimatemode=ECONOMICAL

  [Bitcoin]
  bitcoin.active=1
  bitcoin.mainnet=1
  bitcoin.node=bitcoind

  [tor]
  tor.active=true
  tor.v3=true
  tor.streamisolation=true
  ```

🔍 *This is a standard configuration. Check the official LND [sample-lnd.conf](https://github.com/lightningnetwork/lnd/blob/master/sample-lnd.conf){:target="_blank"} with all possible options

* Exit "lnd" user session to return to "admin" user session

  ```sh
  $ exit
  ```

### Autostart on boot

Now, let's set up LND to start automatically on system startup.

* As user `admin`, create LND systemd unit with the following content. Save and exit.

  ```sh
  $ sudo nano /etc/systemd/system/lnd.service
  ```

  ```sh
  # MiniBolt: systemd unit for lnd
  # /etc/systemd/system/lnd.service

  [Unit]
  Description=LND Lightning Network Daemon
  After=bitcoind.service
  PartOf=bitcoind.service

  [Service]
  ExecStart=/usr/local/bin/lnd
  ExecStop=/usr/local/bin/lncli stop
  Type=simple
  Restart=always
  RestartSec=30
  TimeoutSec=240
  LimitNOFILE=128000
  User=lnd
  RuntimeDirectory=lightningd
  RuntimeDirectoryMode=0710
  PrivateTmp=true
  ProtectSystem=full
  NoNewPrivileges=true
  PrivateDevices=true
  MemoryDenyWriteExecute=true

  [Install]
  WantedBy=multi-user.target
  ```

* Enable, start and unlock LND

  ```sh
  $ sudo systemctl enable lnd
  ```

* Now, the daemon information is no longer displayed on the command line but written into the system journal.
  You can check on it using the following command.

  ```sh
  $ sudo journalctl -f -u lnd
  ```

## Run LND

[Start your SSH program](../system/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the PC and log in as "admin".
Commands for the **second session** start with the prompt `$2` (which must not be entered).

```sh
$2 sudo systemctl start lnd
```

Monitor the systemd journal at the first session created to check if everything works fine. You can exit monitoring at any time with `Ctrl-C`

  ```sh
  > Dec 02 09:23:37 minibolt systemd[1]: Started LND Lightning Network Daemon.
  > Dec 02 09:23:37 minibolt lnd[2584156]: Attempting automatic RPC configuration to bitcoind
  > Dec 02 09:23:37 minibolt lnd[2584156]: Automatically obtained bitcoind's RPC credentials
  > Dec 02 09:23:37 minibolt lnd[2584156]: 2022-12-02 09:23:37.974 [INF] LTND: Version: 0.15.5-beta commit=v0.15.5-beta, build=production, logging=default, debuglevel=info
  > Dec 02 09:23:37 minibolt lnd[2584156]: 2022-12-02 09:23:37.974 [INF] LTND: Active chain: Bitcoin (network=mainnet)
  > Dec 02 09:23:37 minibolt lnd[2584156]: 2022-12-02 09:23:37.975 [INF] RPCS: RPC server listening on 127.0.0.1:10009
  > Dec 02 09:23:37 minibolt lnd[2584156]: 2022-12-02 09:23:37.976 [INF] RPCS: gRPC proxy started at 127.0.0.1:8080
  > Dec 02 09:23:37 minibolt lnd[2584156]: 2022-12-02 09:23:37.976 [INF] LTND: Opening the main database, this might take a few minutes...
  > Dec 02 09:23:37 minibolt lnd[2584156]: 2022-12-02 09:23:37.976 [INF] LTND: Opening bbolt database, sync_freelist=false, auto_compact=true
  [...]
  ```

### Wallet setup

Once LND is started, the process waits for us to create the integrated Bitcoin onchain wallet.

* Change to "lnd" user

  ```sh
  $2 sudo su - lnd
  ```

* Create the LND wallet

  ```sh
  $2 lncli create
  ```

* Enter your `password [C]` as wallet password (it must be exactly the same you stored in `password.txt`).
  To create a new wallet, select `n` when asked if you have an existing cipher seed.
  Just press enter if asked about an additional seed passphrase, unless you know what you're doing.
  A new cipher seed consisting of 24 words is created.

  ```
  Do you have an existing cipher seed mnemonic or extended master root key you want to use?
  Enter 'y' to use an existing cipher seed mnemonic, 'x' to use an extended master root key
  or 'n' to create a new seed (Enter y/x/n): n

  Your cipher seed can optionally be encrypted.
  Input your passphrase if you wish to encrypt it (or press enter to proceed without a cipher seed passphrase):

  Generating fresh cipher seed...

  !!!YOU MUST WRITE DOWN THIS SEED TO BE ABLE TO RESTORE THE WALLET!!!

  ---------------BEGIN LND CIPHER SEED---------------
  1. secret     2. secret    3. secret     4. secret
  ...
  ```

These 24 words is all that you need to restore the Bitcoin on-chain wallet.

* **Write these 24 words down manually on a piece of paper and store it in a safe place.**

You can use a simple piece of paper, write them on the custom themed [Shiftcrypto backup card](https://shiftcrypto.ch/backupcard/backupcard_print.pdf){:target="_blank"}, or even [stamp the seed words into metal](../bonus/bitcoin/safu-ninja.md).
This piece of paper is all an attacker needs to completely empty your on-chain wallet!
Do not store it on a computer.
Do not take a picture with your mobile phone.
**This information should never be stored anywhere in digital form.**
The current state of your channels, however, cannot be recreated from this seed.
For this, the Static Channel Backup stored at `/data/lnd/data/chain/bitcoin/mainnet/channel.backup` is updated for each channel opening and closing.

🚨 This information must be kept secret at all times.

### Allow user "admin" to work with LND

We interact with LND using the application `lncli`.
At the moment, only the user "lnd" has the necessary access privileges.
To make the user "admin" the main administrative user, we make sure it can interact with LND as well.

* Type "exit" to return to the admin user

  ```sh
  $2 exit
  ```

* As user "admin", link the LND data directory in the user "admin" home.
  As a member of the group "lnd", admin has read-only access to certain files.
  We also need to make all directories browsable for the group (with `g+X`) and allow it to read the file `admin.macaroon`

  ```sh
  $2 ln -s /data/lnd /home/admin/.lnd
  $2 sudo chmod -R g+X /data/lnd/data/
  $2 sudo chmod g+r /data/lnd/data/chain/bitcoin/mainnet/admin.macaroon
  ```

* Check if you can use `lncli` by querying LND for information

  ```sh
  $2 lncli getinfo
  ```

## LND in action

💊 Now your Lightning node is ready. This is also the point of no return. Up until now, you can just start over. Once you send real bitcoin to your MiniBolt, you have "skin in the game"

### Watchtower client

Lightning channels need to be monitored to prevent malicious behavior by your channel peers.
If your MiniBolt goes down for a longer period, for instance, due to a hardware problem, a node on the other side of one of your channels might try to close the channel with an earlier channel balance that is better for them.

Watchtowers are other Lightning nodes that can monitor your channels for you.
If they detect such bad behavior, they can react on your behalf, and send a punishing transaction to close this channel.
In this case, all channel funds will be sent to your LND on-chain wallet.

A watchtower can only send such a punishing transaction to your wallet, so you don't have to trust them.
It's good practice to add a few watchtowers, just to be on the safe side.

* With user `"admin"` or `"lnd"`, add the [Lightning Network+ watchtower](https://lightningnetwork.plus/watchtower){:target="_blank"} as a first example

  ```sh
  $2 lncli wtclient add 023bad37e5795654cecc69b43599da8bd5789ac633c098253f60494bde602b60bf@iiu4epqzm6cydqhezueenccjlyzrqeruntlzbx47mlmdgfwgtrll66qd.onion:9911
  ```

* Or the clearnet address

  ```sh
  $2 lncli wtclient add 023bad37e5795654cecc69b43599da8bd5789ac633c098253f60494bde602b60bf@34.216.52.158:9911
  ```

* If you want to list your towers and active watchtowers

  ```sh
  $2 lncli wtclient towers
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
  $2 lncli wtclient remove <pubkey>
  ```

### Watchtower server

Same as you can connect as a watchtower client to other watchtower servers, you could give the same service running an altruist watchtower server. This was previously activated in `lnd.conf`, and you can see the information about it by typing the following command and sharing it with your peers.

  ```sh
  $2 lncli tower info
  ```

Example output:

  ```sh
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

⚠️ This service is not recommended to activate if you have a slow device without high-performance features, if yes considered to disable it.

💡 Almost all of the following steps could be run with the [mobile](../lightning/web-app.md)/[web](../lightning/web-app.md) app guides

### Funding your Lightning node

* Generate a new Bitcoin address (p2tr = taproot/bech32m) to receive funds on-chain and send a small amount of Bitcoin to it from any wallet of your choice.

  ```sh
  $2 lncli newaddress p2tr
  > "address": "bc1p..."
  ```

* Check your LND wallet balance. (The output is only an example)

  ```sh
  $2 lncli walletbalance
  {
      "total_balance": "712345",
      "confirmed_balance": "0",
      "unconfirmed_balance": "712345"
  }
  ```

As soon as your funding transaction is mined (1 confirmation), LND will show its amount as "confirmed_balance".

💡 If you want to open a few channels, you might want to send a few transactions.
If you have only one UTXO, you need to wait for the change to return to your wallet after every new channel opening.

### Opening channels

Although LND features an optional "autopilot", we manually open some channels.

We recommend going on [Amboss.space](https://www.amboss.space/){:target="_blank"} or [1ML.com](https://1ml.com){:target="_blank"} and look for a mix of big and small nodes with decent Node Ranks.
Another great way to find peers to collaboratively set up channels is [LightningNetwork+](https://lightningnetwork.plus/){:target="_blank"}.

To connect to a remote node, you need its URI that looks like `<pubkey>@host`:

* the `<pubkey>` is just a long hexadecimal number, like `02b03a1d133c0338c0185e57f0c35c63cce53d5e3ae18414fc40e5b63ca08a2128`
* the `host` can be a domain name, a clearnet ip address or a Tor onion address, followed by the port number (usually `:9735`)

Just grab the whole URI above the big QR code and use it as follows (we will use the `⚡2FakTor⚡` node as an example):

* **Connect** to the remote node, with the full URI.

  ```sh
  $2 lncli connect 02b03a1d133c0338c0185e57f0c35c63cce53d5e3ae18414fc40e5b63ca08a2128@aopvxn7cf7kv42u5oxfo3mplhl5oerukndi3wos7vpsfvqvc7vvmgyqd.onion:9735
  ```

* **Open a channel** using the `<pubkey>` only (*i.e.*, the part of the URI before the `@`) and the channel capacity in satoshis.

  One Bitcoin equals 100 million satoshis, so at $10'000/BTC, $10 amount to 0.001 BTC or 100'000 satoshis.
  To avoid mistakes, you can just use an [online converter](https://www.buybitcoinworldwide.com/satoshi/to-usd/){:target="_blank"}.

  The command has a built-in fee estimator, but to avoid overpaying fees, you can manually control the fees for the funding transaction by using the `sat_per_vbyte` argument as follows (to select the appropriate fee, in sats/vB, check [mempool.space](https://mempool.space/){:target="_blank"})

  ```sh
  $2 lncli openchannel --sat_per_vbyte 8 02b03a1d133c0338c0185e57f0c35c63cce53d5e3ae18414fc40e5b63ca08a2128 100000 0
  ```

* **Check your funds**, both in the on-chain wallet and the channel balances.

  ```sh
  $2 lncli walletbalance
  $2 lncli channelbalance
  ```

* **List active channels**. Once the channel funding transaction has been mined and gained enough confirmations, your channel is fully operational.
  That can take an hour or more.

  ```sh
  $2 lncli listchannels
  ```

* **Make a Lightning payment**. By default, these work with invoices, so when you buy something or want to send money, you need to get an invoice first. However, you can also pay without requesting an invoice as long the receiving node supports the keysend or amp feature!

To try, why not send me satoshis! You simply need to input my node pukey [`⚡2FakTor⚡`](https://amboss.space/node/02b03a1d133c0338c0185e57f0c35c63cce53d5e3ae18414fc40e5b63ca08a2128){:target="_blank"}, the amount in satoshis and add the –keysend flag

  ```sh
  $2 lncli sendpayment --dest 02b03a1d133c0338c0185e57f0c35c63cce53d5e3ae18414fc40e5b63ca08a2128 --amt <amount in sats whatever you want> --keysend
  ```

### More commands

A quick reference with common commands to play around with:

* list all arguments for the CLI (command line interface)

  ```sh
  $2 lncli
  ```

* get help for a specific command

  ```sh
  $2 lncli help [COMMAND]
  ```

* Find out some general stats about your node:

  ```sh
  $2 lncli getinfo
  ```

* Check the peers you are currently connected to:

  ```sh
  $2 lncli listpeers
  ```

* Check the status of your pending channels:

  ```sh
  $2 lncli pendingchannels
  ```

* Check the status of your active channels:

  ```sh
  $2 lncli listchannels
  ```

* Before paying an invoice, you should decode it to check if the amount and other info are correct:

  ```sh
  $2 lncli decodepayreq [INVOICE]
  ```

* Pay an invoice:

  ```sh
  $2 lncli payinvoice [INVOICE]
  ```

* Pay an AMP invoice (both sender and receiver nodes have to have AMP enabled)

  ```sh
  $2 lncli payinvoice --amt <amount> <amp invoice>
  ```

* Send payment to a node without invoice using AMP (both sender and receiver nodes have to have AMP enabled):

  ```sh
  $2 lncli sendpayment --dest <destination public key> --amt <amount> --amp
  ```

* Send payment to a node without an invoice using Keysend (both sender and receiver nodes have to have Keysend enabled):

  ```sh
  $2 lncli sendpayment --dest <destination public key> --amt <amount> --keysend
  ```

* Check the payments that you sent:

  ```sh
  $2 lncli listpayments
  ```

* Create an invoice:

  ```sh
  $2 lncli addinvoice [AMOUNT_IN_SATOSHIS]
  ```

* Create a Re-Usable Static AMP invoice:

  ```sh
  $2 lncli addinvoice --memo "your memo here" --amt <amount in sats> --expiry <time in seconds> --amp
  ```

💡 Flags `--memo "your memo here" --amt <amount in sats> --expiry <time in seconds>` are optional. Default expiry time will be 30 days by default and the rest can be empty.

Copy the output [lnbc...] of the "payment_request": "lnbc...". Transform your output payment request into a QR code, embed it on your website or add it to your social media. LibreOffice has built-in functionality, and there are plenty of freely available online tools.

* List all invoices:

  ```sh
  $2 lncli listinvoices
  ```

* to close a channel, you need the following two arguments that can be determined with `listchannels` and are listed as "channelpoint": `FUNDING_TXID`:`OUTPUT_INDEX`

  ```sh
  $2 lncli listchannels
  $2 lncli closechannel --sat_per_vbyte <fee> [FUNDING_TXID] [OUTPUT_INDEX]
  ```

* to force close a channel (if your peer is offline or not cooperative), use `--force`

  ```sh
  $2 lncli closechannel --force [FUNDING_TXID] [OUTPUT_INDEX]
  ```

* to close all channels in cooperative mode

  ```sh
  $2 lncli closeallchannels --sat_per_byte <sat/byte>
  ````

🔍 _more: full [LND API reference](https://api.lightning.community/){:target="_blank"}

## For the future: upgrade LND

Upgrading LND can lead to a number of issues.
**Always** read the [LND release notes](https://github.com/lightningnetwork/lnd/releases){:target="_blank"} completely to understand the changes. These also cover a lot of additional topics and many new features not mentioned here.

* Login as "admin" and change to a temporary directory which is cleared on reboot

  ```sh
  $ cd /tmp
  ```

* Set a temporary version environment variable to the installation

  ```sh
  $ VERSION=v0.15.5
  ```

  ```sh
  $ wget https://github.com/lightningnetwork/lnd/releases/download/$VERSION-beta/lnd-linux-amd64-$VERSION-beta.tar.gz
  $ wget https://github.com/lightningnetwork/lnd/releases/download/$VERSION-beta/manifest-$VERSION-beta.txt
  $ wget https://github.com/lightningnetwork/lnd/releases/download/$VERSION-beta/manifest-roasbeef-$VERSION-beta.sig.ots
  $ wget https://github.com/lightningnetwork/lnd/releases/download/$VERSION-beta/manifest-roasbeef-$VERSION-beta.sig
  ```

* Verify the signed checksum against the actual checksum of your download

  ```sh
  $ sha256sum --check manifest-$VERSION-beta.txt --ignore-missing

Expected output:

  ```sh
  > lnd-linux-amd64-$VERSION-beta.tar.gz: OK
  ```

* Get the public key from the LND developer, [Olaoluwa Osuntokun](https://keybase.io/roasbeef){:target="_blank"}, who signed the manifest file; and add it to your GPG keyring

  ```sh
  $ curl https://raw.githubusercontent.com/lightningnetwork/lnd/master/scripts/keys/roasbeef.asc | gpg --import
  > ...
  > gpg: key 372CBD7633C61696: "Olaoluwa Osuntokun <laolu32@gmail.com>"
  > ...
  ```

* Verify the signature of the text file containing the checksums for the application

  ```sh
  $ gpg --verify manifest-roasbeef-$VERSION-beta.sig manifest-$VERSION-beta.txt
  ```

Expected output:

  ```sh
  > gpg: Signature made Thu Dec  1 19:20:10 2022 UTC
  > gpg:                using RSA key 60A1FA7DA5BFF08BDCBBE7903BBD59E99B280306
  > gpg: Good signature from "Olaoluwa Osuntokun <laolu32@gmail.com>" [unknown]
  > gpg: WARNING: This key is not certified with a trusted signature!
  > gpg:          There is no indication that the signature belongs to the owner.
  > Primary key fingerprint: E4D8 5299 674B 2D31 FAA1  892E 372C BD76 33C6 1696
  >      Subkey fingerprint: 60A1 FA7D A5BF F08B DCBB  E790 3BBD 59E9 9B28 0306
  ```

* Let's verify the timestamp of the file matches the release date

  ```sh
  $ ots --no-cache verify manifest-roasbeef-$VERSION-beta.sig.ots -f manifest-roasbeef-$VERSION-beta.sig
  ```

The following output is just an example of one of the versions

  ```sh
  > Got 1 attestation(s) from https://alice.btc.calendar.opentimestamps.org
  > Got 1 attestation(s) from https://btc.calendar.catallaxy.com
  > Got 1 attestation(s) from https://finney.calendar.eternitywall.com
  > Got 1 attestation(s) from https://bob.btc.calendar.opentimestamps.org
  > Success! Bitcoin block 765521 attests existence as of 2022-12-01 UTC
  ```

Check that the date of the timestamp (here 2022-12-01) is close to the [release date](https://github.com/lightningnetwork/lnd/releases){:target="_blank"} of the LND binary (2022-12-02).

* Having verified the integrity and authenticity of the release binary, we can safely proceed to install it

  ```sh
  $ tar -xzf lnd-linux-amd64-$VERSION-beta.tar.gz
  $ sudo install -m 0755 -o root -g root -t /usr/local/bin lnd-linux-amd64-$VERSION-beta/*
  $ lnd --version
  > lnd version $VERSION-beta commit=$VERSION-beta
  ```

* Restart the services to apply the version change

  ```sh
  $ sudo systemctl restart lnd
  ```

<br /><br />

---

Next: [Channel backup >>](channel-backup.md)
