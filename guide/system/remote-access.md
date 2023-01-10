---
layout: default
title: Remote access
nav_order: 20
parent: System
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->
{% include include_metatags.md %}

# Remote access

{: .no_toc }

---

We connect to your personal computer by using the Secure Shell.

---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Find your PC

Your Personal Computer is starting and gets a new address from your home network.
Give it a few minutes to come to life.

* On your regular computer, open the Terminal (also known as "command line")
  * On Linux/macOS with a graphical interface, search on the application list, "Terminal" or press the keyboard shortcut `Ctrl + Alt + T`
  * On Windows, search on the application list `cmd`

* Try to ping using the IP assigned to your MiniBolt in the before step

  ```sh
  $ ping 192.168.x.xxx
  PING 192.168.x.xxx (192.168.x.xxx) 56(84) bytes of data.
  64 bytes from 192.168.x.xxx: icmp_seq=1 ttl=64 time=2.44 ms
  64 bytes from 192.168.x.xxx: icmp_seq=2 ttl=64 time=1.75 ms
  64 bytes from 192.168.x.xxx: icmp_seq=3 ttl=64 time=1.61 ms
  64 bytes from 192.168.x.xxx: icmp_seq=4 ttl=64 time=1.58 ms
  ```

* If the `ping` command fails or does not return anything, you need to manually look for your PC.

* You should now be able to reach your PC, with the IP address like `192.168.x.xxx`

## Access with Secure Shell

Now it’s time to connect to the MiniBolt via Secure Shell (SSH) and get to work.
For that, we need an SSH client.

Install and start the SSH client for your operating system:

* Windows, 2 options:

  * Download Putty [64-bit x86](https://the.earth.li/~sgtatham/putty/latest/w64/putty.exe) or [32-bit x86](https://the.earth.li/~sgtatham/putty/latest/w32/putty.exe) version depending on your OS architecture. [Source](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)

    * Start Putty, to the left tree, select "session", in the "Hostname (or IP address)" box, type `temp@192.168.x.xx`, port `22` to the left box.
    * Press the button OPEN, when a "PuTTy security alert" banner appears, press the "Accept" button, and finally type your `password [A]`.

  * Download MobaXterm [Portable edition](https://download.mobatek.net/2232022120824733/MobaXterm_Portable_v22.3.zip) or [Installer edition](https://download.mobatek.net/2232022120824733/MobaXterm_Installer_v22.3.zip) version depending of you want to install it permanently or not. [Source](https://mobaxterm.mobatek.net/)

    * Start MobaXterm, 2 options:

      * If you want to save the session for later: on the top menu, click on "Session" -> "New session" -> Select "SSH".
        * Enter MiniBolt IP address (192.168.x.xx), check "specify username" and enter to the right "temp", keep port "22" selected to the right.
        * Press the button OK, when a "Connexion to..." banner appears, press the "Accept" button, and finally type your `password [A]`.

      * Otherwise, select on the dashboard the "Start local terminal" button and type directly on terminal `ssh temp@192.168.x.xxx`.

* MacOS and Linux:

  * From the native terminal, type: `ssh temp@192.168.x.xxx`
  * Use Putty, simply from the native terminal type `sudo apt install putty` and start it by typing `putty`, follow the same Putty instructions as before for Windows.

📝 Note, connection details:

  * host name: your MiniBolt IP address like: `192.168.x.xxx`
  * port: `22`
  * username: `temp`
  * password: `password [A]`

## The command line

We will work on the command line of the PC, which may be new to you.
Find some basic information below.
It will help you navigate and interact with your PC.

You enter commands and the Pi answers by printing the results below your command.
To clarify where a command begins, every command in this guide starts with the `$` sign. The system response is marked with the `>` character.

Additional comments begin with `#` and must not be entered.

In the following example, just enter `ls -la` and press the enter/return key:

  ```sh
  $ ls -la
  > example system response
  # This is a comment, don't enter this on the command line
  ```

* **Auto-complete commands**:
  You can use the `Tab` key for auto-completion when you enter commands, i.e., for commands, directories, or filenames.

* **Command history**:
  by pressing ⬆️ (arrow up) and ⬇️ (arrow down) on your keyboard, you can recall previously entered commands.

* **Common Linux commands**:
  For a very selective reference list of Linux commands, please refer to the [FAQ](../faq.md) page.

* **Use admin privileges**:
  Our regular user has no direct admin privileges.
  If a command needs to edit the system configuration, we must use the `sudo` ("superuser do") command as a prefix.
  Instead of editing a system file with `nano /etc/fstab`, we use `sudo nano /etc/fstab`.

  For security reasons, service users like "bitcoin" cannot use the `sudo` command.

* **Using the Nano text editor**:
  We use the Nano editor to create new text files or edit existing ones.
  It's not complicated, but saving and exiting are not intuitive.

  * Save: hit `Ctrl-O` (for Output), confirm the filename, and hit the `Enter` key
  * Exit: hit `Ctrl-X`

* **Copy / Paste**:
  If you are using Windows and the PuTTY SSH client, you can copy text from the shell by selecting it with your mouse (no need to click anything), and paste stuff at the cursor position with a right-click anywhere in the ssh window.

  In other Terminal programs, copy/paste usually works with `Ctrl`-`Shift`-`C` and `Ctrl`-`Shift`-`V`.

<br /><br />

---

Next: [System configuration >>](configuration.md)
