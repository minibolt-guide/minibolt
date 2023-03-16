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

In order to write the operating system to the external drive, we will use the [Balena Etcher](https://www.balena.io/etcher/){:target="_blank"} application, download the correct binary accordingly to your OS.

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
* Attach a screen, a keyboard and the Ethernet wire (not the case for Wifi connection) to the PC and start it
* Press the key fastly to enter to BIOS setup or directly to the boot menu to select the pen drive as the boot device (normally F9, Esc, F12, or Supr keys)

   💡 In this step, you might want to take advantage of activating the **"Restore on AC/Power Loss"** utility in the BIOS setup. Normally found in Advanced > **ACPI Configuration**, switching to "Power ON" or Advanced > Power-On Options > **After Power Loss** switching to "On". With this, you can get the PC to start automatically after a power loss, ensuring services are back available in your absence.

## Ubuntu Server installation

Use the UP, Down and ENTER keys of your keyboard to navigate to the options. Follow the next instructions:

1. On the first screen, select the language of your choice (English recommended)

1. If there is an installer update available, select "Update to the new installer", press ENTER and wait

1. Select your keyboard layout and variant (Spanish recommended to Spanish native speakers) and press done

1. Keep selecting "Ubuntu Server" as the base for the installation, down to "done" and press ENTER

1. Select the interface network connection that you choose to use (Ethernet recommended) and take note of your IP obtained automatically through DHCP. Press done

1. Leave the empty next option if you don't want to use an HTTP proxy to access. Press done

1. If you don't want to use an alternative mirror for Ubuntu, leave it empty and press done directly

1. Configure a guided storage layout:
    * Check **"Use an entire disk"**, if you have only one primary unit storage (1+ TB). In this case, ensure that you **uncheck "Set up this disk as an LVM group"** before pressing done.
    * Check **"Custom storage layout"**, if you want to use one **secondary** or multiple disks, e.g. primary storage for the system and other secondary storage for data (blockchain, indexes, etc)(1+ TB). Navigate to the [Store data in a secondary disk](../bonus/system/store-data-secondary-disk.md) bonus guide to get instructions about this

1. Confirm destructive action by selecting the "Continue" option. Press enter

1. Keep selecting **"Skip for now"** when the **"Upgrade to Ubuntu Pro"** section appears you press ENTER on the "done" button

1. The username `"admin"` is reserved for use by the system, to use in the first place, so we are going to create a temporary user which we will delete later. Complete the profile configuration form with the following. ⚠️ IMPORTANT step!

    * > **name:** temp
    * > **user:** temp
    * > **server name:** minibolt
    * > **password:** PASSWORD [A]

💡 If at any point you wish to change your hostname, just enter the `$ hostnamectl set-hostname <new-hostname>` command, being `<new-hostname>` your choice. Verify the change with the `$ hostname` command.

1. Press ENTER to check "Install OpenSSH server" by pressing the ENTER key and down to select the *"Done"** box and press enter again. ⚠️ IMPORTANT step!

1. If you want to preinstall some additional software (not recommended), select them, if not, press "done" directly to jump to the installation next step

1. Wait until the installation finishes and press "Reboot now" when the option appears you

1. When the prompt shows you "Please remove the installation medium, then press ENTER", extract the pen drive of the PC and press ENTER

🥳 Now the PC should reboot and show you the prompt to log in. You can disconnect the keyboard and the screen of the MiniBolt node, and proceed to connect remotely from your regular computer to continue with the installation.

<br /><br />

---

Next: [Remote access >>](remote-access.md)
