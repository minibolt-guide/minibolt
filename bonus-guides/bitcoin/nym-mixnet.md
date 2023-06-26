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

# NYM mixnet

<div data-full-width="false">

<figure><img src="../../.gitbook/assets/nym-build-structure.png" alt=""><figcaption></figcaption></figure>

</div>

## Installation

### Preparations

#### Install dependencies

* With user `admin`, make sure that all necessary software packages are installed

```bash
$ sudo apt install pkg-config build-essential libssl-dev jq
```

* Install Rustup & Cargo

```bash
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

{% hint style="info" %}
When the prompt asks you to choose an option, type "`1`" and press enter
{% endhint %}

```bash
$ source "$HOME/.cargo/env"
```

#### **Compile NYM binaries from the source code**

* Now we will go to the temporary folder to create the NYM binaries that we will need for the installation process

```bash
$ cd /tmp
```

* Set a temporary version environment variable to the installation

```bash
$ VERSION=1.1.22
```

* Clone the latest version of the source code from the GitHub repository

```bash
$ git clone https://github.com/nymtech/nym.git
```

```bash
$ cd nym
```

* Ensure you downloaded the latest version

```bash
$ git checkout release/v$VERSION
```

* Enter the command to compile

```bash
$ cargo build --release
```

{% hint style="info" %}
This process can take quite a long time, 10-15 minutes or more, depending on the performance of your device. Please be patient until the prompt shows again
{% endhint %}

{% hint style="info" %}
If you come to update, this is the final step, now go back to the [Upgrade section](nym-mixnet.md#for-the-future-upgrade-nym-binaries) to continue
{% endhint %}

### Install NYM network Requester

### **Create the nym user**

* Create the user nym with this command

```bash
$ sudo adduser --gecos "" --disabled-password nym
```

* Staying in the temporary folder, copy to the home nym user the "nym network requester" binary

```bash
$ sudo cp /tmp/nym/target/release/nym-network-requester /home/nym/
```

* Assign the owner of the binary to the nym user&#x20;

```bash
$ sudo chown nym:nym /home/nym/nym-network-requester
```

### Init NYM  network requester

* Switch to the user "nym"

```bash
$ sudo su - nym
```

* Init the network requester for the first time with `gateway based selection` flag to choose a gateway based on its location relative to your device

```bash
$ ./nym-network-requester init --id bitcoin --latency-based-selection
```

<details>

<summary>Example of expected output ⬇️</summary>

<pre><code>      _ __  _   _ _ __ ___
     | '_ \| | | | '_ \ _ \
     | | | | |_| | | | | | |
     |_| |_|\__, |_| |_| |_|
            |___/

             (nym-network-requester - version 1.1.21)


Initialising client...
 2023-06-17T20:28:30.210Z INFO  nym_client_core::init::helpers > choosing gateway by latency...
 2023-06-17T20:28:49.963Z INFO  nym_client_core::init::helpers > chose gateway 2xU4CBE6QiiYt6EyBXSALwxkNvM7gqJfjHXaMkjiFmYW with average latency of 42.730304ms
Registering with new gateway
 2023-06-17T20:28:50.244Z INFO  nym_gateway_client::client     > the gateway is using exactly the same protocol version as we are. We're good to continue!
 2023-06-17T20:28:50.252Z INFO  nym_config                     > Configuration file will be saved to "/home/nym/.nym/service-providers/network-requester/bitcoin/config/config.toml"
Saved configuration file to "/home/nym/.nym/service-providers/network-requester/bitcoin/config/config.toml"
Using gateway: 2xU4CBE6QiiYt6EyBXSALwxkNvM7gqJfjHXaMkjiFmYW
Client configuration completed.

Version: 1.1.14
ID: bitcoin
Identity key: <a data-footnote-ref href="#user-content-fn-1">84K1SPBsSPGcCGQ6hK4AYKXuZHb5iU3zBc9gYb3cJp6o</a>
Encryption: Cfc67agMVw6GRjPb7ZyEfZSwLeVSvYtqKCKmATewYJa5
Gateway ID: 2xU4CBE6QiiYt6EyBXSALwxkNvM7gqJfjHXaMkjiFmYW
Gateway: ws://194.182.172.173:9000
Address of this network-requester: <a data-footnote-ref href="#user-content-fn-2">84K1SPBsSPGcCGQ6hK4AYKXuZHb5iU3zBc9gYb3cJp6o.Cfc67agMVw6GRjPb7ZyEfZSwLeVSvYtqKCKmATewujajT@2xU4CBE6QiiYt6EyBXSALwxkNvM7gqJfjHXaMkjhdjywS</a>
</code></pre>

</details>

{% hint style="info" %}
Take note of your network-requester address, (**\<requesteraddress>)**
{% endhint %}

> Example -->`Address of this network-requester: 84K1SPBsSPGcCGQ6hK4AYKXuZHb5iU3zBc9gYb3cJp6o.Cfc67agMVw6GRjPb7ZyEfZSwLeVSvYtqKCKmATewujajT@2xU4CBE6QiiYt6EyBXSALwxkNvM7gqJfjHXaMkjhdjywS`

* Exit from the nym user session

```bash
$ exit
```

### **Autostart on boot**

The system needs to run the network requester daemon automatically in the background, even when nobody is logged in. We use `"systemd"`, a daemon that controls the startup process using configuration files.

* Create the configuration file in the nano text editor and copy the following paragraph. Save and exit

<pre class="language-bash"><code class="lang-bash"><strong>$ sudo nano /etc/systemd/system/nym-network-requester.service
</strong></code></pre>

```
# MiniBolt: systemd unit for nym network requester
# /etc/systemd/system/nym-network-requester.service

