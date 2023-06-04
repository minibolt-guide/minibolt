---
layout: default
title: Pimp the CLI
parent: + System
grand_parent: Bonus Section
nav_exclude: true
has_toc: false
---
<!-- markdownlint-disable MD014 MD022 MD025 MD033 MD040 -->

# Bonus guide: Pimp the command line

{: .no_toc }

---

In this section, we are going to do instructions for changing the prompt "$" symbol to the Bitcoin symbol "₿" and color and install bash completion scripts for Bitcoin Core and Lightning projects command CLI instructions.

Difficulty: Easy
{: .label .label-green }

Status: Tested MiniBolt
{: .label .label-blue }

---

## Table of contents
{: .no_toc .text-delta }

1. TOC
{:toc}

---

### Command prompt

You can prettify your command prompt for each user by enabling color output and setting a custom prompt

* Open and edit `.bashrc` as shown below, save and exit

  ```sh
  $ nano /home/admin/.bashrc --linenumbers
  ```

* Uncomment line 46

  ```
  force_color_prompt=yes
  ```

* Comment existing line 60 (backup) and add the next line (in line 61)

  ```
  #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
  PS1="${debian_chroot:+($debian_chroot)}\[\e[33m\]\u \[\033[01;34m\]\w\[\e[33m\] ₿\[\e[m\] "
  ```

* Insert the following at the end of the file (line 121)

  ```
  alias ls='ls -la --color=always'
  ```

![Pimp prompt](../../../images/60_pimp_prompt_update.png)

* Apply changes

  ```sh
  $ source /home/admin/.bashrc
  ```

![Pimped prompt](../../../images/60_pimp_prompt_result.png)

### Bash completion

As user “admin”, install bash completion scripts for Bitcoin Core and all Lightning projects. You then can complete partial commands by pressing the Tab key (e.g. bitcoin-cli getblockch [Tab] → bitcoin-cli getblockchaininfo )

  ```sh
  $ cd /tmp/
  $ wget https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/completions/bash/bitcoind.bash-completion
  $ wget https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/completions/bash/bitcoin-cli.bash-completion
  $ wget https://raw.githubusercontent.com/lightningnetwork/lnd/master/contrib/lncli.bash-completion
  $ sudo cp *.bash-completion /etc/bash_completion.d/
  ```

Bash completion will be enabled after your next login.

<br /><br />

---

<< Back: [+ System](index.md)
