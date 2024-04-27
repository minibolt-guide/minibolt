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
$ sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
```
{% endcode %}

* Import the repository signing key

{% code overflow="wrap" %}
```bash
$ wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
```
{% endcode %}

Expected output:

```
> Warning: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8)).
OK
```

* Update the package lists. You can ignore the `W: apt-key is deprecated. Manage keyring files in trusted.gpg.d instead (see apt-key(8))` message

```bash
$ sudo apt update
```

* Install the latest version of PostgreSQL

```bash
$ sudo apt install postgresql postgresql-contrib
```

* Check the correct installation

```bash
$ psql -V
```

**Example** of expected output:

```
> psql (PostgreSQL) 15.3 (Ubuntu 15.3-1.pgdg22.04+1)
```

* Ensure PostgreSQL is running and listening on the default port `5432`

```bash
$ sudo ss -tulpn | grep LISTEN | grep postgres
```

Expected output:

<pre><code><strong>> tcp   LISTEN 0      200        127.0.0.1:5432       0.0.0.0:*    users:(("postgres",pid=2532748,fd=7))
</strong>> tcp   LISTEN 0      200            [::1]:5432          [::]:*    users:(("postgres",pid=2532748,fd=6))
</code></pre>

### Create PostgreSQL account user

* With user `admin`, change to the automatically created user for the PostgreSQL installation called `postgres`

```bash
$ sudo su - postgres
```

* Create a new database user

```bash
$ createuser --pwprompt --interactive
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