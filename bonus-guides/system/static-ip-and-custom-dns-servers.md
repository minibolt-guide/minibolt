# Static IP & custom DNS servers

Set a static IP address and custom DNS nameservers for your MiniBolt.

{% hint style="success" %}
Difficulty: Easy
{% endhint %}

<figure><img src="../../.gitbook/assets/static-ip-custom-dns.PNG" alt=""><figcaption></figcaption></figure>

The router reserves the IP address of the device for a time after going out, but if the device goes out some time, the next time that the device starts, the router could assign a different IP and you could lose access to your node. To avoid this, you need to set a static IP to your node.

{% hint style="danger" %}
**Be careful by setting this!** If you change the router, could be the new router doesn't work in the same IP address range as the old router, the device won't be registered on the local network and will be completely out of the connection.

💡 To avoid this, you will need to **enable the "Automatic (DHCP)" mode before changing the router**, following the [Set the DCHP (automatic) configuration (by command line) section](static-ip-and-custom-dns-servers.md#set-the-automatic-dhcp-mode-configuration-by-command-line) to ensure that the DHCP server auto assigns an IP to the node in the range you are working on, and if you want, after router change, reconfigure the static IP address again following the [Option 2](static-ip-and-custom-dns-servers.md#option-2-after-ubuntu-server-installation-by-command-line) of this guide.

If you don't do this, you will have to attach the monitor screen or television and keyboard to fix this.
{% endhint %}

{% hint style="info" %}
In addition, you can customize your DNS servers to improve your privacy, normally your ISP, gives you the router with its own DNS servers configured by default, and this does that you exposes all of your navigation trackings to your ISP, affecting seriously your privacy.
{% endhint %}

## Option 1: At the beginning, during the Ubuntu Server installation GUI

When you arrive at **step 5** of the [Ubuntu Server installation](../../index-1/operating-system.md#ubuntu-server-installation), you can want to choose set a static IP address and customize the DNS nameserver/s.

Wait for the router to automatically assign the IP address to your MiniBolt node to find out what IP range the node is in, you will be able to assign the same or a different IP in the next step.

<figure><img src="../../.gitbook/assets/static-ip-dns-gif.gif" alt=""><figcaption><p>GIF example of a Static IP &#x26; custom DNS server configuration</p></figcaption></figure>

> > **Subnet:** your router subnet, e.g **192.168.1.0/24**
>
> > **Address**: your assigned local IP address, eg. **192.168.1.87**
>
> > **Gateway:** you router IP, eg. **192.168.1.1**
>
> > **Name servers:** DNS servers choosen (<mark style="color:red;">**important!**</mark>), eg. same of gateway (**192.168.1.1,192.168.1.1**) (your ISP DNS (not recommended)) or **Custom DNS server (recommended)**: Cloudflare (**1.1.1.1,1.0.0.1**) or another (Quad9, MullvadDNS, BlahDNS, etc), check the next annotations for more info
>
> > **Search domains:** \<left blank>

{% hint style="info" %}
This is **only** an **example** if your local network IP range is `192.168.1.0-255`, because for this case, the router assigned to the device the IP address **192.168.1.29**, but it could be **192.168.0.29** `(192.168.0.0-255)`, then you will need to set this instead:

> **Subnet:** 192.168.0.0/24

> **Gateway:** 192.168.0.1
{% endhint %}

{% hint style="danger" %}
In this step, you must set DNS name servers too, otherwise, the host will be offline and will not be able to connect to the Internet
{% endhint %}

{% hint style="info" %}
For this example, we have configured [Cloudflare DNS name servers](https://www.cloudflare.com/learning/dns/what-is-1.1.1.1/) (1.1.1.1,1.0.0.1) but you could put other privacy-focused DNS like:

* [Quad9](https://quad9.net/): 9.9.9.9,149.112.112.112
* [MullvadDNS](https://mullvad.net/en/help/dns-over-https-and-dns-over-tls): 194.242.2.2
* [DNS.SB](https://dns.sb/): 185.222.222.222,45.11.45.11
* [BlahDNS](https://blahdns.com/): 46.250.226.242,78.46.244.143
{% endhint %}

## Option 2: After Ubuntu Server installation (by command line)

After doing the [1.3 Remote access](remote-access.md) section, you could want to set a static IP address to your MiniBolt by the command line.

#### Preparations

* Stay login with user **admin**, and check your current data network interface by doing

```bash
ip address
```

Check your configuration, the next output is **only** an **example** of a concrete case, but in your case, it could be different:

<pre><code>1: lo: &#x3C;LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: <a data-footnote-ref href="#user-content-fn-1">eno1</a>: &#x3C;BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 42:a5:f1:ab:6f:33 brd ff:ff:ff:ff:ff:ff
    altname enp0s25
    inet <a data-footnote-ref href="#user-content-fn-2">192.168.1.87</a>/24 metric 100 brd 192.168.1.255 scope global dynamic eno1
       valid_lft 76855sec preferred_lft 76855sec
    inet6 fe80::42a8:f0ff:feac:6a37/64 scope link
       valid_lft forever preferred_lft forever
</code></pre>

Definitions in the case of before:

> > ```
> > <interface> = e.g eno1
> > ```
>
> > ```
> > <ipaddress> = e.g 192.168.1.87
> > ```
>
> > ```
> > <gateway> = 192.168.1.1 (this case) -> case 192.168.0.X, choose 192.168.0.1
> > ```

{% hint style="info" %}
**Take note** of your case data, you will need it later
{% endhint %}

* Check the current DNS server set, typing the next command

```bash
resolvectl status
```

<details>

<summary><strong>Example</strong> of expected output (more common) ⬇️</summary>

<pre><code>Global
       Protocols: -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
resolv.conf mode: stub

Link 2 (eno1)
    Current Scopes: DNS
         Protocols: +DefaultRoute +LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
Current DNS Server: <a data-footnote-ref href="#user-content-fn-3">192.168.1.1</a>
       DNS Servers: <a data-footnote-ref href="#user-content-fn-3">192.168.1.1</a>
        DNS Domain: home
</code></pre>

</details>

In the previous case:

> > ```
> > <nameserver1> = 192.168.1.1 ( = <gateway>, the DNS servers of your ISP)
> > ```
>
> > ```
> > <nameserver2> = (secondary DNS server, not set in this case)
> > ```

#### Configuration

{% hint style="warning" %}
Remember, always back up your current network configuration before making changes. This ensures you can restore the previous configuration if something goes wrong
{% endhint %}

{% hint style="info" %}
We will use Netplan with the `systemd-networkd` renderer backend
{% endhint %}

* Edit the content of the `.yaml` file

<pre class="language-bash"><code class="lang-bash"><strong>sudo nano /etc/netplan/50-cloud-init.yaml
</strong></code></pre>

{% hint style="info" %}
The name of the file could be different in your case. If the file is empty when you type the next command, press Ctrl + X to exit, and enter the next command to show the real name of your file `ls /etc/netplan`. Replace the name of the `.yaml` file in the previous command and try again, this time it should have content
{% endhint %}

* Replace the content to match this template

```yaml
network:
  ethernets:
    <interface>:
      addresses:
      - <ipaddress>/24
      nameservers:
        addresses:
        - <nameserver1>
        - <nameserver2>
        search: []
      routes:
      - to: default
        via: <gateway>
  version: 2
```

{% hint style="info" %}
-> Replace **\<interface>**, **\<ipaddress>**, **\<nameserver1>, \<nameserver2>** <- (nameservers optional but recommended)**,** and **\<gateway>** to your own data.\
\
-> You can choose the DNS server (**\<nameserver1> +** **\<nameserver2>**) whatever you want, including the default one set in the DNS server of your router (normally DNS servers of your ISP), in this last case, you should type the **\<gateway>** address in **\<nameserver1>** and the same in **\<nameserver2>**.

For this example, we have configured [Cloudflare DNS name servers](https://www.cloudflare.com/learning/dns/what-is-1.1.1.1/) (1.1.1.1,1.0.0.1), but you could set other privacy-focused servers like:

* [Quad9](https://quad9.net/): 9.9.9.9,149.112.112.112
* [MullvadDNS](https://mullvad.net/en/help/dns-over-https-and-dns-over-tls): 194.242.2.2
* [DNS.SB](https://dns.sb/): 185.222.222.222,45.11.45.11
* [BlahDNS](https://blahdns.com/): 46.250.226.242,78.46.244.143
{% endhint %}

<details>

<summary>Example ⬇️</summary>

```
network:
  ethernets:
    eno1:
      addresses:
      - 192.168.1.87/24
      nameservers:
        addresses:
        - 1.1.1.1
        - 1.0.0.1
        search: []
      routes:
      - to: default
        via: 192.168.1.1
  version: 2
```

</details>

* Apply the configuration temporarily

```bash
sudo netplan try
```

{% hint style="info" %}
If prompts show you:

```
WARNING:root:Cannot call Open vSwitch: ovsdb-server.service is not running.
Do you want to keep these settings?

Press ENTER before the timeout to accept the new configuration
```

This means that changes were successfully applied without breaking the connection, then press `ENTER` to accept and apply the new configuration, if not, don't worry, changes will be reverted after 120 seconds and you will connect to the MiniBolt again
{% endhint %}

* Check the correct configuration previously set

```bash
sudo netplan get
```

{% hint style="success" %}
Now you have set your static IP address and custom DNS servers
{% endhint %}

{% hint style="info" %}
If you chose a different IP address than the router assigned you at first and has currently, this step could break the current SSH connection, reconnect using the new and chosen IP address
{% endhint %}

#### Validation

* To check the successful IP address change, type the next command

```bash
ip address
```

{% hint style="info" %}
The output of this command **may not change**, depending on whether you chose the same IP that the router originally assigned you at the beginning, or whether you decided to change to another
{% endhint %}

* To check the successful DNS server change, type the next command

```bash
resolvectl status
```

<details>

<summary>Example of expected output ⬇️</summary>

<pre><code>Global
       Protocols: -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
resolv.conf mode: stub

Link 2 (eno1)
    Current Scopes: DNS
         Protocols: +DefaultRoute +LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
Current DNS Server: <a data-footnote-ref href="#user-content-fn-3">1.1.1.1</a>
       DNS Servers: <a data-footnote-ref href="#user-content-fn-3">1.1.1.1</a> <a data-footnote-ref href="#user-content-fn-3">1.0.0.1</a>
[...]
</code></pre>

</details>

Or if you prefer:

```bash
networkctl status
```

<details>

<summary>Example of expected output ⬇️</summary>

<pre><code>●        State: routable
  Online state: online
       Address: <a data-footnote-ref href="#user-content-fn-3">192.168.1.87</a> on eno1
                10.0.1.1 on wg0
                fe80::1e69:7aff:feac:8129 on eno1
       Gateway: 192.168.1.1 on eno1
           DNS: <a data-footnote-ref href="#user-content-fn-3">1.1.1.1</a>
                <a data-footnote-ref href="#user-content-fn-3">1.0.0.1</a>
           NTP: 10.28.64.1
</code></pre>

</details>

Or if you prefer:

```bash
sudo netplan status --all
```

<details>

<summary>Example of expected output ⬇️</summary>

<pre><code>     Online state: online
    DNS Addresses: 127.0.0.53 (stub)
       DNS Search: .

●  1: lo ethernet UNKNOWN/UP (unmanaged)
      MAC Address: 00:00:00:00:00:00
        Addresses: 127.0.0.1/8
                   ::1/128
           Routes: ::1 metric 256

●  2: eno1 ethernet UP (networkd: eno1)
      MAC Address: 00:0c:19:4f:c6:c9 (Intel Corporation)
        Addresses: <a data-footnote-ref href="#user-content-fn-3">192.168.1.87</a>/24
                   fe80::20c:29ff:fe8f:c7c8/64 (link)
    DNS Addresses: <a data-footnote-ref href="#user-content-fn-3">1.1.1.1</a>
                   <a data-footnote-ref href="#user-content-fn-3">1.0.0.1</a>
           Routes: default via 192.168.1.1 (static)
                   192.168.1.0/24 from 192.168.1.44 (link)
                   fe80::/64 metric 256
</code></pre>

</details>

## Set the A**utomatic (DHCP) mode** configuration (by command line)

{% hint style="info" %}
If you go to change the router you could want to enable or check if you have enabled the a**utomatic (DHCP) mode** configuration to avoid problems

We will use Netplan with the `systemd-networkd` renderer backend (default on Ubuntu Server)
{% endhint %}

Configuration

* Edit the content of the next file

<pre class="language-bash"><code class="lang-bash"><strong>sudo nano /etc/netplan/50-cloud-init.yaml
</strong></code></pre>

{% hint style="info" %}
The name of the file could be different in your case. If the file is empty when you type the next command, press Ctrl + X to exit, and enter the next command to show the real name of your file `ls /etc/netplan`. Replace the name of the `.yaml` file in the previous command and try again, this time it should have content
{% endhint %}

* Replace the content to match this template, replacing **\<interface>** with your data obtained in the [Preparations](static-ip-and-custom-dns-servers.md#preparations) section before

```yaml
network:
  ethernets:
    <interface>
      dhcp4: true
  version: 2
```

* Apply the configuration temporarily

```bash
sudo netplan try
```

{% hint style="info" %}
If prompts show you:

```
WARNING:root:Cannot call Open vSwitch: ovsdb-server.service is not running.
Do you want to keep these settings?

Press ENTER before the timeout to accept the new configuration
```

This means that changes were successfully applied without breaking the connection, then press `ENTER` to accept and apply the new configuration (**`Configuration accepted.`**), if not, don't worry, changes will be reverted after 120 seconds and you will connect to the MiniBolt again
{% endhint %}

* Check the correct configuration previously set

```bash
sudo netplan get
```

* Check the correct application

```bash
sudo netplan status --all
```

<details>

<summary>Example of expected output ⬇️</summary>

<pre><code>     Online state: online
    DNS Addresses: 127.0.0.53 (stub)
       DNS Search: .

●  1: lo ethernet UNKNOWN/UP (unmanaged)
      MAC Address: 00:00:00:00:00:00
        Addresses: 127.0.0.1/8
                   ::1/128
           Routes: ::1 metric 256

●  2: eno1 ethernet UP (networkd: eno1)
      MAC Address: 00:1c:26:7f:c7:c9 (Intel Corporation)
        Addresses: <a data-footnote-ref href="#user-content-fn-3">192.168.1.87</a>/24 (dhcp)
                   fe80::20c:28ff:fe8f:c7c6/64 (link)
    DNS Addresses: <a data-footnote-ref href="#user-content-fn-3">1.1.1.1</a>
                   <a data-footnote-ref href="#user-content-fn-3">1.0.0.1</a>
           Routes: default via 192.168.1.1 from 192.168.1.44 metric 100 (dhcp)
                   1.0.0.1 via 192.168.1.1 from 192.168.1.44 metric 100 (dhcp)
                   1.1.1.1 via 192.168.1.1 from 192.168.1.44 metric 100 (dhcp)
                   10.25.0.1 via 192.168.1.1 from 192.168.1.44 metric 100 (dhcp)
                   192.168.1.0/24 from 192.168.1.44 metric 100 (link)
                   192.168.1.1 from 192.168.1.44 metric 100 (dhcp, link)
                   fe80::/64 metric 256
</code></pre>

</details>

{% hint style="info" %}
Also, you can check changes are applied correctly following the same [validation](static-ip-and-custom-dns-servers.md#validation) steps as before
{% endhint %}

{% hint style="success" %}
You have gone back to the **automatic (DHCP) mode** configuration successfully
{% endhint %}

## Extras (optional)

### DoT/DoH + DNSSEC

DNS-over-TLS (DoT) and DNS-over-HTTPS (DoH) enhance security by encrypting DNS queries, making them resistant to eavesdropping and tampering. This ensures privacy during DNS transmissions, as unencrypted DNS queries are otherwise sent in plain text, leaving them vulnerable to interception by attackers or third parties. These protocols protect DNS traffic from such threats, strengthening network security. However, they do not prevent all types of DNS-related attacks and should be complemented with measures like DNSSEC.

**What are the reasons for choosing** [**Option 1**](static-ip-and-custom-dns-servers.md#option-1-use-dot-and-dnssec-validation-with-systemd-resolved) **or** [**Option 2**](static-ip-and-custom-dns-servers.md#option-2-use-doh-with-cloudflared-proxy-dns)**?**

[**Option 1: DoT & DNSSEC using `systemd-resolved`**](static-ip-and-custom-dns-servers.md#option-1-use-dot-and-dnssec-validation-with-systemd-resolved) (recommended for **common situations**):&#x20;

* Pre-installed by default in the Ubuntu server.
* Better suited for securing DNS traffic at the system or network level, offering simpler configurations and better performance for dedicated DNS resolver setups.
* Run directly over a TLS tunnel without HTTP layering underneath. This may result in a small performance improvement depending on the network environment.
* Allow enabling DNSSEC verification on the MiniBolt node (from the DNS client), without relying on validation of the selected DNS servers.
* Traffic is distinguished as DNS over port 853, and may be blocked if the port is restricted.

[**Option 2: DoH using Cloudflare proxy DNS**](static-ip-and-custom-dns-servers.md#option-2-use-doh-with-cloudflared-proxy-dns) (recommended for **hostile and censor scenarios**):

* Needs to install an external Cloudflare software binary (Cloudflared).
* Not DNSSEC enabling available, relying on validation of the selected DNS servers.
* Offers greater flexibility and better evasion of network restrictions. Traffic blends with general HTTPS (port 443), making it harder to distinguish and block as it uses the same port.

#### Option 1: Use DoT & DNSSEC validation with `systemd-resolved`

To avoid DNS servers would be automatically obtained from the DHCP server (router) for the interface, and overriding the `systemd-resolved` configuration, we need to override the network configuration with `netplan` to manually configure the DNS server.

* With user `admin` , edit the content of the `.yaml` file

```bash
sudo nano /etc/netplan/50-cloud-init.yaml
```

{% hint style="info" %}
The name of the file could be different in your case. If the file is empty when you type the next command, press Ctrl + X to exit, and enter the next command to show the real name of your file `ls /etc/netplan`. Replace the name of the `.yaml` file in the previous command and try again, this time it should have content
{% endhint %}

**-> 2 cases**, depending on whether **you configured a static IP** following the previous sections **or not**:

{% tabs %}
{% tab title="Case 1: Static IP setted" %}
* Replace the content to match the next template by deleting the "nameservers" configuration section (the next):

```yaml
      nameservers:
        addresses:
        - <nameserver1>
        - <nameserver2>
        search: []
```

Final result template:

```yaml
network:
  ethernets:
    <interface>:
      addresses:
      - <ipaddress>/24
      routes:
      - to: default
        via: <gateway>
  version: 2
```

-> Replace **\<interface>,** **\<ipaddress>** and **\<gateway>** with your data obtained in the previous [Preparations](static-ip-and-custom-dns-servers.md#preparations) section

Final result example:

```yaml
network:
  ethernets:
    eno1:
      addresses:
      - 192.168.1.87/24
      routes:
      - to: default
        via: 192.168.1.1
  version: 2
```
{% endtab %}

{% tab title="Case 2: Dynamic IP setted (DHCP) (default)" %}
* Replace the content to match this template adding `dhcp4-overrides` section with `use-dns: false` flag:

```yaml
            dhcp4-overrides:
                use-dns: false
```

Template:

```yaml
network:
    ethernets:
        <interface>:
            dhcp4: true
            dhcp4-overrides:
                use-dns: false
    version: 2
```

-> Replace **\<interface>** with your data obtained in the previous [Preparations](static-ip-and-custom-dns-servers.md#preparations) section

Example:

```yaml
network:
    ethernets:
        eno1:
            dhcp4: true
            dhcp4-overrides:
                use-dns: false
    version: 2
```
{% endtab %}
{% endtabs %}

* Apply the configuration temporarily

```bash
sudo netplan try
```

{% hint style="info" %}
If prompts show you:

```
WARNING:root:Cannot call Open vSwitch: ovsdb-server.service is not running.
Do you want to keep these settings?

Press ENTER before the timeout to accept the new configuration

Changes will revert in 116 seconds
```

-> This means that changes were successfully applied without breaking the connection, then **press `ENTER`** to accept and apply the new configuration (**`Configuration accepted.`**), if not, don't worry, changes will be reverted after 120 seconds and you will connect to the MiniBolt again.

Expected output:

```
Configuration accepted.
```
{% endhint %}

* Check the correct configuration previously set

```bash
sudo netplan get
```

* Check if the DNS status of `systemd-networkd` is `offline`

```bash
sudo netplan status --all | grep Online
```

Expected output:

```
Online state: offline
```

* Create a `resolved.conf` drop-in directory

```bash
sudo mkdir -p /etc/systemd/resolved.conf.d
```

* Create a custom `resolved.conf` file

```bash
sudo nano /etc/systemd/resolved.conf.d/dns.conf
```

* Add the next content. Save and exit

```
[Resolve]
DNS=1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com
DNSSEC=allow-downgrade
DNSOverTLS=yes
```

{% hint style="info" %}
For this example, we have used Cloudflare DNS, but you can choose another DNS server:

```
Quad9: 9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net
MullvadDNS: 194.242.2.2#dns.mullvad.net
DNS.SB: 185.222.222.222#dot.sb 45.11.45.11#dot.sb
BlahDNS: 46.250.226.242#dot-sg.blahdns.com 78.46.244.143#dot-de.blahdns.com
```

-> Replace `1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com` for your selection

Example:

```
[Resolve]
DNS=9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net
DNSSEC=allow-downgrade
DNSOverTLS=yes
```
{% endhint %}

* Clear the DNS cache

```bash
resolvectl flush-caches
```

* Restart the `systemd-resolved` and `systemd-networkd` to apply changes

{% code overflow="wrap" %}
```bash
sudo systemctl restart systemd-resolved && sudo systemctl restart systemd-networkd
```
{% endcode %}

* Check the correct application of the DoT and DNSSEC with `resolvectl`, checking `+DNSOverTLS` and `DNSSEC=allow-downgrade`

```bash
resolvectl status
```

Example of expected output:

<pre><code>Global
         Protocols: +LLMNR +mDNS <a data-footnote-ref href="#user-content-fn-3">+DNSOverTLS</a> <a data-footnote-ref href="#user-content-fn-3">DNSSEC=allow-downgrade</a>/supported
  resolv.conf mode: stub
Current DNS Server: 1.1.1.1#cloudflare-dns.com
        DNS Servers 1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com

Link 2 (ens33)
Current Scopes: <a data-footnote-ref href="#user-content-fn-4">LLMNR/IPv4 LLMNR/IPv6</a>
     Protocols: -DefaultRoute +LLMNR -mDNS +DNSOverTLS DNSSEC=allow-downgrade/supported
</code></pre>

#### Validation

* Ensure `systemd-resolve` is listening on the default 53 port

```bash
sudo ss -tulpn | grep systemd-resolve
```

Expected output:

```
udp   UNCONN 0      0           127.0.0.53%lo:53        0.0.0.0:*    users:(("systemd-resolve",pid=845,fd=13))
tcp   LISTEN 0      4096        127.0.0.53%lo:53        0.0.0.0:*    users:(("systemd-resolve",pid=845,fd=14))
```

* Monitor if there is traffic on port 853 (DoT default port). Keep this command running in the terminal

```bash
sudo tcpdump -i any port 853 -n
```

* [Start your SSH program](../../index-1/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`
* Make a DNS query using, in this example  `minibolt.info` domain

```bash
resolvectl query minibolt.info
```

Expected output:

<pre><code>minibolt.info: 2a06:98c1:3120::5               -- link: ens33
               2a06:98c1:3121::5               -- link: ens33
               188.114.96.5                    -- link: ens33
               188.114.97.5                    -- link: ens33

-- Information acquired via protocol DNS in 421.0ms.
-- <a data-footnote-ref href="#user-content-fn-3">Data is authenticated: yes</a>; <a data-footnote-ref href="#user-content-fn-5">Data was acquired via local or encrypted transport: yes</a>
<strong>-- Data from: network
</strong></code></pre>

{% hint style="info" %}
&#x20;-> In this example, we can see that `minibolt.info` it has `DNSSEC` enabled, and the response was verified directly on the MiniBolt node (DNS client).

The DNS server usually does this before forwarding the request to the DNS client, but we do the verification again on our node so as not to trust the DNS server.

The DNSSEC response depends if the domain has the DNSSEC enabled or not, if the domain we are querying does not have DNSSEC enabled, the request will fail, so we allow resolution without verification with `allow-downgrade`.

The expected output in this case for `minibolt.info`:

```
Data is authenticated: yes
```

-> With the following output, we can verify that the request to the DNS servers for `minibolt.info` was successfully encrypted using `DoT`:

```
Data was acquired via local or encrypted transport
```
{% endhint %}

Example of expected output in the previous terminal with the `tcpdump` command:

```
08:58:01.946478 eno1  Out IP 192.168.1.71.50996 > 1.0.0.1.853: Flags [S], seq 479943231, win 64240, options [mss 1460,sackOK,TS val 1530088766 ecr 0,nop,wscale 7,tfo  cookiereq,nop,nop], length 0
08:58:01.958561 eno1  In  IP 1.0.0.1.853 > 192.168.1.71.50996: Flags [S.], seq 2035886934, ack 479943232, win 65535, options [mss 1452,sackOK,TS val 2664345012 ecr 1530088766,nop,wscale 13], length 0
08:58:01.958623 eno1  Out IP 192.168.1.71.50996 > 1.0.0.1.853: Flags [.], ack 1, win 502, options [nop,nop,TS val 1530088778 ecr 2664345012], length 0
08:58:01.958725 eno1  Out IP 192.168.1.71.50996 > 1.0.0.1.853: Flags [P.], seq 1:652, ack 1, win 502, options [nop,nop,TS val 1530088778 ecr 2664345012], length 651
08:58:01.971682 eno1  In  IP 1.0.0.1.853 > 192.168.1.71.50996: Flags [.], ack 652, win 8, options [nop,nop,TS val 2664345025 ecr 1530088778], length 0
08:58:01.971725 eno1  In  IP 1.0.0.1.853 > 192.168.1.71.50996: Flags [P.], seq 1:220, ack 652, win 8, options [nop,nop,TS val 2664345025 ecr 1530088778], length 219
08:58:01.971741 eno1  Out IP 192.168.1.71.50996 > 1.0.0.1.853: Flags [.], ack 220, win 501, options [nop,nop,TS val 1530088792 ecr 2664345025], length 0
08:58:01.972038 eno1  Out IP 192.168.1.71.50996 > 1.0.0.1.853: Flags [P.], seq 652:658, ack 220, win 501, options [nop,nop,TS val 1530088792 ecr 2664345025], length 6
08:58:01.972181 eno1  Out IP 192.168.1.71.50996 > 1.0.0.1.853: Flags [P.], seq 658:732, ack 220, win 501, options [nop,nop,TS val 1530088792 ecr 2664345025], length 74
08:58:01.972305 eno1  Out IP 192.168.1.71.50996 > 1.0.0.1.853: Flags [P.], seq 732:756, ack 220, win 501, options [nop,nop,TS val 1530088792 ecr 2664345025], length 24
08:58:01.972326 eno1  Out IP 192.168.1.71.50996 > 1.0.0.1.853: Flags [P.], seq 756:846, ack 220, win 501, options [nop,nop,TS val 1530088792 ecr 2664345025], length 90
08:58:01.972355 eno1  Out IP 192.168.1.71.50996 > 1.0.0.1.853: Flags [P.], seq 846:870, ack 220, win 501, options [nop,nop,TS val 1530088792 ecr 2664345025], length 24
08:58:01.972372 eno1  Out IP 192.168.1.71.50996 > 1.0.0.1.853: Flags [P.], seq 870:960, ack 220, win 501, options [nop,nop,TS val 1530088792 ecr 2664345025], length 90
```

{% hint style="success" %}
Now you have DoT enabled on your MiniBolt node to encrypt the DNS queries and DNSSEC to verify them
{% endhint %}

#### Option 2: Use DoH with Cloudflared proxy DNS

#### Requirements

* [Cloudflared](../networking/cloudflare-tunnel.md)

#### Preparations

To avoid DNS servers would be automatically obtained from the DHCP server (router) for the interface, and overriding the `cloudflare-proxy-dns` configuration, we need to override the network configuration with `netplan` to manually configure the DNS server.

* With user `admin` , edit the content of the `.yaml` file

```bash
sudo nano /etc/netplan/50-cloud-init.yaml
```

**-> 2 cases**, depending on whether **you configured a static IP** following the previous sections **or not**:

{% tabs %}
{% tab title="Case 1: Static IP setted" %}
* Replace the content to match the next template by deleting the "nameservers" configuration (the next):

```yaml
      nameservers:
        addresses:
        - <nameserver1>
        - <nameserver2>
        search: []
```

Template:

```yaml
network:
  ethernets:
    <interface>:
      addresses:
      - <ipaddress>/24
      routes:
      - to: default
        via: <gateway>
  version: 2
```

Example:

```yaml
network:
  ethernets:
    eno1:
      addresses:
      - 192.168.1.87/24
      routes:
      - to: default
        via: 192.168.1.1
  version: 2
```

-> Replace **\<interface>,** **\<ipaddress>** and **\<gateway>** with your data obtained in the [Preparations](static-ip-and-custom-dns-servers.md#preparations) section before
{% endtab %}

{% tab title="Case 2: Dynamic IP setted (DHCP) (default)" %}
* Replace the content to match this template adding `dhcp4-overrides` section with `use-dns: false` flag:

```yaml
network:
    ethernets:
        <interface>:
            dhcp4: true
            dhcp4-overrides:
                use-dns: false
    version: 2
```
{% endtab %}
{% endtabs %}

* Apply the configuration temporarily

```bash
sudo netplan try
```

{% hint style="info" %}
If prompts show you:

```
WARNING:root:Cannot call Open vSwitch: ovsdb-server.service is not running.
Do you want to keep these settings?

Press ENTER before the timeout to accept the new configuration
```

-> This means that changes were successfully applied without breaking the connection, then **press `ENTER`** to accept and apply the new configuration (**`Configuration accepted.`**), if not, don't worry, changes will be reverted after 120 seconds and you will connect to the MiniBolt again.
{% endhint %}

* Check if the DNS status of `systemd-networkd` is `offline`

```bash
sudo netplan status --all | grep Online
```

Expected output:

```
Online state: offline
```

* Check the correct configuration previously set

```bash
sudo netplan get
```

* Follow only the [Installation section](../networking/cloudflare-tunnel.md#installation) of the Cloudflare tunnel guide, and come back to continue with the next steps
* Stop and disable `systemd-resolved` service to avoid conflicts

```bash
sudo systemctl stop systemd-resolved && sudo systemctl disable systemd-resolved
```

* Backup the existing `resolv.conf` file

```bash
sudo cp /etc/resolv.conf /etc/resolv.conf.backup
```

* Delete the `resolv.conf` symbolic link associated with the `systemd-resolved` delegation

```bash
sudo rm -f /etc/resolv.conf
```

* Create a new one `resolv.conf` file

```bash
sudo nano /etc/resolv.conf
```

* Paste the next content. Save and exit

```
nameserver 127.0.0.1
```

#### Create the systemd service

The system needs to run the `cloudflared-proxy-dns` daemon automatically in the background. We use `systemd`, a daemon that controls the startup process using configuration files

* Create the systemd configuration

```bash
sudo nano /etc/systemd/system/cloudflared-proxy-dns.service
```

* Enter the complete next configuration. Save and exit

<pre><code># MiniBolt: systemd unit for cloudflared-proxy-dns
# /etc/systemd/system/cloudflared-proxy-dns.service
<strong>
</strong><strong>[Unit]
</strong>Description=DNS over HTTPS (DoH) proxy client
Wants=network-online.target nss-lookup.target
Before=nss-lookup.target

[Service]
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
DynamicUser=yes
ExecStart=/usr/local/bin/cloudflared proxy-dns

[Install]
WantedBy=multi-user.target
</code></pre>

{% hint style="info" %}
For this example, we have configured the default [Cloudflare DoH name servers](https://www.cloudflare.com/learning/dns/what-is-1.1.1.1/) (https://1.1.1.1/dns-query,https://1.0.0.1/dns-query) but you could put other privacy-focused DNS like:

* [Quad9](https://quad9.net/): https://dns.quad9.net/dns-query
* [MullvadDNS](https://mullvad.net/en/help/dns-over-https-and-dns-over-tls): https://dns.mullvad.net/dns-query
* [DNS.SB](https://dns.sb/):&#x20;
  * https://dns.sb/dns-query
  * https://doh.dns.sb/dns-query
  * https://doh.sb/dns-query
* [BlahDNS](https://blahdns.com/):&#x20;
  * https://doh-sg.blahdns.com/dns-query
  * https://doh-de.blahdns.com/dns-query

-> Add to the `ExecStart=/usr/local/bin/cloudflared proxy-dns` line, the `--upstream` parameter + the DoH URL related to the DNS server of your selection:

Example for Quad9:

```
ExecStart=/usr/local/bin/cloudflared proxy-dns --upstream "https://dns.quad9.net/dns-query"
```

Example for BlahDNS:

```
ExecStart=/usr/local/bin/cloudflared proxy-dns --upstream "https://doh-sg.blahdns.com/dns-query" --upstream "https://doh-de.blahdns.com/dns-query"
```
{% endhint %}

* Enable autoboot **(required)**

```bash
sudo systemctl enable cloudflared-proxy-dns
```

* Prepare `cloudflared-proxy-dns` monitoring by the systemd journal and checking the logging output. You can exit monitoring at any time with Ctrl-C

```bash
journalctl -fu cloudflared-proxy-dns
```

{% hint style="info" %}
Keep **this terminal open,** you'll need to come back here on the next step to monitor the logs
{% endhint %}

#### Run

To keep an eye on the software movements, [start your SSH program](../../index-1/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`

* Start the service

```bash
sudo systemctl start cloudflared-proxy-dns
```

<details>

<summary><strong>Example</strong> of expected output on the first terminal with <code>journalctl -fu cloudflared-proxy-dns</code> ⬇️</summary>

```
Nov 06 22:55:14 minibolt systemd[1]: Started DNS over HTTPS (DoH) proxy client.
Nov 06 22:55:14 minibolt cloudflared[1687]: 2024-11-06T22:55:14Z INF Adding DNS upstream url=https://1.1.1.1/dns-query
Nov 06 22:55:14 minibolt cloudflared[1687]: 2024-11-06T22:55:14Z INF Adding DNS upstream url=https://1.0.0.1/dns-query
Nov 06 22:55:14 minibolt cloudflared[1687]: 2024-11-06T22:55:14Z INF Starting DNS over HTTPS proxy server address=dns://localhost:53
Nov 06 22:55:14 minibolt cloudflared[1687]: 2024-11-06T22:55:14Z INF Starting metrics server on 127.0.0.1:40435/metrics
```

</details>

#### Validation

* Ensure `cloudflared proxy-dns` is listening on the default port 53

```bash
sudo ss -tulpn | grep cloudflared | grep 53
```

Expected output:

```
udp   UNCONN 0      0               127.0.0.1:53         0.0.0.0:*    users:(("cloudflared",pid=23882,fd=7))
tcp   LISTEN 0      4096            127.0.0.1:53         0.0.0.0:*    users:(("cloudflared",pid=23882,fd=8))
```

* Monitor if there is traffic on port 443 (DoH port)

```bash
sudo tcpdump -i any port 443 -n
```

Example of expected output:

```
16:52:02.032145 ens33 Out IP 192.168.1.42.34460 > 162.159.36.1.443: Flags [S], seq 330680646, win 64240, options [mss 1460,sackOK,TS val 1651551299 ecr 0,nop,wscale 7], length 0
16:52:02.032266 ens33 Out IP 192.168.1.42.34462 > 162.159.36.1.443: Flags [S], seq 1968356798, win 64240, options [mss 1460,sackOK,TS val 1651551299 ecr 0,nop,wscale 7], length 0
16:52:02.050904 ens33 In  IP 162.159.36.1.443 > 192.168.1.42.34460: Flags [S.], seq 3589147268, ack 330680647, win 65535, options [mss 1460,sackOK,TS val 4255012447 ecr 1651551299,nop,wscale 13], length 0
16:52:02.050904 ens33 In  IP 162.159.36.1.443 > 192.168.1.42.34462: Flags [S.], seq 1269032047, ack 1968356799, win 65535, options [mss 1460,sackOK,TS val 3914800050 ecr 1651551299,nop,wscale 13], length 0
16:52:02.050945 ens33 Out IP 192.168.1.42.34460 > 162.159.36.1.443: Flags [.], ack 1, win 502, options [nop,nop,TS val 1651551318 ecr 4255012447], length 0
16:52:02.051021 ens33 Out IP 192.168.1.42.34462 > 162.159.36.1.443: Flags [.], ack 1, win 502, options [nop,nop,TS val 1651551318 ecr 3914800050], length 0
16:52:02.051318 ens33 Out IP 192.168.1.42.34462 > 162.159.36.1.443: Flags [P.], seq 1:252, ack 1, win 502, options [nop,nop,TS val 1651551318 ecr 3914800050], length 251
16:52:02.051407 ens33 Out IP 192.168.1.42.34460 > 162.159.36.1.443: Flags [P.], seq 1:252, ack 1, win 502, options [nop,nop,TS val 1651551318 ecr 4255012447], length 251
```

{% hint style="info" %}
If you don't have output, you can force this by resolving a domain name manually with:

```bash
nslookup minibolt.info
```
{% endhint %}

{% hint style="success" %}
Now you have DoH enabled on your MiniBolt node and the DNS queries encrypted
{% endhint %}

## Port reference

| Port | Protocol |    Use    |
| :--: | :------: | :-------: |
|  53  |  TCP/UDP |    DNS    |
|  853 |    UDP   | DNS (DoT) |
|  443 |    TCP   | DNS (DoH) |

[^1]: \<interface>

[^2]: address>

[^3]: Check this

[^4]: Also valid "none"

[^5]: Check this
