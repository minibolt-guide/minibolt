---
title: Electrum Wallet Desktop
parent: + Bitcoin
grand_parent: Bonus Section
nav_exclude: true
has_toc: false
---

# Electrum Wallet Desktop

[Electrum wallet Desktop](https://electrum.org) is a well-established, feature-rich Bitcoin wallet for power users that supports most hardware wallets.

{% hint style="success" %}
Difficulty: Easy
{% endhint %}

![](../../images/electrum_wallet_logo.png)

## Requirements

* [Bitcoin Core](../../bitcoin/bitcoin/bitcoin-client.md)
* Electrum server: [Fulcrum](../../bitcoin/bitcoin/electrum-server.md) or [Electrs](electrs.md)

## Installation

On your local computer, download, verify, and install Electrum Wallet.

Using the instructions on [this page](https://electrum.org/#download):

* Download the required version for your OS
* Download the signature file
* Verify the signature following the instructions on the page depending on your OS
* Install Electrum Wallet Desktop

## Configuration

### Force single server Electrum connection to only your node

To preserve privacy, we will constrain Electrum to only connect to a single server (your MiniBolt). How to do this depends on whether you are connecting via Local Area Network or via Tor and the operating system that you use on your regular computer.

#### Local connection

If you plan to use Electrum from only within your own secured local area network, you can use the local connection details.

* **Linux**
  * Execute this command in your Linux terminal to -1 (connect to single server only) -s (server address)

<pre class="language-sh"><code class="lang-sh"><strong>./electrum -1 -s minibolt.local:50002:s
</strong></code></pre>

{% hint style="info" %}
You can also use the local IP address of your node, i.e: 192.168.1.10:50002:s
{% endhint %}

* **Windows**
  * Find the new Electrum desktop shortcut, right-click it, go to "Properties", and click the shortcut tab at the top bar, in the box named target, put "`-1 -s minibolt.local:50002:s`" after "electrum.exe"

```sh
"C:\Program Files (x86)\Electrum\electrum.exe" -1 -s minibolt.local:50002:s
```

{% hint style="info" %}
You can use the local IP address of your node, i.e: 192.168.1.10:50002:s
{% endhint %}

* Apply, accept, and execute by double-clicking on the new shortcut

![](../../images/electrum-win-shortcut-local.PNG)

* **macOS**
  * Execute this command in the Terminal application to -1 (connect to single server only) -s (server address)

{% code overflow="wrap" %}
```sh
/Applications/Electrum.app/Contents/MacOS/run_electrum -1 -s minibolt.local:50002:s
```
{% endcode %}

{% hint style="info" %}
You can use the local IP address of your node, i.e: 192.168.1.10:50002:s
{% endhint %}

* After using this command for the first run, close Electrum, and open the Electrum config file with the following customized command

```sh
nano /Users/<YOUR_PERSONAL_COMPUTER_USERNAME>/.electrum/config
```

* Modify the file to include the following lines

```sh
"auto_connect": false,
"oneserver": true,
"server": "minibolt.local:50002:s",
```

{% hint style="info" %}
You can use the local IP address of your node, i.e: 192.168.1.10:50002:s
{% endhint %}

{% hint style="info" %}
After opening a wallet or creating a new one, Electrum will indicate an active connection to a local server with a green dot in the bottom right corner of the screen
{% endhint %}

![](../../images/electrum-wallet-local.PNG)

### Remote connection over Tor

To connect over Tor, you will need to have Tor installed on the client computer running Electrum.

By OS:

* **Windows**: download, install, and run [Tor Browser](https://www.torproject.org)
  * The application must be started manually and run in the background when you want to connect over Tor.
  * By default, when you have Tor Browser running, Tor proxy is available on port `9150`, but if you want to have `9050` available too, you can run background service on port `9050`, executing `"tor.exe"` file on the installation path route you chose during Tor Browser installation and following the next subpath `...\Tor Browser\Browser\TorBrowser\Tor\tor.exe"`
* **Linux**: only need to execute (`sudo apt install tor`) on the command line and ensure that the Tor service is working and listening at the default ports `9050` and `9150`

```sh
sudo ss -tulpn | grep tor
```

Expected output:

```
tcp   LISTEN 0  4096   127.0.0.1:9050   0.0.0.0:*    users:(("tor",pid=1847,fd=6))
tcp   LISTEN 0  4096   127.0.0.1:9051   0.0.0.0:*    users:(("tor",pid=1847,fd=7))
```

* **macOS**: download, verify, install, and run [Tor Browser](https://www.torproject.org/)
  * The application must be started manually when you want to connect over Tor
  * By default, when you have Tor Browser running, Tor proxy is available on port 9150, use this port instead of `9050` port

Now we need to specify the Tor address for the Electrum Server and the local Tor proxy port in the Electrum Wallet configuration.

First, get the onion address of your Electrum server directly on the MiniBolt, depending on whether you chose the Electrs or Fulcrum service

* For Electrs

```sh
sudo cat /var/lib/tor/hidden_service_electrs/hostname
```

**Example** of expected output:

```
ab...yz.onion
```

* For Fulcrum

```sh
sudo cat /var/lib/tor/hidden_service_fulcrum/hostname
```

**Example** of expected output:

```
ab...yz.onion.onion
```

Now, execute Electrum Wallet choosing the correct way depending on your OS (replace "9050" with "9150" if you choose to run the Tor Browser)

* **Linux**
  * Execute this command in your Linux terminal to -1 (connect to single server only) -s (server address)

```sh
./electrum -1 -s ab...yz.onion:50002:s -p socks5:localhost:9050
```

* **Windows**
  * With your new shortcut created after installation in Desktop, right-click it and go to properties, click the shortcut tab at the top bar, and in the box named target put `"-1 -s ab...yz.onion:50002:s -p socks5:localhost:9050"` after `"electrum.exe"`, apply, accept, and execute by double-clicking on our new shortcut

{% code overflow="wrap" %}
```sh
 C:\Program Files (x86)\Electrum\electrum.exe -1 -s ab...yz.onion:50002:s -p socks5:localhost:9050
```
{% endcode %}

![](../../images/electrum-win-shortcut-tor.PNG)

* **macOS**
  * Open the Tor browser
  * In the Terminal application, run the following command

{% code overflow="wrap" %}
```sh
/Applications/Electrum.app/Contents/MacOS/run_electrum -1 -s ab...yz.onion:50002:s -p socks5:localhost:9050
```
{% endcode %}

After opening a wallet or creating a new one, Electrum will indicate an active connection to a Tor server with a blue dot in the bottom right corner of the screen.

![](../../images/electrum-wallet-tor.png)

{% hint style="danger" %}
Try to check `"Use Tor proxy at port 9050"` or `"Use Tor proxy at port 9150"` in `"Proxy"` settings tab if not connected for you
{% endhint %}

![](../../images/electrum-wallet-tor-check.PNG)

{% hint style="danger" %}
**Troubleshooting note:** for those who already had Electrum installed on their systems with old server connections, it is needed to clear the pre-existing cert of the certs folder. Follow these instructions:

1. Shutdown Electrum if it's running
2. Go to `C:\Users\<yourUsername>\AppData\Roaming\Electrum\certs` (or `~/.electrum/certs` on Linux afaik)
3. Delete the certificate that corresponds to your node IP address
4. Start Electrum again
{% endhint %}
