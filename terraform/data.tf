data "local_file" "ssh_auth_yc" {
  filename = pathexpand("~/.ssh/id_ed25519.pub")
}
