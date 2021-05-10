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
    linode = {
      source  = "linode/linode"
      version = ">=1.0.0"
    }
  }
  required_version = ">= 0.14"
}

provider "linode" {
   token = "675d79974610727496eaccebbf4c64fb167c9f1144f5734331cc7e1fcf089ef8"
}

resource "linode_instance" "lab35" {
	for_each = var.labgroups
	label = "tutorial.dns.lacnic35.${each.key}"
	image = "linode/ubuntu20.04"
	region = "us-central"
	type = "g6-standard-2"
	authorized_keys = [ var.ssh_key ]
	root_pass = "cocoliso123"
}

output "instance_ipv4" {
  value = {
     for ins in linode_instance.lab35:
        ins.label => ins.ip_address
  }
}

#output "instance_ipv4" {
#   value = linode_instance.lab35.ip_address
#}
