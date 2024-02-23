resource "google_compute_instance" "instance" {
  count        = var.instance_count
  name         = "${var.instance_prefix}-${count.index}"
  machine_type = var.instance_type
  zone         = var.gcp_zone

  metadata = {
    ssh-keys       = "${var.user_name}:${file(var.public_ssh_key_path)}"
    startup-script = <<-EOT
      #!/bin/bash
      echo root:${random_password.root_password[count.index].result} | chpasswd
    EOT
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      image = var.instance_image
      size  = var.instance_disk_size
    }
  }

  network_interface {
    // All use the default VPC network
    // Internal ICMP is allowed by default in GCE
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }
}

resource "random_password" "root_password" {
  count  = var.instance_count
  length = 4
}