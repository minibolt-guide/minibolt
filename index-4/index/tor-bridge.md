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

# Tor services: bridges & relays

In this guide, we will explain how to build step by step an obfs4 bridge (one of the kinds of Tor bridges) and a Guard/Middle Relay. Collaborate to provide anonymous, censorship-resistant internet access by routing traffic through decentralized nodes.

{% hint style="danger" %}
_USE WITH CAUTION - For this guide to work properly, you will need to open ports that are reachable from outside_
{% endhint %}

{% hint style="warning" %}
Difficulty: Medium
{% endhint %}

<div data-full-width="false">

<img src="../../.gitbook/assets/tor_bridge_midguard_relay_pan.png" alt="" width="563">

</div>

## Obsf4 bridge

The design of the Tor network means that the IP address of Tor relays is public. However, one of the ways Tor can be blocked by governments or ISPs is by blocklisting the IP addresses of these public Tor nodes. [Tor Bridges](https://tb-manual.torproject.org/bridges/) are nodes in the network that are not listed in the public Tor directory, which makes it harder for ISPs and governments to block them. We are going to use a kind of [pluggable transport](https://tb-manual.torproject.org/circumvention/) called [obfs4](https://gitlab.com/yawning/obfs4), a special kind of bridge, to address this by adding a layer of obfuscation.

We will create a separate instance for the **obfs4 bridge** and **Guard/Middle relay** instead of using the default Tor instance, this ensures improved security, flexibility, and resource management. By isolating that, you reduce the risk of exposing sensitive services in case of a compromise, as the bridge acts as a shield against censorship circumvention techniques. Additionally, running it separately allows for fine-tuned configuration and resource allocation, ensuring optimal performance without interference from other services running on the default instance, which could cause conflicts or degrade performance.

## Requirements

* [Tor](../../index-1/privacy.md#tor-installation)

## Preparations obfs4 bridge

### **Install dependencies**

#### **Install Tor**

* With user `admin`, check if you have Tor daemon installed

```bash
tor --version
```

Example of expected output:

```
Tor version 0.4.7.13.
[...]
```

{% hint style="info" %}
If you obtain `"command not found"` output, you need to [install Tor](../../index-1/privacy.md#tor-installation) following the proper section on MiniBolt and come back to continue with the guide
{% endhint %}

#### Install obfs4 proxy

[obfs4](https://gitlab.com/yawning/obfs4) makes Tor traffic look random and prevents censors from finding bridges by internet scanning.

* Ensure you are logged in with the user `admin` and install obfs4 proxy. Press "**y**" and `enter` or directly `enter` when the prompt asks you

```sh
sudo apt install obfs4proxy
```

* Check the correct installation

```bash
obfs4proxy -version
```

**Example of expected output:**

```
obfs4proxy-0.0.8
```

## **Installation** obfs4 bridge

* Ensure you have Tor daemon installed in your system

```sh
tor --version
```

**Example** of expected output:

```
Tor version 0.4.7.10.
[...]
```

{% hint style="info" %}
If you obtain `"command not found"` output, follow only the [Tor installation](../../index-1/privacy.md#tor-installation) section in the Privacy section to install it and come back to follow the rest of the guide
{% endhint %}

### **Configure Firewall & Router (NAT)**

* Configure the Firewall to allow incoming requests to be replaced `<TODO1>` and `<TODO2>` previously configured in the section before

```sh
sudo ufw allow <TODO1>/tcp comment 'allow OR port Tor bridge from anywhere'
```

```sh
sudo ufw allow <TODO2>/tcp comment 'allow obsf4 port Tor bridge from anywhere'
```

{% hint style="warning" %}
Note that both Tor's OR port and its obfs4 port **must be reachable from outside.**

If your bridge is behind a NAT, make sure to open both ports. See [portforward.com](https://portforward.com/) for directions on how to port forward with your NAT/router device.

You can use our reachability [test](https://bridges.torproject.org/scan/) to see if your obfs4 port **`<TODO2>`** is reachable from the Internet.

Enter the website your public **"IP ADDRESS"** obtained with **`curl icanhazip.com`** or navigate directly with your regular browser to [icanhazip.com](https://icanhazip.com/) on your personal computer inside of the same local network, and put your **`<TODO2>`** port.
{% endhint %}

### Create the obfs4 bridge user & group

* Create the `_tor-obfs4bridge` user and group

<pre class="language-bash"><code class="lang-bash"><strong>sudo adduser --system --no-create-home --group --force-badname _tor-obfs4bridge
</strong></code></pre>

Example of expected output:

```
Allowing use of questionable username.
Adding system user `_tor-obfs4bridge' (UID 116) ...
Adding new group `_tor-obfs4bridge' (GID 121) ...
Adding new user `_tor-obfs4bridge' (UID 116) with group `_tor-obfs4bridge' ...
Not creating home directory `/home/_tor-obfs4bridge'.
```

### Data directories

* Create a data folder to store runtime data, cache files, and other dynamic content specific to the obfs4 bridge Tor instance

```bash
sudo mkdir -p /var/lib/tor-instances/obfs4bridge
```

* Assign the owner of the directory to the `_tor-obfs4bridge` recently created user

```bash
sudo chown _tor-obfs4bridge:_tor-obfs4bridge /var/lib/tor-instances/obfs4bridge
```

* Create a data folder config for the instance

```bash
sudo mkdir -p /etc/tor/instances/obfs4bridge
```

## Configuration obfs4 bridge

* Create a dedicated torrc config file

```sh
sudo nano /etc/tor/instances/obfs4bridge/torrc
```

* Add the next lines. We will use 2 ports: `<TODO1>` and `<TODO2>`**, m**ake sure you replace them in addition to `<address@email.com>` & `<PickANickname>`, rest left the same. Save and exit

<pre><code># MiniBolt: obfs4 bridge configuration
# /etc/tor/instances/obfs4bridge/torrc

<strong>## Control port selected for the obfs4 bridge
</strong>ControlPort 9052

## obfs4 bridge conf
BridgeRelay 1
ExtORPort auto
ServerTransportPlugin obfs4 exec /usr/bin/obfs4proxy --enableLogging --logLevel=INFO

ORPort <a data-footnote-ref href="#user-content-fn-1">&#x3C;TODO1></a> IPv4Only
ServerTransportListenAddr obfs4 0.0.0.0:<a data-footnote-ref href="#user-content-fn-2">&#x3C;TODO2></a>

#### obfs4 bridge relay info
ContactInfo &#x3C;address@email.com>
Nickname &#x3C;PickANickname>
</code></pre>

<details>

<summary>💡 &#x3C;TODO1> ⬇️</summary>

{% code overflow="wrap" %}
```
Replace <TODO1> with a Tor port of your choice >1024. Avoid port 9001 because it's commonly associated with Tor and censors may be scanning the Internet for this port.
```
{% endcode %}

</details>

<details>

<summary>💡 &#x3C;TODO2> ⬇️</summary>

{% code overflow="wrap" %}
```
Replace <TODO2> with an obfs4 port of your choice. This port must be externally reachable and must be different from the one specified for ORPort <TODO1>. Avoid port 9001 because it's commonly associated with Tor and censors may be scanning the Internet for this port.
```
{% endcode %}

</details>

<details>

<summary>💡 ContactInfo ⬇️</summary>

{% code overflow="wrap" %}
```
Replace <address@email.com> with your email address so we can contact you if there are problems with your bridge. This line can be used to contact you if your relay or bridge is misconfigured or something else goes wrong. Note that we archive and publish all descriptors containing these lines and that Google indexes them, so spammers might also collect them. You may want to obscure the fact that it's an email address and/or generate a new address for this purpose. e.g ContactInfo Random Person <nobody AT example dot com>. You might also include your PGP or GPG fingerprint if you have one. This is optional but encouraged.
```
{% endcode %}

</details>

<details>

<summary>💡 Nickname ⬇️</summary>

{% code overflow="wrap" %}
```
Replace <PickANickname> with a nickname that you like for your bridge. Nicknames must be between 1 and 19 characters inclusive and must contain only the characters [a-zA-Z0-9]. This is optional.
```
{% endcode %}

</details>

{% hint style="warning" %}
Don't forget to change the ORPort (<**TODO1>)**, ServerTransportListenAddr (<**TODO2>)**, ContactInfo (**\<address@email.com>)**, and Nickname (<**PickANickname>**)options.
{% endhint %}

{% hint style="info" %}
By default, Tor will advertise your bridge to users through various [mechanisms](https://bridges.torproject.org/info?lang=en). If you want to run a private bridge, for example, you'll give out your bridge address manually to your friends. **Add** the next line at the end of the torrc file:

> ```
> # Bridge distribution conf
> BridgeDistribution none
> ```

Currently valid, recognized options are: `none` | `any` | `https` | `email` | `moat`

If you don't specify this line, by default the method will be `any` , this means that you give the choice of whatever method it sees fit
{% endhint %}

* Enable autoboot **(optional)**

```bash
sudo systemctl enable tor@obfs4bridge
```

* Prepare “tor@obfs4bridge” monitoring by the systemd journal and check the logging output. You can exit monitoring at any time with Ctrl-C

```bash
journalctl -fu tor@obfs4bridge
```

{% hint style="info" %}
Keep **this terminal open,** you'll need to come back here on the next step to monitor the logs
{% endhint %}

## Run obfs4 bridge

* To keep an eye on the software movements, [start your SSH program](https://minibolt.minibolt.info/system/system/remote-access#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`

```sh
sudo systemctl start tor@obfs4bridge
```

<details>

<summary>Example of expected output on <code>journalctl -fu tor@obfs4bridge</code> ⬇️</summary>

<pre><code>Oct 20 14:42:36 minibolt systemd[1]: Starting Anonymizing overlay network for TCP (instance obfs4bridge)...
Oct 20 14:42:37 minibolt sed[15620]: DataDirectory /var/lib/tor-instances/obfs4bridge
Oct 20 14:42:37 minibolt sed[15620]: PidFile /run/tor-instances/obfs4bridge/tor.pid
Oct 20 14:42:37 minibolt sed[15620]: RunAsDaemon 0
Oct 20 14:42:37 minibolt sed[15620]: User _tor-obfs4bridge
Oct 20 14:42:37 minibolt sed[15620]: SyslogIdentityTag obfs4bridge
Oct 20 14:42:37 minibolt sed[15620]: ControlSocket /run/tor-instances/obfs4bridge/control GroupWritable RelaxDirModeCheck
Oct 20 14:42:37 minibolt sed[15620]: SocksPort unix:/run/tor-instances/obfs4bridge/socks WorldWritable
Oct 20 14:42:37 minibolt sed[15620]: CookieAuthentication 1
Oct 20 14:42:37 minibolt sed[15620]: CookieAuthFileGroupReadable 1
Oct 20 14:42:37 minibolt sed[15620]: CookieAuthFile /run/tor-instances/obfs4bridge/control.authcookie
Oct 20 14:42:37 minibolt sed[15620]: Log notice syslog
Oct 20 14:42:37 minibolt tor[15623]: Oct 20 14:42:37.009 [notice] Tor 0.4.8.12 running on Linux with Libevent 2.1.12-stable, OpenSSL 3.0.2, Zlib 1.2.11, Liblzma 5.2.5, Libzstd 1.4.8 and Glibc 2.35 as l                       ibc.
Oct 20 14:42:37 minibolt tor[15623]: Oct 20 14:42:37.009 [notice] Tor can't help you if you use it wrong! Learn how to be safe at https://support.torproject.org/faq/staying-anonymous/
Oct 20 14:42:37 minibolt tor[15623]: Oct 20 14:42:37.009 [notice] Read configuration file "/run/tor-instances/obfs4bridge.defaults".
Oct 20 14:42:37 minibolt tor[15623]: Oct 20 14:42:37.009 [notice] Read configuration file "/etc/tor/instances/obfs4bridge/torrc".
Oct 20 14:42:37 minibolt tor[15623]: Oct 20 14:42:37.010 [notice] Based on detected system memory, MaxMemInQueues is set to 2906 MB. You can override this by setting MaxMemInQueues by hand.
Oct 20 14:42:37 minibolt tor[15623]: Oct 20 14:42:37.010 [warn] Fixing permissions on directory /var/lib/tor-instances/obfs4bridge
Oct 20 14:42:37 minibolt tor[15623]: Configuration was valid
Oct 20 14:42:37 minibolt tor[15624]: Oct 20 14:42:37.028 [notice] Tor 0.4.8.12 running on Linux with Libevent 2.1.12-stable, OpenSSL 3.0.2, Zlib 1.2.11, Liblzma 5.2.5, Libzstd 1.4.8 and Glibc 2.35 as l                       ibc.
Oct 20 14:42:37 minibolt tor[15624]: Oct 20 14:42:37.028 [notice] Tor can't help you if you use it wrong! Learn how to be safe at https://support.torproject.org/faq/staying-anonymous/
Oct 20 14:42:37 minibolt tor[15624]: Oct 20 14:42:37.028 [notice] Read configuration file "/run/tor-instances/obfs4bridge.defaults".
Oct 20 14:42:37 minibolt tor[15624]: Oct 20 14:42:37.028 [notice] Read configuration file "/etc/tor/instances/obfs4bridge/torrc".
Oct 20 14:42:37 minibolt tor[15624]: Oct 20 14:42:37.029 [notice] Based on detected system memory, MaxMemInQueues is set to 2906 MB. You can override this by setting MaxMemInQueues by hand.
Oct 20 14:42:37 minibolt tor[15624]: Oct 20 14:42:37.030 [notice] Opening Control listener on 127.0.0.1:9052
Oct 20 14:42:37 minibolt tor[15624]: Oct 20 14:42:37.030 [notice] Opened Control listener connection (ready) on 127.0.0.1:9052
Oct 20 14:42:37 minibolt tor[15624]: Oct 20 14:42:37.030 [notice] Opening OR listener on 0.0.0.0:2222
Oct 20 14:42:37 minibolt tor[15624]: Oct 20 14:42:37.030 [notice] Opened OR listener connection (ready) on 0.0.0.0:2222
Oct 20 14:42:37 minibolt tor[15624]: Oct 20 14:42:37.030 [notice] Opening Extended OR listener on 127.0.0.1:0
Oct 20 14:42:37 minibolt tor[15624]: Oct 20 14:42:37.030 [notice] Extended OR listener listening on port 45073.
Oct 20 14:42:37 minibolt tor[15624]: Oct 20 14:42:37.030 [notice] Opened Extended OR listener connection (ready) on 127.0.0.1:45073
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: We compiled with OpenSSL 30000020: OpenSSL 3.0.2 15 Mar 2022 and we are running with OpenSSL 30000020: 3.0.2. These two versions should be binary compat                       ible.
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Tor 0.4.8.12 running on Linux with Libevent 2.1.12-stable, OpenSSL 3.0.2, Zlib 1.2.11, Liblzma 5.2.5, Libzstd 1.4.8 and Glibc 2.35 as libc.
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Tor can't help you if you use it wrong! Learn how to be safe at https://support.torproject.org/faq/staying-anonymous/
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Read configuration file "/run/tor-instances/obfs4bridge.defaults".
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Read configuration file "/etc/tor/instances/obfs4bridge/torrc".
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Based on detected system memory, MaxMemInQueues is set to 2906 MB. You can override this by setting MaxMemInQueues by hand.
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Opening Control listener on 127.0.0.1:9052
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Opened Control listener connection (ready) on 127.0.0.1:9052
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Opening OR listener on 0.0.0.0:2222
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Opened OR listener connection (ready) on 0.0.0.0:2222
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Opening Extended OR listener on 127.0.0.1:0
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Extended OR listener listening on port 45073.
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Opened Extended OR listener connection (ready) on 127.0.0.1:45073
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Parsing GEOIP IPv4 file /usr/share/tor/geoip.
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Parsing GEOIP IPv6 file /usr/share/tor/geoip6.
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Configured to measure statistics. Look for the *-stats files that will first be written to the data directory in 24 hours from now.
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: You are running a new relay. Thanks for helping the Tor network! If you wish to know what will happen in the upcoming weeks regarding its usage, have a                        look at https://blog.torproject.org/lifecycle-of-a-new-relay
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: It looks like I need to generate and sign a new medium-term signing key, because I don't have one. To do that, I need to load (or create) the permanent                        master identity key. If the master identity key was not moved or encrypted with a passphrase, this will be done automatically and no further action is required. Otherwise, provide the necessary data using 'tor                        --keygen' to do it manually.
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Your Tor server's identity key fingerprint is 'Ofbs4bridge 2F40A126FA438E01F44D628557A216A2EF7EB5F7'
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Your Tor bridge's hashed identity key fingerprint is 'Ofbs4bridge <a data-footnote-ref href="#user-content-fn-3">29CA77BDCA7C00A7079CDDC0258A4DE0F1170157</a>'
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Your Tor server's identity key ed25519 fingerprint is 'Ofbs4bridge aCFadrH6GzZuFUG-YjmMw1EsMTKevx7ZJaZA4usbUWA'
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: You can check the status of your bridge relay at https://bridges.torproject.org/status?id=29CA77BDCA7C00A7079CDDC0258A4DE0F1170157
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Bootstrapped 0% (starting): Starting
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Starting with guard context "default"
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Signaled readiness to systemd
Oct 20 14:42:37 minibolt systemd[1]: Started Anonymizing overlay network for TCP (instance obfs4bridge).
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Registered server transport 'obfs4' at '[::]:2008'
Oct 20 14:42:38 minibolt Tor-obfs4bridge[15624]: Opening Socks listener on /run/tor-instances/obfs4bridge/socks
Oct 20 14:42:38 minibolt Tor-obfs4bridge[15624]: Opened Socks listener connection (ready) on /run/tor-instances/obfs4bridge/socks
Oct 20 14:42:38 minibolt Tor-obfs4bridge[15624]: Opening Control listener on /run/tor-instances/obfs4bridge/control
Oct 20 14:42:38 minibolt Tor-obfs4bridge[15624]: Opened Control listener connection (ready) on /run/tor-instances/obfs4bridge/control
Oct 20 14:42:38 minibolt Tor-obfs4bridge[15624]: Unable to find IPv4 address for ORPort 2222. You might want to specify IPv6Only to it or set an explicit address or set Address.
Oct 20 14:42:38 minibolt Tor-obfs4bridge[15624]: Bootstrapped 5% (conn): Connecting to a relay
Oct 20 14:42:38 minibolt Tor-obfs4bridge[15624]: Problem bootstrapping. Stuck at 5% (conn): Connecting to a relay. (No route to host; NOROUTE; count 1; recommendation warn; host 89B4597169A9DBB171F0B4629C73C0FD55D767C7 at 81.106.105.234:443)
Oct 20 14:42:38 minibolt Tor-obfs4bridge[15624]: Bootstrapped 10% (conn_done): Connected to a relay
Oct 20 14:42:38 minibolt Tor-obfs4bridge[15624]: Bootstrapped 14% (handshake): Handshaking with a relay
Oct 20 14:42:38 minibolt Tor-obfs4bridge[15624]: Bootstrapped 15% (handshake_done): Handshake with a relay done
Oct 20 14:42:38 minibolt Tor-obfs4bridge[15624]: Bootstrapped 20% (onehop_create): Establishing an encrypted directory connection
Oct 20 14:42:39 minibolt Tor-obfs4bridge[15624]: Bootstrapped 25% (requesting_status): Asking for networkstatus consensus
Oct 20 14:42:39 minibolt Tor-obfs4bridge[15624]: Bootstrapped 30% (loading_status): Loading networkstatus consensus
Oct 20 14:42:40 minibolt Tor-obfs4bridge[15624]: I learned some more directory information, but not enough to build a circuit: We have no usable consensus.
Oct 20 14:42:40 minibolt Tor-obfs4bridge[15624]: Bootstrapped 40% (loading_keys): Loading authority key certs
Oct 20 14:42:40 minibolt Tor-obfs4bridge[15624]: The current consensus has no exit nodes. Tor can only build internal paths, such as paths to onion services.
Oct 20 14:42:40 minibolt Tor-obfs4bridge[15624]: Bootstrapped 45% (requesting_descriptors): Asking for relay descriptors
Oct 20 14:42:40 minibolt Tor-obfs4bridge[15624]: I learned some more directory information, but not enough to build a circuit: We need more microdescriptors: we have 0/8103, and can only build 0% of likely paths. (We have 0% of guards bw, 0% of midpoint bw, and 0% of end bw (no exits in consensus, using mid) = 0% of path bw.)
Oct 20 14:42:40 minibolt Tor-obfs4bridge[15624]: Bootstrapped 50% (loading_descriptors): Loading relay descriptors
Oct 20 14:42:41 minibolt Tor-obfs4bridge[15624]: The current consensus contains exit nodes. Tor can build exit and internal paths.
Oct 20 14:42:42 minibolt Tor-obfs4bridge[15624]: Bootstrapped 55% (loading_descriptors): Loading relay descriptors
Oct 20 14:42:44 minibolt Tor-obfs4bridge[15624]: Bootstrapped 63% (loading_descriptors): Loading relay descriptors
Oct 20 14:42:44 minibolt Tor-obfs4bridge[15624]: Bootstrapped 72% (loading_descriptors): Loading relay descriptors
Oct 20 14:42:44 minibolt Tor-obfs4bridge[15624]: Bootstrapped 75% (enough_dirinfo): Loaded enough directory info to build circuits
Oct 20 14:42:44 minibolt Tor-obfs4bridge[15624]: Bootstrapped 90% (ap_handshake_done): Handshake finished with a relay to build circuits
Oct 20 14:42:44 minibolt Tor-obfs4bridge[15624]: Bootstrapped 95% (circuit_create): Establishing a Tor circuit
Oct 20 14:42:44 minibolt Tor-obfs4bridge[15624]: Bootstrapped 100% (done): Done
</code></pre>

</details>

* Obtain your `HASHED FINGERPRINT`

{% code overflow="wrap" %}
```bash
journalctl -u tor@obfs4bridge --since='1 hour ago' | grep "hashed identity key fingerprint"
```
{% endcode %}

Example of expected output:

```
Oct 20 14:42:37 minibolt Tor-obfs4bridge[15624]: Your Tor bridge's hashed identity key fingerprint is 'Testbridge 29CA77BDCA7C00A7079CDDC0258A4DE0F1170157'
```

{% hint style="info" %}
\-> In this example, HASHED FINGERPRINT, would be: `29CA77BDCA7C00A7079CDDC0258A4DE0F1170157`

\-> Take note of this, about **3 hours** after you start your relay, it should appear on [Relay Search](https://metrics.torproject.org/rs.html) on the Metrics portal. You can search for your relay using your nickname, public IP address, or HASHED FINGERPRINT and monitor your Guard/Middle relay usage on Relay Search. Just enter some of them in the form and click on "Search"

\-> Also, you can check the status of your bridge relay on this URL: `https://bridges.torproject.org/status?id=<HASHEDFINGERPRINT>`, replacing `<HASHEDFINGERPRINT>` for you one
{% endhint %}

* You can see the obfs4proxy logs with

```bash
sudo tail -f /var/lib/tor-instances/obfs4bridge/pt_state/obfs4proxy.log
```

Example of expected output:

```
2024/10/18 20:17:11 [INFO]: obfs4([scrubbed]:1221)  - new connection
2024/10/18 20:17:14 [WARN]: obfs4([scrubbed]:63251) - closed connection: readfrom: read tcp 192.168.1.56:2008->58.24.24.100:64520: read: connection reset by peer
2024/10/18 21:08:51 [INFO]: obfs4([scrubbed]:56454) - new connection
2024/10/18 21:08:51 [INFO]: obfs4([scrubbed]:56454) - closed connection
2024/10/18 21:08:53 [INFO]: obfs4([scrubbed]:56458) - new connection
2024/10/18 21:08:53 [INFO]: obfs4([scrubbed]:56458) - closed connection
```

### Validation

* Ensure that the Tor port related to the bridge and the Obfs4proxy service are working and listening at the the ports selected

```bash
sudo ss -tulpn | grep '\(tor\|obfs4proxy\)'
```

**Example** of expected output:

<pre><code>tcp   LISTEN 0      4096         0.0.0.0:9050       0.0.0.0:*    users:(("tor",pid=975075,fd=6))
tcp   LISTEN 0      4096       127.0.0.1:39149      0.0.0.0:*    users:(("tor",pid=206525,fd=8))
tcp   LISTEN 0      4096       127.0.0.1:9051       0.0.0.0:*    users:(("tor",pid=975075,fd=7))
tcp   LISTEN 0      4096       127.0.0.1:<a data-footnote-ref href="#user-content-fn-4">9052</a>       0.0.0.0:*    users:(("tor",pid=206525,fd=6))
tcp   LISTEN 0      4096       127.0.0.1:44105      0.0.0.0:*    users:(("obfs4proxy",pid=975077,fd=7))
tcp   LISTEN 0      4096         0.0.0.0:<a data-footnote-ref href="#user-content-fn-5">2016</a>       0.0.0.0:*    users:(("tor",pid=206525,fd=7))
tcp   LISTEN 0      4096               *:<a data-footnote-ref href="#user-content-fn-6">2008</a>             *:*    users:(("obfs4proxy",pid=206526,fd=7))
</code></pre>

* If you want to connect to your bridge manually, you will need to know the bridge's obfs4 certificate

{% code overflow="wrap" %}
```sh
sudo tail -n1 /var/lib/tor-instances/obfs4bridge/pt_state/obfs4_bridgeline.txt
```
{% endcode %}

* Take note of the next entire line

```
Bridge obfs4 <IPADDRESS>:<PORT> <FINGERPRINT> cert=<CERTIFICATE> iat-mode=0
```

{% hint style="info" %}
\-> You'll need to replace \<IPADDRESS>, \<PORT>, and \<FINGERPRINT> with the actual values, which you can find in the Tor log. Make sure that you use **"PORT"** as the obfs4 port <**TODO2>,** not ~~**\<TODO1>,**~~ and that you chose **"FINGERPRINT",** not ~~**"HASHED FINGERPRINT"**~~

\-> Remember to exclude the "`Bridge`" word to avoid incompatibility with the Tor Browser Android version

\-> More info to connect the Tor browser to your own Tor bridge on this [website](https://tb-manual.torproject.org/bridges/) in the `"ENTERING BRIDGE ADDRESSES"` section

\-> Take note of your case data, you will need it later
{% endhint %}

## Upgrade obfs4 bridge

* To upgrade, use the package manager by typing this command

```bash
sudo apt update && sudo apt upgrade
```

## Uninstall obfs4 bridge

* With user `admin`, stop obsfs4 bridge service. Wait until the prompts show you again

```bash
sudo systemctl stop tor@obfs4bridge
```

### **Uninstall obfs4 proxy**

* Uninstall obfs4proxy software

```sh
sudo apt autoremove obfs4proxy --purge
```

### Delete user & group <a href="#delete-user-and-group" id="delete-user-and-group"></a>

* Delete the `_tor-obfs4bridge` user. Don't worry about `userdel: _tor-obfs4bridge mail spool (/var/mail/_tor-obfs4bridge) not found` output, the uninstall has been successful

```bash
sudo userdel -rf _tor-obfs4bridge
```

### **Delete data directories & configuration**

* Delete data directories related to the obfs4bridge

{% code overflow="wrap" %}
```bash
sudo rm -r /var/lib/tor-instances/obfs4bridge && sudo rm -r /etc/tor/instances/obfs4bridge
```
{% endcode %}

### **Uninstall FW configuration and router NAT**

* Display the UFW firewall rules and note the numbers of the rules for Tor bridge (e.g. W and Y below)

```sh
sudo ufw status numbered
```

Expected output:

```
[...]
[W] <TODO1>           ALLOW IN    Anywhere           # allow OR port Tor bridge from anywhere
[Y] <TODO2>           ALLOW IN    Anywhere           # allow obsf4 port Tor bridge from anywhere
```

* Delete the rule with the correct number and confirm with "yes"

```sh
sudo ufw delete X
```

* Check the correct update of the rules

```sh
sudo ufw status verbose
```

{% hint style="info" %}
Reverts router NAT configuration following the same [Configure Firewall & Router (NAT) ](tor-bridge.md#configure-firewall-and-router-nat)previous step but this time deleting the configuration setting
{% endhint %}

## Guard/Middle relay

_(also known as non-exit relays)_

{% hint style="danger" %}
Attention!! The IP addresses of the Guard/Middle relays are listed in the public Tor relay directory, this could be a security and privacy risk, so we recommended running this on a security/privacy-focused VPS service like [1984.hosting](https://1984.hosting/)
{% endhint %}

A guard relay is the first relay (hop) in a Tor circuit. A middle relay is a relay that acts as the second hop in the Tor circuit. To become a guard relay, the relay has to be stable and fast (at least 2MByte/s of upstream and downstream bandwidth) otherwise it will remain a middle relay.

Guard and middle relays usually do not receive abuse complaints. However, all relays are listed in the public Tor relay directory, and as a result, they may be blocked by certain services. These include services that either misunderstand how Tor works or deliberately want to censor Tor users, for example, online banking and streaming services.

A non-exit Tor relay requires minimal maintenance efforts and bandwidth usage can be highly customized in the Tor configuration. The so called "exit policy" of the relay decides if it is a relay allowing clients to exit or not. A non-exit relay does not allow exiting in its exit policy.

{% hint style="warning" %}
**Important:** If you are running a relay from home with a single static IP address and are concerned about your IP being blocked by certain online services, consider running a bridge like the before [Obfs4 bridge](tor-bridge.md#obsf4-bridge) or a Tor [snowflake proxy](https://community.torproject.org/relay/setup/snowflake/) (not covered in this guide yet) instead. This alternative can help prevent your non-Tor traffic from being mistakenly blocked as though it's coming from a Tor relay.
{% endhint %}

## Requirements

* [Tor](../../index-1/privacy.md#tor-installation)

### **Install dependencies**

#### **Install Tor**

* With user `admin`, check if you have Tor daemon installed

```bash
tor --version
```

Example of expected output:

```
Tor version 0.4.7.13.
[...]
```

{% hint style="info" %}
If you obtain `"command not found"` output, you need to [install Tor](../../index-1/privacy.md#tor-installation) following the proper section on MiniBolt and come back to continue with the guide
{% endhint %}

## Preparations Guard/Middle relay

### **Configure Firewall & Router (NAT)**

* Configure the Firewall to allow incoming requests

```sh
sudo ufw allow 9001/tcp comment 'allow OR port Guard/Middle relay from anywhere'
```

{% hint style="warning" %}
Note that the Tor OR port **must be reachable from outside.**

If your bridge is behind a NAT, make sure to open both ports. See [portforward.com](https://portforward.com/) for directions on how to port forward with your NAT/router device.

You can use our reachability [test](https://bridges.torproject.org/scan/) to see if your Tor OR port is reachable from the Internet.

Enter the website your public **"IP ADDRESS"** obtained with **`curl icanhazip.com`** or navigate directly with your regular browser to [icanhazip.com](https://icanhazip.com/) on your personal computer inside of the same local network, and put your Tor OR port.
{% endhint %}

## Installation Guard/Middle relay

### Create the guardmidrelay user & group

* Create the `_tor-guardmidrelay` user and group

```bash
sudo adduser --system --no-create-home --group --force-badname _tor-guardmidrelay
```

Example of expected output:

```
Allowing use of questionable username.
Adding system user `_tor-guardmidrelay' (UID 115) ...
Adding new group `_tor-guardmidrelay' (GID 120) ...
Adding new user `_tor-guardmidrelay' (UID 115) with group `_tor-guardmidrelay' ...
Not creating home directory `/home/_tor-guardmidrelay'.
```

### Data directories

* Create a data folder to store runtime data, cache files, and other dynamic content specific to the Guard/Middle relay Tor instance

```bash
sudo mkdir -p /var/lib/tor-instances/guardmidrelay
```

* Assign the owner of the directory to the `_tor-guardmidrelay` recently created user

```bash
sudo chown _tor-guardmidrelay:_tor-guardmidrelay /var/lib/tor-instances/guardmidrelay
```

* Create a data folder config for the instance

```bash
sudo mkdir -p /etc/tor/instances/guardmidrelay
```

## Configuration Guard/Middle relay

* Create a dedicated torrc config file

```sh
sudo nano /etc/tor/instances/guardmidrelay/torrc
```

* Add the next lines. Make sure you replace `<address@email.com>` & `<PickANickname>`, rest left the same. Save and exit

<pre><code># MiniBolt: Guard/Middle configuration
# /etc/tor/instances/guardmidrelay/torrc
<strong>
</strong><strong>## Control port selected for Guard/Middle relay
</strong>ControlPort 9053

## Guard/Middle relay conf
ORPort 9001 IPv4Only
Exitrelay 0
SocksPort 0

#### Guard/Middle relay info
ContactInfo &#x3C;address@email.com>
Nickname &#x3C;PickANickname>
</code></pre>

<details>

<summary>💡 ContactInfo ⬇️</summary>

{% code overflow="wrap" %}
```
Replace <address@email.com> with your email address so we can contact you if there are problems with your bridge. This line can be used to contact you if your relay or bridge is misconfigured or something else goes wrong. Note that we archive and publish all descriptors containing these lines and that Google indexes them, so spammers might also collect them. You may want to obscure the fact that it's an email address and/or generate a new address for this purpose. e.g ContactInfo Random Person <nobody AT example dot com>. You might also include your PGP or GPG fingerprint if you have one. This is optional but encouraged.
```
{% endcode %}

</details>

<details>

<summary>💡 Nickname ⬇️</summary>

{% code overflow="wrap" %}
```
Replace <PickANickname> with a nickname that you like for your bridge. Nicknames must be between 1 and 19 characters inclusive and must contain only the characters [a-zA-Z0-9]. This is optional.
```
{% endcode %}

</details>

* Enable autoboot **(optional)**

```bash
sudo systemctl enable tor@guardmidrelay
```

* Prepare “tor@guardmidrelay” monitoring by the systemd journal and check the logging output. You can exit monitoring at any time with Ctrl-C

```bash
journalctl -fu tor@guardmidrelay
```

{% hint style="info" %}
Keep **this terminal open,** you'll need to come back here on the next step to monitor the logs
{% endhint %}

## Run Guard/Middle relay

* To keep an eye on the software movements, [start your SSH program](https://minibolt.minibolt.info/system/system/remote-access#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`

```sh
sudo systemctl start tor@guardmidrelay
```

<details>

<summary>Example of expected output on <code>journalctl -fu tor@guardmidrelay</code> ⬇️</summary>

<pre><code>Oct 20 14:03:48 minibolt systemd[1]: Starting Anonymizing overlay network for TCP (instance guardmidrelay)...
Oct 20 14:03:48 minibolt sed[15076]: DataDirectory /var/lib/tor-instances/guardmidrelay
Oct 20 14:03:48 minibolt sed[15076]: PidFile /run/tor-instances/guardmidrelay/tor.pid
Oct 20 14:03:48 minibolt sed[15076]: RunAsDaemon 0
Oct 20 14:03:48 minibolt sed[15076]: User _tor-guardmidrelay
Oct 20 14:03:48 minibolt sed[15076]: SyslogIdentityTag guardmidrelay
Oct 20 14:03:48 minibolt sed[15076]: ControlSocket /run/tor-instances/guardmidrelay/control GroupWritable RelaxDirModeCheck
Oct 20 14:03:48 minibolt sed[15076]: SocksPort unix:/run/tor-instances/guardmidrelay/socks WorldWritable
Oct 20 14:03:48 minibolt sed[15076]: CookieAuthentication 1
Oct 20 14:03:48 minibolt sed[15076]: CookieAuthFileGroupReadable 1
Oct 20 14:03:48 minibolt sed[15076]: CookieAuthFile /run/tor-instances/guardmidrelay/control.authcookie
Oct 20 14:03:48 minibolt sed[15076]: Log notice syslog
Oct 20 14:03:48 minibolt tor[15078]: Oct 20 14:03:48.607 [notice] Tor 0.4.8.12 running on Linux with Libevent 2.1.12-stable, OpenSSL 3.0.2, Zlib 1.2.11, Liblzma 5.2.5, Libzstd 1.4.8 and Glibc 2.35 as libc.
Oct 20 14:03:48 minibolt tor[15078]: Oct 20 14:03:48.608 [notice] Tor can't help you if you use it wrong! Learn how to be safe at https://support.torproject.org/faq/staying-anonymous/
Oct 20 14:03:48 minibolt tor[15078]: Oct 20 14:03:48.608 [notice] Read configuration file "/run/tor-instances/guardmidrelay.defaults".
Oct 20 14:03:48 minibolt tor[15078]: Oct 20 14:03:48.608 [notice] Read configuration file "/etc/tor/instances/guardmidrelay/torrc".
Oct 20 14:03:48 minibolt tor[15078]: Oct 20 14:03:48.608 [notice] Based on detected system memory, MaxMemInQueues is set to 2906 MB. You can override this by setting MaxMemInQueues by hand.
Oct 20 14:03:48 minibolt tor[15078]: Oct 20 14:03:48.609 [warn] Fixing permissions on directory /var/lib/tor-instances/guardmidrelay
Oct 20 14:03:48 minibolt tor[15078]: Configuration was valid
Oct 20 14:03:48 minibolt tor[15079]: Oct 20 14:03:48.628 [notice] Tor 0.4.8.12 running on Linux with Libevent 2.1.12-stable, OpenSSL 3.0.2, Zlib 1.2.11, Liblzma 5.2.5, Libzstd 1.4.8 and Glibc 2.35 as libc.
Oct 20 14:03:48 minibolt tor[15079]: Oct 20 14:03:48.628 [notice] Tor can't help you if you use it wrong! Learn how to be safe at https://support.torproject.org/faq/staying-anonymous/
Oct 20 14:03:48 minibolt tor[15079]: Oct 20 14:03:48.628 [notice] Read configuration file "/run/tor-instances/guardmidrelay.defaults".
Oct 20 14:03:48 minibolt tor[15079]: Oct 20 14:03:48.628 [notice] Read configuration file "/etc/tor/instances/guardmidrelay/torrc".
Oct 20 14:03:48 minibolt tor[15079]: Oct 20 14:03:48.628 [notice] Based on detected system memory, MaxMemInQueues is set to 2906 MB. You can override this by setting MaxMemInQueues by hand.
Oct 20 14:03:48 minibolt tor[15079]: Oct 20 14:03:48.629 [notice] Opening Control listener on 127.0.0.1:9053
Oct 20 14:03:48 minibolt tor[15079]: Oct 20 14:03:48.629 [notice] Opened Control listener connection (ready) on 127.0.0.1:9053
Oct 20 14:03:48 minibolt tor[15079]: Oct 20 14:03:48.629 [notice] Opening OR listener on 0.0.0.0:9001
Oct 20 14:03:48 minibolt tor[15079]: Oct 20 14:03:48.629 [notice] Opened OR listener connection (ready) on 0.0.0.0:9001
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: We compiled with OpenSSL 30000020: OpenSSL 3.0.2 15 Mar 2022 and we are running with OpenSSL 30000020: 3.0.2. These two versions should be binary compatible.
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Tor 0.4.8.12 running on Linux with Libevent 2.1.12-stable, OpenSSL 3.0.2, Zlib 1.2.11, Liblzma 5.2.5, Libzstd 1.4.8 and Glibc 2.35 as libc.
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Tor can't help you if you use it wrong! Learn how to be safe at https://support.torproject.org/faq/staying-anonymous/
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Read configuration file "/run/tor-instances/guardmidrelay.defaults".
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Read configuration file "/etc/tor/instances/guardmidrelay/torrc".
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Based on detected system memory, MaxMemInQueues is set to 2906 MB. You can override this by setting MaxMemInQueues by hand.
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Opening Control listener on 127.0.0.1:9053
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Opened Control listener connection (ready) on 127.0.0.1:9053
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Opening OR listener on 0.0.0.0:9001
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Opened OR listener connection (ready) on 0.0.0.0:9001
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Parsing GEOIP IPv4 file /usr/share/tor/geoip.
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Parsing GEOIP IPv6 file /usr/share/tor/geoip6.
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Configured to measure statistics. Look for the *-stats files that will first be written to the data directory in 24 hours from now.
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: You are running a new relay. Thanks for helping the Tor network! If you wish to know what will happen in the upcoming weeks regarding its usage, have a look at https://blog.torproject.org/lifecycle-of-a-new-relay
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: It looks like I need to generate and sign a new medium-term signing key, because I don't have one. To do that, I need to load (or create) the permanent master identity key. If the master identity key was not moved or encrypted with a passphrase, this will be done automatically and no further action is required. Otherwise, provide the necessary data using 'tor --keygen' to do it manually.
Oct 20 14:03:49 minibolt Tor-guardmidrelay[15079]: Your Tor server's identity key fingerprint is 'GuardMidRelay 8D4FE09E8CF58EEB437A6A7FB36B09D7D8D24389'
Oct 20 14:03:49 minibolt Tor-guardmidrelay[15079]: Your Tor server's identity key ed25519 fingerprint is 'GuardMidRelay 70zFbIVtdMeyHOilWab5GyXRAxxnsepchNZE7StSp2k'
Oct 20 14:03:49 minibolt Tor-guardmidrelay[15079]: Bootstrapped 0% (starting): Starting
Oct 20 14:03:49 minibolt Tor-guardmidrelay[15079]: Starting with guard context "default"
Oct 20 14:03:49 minibolt Tor-guardmidrelay[15079]: Signaled readiness to systemd
Oct 20 14:03:49 minibolt systemd[1]: Started Anonymizing overlay network for TCP (instance guardmidrelay).
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Opening Control listener on /run/tor-instances/guardmidrelay/control
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Opened Control listener connection (ready) on /run/tor-instances/guardmidrelay/control
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Unable to find IPv4 address for ORPort 9001. You might want to specify IPv6Only to it or set an explicit address or set Address.
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Bootstrapped 5% (conn): Connecting to a relay
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Bootstrapped 10% (conn_done): Connected to a relay
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Bootstrapped 14% (handshake): Handshaking with a relay
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Bootstrapped 15% (handshake_done): Handshake with a relay done
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Bootstrapped 20% (onehop_create): Establishing an encrypted directory connection
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Bootstrapped 25% (requesting_status): Asking for networkstatus consensus
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Bootstrapped 30% (loading_status): Loading networkstatus consensus
Oct 20 14:03:51 minibolt Tor-guardmidrelay[15079]: I learned some more directory information, but not enough to build a circuit: We have no usable consensus.
Oct 20 14:03:51 minibolt Tor-guardmidrelay[15079]: Bootstrapped 40% (loading_keys): Loading authority key certs
Oct 20 14:03:51 minibolt Tor-guardmidrelay[15079]: The current consensus has no exit nodes. Tor can only build internal paths, such as paths to onion services.
Oct 20 14:03:51 minibolt Tor-guardmidrelay[15079]: Bootstrapped 45% (requesting_descriptors): Asking for relay descriptors
Oct 20 14:03:51 minibolt Tor-guardmidrelay[15079]: I learned some more directory information, but not enough to build a circuit: We need more microdescriptors: we have 0/8103, and can only build 0% of likely paths. (We have 0% of guards bw, 0% of midpoint bw, and 0% of end bw (no exits in consensus, using mid) = 0% of path bw.)
Oct 20 14:03:51 minibolt Tor-guardmidrelay[15079]: We'd like to launch a circuit to handle a connection, but we already have 32 general-purpose client circuits pending. Waiting until some finish.
Oct 20 14:03:52 minibolt Tor-guardmidrelay[15079]: Bootstrapped 50% (loading_descriptors): Loading relay descriptors
Oct 20 14:03:52 minibolt Tor-guardmidrelay[15079]: The current consensus contains exit nodes. Tor can build exit and internal paths.
Oct 20 14:03:53 minibolt Tor-guardmidrelay[15079]: Bootstrapped 55% (loading_descriptors): Loading relay descriptors
Oct 20 14:03:53 minibolt Tor-guardmidrelay[15079]: Bootstrapped 60% (loading_descriptors): Loading relay descriptors
Oct 20 14:03:53 minibolt Tor-guardmidrelay[15079]: Bootstrapped 65% (loading_descriptors): Loading relay descriptors
Oct 20 14:03:53 minibolt Tor-guardmidrelay[15079]: Bootstrapped 70% (loading_descriptors): Loading relay descriptors
Oct 20 14:03:53 minibolt Tor-guardmidrelay[15079]: Bootstrapped 75% (enough_dirinfo): Loaded enough directory info to build circuits
Oct 20 14:03:54 minibolt Tor-guardmidrelay[15079]: Bootstrapped 80% (ap_conn): Connecting to a relay to build circuits
Oct 20 14:03:54 minibolt Tor-guardmidrelay[15079]: Bootstrapped 85% (ap_conn_done): Connected to a relay to build circuits
Oct 20 14:03:54 minibolt Tor-guardmidrelay[15079]: Bootstrapped 89% (ap_handshake): Finishing handshake with a relay to build circuits
Oct 20 14:03:54 minibolt Tor-guardmidrelay[15079]: Bootstrapped 90% (ap_handshake_done): Handshake finished with a relay to build circuits
Oct 20 14:03:54 minibolt Tor-guardmidrelay[15079]: Bootstrapped 95% (circuit_create): Establishing a Tor circuit
Oct 20 14:03:54 minibolt Tor-guardmidrelay[15079]: Bootstrapped 100% (done): DoneOct 20 14:03:48 minibolt systemd[1]: Starting Anonymizing overlay network for TCP (instance guardmidrelay)...
Oct 20 14:03:48 minibolt sed[15076]: DataDirectory /var/lib/tor-instances/guardmidrelay
Oct 20 14:03:48 minibolt sed[15076]: PidFile /run/tor-instances/guardmidrelay/tor.pid
Oct 20 14:03:48 minibolt sed[15076]: RunAsDaemon 0
Oct 20 14:03:48 minibolt sed[15076]: User _tor-guardmidrelay
Oct 20 14:03:48 minibolt sed[15076]: SyslogIdentityTag guardmidrelay
Oct 20 14:03:48 minibolt sed[15076]: ControlSocket /run/tor-instances/guardmidrelay/control GroupWritable RelaxDirModeCheck
Oct 20 14:03:48 minibolt sed[15076]: SocksPort unix:/run/tor-instances/guardmidrelay/socks WorldWritable
Oct 20 14:03:48 minibolt sed[15076]: CookieAuthentication 1
Oct 20 14:03:48 minibolt sed[15076]: CookieAuthFileGroupReadable 1
Oct 20 14:03:48 minibolt sed[15076]: CookieAuthFile /run/tor-instances/guardmidrelay/control.authcookie
Oct 20 14:03:48 minibolt sed[15076]: Log notice syslog
Oct 20 14:03:48 minibolt tor[15078]: Oct 20 14:03:48.607 [notice] Tor 0.4.8.12 running on Linux with Libevent 2.1.12-stable, OpenSSL 3.0.2, Zlib 1.2.11, Liblzma 5.2.5, Libzstd 1.4.8 and Glibc 2.35 as libc.
Oct 20 14:03:48 minibolt tor[15078]: Oct 20 14:03:48.608 [notice] Tor can't help you if you use it wrong! Learn how to be safe at https://support.torproject.org/faq/staying-anonymous/
Oct 20 14:03:48 minibolt tor[15078]: Oct 20 14:03:48.608 [notice] Read configuration file "/run/tor-instances/guardmidrelay.defaults".
Oct 20 14:03:48 minibolt tor[15078]: Oct 20 14:03:48.608 [notice] Read configuration file "/etc/tor/instances/guardmidrelay/torrc".
Oct 20 14:03:48 minibolt tor[15078]: Oct 20 14:03:48.608 [notice] Based on detected system memory, MaxMemInQueues is set to 2906 MB. You can override this by setting MaxMemInQueues by hand.
Oct 20 14:03:48 minibolt tor[15078]: Oct 20 14:03:48.609 [warn] Fixing permissions on directory /var/lib/tor-instances/guardmidrelay
Oct 20 14:03:48 minibolt tor[15078]: Configuration was valid
Oct 20 14:03:48 minibolt tor[15079]: Oct 20 14:03:48.628 [notice] Tor 0.4.8.12 running on Linux with Libevent 2.1.12-stable, OpenSSL 3.0.2, Zlib 1.2.11, Liblzma 5.2.5, Libzstd 1.4.8 and Glibc 2.35 as libc.
Oct 20 14:03:48 minibolt tor[15079]: Oct 20 14:03:48.628 [notice] Tor can't help you if you use it wrong! Learn how to be safe at https://support.torproject.org/faq/staying-anonymous/
Oct 20 14:03:48 minibolt tor[15079]: Oct 20 14:03:48.628 [notice] Read configuration file "/run/tor-instances/guardmidrelay.defaults".
Oct 20 14:03:48 minibolt tor[15079]: Oct 20 14:03:48.628 [notice] Read configuration file "/etc/tor/instances/guardmidrelay/torrc".
Oct 20 14:03:48 minibolt tor[15079]: Oct 20 14:03:48.628 [notice] Based on detected system memory, MaxMemInQueues is set to 2906 MB. You can override this by setting MaxMemInQueues by hand.
Oct 20 14:03:48 minibolt tor[15079]: Oct 20 14:03:48.629 [notice] Opening Control listener on 127.0.0.1:9053
Oct 20 14:03:48 minibolt tor[15079]: Oct 20 14:03:48.629 [notice] Opened Control listener connection (ready) on 127.0.0.1:9053
Oct 20 14:03:48 minibolt tor[15079]: Oct 20 14:03:48.629 [notice] Opening OR listener on 0.0.0.0:9001
Oct 20 14:03:48 minibolt tor[15079]: Oct 20 14:03:48.629 [notice] Opened OR listener connection (ready) on 0.0.0.0:9001
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: We compiled with OpenSSL 30000020: OpenSSL 3.0.2 15 Mar 2022 and we are running with OpenSSL 30000020: 3.0.2. These two versions should be binary compatible.
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Tor 0.4.8.12 running on Linux with Libevent 2.1.12-stable, OpenSSL 3.0.2, Zlib 1.2.11, Liblzma 5.2.5, Libzstd 1.4.8 and Glibc 2.35 as libc.
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Tor can't help you if you use it wrong! Learn how to be safe at https://support.torproject.org/faq/staying-anonymous/
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Read configuration file "/run/tor-instances/guardmidrelay.defaults".
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Read configuration file "/etc/tor/instances/guardmidrelay/torrc".
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Based on detected system memory, MaxMemInQueues is set to 2906 MB. You can override this by setting MaxMemInQueues by hand.
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Opening Control listener on 127.0.0.1:9053
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Opened Control listener connection (ready) on 127.0.0.1:9053
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Opening OR listener on 0.0.0.0:9001
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Opened OR listener connection (ready) on 0.0.0.0:9001
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Parsing GEOIP IPv4 file /usr/share/tor/geoip.
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Parsing GEOIP IPv6 file /usr/share/tor/geoip6.
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: Configured to measure statistics. Look for the *-stats files that will first be written to the data directory in 24 hours from now.
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: You are running a new relay. Thanks for helping the Tor network! If you wish to know what will happen in the upcoming weeks regarding its usage, have a look at https://blog.torproject.org/lifecycle-of-a-new-relay
Oct 20 14:03:48 minibolt Tor-guardmidrelay[15079]: It looks like I need to generate and sign a new medium-term signing key, because I don't have one. To do that, I need to load (or create) the permanent master identity key. If the master identity key was not moved or encrypted with a passphrase, this will be done automatically and no further action is required. Otherwise, provide the necessary data using 'tor --keygen' to do it manually.
Oct 20 14:03:49 minibolt Tor-guardmidrelay[15079]: Your Tor server's identity key fingerprint is 'Guard/Mid_Relay <a data-footnote-ref href="#user-content-fn-7">8D4FE09E8CF58EEB437A6A7FB36B09D7D8D24389</a>'
Oct 20 14:03:49 minibolt Tor-guardmidrelay[15079]: Your Tor server's identity key ed25519 fingerprint is 'Guard/Mid_Relay 70zFBIVtdMEyHOilWfb5GyXRAxxnsepchNZE7StSp2k'
Oct 20 14:03:49 minibolt Tor-guardmidrelay[15079]: Bootstrapped 0% (starting): Starting
Oct 20 14:03:49 minibolt Tor-guardmidrelay[15079]: Starting with guard context "default"
Oct 20 14:03:49 minibolt Tor-guardmidrelay[15079]: Signaled readiness to systemd
Oct 20 14:03:49 minibolt systemd[1]: Started Anonymizing overlay network for TCP (instance guardmidrelay).
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Opening Control listener on /run/tor-instances/guardmidrelay/control
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Opened Control listener connection (ready) on /run/tor-instances/guardmidrelay/control
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Unable to find IPv4 address for ORPort 9001. You might want to specify IPv6Only to it or set an explicit address or set Address.
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Bootstrapped 5% (conn): Connecting to a relay
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Bootstrapped 10% (conn_done): Connected to a relay
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Bootstrapped 14% (handshake): Handshaking with a relay
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Bootstrapped 15% (handshake_done): Handshake with a relay done
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Bootstrapped 20% (onehop_create): Establishing an encrypted directory connection
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Bootstrapped 25% (requesting_status): Asking for networkstatus consensus
Oct 20 14:03:50 minibolt Tor-guardmidrelay[15079]: Bootstrapped 30% (loading_status): Loading networkstatus consensus
Oct 20 14:03:51 minibolt Tor-guardmidrelay[15079]: I learned some more directory information, but not enough to build a circuit: We have no usable consensus.
Oct 20 14:03:51 minibolt Tor-guardmidrelay[15079]: Bootstrapped 40% (loading_keys): Loading authority key certs
Oct 20 14:03:51 minibolt Tor-guardmidrelay[15079]: The current consensus has no exit nodes. Tor can only build internal paths, such as paths to onion services.
Oct 20 14:03:51 minibolt Tor-guardmidrelay[15079]: Bootstrapped 45% (requesting_descriptors): Asking for relay descriptors
Oct 20 14:03:51 minibolt Tor-guardmidrelay[15079]: I learned some more directory information, but not enough to build a circuit: We need more microdescriptors: we have 0/8103, and can only build 0% of likely paths. (We have 0% of guards bw, 0% of midpoint bw, and 0% of end bw (no exits in consensus, using mid) = 0% of path bw.)
Oct 20 14:03:51 minibolt Tor-guardmidrelay[15079]: We'd like to launch a circuit to handle a connection, but we already have 32 general-purpose client circuits pending. Waiting until some finish.
Oct 20 14:03:52 minibolt Tor-guardmidrelay[15079]: Bootstrapped 50% (loading_descriptors): Loading relay descriptors
Oct 20 14:03:52 minibolt Tor-guardmidrelay[15079]: The current consensus contains exit nodes. Tor can build exit and internal paths.
Oct 20 14:03:53 minibolt Tor-guardmidrelay[15079]: Bootstrapped 55% (loading_descriptors): Loading relay descriptors
Oct 20 14:03:53 minibolt Tor-guardmidrelay[15079]: Bootstrapped 60% (loading_descriptors): Loading relay descriptors
Oct 20 14:03:53 minibolt Tor-guardmidrelay[15079]: Bootstrapped 65% (loading_descriptors): Loading relay descriptors
Oct 20 14:03:53 minibolt Tor-guardmidrelay[15079]: Bootstrapped 70% (loading_descriptors): Loading relay descriptors
Oct 20 14:03:53 minibolt Tor-guardmidrelay[15079]: Bootstrapped 75% (enough_dirinfo): Loaded enough directory info to build circuits
Oct 20 14:03:54 minibolt Tor-guardmidrelay[15079]: Bootstrapped 80% (ap_conn): Connecting to a relay to build circuits
Oct 20 14:03:54 minibolt Tor-guardmidrelay[15079]: Bootstrapped 85% (ap_conn_done): Connected to a relay to build circuits
Oct 20 14:03:54 minibolt Tor-guardmidrelay[15079]: Bootstrapped 89% (ap_handshake): Finishing handshake with a relay to build circuits
Oct 20 14:03:54 minibolt Tor-guardmidrelay[15079]: Bootstrapped 90% (ap_handshake_done): Handshake finished with a relay to build circuits
Oct 20 14:03:54 minibolt Tor-guardmidrelay[15079]: Bootstrapped 95% (circuit_create): Establishing a Tor circuit
Oct 20 14:03:54 minibolt Tor-guardmidrelay[15079]: Bootstrapped 100% (done): Done
</code></pre>

</details>

* Obtain your `HASHED FINGERPRINT`

```bash
journalctl -u tor@guardmidrelay --since='1 hour ago' | grep "key fingerprint"
```

Example of expected output:

```
Oct 20 14:03:49 minibolt Tor-guardmidrelay[15079]: Your Tor server's identity key fingerprint is 'GuardMidRelay 8D4FE09E8CF58EEB437A6A7FB36B09D7D8D24389'
```

{% hint style="info" %}
\-> In this example, HASHED FINGERPRINT, would be: `8D4FE09E8CF58EEB437A6A7FB36B09D7D8D24389`

\-> Take note of this, about **3 hours** after you start your relay, it should appear on [Relay Search](https://metrics.torproject.org/rs.html) on the Metrics portal. You can search for your relay using your nickname, public IP address, or `HASHED FINGERPRINT` and monitor your Guard/Middle relay usage on Relay Search. Just enter some of them in the form and click on "Search"
{% endhint %}

### Validation

* Ensure that the Tor port related to the bridge and the Obfs4proxy service are working and listening at the the ports selected

```bash
sudo ss -tulpn | grep tor
```

**Example** of expected output:

<pre><code>tcp   LISTEN 0      4096              0.0.0.0:<a data-footnote-ref href="#user-content-fn-8">9001</a>      0.0.0.0:*    users:(("tor",pid=15332,fd=7))
tcp   LISTEN 0      4096            127.0.0.1:<a data-footnote-ref href="#user-content-fn-9">9051</a>      0.0.0.0:*    users:(("tor",pid=14928,fd=15))
tcp   LISTEN 0      4096            127.0.0.1:9050      0.0.0.0:*    users:(("tor",pid=14928,fd=6))
tcp   LISTEN 0      4096            127.0.0.1:9053      0.0.0.0:*    users:(("tor",pid=15332,fd=6))
</code></pre>

## Upgrade Guard/Middle relay

* To upgrade, use the package manager by typing this command

```bash
sudo apt update && sudo apt upgrade
```

## **Uninstall Tor Guard/Middle**

### Delete user & group <a href="#delete-user-and-group" id="delete-user-and-group"></a>

* Delete the `_tor-guardmidrelay` user. Don't worry about `userdel: _tor-guardmidrelay mail spool (/var/mail/_tor-guardmidrelay) not found` output, the uninstall has been successful

```bash
sudo userdel -rf _tor-guardmidrelay
```

### **Delete data directories & configuration**

* Delete data directories related to the obfs4bridge

{% code overflow="wrap" %}
```bash
sudo rm -r /var/lib/tor-instances/guardmidrelay && sudo rm -r /etc/tor/instances/guardmidrelay
```
{% endcode %}

### **Uninstall FW configuration and router NAT**

* Display the UFW firewall rules and note the numbers of the rules for the Tor Guard/Middle relay(e.g. X below)

```sh
sudo ufw status numbered
```

Expected output:

```
[...]
[X] 9001/tcp           ALLOW IN    Anywhere           # allow OR port Guard/Middle relay from anywhere
```

* Delete the rule with the correct number and confirm with "yes"

```sh
sudo ufw delete X
```

* Check the correct update of the rules

```sh
sudo ufw status verbose
```

{% hint style="info" %}
Reverts router NAT configuration following the same [Configure Firewall & ](tor-bridge.md#configure-firewall-and-router-nat-1)[Router (NAT) ](tor-bridge.md#configure-firewall-and-router-nat-1)previous step but this time deleting the configuration setting
{% endhint %}

## Extras (optional)

### **Nyx**

[Nyx](https://github.com/torproject/nyx) is a command-line monitor for Tor. With this, you can get detailed real-time information about your relays such as bandwidth usage, connections, logs, and much more.

* With user `admin`, install the Nyx package. Press "**y**" and `enter` or directly `enter` when the prompt asks you

```sh
sudo apt install nyx
```

\-> 3 options depending on the instance:

{% tabs %}
{% tab title="For the obfs4 bridge" %}
* Add the user `admin` to the `_tor-obfs4bridge` group

```
sudo adduser admin _tor-obfs4bridge
```
{% endtab %}

{% tab title="For the Guard/Middle relay" %}
* Add the user `admin` to the `_tor-guardminrelay` group

```
sudo adduser admin _tor-guardmidrelay
```
{% endtab %}

{% tab title="For the default instance" %}
* Add the user `admin` to the `debian-tor` group

```
sudo adduser admin debian-tor
```
{% endtab %}
{% endtabs %}

* The assigned group becomes active only in a new user session. Log out from SSH

```bash
exit
```

* Log in as the user `admin` again -> `ssh admin@minibolt.local`
* Execute Nyx, 3 options depending on the instance:

{% tabs %}
{% tab title="For the obfs4 bridge" %}
```bash
nyx -i 9052
```
{% endtab %}

{% tab title="For the Guard/Middle relay" %}
```bash
nyx -i 9053
```
{% endtab %}

{% tab title="For the default instance" %}
```bash
nyx
```

or

```bash
nyx -i 9051
```
{% endtab %}
{% endtabs %}

* Press the **right** `->` **navigation key** to navigate to page 2/5 to show the traffic of your Tor instance

![Example of an obsf4 bridge running](../../images/nyx-tor-bridge.png)

* Press `"q"` key **2 times** to exit

### **Add obfs4 bridge to the default Tor instance**

On some occasions, due to some circumstances, your ISP, the company's network, your country, etc, could be censoring your access to Tor and with it the proper functioning of MiniBolt services **(used on Bitcoin Core / LND + others)**

![](../../images/tor-failing.jpg)

* On the MiniBolt or external node, with the user `admin`, [install Tor](../../index-1/privacy.md#tor-installation) and the `ofbs4 proxy`.  Press "**y**" and `enter` or directly `enter` when the prompt asks you

```bash
sudo apt install obfs4proxy
```

* Check the correct installation

```bash
obfs4proxy -version
```

**Example of expected output:**

```
obfs4proxy-0.0.8
```

* Edit the `torrc` file

```sh
sudo nano /etc/tor/torrc
```

* Add the next lines at the end of the file

```
## Obfs4 bridge data
ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy --enableLogging --logLevel=INFO
UseBridges 1
Bridge obfs4 <IPADDRESS>:<PORT> <FINGERPRINT> cert=<CERTIFICATE> iat-mode=0
```

{% hint style="info" %}
\-> Add the needed lines with the number of bridges that you wish, replacing <**IPADDRESS>**, <**PORT>**, <**FINGERPRINT>**, and <**CERTIFICATE>** with those obtained before

\-> If you want to connect the Tor default instance to the obfs4bridge in the same host (in the same MiniBolt node) you need to set `127.0.0.1` as the `<IPADDRESS>` parameter instead of the node's public IP address

\-> If you want to connect the Tor default instance to the `obfs4bridge` of another host in the same local network, you need to specify the node IP address of the node that is hosting the obfs4 bridge as the `<IPADDRESS>` parameter instead of the node's public IP address, e.g. `192.168.X.X`
{% endhint %}

{% hint style="info" %}
\-> It is recommended to add more obfs4 bridges, you should have at least two for conflux

\-> Since many bridge addresses aren’t public, you may need to request some from the Tor Project. Visit this website [CLEARNET](https://bridges.torproject.org/options) / [ONION](http://yq5jjvr7drkjrelzhut7kgclfuro65jjlivyzfmxiq2kyv5lickrl4qd.onion/options), to get bridges. Push the **`Just give me bridges`** button or select obfs4 on the drop down and push the **`Get Bridges`** button. Select one or the 2 offered, and add the content to the `torrc` configuration as a line more similar like `Bridge obfs4 <IPADDRESS>:...`⬇️
{% endhint %}

<figure><img src="../../images/get-bridge.PNG" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
\-> Remember to add the word "`Bridge`" before the `obfs4 IP...` line got from Tor, if not, Tor daemon will give you an error.

Example:

```
Bridge obfs4 158.91.178.132:3304 34B1F1F5F1632381AFE5C7CAC4C1754AC361B036 cert=IN8IhZk3vFGuJY993wCYyUnSt2Y5WNks4HdWpU+mo0HNS9VeDFkhjlVHHQ/ll0sBlRw/KA iat-mode=0
Bridge obfs4 81.177.121.63:9471 68E9BE060C7CB1F4958DFFF9B76D64DE4DEABD74 cert=CMBeCEftMpVP1IPefS0uqbDwYvEf4CneC9DyW4/HkigxAu1W99MODbkv5Yv+oXYp5wi2Ig iat-mode=0
```



\-> There are many options to request and use bridges apart from using the "`https`" before explained method:

* Request bridges by emailing [bridges@torproject.org](mailto:bridges@torproject.org)
* Request bridges from within the Tor Browser:
  * Tor Browser Desktop: Click on "**Settings**" in the hamburger **menu (≡)** and then on "**Connection**" in the sidebar. In the "**Bridges**" section, from the option "**Find more bridges**" click on the "**Request bridges..**" button, and complete the captcha. Finally, if you wish, you can push the button "**Copy addresses**" to use it on the MiniBolt node or another Tor browser, like the Android version.&#x20;
* Use bridges from within the Tor Browser:
  * Tor Browser Desktop: Click on "**Settings**" in the hamburger **menu (≡)** and then on "**Connection**" in the sidebar. In the "**Bridges**" section, from the option "**Add bridges**" click on "**Add new bridges**" and enter each bridge address on a separate line.
  * Tor Browser Android: Tap on "**Settings"** (⚙️) and then on "**Config Bridge**". Toggle on "**Use a Bridge**" and select "Provide a Bridge I know'. Enter the bridge address. Note: remember not to add the word: "`Bridge`" before the `obfs4 IP...` line this is not compatible with the Tor browser Android version. Also, you can use random public obfs4 bridges by simply selecting the "**`obfs4`**" bridge option.
* Send a message to [@GetBridgesBot](https://t.me/GetBridgesBot) on Telegram. Tap on 'Start', write `/start` or `/bridges` in the chat.
{% endhint %}

* Restart Tor to apply changes

```sh
sudo systemctl restart tor@default
```

* Monitor tor logs to ensure all is correct

```bash
journalctl -fu tor@default
```

Ensure a similar line of the next appear on Tor logs:

```
Oct 18 21:31:35 minibolt Tor[1081477]: new bridge descriptor 'Obfs4Bridge' (fresh): $162CC010CF75411BCD67991C4DA1F166BF669754~Obfs4Bridge [luTt2cQAGji/6Obr+d7gSvpZo1uecd3SUROwCAxlpIk] at 11.11.94.58
```

{% hint style="info" %}
You can [install Nyx](tor-bridge.md#nyx) too on the MiniBolt or external node, realizing that you must follow the "`For the default instance`" case in all sections where there is a choice
{% endhint %}

* You can monitor obfs4 bridge logs with

```bash
sudo tail -f /var/lib/tor/pt_state/obfs4proxy.log
```

Example of expected output:

```
2024/10/18 21:31:31 [NOTICE]: obfs4proxy-0.0.14 - launched
2024/10/18 21:31:31 [INFO]: obfs4proxy - initializing client transport listeners
2024/10/18 21:31:31 [INFO]: obfs4 - registered listener: 127.0.0.1:41739
2024/10/18 21:31:31 [INFO]: obfs4proxy - accepting connections
```

### Limit bandwidth

If you use a VPS to host the obfs4 bridge or guard/middle relay, you probably have limited bandwidth in your plan. Tor has different parameters to limit the available bandwidth for each Tor service and not to overline it

* With user `admin` edit the torrc config file, 3 options depending on the instance:

{% tabs %}
{% tab title="For the obfs4 bridge" %}
```bash
sudo nano /etc/tor/instances/obfs4bridge/torrc
```
{% endtab %}

{% tab title="For the Guard/middle relay" %}
```bash
sudo nano /etc/tor/instances/guardmidrelay/torrc
```
{% endtab %}

{% tab title="For the default instance" %}
```bash
sudo nano /etc/tor/torrc
```
{% endtab %}
{% endtabs %}

* Add the next lines at the end of the file. Save and exit

This is an example for: \~ 30 GB/day \* 30 days = 900 GB for BandwidthMax <1 TB tx+rx, replace with your election

<pre><code>#### Guard/Middle relay limit total sum bandwidth
<a data-footnote-ref href="#user-content-fn-10">AccountingStart</a> day 12:00
<a data-footnote-ref href="#user-content-fn-11">AccountingMax</a> 30 GBytes
<a data-footnote-ref href="#user-content-fn-12">AccountingRule</a> sum
<a data-footnote-ref href="#user-content-fn-13">RelayBandwidthRate </a>1 MBytes
<a data-footnote-ref href="#user-content-fn-14">RelayBandwidthBurst</a> 1 MBytes
</code></pre>

{% hint style="info" %}
More info about limit bandwidth options: [HERE](https://support.torproject.org/relay-operators/bandwidth-shaping/) | [HERE](https://support.torproject.org/relay-operators/limit-total-bandwidth/)
{% endhint %}

* With user `admin`, restart Tor independently, 3 options depending on the instance:

{% tabs %}
{% tab title="For the obfs4 bridge" %}
```bash
sudo systemctl restart tor@obfs4bridge
```
{% endtab %}

{% tab title="For the Guard/Middle relay" %}
```bash
sudo systemctl restart tor@guardmidrelay
```
{% endtab %}

{% tab title="For the default instance" %}
```bash
sudo systemctl restart tor@default
```
{% endtab %}
{% endtabs %}

* If you want to restart all instances

```bash
sudo systemctl restart tor
```

* Monitor logs, 3 options depending on the instance:

{% tabs %}
{% tab title="For the obfs4 bridge" %}
```bash
journalctl -fu tor@obfs4bridge
```
{% endtab %}

{% tab title="For the Guard/Middle relay" %}
```bash
journalctl -fu tor@guardmidrelay
```
{% endtab %}

{% tab title="For the default instance" %}
```bash
journalctl -fu tor@default
```
{% endtab %}
{% endtabs %}

## Port reference

|   Port   | Protocol |             Use            |
| :------: | :------: | :------------------------: |
| \<TODO1> |    TCP   |    OR port obfs4 bridge    |
| \<TODO2> |    TCP   |         obfs4 port         |
|   9001   |    TCP   | OR port Guard/Middle relay |

[^1]: Replace

[^2]: Replace

[^3]: The obfs4 bridge fingerprint to search on the [Relay search](https://metrics.torproject.org/rs.html) Tor service

[^4]: Check this

[^5]: Check this

[^6]: Check this

[^7]: The Guard/Middle relay fingerprint to search on the [Relay search](https://metrics.torproject.org/rs.html) Tor service

[^8]: Check this

[^9]: Control port

[^10]: When the accounting period resets

[^11]: This specifies the maximum amount of data your relay will send during an accounting period, and the maximum amount of data your relay will receive during an accounting period

[^12]: Controls whether Tor tracks only incoming traffic, only outgoing traffic, or both, when applying bandwidth usage limits set with accounting options like `AccountingMax`. (Default: **max**)

    * **`sum`**: It counts both incoming and outgoing traffic (common on VPS)
    * **`in`**: It only counts incoming traffic.
    * **`out`**: It only counts outgoing traffic.
    * **`max`**: calculate using the higher of either the sent or received bytes.

[^13]: Controls the amount of bandwidth your Tor relay or bridge can consistently use to relay traffic

[^14]: Lets your Tor relay or bridge use more bandwidth than the sustained limit during brief spikes in traffic, allowing it to handle sudden increases in demand without immediately throttling
