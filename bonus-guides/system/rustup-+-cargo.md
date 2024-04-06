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

# Rustup + Cargo

{% hint style="success" %}
Difficulty: Easy
{% endhint %}

Rustup is a tool that allows you to easily install, update, and uninstall Rust, and it also includes Cargo, the Rust build tool, and package manage. With Rustup, you can manage your Rust toolchain and dependencies efficiently, making it a convenient choice for Rust developers.

<figure><img src="../../.gitbook/assets/rust-logo.png" alt="" width="563"><figcaption></figcaption></figure>

## Installation

Rustup is an installer for the systems programming language [Rust](https://www.rust-lang.org)

* With user `admin`, run the following in your terminal, then follow the on-screen instructions to install Rust

```bash
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

<details>

<summary>Expected output 🔽</summary>

<pre><code>info: downloading installer

Welcome to Rust!

This will download and install the official compiler for the Rust
programming language, and its package manager, Cargo.

Rustup metadata and toolchains will be installed into the Rustup
home directory, located at:

  /home/admin/.rustup

This can be modified with the RUSTUP_HOME environment variable.

The Cargo home directory is located at:

  /home/admin/.cargo

This can be modified with the CARGO_HOME environment variable.

The cargo, rustc, rustup and other commands will be added to
Cargo's bin directory, located at:

  /home/admin/.cargo/bin

This path will then be added to your PATH environment variable by
modifying the profile files located at:

  /home/admin/.profile
  /home/admin/.bashrc

You can uninstall at any time with rustup self uninstall and
these changes will be reverted.

Current installation options:


   default host triple: x86_64-unknown-linux-gnu
     default toolchain: stable (default)
               profile: default
  modify PATH variable: yes

1) Proceed with installation (default)
2) Customize installation
3) Cancel installation
><a data-footnote-ref href="#user-content-fn-1">1</a>
</code></pre>

</details>

{% hint style="warning" %}
When the prompt asks you to choose an option, type **"`1`"** and press **enter** or press **enter** directly to "Proceed with installation"
{% endhint %}

<details>

<summary>Example of expected output 🔽</summary>

```
info: profile set to 'default'
info: default host triple is x86_64-unknown-linux-gnu
info: syncing channel updates for 'stable-x86_64-unknown-linux-gnu'
info: latest update on 2023-07-13, rust version 1.71.0 (8ede3aae2 2023-07-12)
info: downloading component 'cargo'
  7.0 MiB /   7.0 MiB (100 %)   4.5 MiB/s in  1s ETA:  0s
info: downloading component 'clippy'
info: downloading component 'rust-docs'
 13.6 MiB /  13.6 MiB (100 %)   4.3 MiB/s in  3s ETA:  0s
info: downloading component 'rust-std'
 25.4 MiB /  25.4 MiB (100 %)   4.2 MiB/s in  6s ETA:  0s
info: downloading component 'rustc'
 64.0 MiB /  64.0 MiB (100 %)   4.4 MiB/s in 15s ETA:  0s
info: downloading component 'rustfmt'
info: installing component 'cargo'
info: installing component 'clippy'
info: installing component 'rust-docs'
 13.6 MiB /  13.6 MiB (100 %)   2.8 MiB/s in  4s ETA:  0s
info: installing component 'rust-std'
 25.4 MiB /  25.4 MiB (100 %)  12.7 MiB/s in  1s ETA:  0s
info: installing component 'rustc'
 64.0 MiB /  64.0 MiB (100 %)  13.9 MiB/s in  4s ETA:  0s
info: installing component 'rustfmt'
info: default toolchain set to 'stable-x86_64-unknown-linux-gnu'

  stable-x86_64-unknown-linux-gnu installed - rustc 1.71.0 (8ede3aae2 2023-07-12)


Rust is installed now. Great!

To get started you may need to restart your current shell.
This would reload your PATH environment variable to include
Cargo's bin directory ($HOME/.cargo/bin).

To configure your current shell, run:
source "$HOME/.cargo/env"
```

</details>

* Configure your current shell to reload your PATH environment variable to include Cargo's bin directory (`$HOME/.cargo/bin`)

```bash
$ source "$HOME/.cargo/env"
```

* Now check the correct installation of Rustup

```bash
$ rustc --version
```

**Example** of expected output:

```
> rustc 1.71.0 (8ede3aae2 2023-07-12)
```

* And cargo

```bash
$ cargo -V
```

**Example** of expected output:

```
> cargo 1.71.0 (cfd3bbd8f 2023-06-08)
```

## Upgrade

* With user `admin` type the appropriate command to get that&#x20;

```bash
$ rustup update
```

Expected output:

```
info: syncing channel updates for 'stable-x86_64-unknown-linux-gnu'
info: checking for self-update
[...]
```

## Uninstall

* With user `admin` type the appropriate command to get that&#x20;

```bash
$ rustup self uninstall
```

Expected output:

```
Thanks for hacking in Rust!

This will uninstall all Rust toolchains and data, and remove
$HOME/.cargo/bin from your PATH environment variable.
Continue? (y/N)
```

{% hint style="info" %}
Press "`y"` and enter
{% endhint %}

Expected output:

```
info: removing rustup home
info: removing cargo home
info: removing rustup binaries
info: rustup is uninstalled
```

[^1]: &#x20;Type "`1`" and press enter
