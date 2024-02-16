---
title: Channel backup
nav_order: 20
parent: Lightning
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

# 3.2 Channel backup for LND

We set up a local or remote "Static Channel Backup" for Lightning. A monitoring script keeps it up-to-date to enable the recovery of your Lightning funds in case of hardware failure.

![](../images/remote-scb-backup.png)

## Why are Lightning channel backups important?

The Static Channels Backup (SCB) is a feature of LND that allows for the on-chain recovery of lightning channel balances in the case of a bricked node. Despite its name, it does not allow the recovery of your LN channels but increases the chance that you'll recover all (or most) of your off-chain (local) balances.

The SCB contains all the necessary channel information used for the recovery process called Data Loss Protection (DLP). It is a safe backup mechanism with no risk of provoking penalty transactions that could lead to losing channel balances. The SCB contains all necessary peer and channel information, allowing LND to send a request to force-close the channel on their end to all your previous online peers. Without this method, you would need to contact your peers manually or wait for them to force-close on their own eventually.

This SCB-based recovery method has several consequences worth bearing in mind:

* This method relies on the goodwill of the peer: a malicious peer could refuse to force close the channel, and the funds would remain locked up.
* Recovery only works with online peers: LND cannot send a request to force-close the channel if a peer is offline. Therefore, the funds in that channel will remain locked up until this peer comes back online, or possibly forever if that peer doesn't come back.
* The backup needs to be up-to-date: Since LND needs to know about your peers and channels, the SCB needs to be updated every time you open a new channel.

You need to set up an automated SCB update mechanism that:

1. Creates or updates your SCB file each time you open a channel (or close one, although this is less important).
2. Stores the SCB file in a different backup location to ensure that it is available in case of a failing SSD.

