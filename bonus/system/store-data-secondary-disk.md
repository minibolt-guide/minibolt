---
title: Store data in a secondary disk
parent: + System
grand_parent: Bonus Section
nav_exclude: true
has_toc: false
---

# Store data in a secondary disk

If you want to use a different disk to store data (blockchain and other databases) independently of the system's disk, you can follow these instructions.

{% hint style="success" %}
Difficulty: Easy
{% endhint %}

![](../../images/store-data-secondary-disk.PNG)

## Case 1: during the Ubuntu server guided installation

When you arrive at the **"Guided storage configuration"** **(step 8)** on the [Ubuntu server installation](broken-reference/), follow the next steps:

**8.2.** Pay attention to checking **"Custom storage layout"** instead of ~~Use an entire disk~~, select **\[Done]** and press **ENTER**

📝 Under **AVAILABLE DEVICES** you will see both drives you installed on the PC, identify each one by **drive model name** and **storage**

{% hint style="info" %}
It is recommended to choose the **smallest size drive** for the system and the **bigger size drive** for the data storage **`/data`** (blockchain, databases, etc)
{% endhint %}

> **8.2.1.** Select the section where appeared the **MODEL** of the **primary disk** between `"[]"` and press **enter** -> Select **"Use As Boot Device"** and press **ENTER** again

{% hint style="info" %}
This will select this storage as the boot disk and automatically create a new partition for the **"BIOS grub spacer"** on it.
{% endhint %}

> **8.2.2.** Select the **"free space"** section of the same device, and select **"Add GPT Partition"**. Ensure the format is selected as **`"ext4"`**, select **`"/"`** in the dropdown as mount point, select **"Create"** and press **enter**

> **8.2.3.** Now select the **"free space"** of the **secondary disk** on "AVAILABLE DEVICES" section -> **Add GPT partition**. Ensure the format is selected as `"ext4"`, select **"Other"** in the dropdown, type `/data` to assign to the new **"/data"** folder, select **\[Create]** and press enter

**9.** Select **\[Done]** and press enter. Confirm destructive action warning banner hitting **\[Continue]**

{% hint style="danger" %}
**This will delete all existing data on the disks, including existing partitions!**
{% endhint %}

<figure><img src="../../.gitbook/assets/storage-secondary-disk.gif" alt=""><figcaption></figcaption></figure>

{% hint style="info" %}
The GIF above is a recreation of a scenario made with a virtual machine **->** **VBOX\_HARDDISK\_**_VB4_... would be the **primary disk**, and **->** **VBOX\_HARDDISK\_**_VB5_... would be the **secondary disk**. In your case, this probably **will not match exactly**
{% endhint %}

### Continue with the guide