[Unit]
Description=Nym Network Requester
StartLimitInterval=350
StartLimitBurst=10

[Service]
User=nym
LimitNOFILE=65536
ExecStart=/home/nym/nym-network-requester run --id bitcoin --open-proxy
KillSignal=SIGINT
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
```

* Enable autoboot

```bash
$ sudo systemctl enable nym-network-requester
```

* Prepare “nym-network-requester” monitoring by the systemd journal and check the logging output. You can exit monitoring at any time with Ctrl-C

```bash
$ sudo journalctl -f -u nym-network-requester
```

### Running NYM network requester

To keep an eye on the software movements, [start your SSH program](../../system/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as "admin". Commands for the **second session** start with the prompt `$2` (which must not be entered).

* Start the nym network requester service

```bash
$2 sudo systemctl start nym-network-requester
```

<details>

<summary>Example of expected output ⬇️</summary>

```
Jun 25 20:43:00 minibolt systemd[1]: Started Nym Network Requester.
Jun 25 20:43:00 minibolt nym-network-requester[1774351]:  2023-06-25T18:43:00.402Z INFO  nym_network_requester::cli::run > Starting socks5 service provider
Jun 25 20:43:00 minibolt nym-network-requester[1774351]:  2023-06-25T18:43:00.592Z INFO  nym_client_core::client::base_client::non_wasm_helpers > creating fresh surb database
Jun 25 20:43:00 minibolt nym-network-requester[1774351]:  2023-06-25T18:43:00.644Z INFO  nym_client_core::client::replies::reply_storage::backend::fs_backend::manager > Database migration finished!
Jun 25 20:43:00 minibolt nym-network-requester[1774351]:  2023-06-25T18:43:00.718Z INFO  nym_client_core::client::base_client                                          > Starting nym client
Jun 25 20:43:01 minibolt nym-network-requester[1774351]:  2023-06-25T18:43:01.104Z INFO  nym_gateway_client::client                                                    > the gateway is using exactly the same protocol version as we are. We're good to continue!
Jun 25 20:43:01 minibolt nym-network-requester[1774351]:  2023-06-25T18:43:01.104Z INFO  nym_gateway_client::client                                                    > Claiming more bandwidth for your tokens. This will use 1 token(s) from your wallet. Stop the process now if you don't want that to happen.
Jun 25 20:43:01 minibolt nym-network-requester[1774351]:  2023-06-25T18:43:01.104Z WARN  nym_gateway_client::client                                                    > Not enough bandwidth. Trying to get more bandwidth, this might take a while
Jun 25 20:43:01 minibolt nym-network-requester[1774351]:  2023-06-25T18:43:01.104Z INFO  nym_gateway_client::client                                                    > The client is running in disabled credentials mode - attempting to claim bandwidth without a credential
Jun 25 20:43:01 minibolt nym-network-requester[1774351]:  2023-06-25T18:43:01.155Z INFO  nym_client_core::client::base_client                                          > Obtaining initial network topology
Jun 25 20:43:01 minibolt nym-network-requester[1774351]:  2023-06-25T18:43:01.581Z INFO  nym_client_core::client::base_client                                          > Starting topology refresher...
Jun 25 20:43:01 minibolt nym-network-requester[1774351]:  2023-06-25T18:43:01.581Z INFO  nym_client_core::client::base_client                                          > Starting received messages buffer controller...
Jun 25 20:43:01 minibolt nym-network-requester[1774351]:  2023-06-25T18:43:01.581Z INFO  nym_client_core::client::base_client                                          > Starting mix traffic controller...
Jun 25 20:43:01 minibolt nym-network-requester[1774351]:  2023-06-25T18:43:01.581Z INFO  nym_client_core::client::base_client                                          > Starting real traffic stream...
Jun 25 20:43:01 minibolt nym-network-requester[1774351]:  2023-06-25T18:43:01.581Z INFO  nym_client_core::client::base_client                                          > Starting loop cover traffic stream...
Jun 25 20:43:01 minibolt nym-network-requester[1774351]:  2023-06-25T18:43:01.581Z INFO  nym_network_requester::core                                                   > The address of this client is: Zq2pc3b7tiSWbjdgvQi9Xw5WLvmVVzfTouSvy8DUws9.HCThYe3mTBHPZDayqH46p73iYLMe3GNEKrgVtoPjkhdj@BTZNB3bkkEePsT14GN8ofVtM1SJae4YLWjpBerrKust
Jun 25 20:43:01 minibolt nym-network-requester[1774351]:  2023-06-25T18:43:01.581Z INFO  nym_network_requester::core                                                   > All systems go. Press CTRL-C to stop the server.
Jun 25 20:43:01 minibolt nym-network-requester[1774351]:  2023-06-25T18:43:01.582Z INFO  nym_network_requester::allowed_hosts::standard_list                           > Refreshing standard allowed hosts
```

</details>

### Install NYM socks5 client

* Staying in the temporary folder, copy to the home nym user the "nym socks5 client" binary

```bash
$ cd /tmp
```

```bash
$ sudo cp /tmp/nym/target/release/nym-socks5-client /home/nym/
```

* Assign the owner of the binary to the nym user&#x20;

```bash
$ sudo chown nym:nym /home/nym/nym-socks5-client
```

### Init NYM  socks5 client

* Switch to the user "nym"

```bash
$ sudo su - nym
```

* Init the nym socks5 client for the first time with `gateway based selection` flag to choose a gateway based on its location relative to your device and replace **\<requesteraddress>** with the obtained in the [Run NYM network requester](nym-mixnet.md#run-nym-network-requester) step before

{% code overflow="wrap" %}
```bash
$ ./nym-socks5-client init --id bitcoin --latency-based-selection --provider <requesteraddress>
```
{% endcode %}

<details>

<summary>Example of expected output ⬇️</summary>

```
      _ __  _   _ _ __ ___
     | '_ \| | | | '_ \ _ \
     | | | | |_| | | | | | |
     |_| |_|\__, |_| |_| |_|
            |___/

             (nym-socks5-client - version 1.1.21)


