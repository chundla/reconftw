#############################################################################
#############################################################################
############ WIP to create reconFTW in an IBM Cloud Instance ################
#############################################################################
#############################################################################

provider "ibm" {
        generation = 1
        region = "us-south-2"
}

resource ibm_is_vpc "vpc" {
  name = "reconVPC"
# public_key = "${file("${path.root}/terraform-keys.pub")}"
}

data ibm_is_image "debian" {
    name = "ibm-debian-11-2-minimal-amd64-1"
}

resource "ibm_instance" "reconFTW_Instance" {
    ami = "ami-0f1026b68319bad6c" #debian
    instance_type = "t3.small"
    key_name = ibm_key_pair.terraform-keys.key_name
    vpc_security_group_ids = ["${ibm_security_group.reconFTW_SG.id}"] 
    associate_public_ip_address = true

    provisioner "remote-exec" {
        
        inline = ["sudo hostname"]
        connection {
         host = "${self.public_ip}"
         type        = "ssh"
         user        = "admin"
         private_key = "${file("${path.root}/terraform-keys")}"
                }
        }    
    provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${self.public_ip},' -u admin --private-key terraform-keys reconFTW.yml"
    }
}

resource "ibm_security_group" "reconFTW_SG" {
    name = "Security Group for reconFTW"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port       = 0
      to_port         = 0
      protocol        = "-1"
      cidr_blocks     = ["0.0.0.0/0"]
    }
}

