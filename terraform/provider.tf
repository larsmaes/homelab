terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.75"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.7"
    }
  }

}

provider "proxmox" {
  endpoint = var.proxmox_endpoint

  # TODO: use terraform variable or remove the line, and use PROXMOX_VE_USERNAME environment variable
  username = var.proxmox_username
  # TODO: use terraform variable or remove the line, and use PROXMOX_VE_PASSWORD environment variable
  password = var.proxmox_password

  # because self-signed TLS certificate is in use
  insecure = true
  # uncomment (unless on Windows...)
  # tmp_dir  = "/var/tmp"

  ssh {
    agent = true
    # TODO: uncomment and configure if using api_token instead of password
    # username = "root"
  }
}
