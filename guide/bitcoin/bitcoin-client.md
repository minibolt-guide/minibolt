---
layout: default
title: Bitcoin client
nav_order: 10
parent: Bitcoin
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->

# Bitcoin client: Bitcoin Core

{: .no_toc }

---

We install [Bitcoin Core](https://bitcoin.org/en/bitcoin-core/){:target="_blank"}, the reference client implementation of the Bitcoin network.

![Bitcoin Core logo](../../images/bitcoin-core-logo-trans.png)

---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## This may take some time

Bitcoin Core will download the full Bitcoin blockchain, and validate all transactions since 2009.
We're talking more than 700'000 blocks with a size of over 465 GB, so this is not an easy task.

---

## Installation

We download the latest Bitcoin Core binary (the application) and compare this file with the signed and timestamped checksum.
This is a precaution to make sure that this is an official release and not a malicious version trying to steal our money.

💡 If you want to install Ordisrespector patch to reject Ordinals of your mempool, follow [Ordisrespector bonus guide](../bonus/bitcoin/ordisrespector.md#preparations) and come back to continue with the ["Create the bitcoin user"](#create-the-bitcoin-user) section.

💡 If you want to install Bitcoin Core from source code but without Ordisrespector patch, follow [Ordisrespector bonus guide](../bonus/bitcoin/ordisrespector.md#preparations) skipping [Apply the patch “Ordisrespector”](../bonus/bitcoin/ordisrespector.md#apply-the-patch-ordisrespector) and come back to continue with the ["Create the bitcoin user"](#create-the-bitcoin-user) section.

### **Preparations**

* Login as "admin" and change to a temporary directory which is cleared on reboot

  ```sh
  $ cd /tmp
  ```

* Set a temporary version environment variable to the installation

  ```sh
  $ VERSION=25.0
  ```

* Get the latest binaries and signatures

  ```sh
  $ wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/bitcoin-$VERSION-x86_64-linux-gnu.tar.gz
  ```

  ```sh
  $ wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS
  ```

  ```sh
  $ wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS.asc
  ```

### **Checksum check**

* Check that the reference checksum in file `SHA256SUMS` matches the checksum calculated by you (ignore the "lines are improperly formatted" warning)

  ```sh
  $ sha256sum --ignore-missing --check SHA256SUMS
  ```

Expected output:

  ```
  > bitcoin-$VERSION-x86_64-linux-gnu.tar.gz: OK
  ```

### **Signature check**

Bitcoin releases are signed by several individuals, each using its own key. To verify the validity of these signatures, you must first import the corresponding public keys into your GPG key database.

* The next command download and imports automatically all signatures from the [Bitcoin Core release attestations (Guix)](https://github.com/bitcoin-core/guix.sigs) repository

  ```sh
  $ curl -s "https://api.github.com/repositories/355107265/contents/builder-keys" | grep download_url | grep -oE "https://[a-zA-Z0-9./-]+" | while read url; do curl -s "$url" | gpg --import; done
  ```

Expected output:

  ```
  > gpg: key 17565732E08E5E41: 29 signatures not checked due to missing keys
  > gpg: /home/admin/.gnupg/trustdb.gpg: trustdb created
  > gpg: key 17565732E08E5E41: public key "Andrew Chow <andrew@achow101.com>" imported
  > gpg: Total number processed: 1
  > gpg:               imported: 1
  > gpg: no ultimately trusted keys found
  [...]
  ```

* Verify that the checksums file is cryptographically signed by the release signing keys.
  The following command prints signature checks for each of the public keys that signed the checksums.

  ```sh
  $ gpg --verify SHA256SUMS.asc
  ```

* Check that at least a few signatures show the following text

  ```
  > gpg: Good signature from ...
  > Primary key fingerprint: ...
  ```

### **Timestamp check**

* The binary checksum file is also timestamped with the Bitcoin blockchain using the [OpenTimestamps protocol](https://opentimestamps.org/){:target="_blank"}, proving that the file existed before some point in time. Let's verify this timestamp. On your local computer, download the checksums file and its timestamp proof:

  * [https://bitcoincore.org/bin/bitcoin-core-24.0.1/SHA256SUMS.ots](https://bitcoincore.org/bin/bitcoin-core-24.0.1/SHA256SUMS.ots)
  * [https://bitcoincore.org/bin/bitcoin-core-24.0.1/SHA256SUMS](https://bitcoincore.org/bin/bitcoin-core-24.0.1/SHA256SUMS)

* In your browser, open the [OpenTimestamps website](https://opentimestamps.org/){:target="_blank"}
* In the "Stamp and verify" section, drop or upload the downloaded SHA256SUMS.ots proof file in the dotted box
* In the next box, drop or upload the SHA256SUMS file
* If the timestamps are verified, you should see the following message. The timestamp proves that the checksums file existed on the [release date](https://github.com/bitcoin/bitcoin/releases/tag/v24.0.1){:target="_blank"} of Bitcoin Core v24.0.1.

The following screenshot is just an example of one of the versions:

![Bitcoin timestamp check](../../images/bitcoin-ots-check.PNG)

### **Binaries installation**

* If you're satisfied with the checksum, signature and timestamp checks, extract the Bitcoin Core binaries

  ```sh
  $ tar -xvf bitcoin-$VERSION-x86_64-linux-gnu.tar.gz
  ```

* Install the binaries on the OS

  ```sh
  $ sudo install -m 0755 -o root -g root -t /usr/local/bin bitcoin-$VERSION/bin/*
  ```

* Check the correct installation requesting the output of the version

  ```sh
  $ bitcoind --version
  ```

The following output is just an **example** of one of the versions:

  ```
  > Bitcoin Core version v24.1.0
  > Copyright (C) 2009-2022 The Bitcoin Core developers
  > [...]
  ```

💡 Now, if you want to install manual page for bitcoin-cli, follow the [manual page for bitcoin-cli](#manual-page-for-bitcoin-cli) extra section and then come back to continue with the [next section](#create-the-bitcoin-user)

### **Create the bitcoin user**

The Bitcoin Core application will run in the background as a daemon and use the separate user “bitcoin” for security reasons.
This user does not have admin rights and cannot change the system configuration.

* Create the user bitcoin

  ```sh
  $ sudo adduser --gecos "" --disabled-password bitcoin
  ```

* Add the user **"admin"** to the group "bitcoin" as well

  ```sh
  $ sudo adduser admin bitcoin
  ```

* Allow the user "bitcoin" to configure Tor directly by adding it to the "debian-tor" group

  ```sh
  $ sudo adduser bitcoin debian-tor
  ```

### **Create data folder**

Bitcoin Core uses by default the folder `.bitcoin` in the user's home.
Instead of creating this directory, we create a data directory in the general data location `/data` and link to it.

* Create the Bitcoin data folder

  ```sh
  $ mkdir /data/bitcoin
  ```

  ```sh
  $ sudo chown bitcoin:bitcoin /data/bitcoin
  ```

* Switch to the user "bitcoin"

  ```sh
  $ sudo su - bitcoin
  ```

* Create the symbolic link `.bitcoin` that points to that directory

  ```sh
  $ ln -s /data/bitcoin /home/bitcoin/.bitcoin
  ```

### **Generate access credentials**

For other programs to query Bitcoin Core they need the proper access credentials.
To avoid storing the username and password in a configuration file in plaintext, the password is hashed.
This allows Bitcoin Core to accept a password, hash it and compare it to the stored hash, while it is not possible to retrieve the original password.

Another option to get access credentials is through the `.cookie` file in the Bitcoin data directory.
This is created automatically and can be read by all users that are members of the "bitcoin" group.

Bitcoin Core provides a simple Python program to generate the configuration line for the config file.

* In the Bitcoin folder, download the RPCAuth program

  ```sh
  $ cd .bitcoin
  ```

  ```sh
  $ wget https://raw.githubusercontent.com/bitcoin/bitcoin/master/share/rpcauth/rpcauth.py
  ```

* Run the script with the Python3 interpreter, providing username (`minibolt`) and your `"password [B]"` as arguments.

  🚨 All commands entered are stored in the bash history.
  But we don't want the password to be stored where anyone can find it.
  For this, put a space (` `) in front of the command shown below.

  ```sh
  $  python3 rpcauth.py minibolt YourPasswordB
  ```

Expected **example** output:

  ```
  > String to be appended to bitcoin.conf:
  > rpcauth=minibolt:00d8682ce66c9ef3dd9d0c0a6516b10e$c31da4929b3d0e092ba1b2755834889f888445923ac8fd69d8eb73efe0699afa
  ```

* Copy the `rpcauth` line, we'll need to paste it into the Bitcoin config file.

### **Configuration**

Now, the configuration file for `bitcoind` needs to be created.
We'll also set the proper access permissions.

* Still as user `"bitcoin"`, open it with Nano and paste the configuration below.
  Replace the whole line starting with `"rpcauth=..."` with the connection string you just generated.
  Save and exit.

  ```sh
  $ nano /home/bitcoin/.bitcoin/bitcoin.conf
  ```

  ```
  # MiniBolt: bitcoind configuration
  # /home/bitcoin/.bitcoin/bitcoin.conf

  ## Bitcoin daemon
  server=1
  txindex=1

  # Aditional logs
  debug=tor
  debug=i2p

  # Assign read permission to the Bitcoin group users
  startupnotify=chmod g+r /home/bitcoin/.bitcoin/.cookie

  # Disable debug.log
  nodebuglogfile=1

  # Avoid assuming that a block and its ancestors are valid,
  # and potentially skipping their script verification.
  # We will set it to 0, to verify all.
  # Remember to comment after IBD!
  assumevalid=0

  # Enable all compact filters
  blockfilterindex=1
  # Support filtering of blocks and transactions with bloom filters
  peerbloomfilters=1
  # Serve compact block filters to peers per BIP 157
  peerblockfilters=1
  # Maintain coinstats index used by the gettxoutsetinfo RPC
  coinstatsindex=1

  # Network
  listen=1

  # Connect through Tor SOCKS5 proxy
  proxy=127.0.0.1:9050

  # I2P SAM proxy to reach I2P peers and accept I2P connections
  i2psam=127.0.0.1:7656

  ## Connections
  rpcauth=<replace with your own auth line generated by rpcauth.py in the previous step>

  # Initial block download optimizations (set dbcache size in megabytes (4 to 16384, default: 300) according with your available RAM of your device,
  # recommended: dbcache=1/2 x RAM available e.g: 4GB RAM -> dbcache=2048).
  # Remember to comment after IBD!
  dbcache=2048
  blocksonly=1
  ```

🔍 This is a standard configuration. Check this Bitcoin Core [sample-bitcoind.conf](https://gist.github.com/1ma/65751ba7f148612dfb39ff3527486a92){:target="_blank"} with all possible options

* Set permissions: only the user 'bitcoin' and members of the 'bitcoin' group can read it

  ```sh
  $ chmod 640 /home/bitcoin/.bitcoin/bitcoin.conf
  ```

* Exit the “bitcoin” user session back to user “admin”

  ```sh
  $ exit
  ```

### **Autostart on boot**

The system needs to run the bitcoin daemon automatically in the background, even when nobody is logged in.
We use `"systemd"`, a daemon that controls the startup process using configuration files.

* Create the configuration file in the nano text editor and copy the following paragraph.
  Save and exit.

  ```
  $ sudo nano /etc/systemd/system/bitcoind.service
  ```

  ```
  # MiniBolt: systemd unit for bitcoind
  # /etc/systemd/system/bitcoind.service

  [Unit]
  Description=Bitcoin daemon
  After=network.target

  [Service]
  ExecStart=/usr/local/bin/bitcoind -pid=/run/bitcoind/bitcoind.pid \
                                    -conf=/home/bitcoin/.bitcoin/bitcoin.conf \
                                    -datadir=/home/bitcoin/.bitcoin
  Type=exec
  PIDFile=/run/bitcoind/bitcoind.pid
  TimeoutSec=3600
  User=bitcoin
  UMask=0027
  RuntimeDirectory=bitcoind
  RuntimeDirectoryMode=0710
  PrivateTmp=true
  ProtectSystem=full
  NoNewPrivileges=true
  PrivateDevices=true
  MemoryDenyWriteExecute=true

  [Install]
  WantedBy=multi-user.target
  ```

* Enable autoboot

  ```sh
  $ sudo systemctl enable bitcoind
  ```

* Prepare “bitcoind” monitoring by the systemd journal and check the logging output. You can exit monitoring at any time with Ctrl-C

  ```sh
  $ sudo journalctl -f -u bitcoind
  ```

💡 Keep **this terminal open,** you'll need to come back here on the next step to monitor logs.

## Running bitcoind

To keep an eye on the software movements, [Start your SSH program](../system/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node and log in as "admin".
Commands for the **second session** start with the prompt `$2` (which must not be entered).

* Start the service

  ```sh
  $2 sudo systemctl start bitcoind
  ```

**Example** of expected output on the first terminal with `$ sudo journalctl -f -u bitcoind`:

  ```
  > 2022-11-24T18:08:04Z Bitcoin Core version v24.0.1.0 (release build)
  > 2022-11-24T18:08:04Z InitParameterInteraction: parameter interaction: -proxy set -> setting -upnp=0
  > 2022-11-24T18:08:04Z InitParameterInteraction: parameter interaction: -proxy set -> setting -natpmp=0
  > 2022-11-24T18:08:04Z InitParameterInteraction: parameter interaction: -proxy set -> setting -discover=0
  > 2022-11-24T18:08:04Z Using the 'sse4(1way),sse41(4way),avx2(8way)' SHA256 implementation
  > 2022-11-24T18:08:04Z Using RdRand as an additional entropy source
  > 2022-11-24T18:08:04Z Default data directory /home/bitcoin/.bitcoin
  > 2022-11-24T18:08:04Z Using data directory /home/bitcoin/.bitcoin
  > 2022-11-24T18:08:04Z Config file: /home/bitcoin/.bitcoin/bitcoin.conf
  > 2022-11-24T18:08:04Z Config file arg: blockfilterindex="1"
  > 2022-11-24T18:08:04Z Config file arg: coinstatsindex="1"
  > 2022-11-24T18:08:04Z Config file arg: i2pacceptincoming="1"
  > 2022-11-24T18:08:04Z Config file arg: i2psam="127.0.0.1:7656"
  > 2022-11-24T18:08:04Z Config file arg: listen="1"
  > 2022-11-24T18:08:04Z Config file arg: listenonion="1"
  > 2022-11-24T18:08:04Z Config file arg: peerblockfilters="1"
  > 2022-11-24T18:08:04Z Config file arg: peerbloomfilters="1"
  > 2022-11-24T18:08:04Z Config file arg: proxy="127.0.0.1:9050"
  > 2022-11-24T18:08:04Z Config file arg: rpcauth=****
  > 2022-11-24T18:08:04Z Config file arg: server="1"
  > 2022-11-24T18:08:04Z Config file arg: txindex="1"
  [...]
  > 2022-11-24T18:09:04Z Synchronizing blockheaders, height: 4000 (~0.56%)
  [...]
  ```

Monitor the log file for a few minutes to see if it works fine (it may stop at "dnsseed thread exit", that's ok).

* Link the Bitcoin data directory from the "admin" user home directory as well.
  This allows "admin" to work with bitcoind directly, for example using the command `bitcoin-cli`

  ```sh
  $2 ln -s /data/bitcoin /home/admin/.bitcoin
  ```

* This symbolic link becomes active only in a new user session. Log out from SSH.

  ```sh
  $ exit
  ```

* Log in as user “admin” again `("ssh admin@minibolt.local")`

* Wait a few minutes until Bitcoin Core started, and enter the next command to obtain your Tor and I2P addresses. Take note of them, later you might need it

  ```sh
  $2 bitcoin-cli getnetworkinfo | grep address.*onion && bitcoin-cli getnetworkinfo | grep address.*i2p
  ```

* Check the correct enablement of the I2P and Tor networks

  ```sh
  $2 bitcoin-cli -netinfo
  ```

**Example** of expected output:

  ```
  Bitcoin Core client v24.0.1 - server 70016/Satoshi:24.0.1/
            ipv4    ipv6   onion   i2p   total   block
  in          0       0      25     2      27
  out         7       0       2     1      10       2
  total       7       0      27     3      37
  ```

* Please note:
  * When “bitcoind” is still starting, you may get an error message like “verifying blocks”.
    That’s normal, just give it a few minutes.
  * Among other info, the “verificationprogress” is shown.
    Once this value reaches almost 1 (0.999…), the blockchain is up-to-date and fully validated.

## Bitcoin Core is syncing

This can take between one day and a week, depending mostly on your PC performance.
It's best to wait until the synchronization is complete before going ahead.

### **Explore bitcoin-cli**

If everything is running smoothly, this is the perfect time to familiarize yourself with Bitcoin, the technical aspects of Bitcoin Core and play around with `bitcoin-cli` until the blockchain is up-to-date.

* [**The Little Bitcoin Book**](https://littlebitcoinbook.com){:target="_blank"} is a fantastic introduction to Bitcoin, focusing on the "why" and less on the "how".

* [**Mastering Bitcoin**](https://bitcoinbook.info){:target="_blank"} by Andreas Antonopoulos is a great point to start, especially chapter 3 (ignore the first part how to compile from source code):
  * you definitely need to have a [real copy](https://bitcoinbook.info/){:target="_blank"} of this book!
  * read it online on [GitHub](https://github.com/bitcoinbook/bitcoinbook){:target="_blank"}

  ![Mastering Bitcoin](../../images/30_mastering_bitcoin_book.jpg){:target="_blank"}

* [**Learning Bitcoin from the Command Line**](https://github.com/ChristopherA/Learning-Bitcoin-from-the-Command-Line/blob/master/README.md){:target="_blank"} by Christopher Allen gives a thorough deep dive into understanding the technical aspects of Bitcoin.

* Also, check out the [bitcoin-cli reference](https://en.bitcoin.it/wiki/Original_Bitcoin_client/API_calls_list){:target="_blank"}

### **Activate mempool & reduce 'dbcache' after a full sync**

Once Bitcoin Core is fully synced, we can reduce the size of the database cache.
A bigger cache speeds up the initial block download, now we want to reduce memory consumption to allow the Lightning client and Electrum server to run in parallel.
We also now want to enable the node to listen to and relay transactions.

* As user `"admin"`, comment the following lines out (add a `#` at the beginning) in the Bitcoin settings file. Bitcoin Core will then just use the default cache size of 450 MiB instead of your setting RAM setup. If `blocksonly=1` is left uncommented it will prevent Electrum Server from receiving RPC fee data and will not work. Save and exit.

  ```sh
  $ sudo nano /home/bitcoin/.bitcoin/bitcoin.conf
  ```

  ```
  #dbcache=2048
  #blocksonly=1
  #assumevalid=0
  ```

* Restart Bitcoin Core for the settings to take effect

  ```sh
  $ sudo systemctl restart bitcoind
  ```

## OpenTimestamps client

When we installed Bitcoin Core, we verified the timestamp of the checksum file using the OpenTimestamp website.
In the future, you will likely need to verify more timestamps, when installing additional programs (e.g. LND) and when updating existing programs to a newer version. Rather than relying on a third party, it would be preferable (and more fun) to verify the timestamps using your own blockchain data.
Now that Bitcoin Core is running and synced, we can install the [OpenTimestamp client](https://github.com/opentimestamps/opentimestamps-client){:target="_blank"} to locally verify the timestamp of the binaries checksums file.

* As user `"admin"`, install dependencies

  ```sh
  $ sudo apt-get install python3-dev python3-pip python3-wheel
  ```

* With user "admin", globally install the OpenTimestamp client

  ```sh
  $ sudo pip3 install opentimestamps-client
  ```

* Display the OpenTimestamps client version to check that it is properly installed

  ```sh
  $ ots --version
  ```

## Extras (optional)

### **Privacy mode**

* As user `admin` add these lines to the end of `bitcoin.conf` file, remember to add seed nodes. You can add more seed nodes are of this list: [seed nodes](https://github.com/bitcoin/bitcoin/blob/master/contrib/seeds/nodes_main_manual.txt)

  ```sh
  $ sudo nano /home/bitcoin/.bitcoin/bitcoin.conf
  ```

  ```
  # Privacy mode
  onlynet=onion
  onlynet=i2p
  dns=0
  dnsseed=0

  ##Tor seed nodes
  seednode=2bqghnldu6mcug4pikzprwhtjjnsyederctvci6klcwzepnjd46ikjyd.onion:8333
  seednode=4lr3w2iyyl5u5l6tosizclykf5v3smqroqdn2i4h3kq6pfbbjb2xytad.onion:8333
  seednode=5g72ppm3krkorsfopcm2bi7wlv4ohhs4u4mlseymasn7g7zhdcyjpfid.onion:8333
  seednode=5sbmcl4m5api5tqafi4gcckrn3y52sz5mskxf3t6iw4bp7erwiptrgqd.onion:8333
  seednode=776aegl7tfhg6oiqqy76jnwrwbvcytsx2qegcgh2mjqujll4376ohlid.onion:8333
  seednode=77mdte42srl42shdh2mhtjr7nf7dmedqrw6bkcdekhdvmnld6ojyyiad.onion:8333
  seednode=azbpsh4arqlm6442wfimy7qr65bmha2zhgjg7wbaji6vvaug53hur2qd.onion:8333
  seednode=b64xcbleqmwgq2u46bh4hegnlrzzvxntyzbmucn3zt7cssm7y4ubv3id.onion:8333
  seednode=bsqbtcparrfihlwolt4xgjbf4cgqckvrvsfyvy6vhiqrnh4w6ghixoid.onion:8333
  seednode=bsqbtctulf2g4jtjsdfgl2ed7qs6zz5wqx27qnyiik7laockryvszqqd.onion:8333

  ##I2P seed nodes
  seednode=255fhcp6ajvftnyo7bwz3an3t4a4brhopm3bamyh2iu5r3gnr2rq.b32.i2p:0
  seednode=27yrtht5b5bzom2w5ajb27najuqvuydtzb7bavlak25wkufec5mq.b32.i2p:0
  seednode=3gocb7wc4zvbmmebktet7gujccuux4ifk3kqilnxnj5wpdpqx2hq.b32.i2p:0
  seednode=4fcc23wt3hyjk3csfzcdyjz5pcwg5dzhdqgma6bch2qyiakcbboa.b32.i2p:0
  seednode=4osyqeknhx5qf3a73jeimexwclmt42cju6xdp7icja4ixxguu2hq.b32.i2p:0
  seednode=4umsi4nlmgyp4rckosg4vegd2ysljvid47zu7pqsollkaszcbpqq.b32.i2p:0
  seednode=6j2ezegd3e2e2x3o3pox335f5vxfthrrigkdrbgfbdjchm5h4awa.b32.i2p:0
  seednode=6n36ljyr55szci5ygidmxqer64qr24f4qmnymnbvgehz7qinxnla.b32.i2p:0
  seednode=72yjs6mvlby3ky6mgpvvlemmwq5pfcznrzd34jkhclgrishqdxva.b32.i2p:0
  seednode=a5qsnv3maw77mlmmzlcglu6twje6ttctd3fhpbfwcbpmewx6fczq.b32.i2p:0
  seednode=aovep2pco7v2k4rheofrgytbgk23eg22dczpsjqgqtxcqqvmxk6a.b32.i2p:0
  seednode=bitcoi656nll5hu6u7ddzrmzysdtwtnzcnrjd4rfdqbeey7dmn5a.b32.i2p:0
  seednode=brifkruhlkgrj65hffybrjrjqcgdgqs2r7siizb5b2232nruik3a.b32.i2p:0
  seednode=c4gfnttsuwqomiygupdqqqyy5y5emnk5c73hrfvatri67prd7vyq.b32.i2p:0
  seednode=day3hgxyrtwjslt54sikevbhxxs4qzo7d6vi72ipmscqtq3qmijq.b32.i2p:0
  seednode=du5kydummi23bjfp6bd7owsvrijgt7zhvxmz5h5f5spcioeoetwq.b32.i2p:0
  seednode=e55k6wu46rzp4pg5pk5npgbr3zz45bc3ihtzu2xcye5vwnzdy7pq.b32.i2p:0
  seednode=eciohu5nq7vsvwjjc52epskuk75d24iccgzmhbzrwonw6lx4gdva.b32.i2p:0
  ```

### **Slow device mode**

* As user `admin` add these lines to the end of the existing `bitcoin.conf` file

  ```sh
  $ sudo nano /home/bitcoin/.bitcoin/bitcoin.conf
  ```

  ```
  # Slow devices optimizations
  ## Limit the number of max peers connections
  maxconnections=40
  ## Tries to keep outbound traffic under the given target per 24h
  maxuploadtarget=5000
  ## Increase the number of threads to service RPC calls (default: 4)
  rpcthreads=128
  ## Increase the depth of the work queue to service RPC calls (default: 16)
  rpcworkqueue=256
  ```

* Comment these lines to the existing `bitcoin.conf` file

  ```
  #coinstatsindex=1
  #assumevalid=0
  ```

### **Manual page for bitcoin-cli**

* For convenience it might be useful to have the manual page for bitcoin-cli in the same machine so that they can be consulted offline, they can be installed from the directory
⚠️ This extra section is not valid if you compiled from source code using the [Ordisrespector bonus guide](../bonus/bitcoin/ordisrespector.md)

  ```sh
  $ cd bitcoin-$VERSION/share/man/man1
  ```

  ```sh
  $ gzip *
  ```

  ```sh
  $ sudo cp * /usr/share/man/man1/
  ```

* Now you can read the docs doing

  ```sh
  $ man bitcoin-cli
  ```

⬆️ Now come back to the next section ["Create the bitcoin user"](#create-the-bitcoin-user) to continue with the Bitcoin Core installation process.

## For the future: upgrade Bitcoin Core

The latest release can be found on the [GitHub page](https://github.com/bitcoin/bitcoin/releases) of the Bitcoin Core project. Always read the RELEASE NOTES first!
When upgrading, there might be breaking changes or changes in the data structure that need special attention.
Replace the environment variable `"VERSION=x.xx"` value for the latest version if it has not been already changed in this guide.

* Login as "admin" and change to the temporary directory.

  ```sh
  $ cd /tmp
  ```

* Set a temporary version environment variable to the installation

  ```sh
  $ VERSION=24.1
  ```

* Download binary, checksum, signature files and timestamp file

  ```sh
  $ wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/bitcoin-$VERSION-x86_64-linux-gnu.tar.gz
  ```

  ```sh
  $ wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS
  ```

  ```sh
  $ wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS.asc
  ```

  ```sh
  $ wget https://bitcoincore.org/bin/bitcoin-core-$VERSION/SHA256SUMS.ots
  ```

* Verify the new version against its checksums

  ```sh
  $ sha256sum --ignore-missing --check SHA256SUMS
  ```

Expected output:

  ```
  > bitcoin-$VERSION-x86_64-linux-gnu.tar.gz: OK
  ```

* The next command download and imports automatically all signatures from the [Bitcoin Core release attestations (Guix)](https://github.com/bitcoin-core/guix.sigs) repository

  ```sh
  $ curl -s "https://api.github.com/repositories/355107265/contents/builder-keys" | grep download_url | grep -oE "https://[a-zA-Z0-9./-]+" | while read url; do curl -s "$url" | gpg --import; done
  ```

Expected output:

  ```
  > gpg: key 17565732E08E5E41: 29 signatures not checked due to missing keys
  > gpg: /home/admin/.gnupg/trustdb.gpg: trustdb created
  > gpg: key 17565732E08E5E41: public key "Andrew Chow <andrew@achow101.com>" imported
  > gpg: Total number processed: 1
  > gpg:               imported: 1
  > gpg: no ultimately trusted keys found
  [...]
  ```

* Verify that the checksums file is cryptographically signed by the release signing keys.
  The following command prints signature checks for each of the public keys that signed the checksums.

  ```sh
  $ gpg --verify SHA256SUMS.asc
  ```

* Check that at least a few signatures show the following text

  ```
  > gpg: Good signature from ...
  > Primary key fingerprint: ...
  ```

* If you completed the IBD, now you can verify the timestamp with your own node. If the prompt shows you `-bash: ots: command not found`, ensure that you are installing correctly OTS client in the [proper section](bitcoin-client.md#opentimestamps-client)

  ```sh
  $ ots --no-cache verify SHA256SUMS.ots -f SHA256SUMS
  ```

The following output is just an **example** of one of the versions:

  ```
  > Got 1 attestation(s) from https://btc.calendar.catallaxy.com
  > Got 1 attestation(s) from https://finney.calendar.eternitywall.com
  > Got 1 attestation(s) from https://bob.btc.calendar.opentimestamps.org
  > Got 1 attestation(s) from https://alice.btc.calendar.opentimestamps.org
  > Success! Bitcoin block 766964 attests existence as of 2022-12-11 UTC
  ```

Now, just check that the timestamp date is close to the [release](https://github.com/bitcoin/bitcoin/releases) date of the version you're installing.

* If you're satisfied with the checksum, signature and timestamp checks, extract the Bitcoin Core binaries, install them and check the version.

  ```sh
  $ tar -xvf bitcoin-$VERSION-x86_64-linux-gnu.tar.gz
  ```

  ```sh
  $ sudo install -m 0755 -o root -g root -t /usr/local/bin bitcoin-$VERSION/bin/*
  ```

* Check the new version

  ```sh
  $ bitcoind --version
  ```

**Example** of expected output:

  ```
  > Bitcoin Core version v24.1.0
  > Copyright (C) 2009-2022 The Bitcoin Core developers
  > [...]
  ```

* Restart the Bitcoin Core to apply the new version

  ```sh
  $ sudo systemctl restart bitcoind
  ```

<br /><br />

---

Next: [Electrum server >>](electrum-server.md)
