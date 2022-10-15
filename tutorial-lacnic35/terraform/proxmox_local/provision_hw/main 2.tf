variable "labgroups" {
   type = map(object({
              ip = string,
              vmid = number
            }
          ))
}

variable "ssh_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9dQNOFa6vqxmb/QEqxZamEeeaccda9TkXYhl2DnydCDZBwQUMnuKPsCanxqr8Etxo3NELP6MZVL43Y5trWfg3lzFvldeu/BQYYg2oP4ZtNZkhB9e2or/pGjUzLeS+H/rhmfmfHBTFtozveMq1RkysD535+19JE7zTFFpKaxj7iwsLgDPYfaIdmB7+Gbr7gPp3+PCzY+fWTVJI6tEcpIEvpX0+sgwJZXZQAryBZnvGM5OOb7IHCSvLwS+SToDtEvXe8G5zrS1Ts+byRSo312qDaVQzHDyBIFTDrKI44+OrYwqj/P/ZOWy9yb4v2/xOoC2xb2GdyDx31ViRWNM0Eno5 carlos@potomac"
}

terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = ">=1.0.0"
    }
  }
  required_version = ">= 0.14"
}

provider "proxmox" {
    pm_api_url = "https://puma.in.xt6.us:8006/api2/json"
    pm_tls_insecure = true
    pm_log_enable = true
    pm_log_file = "terraform-plugin-proxmox.log"
    pm_log_levels = {
        _default = "debug"
        _capturelog = ""
    }    
    pm_parallel = 3
}

resource "proxmox_vm_qemu" "lab35" {
    for_each = var.labgroups

    name = "lab35-${each.key}"
    agent = 1
    target_node = "mulita"
    clone = "tpl-ub2004-tiny-mulita"
    os_type = "cloud-init"
    vmid = each.value.vmid
    memory = 2048
    full_clone = true
    ipconfig0 = "ip=${each.value.ip}/23,gw=192.168.88.1"
    sshkeys = <<EOF
        ${var.ssh_key}
    EOF    
    lifecycle {
      ignore_changes = all
    }
}

output "instance_ipv4" {
  value = {
     for ins in proxmox_vm_qemu.lab35:
        ins.name => ins.default_ipv4_address
  }
}
