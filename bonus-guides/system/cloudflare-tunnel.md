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

# Cloudflare Tunnel

Cloudflare tunnel offers an alternative to those solutions with a single downside: Cloudflare can see or modify all of your traffic, as it acts as a middleman between the client's browser and your local server.

With Cloudflare tunnel, you will enjoy low latency access to your server, on clearnet, and WITHOUT the need to configure your Firewall, Internet router, dynamic DNS, and any internet service provider. For free.

{% hint style="warning" %}
Difficulty: Medium
{% endhint %}

{% hint style="success" %}
Status: Tested MiniBolt
{% endhint %}

<figure><img src="../../.gitbook/assets/network-diagram-cloudflared.png" alt=""><figcaption></figcaption></figure>

## [​​](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/local/#prerequisites) Prerequisites <a href="#prerequisites" id="prerequisites"></a>

Before you start, make sure you:

* Add a website to Cloudflare

Exist different options to buy a domain

* Change your domain nameservers to Cloudflare

## Installation

* With user `admin`, go to the temporary folder

```bash
$ cd /tmp
```

* Download Cloudflared

{% code overflow="wrap" %}
```bash
$ wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
```
{% endcode %}

* Use the deb package manager to install it

```bash
$ sudo dpkg -i cloudflared-linux-amd64.deb
```

* Check the correct installation

```bash
$ cloudflared --version
```

**Example** of expected output:

```
> cloudflared version 2023.6.1 (built 2023-06-20-0926 UTC)
```

## Authenticate on Cloudflare <a href="#2-authenticate-cloudflared" id="2-authenticate-cloudflared"></a>

* With user `admin`, authenticate on your Cloudflared

```bash
$ cloudflared tunnel login
```

* Open a browser window and prompt you to log in to your Cloudflare account. After logging in to your account, select your hostname.

{% hint style="info" %}
Leave Cloudflared running to download the cert automatically
{% endhint %}

Expected output:

```
> You have successfully logged in.
> If you wish to copy your credentials to a server, they have been saved to:
> /home/admin/.cloudflared/cert.pem
```

## Create a tunnel and give it a name <a href="#3-create-a-tunnel-and-give-it-a-name" id="3-create-a-tunnel-and-give-it-a-name"></a>

<pre class="language-bash"><code class="lang-bash">$ cloudflared tunnel create <a data-footnote-ref href="#user-content-fn-1">&#x3C;NAME></a>
</code></pre>

{% hint style="info" %}
Suggestion \<NAME> = miniboltunnel
{% endhint %}

**Example** of expected output:

<pre><code>Tunnel credentials written to /home/admin/.cloudflared/8666c35d-6ac3-4b39-9324-12ae32ce64a7.json. cloudflared chose this file based on where your origin certificate was found. Keep this file secret. To revoke these credentials, delete the tunnel.

Created tunnel miniboltunnel with id <a data-footnote-ref href="#user-content-fn-2">8666c35d-6ac3-4b39-9324-12ae32ce64a7</a>
</code></pre>

{% hint style="info" %}
Take note of the tunnel \<UUID>: e.g 8666c35d-6ac3-4b39-9324-12ae32ce64a7
{% endhint %}

* Ensure that the tunnel has been created

```bash
$ cloudflared tunnel list
```

**Example** of expected output:

<pre><code>You can obtain more detailed information for each tunnel with `cloudflared tunnel info &#x3C;name/uuid>`
ID                                      NAME              CREATED               CONNECTIONS
<a data-footnote-ref href="#user-content-fn-3">8666c35d-6ac3-4b39-9324-12ae32ce64a7</a>    miniboltunnel     2023-04-01T15:44:48Z
</code></pre>

You can obtain more detailed information about the tunnel with

```bash
$ cloudflared tunnel info miniboltunnel
```

**Example** of expected output:

```
NAME:     miniboltunnel
ID:       8666c35d-6ac3-4b39-9324-12ae32ce64a7
CREATED:  2023-07-09 19:16:12.744487 +0000 UTC

CONNECTOR ID                         CREATED              ARCHITECTURE VERSION  ORIGIN IP      EDGE
8666c35d-6ac3-4b39-9324-12ae32ce64a7 2023-07-10T16:20:41Z linux_amd64  2023.6.1 <yourpublicip>
```

### Start routing traffic <a href="#5-start-routing-traffic" id="5-start-routing-traffic"></a>

* Now assign a CNAME record that points traffic to your tunnel subdomain

<pre class="language-bash" data-overflow="wrap"><code class="lang-bash"><strong>$ cloudflared tunnel route dns &#x3C;UUID> subdomain.domain.com
</strong></code></pre>

**Example** of expected output:

```
> 2023-07-09T18:01:07Z INF Added CNAME subdomain.domain.com which will route to this tunnel tunnelID=8666c35d-6ac3-4b39-9324-12ae32ce64a7
```

## Create a configuration file

We will create a configuration file in your `.cloudflared` directory. This file will configure the tunnel to route traffic from a given origin to the hostname of your choice. We will use ingress rules to let you specify which local services traffic should be proxied to.

* Staying with user `admin`

```bash
$ nano /home/admin/.cloudflared/config.yml
```

* Replace

```
# MiniBolt: cloudflared configuration
# /home/admin/.cloudflared/config.yml

tunnel: 8666c35d-6ac3-4b39-9324-12ae32ce64a7
credentials-file: /home/admin/.cloudflared/8666c35d-6ac3-4b39-9324-12ae32ce64a7.json

ingress:

# BTCpay
  - hostname: btcpay.<yourdomain>
    service: http://localhost:23000

# BTC RPC Eplorer
  - hostname: explorer.<yourdomain>
    service: http://localhost:3002

  - service: http_status:404
```

