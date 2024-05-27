---
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

# PostgreSQL

<figure><img src="../../.gitbook/assets/PostgreSQL-Logo-white.png" alt="" width="563"><figcaption></figcaption></figure>

* With user `admin`, create the file repository configuration

{% code overflow="wrap" %}
```bash
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
```
{% endcode %}

* Import the repository signing key

{% code overflow="wrap" %}
```bash
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
```
{% endcode %}

Expected output:

```
> Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).
OK
```

* Update the package lists. You can ignore the `W: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8))` message

```bash
sudo apt update
```

* Install the latest version of PostgreSQL

```bash
sudo apt install postgresql postgresql-contrib
```

* Check the correct installation

```bash
psql -V
```

**Example** of expected output:

```
> psql (PostgreSQL) 15.3 (Ubuntu 15.3-1.pgdg22.04+1)
```

* Ensure PostgreSQL is running and listening on the default port `5432`

```bash
sudo ss -tulpn | grep LISTEN | grep postgres
```

Expected output:

<pre><code><strong>> tcp   LISTEN 0      200        127.0.0.1:5432       0.0.0.0:*    users:(("postgres",pid=2532748,fd=7))
</strong>> tcp   LISTEN 0      200            [::1]:5432          [::]:*    users:(("postgres",pid=2532748,fd=6))
</code></pre>

* Create the PostgreSQL data folder

```bash
sudo mkdir /data/postgresdb
```

* Assign as the owner to the `postgres`user

<pre class="language-bash"><code class="lang-bash"><strong>sudo chown postgres:postgres /data/postgresdb
</strong></code></pre>

* Assing permissions of the data folder only to the postgres user

<pre class="language-bash"><code class="lang-bash"><strong>sudo chmod -R 700 /data/postgresdb
</strong></code></pre>

* With user `postgres`, create a new cluster

```bash
sudo -u postgres /usr/lib/postgresql/16/bin/initdb -D /data/postgresdb
```

* Edit PostgreSQL data directory on configuration to redirect the store to the new location

```bash
sudo nano /etc/postgresql/16/main/postgresql.conf --linenumbers
```

* Replace the `line 42` to this. Save and exit

<pre><code><strong>data_directory = '/data/postgresdb'
</strong></code></pre>

* Prepare PostgreSQL main instance monitoring by the systemd journal and check log logging output. You can exit monitoring at any time with `Ctrl-C`

```bash
journalctl -fu postgresql@16-main
```

To keep an eye on the software movements, [start your SSH program](https://v2.minibolt.info/system/system/remote-access#access-with-secure-shell) (eg. PuTTY) a second time, connect to the MiniBolt node, and log in as `admin`

Prepare PostgreSQL sub-instance monitoring by the systemd journal and check log logging output. You can exit monitoring at any time with `Ctrl-C`

```bash
journalctl -fu postgresql
```

* To keep an eye on the software movements, [start your SSH program](https://v2.minibolt.info/system/system/remote-access#access-with-secure-shell) (eg. PuTTY) a third time, connect to the MiniBolt node, and log in as `admin`

{% hint style="info" %}
Commands for the **second session** start with the prompt **`$3` (which must not be entered)**
{% endhint %}

* Restart PostgreSQL to apply changes and monitor the correct status on the main instance and sub-instance monitoring sessions before

<pre class="language-bash"><code class="lang-bash"><strong>sudo systemctl restart postgresql
</strong></code></pre>

Example of expected output of `journalctl -fu postgresql@16-main`

```
Nov 08 11:51:10 minibolt systemd[1]: Stopping PostgreSQL Cluster 16-main...
Nov 08 11:51:11 minibolt systemd[1]: postgresql@16-main.service: Succeeded.
Nov 08 11:51:11 minibolt systemd[1]: Stopped PostgreSQL Cluster 16-main.
Nov 08 11:51:11 minibolt systemd[1]: postgresql@16-main.service: Consumed 1h 10min 8.677s CPU time.
Nov 08 11:51:11 minibolt systemd[1]: Starting PostgreSQL Cluster 16-main...
Nov 08 11:51:13 minibolt systemd[1]: Started PostgreSQL Cluster 16-main.
```

Example of expected output of `journalctl -fu postgresql`

```
Nov 08 11:51:10 minibolt systemd[1]: Stopped PostgreSQL RDBMS.
Nov 08 11:51:10 minibolt systemd[1]: Stopping PostgreSQL RDBMS...
Nov 08 11:51:13 minibolt systemd[1]: Starting PostgreSQL RDBMS...
Nov 08 11:51:13 minibolt systemd[1]: Finished PostgreSQL RDBMS.
```

### Create PostgreSQL user account

* With user `admin`, change to the automatically created user for the PostgreSQL installation called `postgres`

```bash
sudo su - postgres
```

* Create a new database user

```bash
createuser --pwprompt --interactive
```

Type in the following:

> > Enter name of role to add: **admin**
>
> > Enter password for new role: **admin**
>
> > Enter it again: **admin**
>
> > Shall the new role be a superuser? (y/n) **n**
>
> > Shall the new role be allowed to create databases? (y/n) **y**
>
> > Shall the new role be allowed to create more new roles? (y/n) **n**

* Come back to the `admin` user

```bash
exit
```
