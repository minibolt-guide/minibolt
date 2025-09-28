---
title: Download the White Paper
parent: + Bitcoin
grand_parent: Bonus Section
nav_exclude: true
has_children: false
has_toc: false
---

# Download the bitcoin whitepaper

Download the Bitcoin white paper PDF directly from the blockchain data on your node and witness the power of a decentralized network to fight censorship.

{% hint style="success" %}
Difficulty: Easy
{% endhint %}

<figure><img src="../../.gitbook/assets/whitepaper_screen.png" alt=""><figcaption></figcaption></figure>

## Introduction

The Bitcoin whitepaper PDF was encoded in the blockchain in April 2013, in the transaction `54e48e5f5c656b26c3bca14a8c95aa583d07ebe84dde3b7dd4a78f4e4186e713` of block `230009.`

The transaction contains 947 outputs and the sender spent almost 60 million sats as miner fee! Some explanations of how the paper is encoded in the transaction are given in a [Bitcoin StackExchange post](https://bitcoin.stackexchange.com/questions/35959/how-is-the-whitepaper-decoded-from-the-blockchain-tx-with-1000x-m-of-n-multisi/35970#35970) from 2015.

This guide explains how to reconstruct the Bitcoin white paper PDF using your verified blockchain data. No matter how censored the white paper could become (see [this article about white paper copyright claims](https://bitcoinmagazine.com/business/copa-suing-craig-wright-over-bitcoin-white-paper-claims)), you will know how to recreate and share the foundational document of Bitcoin.

## Preparations

* Update the OS

```sh
sudo apt update && sudo apt full-upgrade
```

* Install `jq`, JSON processor that will be used to parse the transaction data

```bash
sudo apt install jq
```

## Extract the whitepaper directly from Bitcoin Core

* With the `admin` user, go to the temporary folder

```sh
cd /tmp
```

* Use `bitcoin-cli` to download and create the PDF

<pre class="language-sh" data-overflow="wrap"><code class="lang-sh"><strong>bitcoin-cli getrawtransaction 54e48e5f5c656b26c3bca14a8c95aa583d07ebe84dde3b7dd4a78f4e4186e713 true | jq -r '.vout[].scriptPubKey.asm' | cut -c3- | xxd -p -r | tail +9c | head -c 184292 > bitcoin.pdf
</strong></code></pre>

* Check PDF was correctly created

```bash
ls -la bitcoin.pdf
```

Expected output:

<pre><code><strong>-rw-rw-r-- 1 admin admin 184292 Jul 25 21:08 bitcoin.pdf
</strong></code></pre>

### How does this work?

Here's how the long command from above actually works:

*   With `bitcoin-cli getrawtransaction`, you get the raw data of the transaction with this specific transaction id. This command returns the result as a JSON object.

    You can run `bitcoin-cli help getrawtransaction` to learn more.
*   The result is handed over ("piped") to the next command: `jq -r '.vout[].scriptPubKey.asm'`. This instruction extracts the assembly data from the "scriptPubKey" for all transaction outputs, where the Bitcoin whitepaper data is stored.

    Run `jq --help` for more information.
*   The result is then piped into the `cut -c3-` command, which cuts off the first two characters on every line.

    Check out `cut --help` to learn more.
*   The command `xxd -p -r` takes the previous result as input and converts everything from hex into binary encoding.

    Run `xxd --help` for more about this command.
*   Then, `tail +9c` output the data starting with the 9th byte

    Use `tail --help` it to learn more.
*   Finally, the data is piped into `head -c 184292`. This command sends the first 184292 bytes onwards.

    Run `head --help` for more information.
* The argument `> bitcoin.pdf` then takes the whole data input stream and stores it in the file "bitcoin.pdf".

This concatenation of simple commands is a shining example of one of the core principles of Linux. The character `|` allows us to string them together to create powerful yet efficient data processing.

### Send the PDF to your computer

To be read, the PDF can now be sent from the remote node to your local computer using the [scp](https://www.man7.org/linux/man-pages/man1/scp.1.html) utility.

*   **macOS or Linux**

    On your local computer, open a terminal window and type the following command. Replace YourNodeIP with the MiniBolt IP address (or `minibolt.local` if it works) and do not forget the dot at the end of the line (representing the destination of the file, here the 'Home' folder of your local computer)

```sh
scp admin@YourNodeIP:/tmp/bitcoin.pdf .
```

*   **Windows**

    This also works with the PSCP tool from PuTTY that you can run from the command line. See [How to Use Putty pscp to Copy Files](https://tonyteaches.tech/putty-pscp-tutorial/) for more information

```sh
pscp admin@YourNodeIP:/tmp/bitcoin.pdf .
```

* The file should now be located in the Home folder of your local computer.

## Get the whitepaper from BTC RPC Explorer

The BTC RPC Explorer has also a functionality to extract the data from the node and display the PDF in the web browser.

![](../../images/white-paper-transac.png)

* Open your Explorer at [https://minibolt.local:4000](https://miniboltt.local:4000/) or replace "minibolt.local" with your node IP address if needed)
* Look up the transaction ID in explorer: `54e48e5f5c656b26c3bca14a8c95aa583d07ebe84dde3b7dd4a78f4e4186e713`
* Click on the link "bitcoin whitepaper" in the top box, this will generate the PDF from the node blockchain and display it as a PDF file in the browser
* Alternatively, use the following direct URL: [https://minibolt.local:4000/bitcoin-whitepaper](https://minibolt.local:4000/bitcoin-whitepaper)
