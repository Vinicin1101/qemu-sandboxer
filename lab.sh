#!/bin/bash

if ! command -v python3; then
    echo "[!] python3 not found. Please install it first."
    exit 1
fi
eval "$(python3 parse_config.py )"

if ! command -v socat; then
    echo "[!] socat not found. Please install it first."
    exit 1
fi

case "$1" in
    reset)
        echo "[!] Reseting lab snapshot..."
        if [ -f /tmp/linux_lab.pid ]; then
            echo "quit" | socat - $SOCKET_MONITOR 2>/dev/null
            sleep 1
        fi
        rm -f "$BASE_DIR/$SNAPSHOT"
        qemu-img create -f qcow2 -b "$BASE_IMAGE" -F qcow2 "$BASE_DIR/$SNAPSHOT"
        echo "[+] Reset completed. Run './lab.sh start' to turn it on."
        ;;
    start)
        if [ ! -f "$BASE_DIR/$SNAPSHOT" ]; then
            echo "[*] Snapshot not found. Creating a new one..."
            qemu-img create -f qcow2 -b "$BASE_IMAGE" -F qcow2 "$BASE_DIR/$SNAPSHOT"
        fi

        echo "[>] Starting Lab..."
	(
	    umask 0007;
            qemu-system-x86_64 \
              -enable-kvm -cpu host -m $VM_MEMORY -smp $VM_CPUS \
              -drive file="$BASE_DIR/$SNAPSHOT",if=virtio \
              -net $FORWARD_PORT\
              -net nic \
              -virtfs local,path=$SHARED_HOST_DIR,security_model=mapped-xattr,mount_tag=host_share \
              -vga none \
              -display none \
              -daemonize \
              -monitor $(echo "$SOCKET_MONITOR,server,nowait") \
              -serial $(echo "$SOCKET_SERIAL,server,nowait") \
              -pidfile /tmp/linux_lab.pid
	 )
	 echo "[!] Lab started [pid: $(cat /tmp/linux_lab.pid)]"
        ;;
    stop)
        echo "[>] Stoping Lab..."
        echo "quit" | socat - unix-connect:${SOCKET_MONITOR#unix:}
        echo "[!] Lab stopped"
	 ;;
    console)
        echo "[>] Entering to serial... (use CTRL + O to exit)"
        socat -,raw,echo=0,escape=0x0f unix-connect:${SOCKET_SERIAL#unix:}
	 ;;
    status)
        if [ -f /tmp/linux_lab.pid ]; then
            echo "[>] Lab status: Running [pid: $(cat /tmp/linux_lab.pid)]"
            PID=$(cat /tmp/linux_lab.pid 2>/dev/null)

            M_TIME=$(ps -p $PID -o etime= | awk 'END {print $NF}')
            M_CPU=$(ps -p $PID -o %cpu= | awk 'END {print $NF}')
            M_MEM=$(ps -p $PID -o %mem= | awk 'END {print $NF}')
            M_COMM=$(ps -p $PID -o comm= | awk 'END {print $NF}')

            echo -e "    - Uptime: $M_TIME \n\
    - Memory: $M_MEM%\n\
    - CPU: $M_CPU%\n\
    - Process: $M_COMM\n"
        else
            echo "[>] Lab status: Stopped"
        fi
        ;;
    *)
        echo -e "Usage: ./lab.sh \n\
    start:  Start the lab \n\
    reset:  Reset the lab \n\
    stop:   Stop the lab \n\
    status: Show the lab status\n\
    console: Enter the serial console"
    ;;
esac