{% hint style="success" %}
That's it: when you finish the [Operating system](../../index-1/operating-system.md) section, your PC will boot the system from the primary disk while the data directory **`/data`** will be located on the secondary disk.
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
NAME          MOUNTPOINT UUID       FSTYPE     SIZE    LABEL  MODEL
sdb                                          931.5G           Secondary_SSD
```

**Example** of expected output with existing partitions:

```
NAME          MOUNTPOINT UUID              FSTYPE       SIZE    LABEL  MODEL
sdb                                                   931.5G           Secondary_SSD
└─sdb1                   2219-782E           ext4     931.5G
```

{% hint style="info" %}
Here we will see if the system has detected the new disk and what unit name has been assigned to it. Normally `sda` is the name assigned for the primary disk and `sdb` for the secondary disk, but your case could be different, pay attention to the "MODEL" column to identify each one, e.g: Samsung SSD 870"
{% endhint %}

### **Delete the existing partition & create a new one**

* Type this command to use the `"fdisk"` utility and manage the secondary disk

```sh
sudo fdisk /dev/sdb
```

-> **2 cases**, depending on whether your drive contains partitions or not:

{% tabs %}
{% tab title="Case 1: doesn't contain existing partitions" %}
If you don't see any "sdb**X**" partition in the previous step, i.e `sdb1`:

* Press **`"n"`** to create a new partition and then press ENTER until the prompt shows you:&#x20;

```
Created a new partition X of type 'Linux filesystem'
(Command (m for help)) again
```
{% endtab %}

{% tab title="Case 2: contain existing partitions" %}
If you have an existing partition "sdb**X**" in the previous step, i.e `sdb1`:

* Press **`"d"`** to delete the existing partitions and then press ENTER until the prompt shows you:

```
Partition X has been deleted
(Command (m for help)) again
```

{% hint style="info" %}
If you have more than one partition, repeat the before step until there are none left
{% endhint %}

* Press **`"n"`** to create a new partition and then press ENTER until the prompt shows:

```
Created a new partition X of type 'Linux filesystem'
(Command (m for help)) again
```
{% endtab %}
{% endtabs %}

-> Finally, don't forget, to type **`w`**  and **ENTER** to write table to disk and exit

{% hint style="info" %}
This will create a new partition called probably **`"sdb1"`**
{% endhint %}

* Format the partition with the **Ext4** system file (replace`[NAME]` to your partition name, e.g. `sdb1`)

```sh
sudo mkfs.ext4 /dev/[NAME]
```

{% hint style="danger" %}
**Attention: this will delete all existing data on the external drive!**
{% endhint %}

**Example** of command:

```bash
sudo mkfs.ext4 /dev/sdb1
```

**Example** of expected output:

<pre><code>mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 1572608 4k blocks and 393216 inodes
Filesystem UUID: <a data-footnote-ref href="#user-content-fn-1">dafc3c67-c6e5-4eaa-8840-adaf604c85db</a>
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736
</code></pre>

{% hint style="info" %}
Take note of the `Filesystem UUID` -> i.e: _dafc3c67-c6e5-4eaa-8840-adaf604c85db_, you will need this more later
{% endhint %}

### **Mount the secondary disk**

The secondary disk is then attached to the file system and becomes available as a regular folder (this is called “mounting”).

* List the block devices one more time to ensure that UUID has been assigned

```sh
lsblk -o NAME,MOUNTPOINT,UUID,FSTYPE,SIZE,LABEL,MODEL
```

**Example** of expected output:

<pre><code>NAME        MOUNTPOINT UUID                                        FSTYPE      SIZE LABEL  MODEL
sda                                                                          126.8G        Primary_SSD
└─sda1                      3aab0952-3ed4-4652-b203-d994c4fdff20     ext4    126.8G
sdb                                                                          931.5G        Secondary_SSD
└─sdb1                 <a data-footnote-ref href="#user-content-fn-2">dafc3c67-c6e5-4eaa-8840-adaf604c85db</a>     ext4    931.5G
</code></pre>

{% hint style="info" %}
Copy the new partition `UUID` into a text editor on your regular machine
{% endhint %}

* Edit the `fstab` file

```sh
sudo nano /etc/fstab
```

* Add the following as a new line **at the end of the file**

<pre><code>UUID=<a data-footnote-ref href="#user-content-fn-3">&#x3C;yourUUID></a> /data ext4 defaults 0 2
</code></pre>

{% hint style="info" %}
Replace `<yourUUID>` with your `UUID` obtained before
{% endhint %}

* Create the data directory as a mount point

```sh
sudo mkdir /data
```

* Assing to the `admin` user as the owner of the **`/data`** folder

```sh
sudo chown admin:admin /data
```

* Mount all drives

```sh
sudo mount -a
```

* Check the file system. Is `/data` listed?

```sh
df -h /data
```

**Example** expected output:

```
Filesystem      Size  Used Avail Use% Mounted on
/dev/sdb1       931G   77M  891G   1% /data
```

Or check the mount point using `lsblk`

```
lsblk -o NAME,MOUNTPOINT,UUID,FSTYPE,SIZE,LABEL,MODEL
```

Example of expected output:

<pre><code>NAME        MOUNTPOINT     UUID                                 FSTYPE   SIZE LABEL  MODEL
sda                                                                    126.8G        Primary_SSD
└─sda1      /              15af9b1d-ca7c-441f-b101-c1a0cf76a062 ext4   126.8G
<strong>sdb                                                                    931.5G        Secondary_SSD
</strong>└─sdb1      /data          15af9b1d-ca7c-441f-b101-c1a0cf76a062 ext4   931.5G
</code></pre>

* Check measure the speed of your secondary drive with

```sh
sudo hdparm -t --direct /dev/sdb
```

{% hint style="success" %}
If the measured speeds are more than 150 MB/s, you're good
{% endhint %}

{% hint style="info" %}
Now you can continue with the Security section of the guide, press [here](../../index-1/security.md)
{% endhint %}

[^1]: Note this

[^2]: Take note of this

[^3]: Replace this