Initialising client...
 2023-06-17T20:32:16.857Z INFO  nym_client_core::init::helpers > choosing gateway by latency...
 2023-06-17T20:32:36.948Z INFO  nym_client_core::init::helpers > chose gateway FQon7UwF5knbUr2jf6jHhmNLbJnMreck1eUcVH59kxYE with average latency of 44.796394ms
Registering with new gateway
 2023-06-17T20:32:37.195Z INFO  nym_gateway_client::client     > the gateway is using exactly the same protocol version as we are. We're good to continue!
 2023-06-17T20:32:37.200Z INFO  nym_config                     > Configuration file will be saved to "/home/nym/.nym/socks5-clients/bitcoin/config/config.toml"
Saved configuration file to "/home/nym/.nym/socks5-clients/bitcoin/config/config.toml"
Using gateway: FQon7UwF5knbUr2jf6jHhmNLbJnMreck1eUcVH59kxYE
Client configuration completed.

Version: 1.1.14
ID: bitcoin
Identity key: GwFEXSpQP1VFZwDdYRkuRTUpQ28v3zvZbq3mtQnNELwr
Encryption: EeAiN8mySPwcFco1hgipD86ymzK8UfShjgdMKkKvbk3a
Gateway ID: FQon7UwF5knbUr2jf6jHhmNLbJnMreck1eUcVH59kxYE
Gateway: ws://116.203.182.89:9000
SOCKS5 listening port: 1080
Address of this client: GwFEXSpQP1VFZwDdYRkuRTUpQ28v3zvZbq3mtQnNELwr.EeAiN8mySPwcFco1hgipD86ymzK8UfShjgdMKkKvghste@FQon7UwF5knbUr2jf6jHhmNLbJnMreck1eUcVH59usta
```

</details>

* Exit from the nym user session

```bash
$ exit
```

### **Autostart on boot**

The system needs to run the network requester daemon automatically in the background, even when nobody is logged in. We use `"systemd"`, a daemon that controls the startup process using configuration files.

* Create the configuration file in the nano text editor and copy the following paragraph. Save and exit

```bash
$ sudo nano /etc/systemd/system/nym-socks5-client.service
```

```
# MiniBolt: systemd unit for nym socks5 client
# /etc/systemd/system/nym-socks5-client.service

