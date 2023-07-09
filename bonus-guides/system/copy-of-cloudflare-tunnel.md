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

# Copy of Cloudflare Tunnel

Cloudflare tunnel offers an alternative to those solutions with a single downside: Cloudflare can see or modify all of your traffic, as it acts as a middleman between the client's browser and your local server.

With Cloudflare tunnel, you will enjoy low latency access to your server, on clearnet, and WITHOUT the need to configure your Firewall, Internet router, dynamic DNS, and any internet service provider. For free.

{% hint style="info" %}

{% endhint %}

{% hint style="info" %}

{% endhint %}

<figure><img src="../../.gitbook/assets/network-diagram-cloudflared.png" alt=""><figcaption></figcaption></figure>

## [​​](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/local/#prerequisites) Prerequisites <a href="#prerequisites" id="prerequisites"></a>

Before you start, make sure you:

* Add a website to Cloudflare
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

```bash
$ cloudflared tunnel create <NAME>
```

{% hint style="info" %}
Suggestion: choose a NAME that defines the service behind it, e.g. btcpay, electrs, fulcrum, etc
{% endhint %}

**Example** of expected output:

```
Tunnel credentials written to /home/admin/.cloudflared/8566c33454-6ac3-4b39-3484-88ae32ce55a6.json. cloudflared chose this file based on where your origin certificate was found. Keep this file secret. To revoke these credentials, delete the tunnel.

Created tunnel btcpay with id 8566c33454-6ac3-4b39-3484-88ae32ce55a6
```

{% hint style="info" %}
Take note of the tunnel UUID: e.g 8566c33454-6ac3-4b39-3484-88ae32ce55a6
{% endhint %}

* To ensure that the tunnel has been created

```bash
$ cloudflared tunnel list
```

**Example** of expected output:

```
You can obtain more detailed information for each tunnel with `cloudflared tunnel info <name/uuid>`
ID                                     NAME       CREATED              CONNECTIONS
8566c33454-6ac3-4b39-3484-88ae32ce55a6 btcpay     2023-04-01T15:44:48Z
```

## Create a configuration file

We will create a configuration file in your `.cloudflared` directory. This file will configure the tunnel to route traffic from a given origin to the hostname of your choice.

* Staying with user `admin`

```bash
$ sudo nano /etc/cloudflared/config.yml
```

* Replace Save and exit

<pre><code># MiniBolt: cloudflared configuration
<strong># /home/admin/.cloudflared/config.yml
</strong>
## BTCpay tunnel
url: http://localhost:23000
tunnel: 8566c33454-6ac3-4b39-3484-88ae32ce55a6
credentials-file: /home/admin/.cloudflared/8566c33454-6ac3-4b39-3484-88ae32ce55a6.json
</code></pre>

### Start routing traffic <a href="#5-start-routing-traffic" id="5-start-routing-traffic"></a>

* Now assign a CNAME record that points traffic to your tunnel subdomain

{% code overflow="wrap" %}
```bash
$ cloudflared tunnel route dns 8566c33454-6ac3-4b39-3484-88ae32ce55a6 subdomain.domain.com
```
{% endcode %}

**Example** of expected output:

```
> 2023-07-09T18:01:07Z INF Added CNAME subdomain.domain.com which will route to this tunnel tunnelID=8566c33454-6ac3-4b39-3484-88ae32ce55a6
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
Description=cloudflared
After=network.target

[Service]
TimeoutStartSec=0
Type=notify
ExecStart=/usr/bin/cloudflared --no-autoupdate --config /etc/cloudflared/config.yml tunnel run

[Install]
WantedBy=multi-user.target
```



### Run the tunnel <a href="#6-run-the-tunnel" id="6-run-the-tunnel"></a>

* Run the tunnel to proxy incoming traffic from the tunnel to any number of services running locally on your origin

```bash
$ cloudflared tunnel run <UUID or NAME>
```

**Example** of expected out:

```
2023-07-09T18:06:36Z INF Starting tunnel tunnelID=8566c35d-6ac3-4b39-9584-55ae32ce64a6
2023-07-09T18:06:36Z INF Version 2023.6.1
2023-07-09T18:06:36Z INF GOOS: linux, GOVersion: go1.19.6, GoArch: amd64
2023-07-09T18:06:36Z INF Settings: map[cred-file:/home/admin/.cloudflared/8566c35d-6ac3-4b39-9584-55ae32ce64a6.json credentials-file:/home/admin/.cloudflared/8566c35d-6ac3-4b39-9584-55ae32ce64a6.json url:http://localhost:23000]
2023-07-09T18:06:36Z INF cloudflared will not automatically update if installed by a package manager.
2023-07-09T18:06:36Z INF Generated Connector ID: 8c40c55a-4b28-4537-92c3-f9b1be7834ff
2023-07-09T18:06:36Z INF Initial protocol quic
2023-07-09T18:06:36Z INF ICMP proxy will use 192.168.1.87 as source for IPv4
2023-07-09T18:06:36Z INF ICMP proxy will use fe80::42a8:f0ff:feb0:aa4d in zone eno1 as source for IPv6
2023-07-09T18:06:37Z INF Starting metrics server on 127.0.0.1:37821/metrics
2023/07/09 20:06:37 failed to sufficiently increase receive buffer size (was: 208 kiB, wanted: 2048 kiB, got: 416 kiB). See https://github.com/quic-go/quic-go/wiki/UDP-Receive-Buffer-Size for details.
2023-07-09T18:06:37Z INF Registered tunnel connection connIndex=0 connection=7af1b688-69da-4760-9a92-f7f0aea44e89 event=0 ip=198.41.200.73 location=MAD protocol=quic
2023-07-09T18:06:38Z INF Registered tunnel connection connIndex=1 connection=4f240612-7844-4583-806d-1cbbfbdea5e2 event=0 ip=198.41.192.77 location=MRS protocol=quic
2023-07-09T18:06:39Z INF Registered tunnel connection connIndex=2 connection=3351c4e1-d522-48a0-826e-12e729f86787 event=0 ip=198.41.200.53 location=MAD protocol=quic
2023-07-09T18:06:40Z INF Registered tunnel connection connIndex=3 connection=8640bb32-0702-416d-ba7c-1d60f6a0168b event=0 ip=198.41.192.27 location=MRS protocol=quic
```





* With user "admin" copy-paste the config.yml to `/etc/cloudflared`

<pre class="language-bash"><code class="lang-bash"><strong>$ sudo cp config.yml /etc/cloudflared/
</strong></code></pre>

* Install the `cloudflared` service

```bash
sudo cloudflared --config /etc/cloudflared/config.yml service install
```

*
