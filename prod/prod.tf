# Объявление конфиденциальных переменных

variable "token" {
  type      = string
  sensitive = true
}

variable "cloud_id" {
  type = string
}

variable "folder_id" {
  description = "ID of the folder where resources will be created"
  type = string
}

variable "vm_user" {
  type = string
}

variable "ssh_key_path" {
  type      = string
  sensitive = true
}

variable "domain" {
  type      = string
}

variable "cores" {
  type      = number
}

variable "memory" {
  type      = number
}

variable "disk_size" {
  type      = number
}

variable "OS_family" {
  type      = string
}

# Добавление прочих переменных
locals {
  network_name = "prod-net"
  subnet_name = "prod-net-subnet"
}

# Настройка провайдера

terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.47.0"
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-a"
}

# Создание облачной сети и подсети

resource "yandex_vpc_network" "prod-network" {
  name = local.network_name
}

resource "yandex_vpc_subnet" "prod-subnet" {
  name           = local.subnet_name
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.prod-network.id
  v4_cidr_blocks = ["192.168.1.0/24"]
}

# Cоздание группы безопасности

resource "yandex_vpc_security_group" "prod-sg" {
  name        = "prod-sg"
  network_id  = yandex_vpc_network.prod-network.id

  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "prometheus"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 9090
  }

  ingress {
    protocol       = "TCP"
    description    = "app"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8080
  }
 

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
    from_port      = 1
    to_port        = 65535
  }
}

# Создание виртуальной машины

data "yandex_compute_image" "my-ubuntu-2004-1" {
  family = var.OS_family
}

resource "yandex_compute_instance" "prod" {
  name        = "prod"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = "${data.yandex_compute_image.my-ubuntu-2004-1.id}"
      size     = var.disk_size
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.prod-subnet.id
    nat = true
    security_group_ids = [yandex_vpc_security_group.prod-sg.id]
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.vm_user}\n    groups: sudo\n    shell: /bin/bash\n    sudo: ['ALL=(ALL) NOPASSWD:ALL']\n    ssh-authorized-keys:\n      - ${file("${path.root}/${var.ssh_key_path}")}"
  }
}

# Создание публичной DNS зоны

resource "yandex_dns_zone" "prod-dns" {
  name        = "prod-dns"
  description = "Public zone"
  zone        = "${var.domain}."
  public      = true
}

resource "yandex_dns_recordset" "prod-A" {
  zone_id = yandex_dns_zone.prod-dns.id
  name    = "${var.domain}."
  ttl     = 600
  type    = "A"
  data    = [yandex_compute_instance.prod.network_interface.0.nat_ip_address]
}

output "prod_external_ip" {
  value = yandex_compute_instance.prod.network_interface.0.nat_ip_address
}