## Autostart Cloudflared on boot

Create the configuration file in the nano text editor and copy the following paragraph. Save and exit

```bash
$ sudo nano /etc/systemd/system/cloudflared.service
```

```
# MiniBolt: systemd unit for Cloudflared
# /etc/systemd/system/cloudflared.service

[Unit]
Description=Cloudflared
After=network.target

[Service]
TimeoutStartSec=0
Type=notify
ExecStart=/usr/bin/cloudflared --no-autoupdate --config /home/admin/.cloudflared/config.yml tunnel run

[Install]
WantedBy=multi-user.target
```

* Enable autoboot

```bash
$ sudo systemctl enable cloudflared
```

* Prepare `cloudflared` monitoring by the systemd journal and checking the logging output. You can exit monitoring at any time with Ctrl-C

```bash
$ sudo journalctl -f -u cloudflared
```

{% hint style="info" %}
Keep **this terminal open,** you'll need to come back here on the next step to monitor the logs
{% endhint %}

### Start Cloudflared and run the tunnel <a href="#6-run-the-tunnel" id="6-run-the-tunnel"></a>

* To keep an eye on the software movements, [start your SSH program](../../system/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as `admin.` Commands for the **second session** start with the prompt `$2` (which must not be entered). Run the tunnel to proxy incoming traffic from the tunnel to any number of services running locally on your origin.&#x20;

```bash
$ sudo systemctl start cloudflared
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>$ sudo journalctl -f -u cloudflared</code> ⬇️</summary>

```
Jul 10 18:20:40 minibolt cloudflared[3405663]: 2023-07-10T16:20:40Z INF Starting tunnel tunnelID=8666c35d-6ac3-4b39-9324-12ae32ce64a7
Jul 10 18:20:40 minibolt cloudflared[3405663]: 2023-07-10T16:20:40Z INF Version 2023.6.1
Jul 10 18:20:40 minibolt cloudflared[3405663]: 2023-07-10T16:20:40Z INF GOOS: linux, GOVersion: go1.19.6, GoArch: amd64
Jul 10 18:20:40 minibolt cloudflared[3405663]: 2023-07-10T16:20:40Z INF Settings: map[config:/home/admin/.cloudflared/config.yml cred-file:/home/admin/.cloudflared/8666c35d-6ac3-4b39-9324-12ae32ce64a7.json credentials-file:/home/admin/.cloudflared/8666c35d-6ac3-4b39-9324-12ae32ce64a7.json no-autoupdate:true]
Jul 10 18:20:40 minibolt cloudflared[3405663]: 2023-07-10T16:20:40Z INF Generated Connector ID: ca7ebf91-844d-4025-89f0-e28df084d0a2
Jul 10 18:20:40 minibolt cloudflared[3405663]: 2023-07-10T16:20:40Z INF cloudflared will not automatically update if installed by a package manager.
Jul 10 18:20:40 minibolt cloudflared[3405663]: 2023-07-10T16:20:40Z INF Initial protocol quic
Jul 10 18:20:40 minibolt cloudflared[3405663]: 2023-07-10T16:20:40Z INF ICMP proxy will use 192.168.1.87 as source for IPv4
Jul 10 18:20:40 minibolt cloudflared[3405663]: 2023-07-10T16:20:40Z INF ICMP proxy will use fe80::42a8:f0ff:feb0:aa4d in zone eno1 as source for IPv6
Jul 10 18:20:40 minibolt cloudflared[3405663]: 2023-07-10T16:20:40Z INF Starting metrics server on 127.0.0.1:46345/metrics
Jul 10 18:20:40 minibolt cloudflared[3405663]: 2023/07/10 18:20:40 failed to sufficiently increase receive buffer size (was: 208 kiB, wanted: 2048 kiB, got: 416 kiB). See https://github.com/quic-go/quic-go/wiki/UDP-Receive-Buffer-Size for details.
Jul 10 18:20:41 minibolt cloudflared[3405663]: 2023-07-10T16:20:41Z INF Registered tunnel connection connIndex=0 connection=0c293573-9581-4087-ab56-504d7eca57a1 event=0 ip=198.41.200.23 location=MAD protocol=quic
Jul 10 18:20:41 minibolt systemd[1]: Started cloudflared.
Jul 10 18:20:41 minibolt cloudflared[3405663]: 2023-07-10T16:20:41Z INF Registered tunnel connection connIndex=1 connection=cb1e7bb6-9051-43da-802e-1791687f7385 event=0 ip=198.41.192.57 location=MRS protocol=quic
Jul 10 18:20:43 minibolt cloudflared[3405663]: 2023-07-10T16:20:43Z INF Registered tunnel connection connIndex=2 connection=749064a4-fe1d-4c07-b0b9-71dbc0bcbe3a event=0 ip=198.41.192.227 location=MRS protocol=quic
Jul 10 18:20:43 minibolt cloudflared[3405663]: 2023-07-10T16:20:43Z INF Registered tunnel connection connIndex=3 connection=00f2ca81-1dd1-4695-9857-6815b376855b event=0 ip=198.41.200.33 location=MAD protocol=quic
```

</details>

[^1]: Suggestion: miniboltunnel

[^2]: \<UUID>

[^3]: \<UUID>
