#Network
resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

# NAT gateway and route table
resource "yandex_vpc_gateway" "nat_gateway" {
  folder_id = var.folder_id
  name      = var.nat_gateway.develop-nat_gateway.name
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "dev-rt" {
  folder_id  = var.folder_id
  name       = var.route_table.develop-stat-route.name
  network_id = yandex_vpc_network.develop.id

  static_route {
    destination_prefix = var.route_table.develop-stat-route.static_route.destination_prefix[0]
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

# VM Web
resource "yandex_vpc_subnet" "develop_web" {
  name           = var.vpc_name_web
  zone           = var.vms_resources.web.zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr_web
  route_table_id = yandex_vpc_route_table.dev-rt.id
}

data "yandex_compute_image" "ubuntu_web" {
  for_each = var.vms_resources
  family = each.value.family
}
resource "yandex_compute_instance" "platform_web" {
  for_each = var.vms_resources

  name        = each.value.name
  hostname    = each.value.hostname 
  platform_id = each.value.platform_id
  zone        = each.value.zone
  resources {
    cores         = each.value.cores
    memory        = each.value.memory
    core_fraction = each.value.core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu_web[each.key].image_id
      size     = each.value.disk_size
      type     = each.value.disk_type
    }
  }
  scheduling_policy {
    preemptible = each.value.preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop_web.id
    nat       = each.value.nat
  }

  metadata = {
    serial-port-enable = "${var.vms_resources_metadata.all.serial-port-enable}"
    ssh-keys           = "${var.vms_resources_metadata.all.ssh-user}:${data.local_file.ssh_auth_yc.content}"
  }
  allow_stopping_for_update = true
}