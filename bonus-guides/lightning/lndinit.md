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

# lndinit

The main purpose of [lndinit](https://github.com/lightninglabs/lndinit) is to help automate the [lnd](../../lightning/lightning-client.md) wallet initialization, including seed and password generation.

## Installation

* We'll download, verify, and install `lndinit`. With the user `admin`. Navigate to the temporary directory

```bash
cd /tmp
```

* Set a temporary version environment variable for the installation

```bash
VERSION=0.1.33
```

* Download the application, checksums, and signature

{% code overflow="wrap" %}
```bash
wget https://github.com/lightninglabs/lndinit/releases/download/v$VERSION-beta/lndinit-linux-amd64-v$VERSION-beta.tar.gz
```
{% endcode %}

{% code overflow="wrap" %}
```bash
wget https://github.com/lightninglabs/lndinit/releases/download/v$VERSION-beta/manifest-v$VERSION-beta.txt
```
{% endcode %}

{% code overflow="wrap" %}
```bash
wget https://github.com/lightninglabs/lndinit/releases/download/v$VERSION-beta/manifest-v$VERSION-beta.sig.ots
```
{% endcode %}

{% code overflow="wrap" %}
```bash
wget https://github.com/lightninglabs/lndinit/releases/download/v$VERSION-beta/manifest-v$VERSION-beta.sig
```
{% endcode %}

### Checksum check <a href="#checksum-check" id="checksum-check"></a>

* Verify the signed checksum against the actual checksum of your download

```bash
sha256sum --check manifest-v$VERSION-beta.txt --ignore-missing
```

**Example** of expected output:

```
lndinit-linux-amd64-v0.1.26-beta.tar.gz: OK
```

### Signature check <a href="#signature-check" id="signature-check"></a>

Now that we've verified the integrity of the downloaded binary, we need to check the authenticity of the manifest file we just used, starting with its signature.

* Get the public key from a LND developer, who signed the manifest file, and add it to your GPG keyring

```bash
curl https://keybase.io/guggero/pgp_keys.asc | gpg --import
```

Expected output:

<pre><code>  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 19417  100 19417    0     0   1799      0  0:00:10  0:00:10 --:--:--  4130
gpg: key 8E4256593F177720: 1 signature not checked due to a missing key
gpg: key 8E4256593F177720: "Oliver Gugger &#x3C;gugger@gmail.com>" <a data-footnote-ref href="#user-content-fn-1">imported</a>
gpg: Total number processed: 1
gpg:              unchanged: 1
</code></pre>

* Verify the signature of the text file containing the checksums for the application

```bash
gpg --verify manifest-v$VERSION-beta.sig manifest-v$VERSION-beta.txt
```

**Example** of expected output:

<pre><code>gpg: Signature made Tue 15 Apr 2025 05:16:09 PM UTC
gpg:                using RSA key F4FC70F07310028424EFC20A8E4256593F177720
gpg: <a data-footnote-ref href="#user-content-fn-1">Good signature</a> from "Oliver Gugger &#x3C;gugger@gmail.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: F4FC 70F0 7310 0284 24EF  C20A 8E42 5659 3F17 7720
</code></pre>

### Timestamp check <a href="#timestamp-check" id="timestamp-check"></a>

We can also check that the manifest file was in existence around the time of the release using its timestamp.

* Let's verify that the timestamp of the file matches the release date

```bash
ots --no-cache verify manifest-v$VERSION-beta.sig.ots -f manifest-v$VERSION-beta.sig
```

**Example** of expected output:

<pre><code>Got 1 attestation(s) from https://alice.btc.calendar.opentimestamps.org
Got 1 attestation(s) from https://bob.btc.calendar.opentimestamps.org
Got 1 attestation(s) from https://finney.calendar.eternitywall.com
<a data-footnote-ref href="#user-content-fn-1">Success</a>! Bitcoin block 892581 attests existence as of 2025-04-15 UTC
</code></pre>

{% hint style="info" %}
Check that the date of the timestamp is close to the [release date](https://github.com/lightninglabs/lndinit/releases) of the lndinit binary
{% endhint %}

* Having verified the integrity and authenticity of the release binary, we can safely

```bash
tar -xzvf lndinit-linux-amd64-v$VERSION-beta.tar.gz
```

**Example** of expected output:

```
lndinit-linux-amd64-v0.1.26-beta/lndinit
lndinit-linux-amd64-v0.1.26-beta/
```

### Binaries installation <a href="#binaries-installation" id="binaries-installation"></a>

-> 2 options, depending on whether you want to use it only once or make a permanent installation:

{% tabs %}
{% tab title="1. Temporary use (recommended)" %}
In this case, only go to the proper step to use this tool in a concrete case. e.g: Migrate bbolt database to PostgreSQL [option 1](../../lightning/lightning-client.md#id-1.-for-temporary-use-option-recommended)
{% endtab %}

{% tab title="2. Permanent installation" %}
* Install the binaries on the OS

{% code overflow="wrap" %}
```bash
sudo install -m 0755 -o root -g root -t /usr/local/bin lndinit-linux-amd64-v$VERSION-beta/lndinit
```
{% endcode %}

* Verify the correct installation

{% code overflow="wrap" %}
```bash
lndinit -h 2>&1 | grep Version
```
{% endcode %}

**Example** of expected output:

```
2026-03-04 11:22:21.211 [INF]: LNDINIT Version 0.1.33-beta commit=v0.1.33-beta, debuglevel=
```

* **(Optional)** Clean the `lndinit` files in the `tmp` folder

{% code overflow="wrap" %}
```bash
sudo rm -r lndinit-linux-amd64-v$VERSION-beta && sudo rm lndinit-linux-amd64-v$VERSION-beta.tar.gz && sudo rm manifest-v$VERSION-beta.sig && sudo rm manifest-v$VERSION-beta.txt && sudo rm manifest-v$VERSION-beta.sig.ots
```
{% endcode %}
{% endtab %}
{% endtabs %}

## Upgrade

Follow the complete [Installation section](lndinit.md#installation) until the [Binaries installation section](lndinit.md#binaries-installation) (included).

## Uninstall

### Uninstall binaries

* Delete the binaries installed (only in case of [2. Permanent installation](lndinit.md#id-2.-permanent-installation))

```bash
sudo rm /usr/local/bin/lndinit
```

[^1]: Check this
