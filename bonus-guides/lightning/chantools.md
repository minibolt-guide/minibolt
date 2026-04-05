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
  tags:
    visible: true
---

# chantools

[chantools](https://github.com/lightninglabs/chantools) is a loose collection of tools all somehow related to [lnd](../../lightning/lightning-client.md) and Lightning Network channels.

{% hint style="success" %}
Difficulty: Easy
{% endhint %}

## Installation

* We'll download, verify, and install `chantools`. With the user `admin`. Navigate to the temporary directory&#x20;

```sh
cd /tmp
```

* Set a temporary version environment variable for the installation

```sh
VERSION=0.14.2
```

* Download the application, checksums, and signature

{% code overflow="wrap" %}
```sh
wget https://github.com/lightninglabs/chantools/releases/download/v$VERSION/chantools-linux-amd64-v$VERSION.tar.gz
```
{% endcode %}

{% code overflow="wrap" %}
```sh
wget https://github.com/lightninglabs/chantools/releases/download/v$VERSION/manifest-v$VERSION.sig
```
{% endcode %}

{% code overflow="wrap" %}
```sh
wget https://github.com/lightninglabs/chantools/releases/download/v$VERSION/manifest-v$VERSION.txt
```
{% endcode %}

### Checksum check <a href="#checksum-check" id="checksum-check"></a>

* Verify the signed checksum against the actual checksum of your download

{% code overflow="wrap" %}
```bash
sha256sum --check manifest-v$VERSION.txt --ignore-missing
```
{% endcode %}

**Example** of expected output:

{% code overflow="wrap" %}
```
chantools-linux-arm64-v0.14.1.tar.gz: OK
```
{% endcode %}

### Signature check <a href="#signature-check" id="signature-check"></a>

Now that we've verified the integrity of the downloaded binary, we need to check the authenticity of the manifest file we just used, starting with its signature.

* Get the public key from a LND developer, who signed the manifest file, and add it to your GPG keyring

```sh
curl https://keybase.io/guggero/pgp_keys.asc | gpg --import
```

**Example** of expected output:

<pre><code>gpg: directory '/home/admin/.gnupg' created
gpg: keybox '/home/admin/.gnupg/pubring.kbx' created
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 19417  100 19417    0     0  25893      0 --:--:-- --:--:-- --:--:-- 25923
gpg: key 8E4256593F177720: 1 signature not checked due to a missing key
gpg: /home/admin/.gnupg/trustdb.gpg: trustdb created
gpg: key 8E4256593F177720: public key "Oliver Gugger &#x3C;gugger@gmail.com>" <a data-footnote-ref href="#user-content-fn-1">imported</a>
gpg: Total number processed: 1
gpg:               imported: 1
gpg: no ultimately trusted keys found
</code></pre>

* Verify the signature of the text file containing the checksums for the application

```sh
gpg --verify manifest-v$VERSION.sig manifest-v$VERSION.txt
```

**Example** of expected output:

<pre><code> gpg: Signature made Fri 07 Oct 2022 07:46:11 AM UTC
 gpg:                using RSA key F4FC70F07310028424EFC20A8E4256593F177720
 gpg: <a data-footnote-ref href="#user-content-fn-1">Good signature</a> from "Oliver Gugger &#x3C;gugger@gmail.com>" [unknown]
 gpg: WARNING: This key is not certified with a trusted signature!
 gpg:          There is no indication that the signature belongs to the owner.
 Primary key fingerprint: F4FC 70F0 7310 0284 24EF  C20A 8E42 5659 3F17 7720
</code></pre>

* Extract chantools

```sh
tar -xzvf chantools-linux-amd64-v$VERSION.tar.gz
```

**Example** of expected output:

{% code overflow="wrap" %}
```
chantools-linux-arm64-v0.14.2/
chantools-linux-arm64-v0.14.2/chantools
```
{% endcode %}

### Binaries installation <a href="#binaries-installation" id="binaries-installation"></a>

-> 2 options, depending on whether you want to use it only once or make a permanent installation:

{% tabs %}
{% tab title="1. Temporary use (recommended)" %}
In this case, only go to the proper step to use this tool in a concrete case. e.g: Recover the BIP32 Master Extended Private Key [option 1](../../lightning/lightning-client.md#id-1.-for-temporary-use-option-recommended-1)
{% endtab %}

{% tab title="2. Permanent installation" %}
* Install the binaries on the OS

{% code overflow="wrap" %}
```bash
sudo install -m 0755 -o root -g root -t /usr/local/bin/ chantools-linux-amd64-v$VERSION/chantools
```
{% endcode %}

* Verify the correct installation

{% code overflow="wrap" %}
```bash
chantools -v
```
{% endcode %}

**Example** of expected output:

{% code overflow="wrap" %}
```
chantools version v0.14.1, commit
```
{% endcode %}

* **(Optional)** Delete the installation files of the `/tmp` folder to be ready for the next upgrade

{% code overflow="wrap" %}
```bash
sudo rm -r chantools-linux-amd64-v$VERSION chantools-linux-amd64-v$VERSION.tar.gz manifest-v$VERSION.txt manifest-v$VERSION.sig
```
{% endcode %}
{% endtab %}
{% endtabs %}

## Upgrade

Follow the complete [Installation section](chantools.md#installation) until the [Binaries installation section](chantools.md#binaries-installation) (included).

## Uninstall

### Uninstall binaries

* Delete the binaries installed (only in case of [2. Permanent installation](chantools.md#id-2.-permanent-installation))

```bash
sudo rm /usr/local/bin/chantools
```

[^1]: Check this
