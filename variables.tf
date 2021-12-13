variable "connection" {
  type = object({
    host        = string
    user        = string
    private_key = string
  })
}

variable "pre_exec" {
  type    = list(string)
  default = []
}

variable "files" {
  type = map(object({
    content = string
    owner   = string
    group   = string
    mode    = string
  }))
}

variable "post_exec" {
  type    = list(string)
  default = []
}
