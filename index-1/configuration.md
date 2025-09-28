# 1.4 Configuration

You are now on the command line of your own Bitcoin node. Let's start with the configuration.

<figure><img src="../.gitbook/assets/configuration.jpg" alt="" width="375"><figcaption></figcaption></figure>

## Add the admin user (and log in with it)

We will use the primary user `admin` instead of `temp` to make this guide more universal.

* Create a new user called `admin` with your `password [A]` when password ask you

```sh
sudo adduser --gecos "" admin
```

**Example** of expected output:

```
Adding user `admin' ...
Adding new group `admin' (1001) ...
Adding new user `admin' (1001) with group `admin' ...
Creating home directory `/home/admin' ...
Copying files from `/etc/skel' ...
```

* Make this new user a superuser by adding it to the `sudo` and old `temp` user groups

```sh
sudo usermod -a -G sudo,adm,cdrom,dip,plugdev,lxd admin
```

* Logout the existing `temp` user

```sh
logout
```

* Repeat [Access with Secure Shell](remote-access.md#access-with-secure-shell) but this time login with `admin` and your `password [A]`
* Delete the `temp` user. Do not worry about the `userdel: temp mail spool (/var/mail/temp) not found` message

```sh
sudo userdel -rf temp
```

Expected output:

```
userdel: temp mail spool (/var/mail/temp) not found
```

{% hint style="info" %}
To change the system configuration and files that don't belong to the user "admin", you have to prefix commands with `sudo`. You will be prompted to enter your admin `password [A]` from time to time for increased security
{% endhint %}

## Login with SSH keys (optional)

{% hint style="info" %}
Now, you can start to access it without a password by following the [SSH keys bonus guide](../bonus-guides/security/ssh-keys.md)
{% endhint %}

## Uninstall Snap (optional)

Ubuntu Server comes with snap preinstalled by default. However, since we don't plan to use it, it can be safely removed without impacting system functionality. Uninstalling Snap is a straightforward process that will help keep our MiniBolt clean and optimized for the applications you need.

* Delete the existing Snap packages

```bash
sudo snap remove lxd && sudo snap remove core20 && sudo snap remove snapd
```

Expected output:

```
lxd removed
core20 removed
snapd removed
```

* Ensure packages have been deleted successfully

```bash
snap list
```

Expected output:

```
No snaps are installed yet. Try 'snap install hello-world'.
```

* Stop and disable the `snapd.service` & `snapd.socket` processes

```bash
sudo systemctl stop snapd snapd.socket && sudo systemctl disable snapd snapd.socket
```

Expected output:

```
Removed /etc/systemd/system/multi-user.target.wants/snapd.service.
Removed /etc/systemd/system/sockets.target.wants/snapd.socket.
```

* To uninstall, use the package manager by typing this command. Press "**y**" and `enter` or directly `enter` when the prompt asks you

```bash
sudo apt autoremove snapd --purge
```

Expected output:

```
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following packages will be REMOVED:
  snapd* squashfs-tools* ubuntu-server-minimal*
0 upgraded, 0 newly installed, 3 to remove and 7 not upgraded.
After this operation, 110 MB disk space will be freed.
Do you want to continue? [Y/n]
```

* Delete the residual folders

```bash
sudo rm -r /root/snap
```

## System update

* Update the operating system and all installed software packages

```sh
sudo apt update && sudo apt full-upgrade
```

{% hint style="info" %}
-> Do this regularly for security-related updates

-> If during the update process, a banner appears asking you, "Which services should be restarted?" you can press ENTER and take note of the services that will be restarted, marked with `[*]`. Example 🔽
{% endhint %}

![](../images/update-action.PNG)

{% hint style="info" %}
It is recommended to keep the default selection and restart all marked items. However, if you want to unmark any of them, select the item and press the **spacebar to toggle the mark**. Finally, press `ENTER` to confirm
{% endhint %}

* To be able to use the `minibolt` hostname instead of the IP address, we must install this necessary software package. Press "**y**" and `enter` or directly `enter` when the prompt asks you

```sh
sudo apt install avahi-daemon
```

## Check drive performance

Performant unit storage is essential for your node.

Let's check if your drive works well as-is.

* Your disk should be detected as `/dev/sda`. Check if this is the case by listing the names of connected block devices

```sh
lsblk -pli
```

* Measure the speed of your drive

```sh
sudo hdparm -t --direct /dev/sda
```

**Example** of expected output:

```
Timing O_DIRECT disk reads: 932 MB in 3.00 seconds = 310.23 MB/sec
```

* If you installed a **secondary disk**, check and measure the speed with the next command, if not, skip it

```sh
sudo hdparm -t --direct /dev/sdb
```

**Example** of expected output:

```
Timing O_DIRECT disk reads: 932 MB in 3.00 seconds = 310.23 MB/sec
```

{% hint style="success" %}
If the measured speeds are more than 150 MB/s, you're good but it is recommended more for a better experience
{% endhint %}

## Data directory

We'll store all application data in the dedicated directory `/data`. This allows for better security because it's not inside any user's home directory. Additionally, it's easier to move that directory somewhere else, for instance to a separate drive, as you can just mount any storage option to `/data`

* Create the data folder

```sh
sudo mkdir /data
```

{% hint style="info" %}
Remember that the before command is unnecessary if you previously followed [Case 1](../bonus/system/store-data-secondary-disk.md#case-1-during-the-ubuntu-server-guided-installation) of [Store data in a secondary disk](../bonus/system/store-data-secondary-disk.md) bonus guide, which involves storing the data in a secondary disk. This is because the **("data")** folder has already been created. If the prompt shows you: `mkdir: cannot create directory '/data': File exists` probably is that. Then ignore it and follow with the next command 🔽
{% endhint %}

* Assing to the `admin` user as the owner of the **`/data`** folder

```sh
sudo chown admin:admin /data
```
