---
title: Ride the Lightning
parent: + Lightning
grand_parent: Bonus Section
nav_exclude: true
has_toc: false
---

# Ride The Lightning

We install [Ride The Lightning](https://github.com/Ride-The-Lightning/RTL), a powerful web interface to manage your Lightning node.

{% hint style="warning" %}
Difficulty: Medium
{% endhint %}

{% hint style="warning" %}
Status: Not tested MiniBolt
{% endhint %}

![](../../images/rtl-homepage.png)

## Preparations

### Check Node.js + NPM

*   Node.js + NPM should have been installed for the [BTC RPC Explorer](../../guide/bonus/bitcoin/blockchain-explorer.md). We can check our version of Node.js with the user "admin"

    ```sh
    $ node -v
    ```

**Example** of expected output:

```
> v16.14.2
```

* If the version is v14.15 or above, you can move to the next section. If Node.js is not installed, follow this [Node.js + NPM bonus guide](../../guide/bonus/bonus/system/nodejs-npm.md) to install it.

### Firewall & reverse proxy

In the [Security section](../../guide/bonus/raspberry-pi/security.md#prepare-nginx-reverse-proxy), we already set up NGINX as a reverse proxy. Now we can add the RTL configuration.

*   With user "admin", enable NGINX reverse proxy to route external encrypted HTTPS traffic internally to RTL

    ```sh
    $ sudo nano /etc/nginx/sites-enabled/rtl-reverse-proxy.conf
    ```

    ```sh
    server {
      listen 4001 ssl;
      error_page 497 =301 https://$host:$server_port$request_uri;

      location / {
        proxy_pass http://127.0.0.1:3000;
      }
    }
    ```
*   Test NGINX configuration

    ```sh
    $ sudo nginx -t
    ```
*   Reload Nginx to apply configuration

    ```sh
    $ sudo systemctl reload nginx
    ```
*   Configure firewall to allow incoming HTTPS requests

    ```sh
    $ sudo ufw allow 4001/tcp comment 'allow Ride The Lightning SSL from anywhere'
    ```

## Ride the Lightning

### Installation

We do not want to run Ride the Lightning alongside bitcoind and lnd because of security reasons. For that, we will create a separate user and we will be running the code as the new user. We are going to install Ride the Lightning in the home directory since it doesn’t take up much space and doesn’t use a database.

*   With user "admin", create a new user, copy the LND credentials and open a new session

    ```sh
    $ sudo adduser --disabled-password --gecos "" rtl
    ```

    ```sh
    $ sudo cp /data/lnd/data/chain/bitcoin/mainnet/admin.macaroon /home/rtl/admin.macaroon
    ```

    ```sh
    $ sudo chown rtl:rtl /home/rtl/admin.macaroon
    ```

    ```sh
    $ sudo su - rtl
    ```
*   Download the PGP keys that are used to sign the software release

    ```sh
    $ curl https://keybase.io/suheb/pgp_keys.asc | gpg --import
    ```

Expected output:

```
> gpg: key 00C9E2BC2E45666F: public key "saubyk (added uid) <39208279+saubyk@users.noreply.github.com>" imported
```

*   Retrieve the source code repository, check for the latest release and verify the code signature

    ```sh
    $ git clone https://github.com/Ride-The-Lightning/RTL.git
    ```

    ```sh
    $ cd RTL
    ```

    ```sh
    $ git tag | grep -E "v[0-9]+.[0-9]+.[0-9]+$" | sort --version-sort | tail -n 1
    ```

**Example** expected output:

```
> v0.13.4
```

```sh
$ git checkout v0.13.4
```

```sh
$ git verify-tag v0.13.4
```

Expected output:

```
> gpg: Signature made Tue 22 Nov 2022 03:04:55 CET
> gpg:                using RSA key 3E9BD4436C288039CA827A9200C9E2BC2E45666F
> gpg: Good signature from "saubyk (added uid) <39208279+saubyk@users.noreply.github.com>" [unknown]
> gpg:                 aka "Suheb <39208279+saubyk@users.noreply.github.com>" [unknown]
> gpg: WARNING: This key is not certified with a trusted signature!
> gpg:          There is no indication that the signature belongs to the owner.
> Primary key fingerprint: 3E9B D443 6C28 8039 CA82  7A92 00C9 E2BC 2E45 666F
```

*   Now install RTL through the Node Package Manager (NPM). Downloading all dependencies can sometimes be very slow, so be patient and let the process run its course.

    ```sh
    $ npm install --omit=dev
    ```

The installation can take some time, and can hang on a single package for a long time. If that happens, just be patient and wait a bit longer. If anything's wrong, it will time out sooner or later.

*   Also, there might be a lot of confusing output. If you do something similar to the following at the end, the installation was successful:

    ```
    > [...]
    > added 362 packages, and audited 363 packages in 12m
    >
    > 24 packages are looking for funding
    >   run `npm fund` for details
    >
    > found 0 vulnerabilities
    ```

### Configuration

Now we take the sample configuration file and add change it to our needs.

*   Copy the sample config file, and open it in the text editor.

    ```sh
    $ cp Sample-RTL-Config.json ./RTL-Config.json
    ```

    ```sh
    $ nano RTL-Config.json
    ```
*   Set `password [E]` to access the RTL web interface. This should be a dedicated password not used anywhere else.

    ```
      "multiPass": "YourPassword[E]"
    ```
*   Specify the values where RTL can find the authentication macaroon file and the LND configuration

    ```
      "macaroonPath": "/home/rtl"
      "configPath": "/data/lnd/lnd.conf"
    ```
*   Change `localhost` to `127.0.0.1` on the following lines to avoid errors

    ```
      "lnServerUrl": "https://127.0.0.1:8080"
      "swapServerUrl": "https://127.0.0.1:8081"
      "boltzServerUrl": "https://127.0.0.1:9003"
    ```
* Save and exit
*   Exit "rtl" user session to return to the "admin" user session

    ```sh
    $ exit
    ```

### Autostart on boot

Now we'll make sure Ride The Lightning starts as a service on the PC so it's always running. In order to do that, we create a systemd unit that starts the service on boot directly after LND.

*   As user "admin", create the service file.

    ```sh
    $ sudo nano /etc/systemd/system/rtl.service
    ```
*   Paste the following configuration. Save and exit.

    ```
    # MiniBolt: systemd unit for Ride the Lightning
    # /etc/systemd/system/rtl.service

    [Unit]
    Description=Ride the Lightning
    After=lnd.service
    PartOf=lnd.service

    [Service]
    WorkingDirectory=/home/rtl/RTL
    ExecStart=/usr/bin/node rtl
    User=rtl

    Restart=always
    RestartSec=30

    [Install]
    WantedBy=multi-user.target
    ```
*   Enable the service

    ```sh
    $ sudo systemctl enable rtl
    ```
*   Prepare "rtl" monitoring by the systemd journal and check log logging output. You can exit monitoring at any time by with `Ctrl-C`

    ```sh
    $ sudo journalctl -f -u rtl
    ```

## Run RTL

[Start your SSH program](../../guide/bonus/system/remote-access.md#access-with-secure-shell) (eg. PuTTY) a second time, connect to the PC and log in as "admin". Commands for the **second session** start with the prompt `$2` (which must not be entered).

*   Start the service.

    ```sh
    $2 sudo systemctl start rtl
    ```

Now point your browser to the secure access point provided by the NGINX web proxy, for example [https://minibolt.local:4001](https://minibolt.local:4001) (or your nodes IP address like [https://192.168.0.20:4001](https://192.168.0.20:4001)). You should see the home page of BTC RPC Explorer.

Your browser will display a warning because we use a self-signed SSL certificate. We can do nothing about that because we would need a proper domain name (e.g., https://yournode.com) to get an official certificate that browsers recognize. Click on "Advanced" and proceed to the Block Explorer web interface.

**Congratulations!** You now have Ride the Lightning running to manage your Lightning service on our own node.

### Remote access over Tor (optional)

You can easily add a Tor hidden service on the RaspiBolt and access the Ride the Lightning interface with the Tor browser from any device.

*   Add the following three lines in the section for "location-hidden services" in the `torrc` file. Save and exit

    ```sh
    $ sudo nano /etc/tor/torrc
    ```

    ```
    ############### This section is just for location-hidden services ###
    # Hidden Service RTL
    HiddenServiceDir /var/lib/tor/hidden_service_rtl/
    HiddenServiceVersion 3
    HiddenServicePort 80 127.0.0.1:3000
    ```

Update Tor configuration changes and get your connection address

```sh
$ sudo systemctl reload tor
```

```sh
$ sudo cat /var/lib/tor/hidden_service_rtl/hostname
```

**Example** expected output:

```
> abcefg...................zyz.onion
```

With the Tor browser (link this), you can access this onion address from any device.

### Enable 2-Factor-Authentication

If you want to be extra careful, you can enable 2FA for access to your RTL interface.

* Log in to RTL
* Click on the RTL logo top right, and choose "Settings"
* Select the "Authentication" tab and click on the "Enable 2FA" button
* Follow the instructions, using a 2FA app like Google Authenticator or Authy

## For the future: RTL upgrade

Updating to a [new release](https://github.com/Ride-The-Lightning/RTL/releases) is straightforward. Make sure to read the release notes first.

*   From user "admin", stop the service and open a "rtl" user session.

    ```sh
    $ sudo systemctl stop rtl
    ```

    ```sh
    $ sudo su - rtl
    ```
*   Fetch the latest GitHub repository information, display the latest release tag, ignoring release candidates and update:

    ```sh
    $ cd /home/rtl/RTL
    ```

    ```sh
    $ git fetch
    ```

    ```sh
    $ git reset --hard
    ```

    ```sh
    $ latest=$(git tag | grep -E "v[0-9]+.[0-9]+.[0-9]+$" | sort --version-sort | tail -n 1)
    ```

    ```sh
    $ git checkout $latest
    ```

    ```sh
    $ git verify-tag $latest
    ```

    ```sh
    $ npm install --omit=dev
    ```

    ```sh
    $ exit
    ```
*   Start the service again.

    ```sh
    $ sudo systemctl start rtl
    ```
