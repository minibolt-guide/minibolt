---
layout: default
title: Login with SSH keys
parent: + System
grand_parent: Bonus Section
nav_exclude: true
has_toc: false
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->

# Bonus guide: Login with SSH keys

{: .no_toc }

---

One of the best options to secure the sensitive SSH login is to disable passwords altogether and require an SSH key certificate.
Only someone with physical possession of the private certificate key can log in.

Difficulty: Medium
{: .label .label-yellow }

Status: Tested MiniBolt
{: .label .label-blue }

![SSH keys](../../../images/SSH-keys.png)

---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Preparations

### **Generate SSH keys on Windows**

* On your regular computer, download Puttygen [64-bit x86](https://the.earth.li/~sgtatham/putty/latest/w64/puttygen.exe) or [32-bit x86](https://the.earth.li/~sgtatham/putty/latest/w32/puttygen.exe) version depending on your OS architecture and start it. Also, you can download [MobaXterm](https://mobaxterm.mobatek.net/download-home-edition.html) start it and use the "MobaKeyGen (SSH key generator)" integrated tool in the "Tools" submenu

* Click on the "Generate" button and move the mouse over the window until the progress is finished

* Assign a key passphrase (recommended), to encrypt the private key locally, use `password [A]` for example

* Click on:
  * "Save public key", and give it a name, eg. minibolt_SSH_pubkey.txt
  * "Save private key", and give it a name, eg. minibolt_SSH_privkey (Keep this safe!)

### **Generate SSH keys on Linux or macOS**

* In the terminal on your regular computer, first, check if the keys already exist

  ```sh
  $ ls -la ~/.ssh/*.pub
  ```

* If files are listed, your public key should be named something like `id_rsa.pub`. If one of these files already exists, skip the next step.

* If none of those files exist, or you get a "No such file or directory" error, create a new public/private key pair:

  ```sh
  $ ssh-keygen -t rsa -b 2048
  ```

  When you're prompted to "Enter a file in which to save the key", press Enter to use the default file location.
  Optionally, for maximum security, enter a key passphrase to protect your key, and use `password [A]`.

* The public key now needs to be copied to the PC.

  Use the command `ssh-copy-id`, which stores your public key on the remote machine (and creates files and directories, if needed).
  You will be prompted for your SSH login password once. If fails you can try `admin@192.168.x.xxx` instead

  ```sh
  $ ssh-copy-id admin@minibolt.local
  ```

💡 If you are on macOS and encounter an error, you might need to install `ssh-copy-id` first by running the following command on your Mac's command line:

  ```sh
  $ brew install ssh-copy-id
  ```

## Import SSH pubkey to MiniBolt node

### **From your regular Windows PC**

* Login with "admin" user on MiniBolt and create a new folder at home called ".ssh". If already exists, skip the next step.

 ```sh
 $ mkdir .ssh
 ```

* Limit permissions for reading, writing, and executing only to the user admin

  ```sh
  $ chmod 700 .ssh
  ```

* Create a file called "authorized_keys" and paste the content information of the "minibolt_SSH_pubkey.txt" file generated in the [Windows step before](#generate-ssh-keys-on-windows)

  ```sh
  $ nano .ssh/authorized_keys
  ```

e.g:

  ```sh
  ssh-rsa AAAAB3N........
  ```

* Limit permissions for reading and writing only to the user admin

  ```sh
  $ chmod 600 authorized_keys
  ```

### **From your regular Linux PC**

* Login with "admin" user on MiniBolt and create a new folder at home called `".ssh"`. If already exists, skip the next step.

 ```sh
 $ mkdir .ssh
 ```

* Limit permissions for reading, writing, and executing only to the user admin

  ```sh
  $ chmod 700 .ssh
  ```

* Create a file called "authorized_keys" on it and paste the content information of the "id_rsa.pub" file generated in the [Linux or macOS step before](#generate-ssh-keys-on-linux-or-macos)

  ```sh
  $ nano .ssh/authorized_keys
  ```

e.g:

  ```sh
  ssh-rsa AAAAB3N........
  ```

* Limit permissions for reading and writing only to the user admin

  ```sh
  $ chmod 600 .ssh/authorized_keys
  ```

### **From GitHub keyserver**

* On your regular computer, access to "GPG and SSH keys" section of your [GitHub account](https://github.com/settings/keys), if you don't have an account [create one](https://github.com/signup)

* Click on the "new SSH key" button, type a title e.g SSH_keys_MiniBolt, select Key type "Authentication key", and paste on the "Key" section the SSH pub key generated in the [preparations [section](#preparations) depending on the regular computer OS

* Login with the "admin" user on MiniBolt and create a new folder at home called ".ssh". If already exists, skip the next step.

  ```sh
  $ mkdir .ssh
  ```

* Limit permissions for reading, writing, and executing only to the user admin

  ```sh
  $ chmod 700 .ssh
  ```

* Enter the ".ssh" folder

  ```sh
  $ cd .ssh
  ```

* Import your SSH GitHub keys replacing `<username>` with the GitHub username (that appears in your profile section)

  ```sh
  $ curl https://github.com/<username>.keys >> authorized_keys
  ```

* Ensure that your SSH keys have been imported correctly in "authorized_keys" file, and press `Ctrl-X` to exit

  ```sh
  $ nano authorized_keys
  ```

* Limit permissions for read and write only to the user admin

  ```sh
  $ chmod 600 authorized_keys
  ```

## Connect to MiniBolt through SSH keys

### **Linux or macOS command line**

* From the Terminal, use the native command

  ```sh
  $ ssh -i /home/<user>/.ssh/privkey admin@minibolt.local
  ```

⚠️ Attention: This command only works if you generated the SSH keys [on Linux or macOS](#generate-ssh-keys-on-linux-or-macos) with OpenSSH terminal method, not Putty or MobaXterm generation methods.

### **Putty Linux/Windows**

* On your regular computer, download Putty [64-bit x86](https://the.earth.li/~sgtatham/putty/latest/w64/putty.exe) or [32-bit x86](https://the.earth.li/~sgtatham/putty/latest/w32/putty.exe) version depending on your OS architecture and start it.

* To automatically connect and log in to your server you need to add the Private Key to the Putty client. Then go to the left Category menu, select SSH –> Auth -> Credentials, on "Private key file for authentication" hit the "Browse" button, search and add your Private Key file.

* To the left tree, select "session", in the "Hostname (or IP address)" box, type `admin@minibolt.local` or `admin@192.168.x.xx`, left port `22` to the right box. Click on `Open`. If you selected a key passphrase in [preparations](#preparations) section, enter it. That’s it! Now you can automatically securely connect to your remote SSH server with Putty client by hitting the Open button without the need to enter passwords.

### **MobaXterm Windows**

* On your regular computer, download MobaXterm [Portable edition](https://download.mobatek.net/2232022120824733/MobaXterm_Portable_v22.3.zip) or [Installer edition](https://download.mobatek.net/2232022120824733/MobaXterm_Installer_v22.3.zip) version depending of you want to install it permanently or not.

* Start MobaXterm, on the top menu, click on Session -> New session -> Select SSH

* Enter in remote host, "minibolt.local" or your MiniBolt IP address (192.168.x.xx), check to "specify username" and enter to the right "admin", keep port "22" selected to the right

* To automatically connect and login to your server you need to add the Private Key to the MobaXterm client, select the "Advanced SSH settings" tab, check "Use private key" and click on the icon to the right form shaped like a document and select your Private Key file

* Click on the "OK" button and that’s it! Now you can automatically securely connect to your remote SSH server with Putty client by hitting the "Open" button without the need to enter passwords.

### **Disable password login**

* Log in to the MiniBolt as "admin" using SSH with your SSH key.
  You shouldn't be prompted for the admin's password anymore.

* Edit the ssh configuration file `/etc/ssh/sshd_config` by uncommenting the following options and setting their value to `no`

  ```sh
  $ sudo nano /etc/ssh/sshd_config --linenumbers
  ```

  ```
  # uncomment and change the line to "no"
  PermitRootLogin no
  # change the line to "no"
  UsePAM no
  # change the line to "no"
  PasswordAuthentication no
  ```

* Test this barebone SSH configuration. If you see no output to the next command, that is OK. If you see something like "/etc/ssh/sshd_config line XX: unsupported option "XXX" that means something is incorrect.

  ```sh
  $ sudo sshd -t
  ```

* Restart the SSH daemon

  ```sh
  $ sudo systemctl restart sshd
  ```

* Type `exit` or `logout` to finish the session

* Log in again with user "admin"

You can no longer log in with a password.
User "admin" is the only user that has the necessary SSH keys, no other user can log in remotely.
You can follow the guide where you left it by clicking [here](../../system/configuration.md#system-update)

🚨 **Backup your SSH keys!**

You will need to attach a screen and keyboard to your PC if you lose them.

### **Disable admin password request (optional -caution!)**

⚠️ Attention: This could be a security risk, is not recommended to disable the admin password to avoid a possible and hypothetical attacker could gain complete control of the node in case of intrusion, if you do it, act at your own risk.

* Ensure you are logged in with user admin, edit the next file

  ```sh
  $ sudo visudo
  ```

* Add the next line at the end of the file. Save and exit

  ```
  admin ALL=(ALL) NOPASSWD:ALL
  ```

<br /><br />

---

<< Back: [+ System](index.md)
