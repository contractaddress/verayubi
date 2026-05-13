# Verayubi

![verayubi-thumnail](public/verayubi.png)

### If you'd like to know more read my blog post @ {placeholder}

Verayubi is a simple script to create/manage veracrypt containers using your yubikey.   

---
### Prerequisites:

packages:

```bash
sudo pacman -S yubikey-manager veracrypt
```
program slot2 with challenge-response (backup the key, keep secret)

```bash
ykman otp chalresp --touch 2
```

provide your hex challenge for `CHALLENGE=` in the script you can generate it with:

```bash
openssl rand -hex 15
```
do not lose the challenge, you can hardcore it. it does not need to be kept secret.
