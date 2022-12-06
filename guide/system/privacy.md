---
layout: default
title: Privacy
nav_order: 50
parent: System
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->
{% include include_metatags.md %}

# Privacy

{: .no_toc }

---

We configure Tor and I2P to run your node anonymously.

![Tor logo](../../images/tor-logo.png)![I2P](../../images/i2pd.png)

---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

Running your own Bitcoin and Lightning node at home makes you a direct, sovereign peer on the Bitcoin network.
However, if not configured without privacy in mind, it also tells the world that there is someone with Bitcoin at that address.

True, it's only your IP address that is revealed, but using services like [iplocation.net](https://www.iplocation.net){:target="_blank"}, your physical address can be determined quite accurately.
Especially with Lightning, your IP address would be widely used.
We need to make sure that you keep your privacy.

We'll also make it easy to connect to your node from outside your home network as an added benefit.

## Tor Project

We use Tor, a free software built by the [Tor Project](https://www.torproject.org){:target="_blank"}.
It allows you to anonymize internet traffic by routing it through a network of nodes, hiding your location and usage profile.

It is called "Tor" for "The Onion Router": information is routed through many hops and encrypted multiple times.
Each node decrypts only the layer of information addressed to it, learning only the previous and the next hop of the whole route. The data package is peeled like an onion until it reaches the final destination.

### Installation

Log in to your MiniBolt via SSH as user "admin" and install Tor.

* Install apt-transport-https

  ```sh
  $ sudo apt install apt-transport-https
  ```

* Create a new file called `tor.list`
  
  ```sh
  $ sudo nano /etc/apt/sources.list.d/tor.list
  ```

* Add the following entries. Save and exit

  ```sh
  deb     [arch=amd64 signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org jammy main
  deb-src [arch=amd64 signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org jammy main
  ```

* Then up to `"root"` user temporarily to add the gpg key used to sign the packages by running the following command at your command prompt. Return to `admin` using `exit` command

  ```sh
  $ sudo su
  $ wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null
  $ exit
  ```

* Install tor and tor debian keyring

   ```sh
   $ sudo apt update
   $ sudo apt install tor deb.torproject.org-keyring
   ```

* Check Tor has been correctly installed

  ```sh
  $ tor --version
  > Tor version 0.4.7.10.
  [...]
  ```

### Configuration

Bitcoin Core will communicate directly with the Tor daemon to route all traffic through the Tor network.
We need to enable Tor to accept instructions through its control port, with the proper authentication.

* Modify the Tor configuration by uncommenting (removing the `#`) or adding the following lines.
Save and exit

  ```sh
  $ sudo nano /etc/tor/torrc
  ```

  ```sh
  # uncomment:
  ControlPort 9051
  CookieAuthentication 1
  # add:
  CookieAuthFileGroupReadable 1
  ```

* Reload Tor configuration to activate the modifications

  ```sh
  $ sudo systemctl reload tor
  ```

* Ensure that the Tor service is working and listening at the default ports `9050` and `9051`.

  ```sh
  $ sudo ss -tulpn | grep LISTEN | grep tor
  ```

Expected output:

  ```sh
  tcp   LISTEN 0      4096             127.0.0.1:9050       0.0.0.0:*    users:(("tor",pid=795,fd=6))
  tcp   LISTEN 0      4096             127.0.0.1:9051       0.0.0.0:*    users:(("tor",pid=795,fd=7))
  ```

* Check the systemd journal to see Tor real time updates output logs.
  
  ```sh
  $ sudo journalctl -f -u tor@default
  ```

Not all network traffic is routed over the Tor network.
But we now have the base to configure sensitive applications to use it.

⚠️**Troubleshooting note:** if you have problems with the Tor connection, is possible that the set of entry guards is overloaded, delete the file called "state" in your Tor directory, you will be forcing Tor to select an entirely new set of entry guards next time it starts.

* Stop Tor

  ```sh
  $ sudo systemctl stop tor
  ```

* Delete the file called "state" in your Tor directory

  ```sh
  $ sudo rm /var/lib/tor/state
  ```

* Start Tor again

  ```sh
  $ sudo systemctl start tor
  ```

If your new set of entry guards still produces the stream error, try connecting to the internet using a cable if you're using Wireless. If that doesn't help, I'd suggest downloading Wireshark and seeing if you're getting drowned in TCP transmission errors for non-Tor traffic. If yes, your ISP is who you need to talk to. If not, try using obfs bridges and see if that helps.

## I2P Project

[I2P](https://geti2p.net/en/){:target="_blank"} is a universal anonymous network layer. All communications over I2P are anonymous and end-to-end encrypted, participants don't reveal their real IP addresses. I2P allows people from all around the world to communicate and share information without restrictions.

I2P client is a software used for building and using anonymous I2P networks. Such networks are commonly used for anonymous peer-to-peer applications (filesharing, cryptocurrencies) and anonymous client-server applications (websites, instant messengers, chat-servers).

We are to use [i2pd](https://i2pd.readthedocs.io/en/latest/) (I2P Daemon), a full-featured C++ implementation of the I2P client as a Tor network complement.

### Installation

* Ensure that you are logged with user "admin" and add i2p repository

  ```sh
  $ wget -q -O - https://repo.i2pd.xyz/.help/add_repo | sudo bash -s -
  ```

* Install i2pd as any other software package

  ```sh
  $ sudo apt update
  $ sudo apt install i2pd
  ```

* Check i2pd has been correctly installed

  ```sh
  $ i2pd --version
  > i2pd version 2.44.0 (0.9.56)
  [...]
  ```

### Configuration

* Configure i2pd to not to relay any public I2P traffic and only permit I2P traffic from Bitcoin Core, uncomment `"notransit=true"`

  ```sh
  $ sudo nano /var/lib/i2pd/i2pd.conf
  ```

  ```sh
  notransit = true
  ```

* Restart the service to apply changes

  ```sh
  $ sudo systemctl restart i2pd
  ```
  
* Enable autoboot on start

  ```sh
  $ sudo systemctl enable i2pd
  ```

* Check the service started and the correct autoboot enabled

  ```sh
  $ sudo systemctl status i2pd
  ```

Expected output, find *"enabled"* and *"Started"* labels:

  ```sh
  * i2pd.service - I2P Router written in C++
      Loaded: loaded (/lib/systemd/system/i2pd.service; enabled; vendor preset: enabled)
      Active: active (running) since Thu 2022-08-11 15:35:54 UTC; 3 days ago
        Docs: man:i2pd(1)
              https://i2pd.readthedocs.io/en/latest/
    Main PID: 828 (i2pd)
        Tasks: 14 (limit: 9274)
      Memory: 56.1M
          CPU: 33min 28.265s
      CGroup: /system.slice/i2pd.service
              -175224 /usr/sbin/i2pd --conf=/etc/i2pd/i2pd.conf --tunconf=/etc/i2pd/tunnels.conf --tunnel...
  Sep 27 18:54:57 minibolt systemd[1]: Starting I2P Router written in C++...
  Sep 27 18:54:57 minibolt systemd[1]: Started I2P Router written in C++.
  [...]
  ```

* Ensure that i2pd service is working and listening at the default ports

  ```sh
  $ sudo ss -tulpn | grep LISTEN | grep i2pd 
  ```

Expected output:

  ```sh
  tcp   LISTEN 0      4096            0.0.0.0:23570       0.0.0.0:*    users:(("i2pd",pid=827,fd=17))
  tcp   LISTEN 0      4096           127.0.0.1:4444       0.0.0.0:*    users:(("i2pd",pid=827,fd=29))
  tcp   LISTEN 0      4096           127.0.0.1:7070       0.0.0.0:*    users:(("i2pd",pid=827,fd=22))
  tcp   LISTEN 0      4096           127.0.0.1:4447       0.0.0.0:*    users:(("i2pd",pid=827,fd=30))
  tcp   LISTEN 0      4096           127.0.0.1:7656       0.0.0.0:*    users:(("i2pd",pid=827,fd=38))
  tcp   LISTEN 0      4096           127.0.0.1:6668       0.0.0.0:*    users:(("i2pd",pid=827,fd=34))
  ```

* See “i2p” in action by monitoring its log file. Exit with Ctrl-C

  ```sh
  $ sudo tail -f /var/log/i2pd/i2pd.log
  ```

## For the future: upgrade Tor and I2P

The latest release can be found on the [official Tor web page](https://gitweb.torproject.org/tor.git/plain/ChangeLog) or on the [unofficial GitHub page](https://github.com/torproject/tor/tags) and for I2P on the [PPA page](https://launchpad.net/~purplei2p/+archive/ubuntu/i2pd). To upgrade simply type this command:

  ```sh
  $ sudo apt update && sudo apt upgrade
  ```

## Extras

### SSH remote access through Tor (optional)

If you want to log into your MiniBolt with SSH when you're away, you can easily do so by adding a Tor hidden service.
This makes "calling home" very easy, without the need to configure anything on your internet router.

#### SSH server

* Add the following three lines in the "location-hidden services" section of the `torrc` file.
Save and exit

  ```sh
  $ sudo nano /etc/tor/torrc
  ```

  ```sh
  ############### This section is just for location-hidden services ###
  # Hidden Service SSH server
  HiddenServiceDir /var/lib/tor/hidden_service_sshd/
  HiddenServiceVersion 3
  HiddenServicePort 22 127.0.0.1:22
  ```

* Reload Tor configuration and look up your Tor connection address

  ```sh
  $ sudo systemctl reload tor
  $ sudo cat /var/lib/tor/hidden_service_sshd/hostname
  > abcdefg..............xyz.onion
  ```

* Save the Tor address in a secure location, e.g., your password manager.

#### SSH client

You also need to have Tor installed on your regular computer where you start the SSH connection.
Usage of SSH over Tor differs by client and operating system.

A few examples:

* **Windows**: configure PuTTY as described in this guide [Torifying PuTTY](https://gitlab.torproject.org/legacy/trac/-/wikis/doc/TorifyHOWTO/Putty){:target="_blank"} by the Tor Project.

  * **Note:** If you are using PuTTy and fail to connect to your PC by setting port 9050 in the PuTTy proxy settings, try setting port 9150 instead. When Tor runs as an installed application instead of a background process it uses port 9150.

* **Linux**: use `torify` or `torsocks`.
  Both work similarly; just use whatever you have available:

  ```sh
  $ torify ssh admin@abcdefg..............xyz.onion
  ```

  ```sh
  $ torsocks ssh admin@abcdefg..............xyz.onion
  ```

* **macOS**: Using `torify` or `torsocks` may not work due to Apple's *System Integrity Protection (SIP)* which will deny access to `/usr/bin/ssh`.

  To work around this, first make sure Tor is installed and running on your Mac:

  ```sh
  $ brew install tor && brew services start tor
  ```

  You can SSH to your PC "out of the box" with the following proxy command:

  ```sh
  $ ssh -o "ProxyCommand nc -X 5 -x 127.0.0.1:9050 %h %p" admin@abcdefg..............xyz.onion
  ```

  For a more permanent solution, add these six lines below to your local SSH config file. Choose any HOSTNICKNAME you want, save and exit.

  ```sh
  $ sudo nano .ssh/config
  ```

  ```sh
  Host HOSTNICKNAME
    Hostname abcdefg..............xyz.onion
    User admin
    Port 22
    CheckHostIP no
    ProxyCommand /usr/bin/nc -x localhost:9050 %h %p
  ```

  Restart Tor

  ```sh
  $ brew services restart tor
  ```

  You should now be able to SSH to your PC with

  ```sh
  $ ssh HOSTNICKNAME
  ```

<br /><br />

---

Next: [Bitcoin >>](../bitcoin/index.md)