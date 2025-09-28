# PostgreSQL

PostgreSQL is a powerful, open source object-relational database system that uses and extends the SQL language combined with many features that safely store and scale the most complicated data workloads.

{% hint style="warning" %}
Difficulty: Medium
{% endhint %}

<figure><img src="../../.gitbook/assets/PostgreSQL-Logo-white.png" alt="" width="563"><figcaption></figcaption></figure>

## Installation

### Install PostgreSQL using the apt package manager

* With user `admin`, update and upgrade your OS

```bash
sudo apt update && sudo apt full-upgrade
```

* Import the repository signing key

{% code overflow="wrap" %}
```bash
sudo install -d /usr/share/postgresql-common/pgdg
```
{% endcode %}

{% code overflow="wrap" %}
```bash
sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
```
{% endcode %}

**Example** of expected output:

```
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  4812  100  4812    0     0   5453      0 --:--:-- --:--:-- --:--:--  5449
```

* Create the repository configuration file

{% code overflow="wrap" %}
```bash
sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
```
{% endcode %}

* Update the package lists and install the latest version of PostgreSQL. Press "**y**" and `enter` or directly `enter` when the prompt asks you

```bash
sudo apt update && sudo apt install postgresql postgresql-contrib
```

* Check the correct installation of PostgreSQL

```bash
psql -V
```

**Example** of expected output:

```
psql (PostgreSQL) 15.3 (Ubuntu 15.3-1.pgdg22.04+1)
```

#### Validation

* Ensure PostgreSQL is running and listening on the default port `5432`

```bash
sudo ss -tulpn | grep postgres
```

Expected output:

<pre><code><strong>tcp   LISTEN 0      200        127.0.0.1:5432       0.0.0.0:*    users:(("postgres",pid=2532748,fd=7))
</strong>tcp   LISTEN 0      200            [::1]:5432          [::]:*    users:(("postgres",pid=2532748,fd=6))
</code></pre>

* You can monitor general logs with the systemd journal. You can exit monitoring at any time with `Ctrl-C`

```bash
journalctl -fu postgresql
```

**Example** of expected output:

```
May 31 13:51:11 minibolt systemd[1]: Finished PostgreSQL RDBMS.
```

* And the sub-instance and specific cluster logs. You can exit monitoring at any time with `Ctrl-C`

```bash
journalctl -fu postgresql@18-main
```

**Example** of expected output:

```
May 31 13:51:18 minibolt systemd[1]: Starting PostgreSQL Cluster 17-main...
May 31 13:51:21 minibolt systemd[1]: Started PostgreSQL Cluster 17-main.
```

### Create data folder

* Create the dedicated PostgreSQL data folder

```bash
sudo mkdir -p /data/postgresdb/18
```

* Assign the owner to the `postgres` user

<pre class="language-bash"><code class="lang-bash"><strong>sudo chown -R postgres:postgres /data/postgresdb
</strong></code></pre>

* Assign permissions of the data folder only to the `postgres` user

<pre class="language-bash"><code class="lang-bash"><strong>sudo chmod -R 700 /data/postgresdb
</strong></code></pre>

* With user `postgres`, create a new cluster in the dedicated folder

```bash
sudo -u postgres /usr/lib/postgresql/18/bin/initdb -D /data/postgresdb/18
```

<details>

<summary><strong>Example</strong> of expected output ⬇️</summary>

```
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "en_US.UTF-8".
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "english".

Data page checksums are disabled.

fixing permissions on existing directory /data/postgresdb17 ... ok
creating subdirectories ... ok
selecting dynamic shared memory implementation ... posix
selecting default "max_connections" ... 100
selecting default "shared_buffers" ... 128MB
selecting default time zone ... Etc/UTC
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... ok
syncing data to disk ... ok

initdb: warning: enabling "trust" authentication for local connections
initdb: hint: You can change this by editing pg_hba.conf or using the option -A, or --auth-local and --auth-host, the next time you run initdb.

Success. You can now start the database server using:

    /usr/lib/postgresql/17/bin/pg_ctl -D /data/postgresdb/17 -l logfile start
```

</details>

