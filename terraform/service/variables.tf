variable "service_name" {
  type    = string
  default = "simplesite"
}

variable "app_repo_url" {
  type    = string
  default = ""
}

variable "infra_state_bucket" {
  type = string
}

variable "infra_state_key" {
  type = string
}

variable "app_state_bucket" {
  type = string
}

variable "app_state_key" {
  type = string
}

variable "region" {
  type = string
}
