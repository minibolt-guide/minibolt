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

## Requirements

* [Bitcoin Core](../../index-2/bitcoin-client.md)
* [LND](../../lightning/lightning-client.md) (optional)
* Others
  * PostgreSQL

## Preparations

To run the BTCPay Server you will need to install `.NET Core SDK`, `PostgreSQL`, and `NBXplorer`

### Configure Bitcoin Core

We need to set up settings in the Bitcoin Core configuration file - add new lines if they are not present

* With user `admin`, edit `bitcoin.conf`

```bash
$ sudo nano /data/bitcoin/bitcoin.conf
```

* Add the following line to the `"# Connections"` section. Save and exit

<pre><code><strong># NBXplorer requeriment
</strong><strong>whitelist=127.0.0.1
</strong></code></pre>

* Restart Bitcoin Core to apply changes

```bash
$ sudo systemctl restart bitcoind
```

### Firewall

* Configure the firewall to allow incoming HTTPS requests

```bash
$ sudo ufw allow 23000/tcp comment 'allow BTCPay Server from anywhere'
```

Expected output

```
Rule added
Rule added (v6)
```

### Create the btcpay user & group

We do not want to run BTCPay Server and other related services alongside other services due to security reasons. Therefore, we will create a separate user and run the code under the new user's account.

* With user `admin`, create a new user called `btcpay`

```bash
$ sudo adduser --disabled-password --gecos "" btcpay
```

* Add `btcpay` user to the bitcoin and lnd groups

```bash
$ sudo usermod -a -G bitcoin,lnd btcpay
```

### Install .NET Core SDK

* With user `admin`, change to the `btcpay` user

```bash
$ sudo su - btcpay
```

* We will use the scripted install mode. Download the script

{% code overflow="wrap" %}
```bash
$ wget https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh
```
{% endcode %}

* Before running this script, you'll need to grant permission for this script to run as an executable

```bash
$ chmod +x ./dotnet-install.sh
```

* Set environment variable version

```bash
$ VERSION=8.0
```

* Install .NET Core SDK

```bash
$ ./dotnet-install.sh --channel $VERSION
```

<details>

<summary>Example of expected output ⬇️</summary>

```
dotnet-install: Attempting to download using aka.ms link https://dotnetcli.azureedge.net/dotnet/Sdk/6.0.417/dotnet-sdk-6.0.417-linux-x64.tar.gz
dotnet-install: Remote file https://dotnetcli.azureedge.net/dotnet/Sdk/6.0.417/dotnet-sdk-6.0.417-linux-x64.tar.gz size is 186250370 bytes.
dotnet-install: Extracting zip from https://dotnetcli.azureedge.net/dotnet/Sdk/6.0.417/dotnet-sdk-6.0.417-linux-x64.tar.gz
dotnet-install: Downloaded file size is 186250370 bytes.
dotnet-install: The remote and local file sizes are equal.
dotnet-install: Installed version is 6.0.417
dotnet-install: Adding to current process PATH: `/home/btcpay/.dotnet`. Note: This change will be visible only when sourcing script.
dotnet-install: Note that the script does not resolve dependencies during installation.
dotnet-install: To check the list of dependencies, go to https://learn.microsoft.com/dotnet/core/install, select your operating system and check the "Dependencies" section.
dotnet-install: Installation finished successfully.
```

</details>

* Add path to dotnet executable

```bash
$ echo 'export DOTNET_ROOT=$HOME/.dotnet' >>~/.bashrc
```

```bash
$ echo 'export PATH=$PATH:$HOME/.dotnet:$HOME/.dotnet/tools' >>~/.bashrc
```

**(Optional)** To improve your privacy, disable the .NET Core SDK telemetry

```bash
$ echo 'export DOTNET_CLI_TELEMETRY_OPTOUT=1' >> ~/.bashrc
```

```bash
$ source ~/.bashrc
```

* Check .NET SDK is correctly installed

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

* Ensure PostgreSQL is running and listening on the default port `5432`

```bash
$ sudo ss -tulpn | grep LISTEN | grep postgres
```

Expected output:

<pre><code><strong>> tcp   LISTEN 0      200        127.0.0.1:5432       0.0.0.0:*    users:(("postgres",pid=2532748,fd=7))
</strong>> tcp   LISTEN 0      200            [::1]:5432          [::]:*    users:(("postgres",pid=2532748,fd=6))
</code></pre>

