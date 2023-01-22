---
layout: default
title: Wireguard VPN
parent: + System
grand_parent: Bonus Section
nav_exclude: true
has_children: false
has_toc: false
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->

## Bonus guide: WireGuard: a simple yet fast VPN

{: .no_toc }

---

Difficulty: Intermediate
{: .label .label-yellow }

Status: Tested MiniBolt
{: .label .label-blue }

---

## Table of contents

{: .no_toc .text-delta }

1. TOC
{:toc}

---

## Acknowledgments

The following guide was derived from contributions by [Pantamis](https://github.com/Pantamis).

[WireGuard](https://www.wireguard.com) is a VPN you can set up to access your MiniBolt from the outside.
It makes it easier to run many more services on your node without exposing them to the public Internet.
It has support on all major computer OSes, and apps for Android and iOS.
The only requirement is to forward a UDP port from your home router to the MiniBolt node.

![https://www.wireguard.com](../../../images/wireguard.png)

## Why using WireGuard and trade-off

A VPN is an encrypted tunnel between two computers over the internet. In our case, the MiniBolt will play the role of the server and you will be able to access your home network from outside with configured client devices.
Depending on the configuration of the client, you can redirect all your internet traffic through the VPN which will hide the true destination from the internet provider your client is currently using (the classical case is public network).
However, your home internet provider (where your MiniBolt is connected) will be able to tell what you are doing, but it will see it coming from your home.

There are several trade-off using a VPN against using Tor:

* The connection with the VPN is a lot faster than using Tor (bitcoin and lnd will still use Tor if already the case)
* WireGuard has an incredible low resource usage. It will automatically go to sleep when not use and instantaneously reconnect if needed whereas Tor has a significant initialization time.
* The attack surface on your home network and MiniBolt is reduced as fewer ports are open on your router.
* However, a VPN is not anonymous, a spy can see that you send encrypted traffic to your home router, but he cannot know what you are doing.
* WireGuard is not censorship-resistant. The encrypted byte headers contain identifiable data which allows to tell that you are using WireGuard VPN.
* You need to open one port on your router if you don't use IPv6, which is more than 0 when you rely only on Tor (notice that this is the case for all services that are not Tor-compatible like lndhub, Joule, Juggernaut....)

![A VPN simulates that you are connected from your home network](../../../images/wireguard-VPN.png)

Copy-pasting command line instructions should work (except when you have to complete with private and public keys). However, you need to know the public URL/IP of your home router where the MiniBolt is connected and to forward a port (51820 if you just copy-paste command lines). The procedure can be different for each router, so you are on your own to do it. If your router does support NAT Loopback, it must be active if you want to be able to connect your VPN client from the local network of the MiniBolt with IPv4 (which is useless in theory but disconnecting the VPN several time at home may be inconvenient if you enable VPN at boot on one client device).

## Prerequisites

Before starting with the installation proper, you need to:

1. Figure out if your Internet Service Provider (ISP) uses [Carrier-Grade NAT](https://superuser.com/questions/713422/how-would-i-test-to-see-if-im-behind-carrier-grade-or-regular-nat).
   If that's the case you have no way of accessing your home network from the outside, and you'll need to phone them asking to put you out of CG-NAT (this means giving your router a dedicated public IP).
   Most ISP simply do this on request or either charge a small fee to allocate a public IP just for you.
2. Figure out the public IP of your home network. If you have a static public IP it'll simplify the setup, but it's not mandatory.
   There are plenty of websites that show you your public IP. One such site is [https://ip.1mahq.com/](https://ip.1mahq.com/)
3. Forward the `51820/UDP` port of your router to the local IP of your MiniBolt.
   This procedure changes from router to router so we can't be very specific, but involves logging into your router's administrative web interface (usually at [http://192.168.1.1](http://192.168.1.1)) and find the relevant settings page.

## Client configuration

Start by visiting [WireGuard's installation page](https://www.wireguard.com/install/) and download and install the relevant version of WireGuard for your OS.
Here, we'll assume your client is a Linux desktop because it the most similar to setting up the server.
On Ubuntu, for instance, you do this by simply installing the `wireguard` package:

  ```sh
  sudo apt install wireguard
  ```

* After that, use the `wg` command to generate a WireGuard key pair:

  ```sh
  $ wg genkey | tee private_key
  GGH/UCK3K9qzd48u8m872azvsdeyaSjs9cVs0pl4fko=
  $ cat private_key | wg pubkey | tee public_key
  pNfWyNJ9WnbMqlLzHxwhvGnZ0/alT18MGy6K0iOxHCI=
  ```

These commands will show both the private and public keys on screen for your convenience, but will also write them in files `private_key` and `public_key`.
Note that each time you run `wg genkey` you get a brand new private key.
However, given the same private key `wg pubkey` will always derive the same public key.

For the next part, you need to become root to be able to create and write the `/etc/wireguard/wg0.conf` file.
When you install the `wireguard` package the directory is created automatically, but it is empty.

  ```sh
  $ sudo su
  $ cd /etc/wireguard
  $ nano wg0.conf
  ```

* Write the following contents to the `wg0.conf` file:

  ```
  [Interface]
  Address = 10.0.0.2/24
  PrivateKey = Client_Private_Key

  [Peer]
  PublicKey = Server_Public_Key
  Endpoint = Your_Public_IP:51820
  AllowedIPs = 10.0.0.1/32
  ```

A few things to note here.

In the `PrivateKey` section you have to fill in the client's private key that we generated in the previous step.

The `PublicKey` of the Peer refers to the public key of MiniBolt. We don't know it because we haven't set it up yet.

In `Endpoint` you need to fill in your router's public IP that you should have found out in the Prerequisites step.
Later on we'll set up a DNS record that will always point to your home's public IP even if your ISP changes it, but for now the raw IP will suffice.

Now that the configuration is written you can delete the `private_key` and `public_key` files from disk, but take note of the client's public key before moving on to configure MiniBolt.

## Server configuration (MiniBolt)

### Configure Firewall

* As user admin, configure the firewall to allow incoming requests

  ```sh
  $ sudo ufw allow 51820/udp comment 'allow WireGuard VPN from anywhere'
  ```

* Update the packages and install WireGuard

  ```sh
  $ sudo apt-get update
  $ sudo apt install wireguard
  ```

* Now we generate another key pair as we did on the client:

  ```sh
  $ wg genkey | tee private_key
  mJFGKxeQqxafyDdLDEDHRml6rDJUs7JZte3uqfJBQ0Q=
  $ cat private_key | wg pubkey | tee public_key
  GOQi4j/yvmu/7f3cRvFZwlXvnWS3gRLosQbjrb13sFY=
  ```

* Again, become root so that you can create and write the `/etc/wireguard/wg0.conf` file.

  ```sh
  $ sudo su
  $ cd /etc/wireguard
  $ nano wg0.conf
  ```

This time write the following:

  ```
  [Interface]
  Address = 10.0.0.1/24
  ListenPort = 51820
  PrivateKey = Server_Private_Key

  [Peer]
  PublicKey = Client_Public_Key
  AllowedIPs = 10.0.0.2/32
  ```

Fill in the server's private key in the `PrivateKey` section and the client's public key in `PublicKey`.

At this point we have defined a Virtual Private network in the `10.0.0.1/24` network range where MiniBolt is at
`10.0.0.1` and your client at `10.0.0.2`.
You could use any other [private IP range](https://en.wikipedia.org/wiki/Private_network#Private_IPv4_addresses).
Here we chose `10.0.0.1/24` because it stands out and is not likely to collide with any other network from your machines.

Now exit root to go back to the admin user and register the newly created WireGuard service with systemd.
This will turn it on permanently, and also start it automatically when MiniBolt reboots.
We won't do this on the client because we want it to be able to connect to the VPN selectively.

  ```sh
  $ exit
  $ sudo systemctl enable wg-quick@wg0.service
  $ sudo systemctl start wg-quick@wg0.service
  ```

Delete the `private_key` and `public_key` files, but take note of the server's public key and go back to the client machine.

## Client configuration (part 2)

Now that the WireGuard server is running and we know its public key we can complete our client setup and test it.

Become root to edit the `/etc/wireguard/wg0.conf` file and fill in the peer's `PublicKey`.

Now, to finally test the VPN connection run this command and try to log in to MiniBolt with SSH using the VPN IP.

  ```sh
  $ wg-quick up wg0
  ```

Expected output:

  ```
  [#] ip link add wg0 type wireguard
  [#] wg setconf wg0 /dev/fd/63
  [#] ip -4 address add 10.0.0.2/24 dev wg0
  [#] ip link set mtu 1420 up dev wg0
  ```

  ```sh
  $ ssh admin@10.0.0.1
  ```

To turn it off use `wg down` instead of `up`

* To check the VPN status use `sudo wg show`

  ```sh
  $ sudo wg show
  ```

Expected output:

  ```
  interface: wg0
    public key: pNfWyNJ9WnbMqlLzHxwhvGnZ0/alT18MGy6K0iOxHCI=
    private key: (hidden)
    listening port: 54124

  peer: GOQi4j/yvmu/7f3cRvFZwlXvnWS3gRLosQbjrb13sFY=
    endpoint: Your_Public_IP:51820
    allowed ips: 10.0.0.1/32
    latest handshake: 10 minutes, 46 seconds ago
    transfer: 49.56 KiB received, 52.36 KiB sent
  ```

  ```sh
  $ wg-quick down wg0
  ```

Expected output:

  ```sh
  [#] ip link delete dev wg0
  ```

## Configure additional clients

For each additional client you need to install the WireGuard software, generate a new key pair for it and write it's configuration file.
This time you'll already know the server's public key from the start.

Mind that each new client has to be allocated a new IP inside the VPN's network range. For instance, a second client could have the IP `10.0.0.3`,
as `10.0.0.1` and `10.0.0.2` are already taken by the server and the first client, respectively.

For instance, in Windows the WireGuard program already generates the key pair and writes a stub for the configuration just by clicking "Create new Tunnel".

![WireGuard Windows Client](../../../images/wireguard-windows.png)

## Configure additional clients (MiniBolt)

Each time you want to add a new client you just need to append a new `[Peer]` section in MiniBolt's `/etc/wireguard/wg0.conf` configuration file:

  ```
  [Peer]
  PublicKey = A_New_Client_Public_Key
  AllowedIPs = 10.0.0.3/32
  ```

After that you need to restart the WireGuard server for the changes to take effect. Mind that if you logged it to MiniBolt through WireGuard from
an already configured client this command will kick you out of MiniBolt temporarily:

  ```sh
  $ sudo systemctl restart wg-quick@wg0.service
  ```

## Set up Dynamic DNS

TODO

## Tip for configuring a mobile client

TODO























------------------


# Proposal: Remove everything below

Paste and complete the following:

  ```sh
  [Interface]
  Address = 10.42.2.1/24
  PrivateKey = <insert server_private_key>
  ListenPort = 51820
  PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
  PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

  [Peer]
  PublicKey = <insert client_public_key>
  AllowedIPs = 10.42.2.2/32
  ```

We need to understand what is happenning here, so let us explain what each line mean so that we know how to change them if you need:

* `[Interface]` is the section where we configure the interface on this computer (the MiniBolt)
* `Address` is field with any IPs range `/24` for local network.  `10.42.2.1/24` means that the VPN server local IP address is `10.42.2.1`  and it will process all the IPs of the local network of the RapiBolt of the form `10.42.2.*` where `*` can be any number between 2 and 255.  They are the local IPs of the subnet of your local network that contain the VPN server and its clients.
**It MUST be different from the range of IPs used by the router for the home network.** (Do not set it to 192.168.1.1/24 if these IPs are used by your router already to find the MiniBolt for example).
* `PrivateKey` is the private key used by the server. You must set it with the result of `# cat server_private_key` you noted before
* `ListenPort = 51820` is the port on which the VPN server is listening. **This is the port you must let open on your router** (and it should be the only one once WireGuard works)
* The next two lines allow clients connected to the VPN server to access your home network (and other services of your Raspberry).
 If your MiniBolt is connected by the **WIFI you must change `eth0` with `wlan0`**
* `[Peer]` is the section where you specified the peer that are allowed to use the VPN. You must add one section for each peer and it should start with this header.
* `PublicKey` is the public key of the current peer. You must set it with the result of `# cat client_public_key` you noted before
* `AllowedIPs` must be the local IP of the client on the VPN network. It must be inside VPN network range specified in `Address` field and different from VPN server IP (which is `10.42.2.1` in this example). `\32` indicates it is not a range of IP.

The example above should work just by completing private and public keys but **it is highly recommanded to not use the same value for private IPs than the ones in this public guide** (you can change 42.2 part of the IP range 10.42.2.* by anything else or used IP in range specified [here](https://en.wikipedia.org/wiki/Private_network))

Save and quit text editor. Finally, we need to setup IP forwarding on the MiniBolt:

  ```sh
  $ nano /etc/sysctl.conf
  ```

Uncomment the line "net.ipv4.ip_forward=1" in text editor and save/quit.

We start automatically WireGuard at boot:

  ```sh
  $ systemctl enable wg-quick@wg0
  $ chown -R root:root /etc/wireguard/
  $ chmod -R og-rwx /etc/wireguard/*
  ```

We must also enable connection to the VPN port of the MiniBolt by `ufw`, change `51820` by what was set as `ListenPort` in the server configuration file:

  ```sh
  $ sudo ufw allow 51820/udp comment 'allow WireGuard VPN from anywhere'
  ```

You may reboot your MiniBolt to apply change correctly (don't forget to stop lnd and bitcoin properly). If it bother you too much, you can also start WireGuard and check it has started properly:

  ```sh
  $ wg-quick up wg0
  $ wg show
  ```

It should return:

  ```sh
  > interface: wg0
  >   public key: <server_public_key>
  >   private key: (hidden)
  >   listening port: 51820
  ```

## Communicate with the VPN server

We need to setup port forwarding on your router if our clients cannot use IPv6 so that we can send encrypted packet to the MiniBolt from outside. There is no general method as it depends of your router.
You need to forward the port (here 51820) to the local IP addres of the MiniBolt. You can obtain it by running `ifconfig` and use the first IP address of the interface `eth0` or `wlan0` or [here](https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#connecting-to-the-raspberry-pi).
You may need to set a static local IP address to the MiniBolt on your router (DHCP settings). More information [here](https://engineerworkshop.com/blog/connecting-your-raspberry-pi-web-server-to-the-internet/#port-forwarding)

You must install WireGuard on devices you want to connect to your local network through VPN. Once again you have to create a WireGuard interface that will route a part of your traffic to the VPN server.

The configuration file must be created in `/etc/wireguard` folder on Linux clients, use the `add empty tunnel` option for Windows clients, `/usr/local/etc/wireguard` for mac. On Android, install the application and use "+" button.

Name your file `minibolt.conf` (`minibolt` will be the name of the interface on the client device) and complete the file as such:

  ```sh
  [Interface]
  Address = 10.42.2.2/32
  PrivateKey = <insert client_private_key>

  [Peer]
  PublicKey = <insert server_public_key>
  Endpoint = <insert vpn_server_address>:51820
  AllowedIPs = <to_be_completed>
  ```

Again, we need to explain what it means so that you know how to change the value if needed.

* `[Interface]` is the section where we set the identity of the client in VPN subnet.
* `Address` is the IP address of this client in the VPN subnet. It must match the one specified in `AllowedIP` field in `[Peer]` section of the configuration file we completed in the Raspberry Pi.
* `PrivateKey` is the result of `# cat client_private_key` you noted before
* `[Peer]` is the section where we declare the identity of the server and what we send to it.No matter how many clients there is, we need to declare only the server on each client.
* `PublicKey` is the result of `# cat server_public_key` you noted before
* `Endpoint` is the public URL or IP of your router (prefer an URL over IPv4). You must find it on the menu of your router. Change `51820` if you decide to open/use another port for the VPN server. If you want to use IPv6, you can find the complete IPv6 of the MiniBolt with `ifconfig` (if your client is not at a fixed place, it is possible that IPv6 may not be enable on other networks it will use so the VPN won't work, you can add a comment with IPv4 address to change th `Endpoint` easly just in case using `#` at the beginning of the line in the file).

If you made it until now, congratulation ! We're almost there !

We need to set up `AllowedIPs`. You have several possibilities and it depends of your needs, you may use two configuration files to change this setting quickly:

1. You can set `AllowedIPs = 0.0.0.0/0, ::/0` in this case, all the internet traffic of the client is encrypted and send to the VPN server. This is useful to protect yourself on your phone when using a publicnetwork for example. You won't notice anything if your home network is working well except maybe a slightly higher latency.
2. You can set `AllowedIPs = 10.42.2.0/24, <local_IP_MiniBolt>/32` where you can get the local IP of the MiniBolt with `ifconfig` and look at the first IP in `eth0` or `wlan0` interface or [here](https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#connecting-to-the-raspberry-pi). The VPN is used on the client only when you try to access the MiniBolt with its local IP from outside.
3. You can set `AllowedIPs = 10.42.2.0/24, <local_IP_range>` where `<local_IP_range> is the range of IP of you local home network. Often it should be something like` 10.0.0.0/24` or `192.168.1.0/24`. The VPN is used when you try to access to any computer in your home network as if you where there.

The IPs `10.42.2.0/24` must be the ones you set for the VPN subnet in server interface.
Start the tunnelling, on linux you must run (or the button "Connect" on the GUI)

  ```sh
  $ sudo wg-quick up minibolt
  ```

(and `sudo wg-quick down minibolt` to stop the tunnelling)

## Test and eventual problems

From the client, ping the VPN server (replace IP with the one you use in `wg0.conf`), on linux command line:

  ```sh
  $ ping 10.42.2.1
  ```

or monitor the VPN (you should see you have the VPN server as a peer and you must have received packets from him)

  ```sh
  $ sudo wg show
  ```

If you received some packets, it works !
If not, check port forwarding is working correctly.
If not and you try it from the same local network as the MiniBolt, try to ping the minibolt using its local address (you got it [before](https://stadicus.github.io/RaspiBolt/raspibolt_20_pi.html#connecting-to-the-raspberry-pi)).
If nothing happen (ping returns nothing) and moreover if you seems to not be able to connect to your MiniBolt with ssh from your local network when tunnelling is up, the explanation may be that you need to set the NAT Loopback on your router.
If your router doesn't allow NAT Loopback then use the public in IPv6 in the field `Endpoint`.
If your router doesn't allow/you don't want to use IPv6 then stop the tunnelling (`sudo wg-quick down minibolt` in Linux command line) on your client, you can only test your VPN from outside.
A good way to test your VPN from home is to use your smartphone on 4G with internet data (it will work on WIFI only if the MiniBolt is connected in ethernet) with the [WireGuard application](https://play.google.com/store/apps/details?id=com.wireguard.android). If you can access services like electrs server or blockexplorer from your phone without Tor with local IP of the MiniBolt, the VPN works !

## Easy configuration on smartphone

Instead of filling the form on the WireGuard app on the smartphone, you can use a qr code.
Completed the configuration file on the MiniBolt or on the computer and use

  ```sh
  $ qrencode -t ansiutf8 < /etc/wireguard/clients/mobile.conf
  ````

to print a qr code in command line that you can scan with the WireGuard app. Install `qrencode` with `apt install qrencode` if necessary.

## Adding more clients

For each new clients you have to:

1. Generate a key pair

  ```sh
  $ wg genkey | tee client_private_key | wg pubkey > client_public_key
  $ cat client_private_key
  $ cat client_public_key
  ```

1. Add a `[Peer]` section to server configuration file, you must use the previously generated public key and choose a new local IP for the client (incrementing last number is fine):

  ```sh
  [Peer]
  PublicKey = <insert client_public_key>
  AllowedIPs = 10.42.2.3/32
  ```

1. Create a configuration file on your client with the same local IP and using the generated private key:

  ```sh
  [Interface]
  Address = 10.42.2.3/32
  PrivateKey = <insert client_private_key>

  [Peer]
  PublicKey = <insert server_public_key>
  Endpoint = <insert vpn_server_address>:51820
  AllowedIPs = <to_be_completed>
  ```

complete the fields `AllowedIPs` as you think you will need for this client. You may replicate the configuration file with a different name and value for `AllowedIPs`to change quickly the interface used to redirect your internet traffic.

**You can't use two different clients with the same key pair at the same time**

## Clean up

If everything works fine, you can delete the files containing the key pairs of server and clients, except the public key of the server that may be useful when adding new clients.
You can now close all ports of your home router except the one used for the VPN (51820 for our example)
Enjoy all the advantages of a VPN on your node ! You can now access your block explorer or RTL by typing in a browser the local IP address of the MiniBolt with the port associated to each from anywhere in the world (where WireGuard is not censored...) !
