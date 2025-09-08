# create policy for demo role 
resource "vault_policy" "ktk" {
  name   = "demo"
  policy = file("policy-ktk.hcl")
}
