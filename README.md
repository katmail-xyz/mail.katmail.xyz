# katmail.xyz installation guide
Setup in this order....

## Certificate for DANE-SMTP
Use rolling letsencrypt certificates.
Initial setup:

`sudo certbot certonly --preferred-challenges=dns --dns-cloudflare --dns-cloudflare-credentials ./DOMAIN.cf.ini -d DOMAIN`

Certs are stored in `/etc/letsencrypt/live/DOMAIN/`.

Then, setup systemd-timer job to do renewals, while preserving the same private key.

`certbot renew --preferred-challenges=dns --dns-cloudflare --dns-cloudflare-credentials /etc/letsencrypt/cf-creds/katmail.xyz.cf.ini --reuse-key`

To generate TSLA record:

Run `dane/gen-smtp-tsla.sh` and store the DNS record under `TSLA:_25.tcp`
Cloudflare has a pretty-formated TSLA record entry process, so fill in the blanks as required.
Running certbot with `--reuse-key` should avoid the need to have to change this DNS record.

## DKIM (DomainKeys Identified Mail)
Install the OpenDKIM package (https://wiki.archlinux.org/index.php/OpenDKIM)

### Intial setup (generating a 2048-bit RSA key):

`openssl genrsa -out DOMAIN.dkim.key 2048`

Run `dkim/gen-dkim-dns-record.sh` to obtain dkim dns record under `TXT:default._domainkey`

### Whitelisting bad signature domains:

Update `/etc/opendkim/ExemptDomains`. Format:

```
foo.bar
```

### Enable Service
Copy across the systemd service script and enable it via Systemd.

## SPF (Sender Policy Framework)
Populate the entries in {ip4,ip6,include}.list.
ip4,ip6 entries should follow CIDR notation.

Run `spf/spf.sh` to obtain the SPF dns record and store under `TXT:_spf`

## DMARC
### Outgoing
Store `v=DMARC1; p={quarantine,reject}; rua=mailto:CONTACT_EMAIL; adkim=s; aspf=s;` under `TXT:_dmarc`

### Incoming
1. Install the [OpenDMARC package](https://wiki.archlinux.org/index.php/OpenDMARC)
2. Add `opendmarc/opendmarc.conf` to `/etc/opendmarc/opendmarc.conf`
3. The Arch package ships with standard systemd-service files. Just tweak override in `/etc/systemd/system/opendmarc.service.d/override.conf`:
```
[Service]
Group=
Group=postfix
```
4. Create UNIX domain socket dir
```
mkdir /run/opendmarc
chown opendmarc:postfix /run/opendmarc
```
5. Enable the service.

## DKIM
DKIM sign outgoing emails and also check incoming emails for DKIM validity.

1. Install the [OpenDKIM package](https://wiki.archlinux.org/index.php/OpenDKIM)
2. Generate the DKIM key `opendkim-genkey -r -s myselector -b 2048 -d example.com`
3. Add `opendkim/opendkim.conf` to `/etc/opendkim/opendkim.conf`.
4. Add `opendkim/opendkim.service` to `/etc/systemd/system/`. Enable and start.

## Dovecot
IMAP/POP3 Server

### Installation
1. Run `dovecot/virtual-user-install.sh` on remote.
2. Copy over configurations to `/etc/dovecot` on remote.
3. Setup database for Virtual Users

### Folders
Get users to push their folders from MUA to the IMAP Server.

## Postfix
### Setting up Postfix to use Dovecot Authentication
[Manual](https://wiki2.dovecot.org/HowTo/PostfixAndDovecotSASL)

No SASL With Postfix Submission Port since reliant on Dovecot Virtual Users.

The current `main.cf` and `dovecot.conf` files already does set this up.

### OpenDKIM and OpenDMARC plugins:
```
non_smtpd_milters   = unix:/run/opendkim/opendkim.sock, unix:/run/opendmarc/opendmarc.sock
smtpd_milters       = unix:/run/opendkim/opendkim.sock, unix:/run/opendmarc/opendmarc.sock
```

###Strong DHE Parameters:

Download [3072/4096-bit parameters](https://github.com/internetstandards/dhe_groups) and save to `/etc/postfix/ssl-dhparam`.

## MTA-STS
Host `.well-known/mta-sts.txt` at `https://mta-sts.[your-domain]/.well-known/mta-sts.txt`.

```
version: STSv1
mode: enforce
mx: mail.katmail.xyz
max_age: 604800
```

Also remember to insert 2 DNS TXT Records:

1. `v=TLSRPTv1; rua=mailto:EMAIL` for `_smtp._tls`.
2. `v=STSv1; id=(increasing nonce)` for `_mta-sts`.

Use `https://aykevl.nl/apps/mta-sts/` to check if setup correctly.
