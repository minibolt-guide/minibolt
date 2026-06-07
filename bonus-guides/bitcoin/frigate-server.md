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

# Frigate

[Frigate](https://github.com/sparrowwallet/frigate) is an Electrum server for [Silent Payments](https://github.com/bitcoin/bips/blob/master/bip-0352.mediawiki) (BIP352), created by [Craig Raw](https://github.com/craigraw). It performs Silent Payments scanning server-side using ephemeral client keys, returning discovered transactions to wallets over an extension to the Electrum JSON-RPC protocol. All other Electrum requests are forwarded transparently to a co-located backend server such as Fulcrum.

{% hint style="success" %}
Difficulty: Easy
{% endhint %}

<figure><img src="../../.gitbook/assets/frigate-portada.png" alt=""><figcaption></figcaption></figure>

## Requirements

* [Bitcoin Core](../../bitcoin/bitcoin/bitcoin-client.md)
* Electrum server: [Fulcrum](../../bitcoin/bitcoin/electrum-server.md) or [Electrs](../../bonus/bitcoin/electrs.md)
* \~ 18 GB of free storage for the index

## Introduction

#### Silent Payments with your own node

[BIP352 Silent Payments](https://github.com/bitcoin/bips/blob/master/bip-0352.mediawiki) is a privacy protocol that allows receiving Bitcoin to a static, reusable address without leaving a traceable pattern on the blockchain. The recipient address never appears on-chain directly, making coin tracking significantly harder.

The challenge is that discovering incoming payments requires scanning every eligible transaction since the wallet's creation date — a process that demands gigabytes of data and heavy computation, making it impractical for light clients on mobile devices or desktop wallets.

Frigate solves this by moving the scanning to the server, following the [Remote Scanner](https://github.com/silent-payments/BIP0352-index-server-specification/blob/main/README.md#remote-scanner-ephemeral) approach in the BIP352 Index Server Specification: the scan private key and spend public key are provided to Frigate for the duration of the session but are **never stored** — they are held in RAM only, analogous to how a public Electrum server handles ephemeral wallet addresses today.

Frigate indexes the Bitcoin blockchain from Taproot activation (block 709,632 on mainnet) and builds a compact tweak index. Scanning runs in-database via [DuckDB](https://duckdb.org/) with optional GPU acceleration.

Since Fulcrum already occupies the canonical Electrum ports `50001`/`50002` in MiniBolt, Frigate will listen on alternative ports (`50011`/`50012`) and forward all non-Silent-Payments queries to Fulcrum transparently.

## Preparations

{% hint style="warning" %}
Make sure that you have followed the [Bitcoin Core](../../bitcoin/bitcoin/bitcoin-client.md) and Electrum server: [Fulcrum](../../bitcoin/bitcoin/electrum-server.md) or [Electrs](../../bonus/bitcoin/electrs.md) guides before continuing. Frigate requires `txindex=1` in `bitcoin.conf` (already set if you followed the Fulcrum guide) and a running Fulcrum instance as its Electrum backend.
{% endhint %}

### Configure Firewall

* Configure the firewall to allow incoming requests

```sh
sudo ufw allow 50011/tcp comment 'allow Frigate TCP from anywhere'
```

```sh
sudo ufw allow 50012/tcp comment 'allow Frigate SSL from anywhere'
```

### Configure Bitcoin Core

We need to add the ZMQ sequence publisher to the Bitcoin Core configuration file. This is required so that Frigate can ingest mempool transactions with low latency when acting as a proxy in front of Fulcrum.

* Edit `bitcoin.conf` file

```sh
sudo nano /data/bitcoin/bitcoin.conf
```

* Add the following lines to the `"# Connections"` section. Save and exit

```
# Enable ZMQ sequence publisher (for Frigate low-latency mempool ingestion)
zmqpubsequence=tcp://127.0.0.1:28336
```

* Restart Bitcoin Core to apply changes

```sh
sudo systemctl restart bitcoind
```

* Check if Bitcoin Core is publishing the `zmqpubsequence` endpoint on port `28336`

```bash
sudo ss -tulpn | grep ':28336'
```

Expected output:

```
tcp   LISTEN 0      100            127.0.0.1:28336       0.0.0.0:*    users=(("bitcoind",pid=XXXXXXX,fd=XX))
```

## Installation

### Create the frigate user & group

* Create the `frigate` user and group

```bash
sudo adduser --disabled-password --gecos "" frigate
```

* Add `frigate` user to the `bitcoin` group, allowing it to read the bitcoind `.cookie` file

```bash
sudo adduser frigate bitcoin
```

### Create data folder

* Create the Frigate data folder

```sh
sudo mkdir /data/frigate
```

* Assign the owner to the `frigate` user

```sh
sudo chown -R frigate:frigate /data/frigate
```

### Download binaries

* Change to the `frigate` user

```bash
sudo su - frigate
```

* Set a temporary version environment variable for the installation

```sh
VERSION=1.5.3
```

* Download the application, manifest, and signature

{% code overflow="wrap" %}
```bash
wget https://github.com/sparrowwallet/frigate/releases/download/$VERSION/frigate-$VERSION-x86_64.tar.gz
```
{% endcode %}

{% code overflow="wrap" %}
```bash
wget https://github.com/sparrowwallet/frigate/releases/download/$VERSION/frigate-$VERSION-manifest.txt.asc
```
{% endcode %}

{% code overflow="wrap" %}
```bash
wget https://github.com/sparrowwallet/frigate/releases/download/$VERSION/frigate-$VERSION-manifest.txt
```
{% endcode %}

### Signature check

* Get the public key from the Frigate developer

```bash
curl https://keybase.io/craigraw/pgp_keys.asc | gpg --import
```

Expected output:

```
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  5588  100  5588    0     0  12606      0 --:--:-- --:--:-- --:--:-- 12613
gpg: key E94618334C674B40: public key "Craig Raw <craig@sparrowwallet.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
```

* Verify the signature of the manifest file containing the checksums for the application

```sh
gpg --verify frigate-$VERSION-manifest.txt.asc frigate-$VERSION-manifest.txt
```

Expected output:

```
gpg: Signature made sáb 30 may 2026 08:30:31 UTC
gpg:                using RSA key D4D0D3202FC06849A257B38DE94618334C674B40
gpg: Good signature from "Craig Raw <craig@sparrowwallet.com>" [unknown]
gpg: Signature notation: manu=2,2.5+1.12,0,3
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: D4D0 D320 2FC0 6849 A257  B38D E946 1833 4C67 4B40
```

### Checksum check

* Verify the signed checksum against the actual checksum of your download

```sh
sha256sum --check frigate-$VERSION-manifest.txt --ignore-missing
```

**Example** of expected output:

```
frigate-1.5.3-x86_64.tar.gz: OK
```

### Binaries installation

* Extract

{% code overflow="wrap" %}
```bash
tar -xzvf frigate-$VERSION-x86_64.tar.gz
```
{% endcode %}

**Example** of expected output:

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
frigate/
frigate/bin/
frigate/bin/frigate
frigate/bin/frigate-cli
frigate/lib/
frigate/lib/frigate-cli.png
frigate/lib/frigate.png
frigate/lib/libapplauncher.so
frigate/lib/app/
frigate/lib/app/.jpackage.xml
frigate/lib/app/frigate-cli.cfg
frigate/lib/app/frigate.cfg
frigate/lib/runtime/
frigate/lib/runtime/release
frigate/lib/runtime/bin/
frigate/lib/runtime/bin/frigate
frigate/lib/runtime/bin/frigate-cli
frigate/lib/runtime/bin/frigate-cli.bat
frigate/lib/runtime/bin/frigate.bat
frigate/lib/runtime/conf/
frigate/lib/runtime/conf/jaxp-strict.properties.template
frigate/lib/runtime/conf/jaxp.properties
frigate/lib/runtime/conf/logging.properties
frigate/lib/runtime/conf/net.properties
frigate/lib/runtime/conf/sdp/
frigate/lib/runtime/conf/sdp/sdp.conf.template
frigate/lib/runtime/conf/security/
frigate/lib/runtime/conf/security/java.security
frigate/lib/runtime/conf/security/policy/
frigate/lib/runtime/conf/security/policy/README.txt
frigate/lib/runtime/conf/security/policy/limited/
frigate/lib/runtime/conf/security/policy/limited/default_US_export.policy
frigate/lib/runtime/conf/security/policy/limited/default_local.policy
frigate/lib/runtime/conf/security/policy/limited/exempt_local.policy
frigate/lib/runtime/conf/security/policy/unlimited/
frigate/lib/runtime/conf/security/policy/unlimited/default_US_export.policy
frigate/lib/runtime/conf/security/policy/unlimited/default_local.policy
frigate/lib/runtime/legal/
frigate/lib/runtime/legal/java.base/
frigate/lib/runtime/legal/java.base/ADDITIONAL_LICENSE_INFO
frigate/lib/runtime/legal/java.base/ASSEMBLY_EXCEPTION
frigate/lib/runtime/legal/java.base/LICENSE
frigate/lib/runtime/legal/java.base/aes.md
frigate/lib/runtime/legal/java.base/c-libutl.md
frigate/lib/runtime/legal/java.base/cldr.md
frigate/lib/runtime/legal/java.base/icu.md
frigate/lib/runtime/legal/java.base/public_suffix.md
frigate/lib/runtime/legal/java.base/siphash.md
frigate/lib/runtime/legal/java.base/unicode.md
frigate/lib/runtime/legal/java.base/zlib.md
frigate/lib/runtime/legal/java.logging/
frigate/lib/runtime/legal/java.logging/ADDITIONAL_LICENSE_INFO
frigate/lib/runtime/legal/java.logging/ASSEMBLY_EXCEPTION
frigate/lib/runtime/legal/java.logging/LICENSE
frigate/lib/runtime/legal/java.naming/
frigate/lib/runtime/legal/java.naming/ADDITIONAL_LICENSE_INFO
frigate/lib/runtime/legal/java.naming/ASSEMBLY_EXCEPTION
frigate/lib/runtime/legal/java.naming/LICENSE
frigate/lib/runtime/legal/java.security.sasl/
frigate/lib/runtime/legal/java.security.sasl/ADDITIONAL_LICENSE_INFO
frigate/lib/runtime/legal/java.security.sasl/ASSEMBLY_EXCEPTION
frigate/lib/runtime/legal/java.security.sasl/LICENSE
frigate/lib/runtime/legal/java.sql/
frigate/lib/runtime/legal/java.sql/ADDITIONAL_LICENSE_INFO
frigate/lib/runtime/legal/java.sql/ASSEMBLY_EXCEPTION
frigate/lib/runtime/legal/java.sql/LICENSE
frigate/lib/runtime/legal/java.transaction.xa/
frigate/lib/runtime/legal/java.transaction.xa/ADDITIONAL_LICENSE_INFO
frigate/lib/runtime/legal/java.transaction.xa/ASSEMBLY_EXCEPTION
frigate/lib/runtime/legal/java.transaction.xa/LICENSE
frigate/lib/runtime/legal/java.xml/
frigate/lib/runtime/legal/java.xml/ADDITIONAL_LICENSE_INFO
frigate/lib/runtime/legal/java.xml/ASSEMBLY_EXCEPTION
frigate/lib/runtime/legal/java.xml/LICENSE
frigate/lib/runtime/legal/java.xml/bcel.md
frigate/lib/runtime/legal/java.xml/dom.md
frigate/lib/runtime/legal/java.xml/jcup.md
frigate/lib/runtime/legal/java.xml/schema10part1.md
frigate/lib/runtime/legal/java.xml/schema10part2.md
frigate/lib/runtime/legal/java.xml/xalan.md
frigate/lib/runtime/legal/java.xml/xerces.md
frigate/lib/runtime/legal/java.xml/xhtml10.md
frigate/lib/runtime/legal/java.xml/xhtml10schema.md
frigate/lib/runtime/legal/java.xml/xhtml11.md
frigate/lib/runtime/legal/java.xml/xhtml11schema.md
frigate/lib/runtime/legal/java.xml/xmlspec.md
frigate/lib/runtime/legal/java.xml/xmlxsd.md
frigate/lib/runtime/lib/
frigate/lib/runtime/lib/classlist
frigate/lib/runtime/lib/jexec
frigate/lib/runtime/lib/jrt-fs.jar
frigate/lib/runtime/lib/jspawnhelper
frigate/lib/runtime/lib/jvm.cfg
frigate/lib/runtime/lib/libjava.so
frigate/lib/runtime/lib/libjimage.so
frigate/lib/runtime/lib/libjli.so
frigate/lib/runtime/lib/libjsig.so
frigate/lib/runtime/lib/libnet.so
frigate/lib/runtime/lib/libnio.so
frigate/lib/runtime/lib/libsimdsort.so
frigate/lib/runtime/lib/libsyslookup.so
frigate/lib/runtime/lib/libverify.so
frigate/lib/runtime/lib/libzip.so
frigate/lib/runtime/lib/modules
frigate/lib/runtime/lib/tzdb.dat
frigate/lib/runtime/lib/security/
frigate/lib/runtime/lib/security/blocked.certs
frigate/lib/runtime/lib/security/cacerts
frigate/lib/runtime/lib/security/public_suffix_list.dat
frigate/lib/runtime/lib/server/
frigate/lib/runtime/lib/server/libjsig.so
frigate/lib/runtime/lib/server/libjvm.so

```

</details>

* Check the correct installation by requesting the output of the version:

```sh
frigate/bin/frigate --version
```

**Example** of expected output:

```
Frigate 1.5.3
```

* **(Optional)** Delete the installation files:

{% code overflow="wrap" %}
```bash
rm frigate-$VERSION-x86_64.tar.gz frigate-$VERSION-manifest.txt.asc frigate-$VERSION-manifest.txt
```
{% endcode %}

{% hint style="info" %}
If you come to update, this is the final step. Go back to the [Upgrade section](frigate-server.md#upgrade) to continue.
{% endhint %}

## Configuration

Frigate listens on ports `50011` (TCP) and `50012` (SSL) to avoid conflicts with Fulcrum, which already occupies the canonical Electrum ports `50001`/`50002`. Silent Payments-capable wallets connect to Frigate; all other Electrum requests are automatically proxied to Fulcrum on `50001` without any extra configuration in your existing wallets.

* Create a Frigate configuration file

```sh
nano /data/frigate/config.toml
```

* Enter the following content. Save and exit

{% hint style="warning" %}
Remember to accommodate the `memoryLimit` parameter depending on your hardware. DuckDB defaults to 80 % of system RAM; cap it on machines with less than 16 GB.
{% endhint %}

{% hint style="info" %}
If you want to save disk space and make indexing much faster, you can use block `950356` as the starting point by setting it in the "startHeight" value of the config.toml file. This is the block from which silent payments were launched in Sparrow Wallet. Before that, the use of Silent Payments was barely widespread.
{% endhint %}

```toml
# MiniBolt: Frigate configuration
# /data/frigate/config.toml

[core]
connect = true
server = "http://127.0.0.1:8332"
authType = "COOKIE"
dataDir = "/data/bitcoin"
zmqSequenceEndpoint = "tcp://127.0.0.1:28336"

[index]
# startHeight = 709632
# cacheSize = "10M"

[scan]
computeBackend = "AUTO"
# dbThreads = 4
# memoryLimit = "8GB"

[server]
tcp = "tcp://0.0.0.0:50011"
ssl = "ssl://0.0.0.0:50012"
sslCert = "cert.pem"
sslKey  = "key.pem"
backendElectrumServer = "tcp://localhost:50001"
```

* Generate cert and key files for SSL

{% code overflow="wrap" %}
```bash
openssl req -x509 -newkey rsa:2048 -keyout /data/frigate/key.pem -out /data/frigate/cert.pem -days 3650 -nodes -subj "/CN=localhost"
```
{% endcode %}

Expected output:

```
Generating a RSA private key
....................+++++
..................................+++++
writing new private key to 'key.pem'
-----
```

* Exit the `frigate` user session to return to the "admin" user session

```sh
exit
```

### Create systemd service

* As user `admin`, create the Frigate systemd unit

```sh
sudo nano /etc/systemd/system/frigate.service
```

* Enter the following complete configuration. Save and exit

```
# MiniBolt: systemd unit for Frigate
# /etc/systemd/system/frigate.service

[Unit]
Description=Frigate Electrum Server
Requires=bitcoind.service fulcrum.service
After=bitcoind.service fulcrum.service

StartLimitBurst=2
StartLimitIntervalSec=20

[Service]
ExecStart=/home/frigate/frigate/bin/frigate -d /data/frigate

User=frigate
Group=frigate

# Process management
####################
Type=simple
KillSignal=SIGINT
TimeoutStopSec=300

[Install]
WantedBy=multi-user.target
```

* Enable autoboot **(optional)**

```sh
sudo systemctl enable frigate
```

* Prepare "frigate" monitoring by the systemd journal and check the log output. You can exit monitoring at any time with `Ctrl-C`

```sh
journalctl -fu frigate
```

## Run

To keep an eye on the software movements, [start your SSH program](../../index-1/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as "admin"

* Start the service

```sh
sudo systemctl start frigate
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>journalctl -fu frigate</code> ⬇️</summary>

```
[...] systemd[1]: Started Frigate Electrum Server.
[...] INFO Using configured Frigate home folder of /data/frigate
[...] INFO Starting Frigate v1.5.3 on mainnet
[...] INFO Using home directory /data/frigate
[...] INFO Using CPU backend for scanning (no GPU detected)
[...] INFO Using home directory /data/frigate
[...] INFO Indexing progress: 99 / 242998 blocks (0.0%, height 709730)
[...] INFO Indexing progress: 199 / 242998 blocks (0.1%, height 709830)
[...]
```

</details>

{% hint style="info" %}
> Frigate must first fully index the blockchain from Taproot activation (block 709,632 on mainnet) up to the chain tip before it can serve Silent Payments queries. This process takes several hours depending on your hardware, config selected values and Bitcoin Core RPC throughput. Watch the log for `Electrum server listening on tcp://...` — that is the readiness signal.

> Once indexed, Frigate will serve Silent Payments requests natively and proxy all other Electrum queries to Fulcrum transparently. Wallets that do not use Silent Payments can keep connecting to Fulcrum on `50001`/`50002` as before.
{% endhint %}

{% hint style="warning" %}
DO NOT REBOOT OR STOP THE SERVICE DURING THE INITIAL INDEXING PROCESS. Although DuckDB is resilient to unclean shutdowns, an interrupted first sync may require a full rebuild. If corruption occurs, start from scratch by deleting the database contents and following the next steps:

* With user `admin`, stop `frigate`

```bash
sudo systemctl stop frigate
```

* Delete the database folder contents

```bash
sudo rm -rf /data/frigate/db/
```

* Start Frigate again

```bash
sudo systemctl start frigate
```

-> You should see the logs of the [Run process](frigate-server.md#run) again

-> The troubleshooting note could be helpful after experiencing **data corruption due to a power outage** during normal operation
{% endhint %}

* When you see logs like this — `Electrum server listening on tcp://...` — Frigate is fully indexed and ready to serve Silent Payments queries.

### Validation

* Ensure the service is working and listening at the `50011` & `50012` ports

```sh
sudo ss -tulpn | grep frigate
```

Expected output:

```
tcp   LISTEN 0      50        0.0.0.0:50011      0.0.0.0:*    users=(("frigate",pid=XXXX,fd=XXX))
tcp   LISTEN 0      50        0.0.0.0:50012      0.0.0.0:*    users=(("frigate",pid=XXXX,fd=XXX))
```

{% hint style="success" %}
Congrats! You now have a Silent Payments Electrum server running on your node. Connect your Silent Payments-capable wallet (e.g., [Sparrow Wallet](../../bitcoin/bitcoin/desktop-signing-app-sparrow.md)) to port `50011` (TCP) or `50012` (SSL) to start scanning for BIP352 transactions. Your existing wallets can continue using Fulcrum on `50001`/`50002` without any changes.
{% endhint %}

## Extras (optional)

### Remote access over Tor

* With the user `admin`, edit the `torrc` file

```sh
sudo nano +63 /etc/tor/torrc --linenumbers
```

* Add the following lines in the "location hidden services" section, below `## This section is just for location-hidden services ##` in the torrc file. Save and exit

```
# Hidden Service Frigate TCP & SSL
HiddenServiceDir /var/lib/tor/hidden_service_frigate_tcp_ssl/
HiddenServiceEnableIntroDoSDefense 1
HiddenServicePoWDefensesEnabled 1
HiddenServicePort 50011 127.0.0.1:50011
HiddenServicePort 50012 127.0.0.1:50012
```

* Reload the Tor configuration to apply changes

```sh
sudo systemctl reload tor
```

* Get your Onion address

```sh
sudo cat /var/lib/tor/hidden_service_frigate_tcp_ssl/hostname
```

**Example** of expected output:

```
abcdefg..............xyz.onion
```

* You should now be able to connect to your Frigate server remotely via Tor using your hostname and port `50011` (TCP) or `50012` (SSL)

## Upgrade

Follow the [Installation section](frigate-server.md#installation) from [Download binaries](frigate-server.md#download-binaries) (included) until the [Binaries installation section](frigate-server.md#binaries-installation) (included), replacing the environment variable `"VERSION=x.xx"` value for the latest if it has not already been changed in this guide.

* Restart the service to apply the changes

```sh
sudo systemctl restart frigate
```

* Check logs and pay attention to the next log if it refers to the new version installed

```sh
journalctl -fu frigate
```

**Example** of expected output:

```
[...]
[...] Started Frigate Electrum Server.
[...]
```

## Uninstall

{% hint style="danger" %}
Warning: This section removes the installation. Only run these commands if you intend to uninstall
{% endhint %}

### Uninstall service

* Ensure you are logged in as the user `admin`, stop Frigate

```sh
sudo systemctl stop frigate
```

* Disable autoboot (if enabled)

```sh
sudo systemctl disable frigate
```

* Delete the service

```sh
sudo rm /etc/systemd/system/frigate.service
```

### Delete user & group

* Delete the frigate user. Don't worry about `userdel: frigate mail spool (/var/mail/frigate) not found` output, the uninstall has been successful

```sh
sudo userdel -rf frigate
```

### Delete data directory

* Delete Frigate directory

```sh
sudo rm -rf /data/frigate
```

### Uninstall Tor hidden service

* Ensure that you are logged in as the user `admin` and delete or comment the following lines in the "location hidden services" section, below `## This section is just for location-hidden services ##` in the torrc file. Save and exit

```sh
sudo nano +63 /etc/tor/torrc --linenumbers
```

```
# Hidden Service Frigate TCP & SSL
#HiddenServiceDir /var/lib/tor/hidden_service_frigate_tcp_ssl/
#HiddenServiceEnableIntroDoSDefense 1
#HiddenServicePoWDefensesEnabled 1
#HiddenServicePort 50011 127.0.0.1:50011
#HiddenServicePort 50012 127.0.0.1:50012
```

* Reload the torrc config

```sh
sudo systemctl reload tor
```

### Uninstall FW configuration

* Ensure you are logged in as the user `admin`, display the UFW firewall rules, and note the numbers of the rules for Frigate (e.g., X and Y below)

```sh
sudo ufw status numbered
```

Expected output:

```
[X] 50011       ALLOW IN    Anywhere          # allow Frigate TCP from anywhere
[Y] 50012       ALLOW IN    Anywhere          # allow Frigate SSL from anywhere
```

* Delete the rules with the correct numbers and confirm with "`yes`"

```sh
sudo ufw delete X
```

```sh
sudo ufw delete Y
```

## Port reference

|  Port | Protocol |    Use   |
| :---: | -------- | :------: |
| 50011 | TCP      | TCP port |
| 50012 | SSL      | SSL port |
