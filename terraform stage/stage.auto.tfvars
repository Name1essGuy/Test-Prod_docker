# Данные для доступа к провайдеру

token        = "<oauth_token_yandex_cloud>"     # Oauth token Yandex Cloud
cloud_id     = "<id_облака_yandex_cloud>"       # Cloud id Yandex Cloud
folder_id    = "<id_папки_yandex_cloud>"        # Folder id Yandex Cloud
vm_user      = "terraform"                      # Имя пользователя, от имени которого будут выполняться действия
ssh_key_path = "/keys/id_rsa.public"            # Путь к файлу ключа

# Доменное имя для сервера

domain       = "<зарегистрированный_домен>"

# Параметры сервера

cores        = "<количество_ядер_процессора>"   # Количество ядер процессора
memory       = "<ОЗУ_ГБ>"                       # Количество ГБ оперативной памяти
disk_size    = "<размер_диска_ГБ>"              # Размер жёсткого диска ГБ
OS_family    = "ubuntu-2004-lts"                # Операционная система