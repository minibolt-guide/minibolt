---
title: Store data in a secondary disk
parent: + System
grand_parent: Bonus Section
nav_exclude: true
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

# Store data in a secondary disk

If you want to use a different disk to store data (blockchain and other databases) independently of the disk of the system, you can follow these instructions.

{% hint style="success" %}
Difficulty: Easy
{% endhint %}

![](../../images/store-data-secondary-disk.PNG)

## Case 1: during the Ubuntu server guided installation

When you arrive at the **"Guided storage configuration"** **(step 8)** on the [Ubuntu server installation](broken-reference/), follow the next steps:

**8.2.** Pay attention to checking **"Custom storage layout"** instead of ~~Use an entire disk~~, select **"Done"** and press **enter**

📝 Under **AVAILABLE DEVICES** you will see both drives you installed on the PC, identify each one by **drive model name** and **storage**

{% hint style="info" %}
It is recommended to choose the **smallest size drive** for the system and the **bigger size drive** for the data storage **`(/data)`** (blockchain, databases, etc)
{% endhint %}

> **8.2.1.** Select the section where appeared the **MODEL** of the **primary disk** between `"[]"` and press enter -> Select **"Use As Boot Device"** and press **enter** again

{% hint style="info" %}
This will select this storage as the boot disk and create automatically a new partition for the **"BIOS grub spacer"** on it.
{% endhint %}

> **8.2.2.** Select the **"free space"** section of the same device, and select **"Add GPT Partition"**. Ensure the format is selected as **`"ext4"`**, select **`"/"`** in the dropdown as mount point, select **"Create"** and press **enter**

> **8.2.3.** Now select the **"free space"** of the **secondary disk** on "AVAILABLE DEVICES" -> **Add GPT partition**. Ensure the format is selected as `"ext4"`, select **"Other"** in the dropdown, type `/data` to assign to the new **("/data")** folder, select **"Create"** and press enter

**9.** Select **"Done"** and press enter. Confirm destructive action warning banner hitting **"Continue"**

{% hint style="danger" %}
**This will delete all existing data on the disks, including existing partitions!**
{% endhint %}

<figure><img src="../../.gitbook/assets/storage-secondary-disk.gif" alt=""><figcaption></figcaption></figure>

{% hint style="warning" %}
The GIF above is a recreation of a scenario made with a virtual machine **-->** **VBOX\_HARDDISK\_**_VB4_... would be the **primary disk**, and **-->** **VBOX\_HARDDISK\_**_VB5_... would be the **secondary disk**. In your case, this probably **will not match exactly**
{% endhint %}

### Continue with the guide

{% hint style="success" %}
That's it: when you finish the [Operating system](../../index-1/operating-system.md) section, your PC will boot the system from the primary disk while the data directory **`(/data)`** will be located on the secondary disk.
{% endhint %}

