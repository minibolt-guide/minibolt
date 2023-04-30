---
layout: default
title: Electrum server
nav_order: 20
parent: Bitcoin
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->

# Electrum Server: Fulcrum

{: .no_toc }

---

[Fulcrum](https://github.com/cculianu/Fulcrum){:target="_blank"} is a fast & nimble SPV server for Bitcoin Cash, Bitcoin BTC, and Litecoin created by Calin Culianu. It can be used as an alternative to Electrs because of its performance, as we can see in Craig Raw's [comparison](https://www.sparrowwallet.com/docs/server-performance.html){:target="_blank"} of servers

![Fulcrum](../../images/fulcrum.png)

---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Requirements

* Bitcoin Core
* Little over 100GB of free storage for the database (external backup recommended)

Fulcrum is a replacement for an [Electrs](../bonus/bitcoin/electrs.md), these two services cannot be run at the same time (due to the same standard ports used), remember to stop Electrs doing `"sudo systemctl stop electrs"`.

## Bitcoin with hardware wallets

The best way to safekeep your bitcoin (meaning the best combination of security and usability) is to use a hardware wallet (like [BitBox](https://shiftcrypto.ch/bitbox02){:target="_blank"}, [Coldcard](https://coldcard.com/){:target="_blank"}, [Ledger](https://www.ledger.com){:target="_blank"} or [Trezor](https://trezor.io){:target="_blank"}) in combination with your own Bitcoin node.
This gives you security, privacy and eliminates the need to trust a third party to verify transactions.

Bitcoin Core on the MiniBolt itself is not meant to hold funds.

One possibility to use Bitcoin Core with your Bitcoin wallets is to use an Electrum server as middleware.
It imports data from Bitcoin Core and provides it to software wallets supporting the Electrum protocol.
Desktop wallets like [Sparrow](https://sparrowwallet.com/){:target="_blank"}, the [BitBoxApp](https://shiftcrypto.ch/app/){:target="_blank"}, [Electrum](https://electrum.org/){:target="_blank"} or [Specter Desktop](https://specter.solutions/desktop/){:target="_blank"} that support hardware wallets can then be used with your own sovereign Bitcoin node.

## Preparations

Make sure that you have [reduced the database cache of Bitcoin Core](../bitcoin/bitcoin-client.md#activate-mempool--reduce-dbcache-after-a-full-sync)

### **Install dependencies**

* With user `"admin"`, make sure that all necessary software packages are installed

  ```sh
  $ sudo apt install libssl-dev
  ```

### **Configure Firewall**

* Configure the firewall to allow incoming requests

  ```sh
  $ sudo ufw allow 50001/tcp comment 'allow Fulcrum TCP from anywhere'
  ```

  ```sh
  $ sudo ufw allow 50002/tcp comment 'allow Fulcrum SSL from anywhere'
  ```

### **Configure Bitcoin Core**

We need to set up settings in the Bitcoin Core configuration file - add new lines if they are not present

* In `bitcoin.conf`, add the following line in the `"# Connections"` section. Save and exit

  ```sh
  $ sudo nano /data/bitcoin/bitcoin.conf
  ```

  ```sh
  zmqpubhashblock=tcp://127.0.0.1:8433
  ```

* Restart Bitcoin Core

  ```sh
  $ sudo systemctl restart bitcoind
  ```

## Installation

### **Download and set up Fulcrum**

We have our Bitcoin Core configuration file set up and can now move on to the next part of the Fulcrum installation.

* Login as "admin" and change to a temporary directory which is cleared on reboot

  ```sh
  $ cd /tmp
  ```

* Set a temporary version environment variable to the installation

  ```sh
  $ VERSION=1.9.1
  ```

* Download the application, checksums and signature

  ```sh
  $ wget https://github.com/cculianu/Fulcrum/releases/download/v$VERSION/Fulcrum-$VERSION-x86_64-linux.tar.gz
  ```

  ```sh
  $ wget https://github.com/cculianu/Fulcrum/releases/download/v$VERSION/Fulcrum-$VERSION-x86_64-linux.tar.gz.asc
  ```

  ```sh
  $ wget https://github.com/cculianu/Fulcrum/releases/download/v$VERSION/Fulcrum-$VERSION-x86_64-linux.tar.gz.sha256sum
  ```

* Get the public key from the Fulcrum developer

  ```sh
  $ curl https://raw.githubusercontent.com/Electron-Cash/keys-n-hashes/master/pubkeys/calinkey.txt | gpg --import
  ```

Expected output:

  ```
  >     % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
  >                                 Dload  Upload   Total   Spent    Left  Speed
  > 100  2328  100  2328    0     0  16043      0 --:--:-- --:--:-- --:--:-- 15945
  > gpg: key 21810A542031C02C: "Calin Culianu (NilacTheGrim) <calin.culianu@gmail.com>" not changed
  > gpg: Total number processed: 1
  > gpg:              unchanged: 1
  ```

* Verify the signature of the text file containing the checksums for the application

  ```sh
  $ gpg --verify Fulcrum-$VERSION-x86_64-linux.tar.gz.asc
  ```

Expected output:

  ```
  > gpg: Good signature from "Calin Culianu (NilacTheGrim) <calin.culianu@gmail.com>" [unknown]
  > gpg: WARNING: This key is not certified with a trusted signature!
  > gpg: There is no indication that the signature belongs to the owner.
  > Primary key fingerprint: D465 135F 97D0 047E 18E9  9DC3 2181 0A54 2031 C02C
  ```

* Verify the signed checksum against the actual checksum of your download

  ```sh
  $ sha256sum --check Fulcrum-$VERSION-x86_64-linux.tar.gz.sha256sum
  ```

Expected output:

  ```
  > Fulcrum-$VERSION-x86_64-linux.tar.gz: OK
  ```

* Extract and install Fulcrum

  ```sh
  $ tar -xvf Fulcrum-$VERSION-x86_64-linux.tar.gz
  ```

  ```sh
  $ sudo install -m 0755 -o root -g root -t /usr/local/bin Fulcrum-$VERSION-x86_64-linux/Fulcrum Fulcrum-$VERSION-x86_64-linux/FulcrumAdmin
  ```

* Check the correct installation requesting the version

  ```sh
  $ Fulcrum --version
  ```

Expected output:

  ```
  > Fulcrum $VERSION (Release xxxxx)
  > compiled: gcc 8.4.0
  [...]
  ```

### **Data directory**

Now that Fulcrum is installed, we need to configure it to run automatically on startup.

* Create the "fulcrum" user, and add it to the "bitcoin" group

  ```sh
  $ sudo adduser --disabled-password --gecos "" fulcrum
  ```

  ```sh
  $ sudo adduser fulcrum bitcoin
  ```

* Create the fulcrum data directory and assign the owner to the "fulcrum" user

  ```sh
  $ sudo mkdir -p /data/fulcrum/fulcrum_db
  ```

  ```sh
  $ sudo chown -R fulcrum:fulcrum /data/fulcrum/
  ```

* Create a symlink to /home/fulcrum/.fulcrum and assign as the owner to the "fulcrum" user

  ```sh
  $ sudo ln -s /data/fulcrum /home/fulcrum/.fulcrum
  ```

  ```sh
  $ sudo chown -R fulcrum:fulcrum /home/fulcrum/.fulcrum
  ```

* Open a "fulcrum" user session

  ```sh
  $ sudo su - fulcrum
  ```

* Change to the fulcrum data folder and generate cert and key files for SSL

  ```sh
  $ cd /data/fulcrum
  ```

  ```sh
  $ openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout key.pem -out cert.pem
  ```

💡 When it asks you to put some info, press `Enter` until the prompt is shown again, is not necessary to put any info

* Download the custom Fulcrum banner based on MiniBolt. Create your own if you want [here](https://patorjk.com/software/taag/#p=display&f=Slant&t=fulcrum)

  ```sh
  $ wget https://raw.githubusercontent.com/twofaktor/minibolt/main/resources/fulcrum-banner.txt
  ```

### **Configuration**

MiniBolt uses SSL as default for Fulcrum, but some wallets like BlueWallet do not support SSL over Tor. That's why we use TCP in configurations as well to let the user choose what he needs. You may as well need to use TCP for other reasons.

* Next, we have to set up our Fulcrum configurations. Troubles could be found without optimizations for slow devices. Choose either one for 4GB or 8GB of RAM depending on your hardware.

  ```sh
  $ nano /data/fulcrum/fulcrum.conf
  ```

* Create the config file with the following content. Save and exit

  ```
  # MiniBolt: fulcrum configuration
  # /data/fulcrum/fulcrum.conf

  ## Bitcoin Core settings
  bitcoind = 127.0.0.1:8332
  rpccookie = /data/bitcoin/.cookie

  ## Fulcrum server general settings
  datadir = /data/fulcrum/fulcrum_db
  cert = /data/fulcrum/cert.pem
  key = /data/fulcrum/key.pem
  ssl = 0.0.0.0:50002
  tcp = 0.0.0.0:50001
  peering = false

  # Set fast-sync accorling with your device,
  # recommended: fast-sync=1/2 x RAM available e.g: 4GB RAM -> dbcache=2048
  fast-sync = 2048

  # Banner
  banner = /data/fulcrum/fulcrum-banner.txt
  ```

💡 Remember, if you have a slow-performance device, follow the [slow device section](#slow-device-mode) to improve the experience of the first indexation

* Exit the "fulcrum" user session to return to the "admin" user session

  ```sh
  $ exit
  ```

### **Autostart on boot**

Fulcrum needs to start automatically on system boot.

* As user "admin", create the Fulcrum systemd unit and copy/paste the following configuration. Save and exit

  ```sh
  $ sudo nano /etc/systemd/system/fulcrum.service
  ```

  ```
  # MiniBolt: systemd unit for Fulcrum
  # /etc/systemd/system/fulcrum.service

  [Unit]
  Description=Fulcrum
  After=bitcoind.service
  PartOf=bitcoind.service

  StartLimitBurst=2
  StartLimitIntervalSec=20

  [Service]
  ExecStart=/usr/local/bin/Fulcrum /data/fulcrum/fulcrum.conf
  KillSignal=SIGINT
  User=fulcrum
  Type=exec
  TimeoutStopSec=3600

  [Install]
  WantedBy=multi-user.target
  ```

* Enable autoboot

  ```sh
  $ sudo systemctl enable fulcrum.service
  ```

* Prepare "fulcrum" monitoring by the systemd journal and check log logging output. You can exit monitoring at any time with `Ctrl-C`

  ```sh
  $ sudo journalctl -f -u fulcrum
  ```

## Run Fulcrum

[Start your SSH program](../system/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the PC and log in as "admin".
Commands for the **second session** start with the prompt `$2` (which must not be entered).

```sh
$2 sudo systemctl start fulcrum
```

Monitor the systemd journal at the first session created to check if everything works fine. **Example** of expected output:

  ```
  -- Journal begins at Mon 2022-04-04 16:41:41 CEST. --
  Jul 28 12:20:13 minibolt Fulcrum[181811]: [2022-07-28 12:20:13.063] simdjson: version 0.6.0
  Jul 28 12:20:13 minibolt Fulcrum[181811]: [2022-07-28 12:20:13.063] ssl: OpenSSL 1.1.1n  15 Mar 2022
  Jul 28 12:20:13 minibolt Fulcrum[181811]: [2022-07-28 12:20:13.063] zmq: libzmq version: 4.3.3, cppzmq version: 4.7.1
  Jul 28 12:20:13 minibolt Fulcrum[181811]: [2022-07-28 12:20:13.064] Fulcrum $VERSION (Release a5a53cf) - Wed Dec 21, 2022 15:35:25.963 UTC - starting up ...
  Jul 28 12:20:13 minibolt Fulcrum[181811]: [2022-07-28 12:20:13.064] Max open files: 524288 (increased from default: 1024)
  Jul 28 12:20:13 minibolt Fulcrum[181811]: [2022-07-28 12:20:13.065] Loading database ...
  Jul 28 12:20:14 minibolt Fulcrum[181811]: [2022-07-28 12:20:14.489] DB memory: 512.00 MiB
  Jul 28 12:20:14 minibolt Fulcrum[181811]: [2022-07-28 12:20:14.491] Coin: BTC
  Jul 28 12:20:14 minibolt Fulcrum[181811]: [2022-07-28 12:20:14.492] Chain: main
  Jul 28 12:20:14 minibolt Fulcrum[181811]: [2022-07-28 12:20:14.494] Verifying headers ...
  Jul 28 12:20:19 minibolt Fulcrum[181811]: [2022-07-28 12:20:19.780] Initializing header merkle cache ...
  Jul 28 12:20:21 minibolt Fulcrum[181811]: [2022-07-28 12:20:21.643] Checking tx counts ...
  ...
  ```

Fulcrum will now index the whole Bitcoin blockchain so that it can provide all necessary information to wallets. With this, the wallets you use no longer need to connect to any third-party server to communicate with the Bitcoin peer-to-peer network.

DO NOT REBOOT OR STOP THE SERVICE DURING DB CREATION PROCESS. YOU MAY CORRUPT THE FILES - in case that happens, start the sync from scratch by deleting and recreating `fulcrum_db` folder.

💡 Fulcrum must first fully index the blockchain and compact its database before you can connect to it with your wallets. This can take up to ~3.5 - 4 days depending on the hardware. Only proceed with the [Desktop Wallet Section](../bitcoin/desktop-wallet.md) once Fulcrum is ready.

* When you see logs like this `<Controller> XXXX mempool txs involving XXXX addresses`, it means that Fulcrum is fully indexed, ensure the service is working and listening at the default `50002` & `50001` ports

  ```sh
  $2 sudo ss -tulpn | grep LISTEN | grep Fulcrum
  ```

## For the future: Fulcrum upgrade

Follow the complete [Download and set up Fulcrum](#download-and-set-up-fulcrum) section replacing the environment variable `"VERSION=x.xx"` value for the latest if it has not been already changed in this guide.

* Restart the service to apply the changes

  ```sh
  $ sudo systemctl restart fulcrum
  ```

* Check logs and pay attention to the next log if that attends to the new version installed

  ```sh
  $ sudo journalctl -f -u fulcrum
  ```

  ```
  Jul 28 12:20:13 minibolt Fulcrum[181811]: [2022-07-28 12:20:13.064] Fulcrum $VERSION (Release a5a53cf) - Wed Dec 21, 2022 15:35:25.963 UTC - starting up ...
  ```

## Extras (optional)

### **Remote access over Tor**

To use your Fulcrum server when you're on the go, you can easily create a Tor hidden service.
This way, you can connect the BitBoxApp or Electrum wallet also remotely, or even share the connection details with friends and family. Note that the remote device needs to have Tor installed as well.

* Ensure that you are logged in with user "admin" and add the following three lines in the section for "location-hidden services" in the torrc file. Save and exit

  ```sh
  $ sudo nano /etc/tor/torrc
  ```

* Edit torrc

  ```
  ############### This section is just for location-hidden services ###
  # Hidden Service Fulcrum TCP & SSL
  HiddenServiceDir /var/lib/tor/hidden_service_fulcrum_tcp_ssl/
  HiddenServiceVersion 3
  HiddenServicePort 50001 127.0.0.1:50001
  HiddenServicePort 50002 127.0.0.1:50002
  ```

* Reload the Tor configuration and get your connection addresses

  ```sh
  $ sudo systemctl reload tor
  ```

  ```sh
  $ sudo cat /var/lib/tor/hidden_service_fulcrum_tcp_ssl/hostname
  ```

*Example* expected output:

  ```
  > abcdefg..............xyz.onion
  ```

* You should now be able to connect to your Fulcrum server remotely via Tor using your hostname and port 50001 (TCP) or 50002 (SSL)

### **Slow device mode**

#### **Fulcrum configuration**

* As the `admin` user, add these lines at the end of the existing `fulcrum.conf` file.
Uncomment the `db_max_open_files` parameter choosing the appropriate one for 4 GB or 8 GB of RAM depending on your hardware.

 ```sh
  $ sudo nano /data/fulcrum/fulcrum.conf
  ```

  ```
  ## Slow device first-time start optimizations
  bitcoind_timeout = 600
  bitcoind_clients = 1
  worker_threads = 1
  db_mem = 1024.0

  # 4GB RAM
  #db_max_open_files = 200
  # 8GB RAM
  #db_max_open_files = 400
  ```

#### **Install zram-swap**

zram-swap is a compressed swap in memory and on disk and is necessary for the proper functioning of Fulcrum during the sync process using compressed swap in memory (increase performance when memory usage is high)

* Access to "admin" home folder, clone the repository of GitHub and install zram-swap

  ```sh
  $ cd /home/admin/
  ````

  ```sh
  $ git clone https://github.com/foundObjects/zram-swap.git
  ```

  ```
  $ cd zram-swap && sudo ./install.sh
  ```

* Add kernel parameters to make better use of zram

  ```sh
  $ sudo nano /etc/sysctl.conf
  ```

* Here are the lines you’ll want to add **at the end** of your `/etc/sysctl.conf` file to make better use of zram. Save and exit

  ```
  vm.vfs_cache_pressure=500
  vm.swappiness=100
  vm.dirty_background_ratio=1
  vm.dirty_ratio=50
  ```

* Then apply the changes with

  ```sh
  $ sudo sysctl --system
  ```

* Restart the service

  ```sh
  $ sudo systemctl restart zram-swap
  ```

* Make sure zram was correctly installed and zram prioritized

  ```sh
  $ sudo cat /proc/swaps
  ```

**Example** of expected output:

  ```
  Filename                                Type            Size            Used            Priority
  /swap.img                               file            4194300         0               -2
  /dev/zram0                              partition       10055452        368896          15
  ```

### **Backup the database**

If the database gets corrupted and you don't have a backup, you will have to resync it from scratch, which takes several days. This is why we recommend making backups of the database once in a while, on an external drive. Like this, if something happens, you'll only have to resync since the date of your latest backup. Before doing the backup, remember to stop Fulcrum by doing `"sudo` systemctl stop fulcrum"`.

## Uninstall

### **Uninstall Fulcrum**

* Ensure you are logged in with user "admin", stop, disable and delete the service

  ```sh
  $ sudo systemctl stop fulcrum
  ```

  ```sh
  $ sudo systemctl disable fulcrum
  ```

  ```sh
  $ sudo rm /etc/systemd/system/fulcrum.service
  ```

* Delete "fulcrum" user

  ```sh
  $ sudo userdel -r fulcrum
  ```

* Delete fulcrum directory

  ```sh
  $ sudo rm -rf /data/fulcrum/
  ```

### **Uninstall Tor hidden service**

* Ensure you are logged in with user "admin", comment or remove fulcrum hidden service in the torrc. Save and exit

  ```sh
  $ sudo nano /etc/tor/torrc
  ```

  ```
  ############### This section is just for location-hidden services ###
  # Hidden Service Fulcrum TCP & SSL
  #HiddenServiceDir /var/lib/tor/hidden_service_fulcrum_ssl/
  #HiddenServiceVersion 3
  #HiddenServicePort 50001 127.0.0.1:50001
  #HiddenServicePort 50002 127.0.0.1:50002
  ```

* Reload the torrc config

  ```sh
  $ sudo systemctl reload tor
  ```

### **Uninstall FW configuration**

* Ensure you are logged in with user "admin", display the UFW firewall rules and note the numbers of the rules for Fulcrum (e.g., X and Y below)

  ```sh
  $ sudo ufw status numbered
  ```

Expected output:

  ```
  > [Y] 50001                   ALLOW IN    Anywhere                  # allow Fulcrum TCP from anywhere
  > [X] 50002                   ALLOW IN    Anywhere                  # allow Fulcrum SSL from anywhere
  ```

* Delete the rule with the correct number and confirm with "yes"

  ```sh
  $ sudo ufw delete X
  ```

### **Uninstall the Zram**

* Ensure you are logged in with user `"admin"`, navigate to zram-swap folder and uninstall

  ```sh
  $ cd /home/admin/zram-swap
  ```

  ```sh
  $ sudo ./install.sh --uninstall
  ```

  ```sh
  $ sudo rm /etc/default/zram-swap
  ```

  ```sh
  $ sudo rm -rf /home/admin/zram-swap
  ```

* Make sure that the change was done

  ```sh
  $ sudo cat /proc/swaps
  ```

* Expected output:

  ```
  Filename                                Type                Size           Used    Priority
  /var/swap                              file                 102396         0       -2
  ```

<br /><br />

---

<< Back: [+ Bitcoin](index.md)