[Unit]
Description=Nym Socks5 client
StartLimitInterval=350
StartLimitBurst=10

[Service]
User=nym
LimitNOFILE=65536
ExecStart=/home/nym/nym-socks5-client run --id bitcoin
KillSignal=SIGINT
Restart=on-failure
RestartSec=30


[Install]
WantedBy=multi-user.target
```

* Enable autoboot

```bash
$ sudo systemctl enable nym-network-requester
```

* Prepare “nym-socks5-client” monitoring by the systemd journal and check the logging output. You can exit monitoring at any time with Ctrl-C

```bash
$ sudo journalctl -f -u nym-socks5-client
```

### Running NYM socks5 client

To keep an eye on the software movements, [start your SSH program](../../system/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as "admin". Commands for the **second session** start with the prompt `$2` (which must not be entered).

* Start the nym socks5 client service

```bash
$2 sudo systemctl start nym-socks5-client
```

<details>

<summary>Example of expected output ⬇️</summary>

```
Jun 25 21:19:30 minibolt systemd[1]: Started Nym Socks5 client.
Jun 25 21:19:30 minibolt nym-socks5-client[1776937]:  2023-06-25T19:19:30.577Z INFO  nym_client_core::client::base_client                                          > Starting nym client
Jun 25 21:19:30 minibolt nym-socks5-client[1776937]:  2023-06-25T19:19:30.947Z INFO  nym_gateway_client::client                                                    > the gateway is using exactly the same protocol version as we are. We're good to continue!
Jun 25 21:19:30 minibolt nym-socks5-client[1776937]:  2023-06-25T19:19:30.947Z INFO  nym_gateway_client::client                                                    > Claiming more bandwidth for your tokens. This will use 1 token(s) from your wallet. Stop the process now if you don't want that to happen.
Jun 25 21:19:30 minibolt nym-socks5-client[1776937]:  2023-06-25T19:19:30.947Z WARN  nym_gateway_client::client                                                    > Not enough bandwidth. Trying to get more bandwidth, this might take a while
Jun 25 21:19:30 minibolt nym-socks5-client[1776937]:  2023-06-25T19:19:30.947Z INFO  nym_gateway_client::client                                                    > The client is running in disabled credentials mode - attempting to claim bandwidth without a credential
Jun 25 21:19:30 minibolt nym-socks5-client[1776937]:  2023-06-25T19:19:30.987Z INFO  nym_client_core::client::base_client                                          > Obtaining initial network topology
Jun 25 21:19:31 minibolt nym-socks5-client[1776937]:  2023-06-25T19:19:31.394Z INFO  nym_client_core::client::base_client                                          > Starting topology refresher...
Jun 25 21:19:31 minibolt nym-socks5-client[1776937]:  2023-06-25T19:19:31.394Z INFO  nym_client_core::client::base_client                                          > Starting received messages buffer controller...
Jun 25 21:19:31 minibolt nym-socks5-client[1776937]:  2023-06-25T19:19:31.394Z INFO  nym_client_core::client::base_client                                          > Starting mix traffic controller...
Jun 25 21:19:31 minibolt nym-socks5-client[1776937]:  2023-06-25T19:19:31.394Z INFO  nym_client_core::client::base_client                                          > Starting real traffic stream...
Jun 25 21:19:31 minibolt nym-socks5-client[1776937]:  2023-06-25T19:19:31.394Z INFO  nym_client_core::client::base_client                                          > Starting loop cover traffic stream...
Jun 25 21:19:31 minibolt nym-socks5-client[1776937]:  2023-06-25T19:19:31.394Z INFO  nym_socks5_client_core                                                        > Running with Mix packets
Jun 25 21:19:31 minibolt nym-socks5-client[1776937]:  2023-06-25T19:19:31.394Z INFO  nym_socks5_client_core                                                        > Starting socks5 listener...
Jun 25 21:19:31 minibolt nym-socks5-client[1776937]:  2023-06-25T19:19:31.394Z INFO  nym_socks5_client_core::socks::server                                         > Listening on 127.0.0.1:1080
Jun 25 21:19:31 minibolt nym-socks5-client[1776937]:  2023-06-25T19:19:31.394Z INFO  nym_socks5_client_core                                                        > Client startup finished!
Jun 25 21:19:31 minibolt nym-socks5-client[1776937]:  2023-06-25T19:19:31.394Z INFO  nym_socks5_client_core                                                        > The address of this client is: GjcMYVkzBmX51e4ZGPknAAgc7Zdk5pn3d9jaAmKMszK9.C82LFDSF6MXfJcZb4rxt3vJSrDBMmSPi2BoAPerthFsg@FYnDMQzT49ZGM23gVqpTxfih14V6wuedNXirekmtIshr
Jun 25 21:19:31 minibolt nym-socks5-client[1776937]:  2023-06-25T19:19:31.394Z INFO  nym_socks5_client_core::socks::server                                         > Serving Connections...
```

</details>

* Ensure the service is working and listening at the default `1080` port

```bash
$2 sudo ss -tulpn | grep LISTEN | grep nym-socks5
```

Expected output:



* Delete the NYM compilation folder to be ready for the next update and free up space

```bash
$ sudo rm -r /tmp/nym
```

## For the future: upgrade NYM binaries

Follow again the entire [**Compile NYM binaries from the source code**](nym-mixnet.md#compile-nym-binaries-from-the-source-code) section until the **"Enter the command to compile"** step (inclusive), once you do that, continue with the next steps below

* Stop the network requester and the socks5 client

```bash
$ sudo systemctl stop nym-network-requester
```

```bash
$ sudo systemctl stop nym-socks5-client
```

**For the Network requester**

* Replace the network requester binary

```bash
$ sudo cp /tmp/nym/target/release/nym-network-requester /home/nym/
```

* Change to the nym user

```bash
$ sudo su - nym
```

* Init again the network requester to update the `config.toml` file if needed

```bash
$ ./nym-network-requester init --id bitcoin --latency-based-selection
```

* Check the correct update

```bash
$ ./nym-network-requester -V
```

<details>

<summary>Example of expected output ⬇️</summary>

```
      _ __  _   _ _ __ ___
     | '_ \| | | | '_ \ _ \
     | | | | |_| | | | | | |
     |_| |_|\__, |_| |_| |_|
            |___/

             (nym-network-requester - version 1.1.21)


