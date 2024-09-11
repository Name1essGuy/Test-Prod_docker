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

variable "bucket_max_size" {
  type      = number
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

# Создание s3 бакета

# Сервисный аккаунт
resource "yandex_iam_service_account" "sa" {
  name = "logger"
}

# Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "sa-admin" {
  folder_id = "${var.folder_id}"
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

# Создание статичного ключа доступа к бакету
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

# Создание самого бакета
resource "yandex_storage_bucket" "logs" {
  access_key            = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key            = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket                = "finalprojectlogs"
  max_size              = var.bucket_max_size
  default_storage_class = "cold"
  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }
}

# Вывод ключей доступа к бакету
output "bucket_static_access_key" {
  value = yandex_iam_service_account_static_access_key.sa-static-key.access_key
}

output "bucket_secret_access_key" {
  value = nonsensitive(yandex_iam_service_account_static_access_key.sa-static-key.secret_key)
}