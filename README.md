# qemu-sandboxer

My lightweight virtual machine orchestration environment (QEMU + KVM + virt-customize) low-level research/development.

### Features

* **TOML-Driven Infrastructure:** Manage memory, CPU, packages, storage sizes and network port-forwarding rules from a single `config.toml`.
* **Background Execution:** Runs virtual machines completely detached (`-daemonize`) with monitoring and console control via Unix sockets (`socat`).
* **Safe Mutation (Snapshotting):** Ephemeral snapshots (`./lab.sh reset`). Destroy the kernel and revert to a clean state instantly.

---

## Quick Start

#### 1. Prerequisites
Ensure your Linux host has the required virtualization packages:
```bash
sudo apt install qemu-system-x86 libguestfs-tools socat python3
```

#### 2. Installation
After installing, clone this repository and navigate to the `qemu-sandboxer` directory:
```bash
git clone https://github.com/Vinicin1101/qemu-sandboxer.git
cd qemu-sandboxer
```

#### 3. Configuration
Before initializing the environment, edit `config.toml` file for your specific setup.

#### 4. Initialization
After editing, run `./init.sh` to set up the environment.
Wait for the script to complete, then run `./lab.sh start` to start the virtual machine.

#### 5. Usage
```bash
./lab.sh start   # Start the VM daemonized
./lab.sh status  # Show telemetry (PID, CPU, RAM, Uptime)
./lab.sh console # Open serial console via socket (CTRL+O to exit)
./lab.sh stop    # Gracefully shutdown lab
./lab.sh reset   # Destroy the current snapshot and recreate a clean one from the base image
```
