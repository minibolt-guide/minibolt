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

# BTCPay Server

[BTCPay Server](https://github.com/btcpayserver/btcpayserver) is a free, open-source, and self-hosted Bitcoin payment gateway, which means developers and security auditors can always inspect the code for quality. It enables individuals and businesses to accept Bitcoin payments online or in person without any fees, offering self-sovereignty in the process.

{% hint style="danger" %}
Difficulty: Hard
{% endhint %}

<figure><img src="../../.gitbook/assets/btc-pay-banner.png" alt=""><figcaption></figcaption></figure>

[BTCPay Server](https://btcpayserver.org/) is a self-hosted and automated invoicing system. At checkout, a customer is presented with an invoice that they pay from their wallet. BTCPay Server follows the status of the invoice through the blockchain and informs you when the payment has been settled so that you can fulfill the order. It also takes care of payment refunding and bitcoin management alongside plenty of other features.

{% hint style="info" %}
More information can be found in its [documentation](https://docs.btcpayserver.org/), and stay tuned for news on its [blog](https://blog.btcpayserver.org/)
{% endhint %}

## Requisites

* Bitcoin Core
* LND (optional)

## Preparations

To run the BTCPay Server you will need to install .NET Core SDK, PostgreSQL, and NBXplorer

### **Reverse proxy & Firewall**

In the security [section](../../index-1/security.md#prepare-nginx-reverse-proxy), we set up Nginx as a reverse proxy. Now we can add the BTCPay Server configuration.

* With user `admin`, enable the Nginx reverse proxy to route external encrypted HTTPS traffic internally to the BTCPay Server. The `error_page 497` directive instructs browsers that send HTTP requests to resend them over HTTPS

```bash
$ sudo nano /etc/nginx/sites-enabled/btcpay-reverse-proxy.conf
```

```
server {
  listen 23001 ssl;
  error_page 497 =301 https://$host:$server_port$request_uri;
  location / {
    proxy_pass http://127.0.0.1:23000;
  }
}
```

* Test and reload Nginx configuration

```bash
$ sudo nginx -t
```

```bash
$ sudo systemctl reload nginx
```

<details>

<summary>Expected output ⬇️</summary>

```
> nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
> nginx: configuration file /etc/nginx/nginx.conf test is successful
```

</details>

* Configure the firewall to allow incoming HTTPS requests

```bash
$ sudo ufw allow 23001/tcp comment 'allow BTCpay SSL from anywhere'
```

### **Configure Bitcoin Core**

We need to set up settings in the Bitcoin Core configuration file - add new lines if they are not present

* With user `admin`, in `bitcoin.conf`, add the following line in the `"# Connections"` section. Save and exit

```bash
$ sudo nano /data/bitcoin/bitcoin.conf
```

<pre><code><strong># NBXplorer dependency
</strong><strong>whitelist=127.0.0.1
</strong></code></pre>

### Create a new btcpay user

We do not want to run BTCPay Server and other related services alongside other services due to security reasons. Therefore, we will create a separate user and run the code under the new user's account.

* With user `admin`, create a new user called `btcpay`. We will need this user later

```bash
$ sudo adduser --disabled-password --gecos "" btcpay
```

* Add it to the bitcoin group

```bash
$ sudo adduser btcpay bitcoin
```

### Install .NET Core SDK

* With user `admin`, change to the user btcpay

```bash
$ sudo su - btcpay
```

* We will use the scripted install mode. Download the script

```bash
$ wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh
```

* Before running this script, you'll need to grant permission for this script to run as an executable

```bash
$ chmod +x ./dotnet-install.sh
```

* Install .NET Core SDK 6.0

```bash
$ ./dotnet-install.sh --channel 6.0
```

* Add path to dotnet executable

```bash
$ echo 'export DOTNET_ROOT=$HOME/.dotnet' >>~/.bashrc
```

```bash
$ echo 'export PATH=$PATH:$HOME/.dotnet:$HOME/.dotnet/tools' >>~/.bashrc
```

```bash
$ source ~/.bashrc
```

* Check .NET SDK 6.0 is correctly installed

```bash
$ dotnet --version
```

**Example** of expected output:

```
> 6.0.411
```

* Delete the installation script

```bash
$ rm dotnet-install.sh
```

* Come back to the "admin" user

```bash
$ exit
```

### Install PostgreSQL

* With user `admin`, create the file repository configuration

{% code overflow="wrap" %}
```bash
$ sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
```
{% endcode %}

* Import the repository signing key

{% code overflow="wrap" %}
```bash
$ wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
```
{% endcode %}

Expected output:

```
> Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).
OK
```

* Update the package lists. You can ignore the `W: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8))` message

```bash
$ sudo apt update
```

* Install the latest version of PostgreSQL

```bash
$ sudo apt install postgresql postgresql-contrib
```

* Check the correct installation

```bash
$ psql -V
```

**Example** of expected output:

```
> psql (PostgreSQL) 15.3 (Ubuntu 15.3-1.pgdg22.04+1)
```

### Create a PostgreSQL database for NBXplorer

* With user `admin`, change to the automatically created user for the PostgreSQL installation called `postgres`

```bash
$ sudo su - postgres
```

* Create a new database user

```bash
$ createuser --pwprompt --interactive
```

Type in the following:

> > Enter name of role to add: **admin**
>
> > Enter password for new role: **admin**
>
> > Enter it again: **admin**
>
> > Shall the new role be a superuser? (y/n) **n**
>
> > Shall the new role be allowed to create databases? (y/n) **y**
>
> > Shall the new role be allowed to create more new roles? (y/n) **n**

* Create 2 new databases

```bash
$ createdb -O admin btcpayserver
```

```bash
$ createdb -O admin nbxplorer
```

* Go back to the `admin` user

```bash
$ exit
```

## Installation

### Install NBXplorer

[NBXplorer](https://github.com/dgarage/NBXplorer) is a minimalist UTXO tracker for HD Wallets, exploited by BTCPay Server

* With user `admin`, switch to the `btcpay` user

```bash
$ sudo su - btcpay
```

* Create a "src" directory and enter the folder

```bash
$ mkdir src
```

```bash
$ cd src
```

* Download the NBXplorer source code and enter the folder

```bash
$ git clone https://github.com/dgarage/NBXplorer
```

```bash
$ cd NBXplorer
```

* Checkout latest tag

{% code overflow="wrap" %}
```bash
$ git checkout $(git tag --sort -version:refname | awk 'match($0, /^v[0-9]+\./)' | head -n 1)
```
{% endcode %}

* Modify NBXplorer run script

```bash
$ nano run.sh
```

* Comment the existing line and add the next line below. Save and exit

{% code overflow="wrap" %}
```
#dotnet run --no-launch-profile --no-build -c Release --project "NBXplorer/NBXplorer.csproj" -- $@

/home/btcpay/.dotnet/dotnet run --no-launch-profile --no-build -c Release --project "NBXplorer/NBXplorer.csproj" -- $@
```
{% endcode %}

* Modify NBXplorer build script

```bash
$ nano build.sh
```

* Comment the existing line and add the next line below. Save and exit

```
#dotnet build -c Release NBXplorer/NBXplorer.csproj

/home/btcpay/.dotnet/dotnet build -c Release NBXplorer/NBXplorer.csproj
```

* Build NBXplorer

```bash
$ ./build.sh
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
Welcome to .NET 6.0!
---------------------
SDK Version: 6.0.411

Telemetry
---------
The .NET tools collect usage data in order to help us improve your experience. It is collected by Microsoft and shared with the community. You can opt-out of telemetry by setting the DOTNET_CLI_TELEMETRY_OPTOUT environment variable to '1' or 'true' using your favorite shell.

Read more about .NET CLI Tools telemetry: https://aka.ms/dotnet-cli-telemetry

----------------
Installed an ASP.NET Core HTTPS development certificate.
To trust the certificate run 'dotnet dev-certs https --trust' (Windows and macOS only).
Learn about HTTPS: https://aka.ms/dotnet-https
----------------
Write your first app: https://aka.ms/dotnet-hello-world
Find out what's new: https://aka.ms/dotnet-whats-new
Explore documentation: https://aka.ms/dotnet-docs
Report issues and find source on GitHub: https://github.com/dotnet/core
Use 'dotnet --help' to see available commands or visit: https://aka.ms/dotnet-cli
--------------------------------------------------------------------------------------
MSBuild version 17.3.2+561848881 for .NET
  Determining projects to restore...
  Restored /home/btcpay/src/NBXplorer/NBXplorer.Client/NBXplorer.Client.csproj (in 18.17 sec).
  Restored /home/btcpay/src/NBXplorer/NBXplorer/NBXplorer.csproj (in 19.19 sec).
  NBXplorer.Client -> /home/btcpay/src/NBXplorer/NBXplorer.Client/bin/Release/netstandard2.1/NBXplorer.Client.dll
  NBXplorer -> /home/btcpay/src/NBXplorer/NBXplorer/bin/Release/net6.0/NBXplorer.dll

Build succeeded.
    0 Warning(s)
    0 Error(s)

```

</details>

* Create the data folder and navigate to it

<pre class="language-sh"><code class="lang-sh"><strong>$ mkdir -p ~/.nbxplorer/Main
</strong></code></pre>

```bash
$ cd ~/.nbxplorer/Main
```

* Create a new config file

```bash
$ nano settings.config
```

#### NBXplorer configuration

* Add the complete next lines

```
# MiniBolt: nbxplorer configuration
# /home/btcpay/.nbxplorer/Main/settings.config

# Bitcoind connection
btc.rpc.cookiefile=/home/bitcoin/.bitcoin/.cookie

# Database
postgres=User ID=admin;Password=admin;Host=localhost;Port=5432;Database=nbxplorer;
```

* Go back to the `admin` user

```bash
$ exit
```

#### Autostart NBXplorer on boot

* Create the configuration file in the nano text editor and copy the following paragraph. Save and exit

```bash
$ sudo nano /etc/systemd/system/nbxplorer.service
```

```
# MiniBolt: systemd unit for NBXplorer
# /etc/systemd/system/nbxplorer.service

[Unit]
Description=NBXplorer daemon
Wants=bitcoind.service
After=bitcoind.service

[Service]
WorkingDirectory=/home/btcpay/src/NBXplorer
ExecStart=/home/btcpay/src/NBXplorer/run.sh
User=btcpay

Type=simple
PrivateTmp=true
ProtectSystem=full
NoNewPrivileges=true
PrivateDevices=true
TimeoutSec=120

[Install]
WantedBy=multi-user.target
```

* Enable autoboot **(optional)**

```bash
$ sudo systemctl enable nbxplorer
```

* Prepare “`nbxplorer`” monitoring by the systemd journal and checking the logging output. You can exit monitoring at any time with Ctrl-C

```bash
$ sudo journalctl -f -u nbxplorer
```

{% hint style="info" %}
Keep **this terminal open,** you'll need to come back here on the next step to monitor the logs
{% endhint %}

#### Running nbxplorer

To keep an eye on the software movements, [start your SSH program](../../index-1/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as "admin". Commands for the **second session** start with the prompt `$2` (which must not be entered)

* With user `admin`, start the `nbxplorer` service

```bash
$ sudo systemctl start nbxplorer
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>$ sudo journalctl -f -u</code> nbxplorer ⬇️</summary>

```
Jul 05 17:50:20 bbonode systemd[1]: Started NBXplorer daemon.
Jul 05 17:50:21 bbonode run.sh[2808966]: info: Configuration:  Data Directory: /home/btcpay/.nbxplorer/Main
Jul 05 17:50:21 bbonode run.sh[2808966]: info: Configuration:  Configuration File: /home/btcpay/.nbxplorer/Main/settings.config
Jul 05 17:50:21 bbonode run.sh[2808966]: info: Configuration:  Network: Mainnet
Jul 05 17:50:21 bbonode run.sh[2808966]: info: Configuration:  Supported chains: BTC
Jul 05 17:50:21 bbonode run.sh[2808966]: info: Configuration:  DBCache: 50 MB
Jul 05 17:50:21 bbonode run.sh[2808966]: info: Configuration:  Network: Mainnet
Jul 05 17:50:21 bbonode run.sh[2808966]: info: Configuration:  Supported chains: BTC
Jul 05 17:50:21 bbonode run.sh[2808966]: info: Configuration:  DBCache: 50 MB
Jul 05 17:50:21 bbonode run.sh[2808966]: info: NBXplorer.DatabaseSetup: Postgres services activated
Jul 05 17:50:21 bbonode run.sh[2808966]: info: NBXplorer.DatabaseSetup: Execute script 001.Migrations...
Jul 05 17:50:21 bbonode run.sh[2808966]: info: NBXplorer.DatabaseSetup: Execute script 002.Model...
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.DatabaseSetup: Execute script 003.Legacy...
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.DatabaseSetup: Execute script 004.Fixup...
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.DatabaseSetup: Execute script 005.ToBTCFix...
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.DatabaseSetup: Execute script 006.GetWalletsRecent2...
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.DatabaseSetup: Execute script 007.FasterSaveMatches...
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.DatabaseSetup: Execute script 008.FasterGetUnused...
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.DatabaseSetup: Execute script 009.FasterGetUnused2...
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.DatabaseSetup: Execute script 010.ChangeEventsIdType...
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.DatabaseSetup: Execute script 011.FixGetWalletsRecent...
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.DatabaseSetup: Execute script 012.PerfFixGetWalletsRecent...
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.DatabaseSetup: Execute script 013.FixTrackedTransactions...
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.DatabaseSetup: Execute script 014.FixAddressReuse...
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.DatabaseSetup: Execute script 015.AvoidWAL...
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.Indexer.BTC: TCP Connection succeed, handshaking...
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.Indexer.BTC: Handshaked
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.Indexer.BTC: Testing RPC connection to http://localhost:8332/
Jul 05 17:50:22 bbonode run.sh[2808966]: Hosting environment: Production
Jul 05 17:50:22 bbonode run.sh[2808966]: Content root path: /home/btcpay/src/NBXplorer/NBXplorer/bin/Release/net6.0/
Jul 05 17:50:22 bbonode run.sh[2808966]: Now listening on: http://127.0.0.1:24444
Jul 05 17:50:22 bbonode run.sh[2808966]: Application started. Press Ctrl+C to shut down.
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.Indexer.BTC: RPC connection successful
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.Indexer.BTC: Full node version detected: 250000
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.Indexer.BTC: Has txindex support
Jul 05 17:50:22 bbonode run.sh[2808966]: warn: NBXplorer.Indexer.BTC: BTC: Your NBXplorer server is not whitelisted by your node, you should add "whitelist=127.0.0.1" to the configuration file of your node. (Or use whitebind)
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.Events: BTC: Node state changed: NotStarted => NBXplorerSynching
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.Indexer.BTC: Current Index Progress not found, start syncing from the header's chain tip (At height: 797318)
Jul 05 17:50:22 bbonode run.sh[2808966]: info: NBXplorer.Events: BTC: Node state changed: NBXplorerSynching => Ready
Jul 05 17:50:23 bbonode run.sh[2808966]: info: NBXplorer.Events: BTC: New block 00000000000000000001415583131d3c1da985497830abcf638413226892d4ad (797318)
```

</details>

* Ensure NBXplorer is running and listening on the default port `24444`

```bash
$ sudo ss -tulpn | grep LISTEN | grep NBXplorer
```

Expected output:

```
tcp   LISTEN 0      512        127.0.0.1:24444      0.0.0.0:*    users:(("NBXplorer",pid=2808966,fd=176))
```

{% hint style="success" %}
You have NBxplorer running and prepared for the BTCpay server to use it
{% endhint %}

### Install BTCPay Server

* Switch to the `btcpay` user and go to the `src` folder

```bash
$ sudo su - btcpay
```

```bash
$ cd src
```

* Clone the BTCPay Server official GitHub repository and go to the `btcpayserver` folder

```bash
$ git clone https://github.com/btcpayserver/btcpayserver
```

```bash
$ cd btcpayserver
```

* Checkout latest tag

{% code overflow="wrap" %}
```bash
$ git checkout $(git tag --sort -version:refname | awk 'match($0, /^v[0-9]+\./)' | head -n 1)
```
{% endcode %}

* Modify BTCPay Server run script

```bash
$ nano run.sh
```

* Comment the next line and add the bellow

```
#dotnet "BTCPayServer.dll" $@

/home/btcpay/.dotnet/dotnet "BTCPayServer.dll" $@
```

* Modify the BTCPay Server build script

```bash
$ nano build.sh
```

* Comment the next line and add the bellow

<pre><code>#dotnet publish --no-cache -o BTCPayServer/bin/Release/publish/ -c Release BTCPayServer/BTCPayServer.csproj

<strong>/home/btcpay/.dotnet/dotnet publish --no-cache -o BTCPayServer/bin/Release/publish/ -c Release BTCPayServer/BTCPayServer.csproj
</strong></code></pre>

* Build BTCPay Server

```bash
$ ./build.sh
```

<details>

<summary>Expected output ⬇️</summary>

```
MSBuild version 17.3.2+561848881 for .NET
  Determining projects to restore...
  Restored /home/btcpay/src/btcpayserver/BTCPayServer/BTCPayServer.csproj (in 59.8 sec).
  Restored /home/btcpay/src/btcpayserver/BTCPayServer.Rating/BTCPayServer.Rating.csproj (in 59.8 sec).
  Restored /home/btcpay/src/btcpayserver/BTCPayServer.Common/BTCPayServer.Common.csproj (in 28 ms).
  Restored /home/btcpay/src/btcpayserver/BTCPayServer.Client/BTCPayServer.Client.csproj (in 596 ms).
  Restored /home/btcpay/src/btcpayserver/BTCPayServer.Abstractions/BTCPayServer.Abstractions.csproj (in 17 ms).
  Restored /home/btcpay/src/btcpayserver/BTCPayServer.Data/BTCPayServer.Data.csproj (in 675 ms).
  BTCPayServer.Client -> /home/btcpay/src/btcpayserver/BTCPayServer.Client/bin/Release/netstandard2.1/BTCPayServer.Client.dll
  BTCPayServer.Rating -> /home/btcpay/src/btcpayserver/BTCPayServer.Rating/bin/Release/net6.0/BTCPayServer.Rating.dll
  BTCPayServer.Common -> /home/btcpay/src/btcpayserver/BTCPayServer.Common/bin/Release/net6.0/BTCPayServer.Common.dll
  BTCPayServer.Abstractions -> /home/btcpay/src/btcpayserver/BTCPayServer.Abstractions/bin/Release/net6.0/BTCPayServer.Abstractions.dll
  BTCPayServer.Data -> /home/btcpay/src/btcpayserver/BTCPayServer.Data/bin/Release/net6.0/BTCPayServer.Data.dll
  BTCPayServer -> /home/btcpay/src/btcpayserver/BTCPayServer/bin/Release/net6.0/BTCPayServer.dll
  BTCPayServer -> /home/btcpay/src/btcpayserver/BTCPayServer/bin/Release/publish/
```

</details>

* Create the data folder and enter it

```bash
$ mkdir -p ~/.btcpayserver/Main
```

```bash
$ cd ~/.btcpayserver/Main
```

#### BTCPay Server configuration

* Create a new config file

```bash
$ nano settings.config
```

* Add the complete following lines

```
# MiniBolt: btcpayserver configuration
# /home/btcpay/.btcpayserver/Main/settings.config

# Server settings
socksendpoint=127.0.0.1:9050

# Database
## NBXplorer
explorer.postgres=User ID=admin;Password=admin;Host=localhost;Port=5432;Database=nbxplorer;
## BTCpay server
postgres=User ID=admin;Password=admin;Host=localhost;Port=5432;Database=btcpay;
```

{% hint style="info" %}
If you want to connect your Lightning LND node to BTCpay too, go to the [Connect to your LND internal node](btcpay-server.md#connect-to-your-lnd-internal-node) optional section
{% endhint %}

* Go back to the `admin` user

```bash
$ exit
```

#### Autostart BTCPay Server on boot

* Create the configuration file in the nano text editor and copy the following paragraph. Save and exit

```bash
$ sudo nano /etc/systemd/system/btcpay.service
```

<pre><code># MiniBolt: systemd unit for BTCpay server
# /etc/systemd/system/btcpay.service

<strong>[Unit]
</strong>Description=BTCPay Server
Wants=nbxplorer.service
After=nbxplorer.service

[Service]
WorkingDirectory=/home/btcpay/src/btcpayserver
ExecStart=/home/btcpay/src/btcpayserver/run.sh
User=btcpay

Type=simple
TimeoutSec=120

[Install]
WantedBy=multi-user.target
</code></pre>

* Enable autoboot (optional)

```bash
$ sudo systemctl enable btcpay
```

* Prepare “`btcpay`” monitoring by the systemd journal and checking the logging output. You can exit monitoring at any time with Ctrl-C

```bash
$ sudo journalctl -f -u btcpay
```

{% hint style="info" %}
Keep **this terminal open,** you'll need to come back here on the next step to monitor the logs
{% endhint %}

#### Running BTCPay Server

To keep an eye on the software movements, [start your SSH program](../../index-1/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as "`admin`". Commands for the **second session** start with the prompt `$2` (which must not be entered)

```bash
$ sudo systemctl start btcpay
```

<details>

<summary>Expected output ⬇️</summary>

```
Jul 05 18:01:08 bbonode run.sh[2810276]: info: Configuration:  Data Directory: /home/btcpay/.btcpayserver/Main
Jul 05 18:01:08 bbonode run.sh[2810276]: info: Configuration:  Configuration File: /home/btcpay/.btcpayserver/Main/settings.config
Jul 05 18:01:09 bbonode run.sh[2810276]: info: BTCPayServer.Plugins.PluginManager: Loading plugins from /home/btcpay/.btcpayserver/Plugins
Jul 05 18:01:09 bbonode run.sh[2810276]: info: BTCPayServer.Plugins.PluginManager: Adding and executing plugin BTCPayServer - 1.10.3
Jul 05 18:01:09 bbonode run.sh[2810276]: info: BTCPayServer.Plugins.PluginManager: Adding and executing plugin BTCPayServer.Plugins.Shopify - 1.10.3
Jul 05 18:01:09 bbonode run.sh[2810276]: info: BTCPayServer.Plugins.PluginManager: Adding and executing plugin BTCPayServer.Plugins.PointOfSale - 1.10.3
Jul 05 18:01:09 bbonode run.sh[2810276]: info: BTCPayServer.Plugins.PluginManager: Adding and executing plugin BTCPayServer.Plugins.PayButton - 1.10.3
Jul 05 18:01:09 bbonode run.sh[2810276]: info: BTCPayServer.Plugins.PluginManager: Adding and executing plugin BTCPayServer.Plugins.NFC - 1.10.3
Jul 05 18:01:09 bbonode run.sh[2810276]: info: BTCPayServer.Plugins.PluginManager: Adding and executing plugin BTCPayServer.Plugins.Crowdfund - 1.10.3
Jul 05 18:01:09 bbonode run.sh[2810276]: info: Configuration:  Supported chains: BTC
Jul 05 18:01:09 bbonode run.sh[2810276]: info: Configuration:  BTC: Explorer url is http://127.0.0.1:24444/
Jul 05 18:01:09 bbonode run.sh[2810276]: info: Configuration:  BTC: Cookie file is /home/btcpay/.nbxplorer/Main/.cookie
Jul 05 18:01:09 bbonode run.sh[2810276]: info: Configuration:  Network: Mainnet
Jul 05 18:01:13 bbonode run.sh[2810276]: info: Configuration:  Root Path: /
Jul 05 18:01:14 bbonode run.sh[2810276]: info: PayServer:      Checking if any payment arrived on lightning while the server was offline...
Jul 05 18:01:14 bbonode run.sh[2810276]: info: PayServer:      Processing lightning payments...
Jul 05 18:01:14 bbonode run.sh[2810276]: info: PayServer:      Starting listening NBXplorer (BTC)
Jul 05 18:01:14 bbonode run.sh[2810276]: info: PayServer:      Start watching invoices
Jul 05 18:01:14 bbonode run.sh[2810276]: info: PayServer:      Starting payment request expiration watcher
Jul 05 18:01:14 bbonode run.sh[2810276]: info: PayServer:      0 pending payment requests being checked since last run
Jul 05 18:01:14 bbonode run.sh[2810276]: info: Configuration:  Now listening on: http://127.0.0.1:23000
Jul 05 18:01:14 bbonode run.sh[2810276]: info: PayServer:      BTC: Checking if any pending invoice got paid while offline...
Jul 05 18:01:14 bbonode run.sh[2810276]: info: PayServer:      BTC: 0 payments happened while offline
Jul 05 18:01:14 bbonode run.sh[2810276]: info: PayServer:      Connected to WebSocket of NBXplorer (BTC)

```

</details>

* Ensure the BTCPay Server is running and listening on the default port `23000`

```bash
$ sudo ss -tulpn | grep LISTEN | grep 23000
```

Expected output:

```
> tcp   LISTEN 0      512        127.0.0.1:23000      0.0.0.0:*    users:(("dotnet",pid=2811744,fd=320))
```

Now point your browser to the secure access point provided by the NGINX web proxy, for example, `"https://minibolt.local:23001"` (or your node IP address) like `"https://192.168.0.20:23001"`.

Your browser will display a warning because we use a self-signed SSL certificate. We can do nothing about that because we would need a proper domain name (e.g., https://yournode.com) to get an official certificate that browsers recognize. Click on "Advanced" and proceed to the BTCPay Server web interface. On the login page, you should see the registration process.

{% hint style="info" %}
You can now create the first account to access the dashboard using a real (recommended) or a dummy email, and password
{% endhint %}

{% hint style="success" %}
**Congratulations!** You now have the amazing BTCPay Server payment processor running
{% endhint %}

## Extras (optional)

### Remote access over Tor

You can easily do so by adding a Tor hidden service on the MiniBolt and accessing the BTCPay Server with the Tor browser from any device.

* Ensure that you are logged in with the user `admin` and add the following lines in the `location hidden services` section, below `## This section is just for location-hidden services ##` in the torrc file. Save and exit

```bash
$ sudo nano /etc/tor/torrc
```

```
# Hidden Service BTCPay
HiddenServiceDir /var/lib/tor/hidden_service_btcpay/
HiddenServiceVersion 3
HiddenServicePort 80 127.0.0.1:23000
```

* Reload the Tor configuration

```bash
$ sudo systemctl reload tor
```

* Get your connection address

```bash
$ sudo cat /var/lib/tor/hidden_service_btcpay/hostname
```

**Example** of expected output:

```
> abcdefg..............xyz.onion
```

* With the [Tor browser](https://www.torproject.org/), you can access this onion address from any device

### Connect to your LND internal node

* With user `admin`, change to the `lnd` user

```bash
$ sudo su - lnd
```

* Go to the `lnd` folder

```bash
$ cd /data/lnd
```

* Get the LND's certificate fingerprint

```bash
$ openssl x509 -noout -fingerprint -sha256 -inform pem -in tls.cert
```

**Example** of expected output:

```
> sha256 Fingerprint=1D:8D:CC:44:A5:56:DF:D6:B8:26:CC:D2:EE:2E:4C:AE:5F:89:F2:FC:E4:0A:CC:32:E5:04:19:BA:10:CA:8D:98
```

{% hint style="warning" %}
Take note of your **Fingerprint=XX:YY:ZZ....**
{% endhint %}

> **Example:**
>
> `<fingerprint> = 1D:8D:CC:44:A5:56:DF:D6:B8:26:CC:D2:EE:2E:4C:AE:5F:89:F2:FC:E4:0A:CC:32:E5:04:19:BA:10:CA:8D:98`

* Go back to the admin user

```bash
$ exit
```

* With user `admin`, copy-paste the `admin.macaroon` file to the `btcpay` home folder

{% code overflow="wrap" %}
```bash
$ sudo cp /data/lnd/data/chain/bitcoin/mainnet/admin.macaroon /home/btcpay/admin.macaroon
```
{% endcode %}

* Change the owner to the `btcpay` user

```bash
$ sudo chown btcpay:btcpay /home/btcpay/admin.macaroon
```

* Stop BTCpay

```bash
$ sudo systemctl stop btcpay
```

* Change to the `btcpay` user

```bash
$ sudo su - btcpay
```

* Go to the `.btcpayserver` folder

```bash
$ cd ~/.btcpayserver/Main
```

* Edit the `settings.config` file

```bash
$ nano settings.config
```

* Add the next content to the end of the file, replacing `<fingerprint>` with your own obtained earlier. Save and exit

```
# Lightning
BTC.lightning=type=lnd-rest;server=https://127.0.0.1:8080/;macaroonfilepath=/home/btcpay/admin.macaroon;certthumbprint=<fingerprint>
```

* Go back to the `admin` user

```bash
$ exit
```

* Start BTCpay again. Monitor logs with `$ sudo journalctl -f -u btcpay` to ensure that all is running well

```bash
$ sudo systemctl start btcpay
```

## For the future: BTCPay Server & NBXplorer upgrade

Updating to a new release of [BTCPay](https://github.com/btcpayserver/btcpayserver/releases)[ Server](https://github.com/btcpayserver/btcpayserver/releases) or [NBXplorer](https://github.com/dgarage/NBXplorer/tags) should be straightforward.

#### Upgrade NBXplorer

* With user `admin`, stop BTCPay Server & NBXplorer

```bash
$ sudo systemctl stop btcpay && sudo systemctl stop nbxplorer
```

* Change to the `btcpay` user

```bash
$ sudo su - btcpay
```

* Enter the `src/nbxplorer` folder

```bash
$ cd src/NBXplorer
```

* Fetch the latest tag

<pre class="language-bash" data-overflow="wrap"><code class="lang-bash"><strong>$ git fetch --tags &#x26;&#x26; git checkout $(git tag --sort -version:refname | awk 'match($0, /^v[0-9]+\./)' | head -n 1)
</strong></code></pre>

* Build it

```bash
$ ./build.sh
```

* Go back to the `admin` user

```bash
$ exit
```

* Start the NBXplorer & BTCpay server again. Monitor logs with `$ sudo journalctl -f -u nbxplorer` to ensure that all is running well

```bash
$ sudo systemctl start nbxplorer && sudo systemctl start btcpay
```

#### Upgrade BTCPay Server

* With user `admin`, stop BTCPay Server

```bash
$ sudo systemctl stop btcpay
```

* Change to the `btcpay` user

```bash
$ sudo su - btcpay
```

* Enter the `src/btcpayserver` folder

```bash
$ cd src/btcpayserver
```

* Fetch the latest tag

<pre class="language-bash" data-overflow="wrap"><code class="lang-bash"><strong>$ git fetch --tags &#x26;&#x26; git checkout $(git tag --sort -version:refname | awk 'match($0, /^v[0-9]+\./)' | head -n 1)
</strong></code></pre>

* Build it

```bash
$ ./build.sh
```

* Go back to the `admin` user

```bash
$ exit
```

* Start the BTCpay server again. Monitor logs with `$ sudo journalctl -f -u btcpay` to ensure that all is running well

```bash
$ sudo systemctl start btcpay
```

## Uninstall

#### Uninstall services

* Ensure you are logged in with the user `admin`, stop `btcpay` and `nbxplorer` services

```bash
$ sudo systemctl stop btcpay
```

```bash
$ sudo systemctl stop nbxplorer
```

* Delete `btcpay` and `nbxplorer` services

```bash
$ sudo rm /etc/systemd/system/btcpay.service
```

```bash
$ sudo rm /etc/systemd/system/nbxplorer.service
```

#### Uninstall Firewall **configuration** & Reverse proxy

* Ensure you are logged in with the user `admin`, display the UFW firewall rules, and note the numbers of the rules for BTCpay (e.g., X and Y below)

```bash
$ sudo ufw status numbered
```

Expected output:

```
> [Y] 23001       ALLOW IN    Anywhere          # allow BTCpay SSL from anywhere
```

* Delete the rule with the correct number and confirm with "`yes`"

```bash
$ sudo ufw delete X
```

* Delete the BTCpay Nginx reverse proxy configuration

```bash
$ sudo rm /etc/nginx/sites-enabled/btcpay-reverse-proxy.conf
```

* Test and reload Nginx configuration

```bash
$ sudo nginx -t
```

```bash
$ sudo systemctl reload nginx
```

**Uninstall Tor hidden service**

* Ensure you are logged in with user "`admin`", comment or remove btcpay hidden service in the torrc. Save and exit

```bash
$ sudo nano /etc/tor/torrc
```

```
# Hidden Service BTCPay
#HiddenServiceDir /var/lib/tor/hidden_service_btcpay/
#HiddenServiceVersion 3
#HiddenServicePort 80 127.0.0.1:23000
```

* Reload the torrc config

```bash
$ sudo systemctl reload tor
```

#### Delete btcpay user

* Ensure you are logged in with the user `admin`. Delete the `btcpay` user.\
  Don't worry about `userdel: nym mail spool (/var/mail/nym) not found` output, the uninstall has been successful

```bash
$ sudo userdel -rf btcpay
```
