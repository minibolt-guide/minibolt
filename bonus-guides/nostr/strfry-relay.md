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

# Nostr relay (strfry)

[strfry](https://github.com/hoytech/strfry) is a high-performance C++ nostr relay with support for NIP-01 through NIP-50, real-time streaming, negentropy syncing, and an LMDB-backed storage engine that requires zero maintenance.

{% hint style="warning" %}
Difficulty: Medium
{% endhint %}

{% hint style="info" %}
This is an **alternative** to the [Nostr relay in Rust](nostr-relay.md) guide. Both are excellent relay implementations — choose one based on your preferences. If you already run nostr-rs-relay on port 8880, you must use a different port for strfry (e.g., 8881) or stop the existing relay first.
{% endhint %}

## Why strfry?

Compared to nostr-rs-relay:

* **LMDB storage** — zero-config, no external database needed (no PostgreSQL/SQLite setup)
* **Lower resource usage** — ~50MB RAM idle, scales to millions of events
* **Negentropy sync** — efficiently synchronize events between relays
* **Write policy plugins** — filter incoming events with external scripts
* **C++ performance** — handles thousands of concurrent WebSocket connections

## Requirements

* No additional services required (unlike nostr-rs-relay which needs PostgreSQL)

## Preparations

### Install dependencies

* With user `admin`, install build dependencies

```bash
sudo apt update && sudo apt install -y git build-essential cmake libssl-dev zlib1g-dev liblmdb-dev libflatbuffers-dev libsecp256k1-dev libzstd-dev
```

### Create the `nostr` user

{% hint style="info" %}
If you already created the `nostr` user for the [Nostr relay in Rust](nostr-relay.md) guide, skip this step
{% endhint %}

* Create a dedicated user for the relay

```bash
sudo adduser --gecos "" --disabled-password nostr
```

### Create data directory

* Create a dedicated data directory for the relay database

```bash
sudo mkdir -p /data/nostr/strfry-db
```

* Assign ownership to the `nostr` user

```bash
sudo chown -R nostr:nostr /data/nostr/strfry-db
```

## Installation

### Build from source

* With user `admin`, clone the strfry repository

```bash
cd /tmp
git clone https://github.com/hoytech/strfry.git
cd strfry
```

* Initialize submodules

```bash
git submodule update --init
```

* Build with cmake

```bash
make setup-golpe
make -j$(nproc)
```

{% hint style="info" %}
The build process takes approximately 5-10 minutes depending on your hardware
{% endhint %}

* Install the binary system-wide

```bash
sudo install -m 0755 strfry /usr/local/bin/
```

* Verify the installation

```bash
strfry --version
```

Expected output:

```
strfry 1.1.0
```

* Clean up build files

```bash
cd /tmp && rm -rf strfry
```

## Configuration

### Create the configuration file

* Switch to the `nostr` user

```bash
sudo su - nostr
```

* Create the configuration file

{% hint style="warning" %}
Replace the placeholder values in the `info` section with your own relay details. Convert your npub to hex format using a tool like [damus.io/key](https://damus.io/key/)
{% endhint %}

```bash
cat > /home/nostr/strfry.conf << 'EOF'
##
## strfry config
##

db = "/data/nostr/strfry-db/"

relay {
    # Interface to listen on. Use 127.0.0.1 if behind a reverse proxy
    bind = "0.0.0.0"

    # Port to open for the relay (default: 8880)
    # Change this if you already run nostr-rs-relay on 8880
    port = 8880

    # Maximum number of open files/sockets
    nofiles = 524288

    # Maximum accepted incoming websocket frame size (bytes)
    maxWebsocketPayloadSize = 524288

    # Maximum number of websocket connections
    maxWebsocketConnections = 500

    # Websocket PING frequency (seconds)
    autoPingSeconds = 55

    # Enable compression for messages larger than threshold
    compression = true
    compressThreshold = 1024

    info {
        # NIP-11: Relay information document
        name = "My MiniBolt Relay"
        description = "A personal nostr relay running on MiniBolt"
        pubkey = "your_hex_pubkey_here"
        contact = "mailto:you@example.com"
        icon = ""
    }

    tempDir = "/data/nostr/strfry-db/tmp/"

    # If behind a reverse proxy, uncomment the appropriate header:
    # realIpHeader = "x-forwarded-for"      # For nginx
    # realIpHeader = "cf-connecting-ip"      # For Cloudflare Tunnel

    writePolicy {
        # Restrict writes to specific pubkeys (optional, uncomment to enable)
        # pubkeyWhitelist = ["hex_pubkey_1", "hex_pubkey_2"]

        # External write policy plugin (optional)
        plugin = ""
    }
}

events {
    # Maximum size of normalised JSON, in bytes
    maxEventSize = 524288

    # Reject events more than 30 minutes in the future
    rejectEventsNewerThanSeconds = 1800

    # Accept events of any age (0 = no limit)
    rejectEventsOlderThanSeconds = 0

    # Ephemeral events older than 60 seconds are rejected
    rejectEphemeralEventsOlderThanSeconds = 60

    # Ephemeral events are deleted after 5 minutes
    ephemeralEventsLifetimeSeconds = 300

    # Maximum number of tags allowed
    maxNumTags = 2000

    # Maximum size for tag values (bytes)
    maxTagValSize = 1024
}
EOF
```

* Create the temp directory for the database

```bash
mkdir -p /data/nostr/strfry-db/tmp
```

* Exit the `nostr` user session

```bash
exit
```

### Firewall

* Configure the firewall to allow incoming requests to the relay port

```bash
sudo ufw allow 8880/tcp comment 'allow strfry relay from anywhere'
```

## Create systemd service

* Create the systemd service file with security hardening

```bash
sudo nano /etc/systemd/system/strfry-relay.service
```

```ini
[Unit]
Description=strfry nostr relay
After=network-online.target
Wants=network-online.target

[Service]
WorkingDirectory=/home/nostr
ExecStart=/usr/local/bin/strfry --config /home/nostr/strfry.conf relay
Environment=STRFRY_CONFIG=/home/nostr/strfry.conf

User=nostr
Group=nostr

Type=simple
TimeoutStopSec=10
Restart=on-failure
RestartSec=5

# Security hardening
NoNewPrivileges=yes
ProtectSystem=strict
ReadWritePaths=/data/nostr/strfry-db

[Install]
WantedBy=multi-user.target
```

* Enable and start the service

```bash
sudo systemctl daemon-reload
sudo systemctl enable strfry-relay
sudo systemctl start strfry-relay
```

* Check the service status

```bash
sudo systemctl status strfry-relay
```

Expected output should include `Active: active (running)`.

* Check the relay logs

```bash
sudo journalctl -u strfry-relay -f
```

## Validation

### Test WebSocket connection

* Install `websocat` if not already available

```bash
sudo apt install -y websocat
```

* Test a basic nostr request

```bash
echo '["REQ","test",{"limit":1}]' | websocat ws://127.0.0.1:8880
```

You should receive a nostr response ending with `EOSE`.

### Test NIP-11 relay information

```bash
curl -s -H "Accept: application/nostr+json" http://127.0.0.1:8880/ | jq
```

Expected output should show your relay name, description, and other NIP-11 metadata.

## Reverse proxy (optional)

If you want to expose your relay to the internet with a domain name and TLS, configure a reverse proxy.

### Option A: Nginx + Let's Encrypt

* Install nginx if not already installed

```bash
sudo apt install -y nginx
```

* Create the nginx configuration

{% hint style="warning" %}
Replace `relay.example.com` with your actual domain
{% endhint %}

```bash
sudo nano /etc/nginx/sites-available/nostr-relay
```

```nginx
server {
    listen 443 ssl http2;
    server_name relay.example.com;

    ssl_certificate /etc/letsencrypt/live/relay.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/relay.example.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8880;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket timeout (24 hours)
        proxy_read_timeout 86400s;
        proxy_send_timeout 86400s;
    }
}

server {
    listen 80;
    server_name relay.example.com;
    return 301 https://$server_name$request_uri;
}
```

* Enable the site and restart nginx

```bash
sudo ln -sf /etc/nginx/sites-available/nostr-relay /etc/nginx/sites-enabled/
sudo nginx -t && sudo systemctl restart nginx
```

{% hint style="info" %}
Remember to uncomment `realIpHeader = "x-forwarded-for"` in strfry.conf when using nginx
{% endhint %}

### Option B: Cloudflare Tunnel

If you already have a [Cloudflare Tunnel](../networking/cloudflare-tunnel.md) configured, add the relay hostname to your tunnel config:

```yaml
ingress:
  - hostname: relay.example.com
    service: http://localhost:8880
```

* Restart cloudflared

```bash
sudo systemctl restart cloudflared
```

{% hint style="info" %}
Remember to uncomment `realIpHeader = "cf-connecting-ip"` in strfry.conf when using Cloudflare Tunnel
{% endhint %}

## Useful commands

### Import events from a JSONL file

```bash
sudo -u nostr strfry --config /home/nostr/strfry.conf import < events.jsonl
```

### Sync with another relay (negentropy)

```bash
sudo -u nostr strfry --config /home/nostr/strfry.conf sync wss://relay.example.com --dir both
```

### Export all events

```bash
sudo -u nostr strfry --config /home/nostr/strfry.conf export > backup.jsonl
```

### Check database info

```bash
sudo -u nostr strfry --config /home/nostr/strfry.conf info
```

### Compact the database

```bash
sudo -u nostr strfry --config /home/nostr/strfry.conf compact
```

## Upgrade

* Stop the service

```bash
sudo systemctl stop strfry-relay
```

* Build the new version

```bash
cd /tmp
git clone https://github.com/hoytech/strfry.git
cd strfry
git submodule update --init
make setup-golpe
make -j$(nproc)
```

* Install the new binary

```bash
sudo install -m 0755 strfry /usr/local/bin/
```

* Start the service and verify

```bash
sudo systemctl start strfry-relay
strfry --version
```

* Clean up

```bash
cd /tmp && rm -rf strfry
```

## Uninstall

### Remove the service

```bash
sudo systemctl stop strfry-relay
sudo systemctl disable strfry-relay
sudo rm /etc/systemd/system/strfry-relay.service
sudo systemctl daemon-reload
```

### Remove the binary

```bash
sudo rm /usr/local/bin/strfry
```

### Remove data (optional — this deletes all relay data)

```bash
sudo rm -rf /data/nostr/strfry-db
```

### Remove the user (optional — only if not shared with nostr-rs-relay)

```bash
sudo userdel -r nostr
```

### Remove firewall rule

```bash
sudo ufw delete allow 8880/tcp
```

## Port reference

|  Port |  Protocol |  Use          |
| ----- | --------- | ------------- |
|  8880 |  TCP      |  strfry relay WebSocket |
