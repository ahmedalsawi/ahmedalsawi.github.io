---
title: "Encrypt Hard drive with cryptsetup"
date: 2020-11-08T15:46:08+02:00
toc: false
images:
tags:
  - IT
---

# prerequisite

```bash
sudo apt install cryptsetup parted
export DRIVE=sdc
```

# Create partition
```bash
sudo dd if=/dev/zero of=/dev/$DRIVE bs=512 count=1 conv=notrunc
sudo parted /dev/$DRIVE
(parted) mkpart primary ext4 0% 100%
(parted) print
(parted) quit
```

# Encrypt partition

```bash
# Encrypt the partition with password
sudo cryptsetup --verbose --verify-passphrase luksFormat /dev/${DRIVE}1

# Open luks with password above
sudo cryptsetup luksOpen /dev/${DRIVE}1 ${DRIVE}1
# Create ext4 filesystem
sudo mkfs.ext4 /dev/mapper/${DRIVE}1
# clean-up luks
sudo cryptsetup luksClose ${DRIVE}1
```

# Test partition

```bash
sudo cryptsetup luksOpen /dev/${DRIVE}1 ${DRIVE}1

##  Mount partition 
mkdir -p /media/`whoami`/${DRIVE}1
sudo mount /dev/mapper/${DRIVE}1 /media/`whoami`/${DRIVE}1

# fix permission
sudo chown -R `whoami`:users /media/`whoami`/${DRIVE}1

# clean-up
sudo umount /media/`whoami`/${DRIVE}1
rm -rf /media/`whoami`/${DRIVE}1

sudo cryptsetup luksClose ${DRIVE}1
```