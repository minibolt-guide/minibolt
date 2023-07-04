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

# BTCpay server

BTCPay Server is a free and open-source Bitcoin payment processor which allows you to accept bitcoin without fees or intermediaries

{% hint style="warning" %}
Difficulty: Intermediate
{% endhint %}

{% hint style="success" %}
Status: Tested v3
{% endhint %}

<figure><img src="../../.gitbook/assets/btc-pay-banner.png" alt=""><figcaption></figcaption></figure>

## Requisites

* Bitcoin Core
* LND

## Preparations

To run the BTCPayServer you will need to install .NET Core SDK, NBXplorer, and PostgreSQL

### Create a new btcpay user

We do not want to run BTCPay Server and other related services alongside other services due to security reasons. Therefore, we will create a separate user and run the code under the new user's account.

* Create a new user called "btcpay". We will need this user later

```bash
$ sudo adduser --disabled-password --gecos "" btcpay
```

* Add it to the bitcoin group

```bash
$ sudo adduser btcpay bitcoin
```

### Install  .NET Core SDK

* With user admin, change to the user btcpay

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

* Come back to the "admin" user

```bash
$ exit
```

### Install PostgreSQL

* With user "admin", create the file repository configuration

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

* Update the package lists. You can ignore the `Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8))` message

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

### Create a PostgreSQL database for NBXplorer

* Change to the automatically created user for the PostgreSQL installation called "postgres"

```bash
$ sudo su - postgres
```

* Enter the PostgreSQL CLI

```bash
$ psql
```

* Create a database for NBXplorer. "postgres=#" is the prompt of PostgreSQL CLI, don't enter

```bash
postgres=# CREATE DATABASE nbxplorer TEMPLATE 'template0' LC_CTYPE 'C' LC_COLLATE 'C' ENCODING 'UTF8';
```

Expected output:

```
> CREATE DATABASE
```

* Create user

```bash
postgres=# CREATE USER nbxplorer WITH ENCRYPTED PASSWORD 'urpassword';
```

* Grant privileges

```bash
postgres=# GRANT ALL PRIVILEGES ON DATABASE nbxplorer TO nbxplorer;
```

### Create a PostgreSQL database for the BTCpay server

* Create a PostgreSQL database for the BTCpay server

```bash
postgres=# CREATE DATABASE btcpay TEMPLATE 'template0' LC_CTYPE 'C' LC_COLLATE 'C' ENCODING 'UTF8';
```

* Create user

<pre class="language-bash"><code class="lang-bash"><strong>postgres=# CREATE USER btcpay WITH ENCRYPTED PASSWORD 'urpassword';
</strong></code></pre>

* Grant privileges

```bash
postgres=# GRANT ALL PRIVILEGES ON DATABASE btcpay TO btcpay;
```

* Exit PostgreSQL

<pre class="language-bash"><code class="lang-bash"><strong>postgres=# \q
</strong></code></pre>

* Go back to the "admin" user

```bash
$ exit
```

## Installation

### Install NBXplorer

[NBXplorer](https://github.com/dgarage/NBXplorer) is a minimalist UTXO tracker for HD Wallets, exploited by BTCPay Server.

* Switch to the btcpay user

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

* Modify NBXplorer build script

```bash
$ nano build.sh
```

* Comment the existing line and add the next line bellow

<pre><code>#dotnet build -c Release NBXplorer/NBXplorer.csproj
<strong>
</strong>/home/btcpay/.dotnet/dotnet build -c Release NBXplorer/NBXplorer.csproj
</code></pre>

* Build NBXplorer

```bash
$ ./build.sh
```

<details>

<summary>Expected output ⬇️</summary>

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

* Modify NBXplorer run script

```bash
$ nano run.sh
```

* Comment the existing line and add the next line. Save and exit

{% code overflow="wrap" %}
```
#dotnet run --no-launch-profile --no-build -c Release --project "NBXplorer/NBXplorer.csproj" -- $@

/home/btcpay/.dotnet/dotnet run --no-launch-profile --no-build -c Release --project "NBXplorer/NBXplorer.csproj" -- $@
```
{% endcode %}

* Run NBXplorer in order to generate default config files. Don't worry with the "**fail: Configuration:"** line

```bash
$ ./run.sh
```

<details>

<summary>Expected output ⬇️</summary>

```
info: Configuration:  Data Directory: /home/btcpay/.nbxplorer/Main
info: Configuration:  Configuration File: /home/btcpay/.nbxplorer/Main/settings.config
info: Configuration:  Creating configuration file
info: Configuration:  Network: Mainnet
info: Configuration:  Supported chains: BTC
info: Configuration:  DBCache: 50 MB
fail: Configuration:  You need to select your backend implementation. There is two choices, PostgresSQL and DBTrie.
        * To use postgres, please use --postgres "..." (or NBXPLORER_POSTGRES="...") with a postgres connection string (see https://www.connectionstrings.com/postgresql/)
        * To use DBTrie, use --dbtrie (or NBXPLORER_DBTRIE=1). This backend is deprecated, only use if you haven't yet migrated. For more information about how to migrate, see https://github.com                              /dgarage/NBXplorer/tree/master/docs/Postgres-Migration.md
```

</details>

* Change to the installation folder

```bash
$ cd /home/btcpay/.nbxplorer/Main
```

* Edit the config file

```bash
$ nano settings.config -l
```

* Uncomment and replace line 33 with this line

```
btc.rpc.cookiefile=/home/bitcoin/.bitcoin/.cookie
```

* Insert the following line at the beginning

```
### Database ###
postgres=User ID=nbxplorer;Password=urpassword;Application Name=nbxplorer;MaxPoolSize=20;Host=localhost;Port=5432;Database=nbxplorer;
```

* Go back to the "admin" user

```bash
$ exit
```

#### Autostart NBXplorer on boot

* Create the configuration file in the nano text editor and copy the following paragraph. Save and exit

```bash
$ sudo nano /etc/systemd/system/nbxplorer.service
```

```
[Unit]
Description=NBXplorer daemon
Requires=bitcoind.service
After=bitcoind.service

[Service]
WorkingDirectory=/home/btcpay/src/NBXplorer
ExecStart=/home/btcpay/src/NBXplorer/run.sh

User=btcpay

Type=simple
TimeoutSec=120
Restart=always
RestartSec=30
KillMode=process

[Install]
WantedBy=multi-user.target
```

* Enable autoboot

```bash
$ sudo systemctl enable nbxplorer
```

* Prepare “nbxplorer” monitoring by the systemd journal and check the logging output. You can exit monitoring at any time with Ctrl-C

```bash
$ sudo journalctl -f -u nbxplorer
```

{% hint style="info" %}
Keep **this terminal open,** you'll need to come back here on the next step to monitor logs.
{% endhint %}

#### Running nbxplorer

To keep an eye on the software movements, [start your SSH program](../../system/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as "admin". Commands for the **second session** start with the prompt `$2` (which must not be entered)

* Start the service

```bash
$ sudo systemctl start nbxplorer
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>$ sudo journalctl -f -u</code> nbxplorer ⬇️</summary>

```
// Some code
```

</details>

### Install BTCpay server
