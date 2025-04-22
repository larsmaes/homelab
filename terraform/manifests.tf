# data "helm_template" "metallb" {
#   name         = "metallb"
#   namespace    = "metallb-system"
#   repository   = "https://metallb.github.io/metallb"
#   chart        = "metallb"
#   kube_version = var.kubernetes_version
# }

# data "helm_template" "ingress-nginx" {
#   name         = "ingress-nginx"
#   namespace    = "ingress-nginx"
#   repository   = "https://kubernetes.github.io/ingress-nginx"
#   chart        = "ingress-nginx"
#   kube_version = var.kubernetes_version
#   include_crds = true
#   values = [<<-EOF
#         controller:
#             service:
#                 annotations:
#                     metallb.io/loadBalancerIPs: ${var.ingress-nginx_vip}
#         EOF
#   ]
# }

# data "helm_template" "cert-manager" {
#   name         = "cert-manager"
#   namespace    = "cert-manager"
#   repository   = "https://charts.jetstack.io"
#   chart        = "cert-manager"
#   include_crds = true
#   kube_version = var.kubernetes_version
#   values = [<<-EOF
#     crds:
#       enabled: true
#     EOF
#   ]
# }

# data "helm_template" "fluxcd" {
#   name         = "flux"
#   namespace    = "flux-system"
#   repository   = "https://fluxcd-community.github.io/helm-charts"
#   chart        = "flux2"
#   kube_version = var.kubernetes_version
#   include_crds = true
#   values = [<<-EOF
#     installCRDs: true
#     EOF
#   ]
# }
