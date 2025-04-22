locals {
  talos_image_id = jsondecode(data.http.talos_image.response_body).id
  talos_iso      = "https://factory.talos.dev/image/${local.talos_image_id}/${var.talos_version}/nocloud-amd64.iso"
}

resource "proxmox_virtual_environment_download_file" "talos_amd64_iso" {
  content_type = "iso"
  datastore_id = "local"
  file_name    = "talos-${var.talos_version}-nocloud-amd64.iso"
  node_name    = "pve"
  url          = local.talos_iso
}

data "http" "talos_image" {
  url    = "https://factory.talos.dev/schematics"
  method = "POST"

  # Optional request body
  request_body = file("${path.module}/talos_factory.yaml")
}

resource "proxmox_virtual_environment_vm" "talos_node" {
  for_each    = var.talos_nodes
  name        = each.key
  description = "Managed by Terraform"
  tags        = ["terraform", "talos", each.value.node_type]

  node_name = each.value.proxmox_node

  agent {
    # read 'Qemu guest agent' section, change to true only when ready
    enabled = true
  }
  # if agent is not enabled, the VM may not be able to shutdown properly, and may need to be forced off
  stop_on_destroy = true
  boot_order      = ["virtio0", "ide3", "net0"]
  startup {
    order    = each.value.order
    up_delay = each.value.wait
  }

  cpu {
    cores = each.value.cores
    type  = "x86-64-v2-AES" # recommended for modern CPUs
    units = null
  }

  memory {
    dedicated = each.value.memory
    floating  = each.value.memory
  }

  cdrom {
    file_id   = proxmox_virtual_environment_download_file.talos_amd64_iso.id
    interface = "ide3"
  }

  initialization {
    ip_config {
      ipv4 {
        address = each.value.ip
        gateway = each.value.gateway

      }
    }
    dns {
      servers = ["192.168.2.254"]
    }
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    interface = "virtio0"
    size      = "16"
  }

  operating_system {
    type = "l26"
  }

  vga {
    type = "virtio"
  }
}
