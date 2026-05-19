#!/bin/bash

TEMP_SNAP="prep_snap.qcow2"

if ! command -v python3 &> /dev/null; then
    echo "[-] python3 is not installed. Please install it and try again."
    exit 1
fi
eval "$(python3 parse_config.py)"

echo "[*] Verifing base image"
if [ ! -f "$BASE_DIR/original_image.qcow2" ]; then
    echo "[+] Transfering image..."
    curl -sL $IMAGE_URL -o $BASE_DIR/$BASE_IMAGE

    cp "$BASE_DIR/$BASE_IMAGE" "$BASE_DIR/original_image.qcow2"
else
    echo -e "[+] Using existing image...\n If you want to start from scratch, delete '$BASE_DIR/original_image.qcow2' and run this script again."
    cp "$BASE_DIR/original_image.qcow2" "$BASE_DIR/$BASE_IMAGE"
fi

echo "[+] Resizing image..."
mv "$BASE_DIR/$BASE_IMAGE" "$BASE_DIR/unsized_image.qcow2"
qemu-img create -f qcow2 "$BASE_DIR/$BASE_IMAGE" 16G
virt-resize --expand /dev/vda1 "$BASE_DIR/unsized_image.qcow2" "$BASE_DIR/$BASE_IMAGE"
rm "$BASE_DIR/unsized_image.qcow2"

echo "[+] Customizing image $BASE_IMAGE..."
virt-customize -a "$BASE_DIR/$BASE_IMAGE" \
    --update \
    --install $PACKAGES \
    --run-command "useradd -m -s /bin/bash $GUEST_USER" \
    --password "$GUEST_USER:password:$GUEST_PASS" \
    --run-command "usermod -aG sudo $GUEST_USER" \
    --edit "/etc/ssh/sshd_config: s/#PasswordAuthentication yes/PasswordAuthentication yes/" \
    --run-command "systemctl enable ssh" \
    --edit '/etc/sudoers: s/^%sudo.*/%sudo ALL=(ALL) NOPASSWD:ALL/' \
    --run-command "mkdir -p $SHARED_GUEST_DIR" \
    --append-line "/etc/fstab:host_share $SHARED_GUEST_DIR 9p trans=virtio,version=9p2000.L,rw,_netdev 0 0" \
    --edit "/etc/default/grub: s/GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=0/" \
    --run-command "update-grub"

echo "[+] Success! Image has been customized and saved as $BASE_IMAGE."
