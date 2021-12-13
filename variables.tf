variable "connection" {
  description = "An object describing how to connect to target server."
  type = object({
    host        = string
    user        = string
    private_key = string
  })
}

variable "pre_exec" {
  description = "A list of commands to execute before provisioning files."
  type        = list(string)
  default     = []
}

variable "files" {
  description = "A map of files to provision (key = full path of a file, value = file content and ownership/mode)."
  type = map(object({
    content = string
    owner   = string
    group   = string
    mode    = string
  }))
}

variable "post_exec" {
  description = "A list of commands to execute after provisioning files."
  type        = list(string)
  default     = []
}
