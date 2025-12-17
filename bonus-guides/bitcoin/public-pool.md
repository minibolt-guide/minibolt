# Public Pool

[Public Pool](https://web.public-pool.io/#/) is a NestJS and Typescript Bitcoin stratum mining server. It allows you to mine in "solo" mode from your node.&#x20;

{% hint style="warning" %}
Difficulty: Medium
{% endhint %}

<figure><img src="../../.gitbook/assets/public-pool.png" alt=""><figcaption></figcaption></figure>

## Requirements

* [Bitcoin Core](../../bitcoin/bitcoin/bitcoin-client.md)



## Preparations

### Check Node + NPM

Node + NPM should have been installed for the [BTC RPC Explorer](../../bitcoin/bitcoin/blockchain-explorer.md).

* With the user `admin`, check the Node version

```sh
node -v
```

**Example** of expected output:

```
v16.14.2
```

* Check the NPM version

```sh
npm -v
```

**Example** of expected output:

```
8.19.3
```

{% hint style="info" %}
-> If the "`node -v"` output is **`>=18`**, you can move to the next section.

-> If Nodejs is not installed (`-bash: /usr/bin/node: No such file or directory`), follow this [Node + NPM bonus guide](../../bonus/system/nodejs-npm.md) to install it
{% endhint %}

### Reverse proxy & Firewall

In the security [section](../../index-1/security.md#prepare-nginx-reverse-proxy), we set up Nginx as a reverse proxy. Now we can add the Public Pool configuration.

Enable the Nginx reverse proxy to route external encrypted HTTPS traffic internally to Public Pool. The `error_page 497` directive instructs browsers that send HTTP requests to resend them over HTTPS.

* With user `admin`, create the reverse proxy configuration

```sh
sudo nano /etc/nginx/sites-available/public-pool-reverse-proxy.conf
```

* Paste the following complete configuration. Save and exit

```nginx
server {
    listen 4040 ssl;
    error_page 497 =301 https://$host:$server_port$request_uri;
 
    root /var/www/public-pool-ui;
 
    index index.html;
 
    location / {
        try_files $uri $uri/ =404;
    }
 
    location ~* ^/api/ {
        proxy_pass http://127.0.0.1:23334;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

* Create the symbolic link that points to the directory `sites-enabled`

{% code overflow="wrap" %}
```bash
sudo ln -s /etc/nginx/sites-available/public-pool-reverse-proxy.conf /etc/nginx/sites-enabled/
```
{% endcode %}

* Test Nginx configuration

```sh
sudo nginx -t
```

Expected output:

```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

* Reload the NGINX configuration to apply changes

```bash
sudo systemctl reload nginx
```

* Configure the firewall to allow incoming HTTP requests from anywhere to the web and stratum servers

```sh
sudo ufw allow 4040/tcp comment 'Allow Public Pool UI SSL from anywhere'
sudo ufw allow 23333/tcp comment 'Allow Public Pool Stratum from anywhere'
```

## Installation

### Create the public-pool user & group

We do not want to run Public Pool code alongside `bitcoind` because of security reasons. For that, we will create a separate user and run the code as the new user.

* Create a new `public-pool` user and group

```sh
sudo adduser --disabled-password --gecos "" public-pool
```

* Add `public-pool` user to the `bitcoin` group to allow the user `public-pool` reading the `.cookie` file

```sh
sudo adduser public-pool bitcoin
```
