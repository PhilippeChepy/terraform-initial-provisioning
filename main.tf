resource "null_resource" "pre_exec_hooks" {
  count = length(var.pre_exec) > 0 ? 1 : 0

  connection {
    host        = var.connection["host"]
    user        = var.connection["user"]
    private_key = var.connection["private_key"]
  }

  triggers = {
    target = jsonencode(var.connection)
  }

  provisioner "remote-exec" {
    inline = [for hook in var.pre_exec : "sudo ${hook}"]
  }
}

resource "null_resource" "files" {
  for_each   = var.files
  depends_on = [null_resource.pre_exec_hooks]

  connection {
    host        = var.connection["host"]
    user        = var.connection["user"]
    private_key = var.connection["private_key"]
  }

  triggers = {
    target    = jsonencode(var.connection)
    filename  = each.key
    file_hash = sha256(each.value.content)
  }

  provisioner "file" {
    content     = each.value.content
    destination = "/tmp/${sha256(each.key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/${sha256(each.key)} ${each.key}",
      "sudo chown ${each.value.owner}:${each.value.group} ${each.key}",
      "sudo chmod ${each.value.mode} ${each.key}",
    ]
  }
}

resource "null_resource" "post_exec_hooks" {
  depends_on = [null_resource.files]

  connection {
    host        = var.connection["host"]
    user        = var.connection["user"]
    private_key = var.connection["private_key"]
  }

  triggers = {
    target     = jsonencode(var.connection)
    pre_hooks  = sha256(jsonencode(length(var.pre_exec) > 0 ? null_resource.pre_exec_hooks[0].triggers : {}))
    files      = sha256(jsonencode({ for filename, specs in var.files : filename => null_resource.files[filename].triggers }))
    post_hooks = jsonencode(var.post_exec)
  }

  provisioner "remote-exec" {
    inline = [for hook in var.post_exec : "sudo ${hook}"]
  }
}