* Edit the PostgreSQL data directory in the configuration to redirect the store to the new location

```bash
sudo nano +42 /etc/postgresql/18/main/postgresql.conf --linenumbers
```

* Replace the `line 42` with `/var/lib/postgresql/18/main` to the next. Save and exit

<pre><code><strong>data_directory = '/data/postgresdb/18'
</strong></code></pre>

* Restart PostgreSQL to apply changes and monitor the correct status of the main instance and sub-instance monitoring sessions before

<pre class="language-bash"><code class="lang-bash"><strong>sudo systemctl restart postgresql
</strong></code></pre>

* You can monitor the PostgreSQL main instance using the systemd journal and check the log output. You can exit the monitoring at any time with `Ctrl-C`

```bash
journalctl -fu postgresql
```

Expected output:

```
Nov 08 11:51:10 minibolt systemd[1]: Stopped PostgreSQL RDBMS.
Nov 08 11:51:10 minibolt systemd[1]: Stopping PostgreSQL RDBMS...
Nov 08 11:51:13 minibolt systemd[1]: Starting PostgreSQL RDBMS...
Nov 08 11:51:13 minibolt systemd[1]: Finished PostgreSQL RDBMS.
```

* You can monitor the PostgreSQL sub-instance using the systemd journal and check log output. You can exit monitoring at any time with `Ctrl-C`

```bash
journalctl -fu postgresql@18-main
```

**Example** of the expected output:

```
Nov 08 11:51:10 minibolt systemd[1]: Stopping PostgreSQL Cluster 17-main...
Nov 08 11:51:11 minibolt systemd[1]: postgresql@17-main.service: Succeeded.
Nov 08 11:51:11 minibolt systemd[1]: Stopped PostgreSQL Cluster 17-main.
Nov 08 11:51:11 minibolt systemd[1]: postgresql@17-main.service: Consumed 1h 10min 8.677s CPU time.
Nov 08 11:51:11 minibolt systemd[1]: Starting PostgreSQL Cluster 17-main...
Nov 08 11:51:13 minibolt systemd[1]: Started PostgreSQL Cluster 17-main.
```

* You can check if the cluster is in status "online" by

```bash
pg_lsclusters
```

**Example** of expected output:

```
Ver Cluster Port Status Owner    Data directory       Log file
17  main    5432 online postgres /data/postgresdb/17  /var/log/postgresql/postgresql-17-main.log
```

{% hint style="info" %}
**(Optional)** -> If you want, you can **disable the autoboot** option for PostgreSQL **(not recommended)** using:

```bash
sudo systemctl disable postgresql
```

Expected output:

```
Synchronizing state of postgresql.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install disable postgresql
Removed /etc/systemd/system/multi-user.target.wants/postgresql.service.
```
{% endhint %}

* Ensure PostgreSQL is listening on the default relational database port

```bash
sudo ss -tulpn | grep postgres
```

Expected output:

```
tcp   LISTEN 0      200        127.0.0.1:5432       0.0.0.0:*    users:(("postgres",pid=3249848,fd=7))
tcp   LISTEN 0      200            [::1]:5432          [::]:*    users:(("postgres",pid=3249848,fd=6))
```

### Create a PostgreSQL user account

* Create a new database `admin` user and assign the password "`admin`" with the automatically created user for the PostgreSQL installation, called `postgres`

<pre class="language-bash"><code class="lang-bash"><strong>sudo -u postgres psql -c "CREATE ROLE admin WITH LOGIN CREATEDB PASSWORD 'admin';"
</strong></code></pre>

Expected output:

```
CREATE ROLE
```

{% hint style="success" %}
Congrats! You have PostgreSQL ready to use as a database backend for another software
{% endhint %}

## Extras (optional)

### Some useful PostgreSQL commands

* With user `admin`, enter the PostgreSQL CLI with the user `postgres`. The prompt should change to `postgres=#`

```bash
sudo -u postgres psql
```

**Example** of expected output:

```
psql (16.3 (Ubuntu 16.3-1.pgdg22.04+1))
Type "help" for help.

postgres=#
```

