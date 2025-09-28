# Go

[Go](https://github.com/golang/go) is an agent-based programming language in the tradition of logic-based programming languages like Prolog designed at Google.

{% hint style="success" %}
Difficulty: Easy
{% endhint %}

<figure><img src="../../.gitbook/assets/golang.png" alt="" width="563"><figcaption></figcaption></figure>

## Installation

* With user `admin`, go to the temporary folder

```bash
cd /tmp
```

* Set a temporary version environment variable to the installation

```bash
VERSION=1.24.1
```

* Set a temporary SHA256 environment variable to the installation

```bash
SHA256=cb2396bae64183cdccf81a9a6df0aea3bce9511fc21469fb89a0c00470088073
```

* Get the latest binary of the [official repository](https://go.dev/dl/)

```bash
wget https://go.dev/dl/go$VERSION.linux-amd64.tar.gz
```

* Check the checksum of the file

```bash
echo "$SHA256 go$VERSION.linux-amd64.tar.gz" | sha256sum --check
```

**Example** of expected output:

<pre><code><strong>go1.21.10.linux-amd64.tar.gz: OK
</strong></code></pre>

* Extract and install Go in the `/usr/local` directory

```bash
sudo tar -C /usr/local -xzvf go$VERSION.linux-amd64.tar.gz
```

* Add the next line at the end of the `/etc/profile` file

```bash
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile
```

Expected output:

```
export PATH=$PATH:/usr/local/go/bin
```

* Apply the changes immediately to the current session

```bash
source /etc/profile
```

* Verify that you've installed Go by typing the following command

```bash
go version
```

**Example** of expected output:

```
go version go1.21.10 linux/amd64
```

* **(Optional)** Delete the file of the temporary folder to be immediately ready for the next update

```bash
rm go$VERSION.linux-amd64.tar.gz
```

## Upgrade

* With user `admin`, remove any previous Go installation

```bash
sudo rm -rf /usr/local/go
```

* Go to the temporary folder

```bash
cd /tmp
```

* Set a temporary version environment variable with the new value, to the installation

```bash
VERSION=1.24.1
```

* Set the new temporary SHA256 environment variable to the installation

```bash
SHA256=cb2396bae64183cdccf81a9a6df0aea3bce9511fc21469fb89a0c00470088073
```

* Get the latest binary of the [official repository](https://go.dev/dl/)

```bash
wget https://go.dev/dl/go$VERSION.linux-amd64.tar.gz
```

* Check the checksum of the file

```bash
echo "$SHA256 go$VERSION.linux-amd64.tar.gz" | sha256sum --check
```

**Example** of expected output:

```
go1.22.3.linux-amd64.tar.gz: OK
```

* Extract and install Go in the `/usr/local` directory

```bash
sudo tar -C /usr/local -xzvf go$VERSION.linux-amd64.tar.gz
```

* Verify that you've updated Go by typing the following command

```
go version
```

**Example** of expected output:

```
go version go1.22.3 linux/amd64
```

* **(Optional)** Delete the file of the temporary folder to be immediately ready for the next update

```bash
rm go$VERSION.linux-amd64.tar.gz
```

## Uninstall

* Delete go folder

```bash
sudo rm -rf /usr/local/go
```

* Edit `/etc/profile` file and delete the complete `export PATH=$PATH:/usr/local/go/bin` line at the end of the file. Save and exit

```bash
sudo nano /etc/profile
```

* Apply the changes immediately to the current session

```bash
source /etc/profile
```

* Ensure you are uninstalled Go definitely

```bash
go version
```

Expected output:

```
-bash: /usr/local/go/bin/go: No such file or directory
```

Next new session you will obtain this command when you try `go version` command:

```
Command 'go' not found..
```
