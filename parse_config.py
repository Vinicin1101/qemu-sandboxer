import tomllib

with open("config.toml", "rb") as f:
    config = tomllib.load(f)

print(f"IMAGE_URL='{config['image']['url']}'")
print(f"BASE_DIR='{config['image']['base_dir']}'")
print(f"BASE_IMAGE='{config['image']['base_name']}'")
print(f"SNAPSHOT='{config['image']['snapshot_name']}'")
print(f"DISK_SIZE='{config['image']['size']}'")

print(f"GUEST_USER='{config['guest']['username']}'")
print(f"GUEST_PASS='{config['guest']['password']}'")

print(f"SHARED_HOST_DIR='{config['shared']['host_dir']}'")
print(f"SHARED_GUEST_DIR='{config['shared']['guest_dir']}'")

print(f"VM_MEMORY='{config['hardware']['memory']}'")
print(f"VM_CPUS='{config['hardware']['cpus']}'")

port_map = config["hardware"]["port_mapping"]
net_fwd = config["hardware"]["network_fwd"]

for port in port_map:
    guest_port = port["guest"]
    host_port = port["host"]
    net_fwd += f",hostfwd=tcp::{host_port}-:{guest_port}"

print(f"FORWARD_PORT='{net_fwd}'")

print(f"SOCKET_MONITOR='{config['host']['socket_monitor']}'")
print(f"SOCKET_SERIAL='{config['host']['socket_serial']}'")

all_pkgs = config["packages"]["system"] + config["packages"]["development"]
print(f"PACKAGES='{','.join(all_pkgs)}'")
