---
title: Web app
nav_order: 30
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

# 3.3 Web app: ThunderHub

[ThunderHub](https://thunderhub.io/) is an open source LND node manager where you can manage and monitor your node on any device or browser. It allows you to take control of the lightning network with a simple and intuitive UX and the most up-to-date tech stack.

![](../images/thunderhub.png)

## Preparations

### **Check Node.js + NPM**

Node.js + NPM should have been installed for the [BTC RPC Explorer](../bitcoin/blockchain-explorer.md).

*   With the user `admin`, check the Node version

    ```sh
    $ node -v
    ```

**Example** of expected output:

```
> v16.14.2
```

*   Check NPM version

    ```sh
    $ npm -v
    ```

**Example** of expected output:

```
> 8.19.3
```

{% hint style="info" %}
If the version is v14.15 or above, you can move to the next section. If Node.js is not installed, follow this [Node.js + NPM bonus guide](../bonus/system/nodejs-npm.md) to install it
{% endhint %}

### **Reverse proxy & Firewall**

In the security [section](../system/security.md#prepare-nginx-reverse-proxy), we set up Nginx as a reverse proxy. Now we can add the ThunderHub configuration.

*   Enable the Nginx reverse proxy to route external encrypted HTTPS traffic internally to ThunderHub. The `error_page 497` directive instructs browsers that send HTTP requests to resend them over HTTPS

    ```sh
    $ sudo nano /etc/nginx/sites-enabled/thunderhub-reverse-proxy.conf
    ```

    ```nginx
    server {
      listen 4002 ssl;
      error_page 497 =301 https://$host:$server_port$request_uri;

      location / {
        proxy_pass http://127.0.0.1:3010;
      }
    }
    ```
*   Test Nginx configuration

    ```sh
    $ sudo nginx -t
    ```

<details>

<summary>Expected output ⬇️</summary>

```
> nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
> nginx: configuration file /etc/nginx/nginx.conf test is successful
```

</details>

```
> nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
> nginx: configuration file /etc/nginx/nginx.conf test is successful
```

*   Reload NGINX configuration

    ```
    $ sudo systemctl reload nginx
    ```
*   Configure the firewall to allow incoming HTTP requests from anywhere to the web server.

    ```sh
    $ sudo ufw allow 4002/tcp comment 'allow ThunderHub SSL from anywhere'
    ```

## ThunderHub

### **Preparation**

We do not want to run Thunderhub code alongside `bitcoind` and `lnd` because of security reasons. For that, we will create a separate user and we will be running the code as the new user. We are going to install Thunderhub in the home directory since it doesn't need too much space.

*   Create a new `thunderhub` user. The new user needs read-only access to the `tls.cert` and our `admin.macaroon`, so we add him to the "lnd" group

    ```sh
    $ sudo adduser --disabled-password --gecos "" thunderhub
    ```



    ```sh
    $ sudo adduser thunderhub lnd
    ```

{% code overflow="wrap" %}
```bash
$ sudo cp /data/lnd/data/chain/bitcoin/mainnet/admin.macaroon /home/thunderhub/admin.macaroon
```
{% endcode %}

```bash
$ sudo chown thunderhub:thunderhub /home/thunderhub/admin.macaroon
```

### Installation

* Change to the thunderhub user

```bash
$ sudo su - thunderhub
```

* Set a temporary version environment variable to the installation

```bash
$ VERSION=0.13.19
```

* Import the GPG key of the developer

```bash
$ curl https://github.com/apotdevin.gpg | gpg --import
```

*   Download the source code directly from GitHub and install all dependencies using NPM

    ```sh
    $ git clone --branch v$VERSION https://github.com/apotdevin/thunderhub.git
    ```

```sh
$ cd thunderhub
```

* Verify the release

```bash
$ git verify-commit v$VERSION
```

**Example** of expected output:

```
gpg: Signature made Fri May 26 16:56:42 2023 CEST
gpg:                using RSA key 3C8A01A8344B66E7875CE5534403F1DFBE779457
gpg: Good signature from "Anthony Potdevin <potdevin.anthony@gmail.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 3C8A 01A8 344B 66E7 875C  E553 4403 F1DF BE77 9457
```

```sh
$ npm install
```

<details>

<summary>Expected output ⬇️</summary>

```
npm WARN deprecated subscriptions-transport-ws@0.11.0: The `subscriptions-transport-ws` package is no longer maintained. We recommend you use `graphql-ws` instead. For help migrating Apollo software to `graphql-ws`, see https://www.apollographql.com/docs/apollo-server/data/subscriptions/#switching-from-subscriptions-transport-ws
[...]
```

</details>

```sh
$ npm run build
```

<details>

<summary>Expected output ⬇️</summary>

```
  [...]
  ├ λ /peers                                 7.21 kB         268 kB
  ├ λ /rebalance                             9.5 kB          285 kB
  ├ λ /settings                              8.13 kB         261 kB
  ├ λ /settings/dashboard                    460 B           249 kB
  ├ λ /sso                                   3.42 kB         248 kB
  ├ λ /stats                                 7.12 kB         252 kB
  ├ λ /swap                                  12.6 kB         291 kB
  ├ λ /tools                                 10 kB           255 kB
  └ λ /transactions                          5.92 kB         350 kB
  + First Load JS shared by all              245 kB
    ├ chunks/framework-0bff4c72fef67389.js   42 kB
    ├ chunks/main-1620fe742cfceb1f.js        27.6 kB
    ├ chunks/pages/_app-e0561dc8c6a45056.js  173 kB
    ├ chunks/webpack-74c128dc0ca7f46d.js     2.04 kB
    └ css/4bab2f810587958d.css               3.4 kB
  λ  (Server)  server-side renders at runtime (uses getInitialProps or getServerSideProps)
```

</details>

### **Configuration**

*   Still with user `thunderhub`, create a symbolic link pointing to your lnd data directory

    ```sh
    $ ln -s /data/lnd /home/thunderhub/.lnd
    ```
*   Copy and open the configuration file

    ```sh
    $ cd ~/thunderhub
    ```



    ```sh
    $ cp .env .env.local
    ```



    ```sh
    $ nano .env.local
    ```
*   Add or edit the following lines, save and exit

    ```
    # -----------
    # Server Configs
    # -----------
    NODE_ENV=production
    PORT=3010

    # -----------
    # Optional (more privacy)
    TOR_PROXY_SERVER=socks://127.0.0.1:9050
    # -----------

    # -----------
    # Account Configs
    # -----------
    ACCOUNT_CONFIG_PATH='/home/thunderhub/thunderhub/thubConfig.yaml'
    ```
* Edit your `thubConfig.yaml`

```sh
$ nano thubConfig.yaml
```

```
masterPassword: 'PASSWORD' # Default password unless defined in account
accounts:
  - name: 'MiniBolt'
    serverUrl: '127.0.0.1:10009'
    macaroonPath: '/home/thunderhub/admin.macaroon'
    certificatePath: '/home/thunderhub/.lnd/tls.cert'
    password: '[E] ThunderHub password'
```

{% hint style="info" %}
Replace the `[E] ThunderHub password` to your one
{% endhint %}

*   Exit `thunderhub` user session to return to the `admin` user session

    ```sh
    $ exit
    ```

## Autostart on boot

Now we'll make sure ThunderHub starts as a service on the PC so it's always running. In order to do that we create a systemd unit that starts the service on boot directly after LND.

*   As user `admin`, create the service file

    ```sh
    $ sudo nano /etc/systemd/system/thunderhub.service
    ```
*   Paste the following configuration. Save and exit.

    <pre><code># MiniBolt: systemd unit for Thunderhub
    # /etc/systemd/system/thunderhub.service

    [Unit]
    Description=Thunderhub
    <strong>Wants=lnd.service
    </strong>After=lnd.service

    [Service]
    WorkingDirectory=/home/thunderhub/thunderhub
    ExecStart=/usr/bin/npm run start:prod
    User=thunderhub
    TimeoutSec=300

    [Install]
    WantedBy=multi-user.target
    </code></pre>
*   Enable autoboot (optional)

    ```sh
    $ sudo systemctl enable thunderhub
    ```
*   Prepare "thunderhub" monitoring by the systemd journal and check log logging output. You can exit monitoring at any time by with `Ctrl-C`

    ```bash
    $ sudo journalctl -f -u thunderhub
    ```

## Run Thunderhub

To keep an eye on the software movements, [start your SSH program](../system/remote-access.md#access-with-secure-shell) straightforward (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as "admin". Commands for the **second session** start with the prompt `$2` (which must not be entered).

*   Start the service

    ```sh
    $2 sudo systemctl start thunderhub
    ```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
Jun 28 23:35:43 minibolt npm[513274]: > thunderhub@0.13.15 start
Jun 28 23:35:43 minibolt npm[513274]: > cross-env NODE_ENV=production nest start
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [NestFactory] Starting Nest application...
Jun 28 23:35:53 minibolt npm[513313]: Getting production env variables.
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] AppModule dependencies initialized +82ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] PassportModule dependencies initialized +1ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] LndModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] ApiModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] MainModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] DiscoveryModule dependencies initialized +1ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] ConfigHostModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] ScheduleModule dependencies initialized +1ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] ConfigModule dependencies initialized +1ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] ConfigModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] ThrottlerModule dependencies initialized +4ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] JwtModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] ViewModule dependencies initialized +1ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] GraphQLSchemaBuilderModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] WinstonModule dependencies initialized +1ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] FilesModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] FetchModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] AuthenticationModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] AccountsModule dependencies initialized +1ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] BaseModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] BitcoinModule dependencies initialized +1ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] GithubModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] UserConfigModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] AuthenticationModule dependencies initialized +1ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] AccountModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] NodeModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] BosModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] GraphQLModule dependencies initialized +1ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] WsModule dependencies initialized +1ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] WalletModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] ToolsModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] MacaroonModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] NetworkModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] PeerModule dependencies initialized +1ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] ChainModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] EdgeModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] ChannelsModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] ForwardsModule dependencies initialized +1ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] HealthModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] TransactionsModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] InvoicesModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] ChatModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] BoltzModule dependencies initialized +1ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] NodeModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] AuthModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] LnUrlModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] AmbossModule dependencies initialized +1ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] SubModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: [Nest] 513313  - 06/28/2023, 11:35:53 PM     LOG [InstanceLoader] LnMarketsModule dependencies initialized +0ms
Jun 28 23:35:53 minibolt npm[513313]: {
Jun 28 23:35:53 minibolt npm[513313]:   message: 'WS server created',
Jun 28 23:35:53 minibolt npm[513313]:   level: 'info',
Jun 28 23:35:53 minibolt npm[513313]:   timestamp: '2023-06-28T21:35:53.547Z'
Jun 28 23:35:53 minibolt npm[513313]: }
Jun 28 23:35:53 minibolt npm[513313]: {
Jun 28 23:35:53 minibolt npm[513313]:   context: 'RoutesResolver',
Jun 28 23:35:53 minibolt npm[513313]:   level: 'info',
Jun 28 23:35:53 minibolt npm[513313]:   message: 'ViewController {/}:',
Jun 28 23:35:53 minibolt npm[513313]:   timestamp: '2023-06-28T21:35:53.552Z'
Jun 28 23:35:53 minibolt npm[513313]: }
Jun 28 23:35:53 minibolt npm[513313]: {
Jun 28 23:35:53 minibolt npm[513313]:   context: 'RouterExplorer',
Jun 28 23:35:53 minibolt npm[513313]:   level: 'info',
Jun 28 23:35:53 minibolt npm[513313]:   message: 'Mapped {/, GET} route',
Jun 28 23:35:53 minibolt npm[513313]:   timestamp: '2023-06-28T21:35:53.555Z'
Jun 28 23:35:53 minibolt npm[513313]: }
Jun 28 23:35:53 minibolt npm[513313]: {
Jun 28 23:35:53 minibolt npm[513313]:   context: 'RouterExplorer',
Jun 28 23:35:53 minibolt npm[513313]:   level: 'info',
Jun 28 23:35:53 minibolt npm[513313]:   message: 'Mapped {/*, GET} route',
Jun 28 23:35:53 minibolt npm[513313]:   timestamp: '2023-06-28T21:35:53.555Z'
Jun 28 23:35:53 minibolt npm[513313]: }
Jun 28 23:35:53 minibolt npm[513313]: {
Jun 28 23:35:53 minibolt npm[513313]:   message: 'Server accounts that will be available: MiniBolt',
Jun 28 23:35:53 minibolt npm[513313]:   level: 'info',
Jun 28 23:35:53 minibolt npm[513313]:   timestamp: '2023-06-28T21:35:53.563Z'
Jun 28 23:35:53 minibolt npm[513313]: }
Jun 28 23:35:54 minibolt npm[513313]: Persisted queries are enabled and are using an unbounded cache. Your server is vulnerable to denial of service attacks via memory exhaustion. Set `cache: "bounded"` or `persistedQueries: false` in your ApolloServer constructor, or see https://go.apollo.dev/s/cache-backends for other alternatives.
Jun 28 23:35:54 minibolt npm[513313]: {
Jun 28 23:35:54 minibolt npm[513313]:   context: 'GraphQLModule',
Jun 28 23:35:54 minibolt npm[513313]:   level: 'info',
Jun 28 23:35:54 minibolt npm[513313]:   message: 'Mapped {/graphql, POST} route',
Jun 28 23:35:54 minibolt npm[513313]:   timestamp: '2023-06-28T21:35:54.092Z'
Jun 28 23:35:54 minibolt npm[513313]: }
Jun 28 23:35:54 minibolt npm[513313]: {
Jun 28 23:35:54 minibolt npm[513313]:   context: 'NestApplication',
Jun 28 23:35:54 minibolt npm[513313]:   level: 'info',
Jun 28 23:35:54 minibolt npm[513313]:   message: 'Nest application successfully started',
Jun 28 23:35:54 minibolt npm[513313]:   timestamp: '2023-06-28T21:35:54.524Z'
Jun 28 23:35:54 minibolt npm[513313]: }
Jun 28 23:35:54 minibolt npm[513313]: Application is running on: http://[::1]:3010
Jun 28 23:35:54 minibolt npm[513313]: (node:513313) [DEP0123] DeprecationWarning: Setting the TLS ServerName to an IP address is not permitted by RFC 6066. This will be ignored in a future version.
Jun 28 23:35:54 minibolt npm[513313]: (Use `node --trace-deprecation ...` to show where the warning was created)
[...]
```

</details>

* Now point your browser to `https://minibolt.local:4002`  or the IP address (e.g. `https://192.168.x.xxx:4002`). You should see the home page of ThunderHub

