---
title: Lightning client
nav_order: 10
parent: Lightning
---

# 3.1 Lightning client: LND

We set up [LND](https://github.com/lightningnetwork/lnd), the Lightning Network Daemon by [Lightning Labs](https://lightning.engineering/).

<div align="center">

<img src="../images/lightning-network-daemon-logo.png" alt="">

</div>

## Preparations

The installation of LND is straightforward, but the application is quite powerful and capable of things not explained here. Check out their [GitHub repository](https://github.com/lightningnetwork/lnd/) for a wealth of information about their open-source project and Lightning in general.

### **Configure Bitcoin Core**

Before running LND, we need to set up settings in the Bitcoin Core configuration file to enable the LND RPC connection.

*   Login as user "admin", edit the `bitcoin.conf` file, and add the following lines. Save and exit

    ```sh
    $ sudo nano /data/bitcoin/bitcoin.conf
    ```

    ```
    # LND RPC connection
    zmqpubrawblock=tcp://127.0.0.1:28332
    zmqpubrawtx=tcp://127.0.0.1:28333
    ```
*   Restart Bitcoin Core to apply changes

    ```sh
    $ sudo systemctl restart bitcoind
    ```

## Installation

### **Download**

We'll download, verify and install LND.

*   Navigate to the temporary directory which is cleared on reboot

    ```sh
    $ cd /tmp
    ```
*   Set a temporary version environment variable to the installation

    ```sh
    $ VERSION=0.16.3
    ```
*   Download the application, checksums and signature

    {% code overflow="wrap" %}
    ```sh
    $ wget https://github.com/lightningnetwork/lnd/releases/download/v$VERSION-beta/lnd-linux-amd64-v$VERSION-beta.tar.gz
    ```
    {% endcode %}

    {% code overflow="wrap" %}
    ```sh
    $ wget https://github.com/lightningnetwork/lnd/releases/download/v$VERSION-beta/manifest-v$VERSION-beta.txt
    ```
    {% endcode %}

    {% code overflow="wrap" %}
    ```sh
    $ wget https://github.com/lightningnetwork/lnd/releases/download/v$VERSION-beta/manifest-roasbeef-v$VERSION-beta.sig.ots
    ```
    {% endcode %}

    {% code overflow="wrap" %}
    ```sh
    $ wget https://github.com/lightningnetwork/lnd/releases/download/v$VERSION-beta/manifest-roasbeef-v$VERSION-beta.sig
    ```
    {% endcode %}

### **Checksum check**

*   Verify the signed checksum against the actual checksum of your download

    ```sh
    $ sha256sum --check manifest-v$VERSION-beta.txt --ignore-missing
    ```

**Example** of expected output:

```
> lnd-linux-amd64-v0.16.3-beta.tar.gz: OK
```

### **Signature check**

Now that we've verified the integrity of the downloaded binary, we need to check the authenticity of the manifest file we just used, starting with its signature.

*   Get the public key from the LND developer, [Olaoluwa Osuntokun](https://keybase.io/roasbeef), who signed the manifest file; and add it to your GPG keyring

    {% code overflow="wrap" %}
    ```sh
    $ curl https://raw.githubusercontent.com/lightningnetwork/lnd/master/scripts/keys/roasbeef.asc | gpg --import
    ```
    {% endcode %}

**Example** of expected output:

{% code fullWidth="false" %}
```
> [...]
> gpg: key 372CBD7633C61696: public key "Olaoluwa Osuntokun <laolu32@gmail.com>" imported
> [...]
```
{% endcode %}

*   Verify the signature of the text file containing the checksums for the application

    ```sh
    $ gpg --verify manifest-roasbeef-v$VERSION-beta.sig manifest-v$VERSION-beta.txt
    ```

Expected output:

```
[...]
> gpg: Signature made Thu Dec  1 19:20:10 2022 UTC
> gpg:                using RSA key 60A1FA7DA5BFF08BDCBBE7903BBD59E99B280306
> gpg: Good signature from "Olaoluwa Osuntokun <laolu32@gmail.com>" [unknown]
> gpg: WARNING: This key is not certified with a trusted signature!
[...]
```

### **Timestamp check**

We can also check that the manifest file was in existence around the time of the release using its timestamp.

*   Let's verify the timestamp of the file matches the release date

    {% code overflow="wrap" %}
    ```sh
    $ ots --no-cache verify manifest-roasbeef-v$VERSION-beta.sig.ots -f manifest-roasbeef-v$VERSION-beta.sig
    ```
    {% endcode %}

**Example** of expected output:

```
> Got 1 attestation(s) from https://alice.btc.calendar.opentimestamps.org
> Got 1 attestation(s) from https://btc.calendar.catallaxy.com
> Got 1 attestation(s) from https://finney.calendar.eternitywall.com
> Got 1 attestation(s) from https://bob.btc.calendar.opentimestamps.org
> Success! Bitcoin block 765521 attests existence as of 2022-12-01 UTC
```

{% hint style="info" %}
Check that the date of the timestamp is close to the [release date](https://github.com/lightningnetwork/lnd/releases) of the LND binary.
{% endhint %}

### **Installation**

Having verified the integrity and authenticity of the release binary, we can safely proceed to install it

```sh
$ tar -xvf lnd-linux-amd64-v$VERSION-beta.tar.gz
```

{% code overflow="wrap" %}
```sh
$ sudo install -m 0755 -o root -g root -t /usr/local/bin lnd-linux-amd64-v$VERSION-beta/*
```
{% endcode %}

```sh
$ lnd --version
```

**Example** of expected output:

```
> lnd version 0.16.3-beta commit=v$VERSION-beta
```

{% hint style="info" %}
If you come to update this is the final step
{% endhint %}

### **Data directory**

Now that LND is installed, we need to configure it to work with Bitcoin Core and run automatically on startup.

*   Create the **"lnd"** service user, and add it to the groups "bitcoin" and "debian-tor"

    ```sh
    $ sudo adduser --disabled-password --gecos "" lnd
    ```

    ```sh
    $ sudo usermod -a -G bitcoin,debian-tor lnd
    ```
*   Add the user "admin" to the group "lnd"

    ```sh
    $ sudo adduser admin lnd
    ```
*   Create the LND data directory

    ```sh
    $ sudo mkdir /data/lnd
    ```

    ```sh
    $ sudo chown -R lnd:lnd /data/lnd
    ```
*   Open a "lnd" user session

    ```sh
    $ sudo su - lnd
    ```
*   Create symbolic links pointing to the LND and bitcoin data directories

    ```sh
    $ ln -s /data/lnd /home/lnd/.lnd
    ```

    ```sh
    $ ln -s /data/bitcoin /home/lnd/.bitcoin
    ```

### **Wallet password**

LND includes a Bitcoin wallet that manages your on-chain and Lightning coins. It is password protected and must be unlocked when LND starts. This creates the dilemma that you either manually unlock LND after each restart of your PC, or you store the password somewhere on the node.

For this initial setup, we choose the easy route: we store the password in a file that allows LND to unlock the wallet automatically. This is not the most secure setup, but you can improve it later if you want, with the bonus guides linked below. To give some perspective: other Lightning implementations like c-lightning or Eclair don't even have a password.

*   Still as user **"lnd"**, create a text file and enter your LND wallet `password [C]`. Save and exit.

    ```sh
    $ nano /data/lnd/password.txt
    ```
*   Tighten access privileges and make the file readable only for user "lnd"

    ```sh
    $ chmod 600 /data/lnd/password.txt
    ```

## Configuration

### **Configure LND**

*   Create the LND configuration file and paste the following content _**(adjust to your alias `"<YOUR_FANCY_ALIAS>"`, your preferred color `"<#ff9900>"`, your minimum channel size `"minchansize"` and fees)**_. Save and exit.

    ```sh
    $ nano /data/lnd/lnd.conf
    ```

    ```
    # MiniBolt: lnd configuration
    # /data/lnd/lnd.conf

    [Application Options]
    # Up to 32 UTF-8 characters, accepts emojis i.e ⚡🧡​ https://emojikeyboard.top/
    alias=<YOUR_FANCY_ALIAS>
    # You can choose the color you want at https://www.color-hex.com/
    color=#ff9900
    listen=localhost
    nat=false
    debuglevel=info

    # Password: automatically unlock wallet with the password in this file
    # -- comment out to manually unlock wallet, and see MiniBolt guide for 
    # more secure options
    wallet-unlock-password-file=/data/lnd/password.txt
    wallet-unlock-allow-create=true

    # Automatically regenerate certificate when near expiration
    tlsautorefresh=true
    # Do not include the interface IPs or the system hostname in TLS certificate.
    tlsdisableautofill=true

    # Channel settings
    # Fee settings - default LND base fee = 1000 (mSat), 
    # default LND fee rate = 1 (ppm)
    # You can choose whatever you want e.g ZeroFeeRouting (0,0)
    #bitcoin.basefee=0
    #bitcoin.feerate=0

    # Minimum channel size (in satoshis, default and minimun 
    # from source code is 20,000 sats). You can choose whatever you want
    #minchansize=20000
    maxpendingchannels=5
    accept-keysend=true
    accept-amp=true
    protocol.wumbo-channels=true
    coop-close-target-confs=24

    # Watchtower client
    wtclient.active=true
    # Specify the fee rate with which justice transactions will be signed. 
    # The default is 10 sat/byte.
    #wtclient.sweep-fee-rate=10

    # Watchtower server
    watchtower.active=true

    # Performance
    gc-canceled-invoices-on-startup=true
    gc-canceled-invoices-on-the-fly=true
    ignore-historical-gossip-filters=true
    stagger-initial-reconnect=true

    # Database
    [bolt]
    # Set the next value to false to disable auto-compact DB 
    # and fast boot and comment the next line
    db.bolt.auto-compact=true
    # Uncomment to do DB compact at every LND reboot (default: 168h)
    #db.bolt.auto-compact-min-age=0h

    [Bitcoind]
    bitcoind.estimatemode=ECONOMICAL

    [Bitcoin]
    bitcoin.active=true
    bitcoin.mainnet=true
    bitcoin.node=bitcoind

    [tor]
    tor.active=true
    tor.v3=true
    tor.streamisolation=true
    ```

{% hint style="info" %}
This is a standard configuration. Check the official LND [sample-lnd.conf](https://github.com/lightningnetwork/lnd/blob/master/sample-lnd.conf) with all possible options
{% endhint %}

*   Exit of the "lnd" user session to return to the **"admin"** user session

    ```sh
    $ exit
    ```

### **Autostart on boot**

Now, let's set up LND to start automatically on system startup.

*   As user `admin`, create LND systemd unit with the following content. Save and exit.

    ```sh
    $ sudo nano /etc/systemd/system/lnd.service
    ```

    ```
    # MiniBolt: systemd unit for lnd
    # /etc/systemd/system/lnd.service

    [Unit]
    Description=LND Lightning Network Daemon
    After=bitcoind.service

    [Service]
    ExecStart=/usr/local/bin/lnd
    ExecStop=/usr/local/bin/lncli stop
    Type=simple
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
*   Enable autoboot

    ```sh
    $ sudo systemctl enable lnd
    ```
*   Now, the daemon information is no longer displayed on the command line but is written into the system journal. You can check on it using the following command. You can exit monitoring at any time with `Ctrl-C`

    ```sh
    $ sudo journalctl -f -u lnd
    ```

## Run LND

To keep an eye on the software movements, [start your SSH program](../system/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as "admin". Commands for the **second session** start with the prompt `$2` (which must not be entered).

* Start LND

```sh
$2 sudo systemctl start lnd
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>$ sudo journalctl -f -u lnd</code> ⬇️</summary>

```
> Dec 02 09:23:37 minibolt systemd[1]: Started LND Lightning Network Daemon.
> Dec 02 09:23:37 minibolt lnd[2584156]: Attempting automatic RPC configuration to bitcoind
> Dec 02 09:23:37 minibolt lnd[2584156]: Automatically obtained bitcoind's RPC credentials
> Dec 02 09:23:37 minibolt lnd[2584156]: 2022-12-02 09:23:37.974 [INF] LTND: Version: $VERSION-beta commit=$VERSION-beta, build=production, logging=default, debuglevel=info
> Dec 02 09:23:37 minibolt lnd[2584156]: 2022-12-02 09:23:37.974 [INF] LTND: Active chain: Bitcoin (network=mainnet)
> Dec 02 09:23:37 minibolt lnd[2584156]: 2022-12-02 09:23:37.975 [INF] RPCS: RPC server listening on 127.0.0.1:10009
> Dec 02 09:23:37 minibolt lnd[2584156]: 2022-12-02 09:23:37.976 [INF] RPCS: gRPC proxy started at 0.0.0.0:8080
> Dec 02 09:23:37 minibolt lnd[2584156]: 2022-12-02 09:23:37.976 [INF] LTND: Opening the main database, this might take a few minutes...
> Dec 02 09:23:37 minibolt lnd[2584156]: 2022-12-02 09:23:37.976 [INF] LTND: Opening bbolt database, sync_freelist=false, auto_compact=true
[...]
```

</details>

### **Wallet setup**

Once LND is started, the process waits for us to create the integrated Bitcoin onchain wallet.

*   Change to the "lnd" user

    ```sh
    $2 sudo su - lnd
    ```
*   Create the LND wallet

    ```sh
    $2 lncli create
    ```
*   Enter your `password [C]` as wallet password (it must be exactly the same one you stored in `password.txt`). To create a new wallet, select `n` when asked if you have an existing cipher seed. Just press enter if asked about an additional seed passphrase unless you know what you're doing. A new cipher seed consisting of 24 words is created.

    {% code fullWidth="false" %}
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
    {% endcode %}

These 24 words are all that you need to restore the Bitcoin on-chain wallet.

* **Write these 24 words down manually on a piece of paper and store it in a safe place**

You can use a simple piece of paper, write them on the custom themed [Shiftcrypto backup card](https://shiftcrypto.ch/backupcard/backupcard\_print.pdf), or even [stamp the seed words into metal](../bonus/bitcoin/safu-ninja.md).

{% hint style="danger" %}
This piece of paper is all an attacker needs to completely empty your on-chain wallet! 🚫 Do not store it on a computer. 🚫 Do not take a picture with your mobile phone. 🚫 **This information should never be stored anywhere in digital form**
{% endhint %}

The current state of your channels, however, cannot be recreated from this seed. For this, the Static Channel Backup stored `/data/lnd/data/chain/bitcoin/mainnet/channel.backup` is updated for each channel opening and closing. Exist a dedicated [guide](channel-backup.md) to automatic backup.

{% hint style="danger" %}
This information must be kept secret at all times.
{% endhint %}

### **Allow user "admin" to work with LND**

We interact with LND using the application `lncli`. At the moment, only the user "lnd" has the necessary access privileges. To make the user "admin" the main administrative user, we make sure it can interact with LND as well.

*   Type "exit" to return to the admin user

    ```sh
    $2 exit
    ```
*   As user "admin", link the LND data directory in the user "admin" home. As a member of the group "lnd", the "admin" user has read-only access to certain files. We also need to make all directories browsable for the group (with `g+X`) and allow it to read the file `admin.macaroon`

    ```sh
    $2 ln -s /data/lnd /home/admin/.lnd
    ```

    ```sh
    $2 sudo chmod -R g+X /data/lnd/data/
    ```

    {% code overflow="wrap" %}
    ```sh
    $2 sudo chmod g+r /data/lnd/data/chain/bitcoin/mainnet/admin.macaroon
    ```
    {% endcode %}
*   Newly added links and permissions become active only in a new user session. Log out from SSH.

    ```sh
    $2 exit
    ```
* Log in as user **“admin”** again `"ssh admin@minibolt.local"`
*   Check if you can use `lncli` by querying LND for information

    ```sh
    $2 lncli getinfo
    ```

## LND in action

💊 Now your Lightning node is ready. This is also the point of no return. Up until now, you can just start over. Once you send real bitcoin to your MiniBolt, you have "skin in the game"

{% hint style="info" %}
The next commands can be entered in any new session without keeping a specific terminal opened with logs, but I recommend keeping to do this just in case any log could give extra information about the command you just entered.
{% endhint %}

### **Watchtower client (recommended)**

Lightning channels need to be monitored to prevent malicious behavior by your channel peers. If your MiniBolt goes down for a longer period of time, for instance, due to a hardware problem, a node on the other side of one of your channels might try to close the channel with an earlier channel balance that is better for them.

Watchtowers are other Lightning nodes that can monitor your channels for you. If they detect such bad behavior, they can react on your behalf, and send a punishing transaction to close this channel. In this case, all channel funds will be sent to your LND on-chain wallet.

A watchtower can only send such a punishing transaction to your wallet, so you don't have to trust them. It's good practice to add a few watchtowers, just to be on the safe side.

*   With user `"admin"`, add the [Lightning Network+ watchtower](https://lightningnetwork.plus/watchtower) Tor address as a first example

    {% code overflow="wrap" %}
    ```sh
    $ lncli wtclient add 023bad37e5795654cecc69b43599da8bd5789ac633c098253f60494bde602b60bf@iiu4epqzm6cydqhezueenccjlyzrqeruntlzbx47mlmdgfwgtrll66qd.onion:9911
    ```
    {% endcode %}
*   Or the clearnet address

    {% code overflow="wrap" %}
    ```sh
    $ lncli wtclient add 023bad37e5795654cecc69b43599da8bd5789ac633c098253f60494bde602b60bf@34.216.52.158:9911
    ```
    {% endcode %}
*   If you want to list your towers and active watchtowers

    ```sh
    $ lncli wtclient towers
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

*   If you want to deactivate an active tower

    ```sh
    $ lncli wtclient remove <pubkey>
    ```

### **Watchtower server (optional)**

Same as you can connect as a watchtower client to other watchtower servers, you could give the same service running an altruist watchtower server. This was previously activated in `lnd.conf`, and you can see the information about it by typing the following command and sharing it with your peers.

```sh
$ lncli tower info
```

Expected output:

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

{% hint style="info" %}
This watchtower server service is not recommended to activate if you have a slow device without high-performance features, if yes considered to disable it.
{% endhint %}

> Note
>
> Almost all of the following steps could be run with the [mobile](mobile-app.md)/[web](web-app.md) app guides. We strongly recommend using these applications with intuitive and visual UI to manage the Lightning Node, instead of using the command line.

### **Funding your Lightning node**

*   Generate a new Bitcoin address (p2tr = taproot/bech32m) to receive funds on-chain and send a small amount of Bitcoin to it from any wallet of your choice.

    ```sh
    $ lncli newaddress p2tr
    ```

Expected output:

```
> "address": "bc1p..."
```

*   Check your LND wallet balance. (The output is only an example)

    ```sh
    $ lncli walletbalance
    ```

Expected output:

```
{
    "total_balance": "712345",
    "confirmed_balance": "0",
    "unconfirmed_balance": "712345"
}
```

As soon as your funding transaction is mined (1 confirmation), LND will show its amount as "confirmed\_balance".

{% hint style="info" %}
If you want to open a few channels, you might want to send a few transactions. If you have only one UTXO, you need to wait for the change to return to your wallet after every new channel opening.
{% endhint %}

### **Opening channels**

Although LND features an optional "autopilot", we manually open some channels.

We recommend going on [amboss.space](https://amboss.space) or [1ML.com](https://1ml.com) and looking for a mix of big and small nodes with decent Node Ranks. Another great way to find peers to collaboratively set up channels is [LightningNetwork+](https://lightningnetwork.plus/).

To connect to a remote node, you need its URI that looks like `<pubkey>@host`:

* the `<pubkey>` is just a long hexadecimal number, like `02b03a1d133c0338c0185e57f0c35c63cce53d5e3ae18414fc40e5b63ca08a2128`
* the `host` can be a domain name, a clearnet IP address, or a Tor onion address, followed by the port number (usually `:9735`)

Just grab the whole URI above the big QR code and use it as follows (we will use the `⚡2FakTor⚡` node as an example):

*   **Connect** to the remote node, with the full URI.

    {% code overflow="wrap" %}
    ```sh
    $ lncli connect 02b03a1d133c0338c0185e57f0c35c63cce53d5e3ae18414fc40e5b63ca08a2128@aopvxn7cf7kv42u5oxfo3mplhl5oerukndi3wos7vpsfvqvc7vvmgyqd.onion:9735
    ```
    {% endcode %}
*   **Open a channel** using the `<pubkey>` only (_i.e._, the part of the URI before the `@`) and the channel capacity in satoshis.

    One Bitcoin equals 100 million satoshis, so at $10'000/BTC, $10 amount to 0.001 BTC or 100'000 satoshis. To avoid mistakes, you can just use an [online converter](https://www.buybitcoinworldwide.com/satoshi/to-usd/).

    The command has a built-in fee estimator, but to avoid overpaying fees, you can manually control the fees for the funding transaction by using the `sat_per_vbyte` argument as follows (to select the appropriate fee, in sats/vB, check [mempool.space](https://mempool.space/))

    {% code overflow="wrap" %}
    ```sh
    $ lncli openchannel --sat_per_vbyte 8 02b03a1d133c0338c0185e57f0c35c63cce53d5e3ae18414fc40e5b63ca08a2128 100000 0
    ```
    {% endcode %}
*   **Check your funds**, both in the on-chain wallet and the channel balances.

    ```sh
    $ lncli walletbalance
    ```

    ```sh
    $ lncli channelbalance
    ```
*   **List active channels**. Once the channel funding transaction has been mined and gained enough confirmations, your channel is fully operational. That can take an hour or more.

    ```sh
    $ lncli listchannels
    ```
* **Make a Lightning payment**. By default, these work with invoices, so when you buy something or want to send money, you need to get an invoice first. However, you can also pay without requesting an invoice as long the receiving node supports the keysend or amp feature!

To try, why not send me satoshis! You simply need to input my node pubkey [`⚡2FakTor`](https://amboss.space/node/02b03a1d133c0338c0185e57f0c35c63cce53d5e3ae18414fc40e5b63ca08a2128), the amount in satoshis and add the "–keysend" flag

{% code overflow="wrap" %}
```sh
$ lncli sendpayment --dest 02b03a1d133c0338c0185e57f0c35c63cce53d5e3ae18414fc40e5b63ca08a2128 --amt <amount in sats whatever you want> --keysend
```
{% endcode %}

### **Some useful commands**

A quick reference with special commands to play around with:

*   Pay an AMP invoice (both sender and receiver nodes have to have AMP enabled)

    ```sh
    $ lncli payinvoice --amt <amount> <amp invoice>
    ```
*   Send payment to node without invoice using AMP invoice (both sender and receiver nodes have to have AMP enabled)

    ```sh
    $ lncli sendpayment --dest <destination public key> --amt <amount> --amp
    ```
*   Send payment to a node without an invoice using Keysend (both sender and receiver nodes have to have Keysend enabled)

    ```sh
    $ lncli sendpayment --dest <destination public key> --amt <amount> --keysend
    ```
*   Create your own Re-Usable Static AMP invoice

    {% code overflow="wrap" %}
    ```sh
    $ lncli addinvoice --memo "your memo here" --amt <amount in sats> --expiry <time in seconds> --amp
    ```
    {% endcode %}

{% hint style="info" %}
The default flags "--memo" "--amt" and "--expiry" are optional. The default expiry time will be 30 days by default and the rest can be empty
{% endhint %}

Copy the output \[lnbc...] of the "payment\_request": "lnbc...". Transform your output payment request into a QR code, embed it on your website, or add it to your social media. LibreOffice has built-in functionality, and there are plenty of freely available online tools.

*   List all invoices:

    ```sh
    $ lncli listinvoices
    ```
*   Close all channels in cooperative mode

    ```sh
    $ lncli closeallchannels --sat_per_byte <sat/byte>
    ```

{% hint style="info" %}
&#x20;More: full [LND API reference](https://api.lightning.community/)
{% endhint %}

## For the future: upgrade LND

Upgrading LND can lead to a number of issues. **Always** read the [LND release notes](https://github.com/lightningnetwork/lnd/releases) completely to understand the changes. These also cover a lot of additional topics and many new features not mentioned here.

*   Check your actual LND version

    ```sh
    $ lnd --version
    ```
* Download, verify, and install the latest LND binaries as described in the [LND section](lightning-client.md#installation) of this guide, replacing the environment variable `"VERSION=x.xx"` value for the latest if it has not been already changed in this guide.
*   Restart LND to apply the new version

    ```sh
    $ sudo systemctl restart lnd
    ```
