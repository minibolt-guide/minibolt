---
layout: default
title: Store data in a secondary disk
parent: + System
grand_parent: Bonus Section
nav_exclude: true
has_toc: false
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->

# Bonus Guide: Store data in a secondary disk

{: .no_toc }

---

If you want to use a different disk to store data (blockchain and others databases) independently of the disk of the system, you can follow these instructions.

Difficulty: Easy
{: .label .label-green }

Status: Not tested MiniBolt
{: .label .label-red }

---

## Table of contents
{: .text-delta }

1. TOC
{:toc}

---

### Steps required

To use a different disk to store data (blockchain and others databases) independently of the disk of the system, there are a few additional steps compared to the default MiniBolt guide.
Below is a summary of the main differences, with detailed guidance in the following sections.

1. [Operating system](../../system/operating-system.md)

    * write the data (blockchain and others databases) in a secondary disk instead of the primary disk

1. [System configuration](../../system/system-configuration.md)

    * attach the secondary disk
    * format the disk
    * mount the disk to `/data`

---

### System configuration

Follow the [System configuration](../../system/configuration.md) section until you reach [Data directory](../../system/configuration.md#data-directory), continuing with the instructions below.

#### Format secondary disk

We will now format the secondary disk.
As a server installation, the Linux native file system Ext4 is the best choice for the secondary hard disk.

* List all block devices with additional information.
  The list shows the devices (e.g. `sda`) and the partitions they contain (e.g. `sda1`).

  ```sh
  $ lsblk -o NAME,MOUNTPOINT,UUID,FSTYPE,SIZE,LABEL,MODEL
  > NAME          MOUNTPOINT UUID                          FSTYPE   SIZE    LABEL  MODEL
  > sda                                                             931.5G         Ext_SSD
  > sda1                     2219-782E                     ext4     931.5G
  ```

* If your disk does not contain any partitions, follow this [How to Create a Disk Partitions in Linux](https://www.tecmint.com/create-disk-partitions-in-linux/){:target="_blank"} guide first.

* Make a note of the partition name of your secondary disk (in this case "sda1").

* Format the partition on the secondary disk with Ext4 (use `[NAME]` from above, e.g. `sda1`)

  🚨 **This will delete all existing data on the secondary disk!**

  ```sh
  $ sudo mkfs.ext4 /dev/[NAME]
  ```

#### Mount secondary disk

The secondary disk is then attached to the file system and becomes available as a regular folder (this is called “mounting”).

* List the block devices once more and copy the new partition's `UUID` into a text editor on your main machine.

  ```sh
  $ lsblk -o NAME,MOUNTPOINT,UUID,FSTYPE,SIZE,LABEL,MODEL
  > NAME        MOUNTPOINT UUID                                 FSTYPE   SIZE LABEL  MODEL
  > sda                                                                931.5G        Ext_SSD
  > └─sda1                 3aab0952-3ed4-4652-b203-d994c4fdff20 ext4   931.5G
  ```

* Edit the `fstab` file and add the following as a new line at the end, replacing `123456` with your own `UUID`.

  ```sh
  $ sudo nano /etc/fstab
  ```

  ```sh
  UUID=123456 /data ext4 defaults 0 2
  ```

  🔍 *more: [complete fstab guide](https://linuxconfig.org/how-fstab-works-introduction-to-the-etc-fstab-file-on-linux){:target="_blank"}*

* Create the data directory as a mount point.
  We also make the directory immutable to prevent data from being written on the system primary disk if the secondary disk is not mounted.

  ```sh
  $ sudo mkdir /data
  $ sudo chown admin:admin /data
  $ sudo chattr +i /data
  ```

* Mount all disks and check the file system.
  Is “/data” listed?

  ```sh
  $ sudo mount -a
  $ df -h /data
  > Filesystem      Size  Used Avail Use% Mounted on
  > /dev/sda1       938G   77M  891G   1% /data
  ```

#### Custom swap size file

The swap file acts as slower memory and is essential for system stability.
MicroSD cards are not very performant and degrade over time under constant read/write activity.
Therefore, we move the swap file to the secondary disk and increase its size as well.

* Install dphys-swapfile

  ```sh
  $ sudo apt install dphys-swapfile
  ```

* Edit the configuration file, add the `CONF_SWAPFILE` line, and comment the entry `CONF_SWAPSIZE` out by placing a `#` in front of it.
  Save and exit.

  ```sh
  $ sudo nano /etc/dphys-swapfile
  ```

  ```sh
  CONF_SWAPFILE=/data/swapfile

  # comment or delete the CONF_SWAPSIZE line. It will then be created dynamically
  #CONF_SWAPSIZE=100
  ```

* Recreate and activate new swapfile

  ```sh
  $ sudo dphys-swapfile install
  $ sudo systemctl restart dphys-swapfile.service
  ```

---

### Continue with the guide

That's it: your Raspberry Pi now boots from the microSD card while the data directory `/data/` is located on the secondary disk.

You can now continue with the RaspiBolt guide.

---

<< Back: [+ System](index.md)