{% hint style="info" %}
Your browser will display a warning because we use a self-signed SSL certificate. We can do nothing about that because we would need a proper domain name (e.g., https://yournode.com) to get an official certificate that browsers recognize. Click on "Advanced" and proceed to the ThunderHub web interface.
{% endhint %}

{% hint style="success" %}
**Congratulations!** You now have Thunderhub up and running
{% endhint %}

## Remote access over Tor (optional)

Do you want to access ThunderHub remotely? You can easily do so by adding a Tor hidden service on the RaspiBolt and accessing ThunderHub with the Tor browser from any device.

*   Ensure that you are logged in with the user admin and add the following lines in the "location hidden services" section, below "`## This section is just for location-hidden services ##`" in the torrc file. Save and exit

    ```sh
    $ sudo nano /etc/tor/torrc
    ```



    ```
    # Hidden Service Thunderhub
    HiddenServiceDir /var/lib/tor/hidden_service_thunderhub/
    HiddenServiceVersion 3
    HiddenServicePort 80 127.0.0.1:3010
    ```
*   Restart Tor and get your connection address.

    ```sh
    $ sudo systemctl reload tor
    ```



    ```sh
    $ sudo cat /var/lib/tor/hidden_service_thunderhub/hostname
    ```

Expected output:

```
> abcdefg..............xyz.onion
```

* With the [Tor browser](https://www.torproject.org), you can access this onion address from any device

## Upgrade

Updating to a [new release](https://github.com/apotdevin/thunderhub/releases) should be straightforward.

*   From user `admin`, stop the service, and open a "thunderhub" user session

    ```sh
    $ sudo systemctl stop thunderhub
    ```



    ```sh
    $ sudo su - thunderhub
    ```
*   Run the update command provided within the package:

    ```sh
    $ cd ~/thunderhub
    ```



    ```sh
    $ npm run update
    ```



    ```sh
    $ exit
    ```
*   Start the service again.

    ```sh
    $ sudo systemctl start thunderhub
    ```

## Uninstall

### **Uninstall service**

*   Stop, disable, and delete the Thunderhub systemd service

    ```sh
    $ sudo systemctl stop thunderhub
    ```



    ```sh
    $ sudo systemctl disable thunderhub
    ```



    ```sh
    $ sudo rm /etc/systemd/system/thunderhub.service
    ```

### **Uninstall FW configuration**

*   Display the UFW firewall rules and notes the numbers of the rules for Thunderhub (e.g., X and Y below)

    ```sh
    $ sudo ufw status numbered
    ```

Expected output:

```
> [...]
> [X] 4002  ALLOW IN    Anywhere  # allow ThunderHub SSL from anywhere
```

*   Delete the two Thunderhub rules (check that the rule to be deleted is the correct one and type "y" and "Enter" when prompted)

    ```sh
    $ sudo ufw delete X
    ```

### **Uninstall Thunderhub**

* Delete the "thunderhub" user. It might take a long time as the Thunderhub user directory is big. Do not worry about the `userdel: thunderhub mail spool (/var/mail/thunderhub) not found`

```sh
$ sudo userdel -rf thunderhub
```

Expected output:

```
> userdel: thunderhub mail spool (/var/mail/thunderhub) not found
```

### **Uninstall Tor hidden service**

*   Comment or remove the fulcrum hidden service lines in torrc. Save and exit

    ```sh
    $ sudo nano /etc/tor/torrc
    ```



    ```
    # Hidden Service Thunderhub
    #HiddenServiceDir /var/lib/tor/hidden_service_thunderhub/
    #HiddenServiceVersion 3
    #HiddenServicePort 80 127.0.0.1:3010
    ```
*   Reload torrc config

    ```sh
    $ sudo systemctl reload tor
    ```

## Extras

### Access to your Amboss node account

* In the "Home" screen - "Quick Actions" section, click on the Amboss icon "**Login**", wait for the top right corner notification to show you "Logged in" and click again on the Amboss icon "Go to". This will open a secondary tab in your browser to access your Amboss account node.

Advice: If you can't do "Login", maybe the cause is that you don't have a channel opened yet. Planning to open a small size channel to be connected with the Lightning Network and to the Amboss node.

* Making sure we are connected to the Amboss account, now back to Thunderhub for the next steps.

### Enable auto backups and healthcheck notifications to the Amboss account

1. Open the “Settings” by pressing the cogwheel in the top right corner of the Thunderhub
2. Switch to "Yes" -> Amboss: "Auto backups" and "Healthcheck Pings"
3. Test pushing a backup to Amboss by entering the "Tools" section, to the left main menu
4. Press to "Push" button to test the correct working
5. Go back to the Amboss website and access "Account" in the main menu
6. Access to "Backup" and ensure that the last date of the backup is the same as before. It is recommended to download the backup file and store it in a safe place for future recovers. The backup file will be updated automatically in Amboss for every channel opening and closing. You could do this too in the "Tools" section in Thunderhub, "Backups" -> "Backup all channels" -> "Download" button.
7. In Amboss, access "Monitoring" to configure "Healthcheck Settings".

{% hint style="info" %}
Feel free to link to Telegram bot notifications, enable different notifications, complete your public node profile in Amboss, and other things in the different sections of your account.
{% endhint %}

### Recovering channels using the ThunderHub method

After possible data corruption of your LND node, ensure that this old node is completely off. Once you have synced the new node, on-chain recovered with seeds, full on-chain re-scan complete and Thunderhub installed, access to the Thunderhub dashboard

1. Access to the "Tools" section, "Backups" -> "Recover Funds from channels" -> "Recover" button
2. Enter the complete string text of your previously downloaded channels backup file in the step before and push the "Recover" button. All of the channels that you had opened in your old node will be forced closed and they will appear in the "Pending" tab in the "Channels" section until closings are confirmed

{% hint style="danger" %}
Use this guide as a last resort if you have lost access to your node or are unable to start LND due to a fatal error. This guide will close all your channels. Your funds will become available on-chain at varying speeds.
{% endhint %}