nym-network-requester 1.1.21
```

</details>

* Exit from the nym user session

```bash
$ exit
```

* Start network requester again

```bash
$ sudo systemctl start nym-network-requester
```

**For the Socks5 client**

* Replace the socks5 client binary

```bash
$ sudo cp /tmp/nym/target/release/nym-socks5-client /home/nym/
```

* Change to the nym user

```bash
$ sudo su - nym
```

* Init again the socks5 client with the same command and service provider, this update the `config.toml` file if needed

{% code overflow="wrap" %}
```bash
$ ./nym-socks5-client init --id bitcoin --latency-based-selection --provider <requesteraddress>
```
{% endcode %}

* Check the correct update

```bash
$ ./nym-socks5-client -V
```

<details>

<summary>Example of expected output ⬇️</summary>

```
      _ __  _   _ _ __ ___
     | '_ \| | | | '_ \ _ \
     | | | | |_| | | | | | |
     |_| |_|\__, |_| |_| |_|
            |___/

             (nym-socks5-client - version 1.1.21)


nym-socks5-client 1.1.21
```

</details>

* Exit from the nym user

```bash
$ exit
```

* Start socks5 client again

```bash
$ sudo systemctl start nym-socks5-client
```

* Delete the NYM compilation folder to be ready for the next update and free up space

```bash
$ sudo rm -r /tmp/nym
```

## Uninstall

* Stop network requester and socks5 client services

```bash
$ sudo systemctl stop nym-network-requester
```

```bash
$ sudo systemctl stop nym-socks5-client
```

* Delete network requester and socks5 client services

```bash
$ sudo rm /etc/systemd/system/nym-network-requester.service
```

```bash
$ sudo rm /etc/systemd/system/nym-socks5-client.service
```

* Delete nym user. Don't worry about `userdel: nym mail spool (/var/mail/nym) not found` output, the uninstall has been successful

```bash
$ sudo userdel -rf nym
```

[^1]: ID key of the gateway selected by latency

[^2]: Your service provider address (take note)
