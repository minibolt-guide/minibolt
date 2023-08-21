---
title: Pimp the CLI
parent: + System
grand_parent: Bonus Section
nav_exclude: true
has_toc: false
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

# Pimp the command line

In this section, we are going to do instructions for changing the prompt "$" symbol to the Bitcoin symbol "₿" and color and install bash completion scripts for Bitcoin Core and Lightning projects command CLI instructions.

{% hint style="success" %}
Difficulty: Easy
{% endhint %}

### Command prompt

You can prettify your command prompt for each user by enabling color output and setting a custom prompt

* With user `admin`, open and edit `.bashrc` as shown below. Save and exit

```sh
$ nano /home/admin/.bashrc --linenumbers
```

* Uncomment line 46

```
force_color_prompt=yes
```

* Comment the existing line 60 (backup) and add the next line (in line 61)

```
#PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
PS1="${debian_chroot:+($debian_chroot)}\[\e[33m\]\u \[\033[01;34m\]\w\[\e[33m\] ₿\[\e[m\] "
```

* Insert the following at the end of the file (line 121)

```
alias ls='ls -la --color=always'
```

![](../../images/60\_pimp\_prompt\_update.png)

* Apply changes

```sh
$ source /home/admin/.bashrc
```

![](../../images/60\_pimp\_prompt\_result.png)

### Bash completion

* As user `admin`, install bash completion scripts for Bitcoin Core and all Lightning projects. You then can complete partial commands by pressing the Tab key (e.g. bitcoin-cli getblockch \[Tab] → bitcoin-cli getblockchaininfo )

```bash
$ cd /tmp/
```

<pre class="language-bash" data-overflow="wrap"><code class="lang-bash"><strong>$ wget https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/completions/bash/bitcoind.bash-completion
</strong></code></pre>

{% code overflow="wrap" %}
```bash
$ wget https://raw.githubusercontent.com/bitcoin/bitcoin/master/contrib/completions/bash/bitcoin-cli.bash-completion
```
{% endcode %}

{% code overflow="wrap" %}
```bash
$ wget https://raw.githubusercontent.com/lightningnetwork/lnd/master/contrib/lncli.bash-completion
```
{% endcode %}

```bash
$ sudo cp *.bash-completion /etc/bash_completion.d/
```

{% hint style="info" %}
Bash completion will be enabled after your next login
{% endhint %}
