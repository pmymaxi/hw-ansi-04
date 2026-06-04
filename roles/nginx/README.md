Nginx
=========

Данная роль выполняет:
- Устанавливает веб-сервер Nginx
- Развертывает конфигурацию Nginx
- Настраивает корневой каталог веб-сайта
- Показывает статус мониторинга сервисов данного проекта

Role Variables
--------------


|          Variable              |              Description                   |     Default                      |
| ------------------------------ | ------------------------------------------ | -------------------------------- |
|  `nginx_user`                  | Имя пользователя web сервиса               | `nginx`                          |
|  `nginx_groups`                | Имя группы                                 | `nginx`                          |
|  `nginx_root_dir`              | Добавление root path директории nginx.conf | `/usr/share/nginx/hw04`          |
|  `nginx_create_root_dir`       | Создание root директории web site          | `/usr/share/nginx/html`          |
|  `nginx_conf_dest`             | Path до файла конфигурации на instance     | `/etc/nginx/nginx.conf`          |


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: nginx }

License
-------

MIT

Author Information
------------------
Max Maxi is a devops student
