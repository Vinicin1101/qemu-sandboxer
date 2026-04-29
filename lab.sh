#!/bin/bash
BASE_DIR="$(dirname "$0")/image"
BASE_IMAGE="debian-base.qcow2"
SNAPSHOT="lab_snapshot.qcow2"
SHARED_DIR="$(pwd)/shared_code"

case "$1" in
    reset)
        echo "[!] Reseting lab..."
        rm -f "$BASE_DIR/$SNAPSHOT"
        qemu-img create -f qcow2 -b "$BASE_IMAGE" -F qcow2 "$BASE_DIR/$SNAPSHOT"
        echo "[+] Reset completed."
        ;;
    start)
        if [ ! -f "$BASE_DIR/$SNAPSHOT" ]; then
            echo "[*] Snapshot not found. Creating a new one..."
            qemu-img create -f qcow2 -b "$BASE_IMAGE" -F qcow2 "$BASE_DIR/$SNAPSHOT"
        fi

        echo "[>] Starting Lab..."
        qemu-system-x86_64 \
          -enable-kvm -cpu host -m 2G -smp 2 \
          -drive file="$BASE_DIR/$SNAPSHOT",if=virtio \
          -net user,hostfwd=tcp::2222-:22 \
          -net nic \
          -nographic \
          -virtfs local,path=./shared_code,security_model=mapped-xattr,mount_tag=host_share
        ;;
    *)
        echo "Usage: ./lab.sh {start|reset}"
        ;;
esac