### Create PostgreSQL databases

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

## Installation, Configuration & Run

### Install NBXplorer

[NBXplorer](https://github.com/dgarage/NBXplorer) is a minimalist UTXO tracker for HD Wallets, used by BTCPay Server

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

* Set the environment variable version

```bash
$ VERSION=2.4.3
```

* Download the NBXplorer source code and enter the folder

```bash
$ git clone --branch v$VERSION https://github.com/dgarage/NBXplorer.git
```

<details>

<summary>Example of expected output ⬇️</summary>

```
Cloning into 'btcpayserver'...
remote: Enumerating objects: 75078, done.
remote: Counting objects: 100% (2765/2765), done.
remote: Compressing objects: 100% (1249/1249), done.
remote: Total 75078 (delta 1834), reused 2203 (delta 1485), pack-reused 72313
Receiving objects: 100% (75078/75078), 51.55 MiB | 4.86 MiB/s, done.
Resolving deltas: 100% (58704/58704), done.
Note: switching to 'a921504bcf619c5e845813b8f994b39147694a97'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by switching back to a branch.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -c with the switch command. Example:

  git switch -c <new-branch-name>

Or undo this operation with:

  git switch -

Turn off this advice by setting config variable advice.detachedHead to false
```

</details>

```bash
$ cd NBXplorer
```

* Modify NBXplorer run script

```bash
$ nano run.sh
```

* Comment existing line

```
#dotnet run --no-launch-profile --no-build -c Release --project "NBXplorer/NBXplorer.csproj" -- $@
```

* Add the next line below. Save and exit

```
/home/btcpay/.dotnet/dotnet run --no-launch-profile --no-build -c Release --project "NBXplorer/NBXplorer.csproj" -- $@
```

* Modify NBXplorer build script

```bash
$ nano build.sh
```

* Comment next line

```
#dotnet build -c Release NBXplorer/NBXplorer.csproj
```

* Add the next line below. Save and exit

```
/home/btcpay/.dotnet/dotnet build -c Release NBXplorer/NBXplorer.csproj
```

* Build NBXplorer

```bash
$ ./build.sh
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
Welcome to .NET 8.0!
---------------------
SDK Version: 8.0.100

----------------
Installed an ASP.NET Core HTTPS development certificate.
To trust the certificate, view the instructions: https://aka.ms/dotnet-https-linux

----------------
Write your first app: https://aka.ms/dotnet-hello-world
Find out what's new: https://aka.ms/dotnet-whats-new
Explore documentation: https://aka.ms/dotnet-docs
Report issues and find source on GitHub: https://github.com/dotnet/core
Use 'dotnet --help' to see available commands or visit: https://aka.ms/dotnet-cli
--------------------------------------------------------------------------------------
MSBuild version 17.8.3+195e7f5a3 for .NET
  Determining projects to restore...
  Restored /home/btcpay/src/NBXplorer/NBXplorer.Client/NBXplorer.Client.csproj (in 30.33 sec).
  Restored /home/btcpay/src/NBXplorer/NBXplorer/NBXplorer.csproj (in 30.35 sec).
  NBXplorer.Client -> /home/btcpay/src/NBXplorer/NBXplorer.Client/bin/Release/netstandard2.1/NBXplorer.Client.dll
  NBXplorer -> /home/btcpay/src/NBXplorer/NBXplorer/bin/Release/net8.0/NBXplorer.dll

Build succeeded.
    0 Warning(s)
    0 Error(s)

Time Elapsed 00:00:41.43
```

</details>

* Check the correct installation

```bash
$ head -n 6 /home/btcpay/src/NBXplorer/NBXplorer/NBXplorer.csproj | grep Version
```

**Example** of expected output:

```
> <Version>2.4.3</Version>
```

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

### NBXplorer configuration

* Add the entire next lines. Save and exit

```
# MiniBolt: nbxplorer configuration
# /home/btcpay/.nbxplorer/Main/settings.config

# Bitcoind connection
btc.rpc.cookiefile=/data/bitcoin/.cookie

# Database
postgres=User ID=admin;Password=admin;Host=localhost;Port=5432;Database=nbxplorer;
```

* Go back to the `admin` user

```bash
$ exit
```

### Create NBXplorer systemd service

* As user `admin`, create the service file

```bash
$ sudo nano /etc/systemd/system/nbxplorer.service
```

* Paste the following configuration. Save and exit

```
# MiniBolt: systemd unit for NBXplorer
# /etc/systemd/system/nbxplorer.service

[Unit]
Description=NBXplorer
Wants=bitcoind.service
After=bitcoind.service

[Service]
WorkingDirectory=/home/btcpay/src/NBXplorer
ExecStart=/home/btcpay/src/NBXplorer/run.sh

User=btcpay
Group=btcpay

# Process management
####################
Type=simple
TimeoutSec=120

# Hardening Measures
####################
PrivateTmp=true
ProtectSystem=full
NoNewPrivileges=true
PrivateDevices=true


[Install]
WantedBy=multi-user.target
```

* Enable autoboot **(optional)**

```bash
$ sudo systemctl enable nbxplorer
```

* Prepare “`nbxplorer`” monitoring by the systemd journal and checking the logging output. You can exit monitoring at any time with Ctrl-C

```bash
$ journalctl -f -u nbxplorer
```

{% hint style="info" %}
Keep **this terminal open,** you'll need to come back here on the next step to monitor the logs
{% endhint %}

### Running NBXplorer

To keep an eye on the software movements, [start your SSH program](../../index-1/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as "admin". Commands for the **second session** start with the prompt `$2` (which must not be entered)

* With user `admin`, start the `nbxplorer` service

```bash
$ sudo systemctl start nbxplorer
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>$ journalctl -f -u nbxplorer</code> ⬇️</summary>

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
> tcp   LISTEN 0   512    127.0.0.1:24444    0.0.0.0:*    users:(("NBXplorer",pid=2808966,fd=176))
```

{% hint style="success" %}
You have NBxplorer running and prepared for the BTCpay server to use it
{% endhint %}

### Install BTCPay Server

* Switch to the `btcpay` user

```bash
$ sudo su - btcpay
```

* Go to the `src` folder

```bash
$ cd src
```

* Set variable environment version

```bash
$ VERSION=1.13.0
```

* Clone the BTCPay Server official GitHub repository

```bash
$ git clone --branch v$VERSION https://github.com/btcpayserver/btcpayserver
```

<details>

<summary>Example of expected output ⬇️</summary>

```
Cloning into 'btcpayserver'...
remote: Enumerating objects: 75078, done.
remote: Counting objects: 100% (2765/2765), done.
remote: Compressing objects: 100% (1249/1249), done.
remote: Total 75078 (delta 1834), reused 2203 (delta 1485), pack-reused 72313
Receiving objects: 100% (75078/75078), 51.55 MiB | 4.86 MiB/s, done.
Resolving deltas: 100% (58704/58704), done.
Note: switching to 'a921504bcf619c5e845813b8f994b39147694a97'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by switching back to a branch.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -c with the switch command. Example:

  git switch -c <new-branch-name>

Or undo this operation with:

  git switch -

Turn off this advice by setting config variable advice.detachedHead to false
```

</details>

* Go to the `btcpayserver` folder

```bash
$ cd btcpayserver
```

* Modify BTCPay Server run script

```bash
$ nano run.sh
```

* Comment next line

```
#dotnet "BTCPayServer.dll" $@
```

* Add the next line below. Save and exit

```
/home/btcpay/.dotnet/dotnet "BTCPayServer.dll" $@
```

* Modify the BTCPay Server build script

```bash
$ nano build.sh
```

* Comment next line

```
#dotnet publish --no-cache -o BTCPayServer/bin/Release/publish/ -c Release BTCPayServer/BTCPayServer.csproj
```

* Add the next line below. Save and exit

```
/home/btcpay/.dotnet/dotnet publish --no-cache -o BTCPayServer/bin/Release/publish/ -c Release BTCPayServer/BTCPayServer.csproj
```

* Build BTCPay Server

```bash
$ ./build.sh
```

<details>

<summary>Example of expected output ⬇️</summary>

```
MSBuild version 17.3.2+561848881 for .NET
  Determining projects to restore...
  Restored /home/btcpay/src/btcpayserver/BTCPayServer.Rating/BTCPayServer.Rating.csproj (in 32.66 sec).
  Restored /home/btcpay/src/btcpayserver/BTCPayServer.Data/BTCPayServer.Data.csproj (in 1.41 sec).
  Restored /home/btcpay/src/btcpayserver/BTCPayServer.Common/BTCPayServer.Common.csproj (in 392 ms).
  Restored /home/btcpay/src/btcpayserver/BTCPayServer.Client/BTCPayServer.Client.csproj (in 1.1 sec).
  Restored /home/btcpay/src/btcpayserver/BTCPayServer.Abstractions/BTCPayServer.Abstractions.csproj (in 8 ms).
  Restored /home/btcpay/src/btcpayserver/BTCPayServer/BTCPayServer.csproj (in 36.6 sec).
  BTCPayServer.Common -> /home/btcpay/src/btcpayserver/BTCPayServer.Common/bin/Release/net6.0/BTCPayServer.Common.dll
  BTCPayServer.Client -> /home/btcpay/src/btcpayserver/BTCPayServer.Client/bin/Release/netstandard2.1/BTCPayServer.Client.dll
  BTCPayServer.Rating -> /home/btcpay/src/btcpayserver/BTCPayServer.Rating/bin/Release/net6.0/BTCPayServer.Rating.dll
  BTCPayServer.Abstractions -> /home/btcpay/src/btcpayserver/BTCPayServer.Abstractions/bin/Release/net6.0/BTCPayServer.Abstractions.dll
  BTCPayServer.Data -> /home/btcpay/src/btcpayserver/BTCPayServer.Data/bin/Release/net6.0/BTCPayServer.Data.dll
/home/btcpay/src/btcpayserver/BTCPayServer/Services/Cheater.cs(37,35): warning CS1998: This async method lacks 'await' operators and will run synchronously. Consider using the 'await' operator to await non-blocking API calls, or 'await Task.Run(...)' to do CPU-bound work on a background thread. [/home/btcpay/src/btcpayserver/BTCPayServer/BTCPayServer.csproj]
  BTCPayServer -> /home/btcpay/src/btcpayserver/BTCPayServer/bin/Release/net6.0/BTCPayServer.dll
  BTCPayServer -> /home/btcpay/src/btcpayserver/BTCPayServer/bin/Release/publish/
```

</details>

* Check the correct installation

```bash
$ head -n 3 /home/btcpay/src/btcpayserver/Build/Version.csproj | grep Version
```

**Example** of expected output:

```
> <Version>1.12.0</Version>
```

* Create the data folder and enter it

```bash
$ mkdir -p ~/.btcpayserver/Main
```

```bash
$ cd ~/.btcpayserver/Main
```

### BTCPay Server configuration

* Create a new config file

```bash
$ nano settings.config
```

* Add the complete following lines

<pre><code># MiniBolt: btcpayserver configuration
# /home/btcpay/.btcpayserver/Main/settings.config

# Server settings
<strong>bind=0.0.0.0
</strong>
# Database
## NBXplorer
explorer.postgres=User ID=admin;Password=admin;Host=localhost;Port=5432;Database=nbxplorer;
## BTCpay server
postgres=User ID=admin;Password=admin;Host=localhost;Port=5432;Database=btcpay;
</code></pre>

{% hint style="info" %}
If you want to connect your Lightning LND node to BTCpay too, go to the [Connect to your LND internal node](btcpay-server.md#connect-to-your-lnd-internal-node) optional section
{% endhint %}

* Go back to the `admin` user

```bash
$ exit
```

### Create BTCPay Server systemd service

* As user `admin`, create the service file

```bash
$ sudo nano /etc/systemd/system/btcpay.service
```

* Paste the following configuration. Save and exit

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
Group=btcpay

# Process management
####################
Type=simple
TimeoutSec=120

[Install]
WantedBy=multi-user.target
</code></pre>

* Enable autoboot **(optional)**

```bash
$ sudo systemctl enable btcpay
```

* Prepare `btcpay` monitoring by the systemd journal and checking the logging output. You can exit monitoring at any time with Ctrl-C

```bash
$ journalctl -f -u btcpay
```

{% hint style="info" %}
Keep **this terminal open,** you'll need to come back here on the next step to monitor the logs
{% endhint %}

### Running BTCPay Server

To keep an eye on the software movements, [start your SSH program](../../index-1/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`. Commands for the **second session** start with the prompt `$2` (which must not be entered)

```bash
$ sudo systemctl start btcpay
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>$ journalctl -f -u btcpay</code> ⬇️</summary>

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
> tcp   LISTEN 0   512        127.0.0.1:23000   0.0.0.0:*    users:(("dotnet",pid=2811744,fd=320))
```

Now point your browser, `"http://minibolt.local:23000"` (or your node IP address) like `"http://192.168.0.20:23000"`.

{% hint style="info" %}
You can now create the first account to access the dashboard using a real (recommended) or a dummy email, and password
{% endhint %}

{% hint style="success" %}
**Congratulations!** You now have the amazing BTCPay Server payment processor running
{% endhint %}

## Extras (optional)

### Remote access over Tor

You can easily do so by adding a Tor hidden service on the MiniBolt and accessing the BTCPay Server with the Tor browser from any device.

* Ensure that you are logged in with the user `admin` and add the following lines to the `location hidden services` section, below `## This section is just for location-hidden services ##` in the torrc file. Save and exit

```bash
$ sudo nano /etc/tor/torrc
```

```
# Hidden Service BTCPay Server
HiddenServiceDir /var/lib/tor/hidden_service_btcpay/
HiddenServiceVersion 3
HiddenServicePoWDefensesEnabled 1
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

#### Configure LND

* Stay logged as `admin` user, and configure LND to allow LND REST from anywhere editing the `lnd.conf` file

```bash
$ sudo nano /data/lnd/lnd.conf
```

* Add the next line under the `[Application Options]` section. Save and exit

```
# Specify all ipv4 interfaces to listen on for REST connections
restlisten=0.0.0.0:8080
```

* Restart LND to apply changes

```bash
$ sudo systemctl restart lnd
```

* Ensure the REST port is now binding to the `0.0.0.0`  host instead of `127.0.0.1`

```bash
$ sudo ss -tulpn | grep LISTEN | grep lnd | grep 8080
```

Expected output:

<pre><code><strong>> tcp   LISTEN 0      4096         0.0.0.0:8080       0.0.0.0:*    users:(("lnd",pid=774047,fd=32))
</strong></code></pre>

* Stop BTCPay Server before making changes

```bash
$ sudo systemctl stop btcpay
```

* Change to the `btcpay` user

```bash
$ sudo su - btcpay
```

* Edit the `settings.config` file

```bash
$ nano .btcpayserver/Main/settings.config
```

* Add the next content to the end of the file. Save and exit

```
# Lightning internal node connection
BTC.lightning=type=lnd-rest;server=https://127.0.0.1:8080/;macaroonfilepath=/data/lnd/data/chain/bitcoin/mainnet/admin.macaroon;allowinsecure=true
```

* Go back to the `admin` user

```bash
$ exit
```

* Start the BTCPay Server again

```bash
$ sudo systemctl start btcpay
```

{% hint style="info" %}
Monitor logs with `$ journalctl -f -u btcpay` to ensure that all is running well
{% endhint %}

## Upgrade

Updating to a new release of [BTCPay Server](https://github.com/btcpayserver/btcpayserver/releases) or [NBXplorer](https://github.com/dgarage/NBXplorer/tags) should be straightforward.

### Upgrade .NET Core SDK

* With user `admin`, stop BTCPay Server & NBXplorer

```bash
$ sudo systemctl stop btcpay && sudo systemctl stop nbxplorer
```

* Change to the `btcpay` user

```bash
$ sudo su - btcpay
```

* We will use the scripted install mode. Download the script

```bash
$ wget https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.sh
```

* Before running this script, you'll need to grant permission for this script to run as an executable

```bash
$ chmod +x ./dotnet-install.sh
```

* Set the new `VERSION` environment variable, for example, 6.0 -> 8.0

```bash
$ VERSION=8.0
```

* Install .NET Core SDK

```bash
$ ./dotnet-install.sh --channel $VERSION
```

<details>

<summary>Example of expected output ⬇️</summary>

```
dotnet-install: Attempting to download using aka.ms link https://dotnetcli.azureedge.net/dotnet/Sdk/6.0.417/dotnet-sdk-6.0.417-linux-x64.tar.gz
dotnet-install: Remote file https://dotnetcli.azureedge.net/dotnet/Sdk/6.0.417/dotnet-sdk-6.0.417-linux-x64.tar.gz size is 186250370 bytes.
dotnet-install: Extracting zip from https://dotnetcli.azureedge.net/dotnet/Sdk/6.0.417/dotnet-sdk-6.0.417-linux-x64.tar.gz
dotnet-install: Downloaded file size is 186250370 bytes.
dotnet-install: The remote and local file sizes are equal.
dotnet-install: Installed version is 6.0.417
dotnet-install: Adding to current process PATH: `/home/btcpay/.dotnet`. Note: This change will be visible only when sourcing script.
dotnet-install: Note that the script does not resolve dependencies during installation.
dotnet-install: To check the list of dependencies, go to https://learn.microsoft.com/dotnet/core/install, select your operating system and check the "Dependencies" section.
dotnet-install: Installation finished successfully.
```

</details>

**(Optional)**  If you haven't done this before, to improve your privacy, disable the .NET Core SDK telemetry

```bash
$ echo 'export DOTNET_CLI_TELEMETRY_OPTOUT=1' >> ~/.bashrc
```

* Apply changes

```bash
$ source ~/.bashrc
```

* Check the new .NET SDK version has been correctly installed

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

* Exit to return to the admin user

```bash
$ exit
```

### Upgrade NBXplorer

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

* Set the environment variable version

```bash
$ VERSION=2.5.0
```

* Fetch the changes of the wish latest tag

<pre class="language-bash" data-overflow="wrap"><code class="lang-bash"><strong>$ git pull https://github.com/dgarage/NBXplorer.git v$VERSION
</strong></code></pre>

**Example** of expected output:

```
From https://github.com/dgarage/NBXplorer
 * tag               v2.4.3     -> FETCH_HEAD
Updating c7b5a73..95f28ac
Fast-forward
 Dockerfile.linuxamd64                                              |   4 +-
 Dockerfile.linuxarm32v7                                            |   4 +-
 Dockerfile.linuxarm64v8                                            |   4 +-
 NBXplorer.Client/AssetMoney.cs                                     |   1 -
[...]
```

{% hint style="info" %}
If the prompt shows you `"fatal: unable to auto-detect email address (got 'btcpay@minibolt2fa.(none)')"`⬇️

```bash
$ git config user.email "minibolt@dummyemail.com"
```

```bash
$ git config user.name "MiniBolt"
```
{% endhint %}

{% hint style="info" %}
If the prompt shows you this:

```
hint: You have divergent branches and need to specify how to reconcile them.
hint: You can do so by running one of the following commands sometime before
hint: your next pull:
hint:
hint:   git config pull.rebase false  # merge (the default strategy)
hint:   git config pull.rebase true   # rebase
hint:   git config pull.ff only       # fast-forward only
hint:
hint: You can replace "git config" with "git config --global" to set a default
hint: preference for all repositories. You can also pass --rebase, --no-rebase,
hint: or --ff-only on the command line to override the configured default per
hint: invocation.
```

You need to do and exec the before `git pull` command again:

```bash
$ git config pull.rebase false
```
{% endhint %}

* Press `Ctrl+X` when the nano automatically opens the `MERGE_MSG` to no apply modifications
* Build it

```bash
$ ./build.sh
```

* Check the correct installation update

```bash
$ head -n 6 /home/btcpay/src/NBXplorer/NBXplorer/NBXplorer.csproj | grep Version
```

**Example** of expected output:

```
> <Version>2.4.3</Version>
```

* Go back to the `admin` user

```bash
$ exit
```

* Start the NBXplorer & BTCpay server again. Monitor logs with `$ journalctl -f -u nbxplorer` & `$ journalctl -f -u btcpay` to ensure that all is running well

```bash
$ sudo systemctl start nbxplorer && sudo systemctl start btcpay
```

### Upgrade BTCPay Server

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

* Set the environment variable version

```bash
$ VERSION=1.12.4
```

* Fetch the changes of the wish latest tag

{% code overflow="wrap" %}
```bash
$ git pull https://github.com/btcpayserver/btcpayserver.git v$VERSION
```
{% endcode %}

**Example** of expected output:

```
From https://github.com/btcpayserver/btcpayserver
 * tag                   v1.12.0    -> FETCH_HEAD
Updating 541cef55b..6ecfe073e
Fast-forward
 BTCPayServer.Data/ApplicationDbContext.cs                         |  2 +-
 BTCPayServer.Data/Data/AppData.cs                                 | 10 +++++++++-
[...]
```

{% hint style="info" %}
If the prompt shows you `"fatal: unable to auto-detect email address (got 'btcpay@minibolt2fa.(none)')"`⬇️

```bash
$ git config user.email "minibolt@dummyemail.com"
```

```bash
$ git config user.name "MiniBolt"
```
{% endhint %}

{% hint style="info" %}
If the prompt shows you: `fatal: Need to specify how to reconcile divergent branches.`⬇️

```bash
$ git config pull.rebase false
```
{% endhint %}

* Press `Ctrl+X` when the nano automatically opens the `MERGE_MSG` to no apply modifications
* Build it

```bash
$ ./build.sh
```

<details>

<summary>Example of expected output ⬇️</summary>

```
  Determining projects to restore...
  Restored /home/btcpay/src/btcpayserver/BTCPayServer.Abstractions/BTCPayServer.Abstractions.csproj (in 965 ms).
  Restored /home/btcpay/src/btcpayserver/BTCPayServer.Client/BTCPayServer.Client.csproj (in 965 ms).
  Restored /home/btcpay/src/btcpayserver/BTCPayServer.Common/BTCPayServer.Common.csproj (in 978 ms).
  Restored /home/btcpay/src/btcpayserver/BTCPayServer.Data/BTCPayServer.Data.csproj (in 113 ms).
  Restored /home/btcpay/src/btcpayserver/BTCPayServer.Rating/BTCPayServer.Rating.csproj (in 178 ms).
  Restored /home/btcpay/src/btcpayserver/BTCPayServer/BTCPayServer.csproj (in 1.9 sec).
  BTCPayServer.Client -> /home/btcpay/src/btcpayserver/BTCPayServer.Client/bin/Release/netstandard2.1/BTCPayServer.Client.dll
  BTCPayServer.Common -> /home/btcpay/src/btcpayserver/BTCPayServer.Common/bin/Release/net8.0/BTCPayServer.Common.dll
  BTCPayServer.Rating -> /home/btcpay/src/btcpayserver/BTCPayServer.Rating/bin/Release/net8.0/BTCPayServer.Rating.dll
  BTCPayServer.Abstractions -> /home/btcpay/src/btcpayserver/BTCPayServer.Abstractions/bin/Release/net8.0/BTCPayServer.Abstractions.dll
  BTCPayServer.Data -> /home/btcpay/src/btcpayserver/BTCPayServer.Data/bin/Release/net8.0/BTCPayServer.Data.dll
  BTCPayServer -> /home/btcpay/src/btcpayserver/BTCPayServer/bin/Release/net8.0/BTCPayServer.dll
  BTCPayServer -> /home/btcpay/src/btcpayserver/BTCPayServer/bin/Release/publish/
```

</details>

* Check the correct installation update

```bash
$ head -n 3 /home/btcpay/src/btcpayserver/Build/Version.csproj | grep Version
```

**Example** of expected output:

```
> <Version>1.12.0</Version>
```

* Go back to the `admin` user

```bash
$ exit
```

* Start the BTCpay server again. Monitor logs with `$ journalctl -f -u btcpay` to ensure that all is running well

```bash
$ sudo systemctl start btcpay
```

## Uninstall

### Uninstall service & user

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

* Ensure you are logged in with the user `admin`. Delete the `btcpay` user.\
  Don't worry about `userdel: btcpay mail spool (/var/mail/btcpay) not found` output, the uninstall has been successfull

```bash
$ sudo userdel -rf btcpay
```

### Uninstall Firewall **configuration** & Reverse proxy

* Ensure you are logged in with the user `admin`, display the UFW firewall rules, and note the numbers of the rules for BTCPay Server (e.g. X and Y below)

```bash
$ sudo ufw status numbered
```

Expected output:

```
> [Y] 23000       ALLOW IN    Anywhere          # allow BTCPay Server from anywhere
```

* Delete the rule with the correct number and confirm with `yes`

```bash
$ sudo ufw delete X
```

### **Uninstall Tor hidden service**

* Ensure you are logged in with the user `admin`

```bash
$ sudo nano /etc/tor/torrc
```

* Comment or remove the btcpay hidden service in the torrc. Save and exit

<pre><code># Hidden Service BTCPay Server
#HiddenServiceDir /var/lib/tor/hidden_service_btcpay/
#HiddenServiceVersion 3
<strong>#HiddenServicePoWDefensesEnabled 1
</strong>#HiddenServicePort 80 127.0.0.1:23000
</code></pre>

* Reload the torrc config

```bash
$ sudo systemctl reload tor
```

## Port reference

|  Port | Protocol |             Use            |
| :---: | :------: | :------------------------: |
|  5432 |    TCP   |  PostgreSQL default port   |
| 24444 |    TCP   |   NBXplorer default port   |
| 23000 |    TCP   | BTCPay Server default port |
