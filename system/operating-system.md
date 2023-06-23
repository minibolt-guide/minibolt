---
title: Operating system
nav_order: 20
parent: System
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

# 1.2 Operating system

We configure the PC and install the Linux operating system.

<figure><img src="../.gitbook/assets/operating-system.gif" alt="" width="295"><figcaption></figcaption></figure>

### Which operating system to use?

We use Ubuntu Server LTS (Long Term Support) OS, without a graphical user interface. This provides the best stability for the PC and makes the initial setup a breeze.

[Ubuntu Server](https://ubuntu.com/server/docs) is based on the [Debian](https://www.debian.org/) Linux distribution, which is available for most hardware platforms. To make this guide as universal as possible, it uses only standard Debian commands. As a result, it should work smoothly with a personal computer while still being compatible with most other hardware platforms running Debian.

### Balena Etcher and Ubuntu Server

To flash the operating system **.iso** to the pen drive, we will use the [Balena Etcher](https://www.balena.io/etcher/) application. Go to the website and download the correct binary accordingly to your OS.

* Direct download Ubuntu Server LTS doing click [here](https://releases.ubuntu.com/22.04.2/ubuntu-22.04.2-live-server-amd64.iso) or going to the official Ubuntu Server [website](https://ubuntu.com/download/server) and clicking on the **"Download Ubuntu Server xx.xx LTS"** button
* **Start** the **Balena Etcher**
* Select **"Flash from file"** --> Select Ubuntu Server LTS **.iso** file previously downloaded

### Write the operating system to the pen drive

* Connect the pen drive to your regular computer
* Click on **"Select target"**
* Select your pen drive unit
* Click on **"Flash!**"

Balena Etcher will now flash the operating system to your drive and validate it.

{% hint style="success" %}
It should display a **"Flash Complete!"** message after
{% endhint %}

### Start your PC

* **Safely eject** the pen drive from your regular computer
* **Connect to your selected PC** for the MiniBolt node
* **Attach a screen**, a **keyboard,** and the **Ethernet** wire of the Internet (not the case for Wifi connection) to the **PC** and start it
*   Press the key fastly to **enter to BIOS setup** or directly to the **boot menu** to select the **pen drive as the 1st boot priority device** (normally, F9, Esc, F12, or Supr keys)

    💡 In this step, you might want to take advantage of activating the **"Restore on AC"** or similar in the BIOS setup. Normally found in **Advanced** -> **ACPI Configuration**, switching to **"Power ON"** or similar. With this, you can get the PC to start automatically after a power loss, ensuring services are back available in your absence.
* If you configured boot options in BIOS, **save changes and exit**. This start automatically with the Ubuntu Server guided installation. You will keep selecting **"Try or Install Ubuntu Server"** and press **enter**, or wait 20 seconds for it to start automatically.

### Ubuntu Server installation

Use the **UP**, **Down,** and **ENTER** keys of your keyboard to navigate to the options. Follow the next instructions:

**1.** On the first screen, select the language of your choice **(English recommended)**

**2.** If there is an installer update available, select **"Update to the new installer"**, press **enter,** and wait

**3.** Select your keyboard layout and variant **(Spanish recommended to Spanish native speakers)** and press \[**done]**

**4.** Keep selecting **"Ubuntu Server"** as the base for the installation, down to **done,** and press **enter**

**5.** Select the interface network connection that you choose to use **(Ethernet recommended)** and **take note of your IP** obtained automatically through DHCP. (Normally 192.168.x.xx). Press \[**done]**

{% hint style="info" %}
The router reserves the IP address of the device for a time, but If the device goes out soo time, the next time that the device starts, the router could assign a different IP and you could lose access to your node. To avoid this, you need to set a static IP to your node. Go to the [Set Static IP address](operating-system.md#set-a-static-ip-address-and-custom-dns-nameservers-optional) optional section to get more instructions to do this.

\
🚨 <mark style="color:red;">Be careful by setting this!</mark> If you change the router could be **the new router doesn't work in the same IP address range as the old router**, the MiniBolt won't be registered and will be completely out of the connection. To avoid this, follow the [Set the DCHP (automatic) configuration](operating-system.md#set-the-automatic-dhcp-mode-configuration) section to ensure that the DHCP server auto assigns an IP to the node in the range you are working on, and if you want after the change of the router, reconfigure the static IP address again following the [Option 2](operating-system.md#option-2-after-ubuntu-server-installation-by-command-line) section.
{% endhint %}

**6.** Leave the empty next option if you don't want to use an HTTP proxy to access it. Press \[**done]**

**7.** If you don't want to use an alternative mirror for Ubuntu, leave it empty and press \[**done]** directly

**8.** Configure a **guided storage layout**, with 2 options:

> **8.1.** Check **"Use an entire disk"**, if you have **only one primary unit storage (1+ TB)**. In this case, ensure that you **uncheck "Set up this disk as an LVM group"** before select \[**done]** and press **enter**. Then, continue with **step 9**.

> **8.2.** Check **"Custom storage layout"**, if you want to use one **secondary** disk, e.g. primary for the system and secondary disk for data (blockchain, indexes, etc)(1+ TB). For this case, go to --> [Store data in a secondary disk](../bonus/system/store-data-secondary-disk.md) bonus guide, to get instructions about how to follow, and then continue with **step 10**.

**9.** Confirm destructive action by selecting the \[**Continue]** option. Press **enter**

{% hint style="danger" %}
**This will delete all existing data on the disks, including existing partitions!**
{% endhint %}

**10.** Keep selecting **"Skip for now",** when the **"Upgrade to Ubuntu Pro"** section appears you press **enter** on the **done** button

**11.** The username **`"admin"`** is reserved for use by the system, to use in the first place, so we are going to create a **temporary user** which we will **delete later**. Complete the profile configuration form with the following.

{% hint style="danger" %}
This is an IMPORTANT step!
{% endhint %}

{% code fullWidth="false" %}
```
> name: temp
> user: temp
> server name: minibolt
> password: PASSWORD [A]
```
{% endcode %}

**12.** Press **enter** to check **"Install OpenSSH server"** by pressing the **enter** key, and down to select the \[**Done]** box and press **enter** again

{% hint style="danger" %}
This is an IMPORTANT step!
{% endhint %}

**13.** If you want to preinstall some additional software **(not recommended)**, select them, if not, press \[**done]** directly to jump to the next step.

**14.** Now all before configurations will be applied and the system installed. This would be a few minutes depending on the hardware used. You can show extended logs by pressing **\[View full log]** if you want.

⌛ Wait until the installation finishes, when it happens, \[**Reboot now]** will appear. Select it and press **enter**.

**15.** When the prompt shows you **"Please remove the installation medium, then press ENTER"**, extract the pen drive of the PC and press **enter** finally.

{% hint style="success" %}
🥳 Now the PC should reboot and show you the prompt to log in. You can disconnect the keyboard and the screen of the MiniBolt node, and proceed to connect remotely from your regular computer to continue with the installation
{% endhint %}

![](../resources/demo-install-os.gif)

{% hint style="info" %}
The GIF before is only a recreation of a scenario made with a virtual machine, **VBOX\_HARDDISK\_**... is the **example name** for the name of the disk. In your case, this probably will not match exactly
{% endhint %}

### Set a static IP address and custom DNS nameservers <mark style="color:red;">(optional)</mark>

#### Option 1: At the beginning, during the Ubuntu Server installation GUI

When you arrive at **step 15** of the [Ubuntu Server guided installation](operating-system.md#ubuntu-server-installation), you can want to choose set a static IP address and customize the DNS name server/s.&#x20;

Wait for the router's DHCP server to assign the IP address to your MiniBolt node to find out what IP range the node is in, you will be able to assign the same or a different IP in the next step.

<figure><img src="../.gitbook/assets/static-ip-dns-gif.gif" alt=""><figcaption></figcaption></figure>

> > **Subnet:** your router subnet, e.g 192.168.1.0/24
>
> > **Address**: your assigned local IP address, eg. 192.168.1.29
>
> > **Gateway:** you router IP, eg. 192.168.1.1
>
> > **Name servers:** DNS servers choosen, eg. same of gateway (192.168.1.1,192.168.1.1) (your ISP DNS) or Cloudflare DNS server (1.1.1.1,1.0.0.1) <- (recommended)
>
> > **Search domains:** \<left blank>

{% hint style="info" %}
This is **only** an **example** if your local network IP range is `192.168.1.0-255,` because for this case, the router assigned to the device the IP address **192.168.1.29**, but could be **192.168.0.29** (`192.168.0.0-255)`, then you will need to set this instead:

> **Subnet:** 192.168.0.0/24

> **Gateway:** 192.168.0.1
{% endhint %}

{% hint style="danger" %}
**Be careful by setting this!** If you change the router, could be the new router doesn't work in the same IP address range as the old router, the device won't be registered on the local network and will be completely out of the connection.

💡 To avoid this, you will need to **enable the "Automatic (DHCP)" mode again before changing the router**, following the [Set the DCHP (automatic) configuration](operating-system.md#set-the-automatic-dhcp-mode-configuration-by-command-line) to ensure that the DHCP server auto assigns an IP to the node in the range you are working on, and if you want, after router change, reconfigure the static IP address again following the [Option 2](operating-system.md#option-2-after-ubuntu-server-installation-by-command-line).

If you don't do this, you will have to attach the monitor screen or television and keyboard again to fix this.
{% endhint %}

{% hint style="info" %}
In this step, you can set DNS name servers too, for this example, we have configured [Cloudflare DNS name servers](https://www.cloudflare.com/learning/dns/what-is-1.1.1.1/) (1.1.1.1/1.0.0.1) but you could set [others](https://www.quad9.net/service/service-addresses-and-features)
{% endhint %}

#### Option 2: After Ubuntu Server installation (by command line)

After having done the [1.3 Remote access](remote-access.md) section, you could want set a static IP address to your MiniBolt

* Check your current data network interface by doing

```bash
$ ip address
```

Check your own configuration, the next output is **only** an **example** of a concrete case, but in your case could be different:

<pre><code>1: lo: &#x3C;LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: <a data-footnote-ref href="#user-content-fn-1">eno1</a>: &#x3C;BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 40:a8:f0:ac:6a:37 brd ff:ff:ff:ff:ff:ff
    altname enp0s25
    inet <a data-footnote-ref href="#user-content-fn-2">192.168.1.147</a>/24 metric 100 brd 192.168.1.255 scope global dynamic eno1
       valid_lft 76855sec preferred_lft 76855sec
    inet6 fe80::42a8:f0ff:feac:6a37/64 scope link
       valid_lft forever preferred_lft forever
</code></pre>

Definitions in the case of before:

> > ```
> > <interface> = eno1
> > ```
>
> > ```
> > <ipaddress> = 192.168.1.147
> > ```
>
> > ```
> > <gateway> = 192.168.1.1 (this case) -> for case 192.168.0.147 choose 192.168.0.1
> > ```

{% hint style="info" %}
Take note of your case data, you will need it later
{% endhint %}

* &#x20;Check the current DNS server setted

```bash
$ resolvectl status
```

**Example** of expected output:

```
Global
       Protocols: -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
resolv.conf mode: stub

Link 2 (eno1)
    Current Scopes: DNS
         Protocols: +DefaultRoute +LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
Current DNS Server: 192.168.1.1
       DNS Servers: 192.168.1.1
        DNS Domain: home
```

In the case of before:

> > ```
> > <nameserver1> = 192.168.1.1 (your router IP)
> > ```
>
> > ```
> > <nameserver2> = (secondary DNS server not setted in this case)
> > ```

* Edit the content of the next file

<pre class="language-bash"><code class="lang-bash"><strong>$ sudo nano /etc/netplan/00-installer-config.yaml
</strong></code></pre>

* Replace the content to match this template

```
# This is the network config written by 'subiquity'
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
Replace **\<interface>**, **\<ipaddress>**, **\<nameserver1>**, **\<nameserver2>** (optional but recommended)**,** and **\<gateway>** to your own data. \
\
You can choose the DNS server (**\<nameserver1> +** **\<nameserver2>**) whatever you want, including the default one set in the DNS server of your router (normally of the ISP), in that case, you should type the **\<gateway>** address in **\<nameserver1>** and the same in **\<nameserver2>**.  For this example, we have configured [Cloudflare DNS name servers](https://www.cloudflare.com/learning/dns/what-is-1.1.1.1/) (1.1.1.1/1.0.0.1) <-- (recommended), but you could set [others](https://www.quad9.net/service/service-addresses-and-features)
{% endhint %}

<details>

<summary>Example ⬇️</summary>

```
# This is the network config written by 'subiquity'
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

* Finally, type this command to apply the changes

```bash
$ sudo netplan apply
```

{% hint style="info" %}
If you chose a different IP address than the router assigned you, this step could break the current SSH connection, reconnect using the chosen IP address
{% endhint %}

#### **Check changes are applied:**

* For the IP address change, type the next command

```bash
$ ip address
```

{% hint style="info" %}
The output of this command **may not change**, depending on whether you chose the same IP that the router originally assigned you at first, or whether you chose to change to another
{% endhint %}

* For the DNS servers change, type the next command

```bash
$ resolvectl status
```

<details>

<summary>Example ⬇️</summary>

```
Global
       Protocols: -LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
resolv.conf mode: stub

Link 2 (eno1)
    Current Scopes: DNS
         Protocols: +DefaultRoute +LLMNR -mDNS -DNSOverTLS DNSSEC=no/unsupported
Current DNS Server: 1.1.1.1
       DNS Servers: 1.1.1.1 1.0.0.1
[...]
```

</details>

### Set the A**utomatic (DHCP) mode** configuration (by command line)

If you go to change the router you could want to enable or check if you have enabled the a**utomatic (DHCP) mode** configuration to avoid problems

* Edit the content of the next file

<pre class="language-bash"><code class="lang-bash"><strong>$ sudo nano /etc/netplan/00-installer-config.yaml
</strong></code></pre>

* Replace the content to match this template

<pre><code><strong># This is the network config written by 'subiquity'
</strong>network:
  ethernets:
    &#x3C;interface>:
      dhcp4: true
  version: 2
</code></pre>

* Finally, type this command to apply the changes

```bash
$ sudo netplan apply
```

{% hint style="info" %}
#### Check changes are applied following [the same step as before](operating-system.md#check-changes-are-applied-following-the-same-step-before)
{% endhint %}

[^1]: \<interface>

[^2]: \<ipaddress>
