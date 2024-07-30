# Набор инструкций для создания окружения stage и production серверов
Данный набор инструкций предназначен для развёртывания и настройки серверов для тестирования и выкладки в публичный доступ приложения, упакованного в контейнер docker.

Создание серверов происходит на Yandex Cloud при помощи terraform, а их настройка при помощи ansible.

Так же на тестовый сервер при желании может быть установлен GitlabRunner, что позволяет использовать его в GitlabCI.

Для использования данного набора инструкций вам понадобится: 
* Аккаунт [Yandex Cloud](https://yandex.cloud/ru/)
* Аккаунт [GitLab](https://about.gitlab.com)
* Зарегистрированное [доменное имя](https://help.reg.ru/support/domains/registratsiya-domena/kak-zaregistrirovat-domen#1)
* Сгенерированная [пара ключей](https://learn.microsoft.com/ru-ru/azure/virtual-machines/linux/create-ssh-keys-detailed) для доступа к серверам

## Создание окружения тестового сервера
1. Установите terraform

2. Внесите изменения в файл `terraform stage/stage.auto.tfvars`
   А именно:
   1. Данные для доступа к Yandex Cloud
   2. Доменное имя сервера
   3. Желаемые параметры сервера

3. Положите файл публичного ключа в `terraform stage/keys`

4. Из папки `terraform stage` используйте:
   ```shell
   terraform init && terraform apply
   ```
   Возможно придётся использовать VPN!

## Настройка окружения тестового сервера
1. Установите ansible

2. Внесите изменения в файл `ansible/infra/inventory`
   А именно:
   1. Ip-адрес развёрнутого вами ранее сервера (можно использовать его доменное имя)
   2. Путь к файлу закрытого ключа на вашем ПК
   3. Если Вы меняли имя пользователя в файле `terraform stage/stage.auto.tfvars`, тут его тоже нужно поменять на то, которое указали ранее.

3. Если вам не нужна установка GitlabRunner'а перейдите к шагу 4!
   Для установки GitlabRunner'а внесите изменения в файл `ansible/infra/stage/defaults/main.yml`
   А именно:
   1. Измените `gitlab_install: False` на `gitlab_install: True`
   2. Введите url адрес GitHub
   3. Введите [полученный токен](https://docs.gitlab.com/runner/register/) для runner'а

4. Из папки `ansible/infra` используйте:
   ```shell
   ansible-playbook -b stage-playbook.yml
   ```

## GitlabCI
В наборе инструкций присутствует systemd unit для запуска докер контейнера по его тегу после его билда. Чтобы его развернуть:

1. Установите ansible (если не сделали этого ранее)

2. Внесите изменения в файл `ansible/service/inventory` по аналогии с пунктом 2 настройки окружения тестового сервера

3. Из папки `ansible/service` используйте:
   ```shell
   ansible-playbook -b service-playbook.yml
   ```

Чтобы им воспользоваться на стадии деплоя в вашем пайплайне используйте:

```shell
sed -i 's/some_tag/<container_tag>/g' /etc/systemd/system/docker-container.service.d/docker-container.conf
systemctl start docker-container.service
```

Где <container_tag> - тэг билда вашего контейнера.

После чего контейнер может быть остановлен командой:

```shell
systemctl stop docker-container.service
```