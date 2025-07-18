resource "talos_machine_secrets" "this" {
  depends_on = [proxmox_virtual_environment_vm.talos_node]
}

data "talos_machine_configuration" "controlplane" {
  for_each = { for k, v in var.talos_nodes : k => v if v.node_type == "controlplane" }

  cluster_name       = var.talos_cluster_name
  cluster_endpoint   = var.talos_cluster_endpoint
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  config_patches = [
    templatefile("${path.module}/templates/controlplane.yaml.tmpl", {
      hostname       = each.key
      install_disk   = each.value.install_disk
      talos_version  = var.talos_version
      talos_image_id = local.talos_image_id
      fluxcd_manifest = file("${path.module}/manifests/fluxcd/install.yaml")
      fluxcd_repo_secret = templatefile("${path.module}/manifests/fluxcd/secret.yaml.tmpl", {
        private_key = file("${path.module}/${var.github_private_key_file}")
        public_key  = file("${path.module}/${var.github_public_key_file}")
        sops_gpg = file("${path.module}/${var.sops_gpg_key_file}")
      })
      fluxcd_repo = templatefile("${path.module}/manifests/fluxcd/repository.yaml.tmpl", {
        github_repository_url = var.github_repository_url
      })
      fluxcd_sync = file("${path.module}/manifests/fluxcd/gotk-sync.yaml")
      ghrc_registry_auth = var.ghrc_registry_auth
    }),
  ]
}

data "talos_machine_configuration" "worker" {
  cluster_name       = var.talos_cluster_name
  cluster_endpoint   = var.talos_cluster_endpoint
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
}

data "talos_client_configuration" "this" {
  cluster_name         = var.talos_cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = [for k, v in var.talos_nodes : split("/", v.ip)[0] if v.node_type == "controlplane"]
}

resource "talos_machine_configuration_apply" "controlplane" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane[each.key].machine_configuration
  for_each                    = { for k, v in var.talos_nodes : k => v if v.node_type == "controlplane" }
  node                        = split("/", each.value.ip)[0]
}

resource "talos_machine_configuration_apply" "worker" {
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  for_each                    = { for k, v in var.talos_nodes : k => v if v.node_type == "worker" }
  node                        = split("/", each.value.ip)[0]
  config_patches = [
    templatefile("${path.module}/templates/worker.yaml.tmpl", {
      hostname       = each.key
      install_disk   = each.value.install_disk
      talos_version  = var.talos_version
      talos_image_id = local.talos_image_id
      ghrc_registry_auth = var.ghrc_registry_auth
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.controlplane]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = [for k, v in var.talos_nodes : split("/", v.ip)[0] if v.node_type == "controlplane"][0]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = [for k, v in var.talos_nodes : split("/", v.ip)[0] if v.node_type == "controlplane"][0]
}