{% hint style="info" %}
Type `\q` command and enter to exit PostgreSQL CLI, and exit to come back to the `admin` user
{% endhint %}

#### List the global existing users and roles associated

* Type the next command and enter

```sql
\du
```

**Example** of expected output:

```
                             List of roles
 Role name |                         Attributes
-----------+------------------------------------------------------------
 admin     | Create DB
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS
```

#### List the existing global databases

* Type the next command and enter

```sql
\l
```

**Example** of expected output:

```
     Name     |  Owner   | Encoding | Locale Provider |   Collate   |    Ctype    | ICU Locale | ICU Rules |   Access privileges
--------------+----------+----------+-----------------+-------------+-------------+------------+-----------+-----------------------
 btcpay       | admin    | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           |
 lndb         | admin    | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           |
 nbxplorer    | admin    | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           |
 nostrelay    | admin    | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           |
 postgres     | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           |
 template0    | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =c/postgres          +
              |          |          |                 |             |             |            |           | postgres=CTc/postgres
 template1    | postgres | UTF8     | libc            | en_US.UTF-8 | en_US.UTF-8 |            |           | =c/postgres          +
              |          |          |                 |             |             |            |           | postgres=CTc/postgres
(8 rows)
```

#### List tables inside a specific database

* Connect to a specific database, type the next command, and enter. The prompt should change to the name of the database. Example: `lndb=#`

```sql
\c <NAMEOFDATABASE>
```

{% hint style="info" %}
Replace `<NAMEOFDATABASE`> to the specific name of the database
{% endhint %}

**Example:**

```sql
\c lndb
```

**Expected output:**

```
You are now connected to database "lndb" as user "postgres".
```

* List tables

```sql
\dt
```

**Example of expected output:**

```
             List of relations
 Schema |       Name       | Type  | Owner
--------+------------------+-------+-------
 public | channeldb_kv     | table | admin
 public | decayedlogdb_kv  | table | admin
 public | macaroondb_kv    | table | admin
 public | towerclientdb_kv | table | admin
 public | towerserverdb_kv | table | admin
 public | walletdb_kv      | table | admin
(6 rows)
```

#### **View the size of a specific database**

* Type the next command and enter

```sql
SELECT pg_size_pretty(pg_database_size('<NAMEOFDATABASE>'));
```

{% hint style="info" %}
Replace `<NAMEOFDATABASE`> to the specific name of the database
{% endhint %}

**Example:**

```sql
SELECT pg_size_pretty(pg_database_size('lndb'));
```

**Example** of expected output:

```
 pg_size_pretty
----------------
 546 MB
(1 row)
```

#### **View the size of a specific table inside a database**

* Enter a specific database with

```sql
\c <NAMEOFDATABASE>
```

{% hint style="info" %}
Replace `<NAMEOFDATABASE>` to the specific name of the database
{% endhint %}

**Example:**

```bash
\c lndb
```

* View the size of a specific table

```sql
SELECT pg_size_pretty(pg_total_relation_size('<NAMEOFTABLE>'));
```

{% hint style="info" %}
Replace `<NAMEOFTABLE>` to the specific name of the database
{% endhint %}

**Example:**

```sql
SELECT pg_size_pretty(pg_total_relation_size('channeldb_kv'));
```

**Example** of expected output:

```
 pg_size_pretty
----------------
 457 MB
(1 row)
```

#### **Show if there is content inside a table**

Get a quick view of the data stored in a table without having to retrieve all the records. Useful after a data migration, for example.

* Enter a specific database

```
\c <NAMEOFDATABASE>
```

Example:

```bash
\c lndb
```

* Type the next command to make a request and obtain the data

```sql
 SELECT * FROM <NAMEOFTABLE> LIMIT 10;
```

{% hint style="info" %}
Replace `<NAMEOFTABLE>` to the specific name of the database
{% endhint %}

#### **Example:**

```sql
 SELECT * FROM channeldb_kv LIMIT 10;
```

#### **Delete** a specific database

* Type the next command and enter

```sql
DROP DATABASE <NAMEOFDATABASE>;
```

{% hint style="info" %}
Replace `<NAMEOFTABLE>` to the specific name of the table
{% endhint %}