**->** Now you can continue with **step 10** of the [Ubuntu Server installation](../../index-1/operating-system.md#ubuntu-server-installation)

## **Case 2: build it after system installation (by command line)**

Attach the secondary disk to the MiniBolt node

### **Format secondary disk**

* List all block devices with additional information

```sh
lsblk -o NAME,MOUNTPOINT,UUID,FSTYPE,SIZE,LABEL,MODEL
```

**Example** of expected output without existing partitions:

```
> NAME          MOUNTPOINT UUID       FSTYPE   SIZE    LABEL  MODEL
> sdb                                          931.5G         Samsung SSD 870
```

_Example_ expected output with existing partitions:

```
> NAME          MOUNTPOINT UUID              FSTYPE   SIZE    LABEL  MODEL
> sdb                                                 931.5G         Samsung SSD 870
> sdb1                     2219-782E         ext4     931.5G
```

{% hint style="info" %}
Here we will see if the new disk has been detected by the system and what unit name has been assigned to it. Normally `sda` is the name assigned for the primary disk and `sdb` for the secondary disk, but your case could be different, pay attention to the "MODEL" column to identify each one, e.g: Samsung SSD 870"
{% endhint %}

### **Delete the existing partition & create a new one**

* Type this command to use the `"fdisk"` utility and manage the secondary disk

```sh
sudo fdisk /dev/sdb
```

* Now we select the option wished pressing the option letter and enter
  * Press **`"n"`** to create a new partition and then enter. Press `enter` until the prompt show **(Command (m for help))** again

> **Case 1:** if you had existing partition/s, the prompt will show you **"All space for primary partitions is in use"**, you will need to type **`d`** and press enter until the prompt shows you **"Partition X has been deleted",** if not, press enter until the prompt shows you **"Created a new partition X of type 'Linux filesystem'"** and...

> **Case 2:** if you had existing partition/s, the prompt will show you **"Partition #1 contains an ext4 signature"** **"Do you want to remove the signature? \[Y]es/\[N]o"**, type **`Y`** and press enter until the prompt shows you **"The signature will be removed by a write command",** if not, press enter until the prompt shows you **"Created a new partition X of type 'Linux filesystem'"** and...

* Finally, don't forget, to type **`w`** to automatically write on disk and exit

{% hint style="info" %}
This will create a new partition called probably **`"sdb1"`**
{% endhint %}

* Finally, format the new partition to `"Ext4"` and obtain the **UUID**

```sh
sudo mkfs.ext4 /dev/[NAME_P]
```

**Example** of expected output:

<pre><code>mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 1572608 4k blocks and 393216 inodes
Filesystem UUID: <a data-footnote-ref href="#user-content-fn-1">dafc3c67-c6e5-4eaa-8840-adaf604c85db</a>
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736
</code></pre>

{% hint style="info" %}
Take note of your **UUID** e.g _**dafc3c67-c6e5-4eaa-8840-adaf604c85db**_ and the partition name of your secondary disk (normally **"sdb1"**)
{% endhint %}

### **Mount the secondary disk**

The secondary disk is then attached to the file system and becomes available as a regular folder (this is called “mounting”).

* List the block devices once more and copy the new partitions `UUID` into a text editor on your main machine

```sh
lsblk -o NAME,MOUNTPOINT,UUID,FSTYPE,SIZE,LABEL,MODEL
```

**Example** of expected output:

```
> NAME        MOUNTPOINT UUID                                 FSTYPE   SIZE LABEL  MODEL
> sdb                                                                931.5G        Samsung SSD 870
> └─sdb1                 3aab0952-3ed4-4652-b203-d994c4fdff20 ext4   931.5G
```

* Edit the `"fstab"` file and add the following as a new line **at the end**, replacing `<yourUUID>` with your own `UUID`

```sh
sudo nano /etc/fstab
```

```
UUID=<yourUUID> /data ext4 defaults 0 2
```

* Create the data directory as a mount point

```sh
sudo mkdir /data
```

* Assign as the owner to the `admin` user

```sh
sudo chown admin:admin /data
```

* Mount all disks and check the file system

```sh
sudo mount -a
```

* Is “/data” listed?

```sh
df -h /data
```

**Example** expected output:

```
> Filesystem      Size  Used Avail Use% Mounted on
> /dev/sdb1       938G   77M  891G   1% /data
```

* Check measure the speed of your secondary drive with

```sh
sudo hdparm -t --direct /dev/sdb
```

{% hint style="success" %}
If the measured speeds are more than 100 MB/s, you're good
{% endhint %}

**->** Now you can continue with the Security section of the guide, press [here](../../index-1/security.md)

## Case 3: replace the data disk

Change de data disk in MiniBolt node.

### Disable services

The first step is to disable all system services that use files on the disk we want to replace.

* We can check the services configured to start at boot by using:

```sh
ls /etc/systemd/system/multi-user.target.wants/
```

If you've followed this guide, these are the services you should disable.

```
bitcoind.service
fulcurm.service
btcrpcexplorer.service
lnd.service
thunderhub.service
```
* To disable these services, run the following for each one of them:

```sh
sudo systemctl disable <service name>
```

**Example:**

```sh
sudo systemctl disable bitcoind.service
```

* Check that the services you disabled no longer appear in the previously listed directory.

```sh
ls /etc/systemd/system/multi-user.target.wants/
```

### Disable automatic mounting of the old disk.

To change the disk, we will remove the disk we want to replace from the `/etc/fstab` file.

* List all block devices with additional information

```sh
lsblk -o NAME,MOUNTPOINT,UUID,FSTYPE,SIZE,LABEL,MODEL
```

We look for the partition of the disk we want to replace (it will be the one with `MOUNTPOINT = /data`) and copy its `UUID`.

* We modify the `/etc/fstab` file

```sh
sudo nano /etc/fstab
```

We look for the line that has the `UUID` we copied earlier (which should have `/data` as the mount point) and comment it out by adding `#` at the beginning.

We save and close the `/etc/fstab` file by pressing `Ctrl + o` and `ENTER`, and finally `Ctrl + x`.

### Replace the disk

* Shut down the system

```sh
sudo shutdown now
```

Once the system has shut down (you'll need to wait a short time), remove the old disk and insert the new one into the system. After finishing, start the system.

### Format secondary disk

* List all block devices with additional information

```sh
lsblk -o NAME,MOUNTPOINT,UUID,FSTYPE,SIZE,LABEL,MODEL
```

**Example** of expected output without existing partitions:

```
> NAME          MOUNTPOINT UUID       FSTYPE   SIZE    LABEL  MODEL
> sdb                                          931.5G         Samsung SSD 870
```

_Example_ expected output with existing partitions:

```
> NAME          MOUNTPOINT UUID              FSTYPE   SIZE    LABEL  MODEL
> sdb                                                 931.5G         Samsung SSD 870
> sdb1                     2219-782E         ext4     931.5G
```

> Here we will see if the new disk has been detected by the system and what unit name has been assigned to it. Normally `sda` is the name assigned for the primary disk and `sdb` for the secondary disk, but your case could be different, pay attention to the "MODEL" column to identify each one, e.g: Samsung SSD 870"

### Delete the existing partition & create a new one

* Type this command to use the `"fdisk"` utility and manage the secondary disk

```sh
sudo fdisk /dev/sdb
```

* Now we select the option wished pressing the option letter and enter
  * Press **`"n"`** to create a new partition and then enter. Press `enter` until the prompt show **(Command (m for help))** again

> **Case 1:** if you had existing partition/s, the prompt will show you **"All space for primary partitions is in use"**, you will need to type **`d`** and press enter until the prompt shows you **"Partition X has been deleted",** if not, press enter until the prompt shows you **"Created a new partition X of type 'Linux filesystem'"** and...

> **Case 2:** if you had existing partition/s, the prompt will show you **"Partition #1 contains an ext4 signature"** **"Do you want to remove the signature? \[Y]es/\[N]o"**, type **`Y`** and press enter until the prompt shows you **"The signature will be removed by a write command",** if not, press enter until the prompt shows you **"Created a new partition X of type 'Linux filesystem'"** and...

* Finally, don't forget, to type **`w`** to automatically write on disk and exit

> This will create a new partition called probably **`"sdb1"`**

* Finally, format the new partition to `"Ext4"` and obtain the **UUID**

```sh
sudo mkfs.ext4 /dev/[NAME_P]
```

**Example** of expected output:

<pre><code>mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 1572608 4k blocks and 393216 inodes
Filesystem UUID: <a data-footnote-ref href="#user-content-fn-1">dafc3c67-c6e5-4eaa-8840-adaf604c85db</a>
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736
</code></pre>

> Take note of your **UUID** e.g _**dafc3c67-c6e5-4eaa-8840-adaf604c85db**_ and the partition name of your secondary disk (normally **"sdb1"**)

### Mount the secondary disk

The secondary disk is then attached to the file system and becomes available as a regular folder (this is called “mounting”).

* List the block devices once more and copy the new partitions `UUID` into a text editor on your main machine

```sh
lsblk -o NAME,MOUNTPOINT,UUID,FSTYPE,SIZE,LABEL,MODEL
```

**Example** of expected output:

```
> NAME        MOUNTPOINT UUID                                 FSTYPE   SIZE LABEL  MODEL
> sda                                                                    119.2G       128GB SSD
> ├─sda1 /boot/efi         E752-C921                            vfat         1G
> └─sda2 /                 84c9357d-8e36-465d-90b8-1036a2be26d1 ext4     118.2G
> sdb                                                                      1.9T       Fanxiang S101 2T
> └─sdb1 /data             d77c2442-1294-42e4-ba4e-9c54421469c7 ext4       1.9T
```


* Edit the `"/etc/fstab"` file and add the following as a new line **at the end**, replacing `<yourUUID>` with your own `UUID`

```sh
sudo nano /etc/fstab
```

```
UUID=<yourUUID> /data ext4 defaults 0 2
```

* Mount all disks and check the file system

```sh
sudo mount -a
```

* Is “/data” listed?

```sh
df -h /data
```

**Example** expected output:

```
> Filesystem      Size  Used Avail Use% Mounted on
> /dev/sdb1       1.9T  383G  1.9T  1% /data
```

* Check measure the speed of your secondary drive with

```sh
sudo hdparm -t --direct /dev/sdb
```

> If the measured speeds are more than 100 MB/s, you're good

### Copy data

* Connect the old disk to the system (you'll need to place the disk in an adapter that allows it to connect via USB) and check that it is detected:

```sh
lsblk -o NAME,MOUNTPOINT,UUID,FSTYPE,SIZE,LABEL,MODEL
```

**Example** of expected output:

```
> NAME        MOUNTPOINT UUID                                 FSTYPE   SIZE LABEL  MODEL
> sdc                                                                    931.5G       > 500SSD1
> └─sdc1                 d5932005-de0a-4926-bccb-2a341b720555 ext4     931.5G
```

> We will assume that the partition of the old disk connected via USB is `sdc1`.

* We create a directory to mount the old disk and then mount it.

```sh
sudo mkdir /mnt/old_disk
```

```sh
sudo mount /dev/sdc1 /mnt/old_disk/
```

And check that it has mounted correctly:

```sh
ls  /mnt/old_disk/
```

**Example** of expected output:

```
bitcoin fulcrum lnd
```

* Copy data

```sh
sudo rsync -aAXv /mnt/old_disk/ /data/
```
> This may take several hours, depending on the size of your disk. It's an incremental process, so if you need to stop it, when you restart it, it will continue synchronizing from where it left off.

* Umount old disk

```sh
sudo umount /mnt/old_disk
```

Now you can disconnect the old disk.

### Enable services

* Now we can re-enable the services that we had previously disabled.

```sh
sudo systemctl enable <service name>
```

**Example:**

```sh
sudo systemctl enable bitcoind.service
```

* You can verify that the services have been enabled by checking if the symbolic links are created:

```sh
ls /etc/systemd/system/multi-user.target.wants/
```

* Finally, restart the system to ensure all services start up again.

```sh
sudo reboot
```

### Check and clean up

* Check if the new disk has been mounted.

```sh
ls /data
```

**Example** of expected output:

```
bitcoin fulcrum lnd
```

* Check if the services have started correctly.

```sh
systemctl status <service name>
```

```sh
journalctl -fu <service name>
```

* You can clean up the `/etc/fstab` file by deleting the line we previously commented out that referenced the old disk. If you prefer, you can leave it commented out.

```sh
sudo nano/etc/fstab
```

* Delete the folder created for mounting the USB

```sh
sudo rm -r /mnt/old_disk/
```

[^1]: Note this
