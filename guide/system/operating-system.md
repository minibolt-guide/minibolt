---
layout: default
title: Operating system
nav_order: 20
parent: System
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->

{% include include_metatags.md %}

# Operating system

{: .no_toc }

---

We configure the PC and install the Linux operating system.

Status: Tested MiniBolt
{: .label .label-blue }

---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Which operating system to use?

We use Ubuntu Server LTS (Long Term Support) OS, without a graphical user interface.
This provides the best stability for PC and makes the initial setup a breeze.

Ubuntu Server is based on the [Debian](https://www.debian.org/){:target="_blank"} Linux distribution, which is available for most hardware platforms.
To make this guide as universal as possible, it uses only standard Debian commands.
As a result, it should work smoothly with a personal computer while still being compatible with most other hardware platforms running Debian.

## Get Ubuntu Server

In order to write the operating system to the external drive, we will use the [Balena Etcher](https://www.balena.io/etcher/){:target="_blank"} application, download the correct binarie accordly to your OS.

* Download Ubuntu Server LTS doing click [here](https://softlibre.unizar.es/ubuntu/releases/22.04.1/ubuntu-22.04.1-live-server-amd64.iso)
* Start the Balena Etcher
* Select "Flash from file" > Select Ubuntu Server LTS .iso file previously downloaded

## Write the operating system to the pen drive

* Connect pen drive to your regular computer
* Click on "Select target"
* Select your pen drive unit
* Click on "Flash!"

Balena Etcher will now flash the operating system to your drive and validate it. It should display a "Flash Complete!" message after.

## Start your PC

* Safely eject the pen drive from your regular computer
* Connect it to your selected PC to the MiniBolt node
* Attach a screen, a keyboard and the Ethernet wire (not case for Wifi connection) to the PC and start it
* Press the key fastly to enter to BIOS setup or directly to the boot menu to select the pen drive as the boot device (normally F9, Esc, F12, or Supr keys)

## Ubuntu Server installation

Use your keyboard to navigate for the options. Use UP, Down and ENTER keys to select your lenguage (English recommended). Follow the next instructions:

1. Select your keyboard layout (Spanish recommended to Spanish native speakers) and press done

1. Choose "Ubuntu Server" as the base for the installation

1. Select interface network connection that you choose to use (Ethernet or Wifi), take note of your IP obtained automatically through DHCP. Press done

1. Leave empty next option if you don't want to use an HTTP proxy to access. Press done

1. If you don't want to use an alternative mirror for Ubuntu, leave empty and press done directly

1. Configure a guided storage layout, or create a custom one, you will need to mount a filesystem at primary unit storage `("/")` and select a boot disk

    💡 If you want to use a secondary unit storage to storage data (blockchain, indexes, etc), you have to:

    * > Format the secondary unit storage as Ext4 filesystem type and mount `"/data"` directory on it. Press done

    🚨 In this case, when you are log in with the `"admin"` user, remember to assign the owner of the `/data` directory to the `"admin"` user, in the step [data directory](https://twofaktor.github.io/minibolt/guide/system/configuration.html#data-directory), discarding the creating of the `"/data"` folder already created in the before step.

1. Confirm destructive action by selecting the "Continue" option

1. Fill the profile setup form with the follows ⚠️ IMPORTANT step!

    * > **name:** temp
    * > **user:** temp
    * > **server name:** minibolt
    * > **password:** PASSWORD [A]

1. Check "Install OpenSSH server" by pressing the ENTER key and down to select "Done" box and press ENTER again. ⚠️ IMPORTANT step!

1. If you want to preinstall some additional software (not recommended), select them, if not, press "done" directly to jump to the installation next step

1. Wait until installation finishes and press "Reboot now" when the option appears you

1. When the prompt shows you "Please remove the installation medium, then press ENTER", extract the pen drive of the PC and press ENTER

🥳 Now the PC should reboot and show you the prompt to log in. You can disconnect the keyboard and the screen of the MiniBolt node, and proceed to connect remotely from your regular computer to continue with the installation.

<br /><br />

---

Next: [Remote access >>](remote-access.md)
