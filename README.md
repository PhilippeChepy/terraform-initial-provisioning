# Easily deploy files and run commands on remote host

This module allows one to easily deploy files and execute commands on a remote host (either before
or after provisioning files).

Example usage:

```terraform
module "etcd" {
  source   = "git@github.com:PhilippeChepy/terraform-initial-provisioning.git"
  for_each = var.hostnames

  connection = merge(
    { host = exoscale_compute.etcd[each.value].ip_address },
    var.connection
  )

  # It's possible to run commands before copying files to the remote
  # pre_exec = [
  # ]

  files = {
    "/etc/etcd/tls/server-ca.pem" = {
      content = var.certificates.ca_certificate
      owner   = "etcd"
      group   = "etcd"
      mode    = "0644"
    }
    "/etc/etcd/tls/server-cert.pem" = {
      content = var.certificates.server_certificates[each.value]
      owner   = "etcd"
      group   = "etcd"
      mode    = "0644"
    }
    "/etc/etcd/tls/server-cert.key" = {
      content = var.certificates.server_private_keys[each.value]
      owner   = "etcd"
      group   = "etcd"
      mode    = "0600"
    }
    "/etc/etcd/tls/peer-ca.pem" = {
      content = var.certificates.ca_certificate
      owner   = "etcd"
      group   = "etcd"
      mode    = "0644"
    }
    "/etc/etcd/tls/peer-cert.pem" = {
      content = var.certificates.peer_certificates[each.value]
      owner   = "etcd"
      group   = "etcd"
      mode    = "0644"
    }
    "/etc/etcd/tls/peer-cert.key" = {
      content = var.certificates.peer_private_keys[each.value]
      owner   = "etcd"
      group   = "etcd"
      mode    = "0600"
    }
    "/etc/default/etcd" = {
      content = templatefile("${path.module}/templates/etcd", {
        hostname          = each.value,
        etcd_ip_address = exoscale_compute.etcd[each.value].ip_address,
        etcd_ip_cluster = join(",", [for peer in var.hostnames : "${peer}=https://${exoscale_compute.etcd[peer].ip_address}:2380"])
      })
      owner = "etcd"
      group = "etcd"
      mode  = "0644"
    }
  }

  post_exec = [
    "sudo systemctl enable etcd",
    "sudo systemctl start etcd"
  ]
}
```


<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

The following providers are used by this module:

- <a name="provider_null"></a> [null](#provider\_null)

## Modules

No modules.

## Resources

The following resources are used by this module:

- [null_resource.files](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_connection"></a> [connection](#input\_connection)

Description: An object describing how to connect to target server.

Type:

```hcl
object({
  host        = string
  user        = string
  private_key = string
})
```

### <a name="input_files"></a> [files](#input\_files)

Description: A map of files to provision (key = full path of a file, value = file content and ownership/mode).

Type:

```hcl
map(object({
  content = string
  owner   = string
  group   = string
  mode    = string
}))
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_post_exec"></a> [post\_exec](#input\_post\_exec)

Description: A list of commands to execute after provisioning files.

Type: `list(string)`

Default: `[]`

### <a name="input_pre_exec"></a> [pre\_exec](#input\_pre\_exec)

Description: A list of commands to execute before provisioning files.

Type: `list(string)`

Default: `[]`

## Outputs

No outputs.
<!-- END_TF_DOCS -->