You can read more about SCBs in [this section of Mastering the Lightning Network](https://github.com/lnbook/lnbook/blob/ec806916edd6f4d1b2f9da2fef08684f80acb671/05\_node\_operations.asciidoc#node-and-channel-backups)

## Choose your preferred backup method(s)

This guide covers two automated backup methods:

* **LOCAL**: store the backup on a USB thumbdrive or microSD card plugged into your Pi
* **REMOTE**: send the encrypted backup to a private GitHub repository

<table data-full-width="false"><thead><tr><th align="center">Method</th><th align="center">Requires hardware</th><th align="center">Requires GitHub account</th><th align="center">Protects against</th><th align="center">Relies on 3rd-party</th></tr></thead><tbody><tr><td align="center">LOCAL</td><td align="center">YES</td><td align="center">NO</td><td align="center">Drive failure only</td><td align="center">NO</td></tr><tr><td align="center">REMOTE</td><td align="center">NO</td><td align="center">YES</td><td align="center">Drive failure &#x26; widespread node damage</td><td align="center">YES</td></tr></tbody></table>

We recommend using both methods, but you can choose either one of them, depending on your requirements and preferences. Whatever method you choose:

1. Follow the "Preparations" section first, then
2. Follow the optional local and/or remote backup sections.
3. Finally, follow the "Run SCB-Backup" section that works for whatever method you've chosen.

## Requirements

* [Bitcoin Core](../index-2/bitcoin-client.md)
* [LND](lightning-client.md)

## Preparations

We prepare a shell script that automatically updates the LND SCB file on a change in your backup location(s).

### Install inotify-tools

Installing [`inotify-tools`](https://github.com/inotify-tools/inotify-tools) allows us to use `inotify`, an application that monitors files and directories for changes.

We will use it to monitor the `channel.backup` file and detect updates by LND each time a channel is opened or closed.

* With user `admin`, install `inotify-tools`

```sh
$ sudo apt install inotify-tools
```

### Create script

We create a shell script to monitor `channel.backup` and make a copy of our backup locations if it changes.

* Create a new shell script file

```sh
$ sudo nano /usr/local/bin/scb-backup --linenumbers
```

* Check the following lines of code and paste them into the text editor. By default, both local and remote backup methods are disabled. We will enable one or both of them in the next sections, depending on your preferences. Save and exit

```
#!/bin/bash

# Safety bash script options
# -e causes a bash script to exit immediately when a command fails
# -u causes the bash shell to treat unset variables as an error and exit immediately.
set -eu

# The script waits for a change in the "channel.backup" file
# When a change happens, it creates a backup of the file locally
# on a storage device and/or remotely in a GitHub repo

# By default, either method is used. If you want to use one of the
# method, replace "false" with "true" in the two variables below:
LOCAL_BACKUP_ENABLED=false
REMOTE_BACKUP_ENABLED=false

# Locations of source SCB file and the backup target directories (local and remote)
SCB_SOURCE_FILE="/data/lnd/data/chain/bitcoin/mainnet/channel.backup"
LOCAL_BACKUP_DIR="/mnt/static-channel-backup-external"
REMOTE_BACKUP_DIR="/data/lnd/remote-lnd-backup"

# Local backup function
run_local_backup_on_change () {
  echo "Copying backup file to local storage device..."
  echo "$1"
  cp "$SCB_SOURCE_FILE" "$1"
  echo "Success! The file is now locally backed up!"
}

# Remote backup function
run_remote_backup_on_change () {
  echo "Entering Git repository..."
  cd $REMOTE_BACKUP_DIR || exit
  echo "Making a timestamped copy of channel.backup..."
  echo "$1"
  cp "$SCB_SOURCE_FILE" "$1"
  echo "Committing changes and adding a message..."
  git add .
  git commit -m "Static Channel Backup $(date +"%Y%m%d-%H%M%S")"
  echo "Pushing changes to remote repository..."
  git push --set-upstream origin main
  echo "Success! The file is now remotely backed up!"
}

# Monitoring function
run () {
  while true; do

      inotifywait $SCB_SOURCE_FILE
      echo "channel.backup has been changed!"

      LOCAL_BACKUP_FILE="$LOCAL_BACKUP_DIR/channel-$(date +"%Y%m%d-%H%M%S").backup"
      REMOTE_BACKUP_FILE="$REMOTE_BACKUP_DIR/channel-$(date +"%Y%m%d-%H%M%S").backup"

      if [ "$LOCAL_BACKUP_ENABLED" == true ]; then
        echo "Local backup is enabled"
        run_local_backup_on_change "$LOCAL_BACKUP_FILE"
      fi

      if [ "$REMOTE_BACKUP_ENABLED" == true ]; then
        echo "Remote backup is enabled"
        run_remote_backup_on_change "$REMOTE_BACKUP_FILE"
      fi

  done
}

run
```

* Make the script executable

```sh
$ sudo chmod +x /usr/local/bin/scb-backup
```

## Option 1: Local backup

Follow this section if you want a local backup. If you only want a remote backup, skip to the [next section](channel-backup.md#option-2-remote-backup-preparations).

### Storage device size

The `channel.backup` file is very small in size (<<1 MB) so even the smallest USB thumbdrive or microSD card will do the job.

### Formatting

* To ensure that the storage device does not contain malicious code, we will format it on our local computer (select a name easy to recognize like "SCB backup" and choose the FAT filesystem). The following external guides explain how to format your USB thumbdrive or microSD card on [Windows](https://www.techsolutions.support.com/how-to/how-to-format-a-usb-drive-in-windows-12893), [macOS](https://www.techsolutions.support.com/how-to/how-to-format-a-usb-drive-on-a-mac-12899), or [Linux](https://phoenixnap.com/kb/linux-format-usb)
* Once formatted, plug the storage device into your PC. If using a thumbdrive, use one of the black USB2 ports

### Set up a mounting point for the storage device

* Create the mounting directory

```sh
$ sudo mkdir /mnt/static-channel-backup-external
```

* Make it immutable

```bash
$ sudo chattr +i /mnt/static-channel-backup-external
```

* List active block devices and copy the `UUID` of your backup device into a text editor on your local computer (e.g. here `123456`)

```sh
$ lsblk -o NAME,MOUNTPOINT,UUID,FSTYPE,SIZE,LABEL,MODEL
```

```
> NAME   MOUNTPOINT UUID                                 FSTYPE   SIZE LABEL      MODEL
> sda                                                           931.5G            SSD_PLUS_1000GB
> |-sda1 /boot      DBF3-0E3A                            vfat     256M boot
> `-sda2 /          b73b1dc9-6e12-4e68-9d06-1a1892663226 ext4   931.3G rootfs
> sdb               123456                               vfat     1.9G SCB backup UDisk
```

* Get the "lnd" user identifier (UID) and the "lnd" group identifier (GID) from the `/etc/passwd` database of all user accounts. Copy these values into a text editor on your local computer (e.g. here GID `XXXX` and UID `YYYY`)

```sh
$ awk -F ':' '$1=="lnd" {print "GID: "$3" / UID: "$4}'  /etc/passwd
```

```
> GID: XXXX / UID: YYYY
```

* Edit your Filesystem Table configuration file and add the following as a new line at the end, replacing `123456`, `XXXX` and `YYYY` with your own `UUID`, `GID` and `UID`

```sh
$ sudo nano /etc/fstab
```

```sh
UUID=123456 /mnt/static-channel-backup-external vfat auto,noexec,nouser,rw,sync,nosuid,nodev,noatime,nodiratime,nofail,umask=022,gid=XXXX,uid=YYYY 0 0
```

* Mount the drive and check the file system

```sh
$ sudo mount -a
```

* &#x20;Is “`/mnt/static-channel-backup-external`” listed?

```bash
$ df -h /mnt/static-channel-backup-external
```

```
> Filesystem      Size  Used Avail Use% Mounted on
> /dev/sdb        1.9G  4.0K  1.9G   1% /mnt/static-channel-backup-external
```

### Enable the local backup function in the script

* Enable the local backup in the script by changing the variable value for `LOCAL_BACKUP_ENABLED` at line 14 to `true`. Save and exit

```sh
$ sudo nano /usr/local/bin/scb-backup --linenumbers
```

```
LOCAL_BACKUP_ENABLED=true
```

## Option 2: Remote backup preparations

Follow this section if you want a remote backup. If you already set up a local backup, and don't want a remote backup, skip to the [next section](channel-backup.md#create-systemd-service).

### Create a GitHub repository

* Go to [GitHub](https://github.com/), sign up for a new user account, or log in with an existing one. If you don't want GitHub to know your identity and IP address in relation to your Lightning node, it is recommended to create a new account even if you have an existing one, and use [Tor Browser](https://www.torproject.org/download/) for this and follow the steps
* Create a [new repository](https://github.com/new)
  * Type the following repository name: `remote-lnd-backup`
  * Select "Private" (rather than the default "Public")
  * Click on "Create repository"

### Clone the repository to your node

* Using the `lnd` user

```sh
$ sudo su - lnd
```

* Create a pair of SSH keys

```bash
$ ssh-keygen -t rsa -b 4096
```

* When prompted, press "Enter" to confirm the default SSH directory and press "Enter" again to not set up a passphrase

```
> Generating public/private rsa key pair.
> [...]
```

* Display the public key and take note

```sh
$ cat ~/.ssh/id_rsa.pub
```

```
> ssh-rsa 1234abcd... lnd@minibolt
```

* Go back to the GitHub repository webpage
  * Click on "Settings", then "Deploy keys", then "Add deploy key"
  * Type a title (e.g. "SCB")
  * In the "Key" box, copy/paste the string generated above starting (e.g. `ssh-rsa 1234abcd... lnd@minibolt`)
  * Tick the box "`Allow write access`" to enable this key to push changes to the repository
  * Click "Add key"
* Set up global Git configuration values (the name and email are required but can be dummy values)

```sh
$ git config user.name "MiniBolt"
```

```bash
$ git config user.email "minibolt@dummyemail.com"
```

* **(Optional)** Add this step if you want to preserve your privacy with GitHub servers if not, jump to the next step directly -> (`$ cd ~/.lnd`)

<pre class="language-bash"><code class="lang-bash"><strong>$ git config --global core.sshCommand "torsocks ssh"
</strong></code></pre>

* Move to the LND data folder and clone your newly created empty repository

```bash
$ cd ~/.lnd
```

* Replace `<YourGitHubUsername>` with your own GitHub username.  When prompted `"Are you sure you want to continue connecting (yes/no/[fingerprint])?"` type "yes" and enter

```bash
$ git clone git@github.com:<YourGitHubUsername>/remote-lnd-backup.git
```

**Example** of expected output:

```
> Cloning into 'remote-lnd-backup'...
> The authenticity of host 'github.com (140.82.121.3)' can't be established.
> ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.
> This key is not known by any other names
> Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
> Warning: Permanently added 'github.com' (ED25519) to the list of known hosts.
> warning: You appear to have cloned an empty repository.
[...]
```

* Exit the `lnd` session to return to the `admin` user session

```bash
$ exit
```

### Enable the remote backup function in the script

* Enable the remote backup in the script by changing the variable value for `REMOTE_BACKUP_ENABLED` line 15 to `true`. Save and exit

```sh
$ sudo nano /usr/local/bin/scb-backup --linenumbers
```

```
REMOTE_BACKUP_ENABLED=true
```

## Create systemd service

We set up the backup script as a systemd service to run in the background and optionally start automatically on system startup.

* Still as user `admin`, create a new service file

```sh
$ sudo nano /etc/systemd/system/scb-backup.service
```

* Paste the following lines. Save and exit

<pre><code># MiniBolt: systemd unit for automatic SCB backup
# /etc/systemd/system/scb-backup.service

[Unit]
Description=SCB Automatic Backup
After=lnd.service

[Service]
ExecStart=/usr/local/bin/scb-backup

User=lnd
Group=lnd

<strong># Process management
</strong>####################
Restart=always
RestartSec=1

[Install]
WantedBy=multi-user.target
</code></pre>

* Enable autoboot **(optional)**

```sh
$ sudo systemctl enable scb-backup
```

* Prepare “scb-backup” monitoring by the systemd journal and check the logging output. You can exit monitoring at any time with Ctrl-C

```bash
$ journalctl -f -u scb-backup
```

## Run

To keep an eye on the software movements, [start your SSH program](../index-1/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as "admin". Commands for the **second session** start with the prompt **`$2` (which must not be entered).**

* Start the service

```bash
$2 sudo systemctl start scb-backup
```

**Example** of expected output on the  first SSH session with `$ journalctl -f -u btcrpcexplorer` ⬇️

```
Jul 25 17:31:54 minibolt systemd[1]: Started SCB Backup.
Jul 25 17:31:54 minibolt scb-backup[401705]: Watches established.
```

* The automated backup is now up and running. To test if everything works, we now cause the default `channel.backup` file to change. Then we check if a copy gets stored at the intended backup location(s). Simulate a `channel.backup` file change with the `touch` command (don't worry! It simply updates the timestamp of the file but not its content)

```sh
$2 sudo touch /data/lnd/data/chain/bitcoin/mainnet/channel.backup
```

* Switch back again to the first SSH session. In the logs, you should see new entries similar to these (depending on which backup methods you enabled)

<details>

<summary><strong>Example</strong> of the expected output  with <code>$ journalctl -f -u btcrpcexplorer</code> ⬇️</summary>

```
Jul 25 17:32:32 minibolt scb-backup[401705]: /data/lnd/data/chain/bitcoin/mainnet/channel.backup OPEN
Jul 25 17:32:32 minibolt scb-backup[401704]: channel.backup has been changed!
Jul 25 17:32:32 minibolt scb-backup[401704]: Remote backup is enabled
Jul 25 17:32:32 minibolt scb-backup[401704]: Entering Git repository...
Jul 25 17:32:32 minibolt scb-backup[401704]: Making a timestamped copy of channel.backup...
Jul 25 17:32:32 minibolt scb-backup[401704]: /data/lnd/remote-lnd-backup/channel-20230725-173232.backup
Jul 25 17:32:32 minibolt scb-backup[401704]: Committing changes and adding a message
Jul 25 17:32:32 minibolt scb-backup[401740]: [main (root-commit) 927ac24] Static Channel Backup 20230725-173232
Jul 25 17:32:32 minibolt scb-backup[401740]:  1 file changed, 0 insertions(+), 0 deletions(-)
Jul 25 17:32:32 minibolt scb-backup[401740]:  create mode 100644 channel-20230725-173232.backup
Jul 25 17:32:32 minibolt scb-backup[401704]: Pushing changes to remote repository...
Jul 25 17:32:34 minibolt scb-backup[401742]: To github.com:minibolt/remote-lnd-backup.git
Jul 25 17:32:34 minibolt scb-backup[401742]:  * [new branch]      main -> main
Jul 25 17:32:34 minibolt scb-backup[401742]: Branch 'main' set up to track remote branch 'main' from 'origin'.
Jul 25 17:32:34 minibolt scb-backup[401704]: Success! The file is now remotely backed up!
Jul 25 17:32:34 minibolt scb-backup[401749]: Setting up watches.
Jul 25 17:32:34 minibolt scb-backup[401749]: Watches established.
```

</details>

{% hint style="warning" %}
If you get the next error:

```
Nov 05 23:18:43 minibolt scb-backup[1710686]: Pushing changes to remote repository...
Nov 05 23:18:43 minibolt scb-backup[1711268]: error: src refspec main does not match any
Nov 05 23:18:43 minibolt scb-backup[1711268]: error: failed to push some refs to 'github.com:<YourGitHubUsername>/remote-lnd-backup.git
```

\-> Replace the line 41 `git push "--set-upstream origin`` `**`main"`** to "`git push --set-upstream origin`` `**`master"`** [in the script](channel-backup.md#create-script) , and try again
{% endhint %}

* **If you enabled the local backup**, check the content of your local storage device. It should now contain a backup file with the date/time corresponding to the test made just above

```sh
$ ls -la /mnt/static-channel-backup-external
```

**Example** of expected output:

```
> -rwxr-xr-x 1 lnd  lnd  14011 Feb  5 10:59 channel-20220205-105949.backup
```

* **If you enabled the remote backup**, check your GitHub repository (in the `[ <> Code ]` tab). It should now contain the latest timestamped backup file

{% hint style="success" %}
You're set! Each time you open a new channel or close an existing one, the monitoring script will automatically save a timestamped copy of the backup file to your backup location(s)
{% endhint %}

## Uninstall

### Uninstall service & user

Ensure you are logged in with the user `admin`, stop, disable autoboot (if enabled), and delete the service

```bash
$ sudo systemctl stop scb-backup
```

```bash
$ sudo systemctl disable scb-backup
```

```bash
$ sudo rm /etc/systemd/system/scb-backup.service
```

### Uninstall script

* &#x20;Delete the script installed

```bash
$ sudo rm /usr/local/bin/scb-backup
```
