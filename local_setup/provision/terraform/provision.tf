resource "null_resource" "wait_for_load_balancer_instances" {
  count           = local.load_balancer_count

	provisioner "remote-exec" {
		connection {
			host        = aws_instance.load_balancer[count.index].public_ip
			user        = "ubuntu"
			private_key = file("${path.module}/provision_private_key")
		}

		inline = [ "echo 'connected!' && hostname" ]
	}
}

resource "null_resource" "wait_for_application_instances" {
  count           = local.application_count

	provisioner "remote-exec" {
		connection {
			host                = aws_instance.applications[count.index].private_ip
			user                = "ubuntu"
			private_key         = file("${path.module}/provision_private_key")

      bastion_host        = aws_instance.load_balancer[0].public_ip
      bastion_user        = "ubuntu"
      bastion_private_key = file("${path.module}/provision_private_key")
		}

		inline = [ "echo 'connected!' && hostname" ]
	}
}

resource "null_resource" "provision_load_balancer_instances" {
  count           = local.load_balancer_count

	provisioner "local-exec" {
		command = "cd ../ansible && ANSIBLE_HOST_KEY_CHECKING=False /usr/bin/ansible-playbook -i ${aws_instance.load_balancer[count.index].public_ip}, -e 'application_ips=${jsonencode(local.application_ips)}' --user ubuntu --private-key ../terraform/provision_private_key playbooks/load_balancer.yml"
	}

  depends_on = [ null_resource.wait_for_load_balancer_instances, null_resource.wait_for_application_instances ]

  triggers = {
    always_run = timestamp()
  }
}

resource "null_resource" "provision_application_instances" {
	provisioner "local-exec" {
    command = "sed -i 's/SED_IP_HERE/${aws_instance.load_balancer[0].public_ip}/g' /etc/workdir/provision/ssh_config"
  }

	provisioner "local-exec" {
		command = "cd ../ansible && ANSIBLE_HOST_KEY_CHECKING=False /usr/bin/ansible-playbook -i ${join(",", local.application_ips)}, playbooks/application.yml --diff"
	}

  depends_on = [ null_resource.wait_for_load_balancer_instances, null_resource.wait_for_application_instances, null_resource.provision_load_balancer_instances ]

  triggers = {
    always_run = timestamp()
  }
}
