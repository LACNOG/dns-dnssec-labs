locals {
	labgroups = {
		"g1" = {ip = "192.168.89.144", vmid = 8001 },
		"g2" = {ip = "192.168.89.145", vmid = 8002 }
	}
}

module "prov_hardware" {
   source = "./provision_hw"
   labgroups = local.labgroups
}

module "prov_software" {
   source = "./provision_sw"
   # instance_ipv4 = {
   #   "g1" = module.prov_hardware.instance_ipv4
   #}
   
   instance_ipv4 = module.prov_hardware.instance_ipv4
   # instance_ipv4 = toset( module.prov_hardware.instance_ipv4 )
   # instance_ipv4 = toset( [ for i in local.labgroups: i.ip ] )
   # instance_ipv4 = ["192.168.89.144", "192.168.89.145"]
}
