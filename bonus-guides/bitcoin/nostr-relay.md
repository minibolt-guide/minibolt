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

# Nostr relay

A nostr relay written in Rust with support for the entire relay protocol and data persistence using SQLite

<figure><img src="../../.gitbook/assets/nostr-relay-gif.gif" alt=""><figcaption></figcaption></figure>

## Requisites

* [Cloudflare tunnel](../system/cloudflare-tunnel.md)

## Preparations

#### Install dependencies

* With user `admin`, make sure that all necessary software packages are installed (pending to concrete)

{% code overflow="wrap" %}
```bash
& sudo apt install build-essential cmake protobuf-compiler pkg-config libssl-dev build-essential sqlite3 libsqlite3-dev
```
{% endcode %}

* Check if you already have Rustup installed

```bash
$ rustc --version
```

**Example** of expected output:

```
> rustc 1.71.0 (8ede3aae2 2023-07-12)
```

* And Cargo too

```bash
$ cargo -V
```

**Example** of expected output:

```
> cargo 1.71.0 (cfd3bbd8f 2023-06-08)
```

{% hint style="info" %}
If you obtain "**command not found**" outputs, you need to follow the [Rustup + Cargo bonus section](rustup-+-cargo.md) to install it and then come back to continue with the guide
{% endhint %}

## Installation

* With user `admin`, go to the temporary folder

```bash
$ cd /tmp
```

* Clone the source code directly from GitHub repository, and then build a release version of the relay

```bash
$ git clone https://github.com/scsibug/nostr-rs-relay.git
```

* Go to the folder recently created

```bash
$ cd nostr-rs-relay
```

* Build a release version of the relay

```bash
$ cargo build --release
```

* Install it

<pre class="language-bash" data-overflow="wrap"><code class="lang-bash"><strong>&#x26; sudo install -m 0755 -o root -g root -t /usr/local/bin /tmp/nostr-rs-relay/target/release/nostr-rs-relay
</strong></code></pre>

* Check the correct installation

```bash
$ nostr-rs-relay -V
```

**Example** of expected output:

```
> nostr-rs-relay 0.8.9
```

### Create the nostr user

* Create the user `nostr` with this command

```bash
$ sudo adduser --gecos "" --disabled-password nostr
```

* Change to the home `nostr` user folder

```bash
$ sudo su - nostr
```

* Create the `relay` and `db` folders

```bash
$ mkdir -p relay/db
```

* Exit to the `admin` user

```bash
$ exit
```

### Configuration

* With user `admin`, copy-paste the configuration file

```bash
$ cp /tmp/nostr-rs-relay/config.toml /home/nostr/relay/
```

* Assign as the owner to the `nostr` user

```bash
$ sudo chown nostr:nostr /home/nostr/relay/config.toml 
```

* Edit the config file

```bash
$ sudo nano /home/nostr/relay/config.toml
```

> > data\_directory = "/home/nostr/relay/db"
>
> > address = "127.0.0.1"
>
> > port = 8880
>
> > remote\_ip\_header = "cf-connecting-ip"

## **Create systemd service**

The system needs to run the nostr relay daemon automatically in the background, even when nobody is logged in. We use `"systemd"`, a daemon that controls the startup process using configuration files.

* With the user `admin`, Create the configuration file in the nano text editor and copy the following paragraph. Save and exit

<pre class="language-bash"><code class="lang-bash"><strong>$ sudo nano /etc/systemd/system/nostr-relay.service
</strong></code></pre>

