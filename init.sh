#!/bin/bash

IMAGE_URL="https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-nocloud-amd64.qcow2"
BASE_DIR="$(dirname "$0")/image"
BASE_IMAGE="debian-base.qcow2"
TEMP_SNAP="prep_snap.qcow2"
SEED_ISO="seed.iso"
GUEST_USER="cobaia"
BASE_SHARED="/home/$GUEST_USER/code"

echo "[*] Verifing base image"
if [ ! -f "$BASE_DIR/$BASE_IMAGE" ]; then
    echo "[+] Transfering image debian-nocloud..."
    curl -sL $IMAGE_URL -o $BASE_DIR/$BASE_IMAGE
fi

echo "[+] Resizing image..."
qemu-img resize "$BASE_DIR/$BASE_IMAGE" 16G

echo "[+] Customizing image..."
virt-customize -a "$BASE_DIR/$BASE_IMAGE" \
    --install ssh,curl,net-tools,vim \
    --install build-essential,gdb,gcc-multilib,python3-pip,git \
    --run-command "useradd -m -s /bin/bash $GUEST_USER" \
    --password $GUEST_USER:password:$GUEST_USER \
    --run-command "usermod -aG sudo $GUEST_USER" \
    --run-command "sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config" \
    --run-command "systemctl enable ssh" \
    --edit '/etc/sudoers: s/^%sudo.*/%sudo ALL=(ALL) NOPASSWD:ALL/' \
    --run-command "mkdir -p $BASE_SHARED" \
    --run-command "chown $GUEST_USER:$GUEST_USER $BASE_SHARED" \
    --append-line "/etc/fstab:host_share $BASE_SHARED 9p trans=virtio,version=9p2000.L,rw,_netdev 0 0"

echo "[+] Success! Image has been customized and saved as '$BASE_IMAGE'."

mkdir -p ./shared_code