Example:

```sql
DROP DATABASE lndb;
```

#### Expected output:

```
DROP DATABASE
```

#### Delete a table inside a specific database

{% hint style="warning" %}
Stop the service related to this database before the action, i.e: `sudo systemctl stop lnd`
{% endhint %}

* Enter a specific database with

```sql
\c <NAMEOFDATABASE>
```

{% hint style="info" %}
Replace `<NAMEOFDATABASE>` to the specific name of the database
{% endhint %}

**Example:**

```sql
\c lndb
```

* Delete a specific table

{% hint style="warning" %}
Stop the service related to this table and database before the action, i.e: `sudo systemctl stop lnd`
{% endhint %}

```sql
DROP TABLE <NAMEOFTABLE>;
```

{% hint style="info" %}
Replace `<NAMEOFTABLE>` to the specific name of the table
{% endhint %}

{% hint style="danger" %}
Warning: this command is especially dangerous, do it at your own risk
{% endhint %}

Example:

```sql
DROP TABLE towerclientdb_kv;
```

#### Delete existing users

* In some hypothetical situation, you might want to delete an existing user of PostgreSQL. Type the next command

```sql
DROP ROLE <user>;
```

{% hint style="info" %}
Replace `<user>` to the desired user
{% endhint %}

Example:

```sql
DROP ROLE admin;
```

{% hint style="danger" %}
Warning: this command is especially dangerous, do it at your own risk
{% endhint %}

## Upgrade

