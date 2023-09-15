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

A [nostr relay written in Rust](https://github.com/scsibug/nostr-rs-relay) with support for the entire relay protocol and data persistence using SQLite

<figure><img src="../../.gitbook/assets/nostr-relay-gif.gif" alt=""><figcaption></figcaption></figure>

## Requisites

* [Cloudflare tunnel](../system/cloudflare-tunnel.md)

## Preparations

#### Install dependencies

* With user `admin`, make sure that all necessary software packages are installed (pending to concrete)

{% code overflow="wrap" %}
```bash
$ sudo apt install build-essential cmake protobuf-compiler pkg-config libssl-dev build-essential sqlite3 libsqlite3-dev
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

* Also Cargo

```bash
$ cargo -V
```

**Example** of expected output:

```
> cargo 1.71.0 (cfd3bbd8f 2023-06-08)
```

{% hint style="info" %}
If you obtain "**command not found**" outputs, you need to follow the [Rustup + Cargo bonus section](../system/rustup-+-cargo.md) to install it and then come back to continue with the guide
{% endhint %}

## Installation

* With user `admin`, go to the temporary folder

```bash
$ cd /tmp
```

* Clone the source code directly from the GitHub repository, and then build a release version of the relay

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

<details>

<summary>Expected output ⬇️</summary>

```
    Updating crates.io index
  Downloaded pathdiff v0.2.1
  Downloaded num_cpus v1.16.0
  Downloaded indexmap v2.0.0
  Downloaded parking_lot_core v0.9.8
  Downloaded want v0.3.1
  Downloaded pest v2.7.2
  Downloaded percent-encoding v2.3.0
  Downloaded parse_duration v2.1.1
  Downloaded prost-build v0.11.9
  Downloaded clap_lex v0.5.0
  Downloaded autocfg v0.1.8
  Downloaded fastrand v2.0.0
  Downloaded is-terminal v0.4.9
  Downloaded json5 v0.4.1
  Downloaded num v0.2.1
  Downloaded paste v1.0.14
  Downloaded pin-project-internal v1.1.3
  Downloaded num-iter v0.1.43
  Downloaded fallible-streaming-iterator v0.1.9
  Downloaded md-5 v0.10.5
  Downloaded linked-hash-map v0.5.6
  Downloaded number_prefix v0.4.0
  Downloaded itoa v1.0.9
  Downloaded openssl-sys v0.9.91
  Downloaded async-lock v2.7.0
  Downloaded pest_derive v2.7.2
  Downloaded async-channel v1.9.0
  Downloaded tokio-io-timeout v1.2.0
  Downloaded async-global-executor v2.3.1
  Downloaded sync_wrapper v0.1.2
  Downloaded matchers v0.1.0
  Downloaded no-std-compat v0.4.1
  Downloaded block-padding v0.3.3
  Downloaded pest_generator v2.7.2
  Downloaded atomic-waker v1.1.1
  Downloaded pin-project-lite v0.2.12
  [...]
```

</details>

* Install it

<pre class="language-bash" data-overflow="wrap"><code class="lang-bash"><strong>$ sudo install -m 0755 -o root -g root -t /usr/local/bin /tmp/nostr-rs-relay/target/release/nostr-rs-relay
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

* (Optional) If you want to use the MiniBolt `favicon.ico` file, download by entering this command

{% code overflow="wrap" %}
```bash
$ wget https://raw.githubusercontent.com/minibolt-guide/minibolt/nostr-relay-PR/resources/favicon.ico
```
{% endcode %}

* Delete the `nostr-rs-relay` folder to be ready for the next update

```bash
$ sudo rm -r /tmp/nostr-rs-relay
```

* Exit to the `admin` user

```bash
$ exit
```

### Configuration

* With user `admin`, copy-paste the configuration file

```bash
$ sudo cp /tmp/nostr-rs-relay/config.toml /home/nostr/relay/
```

* Assign as the owner to the `nostr` user

```bash
$ sudo chown nostr:nostr /home/nostr/relay/config.toml
```

* Edit the config file, uncomment, and replace the needed information on the parameters

```bash
$ sudo nano /home/nostr/relay/config.toml
```

**Required same as next:**

> > favicon = "favicon.ico"
>
> > data\_directory = "/home/nostr/relay/db"
>
> > address = "127.0.0.1"
>
> > port = 8880
>
> > remote\_ip\_header = "cf-connecting-ip"
>
> **Optional (customize):**\
> Edit the **\[info]** section, using your nostr information as owner and different data of you wish for your Nostr relay.
>
> (Optional) If you want, use the same `favicon.ico` file downloaded before (the relay's icon of MiniBolt) and the value `relay_icon` parameter, or replace with your own.&#x20;
>
> **Customize this with your own info:**
>
> > relay\_url = "[`<yourelayurl>`](#user-content-fn-1)[^1]"
>
> > name = "[`<nametotherelay>`](#user-content-fn-2)[^2]"
>
> > description = "[`<descriptionrelay>`](#user-content-fn-3)[^3]"
>
> > pubkey = "[`<yournostrhexpubkey>`](#user-content-fn-4)[^4]"
>
> > contact = "[`<yourcontact>`](#user-content-fn-5)[^5]"
>
> > relay\_icon = "[`<yourelayiconURL>`](#user-content-fn-6)[^6]"

## **Create systemd service**

The system needs to run the nostr relay daemon automatically in the background, even when nobody is logged in. We use `systemd`, a daemon that controls the startup process using configuration files.

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
$ journalctl -fu nostr-relay
```

## Running nostr relay

To keep an eye on the software movements, [start your SSH program](../../index-1/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`. Commands for the **second session** start with the prompt `$2` (which must not be entered).

* Start the nostr relay

```bash
$2 sudo systemctl start nostr-relay
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>$ journalctl -f -u nostr-relay</code> ⬇️</summary>

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

### Cloudflare tunnel

Follow the [Cloudflare Tunnel bonus guide](nostr-relay.md#cloudflare-tunnel), when you arrive at the [Configuration file section](../system/cloudflare-tunnel.md#create-a-configuration-file), add the next `# Nostr relay` lines

```bash
$ nano /home/admin/.cloudflared/config.yml
```

<pre><code># MiniBolt: cloudflared configuration
# /home/admin/.cloudflared/config.yml

tunnel: &#x3C;UUID>
credentials-file: /home/admin/.cloudflared/&#x3C;UUID>.json

ingress:

# Nostr relay
  - hostname: <a data-footnote-ref href="#user-content-fn-7">relay</a>.<a data-footnote-ref href="#user-content-fn-8">&#x3C;domain.com></a>
    service: ws://localhost:8880

  - service: http_status:404
</code></pre>

* Restart the Cloudflared service

```bash
$ sudo systemctl restart cloudflared
```

* Check the Cloudflared logs

```bash
$ journalctl -fu cloudflared
```

#### Check relay connection

3 different methods:

1. Go to the [nostr.watch](https://nostr.watch) website to check and test the relay connection

Access to the URL, replacing `<relay.domain.com>` with your Nostr relay URL: `https://nostr.watch/relay/relay.domain.com,` example: [https://nostr.watch/relay/relay.damus.io](https://nostr.watch/relay/relay.damus.io)

Expected output:

<figure><img src="../../.gitbook/assets/relay-connection.PNG" alt=""><figcaption></figcaption></figure>

2. Go to the [websocketking.com](https://websocketking.com/) website, type in the WebSocket URL box your Nostr relay URL e.g. `wss://relay.domain.com`, and click on the **\[Connect]** button

**Example** of expected output:

<figure><img src="../../.gitbook/assets/relay-test-connected.PNG" alt=""><figcaption></figcaption></figure>

3. Use a client to check the connection to the relay

#### Mobile:

Amethyst

**Desktop:**

**Web:**

## For the future: Nostr Relay upgrade

* With user `admin`, stop `nostr-rs-relay` service

```bash
$ sudo systemctl stop nostr-relay
```

* Follow the complete [Installation](nostr-relay.md#installation) section **without deleting the nostr-rs-relay folder of the temporary folder**
* Replace the `config.toml` file with the new one of the new version

{% hint style="warning" %}
This step is only necessary if you see changes on the config file template since your current version until the current release, you can display this on this [history link](https://github.com/scsibug/nostr-rs-relay/commits/master/config.toml)
{% endhint %}

* Backup the `config.toml` file

```bash
$ sudo cp /home/nostr/relay/config.toml /home/nostr/relay/config.toml.backup
```

* Assign as the owner to the `nostr` user

```bash
$ sudo chown nostr:nostr /home/nostr/relay/config.toml.backup
```

* Replace the new `config.toml` file of the new release

```bash
$ sudo cp /tmp/nostr-rs-relay/config.toml /home/nostr/relay/
```

* Edit the config file and replace it with the same old information of the file. Save and exit

```bash
$ sudo nano /home/nostr/relay/config.toml
```

* Start `nostr-rs-relay` service again

```bash
$ sudo systemctl start nostr-relay
```

* Delete the `nostr-rs-relay` folder to be ready for the next update

```bash
$ sudo rm -r /tmp/nostr-rs-relay
```

## Extras

### Broadcast the past events to your new relay (optional)

If you want all your past events to be accessible through your new relay, you can back them up by following these instructions:

* Go to [metadata.nostr.com](https://metadata.nostr.com) website, log in **\[Load My Profile]**, and click on **\[Relays]**
* Add your new Nostr relay **`[wss://relay.domain.com]`** address to the list of preferred relays in your profile (in the empty box below), select the **read+write** option, and click the **\[Update]** button
* Go to [nostryfied.amethyst.social](https://nostryfied.amethyst.social) webpage and log in **\[Get from extension]**, or manually enter the \[npub... of your Nostr profile
* Click the **\[Backup & Broadcast]** button...

<figure><img src="../../.gitbook/assets/broadcast-relay.png" alt="" width="319"><figcaption></figcaption></figure>

{% hint style="info" %}
Please wait patiently until all processes are finished. This might take some time, depending on the number of events you've published on Nostr with that pubkey meaning the interactions you've had on Nostr. Optionally, you can also save a copy of all your events locally as you'll have the download option
{% endhint %}

### Other interesting Nostr clients

{% tabs %}
{% tab title="Coracle" %}
Coracle is a web client for the Nostr protocol focused on pushing the boundaries of what's unique about Nostr, including relay selection and management, web-of-trust based moderation and content recommendations, and privacy protection.

[Web](https://coracle.social/) | [GitHub](https://github.com/coracle-social/coracle)
{% endtab %}

{% tab title="Snort" %}
A nostr UI built with React aiming for speed and efficiency.

[Web](https://snort.social) | [Git](https://git.v0l.io/Kieran/snort)
{% endtab %}

{% tab title="Zap stream" %}
Nostr live streaming

[Web](https://zap.stream/) | [GitHub](https://github.com/v0l/zap.stream)
{% endtab %}

{% tab title="Rana" %}
Nostr public key mining tool

[GitHub](https://github.com/grunch/rana)
{% endtab %}

{% tab title="URL Shortener" %}
A free URL shortener service enabled by the NOSTR protocol, that is fast and fuss-free, stripped of all bells and whistles, no gimmicks—it just works!

[Web](https://w3.do/) | [GitHub](https://github.com/jinglescode/nostr-url-shortener)
{% endtab %}
{% endtabs %}

{% tabs %}
{% tab title="Nostree" %}
A Nostr-based application to create, manage and discover link lists, show notes and other stuff.

[Web](https://nostree.me/) | [GitHub](https://github.com/gzuuus/linktr-nostr)
{% endtab %}

{% tab title="Second Tab" %}

{% endtab %}
{% endtabs %}

[^1]: Example: "wss://relay.minibolt/"

[^2]: Example: "MiniBolt Relay"

[^3]: Example: "The Nostr relay of the MiniBolt project"

[^4]: Example: "b17fccdf07ba2387f038b34426720cd68d112df923bca2bed8f8c309b7211155"

[^5]: Example: "hello@minibolt.info"

[^6]: Example: "https://cdn.nostr.build/i/35cb7871786875878269f04faafd3be8b5a536b9c4ce5f4bbbf82742873bc222.png"

[^7]: This is only an example of a subdomain related for a nostr relay

[^8]: Here your personal domain
