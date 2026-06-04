output "out_info" {
  value = {
    for k, v in var.vms_resources :
    k => {
      external_ip: yandex_compute_instance.platform_web[k].network_interface[0].nat_ip_address
      internal_ip: yandex_compute_instance.platform_web[k].network_interface[0].ip_address
      fqdn: yandex_compute_instance.platform_web[k].fqdn
    }
  }

  }