The latest release can be found on the [official PostgreSQL web page](https://www.postgresql.org/ftp/source/).

* To upgrade, type this command. Press "y" and enter, or directly enter when the prompt asks you

```bash
sudo apt update && sudo apt full-upgrade
```

{% hint style="info" %}
If a banner like this appears to you, keep selecting "No" and press Enter
{% endhint %}

<figure><img src="../../.gitbook/assets/Screenshot 2025-09-27 000712.png" alt=""><figcaption></figcaption></figure>

* Finally, enter this command to reload the systemctl daemon

```bash
sudo systemctl daemon-reload
```

### Migrate to a major version <a href="#upgrade-to-major-version" id="upgrade-to-major-version"></a>

* With user `admin`, ensure you followed [the previous Upgrade](postgresql.md#upgrade) section

#### **PostgreSQL server migration**

* Stop all existing PostgreSQL dependencies and subdependencies services, at this moment on MiniBolt

```bash
sudo systemctl stop nostr-relay thunderhub lnd scbackup btcpay nbxplorer
```

* Stop all existing PostgreSQL clusters and the main cluster

```bash
sudo systemctl stop postgresql
```

* Enable data page checksums

{% code overflow="wrap" %}
```bash
sudo -u postgres /usr/lib/postgresql/17/bin/pg_checksums -D /data/postgresdb/17 --enable
```
{% endcode %}

Example of expected output:

<pre><code>Checksum operation completed
Files scanned:   2925
Blocks scanned:  1009194
Files written:  2423
Blocks written: 1009149
pg_checksums: syncing data directory
pg_checksums: updating control file
<a data-footnote-ref href="#user-content-fn-1">Checksums enabled in cluster</a>
</code></pre>

{% hint style="info" %}
This could take a moment, depending on your hardware and database size
{% endhint %}

* Create a new database destination folder for the new v18 cluster, ready for migration from v17

{% hint style="info" %}
This could change in the future with the next releases, for example, you will need to replace v17 with v18, and v18 with v19, etc.
{% endhint %}

```bash
sudo mkdir /data/postgresdb/18
```

* Assign the owner as the postgres user

```bash
sudo chown postgres:postgres /data/postgresdb/18
```

* Assign the correct permissions

```bash
sudo chmod 700 /data/postgresdb/18
```

* Start the migration with the PostgreSQL migration tool

```bash
sudo -u postgres pg_upgradecluster 17 main /data/postgresdb/18
```

{% hint style="info" %}
⌛ This may take a lot of time depending on the existing database size (the nostr relay database, especially) and your machine's performance; it is recommended to use [tmux](https://github.com/tmux/tmux). Wait until the prompt shows up again
{% endhint %}

<details>

<summary>Example of expected output 👇</summary>

```
Upgrading cluster 17/main to 18/main ...
Stopping old cluster...
Warning: stopping the cluster using pg_ctlcluster will mark the systemd unit as failed. Consider using systemctl:
  sudo systemctl stop postgresql@17-main
Restarting old cluster with restricted connections...
Notice: extra pg_ctl/postgres options given, bypassing systemctl for start operation
Creating new PostgreSQL cluster 18/main ...
/usr/lib/postgresql/18/bin/initdb -D /data/postgresdb/18 --auth-local peer --auth-host scram-sha-256 --no-instructions --encoding UTF8 --lc-collate en_GB.UTF-8 --lc-ctype en_GB.UTF-8 --locale-provider libc --data-checksums
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "en_GB.UTF-8".
The default text search configuration will be set to "english".

Data page checksums are enabled.

fixing permissions on existing directory /data/postgresdb/18 ... ok
creating subdirectories ... ok
selecting dynamic shared memory implementation ... posix
selecting default "max_connections" ... 100
selecting default "shared_buffers" ... 128MB
selecting default time zone ... Europe/Madrid
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... ok
syncing data to disk ... ok
Warning: systemd does not know about the new cluster yet. Operations like "service postgresql start" will not handle it. To fix, run:
  sudo systemctl daemon-reload

Copying old configuration files...
Copying old start.conf...
Copying old pg_ctl.conf...
Starting new cluster...
Notice: extra pg_ctl/postgres options given, bypassing systemctl for start operation
Running init phase upgrade hook scripts ...

Upgrading databases ...
/usr/share/postgresql-common/pg_dumpcluster -A /usr/lib/postgresql/18/bin/pg_dumpall -h /var/run/postgresql -p 5432 -Q /usr/lib/postgresql/18/bin/psql -H /var/run/postgresql -P 5433 -U postgres
SET default_transaction_read_only = off;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
CREATE ROLE "admin";
ALTER ROLE "admin" WITH NOSUPERUSER INHERIT NOCREATEROLE CREATEDB LOGIN NOREPLIC
ALTER ROLE "postgres" WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATI
You are now connected to database "template1" as user "postgres".

[...]

vacuumdb: processing database "lndb": Generating default (full) optimizer statistics
vacuumdb: processing database "postgres": Generating default (full) optimizer statistics
vacuumdb: processing database "template1": Generating default (full) optimizer statistics
vacuumdb: vacuuming database "lndb"
vacuumdb: vacuuming database "postgres"
vacuumdb: vacuuming database "template1"

Success. Please check that the upgraded cluster works. If it does,
you can remove the old cluster with
    pg_dropcluster 17 main

Ver Cluster Port Status Owner    Data directory      Log file
17  main    5433 down   postgres /data/postgresdb/17 /var/log/postgresql/postgresql-17-main.log
Ver Cluster Port Status Owner    Data directory      Log file
18  main    5432 online postgres /data/postgresdb/18 /var/log/postgresql/postgresql-18-main.log
```

</details>

* Reload the systemd again

```bash
sudo systemctl daemon-reload
```

* Stop the old version cluster using the `pg_ctlcluster` tool, to then be able to run it and manage it with `systemd`

```bash
sudo pg_ctlcluster 18 main stop
```

* Monitor the logs of the PostgreSQL version 18 cluster to ensure that it is working fine with `systemd.` Press Ctrl + C to continue with the steps

```bash
journalctl -fu postgresql@18-main
```

* To keep an eye on the software movements, [start your SSH program](https://minibolt.minibolt.info/system/system/remote-access#access-with-secure-shell) (eg, PuTTY) a second time, connect to the MiniBolt node, and log in as "admin"
* Start the new version cluster with systemd and PostgreSQL RDBMS (Relational Database Management System)

```bash
sudo systemctl start postgresql
```

**Example** of expected output on the first terminal with `journalctl -fu postgresql@18-main`⬇️

```
minibolt systemd[1]: Starting PostgreSQL Cluster 18-main...
minibolt systemd[1]: Started PostgreSQL Cluster 18-main.
```

* Start all existing PostgreSQL dependencies and subdependencies services, at this moment on MiniBolt

<pre class="language-bash"><code class="lang-bash"><strong>sudo systemctl start nostr-relay lnd thunderhub scbackup nbxplorer btcpay 
</strong></code></pre>

{% hint style="info" %}
Monitor the logs with `journalctl -fu "X"` to ensure all is running fine with the new PostgreSQL version, e.g, `journalctl -fu lnd`
{% endhint %}

* If all is running fine, we can delete the old and unused cluster

```bash
sudo pg_dropcluster 17 main
```

* List the clusters to check the correct old cluster deletion and the new one running

```bash
pg_lsclusters
```

Example of expected output:

```
Ver Cluster Port Status Owner     Data directory      Log file
18  main    5432 online <unknown> /data/postgresdb/18 /var/log/postgresql/postgresql-18-main.log
```

{% hint style="info" %}
Note that the old version of the cluster is no longer listed, and the new one is running
{% endhint %}

#### **Check the PostgreSQL server version in use**

* With the user `admin`, enter the psql (PostgreSQL CLI)

```bash
sudo -u postgres psql
```

* Enter the next command to check the server version

```sql
SELECT version();
```

Example of expected output:

<pre><code>                                                              version
-----------------------------------------------------------------------------------------------------------------------------------
 PostgreSQL <a data-footnote-ref href="#user-content-fn-1">18.0</a> (Ubuntu 18.0-1.pgdg22.04+3) on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 11.4.0-1ubuntu1~22.04.2) 11.4.0, 64-bit
(1 row)
</code></pre>

{% hint style="info" %}
Check the previous version in use is now PostgreSQL 17.2 (the latest and current version of the PostgreSQL server at this moment)
{% endhint %}

* Come back to the `admin` user bash prompt

```sql
\q
```

* Check the client version

```bash
psql -V
```

Example of expected output:

<pre><code>psql (PostgreSQL) <a data-footnote-ref href="#user-content-fn-1">18.0</a> (Ubuntu 18.0-1.pgdg22.04+3)
</code></pre>

* Delete unnecessary packages if there are any. Press "y" and enter, or directly enter when the prompt asks you

```bash
sudo apt autoremove
```

{% hint style="success" %}
That's it! You have updated PostgreSQL to the major version immediately higher
{% endhint %}

## Uninstall

### Uninstall the PostgreSQL package and configuration

* With user `admin`, stop and disable the PostgreSQL service

```bash
sudo systemctl stop postgresql && sudo systemctl disable postgresql
```

* Uninstall PostgreSQL using the apt package manager

```bash
sudo apt remove postgresql postgresql-* --purge
```

* Uninstall possible unnecessary dependencies

```bash
sudo apt autoremove
```

* Delete configuration files and data

{% code overflow="wrap" %}
```bash
sudo rm -rf /etc/postgresql/ && sudo rm -rf /etc/postgresql-common/ && sudo rm -rf /var/lib/postgresql/ && sudo rm -rf /var/log/postgresql/ && sudo rm -rf /usr/lib/postgresql/ && sudo rm -rf /usr/share/postgresql/
```
{% endcode %}

### Uninstall postgres user

* Delete the postgres user. Don't worry about `userdel: bitcoind mail spool (/var/mail/bitcoind) not found` output, the uninstall has been successful

```bash
sudo userdel -rf postgres
```

* Delete postgres group

```bash
sudo groupdel postgres
```

* Delete the complete `postgresdb` directory

```bash
sudo rm -rf /data/postgresdb
```

## Port reference

<table><thead><tr><th align="center">Port</th><th width="100">Protocol<select><option value="cJHzxcH6LkT8" label="TCP" color="blue"></option><option value="dS4cpQA3v9DQ" label="SSL" color="blue"></option><option value="gBPUaCLnXFI8" label="UDP" color="blue"></option></select></th><th align="center">Use</th></tr></thead><tbody><tr><td align="center">5432</td><td><span data-option="cJHzxcH6LkT8">TCP</span></td><td align="center">Default relational DB port</td></tr></tbody></table>

[^1]: Check this
