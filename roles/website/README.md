Website
=========

Данная роль выполняет:
- Устанавливает веб-сайт на server Nginx

Role Variables
--------------


|          Variable              |              Description                 |     Default                        |
| ------------------------------ | ---------------------------------------- | ---------------------------------- |
|  `website_web_dest`            | Path для стартовой web страницы index    | `/usr/share/nginx/html/index.html` |
|  `website_clickhouse_server`   | Адрес clickhouse server                  | `http://127.0.0.1:8123`            |


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: website }

License
-------

MIT

Author Information
------------------
Max Maxi is a devops student
