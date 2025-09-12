# enable the kubernetes auth method
resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}

# retrieve CA cert from kubernetes
data "kubernetes_config_map" "kube_root_ca" {
  metadata {
    name = "kube-root-ca.crt"
  }
}

# configure the kubernetes method using the certificate and token from that SA
resource "vault_kubernetes_auth_backend_config" "kubernetes_config" {
  backend            = vault_auth_backend.kubernetes.path
  kubernetes_host    = "https://kubernetes.default.svc.cluster.local"
  kubernetes_ca_cert = data.kubernetes_config_map.kube_root_ca.data["ca.crt"]
}

# create a simple kubernetes role 
resource "vault_kubernetes_auth_backend_role" "ktk" {
  backend                          = vault_auth_backend.kubernetes.type
  role_name                        = "demo"
  bound_service_account_names      = ["demo-serviceaccount"]
  bound_service_account_namespaces = ["eso", "csi", "vai"]
  token_policies                   = [vault_policy.ktk.name]
}

