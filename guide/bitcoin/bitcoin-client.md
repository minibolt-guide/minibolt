---
layout: default
title: Bitcoin client
nav_order: 10
parent: Bitcoin
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->

# Bitcoin client

{: .no_toc }

---

We install [Bitcoin Core](https://bitcoin.org/en/bitcoin-core/){:target="_blank"}, the reference client implementation of the Bitcoin network.

Status: Tested MiniBolt
{: .label .label-blue }

---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## This may take some time

Bitcoin Core will download the full Bitcoin blockchain, and validate all transactions since 2009.
We're talking more than 700'000 blocks with a size of over 430 GB, so this is not an easy task.

---

## Installation

We download the latest Bitcoin Core binary (the application) and compare this file with the signed and timestamped checksum.
This is a precaution to make sure that this is an official release and not a malicious version trying to steal our money.

### Preparations

* Login as "admin" and change to a temporary directory which is cleared on reboot.

  ```sh
  $ cd /tmp
  ```

* Get the latest download links at [bitcoincore.org/en/download](https://bitcoincore.org/en/download){:target="_blank"} (x86/amd64 Linux), they change with each update.

  ```sh
  # download Bitcoin Core binary
  $ wget https://bitcoincore.org/bin/bitcoin-core-23.0/bitcoin-23.0-x86_64-linux-gnu.tar.gz

  # download the list of cryptographic checksum
  $ wget https://bitcoincore.org/bin/bitcoin-core-23.0/SHA256SUMS

  # download the signatures attesting to validity of the checksums
  $ wget https://bitcoincore.org/bin/bitcoin-core-23.0/SHA256SUMS.asc
  ```

### Checksum check

* Check that the reference checksum in file `SHA256SUMS` matches the checksum calculated by you (ignore the "lines are improperly formatted" warning)

  ```sh
  $ sha256sum --ignore-missing --check SHA256SUMS
  > bitcoin-23.0-x86_64-linux-gnu.tar.gz: OK
  ```

### Signature check

* Bitcoin releases are signed by a number of individuals, each using their own key.
  In order to verify the validity of these signatures, you must first import the corresponding public keys.
  You can find many developer keys listed in the builder-keys repository, which you can then load into your GPG key database.

  ```sh
  $ wget https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/builder-keys/keys.txt
  $ while read fingerprint keyholder_name; do gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys ${fingerprint}; done < ./keys.txt
  ```

* Verify that the checksums file is cryptographically signed by the release signing keys.
  The following command prints signature checks for each of the public keys that signed the checksums.
  
  ```sh
  $ gpg --verify SHA256SUMS.asc
  ```

* Check that at least a few signatures show the following text

  ```sh
  > gpg: Good signature from ...
  > Primary key fingerprint: ...
  ```

### Timestamp check

* The binary checksum file is also timestamped with the Bitcoin blockchain using the [OpenTimestamps protocol](https://opentimestamps.org/){:target="_blank"}, proving that the file existed prior to some point in time. Let's verify this timestamp. On your local computer, download the checksums file and its timestamp proof:

  * [https://bitcoincore.org/bin/bitcoin-core-23.0/SHA256SUMS](https://bitcoincore.org/bin/bitcoin-core-23.0/SHA256SUMS)
  * [https://bitcoincore.org/bin/bitcoin-core-23.0/SHA256SUMS.ots](https://bitcoincore.org/bin/bitcoin-core-23.0/SHA256SUMS.ots)

* In your browser, open the [OpenTimestamps website](https://opentimestamps.org/){:target="_blank"}
* In the "Stamp and verify" section, drop or upload the downloaded SHA256SUMS.ots proof file in the dotted box
* In the next box, drop or upload the SHA256SUMS file
* If the timestamps is verified, you should see the following message. The timestamp proves that the checksums file existed on the [release date](https://github.com/bitcoin/bitcoin/releases/tag/v23.0){:target="_blank"} of Bitcoin Core v23.0.

![Bitcoin timestamp check](../../images/bitcoin-ots-check.PNG)

### Installation

* If you're satisfied with the checkum, signature and timestamp checks, extract the Bitcoin Core binaries, install them and check the version.

  ```sh
  $ tar -xvf bitcoin-23.0-x86_64-linux-gnu.tar.gz
  $ sudo install -m 0755 -o root -g root -t /usr/local/bin bitcoin-23.0/bin/*
  $ bitcoind --version
  > Bitcoin Core version v23.0.0
  > [...]
  ```

🔍 *Verifying signed software is important, not only for Bitcoin.
You can read more on [How to securely install Bitcoin](https://medium.com/@lukedashjr/how-to-securely-install-bitcoin-9bfeca7d3b2a){:target="_blank"} by Luke-Jr.*

### Create the bitcoin user

The Bitcoin Core application will run in the background as a daemon and use the separate user “bitcoin” for security reasons.
This user does not have admin rights and cannot change the system configuration.

* Create the user bitcoin

  ```sh
  $ sudo adduser --gecos "" --disabled-password bitcoin
  ```

* Add the user "admin" to the group "bitcoin" as well

  ```sh
  $ sudo adduser admin bitcoin
  ```

* Allow the user "bitcoin" to configure Tor directly by adding it to the "debian-tor" group

  ```sh
  $ sudo adduser bitcoin debian-tor
  ```

### Create data folder

Bitcoin Core uses by default the folder `.bitcoin` in the user's home.
Instead of creating this directory, we create a data directory in the general data location `/data` and link to it.

* Create the Bitcoin data folder

  ```sh
  $ mkdir /data/bitcoin
  $ sudo chown bitcoin:bitcoin /data/bitcoin
  ```

* Switch to user "bitcoin"

  ```sh
  $ sudo su bitcoin
  ```

* Create the symbolic link `.bitcoin` that points to that directory

  ```sh
  $ ln -s /data/bitcoin /home/bitcoin/.bitcoin
  ```

* Display the link and check that it is not shown in red (this would indicate an error)

  ```sh
  $ ls -la
  ```

### Generate access credentials

For other programs to query Bitcoin Core they need the proper access credentials.
To avoid storing username and password in a configuration file in plaintext, the password is hashed.
This allows Bitcoin Core to accept a password, hash it and compare it to the stored hash, while it is not possible to retrieve the original password.

Another option to get access credentials is through the `.cookie` file in the Bitcoin data directory.
This is created automatically and can be read by all users that are members of the "bitcoin" group.

Bitcoin Core provides a simple Python program to generate the configuration line for the config file.

* In the Bitcoin folder, download the RPCAuth program

  ```sh
  $ cd .bitcoin
  $ wget https://raw.githubusercontent.com/bitcoin/bitcoin/master/share/rpcauth/rpcauth.py
  ```

* Run the script with the Python3 interpreter, providing username (`minibolt`) and your `password [B]` as arguments.

  🚨 All commands entered are stored in the bash history.
  But we don't want the password to be stored where anyone can find it.
  For this, put a space (` `) in front of the command shown below.

  ```sh
  $  python3 rpcauth.py minibolt YourPasswordB
  > String to be appended to bitcoin.conf:
  > rpcauth=minibolt:00d8682ce66c9ef3dd9d0c0a6516b10e$c31da4929b3d0e092ba1b2755834889f888445923ac8fd69d8eb73efe0699afa
  ```

* Copy the `rpcauth` line, we'll need to paste it into the Bitcoin config file.

### Configuration

Now, the configuration file for `bitcoind` needs to be created.
We'll also set the proper access permissions.

* Still as user "bitcoin", open it with Nano and paste the configuration below.
  Replace the whole line starting with "rpcauth=" with the connection string you just generated.
  Save and exit.

  ```sh
  $ nano /home/bitcoin/.bitcoin/bitcoin.conf
  ```

  ```sh
  # MiniBolt: bitcoind configuration
  # /home/bitcoin/.bitcoin/bitcoin.conf

  ## Bitcoin daemon
  server=1
  txindex=1
  # Assign read permission to the Bitcoin group users 
  startupnotify=chmod g+r /home/bitcoin/.bitcoin/.cookie

  # Enable all compact filters
  blockfilterindex=1
  # Support filtering of blocks and transactions with bloom filters
  peerbloomfilters=1
  # Serve compact block filters to peers per BIP 157.
  peerblockfilters=1
  # Maintain coinstats index used by the gettxoutsetinfo RPC 
  coinstatsindex=1

  ## Network
  listen=1

  # Enable and proxify Tor
  listenonion=1
  proxy=127.0.0.1:9050

  ## Connections
  rpcauth=<replace with your own auth line generated by rpcauth.py in the previous step>

  ## Initial block download optimizations (set dbcache size in megabytes (4 to 16384, default: 300) according with your available RAM of your device, 
  ## recommended: dbcache=1/2 x RAM available e.g: 4GB RAM -> dbcache=2048)
  dbcache=2048
  blocksonly=1

  ```

* Set permissions: only the user 'bitcoin' and members of the 'bitcoin' group can read it

  ```sh
  $ chmod 640 /home/bitcoin/.bitcoin/bitcoin.conf
  ```

---

## Running bitcoind

Still logged in as user "bitcoin", let's start "bitcoind" manually.

* Start "bitcoind".
  Monitor the log file a few minutes to see if it works fine (it may stop at "dnsseed thread exit", that's ok).

  ```sh
  $ bitcoind
  ```

* Once everything looks ok, stop "bitcoind" with `Ctrl-C`

* Grant the "bitcoin" group read-permission for the debug log file:

  ```sh
  $ chmod g+r /data/bitcoin/debug.log
  ```

* Exit the “bitcoin” user session back to user “admin”

  ```sh
  $ exit
  ```

* Link the Bitcoin data directory from the "admin" user home directory as well.
  This allows "admin" to work with bitcoind directly, for example using the command `bitcoin-cli`

  ```sh
  $ ln -s /data/bitcoin /home/admin/.bitcoin
  ```

### Autostart on boot

The system needs to run the bitcoin daemon automatically in the background, even when nobody is logged in.
We use "systemd", a daemon that controls the startup process using configuration files.

* Create the configuration file in the Nano text editor and copy the following paragraph.
  Save and exit.

  ```
  $ sudo nano /etc/systemd/system/bitcoind.service
  ```

  ```sh
  # MiniBolt: systemd unit for bitcoind
  # /etc/systemd/system/bitcoind.service

  [Unit]
  Description=Bitcoin daemon
  After=network.target

  [Service]

  # Service execution
  ###################

  ExecStart=/usr/local/bin/bitcoind -daemon \
                                    -pid=/run/bitcoind/bitcoind.pid \
                                    -conf=/home/bitcoin/.bitcoin/bitcoin.conf \
                                    -datadir=/home/bitcoin/.bitcoin

  # Process management
  ####################
  Type=forking
  PIDFile=/run/bitcoind/bitcoind.pid
  Restart=on-failure
  TimeoutSec=300
  RestartSec=30

  # Directory creation and permissions
  ####################################
  User=bitcoin
  UMask=0027

  # /run/bitcoind
  RuntimeDirectory=bitcoind
  RuntimeDirectoryMode=0710

  # Hardening measures
  ####################
  # Provide a private /tmp and /var/tmp.
  PrivateTmp=true

  # Mount /usr, /boot/ and /etc read-only for the process.
  ProtectSystem=full

  # Disallow the process and all of its children to gain
  # new privileges through execve().
  NoNewPrivileges=true

  # Use a new /dev namespace only populated with API pseudo devices
  # such as /dev/null, /dev/zero and /dev/random.
  PrivateDevices=true

  # Deny the creation of writable and executable memory mappings.
  MemoryDenyWriteExecute=true

  [Install]
  WantedBy=multi-user.target
  ```

* Enable the service

  ```sh
  $ sudo systemctl enable bitcoind.service
  ```

### Verification of bitcoind operations

After rebooting, "bitcoind" should start and begin to sync and validate the Bitcoin blockchain.

* Wait a bit, reconnect via SSH and login with the user “admin”.

* Check the status of the bitcoin daemon that was started by "systemd".
  Exit with `Ctrl-C`

  ```sh
  $ sudo systemctl status bitcoind.service
  > * bitcoind.service - Bitcoin daemon
  >      Loaded: loaded (/etc/systemd/system/bitcoind.service; enabled; vendor preset: enabled)
  >      Active: active (running) since Thu 2021-11-25 22:50:59 GMT; 7s ago
  >     Process: 2316 ExecStart=/usr/local/bin/bitcoind -daemon -pid=/run/bitcoind/bitcoind.pid -conf=/home/bitcoin/.bitcoin/bitcoin.> conf -datadir=/home/bitcoin/.bitcoin (code=exited, status=0/SUCCESS)
  >    Main PID: 2317 (bitcoind)
  >       Tasks: 12 (limit: 4164)
  >         CPU: 7.613s
  >      CGroup: /system.slice/bitcoind.service
  >              `-2317 /usr/local/bin/bitcoind -daemon -pid=/run/bitcoind/bitcoind.pid -conf=/home/bitcoin/.bitcoin/bitcoin.conf > -datadir=/home/bitcoin/.bitcoin
  >
  ```

* Check if the permission cookie can be accessed by the group "bitcoin".
  The output must contain the `-rw-r-----` part, otherwise no application run by a different user can access Bitcoin Core.

  ```sh
  $ ls -la /home/bitcoin/.bitcoin/.cookie
  > -rw-r----- 1 bitcoin bitcoin 75 Dec 17 13:48 /home/bitcoin/.bitcoin/.cookie
  ```

* See "bitcoind" in action by monitoring its log file.
  Exit with `Ctrl-C`

  ```sh
  $ tail -f /home/bitcoin/.bitcoin/debug.log
  ```

* Use the Bitcoin Core client `bitcoin-cli` to get information about the current blockchain

  ```sh
  $ bitcoin-cli getblockchaininfo
  ```

* Please note:
  * When “bitcoind” is still starting, you may get an error message like “verifying blocks”.
    That’s normal, just give it a few minutes.
  * Among other infos, the “verificationprogress” is shown.
    Once this value reaches almost 1 (0.999…), the blockchain is up-to-date and fully validated.

---

## Bitcoin Core is syncing

This can take between one day and a week, depending mostly on your external drive (SSD good, HDD bad; USB3 good, USB2 very bad).
It's best to wait until the synchronization is complete before going ahead.

### Explore bitcoin-cli

If everything is running smoothly, this is the perfect time to familiarize yourself with Bitcoin, the technical aspects of Bitcoin Core and play around with `bitcoin-cli` until the blockchain is up-to-date.

* [**The Little Bitcoin Book**](https://littlebitcoinbook.com){:target="_blank"} is a fantastic introduction to Bitcoin, focusing on the "why" and less on the "how".

* [**Mastering Bitcoin**](https://bitcoinbook.info){:target="_blank"} by Andreas Antonopoulos is a great point to start, especially chapter 3 (ignore the first part how to compile from source code):
  * you definitely need to have a [real copy](https://bitcoinbook.info/){:target="_blank"} of this book!
  * read it online on [Github](https://github.com/bitcoinbook/bitcoinbook){:target="_blank"}

  ![Mastering Bitcoin](../../images/30_mastering_bitcoin_book.jpg){:target="_blank"}

* [**Learning Bitcoin from the Command Line**](https://github.com/ChristopherA/Learning-Bitcoin-from-the-Command-Line/blob/master/README.md){:target="_blank"} by Christopher Allen gives a thorough deep dive into understanding the technical aspects of Bitcoin.

* Also, check out the [bitcoin-cli reference](https://en.bitcoin.it/wiki/Original_Bitcoin_client/API_calls_list){:target="_blank"}

### Reduce 'dbcache' after full sync

Once Bitcoin Core is fully synced, we can reduce the size of the database cache.
A bigger cache speeds up the initial block download, now we want to reduce memory consumption to allow LND and Electrs to run in parallel.
We also now want to enable the node to listen to and relay transactions.

* As user "admin", comment the following lines out (add a `#` at the beginning) in the Bitcoin settings file.
  Bitcoin Core will then just use the default cache size of 300 MB instead of 2 GB.
  Save and exit.

  ```sh
  $ sudo nano /home/bitcoin/.bitcoin/bitcoin.conf
  ```

  ```sh
  #dbcache=2048
  #blocksonly=1
  ```

* Restart Bitcoin Core for the settings to take effect.

  ```sh
  $ sudo systemctl restart bitcoind
  ```

---

## Extras (optional)

### Privacy mode

* As user `admin` add this lines to the end of `bitcoin.conf` file, remember add seed nodes

  ```sh
  $ sudo nano /home/bitcoin/.bitcoin/bitcoin.conf
  ```

  ```sh
  # Privacy mode
  onlynet=onion
  onlynet=i2p
  dns=0
  dnsseed=0

  ##Tor seed nodes
  seednode=5g72ppm3krkorsfopcm2bi7wlv4ohhs4u4mlseymasn7g7zhdcyjpfid.onion:8333
  seednode=b64xcbleqmwgq2u46bh4hegnlrzzvxntyzbmucn3zt7cssm7y4ubv3id.onion:8333
  seednode=fjdyxicpm4o42xmedlwl3uvk5gmqdfs5j37wir52327vncjzvtpfv7yd.onion:8333
  seednode=fpz6r5ppsakkwypjcglz6gcnwt7ytfhxskkfhzu62tnylcknh3eq6pad.onion:8333
  seednode=gxo5anvfnffnftfy5frkgvplq3rpga2ie3tcblo2vl754fvnhgorn5yd.onion:8333
  seednode=ifdu5qvbofrt4ekui2iyb3kbcyzcsglazhx2hn4wfskkrx2v24qxriid.onion:8333
  seednode=itz3oxsihs62muvknc237xabl5f6w6rfznfhbpayrslv2j2ubels47yd.onion:8333
  seednode=kpgvmscirrdqpekbqjsvw5teanhatztpp2gl6eee4zkowvwfxwenqaid.onion:8333
  seednode=m7cbpjolo662uel7rpaid46as2otcj44vvwg3gccodnvaeuwbm3anbyd.onion:8333
  seednode=mwmfluek4au6mxxpw6fy7sjhkm65bdfc7izc7lpz3trewfdghyrzsbid.onion:8333
  seednode=rp7k2go3s5lyj3fnj6zn62ktarlrsft2ohlsxkyd7v3e3idqyptvread.onion:8333

  ##I2P seed nodes
  seednode=255fhcp6ajvftnyo7bwz3an3t4a4brhopm3bamyh2iu5r3gnr2rq.b32.i2p:0
  seednode=27yrtht5b5bzom2w5ajb27najuqvuydtzb7bavlak25wkufec5mq.b32.i2p:0
  seednode=2el6enckmfyiwbfcwsygkwksovtynzsigmyv3bzyk7j7qqahooua.b32.i2p:0
  seednode=3gocb7wc4zvbmmebktet7gujccuux4ifk3kqilnxnj5wpdpqx2hq.b32.i2p:0
  seednode=3tns2oov4tnllntotazy6umzkq4fhkco3iu5rnkxtu3pbfzxda7q.b32.i2p:0
  seednode=4fcc23wt3hyjk3csfzcdyjz5pcwg5dzhdqgma6bch2qyiakcbboa.b32.i2p:0
  seednode=4osyqeknhx5qf3a73jeimexwclmt42cju6xdp7icja4ixxguu2hq.b32.i2p:0
  seednode=4umsi4nlmgyp4rckosg4vegd2ysljvid47zu7pqsollkaszcbpqq.b32.i2p:0
  seednode=52v6uo6crlrlhzphslyiqblirux6olgsaa45ixih7sq5np4jujaa.b32.i2p:0
  seednode=6j2ezegd3e2e2x3o3pox335f5vxfthrrigkdrbgfbdjchm5h4awa.b32.i2p:0
  seednode=6n36ljyr55szci5ygidmxqer64qr24f4qmnymnbvgehz7qinxnla.b32.i2p:0
  seednode=72yjs6mvlby3ky6mgpvvlemmwq5pfcznrzd34jkhclgrishqdxva.b32.i2p:0
  seednode=7r4ri53lby2i3xqbgpw3idvhzeku7ubhftlf72ldqkg5kde6dauq.b32.i2p:0
  seednode=a5qsnv3maw77mlmmzlcglu6twje6ttctd3fhpbfwcbpmewx6fczq.b32.i2p:0
  seednode=aovep2pco7v2k4rheofrgytbgk23eg22dczpsjqgqtxcqqvmxk6a.b32.i2p:0
  seednode=bddbsmkas3z6fakorbkfjhv77i4hv6rysyjsvrdjukxolfghc23q.b32.i2p:0
  seednode=bitcoi656nll5hu6u7ddzrmzysdtwtnzcnrjd4rfdqbeey7dmn5a.b32.i2p:0
  seednode=brifkruhlkgrj65hffybrjrjqcgdgqs2r7siizb5b2232nruik3a.b32.i2p:0
  seednode=c4gfnttsuwqomiygupdqqqyy5y5emnk5c73hrfvatri67prd7vyq.b32.i2p:0
  seednode=day3hgxyrtwjslt54sikevbhxxs4qzo7d6vi72ipmscqtq3qmijq.b32.i2p:0
  seednode=di2zq6fr3fegf2jdcd7hdwyql4umr462gonsns2nxz5qg5vz4bka.b32.i2p:0
  seednode=e55k6wu46rzp4pg5pk5npgbr3zz45bc3ihtzu2xcye5vwnzdy7pq.b32.i2p:0
  seednode=eciohu5nq7vsvwjjc52epskuk75d24iccgzmhbzrwonw6lx4gdva.b32.i2p:0
  seednode=ejlnngarmhqvune74ko7kk55xtgbz5i5ncs4vmnvjpy3l7y63xaa.b32.i2p:0
  seednode=g47cqoppu26pr4n2cfaioqx7lbdi7mea7yqhlrkdz3wjwxjxdh2a.b32.i2p:0
  seednode=h3r6bkn46qxftwja53pxiykntegfyfjqtnzbm6iv6r5mungmqgmq.b32.i2p:0
  seednode=hhfi4yqkg2twqiwezrfksftjjofbyx3ojkmlnfmcwntgnrjjhkya.b32.i2p:0
  seednode=hpiibrflqkbrcshfhmrtwfyeb7mds7a3obzwrgarejevddzamvsq.b32.i2p:0
  seednode=i4pyhsfdq4247dunel7paatdaq5gusi2hnybp2yf5wxwdnrgxaqq.b32.i2p:0
  ```

### Slow device mode

* As user `admin` add this lines to the end of the exist `bitcoin.conf` file

 ```sh
  $ sudo nano /home/bitcoin/.bitcoin/bitcoin.conf
  ```

  ```sh
  ## Slow devices optimizations
  # Limit the number of max peers connections
  maxconnections=40
  # Increase the number of threads to service RPC calls (default: 4)
  rpcthreads=128
  # Increase the depth of the work queue to service RPC calls
  rpcworkqueue=512
  ```

* Comment this line to the exist `bitcoin.conf` file

  ```sh
  # Maintain coinstats index used by the gettxoutsetinfo RPC
  #coinstatsindex=1
  ```

### OpenTimestamps client

When we installed Bitcoin Core, we verified the timestamp of the checksum file using the OpenTimestamp website.
In the future, you will likely need to verify more timestamps, when installing additional programs (e.g. LND) and when updating existing programs to a newer version. Rather than relying on a third-party, it would be preferable (and more fun) to verify the timestamps using your own blockchain data.
Now that Bitcoin Core is running and synced, we can install the [OpenTimestamp client](https://github.com/opentimestamps/opentimestamps-client){:target="_blank"} to locally verify the timestamp of the binaries checksums file.

* Install dependencies

  ```sh
  $ sudo apt-get install python3 python3-dev python3-pip python3-setuptools python3-wheel
  ```

* With user "admin", globally install the OpenTimestamp client

  ```sh
  $ sudo pip3 install opentimestamps-client
  ```

* Display the OpenTimestamps client version to check that it is properly installed

  ```sh
  $ ots --version
  ```

---

## For the future: upgrade Bitcoin Core

The latest release can be found on the Github page of the Bitcoin Core project:
<https://github.com/bitcoin/bitcoin/releases>
Always read the RELEASE NOTES first!
When upgrading, there might be breaking changes, or changes in the data structure that need special attention.

* There's no need to stop the application.

  Simply install the new version and restart the service.

Download, verify, extract and install the Bitcoin Core binaries as described in the [Bitcoin section](bitcoin-client.md#installation) of this guide. When checking the timestamp, instead of using the website, use the following command:

* Download the timestamp in the same directory as the checksum and signature files, i.e. /tmp

  ```sh
  $ wget https://bitcoincore.org/bin/bitcoin-core-23.0/SHA256SUMS
  $ wget https://bitcoincore.org/bin/bitcoin-core-23.0/SHA256SUMS.ots
  ```

* Verify the timestamp

  ```sh
  $ ots --no-cache verify SHA256SUMS.ots -f SHA256SUMS
  ```

* Expected output

  ```sh
  > Got 1 attestation(s) from https://alice.btc.calendar.opentimestamps.org
  > Got 1 attestation(s) from https://finney.calendar.eternitywall.com
  > Got 1 attestation(s) from https://btc.calendar.catallaxy.com
  > Got 1 attestation(s) from https://bob.btc.calendar.opentimestamps.org
  > Success! Bitcoin block 733490 attests existence as of 2022-04-25 UTC
  ```

Now, just check that the timestamp date is close to the release date of the version you're installing.

* Restart the Bitcoin Core systemd unit

  ```sh
  $ sudo systemctl restart bitcoind
  ```

<br /><br />

---

Next: [Electrum server >>](electrum-server.md)
