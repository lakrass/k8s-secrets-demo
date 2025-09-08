# CRUD access to path globals
path "kv/*" {
    capabilities = ["create", "read", "update", "delete", "list"]
}
