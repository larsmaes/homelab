variable "proxmox_endpoint" {
  description = "Proxmox VE endpoint"
  type        = string
}

variable "proxmox_username" {
  description = "Proxmox VE username"
  type        = string
}
variable "proxmox_password" {
  description = "Proxmox VE password"
  type        = string
  ephemeral = true
  sensitive = true
}

variable "talos_version" {
  description = "Talos version to use"
  type        = string  
}

variable "talos_nodes" {
  description = "List of Talos nodes to create"
  type = map(object({
    memory = number
    cores  = number
    order  = number
    wait   = number
    proxmox_node = string
    node_type = string
    ip = string
    gateway = string
    install_disk = string
  }))
  
}

variable "talos_cluster_name" {
  description = "Talos cluster name"
  type        = string
}

variable "talos_cluster_endpoint" {
  description = "Talos cluster endpoint"
  type        = string
}

variable "metallb_addresses" {
  description = "Metallb address range"
  type        = list(string)
}	

variable "kubernetes_version" {
  description = "Kubernetes version to use"
  type        = string
}

variable "ingress-nginx_vip" {
  description = "VIP for NGINX Ingress Controller"
  type        = string
}

variable "cert-manager_email" {
  description = "Email for cert-manager"
  type        = string
  
}

variable "github_private_key_file" {
  description = "GitHub private key for FluxCD"
  type        = string
  sensitive   = true
}

variable "github_public_key_file" {
  description = "GitHub public key for FluxCD"
  type        = string
  
}

variable "github_repository_url" {
  description = "GitHub repository URL for FluxCD"
  type        = string
}

variable "sops_gpg_key_file" {
  description = "SOPS GPG key file"
  type        = string
  sensitive   = true  
}

variable "ghrc_registry_auth" {
  description = "Registry authentication for ghrc.io"
  type        = string
  sensitive   = true
}