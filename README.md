# CDS 2025 Demo

## Prerequisites

Have the following tools installed:

- [kind](https://kind.sigs.k8s.io) (creates throw-away K8s clusters in containers)
- [kubectl](https://kubernetes.io/de/docs/tasks/tools/install-kubectl/) (K8s CLI)
- [helm](https://helm.sh) (K8s "package manager")
- [helmfile](https://helmfile.readthedocs.io/en/latest/) (Wrapper for advanced usage of helm)
- [vault](https://developer.hashicorp.com/vault/tutorials/get-started/install-binary) (Vault Binary including CLI)

You will also need a container runtime for `kind`, like:

- [docker](https://www.docker.com)
- [podman](https://podman.io)

This demo is tested with Podman Desktop on MacOS, but should also run on any other OS with `docker` or `podman`. The container runtime can be run rootless.

### With `nix` and `direnv`

Alternatively, if you are using `nix`, you can just make use of the provided `flake.nix` included in this repo. It can be used with `nix-shell` to get an environment with all required prerequisites. Check out the [docs](https://nixos.wiki/wiki/Development_environment_with_nix-shell) for further information.

When using `direnv` in addition, it will detect the provided `.envrc` file in this repo. You'll need to allow the usage of the porivided env by `direnv allow`.

## Setup the environment

### Install applications

1. Run `kind create cluster --config kind-config.yaml` inside this directory to create a K8s cluster.

2. Run `helmfile init` to ensure all required helm plugins are available and the tool is ready to use.

3. Run `helmfile apply` inside this directory to install all required dependencies for the environment inside the cluster. Make sure the right cluster context is set.

4. Wait for all containers to become ready, except the Vault container. Check by `watch kubectl get pods -A`.

### Initialize and unseal Vault

1. Run `export VAULT_ADDR="http://localhost:8200"` to set the URL for the `vault` CLI.

2. Run `vault operator init -n 1 -t 1` to initalize the Vault.
   **IMPORTANT: Save the output for later use!**

3. Run `vault operator unseal` and you will be prompted for a unseal key, which you can find in the saved output of the previous command.

4. Run `vault login` and you will be prompted fo a token. Use the root token provided in the saved output.

### Configure Vault

Run all following commands inside the directory `vault-tf-config`.

1. Run `terraform init`.

2. Run `terraform apply -auto-approve`.

Check out https://localhost:8200 and login with the root token from the previous steps, if you want to inspect the configuration from the Vault UI.

## Check the Demos

### External Secrets Operator

Check out the resources inside the directors `examples/external-secrets-operator`. Run all following commands from this directory.

1. Run `kubectl apply -f 00-serviceaccount.yml` to create a ServiceAccount the ESO will use to authenticate to Vault.

2. Run `kubectl apply -f 01-secret-store.yml` to create a SecretStore pointing to the KVv2 Engine `kv`. It will authenticate using the previously created ServiceAccount.

3. Run `kubectl get secretstore -n eso demo-secret-store` to inspect if the SecretStore is valid.

4. Run `kubectl get secrets -n eso` to proof the Secret `demo-secret` does not already exist.

5. Run `kubectl apply -f 02-external-secret.yml` to create an ExternalSecret which the ESO will use to retrieve secret data from the Vault and store it in a K8s Secret.

6. Run `kubectl get secrets -n eso demo-secret -o yaml` to check the generated Secret.

### Vault CSI Provider

Check out the resources inside the directors `examples/vault-csi-provider`. Run all following commands from this directory.

1. Run `kubectl apply -f 00-serviceaccount.yml` to create a ServiceAccount the CSI Provider will use to authenticate to Vault.

2. Run `kubectl apply -f 01-secret-provider-class.yml` to create a SecretProviderClass pointing to the KVv2 Engine `kv` and referencing the requested secret data. It will authenticate using the previously created ServiceAccount.

3. Run `kubectl apply -f 02-pod.yml` to create an Pod using the previously created SecretProviderClass.

4. Run `kubectl exec -n csi demo-pod -- cat /mnt/secrets-store/foo` to inspect the created file inside the Pod.

### Vault Agent Injector

Check out the resources inside the directors `examples/vault-agent-injector`. Run all following commands from this directory.

1. Run `kubectl apply -f 00-serviceaccount.yml` to create a ServiceAccount the Vault Agent will use to authenticate to Vault.

2. Run `kubectl apply -f 02-pod.yml` to create an Pod. All required information about which secret data to retrieve and how to authenticate is stored within annotations.

3. Run `kubectl exec -n vai demo-pod -- cat /vault/secrets/foo` to inspect the created file inside the Pod.

### Vault Secrets Webhook

Check out the resources inside the directors `examples/vault-secrets-webhook`. Run all following commands from this directory.

1. Run `kubectl apply -f 00-namespace.yml` to create an additional namespace for this example, as workloads using the webhook need to run in a seperate namespace.

2. Run `kubectl apply -f 01-serviceaccount.yml` to create a ServiceAccount `vault-env` (injected by the webhook) will use to authenticate to Vault.

3. Run `kubectl apply -f 02-pod.yml` to create an Pod. All required information about which secret data to retrieve and how to authenticate is stored within annotations. The webhook will use this information to alter the Pod on creation.

4. Run `kubectl get pod -n vswh-workloads demo-pod -o yaml` to check how the webhook altered the Pod.

5. Run `kubectl logs -n vswh-workloads demo-pod` to check the outputs of this Pod. It is configured to print out the environment variables which should contain the secrets.

## Further things to try

- Inspect the logs of the installed components.
- Change the secret data inside Vault and see if it propagates. This should work for all solutions except the Webhook.
- Delete the ExternalSecret and check if the Secret is deleted.
- Change the SecretProviderClass and check if the changes are reflected within the Pod. Recreate the Pod.

## Issues

If you ran into any issue during this demo, feel free to contact me or raise an issue on this repo.
