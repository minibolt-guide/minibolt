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

# 1.2 Operating system

We configure the PC and install the Ubuntu Server operating system.

<figure><img src="../.gitbook/assets/operating-system.gif" alt="" width="295"><figcaption></figcaption></figure>

## Which operating system to use?

We use Ubuntu Server LTS (Long Term Support) OS, without a graphical user interface. This provides the best stability for the PC and makes the initial setup a breeze.

[Ubuntu Server](https://ubuntu.com/server/docs) is based on the [Debian](https://www.debian.org/) Linux distribution, which is available for most hardware platforms. To make this guide as universal as possible, it uses only standard Debian commands. As a result, it should work smoothly with a personal computer while still being compatible with most other hardware platforms running Debian.

## Balena Etcher and Ubuntu Server

To flash the operating system **.iso** to the pen drive, we will use the [Balena Etcher](https://www.balena.io/etcher/) application

* Go to the website and [download](https://etcher.balena.io/#download-etcher) the correct binary according to your OS
* Direct download Ubuntu Server **22.04.4** LTS by clicking [here](https://releases.ubuntu.com/jammy/ubuntu-22.04.4-live-server-amd64.iso)

{% hint style="warning" %}
MiniBolt has currently been tested using **Ubuntu Server 22.04.4 LTS (Jammy Jellyfish)**, it has not been tested on other distributions or versions and there is no guarantee that it will work well on them
{% endhint %}

* **Start** the **Balena Etcher**
* Select **"Flash from file"** -> Select Ubuntu Server LTS **.iso** file previously downloaded

## Write the operating system to the pen drive

* Connect the pen drive to your regular computer
* Click on **"Select target"**
* Select your pen drive unit
* Click on **"Flash!**"

Balena Etcher will now flash the operating system to your drive and validate it.

{% hint style="success" %}
It should display a **"Flash Complete!"** message after
{% endhint %}

## Start your PC

* **Safely eject** the pen drive from your regular computer
* **Connect to your selected PC** for the MiniBolt node
* **Attach a screen**, a **keyboard,** and the **Ethernet** wire of the Internet (not the case for Wi-Fi connection) to the **PC** and start it
* Press the key quickly to **enter to BIOS setup** or directly to the **boot menu** to select the **pen drive as the 1st boot priority device** (normally, F9, Esc, F12, or Supr keys)

{% hint style="info" %}
&#x20;In this step, you might want to take advantage of activating the **Restore on AC** / **After power failure** or similar in the BIOS setup. Normally found in **Advanced** -> **Power** / **ACPI Configuration**, switching to **Last State** / **Memory** or similar (System power on depends on the status before AC lost) or **Power ON / Full on** or similar (Always power on the system when AC back) depends on your preference. With this, you can get the PC to start automatically after a power loss, ensuring services are back available in your absence
{% endhint %}

* If you configured boot options in BIOS, **save changes and exit**. This starts automatically with the Ubuntu Server guided installation. You will keep selecting \[**Try or Install Ubuntu Server]** and press **enter**, or wait 20 seconds for it to start automatically

## Ubuntu Server installation

Use the **UP**, **Down,** and **ENTER** keys of your keyboard to navigate to the options. Follow the next instructions:

**1.** On the first screen, select the language of your choice **(English recommended)**

**2.** If there is an installer update available, select **"Update to the new installer"**, press **enter,** and wait

**3.** Select your keyboard layout and variant **(Spanish recommended to Spanish native speakers)** and press \[**done]**

**4.** Keep selecting **"Ubuntu Server"** as the base for the installation, down to \[**done],** and press **enter**

**5.** Select the interface network connection that you choose to use **(Ethernet recommended)** and **take note of your IP** obtained automatically through DHCP. (Normally 192.168.x.xx). Press \[**done]**

{% hint style="info" %}
The router reserves the IP address of the device for a time after going out, but If the device goes out some time, the next time that the device starts, the router could assign a different IP and you could lose access to your node. To avoid this, you need to set a static IP to your node. Go to the [Static IP & custom DNS servers](../bonus-guides/system/static-ip-and-custom-dns-servers.md) bonus guide to get more instructions to do this.

\
🚨 <mark style="color:red;">Be careful by setting this!</mark> If you change the router could be **the new router doesn't work in the same IP address range as the old router**, the MiniBolt won't be registered and will be completely out of the connection. To avoid this, follow the [Set the DCHP (automatic) configuration](../bonus-guides/system/static-ip-and-custom-dns-servers.md#set-the-automatic-dhcp-mode-configuration-by-command-line) section of the bonus guide to ensure that the DHCP server auto assigns an IP to the node in the range you are working on, and if you want after the change of the router, reconfigure the static IP address again following the [Option 2](../bonus-guides/system/static-ip-and-custom-dns-servers.md#option-2-after-ubuntu-server-installation-by-command-line) section.
{% endhint %}

**6.** Leave the empty next option if you don't want to use an HTTP proxy to access it. Press \[**done]**

**7.** If you don't want to use an alternative mirror for Ubuntu, leave it empty and press \[**done]** directly

**8.** Configure a **guided storage layout**, with 2 options:

> **8.1.** Check **"Use an entire disk"**, if you have **only one primary unit storage (1+ TB)**. In this case, ensure that you **uncheck "Set up this disk as an LVM group"** before select \[**done]** and press **enter**. Then, continue with **step 9**.

> **8.2.** Check **"Custom storage layout"**, if you want to use one **secondary** disk, e.g. primary for the system and secondary disk for data (blockchain, indexes, etc)(1+ TB). For this case, go to -> the [Case 1](../bonus/system/store-data-secondary-disk.md#case-1-during-the-ubuntu-server-guided-installation) of [Store data in a secondary disk](../bonus/system/store-data-secondary-disk.md) bonus guide, to get instructions about how to follow, and then continue with **step 10**.

**9.** Confirm destructive action by selecting the \[**Continue]** option. Press **enter**

{% hint style="danger" %}
**This will delete all existing data on the disks, including existing partitions!**
{% endhint %}

**10.** Keep selecting \[**Skip for now],** when the \[**Upgrade to Ubuntu Pro]** section appears you press **enter** on the **done** button

**11.** The username **`admin`** is reserved for use by the system, to use in the first place, so we are going to create a **temporary user** called "temp" which we will **delete later**. Complete the profile configuration form with the following.

{% hint style="danger" %}
Very IMPORTANT step!
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
Very IMPORTANT step!
{% endhint %}

**13.** If you want to preinstall some additional software **(not recommended)**, select them, if not, press \[**done]** directly to jump to the next step.

**14.** Now all before configurations will be applied and the system installed. This would be a few minutes depending on the hardware used. You can show extended logs by pressing **\[View full log]** if you want.

⌛ Wait until the installation finishes, when it happens, \[**Reboot now]** will appear. Select it and press **enter**.

**15.** When the prompt shows you **"Please remove the installation medium, then press ENTER"**, extract the pen drive of the PC and press **enter** finally.

{% hint style="success" %}
🥳 Now the PC should reboot and show you the prompt to log in. You can disconnect the keyboard and the screen of the MiniBolt node, and proceed to connect remotely from your regular computer to continue with the installation
{% endhint %}

<figure><img src="../.gitbook/assets/demo-install-os.gif" alt=""><figcaption><p>GIF showing an example of Ubuntu installation using automatic (DHCP)</p></figcaption></figure>

{% hint style="info" %}
The GIF before is only a recreation of a scenario made with a virtual machine, (**VBOX\_HARDDISK\_**...) is the **example name** for the name of the disk. In your case, this probably will not match exactly
{% endhint %}
