# NixOS Configuration

NixOS flake configuration for all of Carl's machines.

## Machines

| Hostname | Description |
|---|---|
| `loki` | Primary desktop |
| `freia` | Laptop |
| `carl-rpi` / `brian-rpi` / `zero-rpi` | Raspberry Pis |

## Applying changes

```sh
sudo nixos-rebuild switch --flake /etc/nixos#<hostname>
```

---

## Claude Code VM (loki only)

A lightweight microVM on `loki` for running Claude Code in isolation. Defined in
`systems/vms/claude-code.nix`, managed by [microvm.nix](https://github.com/microvm-nix/microvm.nix).

**Specs:** 8 vCPUs, 16 GB RAM, cloud-hypervisor

### Networking

```
VM (10.0.100.2)
    │  virtio-net NIC
    │
[ TAP: vm-claude ]        ← created by cloud-hypervisor on VM start
    │
[ Bridge: microvm-br ]    ← 10.0.100.1/24, always up on loki
    │  NAT via iptables
    │
[ enp8s0 ]  →  internet
```

The VM's `/home/carl/code` is mounted from the host via virtiofs (not over the network).

### Start / stop

```sh
sudo systemctl start microvm@claude-code.service
sudo systemctl stop microvm@claude-code.service
sudo systemctl status microvm@claude-code.service
```

To start automatically on boot:

```sh
sudo systemctl enable microvm@claude-code.service
```

### SSH into the VM

```sh
ssh carl@10.0.100.2
```

Your normal SSH keys are authorized. The VM does not accept password authentication.

### Accessing your code

`/home/carl/code` on the host is mounted at `/home/carl/code` inside the VM.
Changes made inside the VM are reflected on the host immediately (virtiofs).

### Updating the VM

Edit `systems/vms/claude-code.nix`, then rebuild and restart:

```sh
sudo nixos-rebuild switch --flake /etc/nixos#loki
sudo systemctl restart microvm@claude-code.service
```

To rebuild the VM's own NixOS config (e.g. to update packages inside it):

```sh
sudo nixos-rebuild switch --flake /etc/nixos#claude-code \
  --target-host carl@10.0.100.2 --use-remote-sudo
```
