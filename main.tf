resource "null_resource" "files" {
  connection {
    host        = var.connection["host"]
    user        = var.connection["user"]
    private_key = var.connection["private_key"]
  }

  triggers = {
    target        = jsonencode(var.connection)
    deploy_script = <<EOT
#!/bin/bash
set -euxo pipefail

# Execute pre hooks
%{for hook in var.pre_exec}
${hook}
%{endfor}

# Provision files
%{for target, file in var.files}
# ${target}
base64 -d << _EOF > ${target}
${base64encode(file.content)}
_EOF
chown ${file.owner}:${file.group} ${target}
chmod ${file.mode} ${target}
%{endfor}

# Execute post hooks
%{for hook in var.post_exec}
${hook}
%{endfor}
EOT
  }

  provisioner "file" {
    content     = self.triggers.deploy_script
    destination = "/tmp/${sha256(self.triggers.deploy_script)}.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/${sha256(self.triggers.deploy_script)}.sh",
      "sudo /tmp/${sha256(self.triggers.deploy_script)}.sh",
      "rm /tmp/${sha256(self.triggers.deploy_script)}.sh"
    ]
  }
}
