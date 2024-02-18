---
title: Desktop wallet
nav_order: 30
parent: Bitcoin
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

# 2.4 Desktop wallet: Sparrow wallet

We install [Sparrow wallet](https://github.com/sparrowwallet/sparrow) on a computer and connect it to your Electrum server on your node for private Bitcoin on-chain transactions.

![](../images/sparrow.png)

## Requirements

* [Bitcoin Core](../index-2/bitcoin-client.md)
* Electrum server: [Fulcrum](electrum-server.md) or [Electrs](../bonus/bitcoin/electrs.md)

## Introduction

Sparrow wallet is an excellent software wallet to use with your MiniBolt: it's reliable and transparently shows what it's doing under the hood.

You can also use the following alternatives instead of Sparrow Wallet, according to your preferences and needs:

* BitBoxApp: wallet for users of BitBox hardware wallets
* [Electrum Wallet Desktop](../bonus/bitcoin/electrum-wallet-desktop.md): a well-established poweruser wallet
* [Ledger Live](https://support.ledger.com/hc/en-us/articles/360017551659-Setting-up-your-Bitcoin-full-node?docs=true): wallet for users of Ledger hardware wallets (this wallet connects directly to Bitcoin Core)
* [Trezor Suite](https://blog.trezor.io/connecting-your-wallet-to-a-full-node-edf56693b545?gi=d1e285f3d3c5): wallet for users of Trezor hardware wallets

We will connect Sparrow wallet to our own Electrum server as it is the most private option. For more information about the privacy and security trade-offs of the various server connection options, read the following [article](https://www.sparrowwallet.com/docs/best-practices.html) by Craig Raw, the author of the wallet.

![](../images/sparrow-stages.png)

We will set up Sparrow to connect to Fulcrum within your local network. There is also an optional section at the end that explains how to connect Sparrow to Fulcrum using Tor for when you're on the move.

Sparrow also connects to a couple of external services to get the Bitcoin price and communicate with the Whirlpool server during CoinJoin operations. By default, it uses clearnet which leaks your computer IP address to these services and degrades your privacy. However, Sparrow can also connect to them using a Tor proxy. There is an optional section at the end that explains how to set this proxy up.

## Installation

On your local computer, download, verify, and install Sparrow wallet.

* [Using the instructions on this page](https://www.sparrowwallet.com/download/)
  * Download the required version for your OS
  * Download the manifest and manifest signature files
  * Verify the release
  * Install Sparrow wallet

## Local connection

We now configure Sparrow to connect to your node within your local network.

### Launch Sparrow

* Launch Sparrow
* Read carefully the introductory messages and click on "Next" several times
* When you reach the "Connecting to a Private Electrum Server" message, click on "Configure Server"

### Connect to Fulcrum

* Click on the "Private Electrum" tab
* On the "URL" line, paste `minibolt.local` or your node IP (e.g., `192.168.X.XXX`) in the first box and `50002` in the second box
* Enable SSL by clicking on the slider
* Click on "Test Connection". A green tick should appear on the button and you should see something similar to the following output:

```
> Connected to Fulcrum x.x.x on protocol version...
> [...]
```

![](../images/sparrow-electrum-no-proxy.png)

If there is a connection error message, try the following troubleshooting:

* Make sure that your computer is not connected to any "guest" WiFi network at home. A "guest" WiFi network prevents the computer from connecting to any other devices on the local network, such as your node.
* If you have used Sparrow wallet before on this computer, try to connect again after deleting the existing certificates that are stored within the `certs` folder:
  * On Windows: `C:\Users\<username>\AppData\Roaming\Sparrow\certs`
  * On macOS: `~/.sparrow/certs`
  * On Linux: `~/.sparrow/certs`

Let's go back to the wallet and check that it is connected to our own Electrum server.

* Close the server configuration window
* Check the icon in the bottom right corner of the wallet window ![status icon](../images/sparrow-server-icon.png)
  * The icon should be a blue slider button and a mouse over should display "Connected to \[...] at height \[...]"

You're set! Sparrow is now configured to connect to your Electrum server from within your local network.

For maximal privacy, we highly recommend that you set up the Tor proxy when using Sparrow within your local network over clearnet. Check the [optional section](desktop-wallet.md#optional-set-up-a-tor-proxy-for-external-services) at the end of this guide.

## Sparrow in action

Congratulations, you have now a Bitcoin desktop wallet, capable of securing your Bitcoin, running with your own trustless Bitcoin full node! Sparrow is a powerful wallet that allows you to use the most advanced features for securing your bitcoins and preserving your privacy.

With Sparrow, you can:

* Connect any hardware wallet
* Send and receive bitcoins
* Have full control throughout the transaction creation and signing process: coin control, PSBT, labeling, byte level transaction viewer...
* Create batched transactions to save on miner fees
* Create multisig wallets for improved security
* Coinjoin your coins for improved privacy
* Analyze your transactions with the built-in blockchain explorer

For more information, tutorials, and support, visit the [Sparrow documentation webpage](https://sparrowwallet.com/docs/) and their [Telegram group](https://t.me/sparrowwallet).

### (Optional) Remote connection over Tor

If you want to use Sparrow outside your home network, when you're on the go, you can use a connection over Tor.

### Server Tor address

To connect via Tor to Fulcrum, the server must have a Tor hidden service connection address. Make sure you have set up a Tor hidden service as explained in the ["Electrum server" guide](electrum-server.md#remote-access-over-tor).

If you've already set up the hidden service but lost the connection address, you can obtain it again by running the following command with "admin" on your node:

```sh
$ sudo cat /var/lib/tor/hidden_service_fulcrum_tcp_ssl/hostname
```

Expected output:

```
> abcd...1234.onion
```

### Sparrow configuration

* Open Sparrow
* Navigate to the server configuration page by hitting `Ctrl`+`P`, or `Cmd`+`,` on OSX, then click on "Server"
* Click on the "Private Electrum" tab. If you've already had an existing clearnet connection, click on "Edit Existing Connection".
* On the "URL" line, paste your Tor hidden service connection address (e.g. "abcd...1234.onion") in the first box and `50002` in the second box
* Enable SSL by clicking on the slider
* Click on "Test Connection". A green tick should appear on the button and you should see something similar to the following output:

```
> Connected to Fulcrum x.x.x on protocol version ...
> [...]
```

![](../images/sparrow-electrum-tor-no-proxy.png)

You're set! Sparrow is now configured to connect to your node over Tor and you can use it wherever you are.

### (Optional) Set up a Tor proxy for external services

If a Tor proxy is configured in Sparrow, all external connections use Tor. This includes rate fetching, coinjoin, etc - even transaction broadcasting is then done via an external service (like blockstream.info) over Tor for additional privacy. Where-ever possible, the onion URLs of these services are used.

Sparrow can be configured to use an internal (bundled) or external Tor proxy. To use the internal proxy, an onion Electrum server URL must be specified, and the 'Use Proxy' toggle must be off. Therefore, the following section only applies if you connect to your Electrum server using the local IP address within your local network (e.g., `minibolt.local` or `192.168.X.XXX`). If you're using a Tor onion address to connect to your node, then Sparrow is already using the internal proxy and there is nothing else to be done!

If you're using a local connection, we recommend that you set up this external Tor proxy as described below for maximal privacy.

### Preparations on your computer

For Sparrow Wallet to connect to the external services via Tor, Tor has to be running on your computer. You can run the Tor Browser and use port 9150 on localhost or else run Tor as a background service and use port 9050.

By OS:

* **Windows**: download, install, and run [Tor Browser](https://www.torproject.org)
  * The application must be started manually and run in the background when you want to connect over Tor.
  * By default, when you have Tor Browser running, Tor proxy is available on port `9150`, but if you want to have `9050` available too, you can run background service on port `9050`, executing `"tor.exe"` file on the installation path route you chose during Tor Browser installation and following the next subpath `...\Tor Browser\Browser\TorBrowser\Tor\tor.exe"`
* **Linux**: only needs to execute (`sudo apt install tor`) on the command line and ensure that the Tor service is working and listening at the default port `9050`

```sh
$ sudo ss -tulpn | grep LISTEN | grep tor
```

Expected output:

<pre><code><strong>> tcp   LISTEN 0  4096   127.0.0.1:9050   0.0.0.0:*    users:(("tor",pid=1847,fd=6))
</strong></code></pre>

* **macOS**: download, verify, install, and run [Tor Browser](https://www.torproject.org/)
  * The application must be started manually when you want to connect over Tor
  * By default, when you have Tor Browser running, Tor proxy is available on port 9150, use this port instead of `9050` port

### Server configuration

* Open Sparrow
* Navigate to the server configuration page by hitting `Ctrl`+`P`, or `Cmd`+`,` on OSX, then click on "Server"
* Click on the "Private Electrum" tab. If you already have an existing clearnet connection, click on "Edit Existing Connection".
* Enable the Tor proxy by clicking on the "Use proxy" slider
* On the "Proxy URL" line, enter `localhost` or `127.0.0.1` in the first box and either `9150` or `9050` in the second box depending if you run the Tor Browser or Tor as a background service.
* Click on "Test Connection". A green tick should appear on the button and you should see something similar to the following output

```
> Connected to Fulcrum x.x.x on protocol version ...
> [...]
```

![](../images/sparrow-tor-proxy.png)

{% hint style="info" %}
If you followed the [**Use the Tor proxy from another device**](../index-1/privacy.md#use-the-tor-proxy-from-another-device) section, you can use the Tor instance of your node instead of the instance of your regular computer, simply put on the "Proxy URL" box, your node IP local address (i.e 192.168.1.60) instead of localhost (127.0.0.1)
{% endhint %}

Now, let's go back to the wallet and check that the proxy is working properly.

* Close the server configuration window
* Check the two icons in the bottom right corner of the wallet window ![status icons](../images/sparrow-server-proxy-icons.png)
  * The first icon should be grey, not red; and a mouse hover should display "External Tor proxy enabled"

You're set! Sparrow Wallet is now configured to use the Tor proxy when fetching the Bitcoin price and when communicating with the Whirlpool server during CoinJoins.

{% hint style="danger" %}
**Troubleshooting note:** For those who already had Sparrow installed on their systems with old server connections, is needed to clear the pre-existing cert of the certs folder. Follow these instructions:
{% endhint %}

1. Shut down Sparrow if it's running
2. Go to C:\Users\<yourUsername>\AppData/Roaming\Sparrow\certs (or \~/.Sparrow/certs on Linux afaik)
3. Delete the certificate that corresponds to your node IP address
4. Start Sparrow again

## Upgrade

Sparrow will automatically notify you when an update is available. Simply install the updates using the usual method for your OS.
