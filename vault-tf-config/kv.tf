# enable KVv2 engine under path kv/
resource "vault_mount" "kv" {
  path = "kv"
  type = "kv-v2"
}

# create the following KV entries in kv/demo-secret
resource "vault_generic_secret" "demo" {
  path = "${vault_mount.kv.path}/demo"

  data_json = jsonencode(
    {
      "foo" = "bar",
    }
  )
}
