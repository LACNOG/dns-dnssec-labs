variable "instance_ipv4" {
  type = map
}

resource "null_resource" "prov_env" {

   for_each = var.instance_ipv4
  

   connection {
     type = "ssh"
     host = each.value
     user = "ubuntu"
     agent = true
   }

   triggers = {
     setup_sh_changed = "${sha1(file("setup.sh"))}"
   }

   provisioner "remote-exec" {
       script = "setup.sh"
   }

   provisioner "remote-exec" {
      inline = [
        "sudo usermod -a -G docker ubuntu"
      ]
   }

}

