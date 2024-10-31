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

# MiniBolt on Testnet

You can run your MiniBolt node on **Testnet4** to develop and experiment with new applications, without putting real money at risk. This bonus guide highlights all configuration changes compared to the main guide.

{% hint style="warning" %}
Difficulty: Medium
{% endhint %}

<figure><img src="../../.gitbook/assets/bitcoin-testnet.PNG" alt=""><figcaption></figcaption></figure>

## Introduction

Running a testnet node is a great way to get acquainted with the MiniBolt and the suite of Bitcoin-related software typical of these powerful setups. Moreover, testnet empowers users to tinker with the software and its many configurations without the threat of losing funds. Helping Bitcoiners run a full testnet setup is a goal worthy of the MiniBolt, and this page should provide you with the knowledge to get there.

The great news is that most of the MiniBolt guide can be used as-is. The small adjustments come in the form of changes to the config files and ports for testnet. You can follow the guide and replace the following configurations in the right places as you go.

{% hint style="info" %}
> <mark style="color:red;">**Advice:**</mark>
>
> For the moment, this guide will touch only the case of simultaneous mode situation for Bitcoin Core, in the future, we will study adding the case of configuration to enable the parallel/simultaneous mode (`mainnet+testnet` in the same device)

> The services mentioned in this guide are those that have been tested using testnet configuration and these worked fine. Later, in the next versions of this guide, we will go to adding other process to adapt other services to the testnet mode
{% endhint %}

## Bitcoin

### [Bitcoin client: Bitcoin Core](../../bitcoin/bitcoin/bitcoin-client.md) (mainnet + testnet simultaneous mode)