```
# MiniBolt: systemd unit for nostr relay
# /etc/systemd/system/nostr-relay.service

[Unit]
Description=Nostr Relay
After=network.target

[Service]
Type=simple
User=nostr
WorkingDirectory=/home/nostr
Environment=RUST_LOG=info,nostr_rs_relay=info
ExecStart=/usr/local/bin/nostr-rs-relay -c /home/nostr/relay/config.toml
TimeoutStopSec=10
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

* Enable autoboot **(optional)**

```bash
$ sudo systemctl enable nostr-relay
```

* Prepare “nostr-relay” monitoring by the systemd journal and check the logging output. You can exit monitoring at any time with Ctrl-C

```bash
$ sudo journalctl -fu nostr-relay
```

## Running nostr relay

To keep an eye on the software movements, [start your SSH program](../../system/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as "admin". Commands for the **second session** start with the prompt `$2` (which must not be entered).

* Start the nostr relay

```bash
$2 sudo systemctl start nostr-relay
```

<details>

<summary>Example of expected output ⬇️</summary>

```
Jul 31 19:05:59 minibolt nostr-rs-relay[35593]: 2023-07-31T19:05:59.232103Z  INFO nostr_rs_relay: Starting up from main
Jul 31 19:05:59 minibolt nostr-rs-relay[35593]: 2023-07-31T19:05:59.233677Z  INFO nostr_rs_relay::server: listening on: 127.0.0.1:8008
Jul 31 19:05:59 minibolt nostr-rs-relay[35593]: 2023-07-31T19:05:59.241608Z  INFO nostr_rs_relay::repo::sqlite: Built a connection pool "writer" (min=0, max=2)
Jul 31 19:05:59 minibolt nostr-rs-relay[35593]: 2023-07-31T19:05:59.242695Z  INFO nostr_rs_relay::repo::sqlite: Built a connection pool "maintenance" (min=0, max=2)
Jul 31 19:05:59 minibolt nostr-rs-relay[35593]: 2023-07-31T19:05:59.244825Z  INFO nostr_rs_relay::repo::sqlite: Built a connection pool "reader" (min=4, max=8)
Jul 31 19:05:59 minibolt nostr-rs-relay[35593]: 2023-07-31T19:05:59.245895Z  INFO nostr_rs_relay::repo::sqlite_migration: DB version = 18
Jul 31 19:05:59 minibolt nostr-rs-relay[35593]: 2023-07-31T19:05:59.246417Z  INFO nostr_rs_relay::server: db writer created
Jul 31 19:05:59 minibolt nostr-rs-relay[35593]: 2023-07-31T19:05:59.246880Z  INFO nostr_rs_relay::server: control message listener started
Jul 31 19:06:59 minibolt nostr-rs-relay[35593]: 2023-07-31T19:06:59.250853Z  INFO nostr_rs_relay::repo::sqlite: checkpoint ran in 137.674µs (result: Ok, WAL size: 0)
Jul 31 19:07:59 minibolt nostr-rs-relay[35593]: 2023-07-31T19:07:59.255370Z  INFO nostr_rs_relay::repo::sqlite: checkpoint ran in 217.764µs (result: Ok, WAL size: 0)
Jul 31 19:08:59 minibolt nostr-rs-relay[35593]: 2023-07-31T19:08:59.261774Z  INFO nostr_rs_relay::repo::sqlite: checkpoint ran in 131.048µs (result: Ok, WAL size: 0)
Jul 31 19:09:59 minibolt nostr-rs-relay[35593]: 2023-07-31T19:09:59.265335Z  INFO nostr_rs_relay::repo::sqlite: checkpoint ran in 176.033µs (result: Ok, WAL size: 0)
Jul 31 19:10:59 minibolt nostr-rs-relay[35593]: 2023-07-31T19:10:59.270412Z  INFO nostr_rs_relay::repo::sqlite: checkpoint ran in 172.006µs (result: Ok, WAL size: 0)
Jul 31 19:11:59 minibolt nostr-rs-relay[35593]: 2023-07-31T19:11:59.275842Z  INFO nostr_rs_relay::repo::sqlite: checkpoint ran in 131.853µs (result: Ok, WAL size: 0)
```

</details>

* Ensure the service is working and listening at the default 8880 port

```bash
$ sudo ss -tulpn | grep LISTEN | grep nostr-rs-relay
```

Expected output:

```
> tcp   LISTEN 0   128   127.0.0.1:8880   0.0.0.0:*  users:(("nostr-rs-relay",pid=138820,fd=24))
```

## Extras

### Cloudflare tunnel
