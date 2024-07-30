variable "proxy_host" {
  type        = string
  description = "The IP, hostname, or fqdn of the egress proxy, if any."
  default     = ""
}

variable "proxy_proto" {
  type        = string
  description = "Transport protocol between client and proxy."
  default     = ""
}

variable "proxy_port" {
  type        = string
  description = "The tcp port of the egress proxy. Squid assumed."
  default     = ""
}

variable "proxy_user" {
  type        = string
  description = "Username for authenticated web access."
  sensitive   = true
  default     = ""
}

variable "proxy_password" {
  type        = string
  description = "Password for authenticated web access."
  sensitive   = true
  default     = ""
}

variable "https_proxy" {
  type        = string
  description = "The environment variable HTTPS_PROXY if needed"
  default     = ""
}
variable "iso_url1" {
  type        = string
  description = "local pathname to the downloaded DVD ISO"
}

variable "iso_url2" {
  type        = string
  description = "URL to download the DVD ISO"
}

variable "iso_checksum" {
  type        = string
  description = "https://mirrors.xtom.de/almalinux/8/isos/x86_64/CHECKSUM"
}

variable "client_id" {
  type        = string
  sensitive   = true
  description = "The Active Directory service principal associated with your builder."
  default     = "bogus_value"
}

variable "client_secret" {
  type        = string
  sensitive   = true
  description = "The password or secret for your service principal."
  default     = "bogus_value"
}

variable "subscription_id" {
  type        = string
  sensitive   = true
  description = "The service principal specified in client_id must have full access to this subscription"
  default     = "bogus_value"
}

variable "tenant_id" {
  type        = string
  sensitive   = true
  description = "https://www.packer.io/docs/builders/azure/arm"
  default     = "bogus_value"
}

variable "location" {
  type        = string
  description = "https://azure.microsoft.com/en-us/global-infrastructure/geographies/"
  default     = "westeurope"
}

variable "managed_image_resource_group_name" {
  type        = string
  description = "https://developer.hashicorp.com/packer/plugins/builders/azure/arm#managed_image_resource_group_name"
  default     = "VMImageResourceGroup"
}

variable "storage_account" {
  type        = string
  description = "make arm-storageaccount in Makefile"
  default     = "bogus_value"
}


variable "image" {
  type        = string
  description = "Name of the image when created"
  default     = "alma8"
}
