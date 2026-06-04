variable "vms_resources" {
  type = map(object({
    name          = string
    hostname      = string
    user          = optional(string)
    family        = string
    platform_id   = string
    zone          = string
    cores         = number
    memory        = number
    core_fraction = number
    disk_size     = number
    disk_type     = string
    preemptible   = bool
    subnet_id     = string
    nat           = bool
  }))

}
variable "vms_resources_metadata" {
  type = map(object({
    serial-port-enable = string
    ssh-user = string
  }))
}

variable "nat_gateway" {
  type = map(object({
    name = string
  }))
}

variable "route_table" {
  type = map(object({
    name = string
    #network_id   = string
    static_route = object({
      destination_prefix = list(string)
    })
  }))

}