---
layout:
  width: default
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
  metadata:
    visible: true
---

# MariaDB

[MariaDB Server](https://mariadb.org/) is one of the most popular open source relational databases. It’s made by the original developers of MySQL and guaranteed to stay open source. It is part of most cloud offerings and the default in most Linux distributions.

{% hint style="success" %}
Difficulty: Easy
{% endhint %}

<figure><img src="../../.gitbook/assets/mariadb.jpg" alt=""><figcaption></figcaption></figure>

## Installation

### Install MariaDB using the apt package manager

* With user `admin`, update and upgrade your OS. Press "**y**" and `enter` or directly `enter` when the prompt asks you

```bash
sudo apt update && sudo apt full-upgrade
```

* Import the repository signing key

{% code overflow="wrap" %}
```bash
sudo curl -o /etc/apt/keyrings/mariadb-keyring.pgp 'https://mariadb.org/mariadb_release_signing_key.pgp'
```
{% endcode %}

**Example** of expected output:

```
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  6575  100  6575    0     0  17781      0 --:--:-- --:--:-- --:--:-- 17770
```

* Create the repository configuration file

{% code overflow="wrap" %}
```bash
sudo tee /etc/apt/sources.list.d/mariadb.sources > /dev/null <<'EOF'
# MariaDB 12.2 repository list - created 2025-12-17 07:10 UTC
# https://mariadb.org/download/
X-Repolib-Name: MariaDB
Types: deb
# deb.mariadb.org is a dynamic mirror if your preferred mirror goes offline. See https://mariadb.org/mirrorbits/ for details.
# URIs: https://deb.mariadb.org/12.rc/ubuntu
URIs: https://mirror.raiolanetworks.com/mariadb/repo/12.2/ubuntu
Suites: jammy
Components: main main/debug
Signed-By: /etc/apt/keyrings/mariadb-keyring.pgp
EOF
```
{% endcode %}

* Update the package lists and install the latest version of MariaDB. Press "**y**" and `enter` or directly `enter` when the prompt asks you

```bash
sudo apt update && sudo apt install mariadb-server mariadb-client
```

* Check the correct installation of MariaDB

```bash
mariadb --version
```

**Example** of expected output:

```
mariadb from 12.2.1-MariaDB, client 15.2 for debian-linux-gnu (x86_64) using  EditLine wrapper
```

#### Validation

* Ensure MariaDB is running and listening on the default port 3306

```bash
sudo ss -tulpn | grep mariadb
```

Expected output:

```
tcp   LISTEN 0      80         127.0.0.1:3306       0.0.0.0:*    users:(("mariadbd",pid=2508568,fd=60))
```

* You can monitor general logs with the systemd journal. You can exit monitoring at any time with `Ctrl-C`

```bash
journalctl -fu mariadb
```

**Example** of expected output:

```
dic 17 06:57:55 minibolt systemd[1]: Started MariaDB 12.2.1 database server.
```

### Secure the installation

```bash
sudo mariadb-secure-installation
```

{% hint style="warning" %}
* When the prompt asks you to enter the current password for root, press **`enter`,**
* When the prompt asks if  you want to switch to unix\_socket authentication, type `"n"` and press **`enter`,**
* When the prompt asks if  you want to change the root password, type `"n"` and press **`enter`,**
* When the prompt asks if  you want to remove anonymous users, type `"y"` and press **`enter`,**
* When the prompt asks if  you want to disallow root login remotely, type `"y"` and press **`enter`,**
* When the prompt asks if  you want to remove test database and access to it, type `"y"` and press **`enter`,**
* When the prompt asks if  you want to reload privilege tables now type `"y"` and press **`enter`.**
{% endhint %}

Expected output:

```
All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

### Create data folder

* Create the dedicated MariaDB data folder

```bash
sudo mkdir -p /data/mariadb
```

* Assign the owner to the `mysql` user

<pre class="language-bash"><code class="lang-bash"><strong>sudo chown -R mysql:mysql /data/mariadb
</strong></code></pre>

* Assign permissions of the data folder only to the `mysql` user

<pre class="language-bash"><code class="lang-bash"><strong>sudo chmod -R 700 /data/mariadb
</strong></code></pre>

* Move `mariadb` existing data to the newly created directory

```bash
sudo rsync -av /var/lib/mysql/ /data/mariadb/
```

* Edit the MariaDB data directory in the configuration to redirect the store to the new location

```bash
sudo nano +18 /etc/mysql/mariadb.conf.d/50-server.cnf --linenumbers
```

* Uncomment and replace this line

```
datadir = /data/mariadb
```

* Add this line just under the previous one

```
socket = /data/mariadb/mysql.sock
```

* Edit the MariaDB client file

```bash
sudo nano /etc/mysql/mariadb.conf.d/50-client.cnf
```

* Add this lines in the `[client]` section

```
[client]
socket = /data/mariadb/mysql.sock
```

* Restart MariaDB to apply changes and monitor the correct status of the instance

<pre class="language-bash"><code class="lang-bash"><strong>sudo systemctl restart mariadb
</strong></code></pre>

* You can monitor the MariaDB instance using the systemd journal and check the log output. You can exit the monitoring at any time with `Ctrl-C`

```bash
journalctl -fu mariadb
```

Expected output:

```
dic 17 07:57:02 minibolt mariadbd[2527466]: 2025-12-17  7:57:02 0 [Note] InnoDB: Loading buffer pool(s) from /data/mariadb/ib_buffer_pool
dic 17 07:57:02 minibolt mariadbd[2527466]: 2025-12-17  7:57:02 0 [Note] InnoDB: Buffer pool(s) load completed at 251217  7:57:02
dic 17 07:57:04 minibolt mariadbd[2527466]: 2025-12-17  7:57:04 0 [Note] Server socket created on IP: '127.0.0.1', port: '3306'.
dic 17 07:57:04 minibolt mariadbd[2527466]: 2025-12-17  7:57:04 0 [Note] mariadbd: Event Scheduler: Loaded 0 events
dic 17 07:57:04 minibolt mariadbd[2527466]: 2025-12-17  7:57:04 0 [Note] /usr/sbin/mariadbd: ready for connections.
dic 17 07:57:04 minibolt mariadbd[2527466]: Version: '12.2.1-MariaDB-ubu2204'  socket: '/data/mariadb/mysql.sock'  port: 3306  mariadb.org binary distribution
```

## Extras (optional)

## Upgrade

The latest release can be found on the [official MariaDB web page](https://mariadb.org/download/).

* To upgrade, type this command. Press `"y"` and `enter`, or directly `enter` when the prompt asks you

```bash
sudo apt update && sudo apt full-upgrade
```

* Finally, enter this command to reload the systemctl daemon

```bash
sudo systemctl daemon-reload
```

## Uninstall

### Uninstall the MariaDB package and configuration

* With user `admin`, stop and disable the MariaDB service

```bash
sudo systemctl stop mariadb && sudo systemctl disable mariadb
```

* Uninstall MariaDB using the apt package manager

```bash
sudo apt remove mariadb-* --purge
```

* Uninstall possible unnecessary dependencies

```bash
sudo apt autoremove
```

* Delete configuration files and data

{% code overflow="wrap" %}
```bash
sudo rm -rf /etc/mysql/ && sudo rm -rf /var/lib/mysql/ && sudo rm -rf /var/log/mysql/ && sudo rm -rf /usr/lib/mysql/ && sudo rm -rf /usr/share/mysql/
```
{% endcode %}

### Uninstall MySQL user

* Delete the `mysql` user. Don't worry about `userdel: bitcoind mail spool (/var/mail/bitcoind) not found` output, the uninstall has been successful

```bash
sudo userdel -rf mysql
```

* Delete mysql group

```bash
sudo groupdel mysql
```

* Delete the complete `mariadb` directory

```bash
sudo rm -rf /data/mariadb
```

## Port reference

<table><thead><tr><th align="center">Port</th><th width="100">Protocol<select><option value="cJHzxcH6LkT8" label="TCP" color="blue"></option><option value="dS4cpQA3v9DQ" label="SSL" color="blue"></option><option value="gBPUaCLnXFI8" label="UDP" color="blue"></option></select></th><th align="center">Use</th></tr></thead><tbody><tr><td align="center">3306</td><td><span data-option="cJHzxcH6LkT8">TCP</span></td><td align="center">Default relational DB port</td></tr></tbody></table>
