---
title: Electrs
parent: + Bitcoin
grand_parent: Bonus Section
nav_exclude: true
has_children: false
has_toc: false
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

# Electrs

We set up [Electrs](https://github.com/romanz/electrs/) to serve as a full Electrum server for use with your Bitcoin software or hardware wallets.

{% hint style="warning" %}
Difficulty: Medium
{% endhint %}

![](../../images/electrs-logo.png)

## Preparations

Make sure that you have [reduced the database cache of Bitcoin Core](../../index-2/bitcoin-client.md#activate-mempool--reduce-dbcache-after-a-full-sync) after a full sync.

Electrs is a replacement for a [Fulcrum](../../bitcoin/electrum-server.md), these two services cannot be run at the same time (due to the same standard ports used), remember to stop Fulcrum by doing `"sudo systemctl stop fulcrum"`.

### **Install dependencies**

* With user `admin`, update the packages and upgrade to keep up to date with the OS

```sh
$ sudo apt update && sudo apt full-upgrade
```

* Make sure that all necessary software packages are installed

{% code overflow="wrap" %}
```sh
$ sudo apt install libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev make g++ clang cmake build-essential
```
{% endcode %}

* Install the `librocksdb v7.8.3` from the source code. Go to the temporary folder

```bash
$ cd /tmp
```

* Clone the `rocksdb` GitHub repository

```bash
$ git clone -b v7.8.3 --depth 1 https://github.com/facebook/rocksdb
```

* Enter to the `rocksdb` folder

```bash
$ cd rocksdb
```

* Compile it

```bash
$ make shared_lib -j $(nproc)
```

* Install it

```bash
$ sudo make install-shared
```

* Update the shared library cache

```bash
$ sudo ldconfig
```

* Check if you already have `Rustc` installed

```bash
$ rustc --version
```

Expected output:

```
> rustc 1.71.0 (8ede3aae2 2023-07-12)
```

* And cargo installed

```bash
$ cargo -V
```

Expected output:

```
> cargo 1.71.0 (cfd3bbd8f 2023-06-08)
```

{% hint style="info" %}
If you obtain "command not found" outputs, you need to follow the [Rustup + Cargo bonus section](https://v2.minibolt.info/bonus-guides/system/rustup-+-cargo) to install it and then come back to continue with the guide
{% endhint %}

### **Firewall & reverse proxy**

In the [Security section](broken-reference/), we already set up NGINX as a reverse proxy. Now we can add the Electrs configuration.

* Enable NGINX reverse proxy to add SSL/TLS encryption to the Electrs communication. Create the configuration file and paste the following content

```sh
$ sudo nano /etc/nginx/streams-enabled/electrs-reverse-proxy.conf
```

```nginx
upstream electrs {
  server 127.0.0.1:50001;
}
server {
  listen 50002 ssl;
  proxy_pass electrs;
}
```

* Test and reload NGINX configuration

```bash
$ sudo nginx -t
```

```sh
$ sudo systemctl reload nginx
```

* Configure the firewall to allow incoming requests

```sh
$ sudo ufw allow 50002/tcp comment 'allow Electrs SSL from anywhere'
```

```sh
$ sudo ufw allow 50001/tcp comment 'allow Electrs TCP from anywhere'
```

## Electrs

An easy and performant way to run an Electrum server is to use [Electrs](https://github.com/romanz/electrs), the Electrum Server in Rust. There are no binaries available, so we will compile the application ourselves.

### **Build from the source code**

We get the latest release of the Electrs source code, verify it, compile it to an executable binary, and install it.

* Download the source code for the latest Electrs release. You can check the [release page](https://github.com/romanz/electrs/releases) to see if a newer release is available. Other releases might not have been properly tested with the rest of the MiniBolt configuration

```sh
$ cd /tmp
```

* Set a temporary version environment variable to the installation

```sh
$ VERSION=0.10.0
```

```sh
$ git clone --branch v$VERSION https://github.com/romanz/electrs.git
```

```sh
$ cd electrs
```

* To avoid using bad source code, verify that the release has been properly signed by the main developer [Roman Zeyde](https://github.com/romanz)

```sh
$ curl https://romanzey.de/pgp.txt | gpg --import
```

Expected output:

```
>   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
>                                    Dload  Upload   Total   Spent    Left  Speed
> 100  1255  100  1255    0     0   3562      0 --:--:-- --:--:-- --:--:--  3555
> gpg: key 87CAE5FA46917CBB: public key "Roman Zeyde <me@romanzey.de>" imported
> gpg: Total number processed: 1
> gpg:               imported: 1
```

```sh
$ git verify-tag v$VERSION
```

Expected output:

```
> gpg: Signature made Thu 03 Nov 2022 03:37:23 PM UTC
> gpg:                using ECDSA key 15C8C3574AE4F1E25F3F35C587CAE5FA46917CBB
> gpg:                issuer "me@romanzey.de"
> gpg: Good signature from "Roman Zeyde <me@romanzey.de>" [unknown]
> gpg:                 aka "Roman Zeyde <roman.zeyde@gmail.com>" [unknown]
> gpg: WARNING: This key is not certified with a trusted signature!
> gpg:          There is no indication that the signature belongs to the owner.
> Primary key fingerprint: 15C8 C357 4AE4 F1E2 5F3F  35C5 87CA E5FA 4691 7CBB
```

* Now compile the source code into an executable binary

{% code overflow="wrap" %}
```bash
$ ROCKSDB_INCLUDE_DIR=/usr/local/include ROCKSDB_LIB_DIR=/usr/local/lib cargo build --locked --release
```
{% endcode %}

* Install it

{% code overflow="wrap" %}
```bash
$ sudo install -m 0755 -o root -g root -t /usr/local/bin ./target/release/electrs
```
{% endcode %}

<details>

<summary>Example of expected output 🔽</summary>

```
info: syncing channel updates for '1.63.0-x86_64-unknown-linux-gnu'
info: latest update on 2022-08-11, rust version 1.63.0 (4b91a6ea7 2022-08-08)
info: downloading component 'cargo'
info: downloading component 'clippy'
info: downloading component 'rust-docs'
info: downloading component 'rust-std'
info: downloading component 'rustc'
info: downloading component 'rustfmt'
info: installing component 'cargo'
info: installing component 'clippy'
info: installing component 'rust-docs'
info: installing component 'rust-std'
info: installing component 'rustc'
info: installing component 'rustfmt'
    Updating crates.io index
  Downloaded hex_lit v0.1.1
  Downloaded humantime v2.1.0
  Downloaded bitflags v1.3.2
  Downloaded getrandom v0.2.10
  Downloaded rand_chacha v0.3.1
  Downloaded is-terminal v0.4.7
  Downloaded lock_api v0.4.10
  Downloaded libloading v0.7.4
  Downloaded jsonrpc v0.14.1
  Downloaded jobserver v0.1.26
  Downloaded thiserror-impl v1.0.40
  Downloaded autocfg v1.1.0
  Downloaded dirs-sys-next v0.1.2
  Downloaded dirs-next v2.0.0
  Downloaded httpdate v1.0.2
  Downloaded configure_me v0.4.0
  Downloaded lazycell v1.3.0
  Downloaded num_cpus v1.16.0
[...]
```

</details>

* Check the correct installation

```sh
$ electrs --version
```

**Example** of expected output:

```
> v0.10.0
```

* Return to the home folder and delete the folder `/electrs` to be ready for the next update, if the prompt asks you `rm: remove write-protected regular file...` type `yes` and press `enter`

```sh
$ cd
```

```sh
$ rm -r /tmp/electrs
```
{% hint style="info" %}
If prompted to confirm the removal of a write protected file when deleting tmp/electrs directory, type "y".  
{% endhint %}
{% hint style="info" %}
If you come to update this is the final step.  
{% endhint %}

### **Configuration**

* Create the `electrs` user, and make it a member of the "bitcoin" group

```sh
$ sudo adduser --disabled-password --gecos "" electrs
```

```sh
$ sudo adduser electrs bitcoin
```

* Create the Electrs data directory

```sh
$ sudo mkdir /data/electrs
```

```sh
$ sudo chown -R electrs:electrs /data/electrs
```

* Switch to the `electrs` user and create the config file with the following content

```sh
$ sudo su - electrs
```

```sh
$ nano /data/electrs/electrs.conf
```

```
# MiniBolt: electrs configuration
# /data/electrs/electrs.conf

# Bitcoin Core settings
network = "bitcoin"
cookie_file= "/data/bitcoin/.cookie"
daemon_rpc_addr = "127.0.0.1:8332"
daemon_p2p_addr = "127.0.0.1:8333"

# Electrs settings
electrum_rpc_addr = "0.0.0.0:50001"
db_dir = "/data/electrs/db"
server_banner = "Welcome to electrs (Electrum Rust Server) running on a MiniBolt node!"

# Logging
log_filters = "INFO"
timestamp = true
```

* Exit `electrs` user session to return to the "admin" user session

```sh
$ exit
```

### **Create systemd service**

Electrs need to start automatically on system boot.

* As user `admin`, create the Electrs systemd unit, and copy/paste the following configuration. Save and exit

```sh
$ sudo nano /etc/systemd/system/electrs.service
```

```
# MiniBolt: systemd unit for electrs
# /etc/systemd/system/electrs.service

[Unit]
Description=Electrs
Wants=bitcoind.service
After=bitcoind.service

[Service]
ExecStart=/usr/local/bin/electrs --conf /data/electrs/electrs.conf --skip-default-conf-files
Type=simple
TimeoutSec=300
KillMode=process
User=electrs
RuntimeDirectory=electrs
RuntimeDirectoryMode=0710
PrivateTmp=true
ProtectSystem=full
ProtectHome=true
PrivateDevices=true
MemoryDenyWriteExecute=true

[Install]
WantedBy=multi-user.target
```

* Enable autoboot **(optional)**

```sh
$ sudo systemctl enable electrs
```

* Prepare "electrs" monitoring by the systemd journal and check log logging output. You can exit monitoring at any time by with `Ctrl-C`

```sh
$ journalctl -f -u electrs
```

## Run Electrs

To keep an eye on the software movements, [start your SSH program](../../index-1/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`. Commands for the **second session** start with the prompt `$2` (which must not be entered).

* Start the service. It will immediately start with the initial indexing of the Bitcoin blocks

```sh
$2 sudo systemctl start electrs
```

Monitor the systemd journal at the first session created to check if everything works fine

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>$ journalctl -f -u electrs</code> ⬇️</summary>

<pre><code>Starting electrs <a data-footnote-ref href="#user-content-fn-1">0.10.0</a> on x86_64 linux with Config { network: Bitcoin, db_path: "/data/electrs/db/bitcoin", daemon_dir: "/data/bitcoin", daemon_auth: CookieFile("/data/bitcoin/.cookie"), daemon_rpc_addr: 127.0.0.1:8332, daemon_p2p_addr: 127.0.0.1:8333, electrum_rpc_addr: 0.0.0.0:50001, monitoring_addr: 127.0.0.1:4224, wait_duration: 10s, jsonrpc_timeout: 15s, index_batch_size: 10, index_lookup_limit: None, reindex_last_blocks: 0, auto_reindex: true, ignore_mempool: false, sync_once: false, disable_electrum_rpc: false, server_banner: "Welcome to electrs (Electrum Rust Server) running on a MiniBolt node!", args: [] }
[2021-11-09T07:09:42.744Z INFO  electrs::metrics::metrics_impl] serving Prometheus metrics on 127.0.0.1:4224
[2021-11-09T07:09:42.744Z INFO  electrs::server] serving Electrum RPC on 0.0.0.0:50001
[2021-11-09T07:09:42.812Z INFO  electrs::db] "/data/electrs/db/bitcoin": 0 SST files, 0 GB, 0 Grows
[2021-11-09T07:09:43.174Z INFO  electrs::index] indexing 2000 blocks: [1..2000]
[2021-11-09T07:09:44.665Z INFO  electrs::chain] chain updated: tip=00000000dfd5d65c9d8561b4b8f60a63018fe3933ecb131fb37f905f87da951a, height=2000
[2021-11-09T07:09:44.986Z INFO  electrs::index] indexing 2000 blocks: [2001..4000]
[2021-11-09T07:09:46.191Z INFO  electrs::chain] chain updated: tip=00000000922e2aa9e84a474350a3555f49f06061fd49df50a9352f156692a842, height=4000
[2021-11-09T07:09:46.481Z INFO  electrs::index] indexing 2000 blocks: [4001..6000]
[2021-11-09T07:09:47.581Z INFO  electrs::chain] chain updated: tip=00000000dbbb79792303bdd1c6c4d7ab9c21bba0667213c2eca955e11230c5a5, height=6000
[2021-11-09T07:09:46.481Z INFO  electrs::index] indexing 2000 blocks: [6001..8000]
[2021-11-09T07:09:47.581Z INFO  electrs::chain] chain updated: tip=00000000dbbb79792303bdd1c6c4d7ab9c21bba0667213c2eca955e11230c5a6, height=8000
[2021-11-09T07:09:46.481Z INFO  electrs::index] indexing 2000 blocks: [8001..10000]
[2021-11-09T07:09:47.581Z INFO  electrs::chain] chain updated: tip=00000000dbbb79792303bdd1c6c4d7ab9c21bba0667213c2eca955e11230c5a7, height=10000
[...]
[2021-11-09T07:09:46.481Z INFO  electrs::index] indexing 65 blocks: [756001..756065]
[2021-11-09T07:09:47.581Z INFO  electrs::chain] chain updated: tip=00000000dbbb79792303bdd1c6c4d7ab9c21bba0667213c2eca955e11230c510, height=756065
[2021-11-09T07:09:47.581Z INFO  electrs::db] starting config compaction
[2021-11-09T07:09:47.581Z INFO  electrs::db] starting headers compaction
[2021-11-09T07:09:47.581Z INFO  electrs::db] starting txid compaction
[2021-11-09T07:09:47.581Z INFO  electrs::db] starting funding compaction
[2021-11-09T07:09:47.581Z INFO  electrs::db] starting spending compaction
[...]
</code></pre>

</details>

{% hint style="info" %}
Electrs will now index the whole Bitcoin blockchain so that it can provide all necessary information to wallets. With this, the wallets you use no longer need to connect to any third-party server to communicate with the Bitcoin peer-to-peer network
{% endhint %}

* Ensure electrs service is working and listening at the default `50001` port

```sh
$2 sudo ss -tulpn | grep LISTEN | grep electrs 
```

Expected output:

```bash
> tcp   LISTEN 0   128   0.0.0.0:50001   0.0.0.0:*    users:(("electrs",pid=158391,fd=4))
```

* And the reverse proxy `50002` port

```bash
$2 sudo ss -tulpn | grep LISTEN | grep 50002
```

Expected output:

```
> tcp   LISTEN 0   511   0.0.0.0:50002   0.0.0.0:*    users:(("nginx",pid=719,fd=5),("nginx",pid=718,fd=5),("nginx",pid=717,fd=5),("nginx",pid=716,fd=5),("nginx",pid=715,fd=5))
```

{% hint style="info" %}
Electrs must first fully index the blockchain and compact its database before you can connect to it with your wallets. This can take a few hours. Only proceed with the [next section](../../bitcoin/desktop-wallet.md) once Electrs is ready
{% endhint %}

## **Remote access over Tor (optional)**

To use your Electrum server when you're on the go, you can easily create a Tor hidden service. This way, you can connect the BitBoxApp or Electrum wallet also remotely, or even share the connection details with friends and family. Note that the remote device needs to have Tor installed as well.

* Ensure that you are logged in with the user admin and add the following lines in the "location hidden services" section, below "`## This section is just for location-hidden services ##`" in the torrc file. Save and exit

```sh
$ sudo nano /etc/tor/torrc
```

```
# Hidden Service Electrs TCP & SSL
HiddenServiceDir /var/lib/tor/hidden_service_electrs_tcp_ssl/
HiddenServiceVersion 3
HiddenServicePoWDefensesEnabled 1
HiddenServicePort 50001 127.0.0.1:50001
HiddenServicePort 50002 127.0.0.1:50002
```

* Reload the Tor configuration, get your connection addresses, and take note of these, later you will need them

```sh
$ sudo systemctl reload tor
```

```sh
$ sudo cat /var/lib/tor/hidden_service_electrs_tcp_ssl/hostname
```

Expected output:

```
> abcdefg..............xyz.onion
```

* You should now be able to connect to your Electrs server remotely via Tor using your hostname and port 50002 (SSL) or 50001 (TCP)

### **Migrate BTC RPC Explorer to Electrs API connection**

To get address balances, either an Electrum server or an external service is necessary. Your local Electrs server can provide address transaction lists, balances, and more.

* As user `admin`, open the `btcrpcexplorer` service

```sh
$ sudo nano /etc/systemd/system/btcrpcexplorer.service
```

* Replace the `"After=fulcrum.service"` with the `"After=electrs.service"` parameter. Save and exit

```sh
After=electrs.service
```

* Restart the BTC RPC Explorer service to apply the changes

```sh
$ sudo systemctl restart btcrpcexplorer
```

## For the future: Electrs upgrade

Updating Electrs is straightforward. You can display the current version with the command below and check the Electrs [release page](https://github.com/romanz/electrs/releases) to see if a newer version is available. Depending if you come from a version prior to `0.10.0` or not, you will need to follow an installation process or other:

> If you come from a version prior to `0.10.0`, follow the entire [Install dependencies](electrs.md#install-dependencies) to install the neccesary `librocksdb v7.8.3` dependency, and [Build from the source code](electrs.md#build-from-the-source-code) sections

> If not, follow only the complete [Build from the source code](electrs.md#build-from-the-source-code) section

* When you finish the section or both sections, restart Electrs to apply the new version

```sh
$ sudo systemctl restart electrs
```

* Check logs and pay attention to the next log if that attends to the new version installed

```bash
$ journalctl -fu electrs
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

<pre><code>Starting electrs <a data-footnote-ref href="#user-content-fn-2">0.10.0</a> on x86_64 linux with Config { network: Bitcoin, db_path: "/data/electrs/db/bitcoin", daemon_dir: "/data/bitcoin", daemon_auth: CookieFile("/data/bitcoin/.cookie"), daemon_rpc_addr: 127.0.0.1:8332, daemon_p2p_addr: 127.0.0.1:8333, electrum_rpc_addr: 0.0.0.0:50001, monitoring_addr: 127.0.0.1:4224, wait_duration: 10s, jsonrpc_timeout: 15s, index_batch_size: 10, index_lookup_limit: None, reindex_last_blocks: 0, auto_reindex: true, ignore_mempool: false, sync_once: false, disable_electrum_rpc: false, server_banner: "Welcome to electrs (Electrum Rust Server) running on a MiniBolt node!", args: [] }
[2021-11-09T07:09:42.744Z INFO  electrs::metrics::metrics_impl] serving Prometheus metrics on 127.0.0.1:4224
[2021-11-09T07:09:42.744Z INFO  electrs::server] serving Electrum RPC on 0.0.0.0:50001
[2021-11-09T07:09:42.812Z INFO  electrs::db] "/data/electrs/db/bitcoin": 0 SST files, 0 GB, 0 Grows
[2021-11-09T07:09:43.174Z INFO  electrs::index] indexing 2000 blocks: [1..2000]
[2021-11-09T07:09:44.665Z INFO  electrs::chain] chain updated: tip=00000000dfd5d65c9d8561b4b8f60a63018fe3933ecb131fb37f905f87da951a, height=2000
[2021-11-09T07:09:44.986Z INFO  electrs::index] indexing 2000 blocks: [2001..4000]
[2021-11-09T07:09:46.191Z INFO  electrs::chain] chain updated: tip=00000000922e2aa9e84a474350a3555f49f06061fd49df50a9352f156692a842, height=4000
[2021-11-09T07:09:46.481Z INFO  electrs::index] indexing 2000 blocks: [4001..6000]
[2021-11-09T07:09:47.581Z INFO  electrs::chain] chain updated: tip=00000000dbbb79792303bdd1c6c4d7ab9c21bba0667213c2eca955e11230c5a5, height=6000
[2021-11-09T07:09:46.481Z INFO  electrs::index] indexing 2000 blocks: [6001..8000]
[2021-11-09T07:09:47.581Z INFO  electrs::chain] chain updated: tip=00000000dbbb79792303bdd1c6c4d7ab9c21bba0667213c2eca955e11230c5a6, height=8000
[2021-11-09T07:09:46.481Z INFO  electrs::index] indexing 2000 blocks: [8001..10000]
[2021-11-09T07:09:47.581Z INFO  electrs::chain] chain updated: tip=00000000dbbb79792303bdd1c6c4d7ab9c21bba0667213c2eca955e11230c5a7, height=10000
[...]
[2021-11-09T07:09:46.481Z INFO  electrs::index] indexing 65 blocks: [756001..756065]
[2021-11-09T07:09:47.581Z INFO  electrs::chain] chain updated: tip=00000000dbbb79792303bdd1c6c4d7ab9c21bba0667213c2eca955e11230c510, height=756065
[2021-11-09T07:09:47.581Z INFO  electrs::db] starting config compaction
[2021-11-09T07:09:47.581Z INFO  electrs::db] starting headers compaction
[2021-11-09T07:09:47.581Z INFO  electrs::db] starting txid compaction
[2021-11-09T07:09:47.581Z INFO  electrs::db] starting funding compaction
[2021-11-09T07:09:47.581Z INFO  electrs::db] starting spending compaction
[...]
</code></pre>

</details>

[^1]: Current version installed

[^2]: Current version installed
