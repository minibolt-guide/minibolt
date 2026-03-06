# Rustup + Cargo

Rustup is a tool that allows you to easily install, update, and uninstall Rust, and it also includes Cargo, the Rust build tool, and package manage. With Rustup, you can manage your Rust toolchain and dependencies efficiently, making it a convenient choice for Rust developers.

{% hint style="success" %}
Difficulty: Easy
{% endhint %}

<figure><img src="../../.gitbook/assets/rust-logo.png" alt="" width="563"><figcaption></figcaption></figure>

## Installation

Rustup is an installer for the systems programming language [Rust](https://www.rust-lang.org)

* With user `admin`, run the following in your terminal, then follow the on-screen instructions to install Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
```

<details>

<summary><strong>Example</strong> of expected output 🔽</summary>

```
info: downloading installer
info: profile set to 'minimal'
info: default host triple is x86_64-unknown-linux-gnu
info: syncing channel updates for 'stable-x86_64-unknown-linux-gnu'
info: latest update on 2026-02-12, rust version 1.93.1 (01f6ddf75 2026-02-11)
info: downloading component 'cargo'
info: downloading component 'rust-std'
 28.1 MiB /  28.1 MiB (100 %)  14.0 MiB/s in  2s
info: downloading component 'rustc'
 74.4 MiB /  74.4 MiB (100 %)  14.9 MiB/s in  5s
info: installing component 'cargo'
info: installing component 'rust-std'
 28.1 MiB /  28.1 MiB (100 %)  13.0 MiB/s in  2s
info: installing component 'rustc'
 74.4 MiB /  74.4 MiB (100 %)  11.3 MiB/s in  6s
info: default toolchain set to 'stable-x86_64-unknown-linux-gnu'

  stable-x86_64-unknown-linux-gnu installed - rustc 1.93.1 (01f6ddf75 2026-02-11)


Rust is installed now. Great!

To get started you may need to restart your current shell.
This would reload your PATH environment variable to include
Cargo's bin directory ($HOME/.cargo/bin).

To configure your current shell, you need to source
the corresponding env file under $HOME/.cargo.

This is usually done by running one of the following (note the leading DOT):
. "$HOME/.cargo/env"            # For sh/bash/zsh/ash/dash/pdksh
source "$HOME/.cargo/env.fish"  # For fish
source $"($nu.home-path)/.cargo/env.nu"  # For nushell
```

</details>

{% hint style="info" %}
This process can take quite **a long time**, 10-15 minutes or more, depending on the performance of your device. Please be patient until the prompt shows again
{% endhint %}

* Configure your current shell to reload your PATH environment variable to include Cargo's bin directory (`$HOME/.cargo/bin`)

```bash
source "$HOME/.cargo/env"
```

* Now check the correct installation of Rustup

```bash
rustc --version
```

**Example** of expected output:

```
rustc 1.71.0 (8ede3aae2 2023-07-12)
```

* And cargo

```bash
cargo -V
```

**Example** of expected output:

```
cargo 1.71.0 (cfd3bbd8f 2023-06-08)
```

## Upgrade

* With user `admin` type the appropriate command to get that

```bash
rustup update
```

Expected output:

```
info: syncing channel updates for 'stable-x86_64-unknown-linux-gnu'
info: checking for self-update
[...]
```

## Uninstall

* With user `admin` type the appropriate command to get that

```bash
rustup self uninstall
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