* Follow the complete MiniBolt guide from the beginning [(Bitcoin client included)](../../bitcoin/bitcoin/bitcoin-client.md), when you arrive at the ["Configuration section"](../../bitcoin/bitcoin/bitcoin-client.md#configuration)

```bash
nano /home/bitcoin/.bitcoin/bitcoin-testnet4.conf
```

* Stay tuned to replace and add the next lines on the `bitcoin.conf` file

```
## Replace the parameter
uacomment=MiniBolt Testnet4 node

## Add the parameter
testnet4=1

## Delete the parameter
bind=127.0.0.1

## Add the next 2 lines at the end of the file
[testnet4]
bind=127.0.0.1
```

* When you finish the [Run](../../bitcoin/bitcoin/bitcoin-client.md#run) section, with the user `admin` provide read and execute permissions to the Bitcoin group for the testnet folder

```bash
sudo chmod g+rx /data/bitcoin/testnet4
```

{% hint style="warning" %}
**Attention:** the step before is critical to allow the Bitcoin Core dependencies to access the `.cookie` file and startup without problems
{% endhint %}

* When you arrive at the [Create systemd service](../../bitcoin/bitcoin/bitcoin-client.md#create-systemd-service), create a new systemd file configuration for Testnet4

```bash
sudo nano /etc/systemd/system/bitcoind-testnet4.service
```

* Include this content

```
# MiniBolt: systemd unit for bitcoind
# /etc/systemd/system/bitcoind-testnet4.service

[Unit]
Description=Bitcoin Core Daemon (Testnet4)
Requires=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/local/bin/bitcoind -pid=/run/bitcoind/bitcoind-testnet4.pid \
                                  -conf=/home/bitcoin/.bitcoin/bitcoin-testnet4.conf \
                                  -datadir=/home/bitcoin/.bitcoin \
                                  -startupnotify='systemd-notify --ready' \
                                  -shutdownnotify='systemd-notify --status="Stopping"'
# Process management
####################
Type=notify
NotifyAccess=all
PIDFile=/run/bitcoind/bitcoind-testnet4.pid

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

```bash
sudo systemctl enable bitcoind-testnet4
```

* Prepare “bitcoind” monitoring by the systemd journal and check the logging output. You can exit monitoring at any time with Ctrl-C

```bash
journalctl -fu bitcoind-testnet4
```

* When you arrive at the [Run](../../bitcoin/bitcoin/bitcoin-client.md#run) section, start the service with this

```bash
sudo systemctl start bitcoind-testnet4
```

{% hint style="info" %}
Use the flag `--testnet4` when you use the `bitcoin-cli` commands, e.g `bitcoin-cli --testnet4 -netinfo`
{% endhint %}

{% hint style="success" %}
The rest of the Bitcoin client guide is the same as the mainnet mode
{% endhint %}

### [Electrum server: Fulcrum](../../bitcoin/bitcoin/electrum-server.md) (only testnet mode)

Follow the complete Electrum server guide from the beginning, when you arrive at the ["Configure Firewall"](../../bitcoin/bitcoin/electrum-server.md#configure-firewall) section:

[Configure Firewall](../../bitcoin/bitcoin/electrum-server.md#configure-firewall)

* Replace the next lines to 40001/40002 ports, to match with the Testnet mode

```sh
sudo ufw allow 40001/tcp comment 'allow Fulcrum Testnet4 TCP from anywhere'
```

```sh
sudo ufw allow 40002/tcp comment 'allow Fulcrum Testnet4 SSL from anywhere'
```

* When you arrive at the ["Data directory"](../../bitcoin/bitcoin/electrum-server.md#data-directory) section, on the..."Download the custom Fulcrum banner based on MiniBolt ..." step, d\_ownload the Fulcrum testnet banner instead of the mainnet banner

{% code overflow="wrap" %}
```bash
wget https://raw.githubusercontent.com/minibolt-guide/minibolt/main/resources/fulcrum-banner-testnet4.txt
```
{% endcode %}

[Configuration](../../bitcoin/bitcoin/electrum-server.md#configuration)

* In the next [Configuration](../../bitcoin/bitcoin/electrum-server.md#configuration) step, stay tuned to **replace** the next lines on the `fulcrum.conf` file, to match with the testnet mode

```sh
nano /data/fulcrum/fulcrum.conf
```

```
# Bitcoin Core settings
bitcoind = 127.0.0.1:48332
rpccookie = /data/bitcoin/testnet4/.cookie

# Fulcrum server general settings
ssl = 0.0.0.0:40002
tcp = 0.0.0.0:40001

# Banner
banner = /data/fulcrum/fulcrum-banner-testnet4.txt
```

&#x20;[Create systemd service](../../bitcoin/bitcoin/electrum-server.md#create-systemd-service)

* When you arrive at the [Create systemd service](../../bitcoin/bitcoin/electrum-server.md#create-systemd-service) section, stay tuned to replace the next lines on the `fulcrum.service` file, to match the Bitcoin Core on Testnet mode dependency. Save and exit

```bash
sudo nano +6 -l /etc/systemd/system/fulcrum.service
```

```
Requires=bitcoind-testnet4.service
After=bitcoind-testnet4.service
```

[Remote access over Tor](../../bitcoin/bitcoin/electrum-server.md#remote-access-over-tor)

* When you arrive at the[ remote access over the Tor section](../../bitcoin/bitcoin/electrum-server.md#remote-access-over-tor), edit the torrc file

```sh
sudo nano +63 -l /etc/tor/torrc
```

* Replace ports to 40001/40002 to match with testnet mode

```
############### This section is just for location-hidden services ###
# Hidden Service Fulcrum Testnet4 TCP & SSL
HiddenServiceDir /var/lib/tor/hidden_service_fulcrum_testnet4_tcp_ssl/
HiddenServiceVersion 3
HiddenServicePoWDefensesEnabled 1
HiddenServicePort 40001 127.0.0.1:40001
HiddenServicePort 40002 127.0.0.1:40002
```

* Reload the Tor configuration

```sh
sudo systemctl reload tor
```

* Get your connection addresses

```sh
sudo cat /var/lib/tor/hidden_service_fulcrum_testnet4_tcp_ssl/hostname
```

**Example** of expected output:

```
abcdefg..............xyz.onion
```

{% hint style="info" %}
You should now be able to connect to your Fulcrum server remotely via Tor using your hostname and port 40001 (TCP) or 40002 (SSL)
{% endhint %}

{% hint style="success" %}
The rest of the **Fulcrum** guide is the same as the mainnet mode
{% endhint %}

### [Blockchain Explorer: BTC RPC Explorer](../../bitcoin/bitcoin/blockchain-explorer.md) (not Testnet4 compatible)

{% hint style="danger" %}
#### Not Testnet4 compatible yet, the next steps are not valid!
{% endhint %}

* Follow the complete guide from the beginning, when you arrive at the [Configuration section](../../bitcoin/bitcoin/blockchain-explorer.md#configuration), set the next lines with the next values instead of the existing ones for mainnet. Edit **`.env`** file

```sh
nano /home/btcrpcexplorer/btc-rpc-explorer/.env
```

```
BTCEXP_BITCOIND_PORT=18332
BTCEXP_BITCOIND_COOKIE=/data/bitcoin/testnet3/.cookie
BTCEXP_ELECTRUM_SERVERS=tcp://127.0.0.1:60001
```

{% hint style="success" %}
The rest of the **BTC RPC Explorer** guide is the same as the mainnet mode
{% endhint %}

## Lightning

### [Lightning client: LND](../../lightning/lightning-client.md)

{% hint style="danger" %}
#### Not Testnet4 compatible yet, the next steps are not valid!
{% endhint %}

* Follow the complete guide from the beginning, when you arrive at the [Configur](../../lightning/lightning-client.md#configuration)[ation](../../lightning/lightning-client.md#configuration) section, edit `lnd.conf`

```bash
nano /data/lnd/lnd.conf
```

* Replace the parameter `bitcoin.mainnet=true` with the `bitcoin.testnet=true` to enable LND in testnet mode and add the location of the `bitcoin-testnet3.conf` in the `[Bitcoind]` section

```
[Bitcoin]
bitcoin.testnet=true

[Bitcoind]
bitcoind.config=/data/bitcoin/bitcoin-testnet3.conf
```

{% hint style="info" %}
If you use [Ordirespector](ordisrespector.md) on testnet, add the next lines at the end of the file:
{% endhint %}

```
[fee]
# Use external fee estimator
fee.url=https://nodes.lightning.computer/fees/v1/btctestnet-fee-estimates.json
```

* When you arrive at the [Create systemd service](../../lightning/lightning-client.md#create-systemd-service) section, edit the `lnd.service` file and replace `ExecStop` parameter to this

```
ExecStop=/usr/local/bin/lncli --network=testnet stop
```

{% hint style="info" %}
When you arrive at the [Watchtower client](../../lightning/lightning-client.md#watchtower-client-recommended) section, keep in mind that the Watchtower server suggested won't work with the LND testnet, same with the LND mainnet peer suggested to open the channel and send a payment
{% endhint %}

**Interacting with the LND daemon**

* Note that when interacting with the LND daemon, you'll need to use the `"--network testnet"` flag. Example:

```sh
lncli --network=testnet --tlscertpath /data/lnd/tls.cert.tmp create
```

{% hint style="info" %}
Note that it has [a list of testnet aliases](https://raw.githubusercontent.com/minibolt-guide/minibolt/main/resources/.bash\_aliases) related to these commonly used commands to make it easier to introduce in the terminal. Follow the ["Aliases bonus guide"](../system/aliases.md) to install it
{% endhint %}

{% hint style="success" %}
The rest of the **Lightning Clien**t guide is the same as the mainnet mode
{% endhint %}

### [Channel backup](../../lightning/channel-backup.md)

{% hint style="danger" %}
#### Not Testnet4 compatible yet, the next steps are not valid!
{% endhint %}

* Follow the complete guide from the beginning, when you arrive at the ["Create script"](../../lightning/channel-backup.md#create-script) section, create the script

```sh
sudo nano /usr/local/bin/scb-backup --linenumbers
```

* Replace the `line 18` in the script to match with the testnet path

```
SCB_SOURCE_FILE="/data/lnd/data/chain/bitcoin/testnet/channel.backup"
```

{% hint style="info" %}
**If you have a mainnet node running on another device** and you want to use the same GitHub account for the testnet channel backups:

* Change this line on the script to this for example: `REMOTE_BACKUP_DIR="/data/lnd/remote-lnd-testnet-backup"`
* When you arrive at the ["Create a GitHub repository"](../../lightning/channel-backup.md#create-a-github-repository) section, change the name of the GitHub repo to for example: "`remote-lnd-testnet-backup"`
* When you arrive at the ["Clone the repository to your node"](../../lightning/channel-backup.md#clone-the-repository-to-your-node) section, replace the command with: `git clone git@github.com:<YourGitHubUsername>/remote-lnd-testnet-backup.git`
* When you arrive at the ["GitHub test"](../../lightning/channel-backup.md#github-test) section, replace the command to: `cd remote-lnd-testnet-backup`
{% endhint %}

{% hint style="success" %}
The rest of the **Channel Backup guide** is the same as the mainnet mode
{% endhint %}

### [Web app: ThunderHub](../../lightning/web-app.md)

{% hint style="danger" %}
#### Not Testnet4 compatible, the next steps are not valid!
{% endhint %}

* Follow the complete guide from the beginning, when you arrive at the [Configuration](../../lightning/web-app.md#configuration) section, replace the next parameter to match with the testnet mode on the `.env.local` file

```
MEMPOOL_URL='https://mempool.space/testnet'
```

* And replace the next parameter on the `thubConfig.yaml` file

```
macaroonPath: /data/lnd/data/chain/bitcoin/testnet/admin.macaroon
```

{% hint style="success" %}
The rest of the **Web app: Thunderhub** is the same as the mainnet mode
{% endhint %}

### [Mobile app: Zeus](../../lightning/mobile-app.md)

{% hint style="danger" %}
#### Not Testnet4 compatible yet, the next steps are not valid!
{% endhint %}

* Follow the complete guide from the beginning, when you arrive at the [**Create a lndconnect QR code**](../../lightning/mobile-app.md#create-a-lndconnect-qr-code) section, modify the "lndconnect" command to match with the next

For **example**, to generate a QR code for a Wireguard VPN connection, enter this command:

{% code overflow="wrap" %}
```sh
lndconnect --host=10.0.1.1 --port=8080 --bitcoin.testnet --adminmacaroonpath=/home/admin/.lnd/data/chain/bitcoin/testnet/admin.macaroon --nocert
```
{% endcode %}

{% hint style="info" %}
Be careful to add `--nocert` parameter only to the onion and Wireguard VPN network, the local network could be shared with more devices and you should use a valid certificate to encrypt the connection, so don't add that parameter in this case
{% endhint %}

## Bonus section

### Bitcoin: [Electrs](electrs.md) (only testnet mode)

{% hint style="danger" %}
#### Not Testnet4 compatible yet, the next steps are not valid!
{% endhint %}

Follow the complete guide from the beginning, when you arrive at the [Reverse proxy & Firewall](electrs.md#reverse-proxy-and-firewall) section, follow the next steps:

* Create the `electrs-reverse-proxy.conf` file

```sh
sudo nano /etc/nginx/streams-enabled/electrs-reverse-proxy.conf
```

* Replace the mainnet ports `50021/50022` with the `40021/40022` testnet4 ports

```nginx
upstream electrs {
  server 127.0.0.1:40021;
}
server {
  listen 40022 ssl;
  proxy_pass electrs;
}
```

* Test and reload Nginx configuration

```sh
sudo nginx -t
```

```bash
sudo systemctl reload nginx
```

* Configure the Firewall to allow incoming requests

```sh
sudo ufw allow 40022/tcp comment 'allow Electrs Testnet4 SSL from anywhere'
```

```sh
sudo ufw allow 40021/tcp comment 'allow Electrs Testnet4 TCP from anywhere'
```

[Configuration](electrs.md#configuration)

* When you arrive at the [Configuration](electrs.md#configuration) section, replace it with the next lines

```sh
nano /data/electrs/electrs.conf
```

<pre><code># MiniBolt: electrs testnet4 configuration
# /data/electrs/electrs.conf

# Bitcoin Core settings
<strong>network = "testnet4"
</strong>cookie_file = "/data/bitcoin/testnet4/.cookie"

# Electrs settings
electrum_rpc_addr = "0.0.0.0:40021"
server_banner = "Welcome to electrs (Electrum Rust Server) running on a MiniBolt node Testnet4!"
</code></pre>

[Remote access over Tor](electrs.md#remote-access-over-tor-optional)

* When you arrive at the [Remote access over Tor](electrs.md#remote-access-over-tor-optional) section

```sh
sudo nano +63 /etc/tor/torrc
```

* Edit the torrc file and replace ports to `40021/40022` to match with testnet4 mode

```
# Hidden Service Electrs Testnet4 TCP & SSL
HiddenServiceDir /var/lib/tor/hidden_service_electrs_testnet4_tcp_ssl/
HiddenServiceVersion 3
HiddenServicePoWDefensesEnabled 1
HiddenServicePort 40021 127.0.0.1:40021
HiddenServicePort 40022 127.0.0.1:40022
```

* Reload the Tor configuration and get your connection addresses

```sh
sudo systemctl reload tor
```

```sh
sudo cat /var/lib/tor/hidden_service_electrs_testnet4_tcp_ssl/hostname
```

**Example** of expected output:

```
abcdefg..............xyz.onion
```

{% hint style="success" %}
The rest of the **Electrs guide** is the same as the mainnet mode
{% endhint %}

## Port reference

Here we are going to describe only what ports differ from the mainnet mode:

|  Port |  Protocol |                   Use                  |
| :---: | :-------: | :------------------------------------: |
| 48333 |    TCP    |            P2P Testnet4 port           |
| 48334 |    TCP    |       P2P Testnet4 secondary port      |
| 48332 |    TCP    |            RPC Testnet4 port           |
| 40001 |    TCP    |          Fulcrum Testnet4 port         |
| 40002 | TCP (SSL) | Fulcrum server Testnet4 encrypted port |
| 40021 |    TCP    |          Electrs Testnet4 port         |
| 40022 | TCP (SSL) | Electrs server Testnet4 encrypted port |
