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

# Nostr Relay

A nostr relay written in Rust with support for the entire relay protocol and data persistence using SQLite

<figure><img src="../../.gitbook/assets/nostr-relay-gif.gif" alt=""><figcaption></figcaption></figure>

## Requisites

* [Cloudflare tunnel](../system/cloudflare-tunnel.md)

## Preparations

#### Install dependencies

* With user `admin`, make sure that all necessary software packages are installed

```bash
$ sudo apt install pkg-config build-essential libssl-dev jq
```

* Check if you already have Rustc

```bash
$ rustc --version
```

**Example** of expected output:

```
> rustc 1.71.0 (8ede3aae2 2023-07-12)
```

* &#x20;And cargo installed

```bash
$ cargo -V
```

**Example** of expected output:

```
> cargo 1.71.0 (cfd3bbd8f 2023-06-08)
```

{% hint style="info" %}
If you obtain "command not found" outputs, you need to follow the [Rustup + Cargo bonus section](rustup-+-cargo.md) to install it and then come back to continue with the guide
{% endhint %}
