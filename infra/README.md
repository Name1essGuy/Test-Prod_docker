# Набор инструкций для создания окружения stage и production серверов
Данный набор инструкций предназначен для развёртывания и настройки серверов для тестирования.

Создание серверов происходит на Yandex Cloud при помощи terraform, а их настройка при помощи ansible.

Так же на тестовый сервер при желании может быть установлен GitlabRunner, что позволяет использовать его в GitlabCI.

Для использования данного набора инструкций вам понадобится: 
* Аккаунт [Yandex Cloud](https://yandex.cloud/ru/)
* Аккаунт [GitLab](https://about.gitlab.com)
* Зарегистрированное [доменное имя](https://help.reg.ru/support/domains/registratsiya-domena/kak-zaregistrirovat-domen#1)
* Сгенерированная [пара ключей](https://learn.microsoft.com/ru-ru/azure/virtual-machines/linux/create-ssh-keys-detailed) для доступа к серверам

## Создание окружения тестового сервера
1. Установите terraform

2. Внесите изменения в файл `infra/terraform/stage/stage.auto.tfvars`
   А именно:
   1. Данные для доступа к Yandex Cloud
   2. Доменное имя сервера
   3. Желаемые параметры сервера

3. Положите файл публичного ключа в `infra/terraform/stage/keys`

4. Из папки `infra/terraform/stage` используйте:
   ```shell
   terraform init && terraform apply
   ```
   Возможно придётся использовать VPN!

## Настройка окружения тестового сервера
1. Установите ansible

2. Внесите изменения в файл `infra/ansible/inventory`
   А именно:
   1. Ip-адрес развёрнутого вами ранее сервера (можно использовать его доменное имя)
   2. Путь к файлу закрытого ключа на вашем ПК
   3. Если Вы меняли имя пользователя в файле `infra/terraform/stage/stage.auto.tfvars`, тут его тоже нужно поменять на то, которое указали ранее.

3. Если вам не нужна установка GitlabRunner'а перейдите к шагу 4!
   Для установки GitlabRunner'а внесите изменения в файл `infra/ansible/stage/defaults/main.yml`
   А именно:
   1. Измените `gitlab_install: False` на `gitlab_install: True`
   2. Введите url адрес GitHub
   3. Введите [полученный токен](https://docs.gitlab.com/runner/register/) для runner'а

4. Из папки `infra/ansible` используйте:
   ```shell
   ansible-playbook -b stage-playbook.yml
   ```
   