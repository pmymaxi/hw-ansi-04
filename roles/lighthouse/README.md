Lighthouse
=========

Данная роль выполняет:
- Устанавливает репозиторий lighthouse на предустановленный Nginx сервер

Role Variables
--------------


|          Variable              |              Description                 |     Default                               |
| ------------------------------ | ---------------------------------------- | ----------------------------------------- |
|  `lighthouse_git_repo`         | URL репозитории                          | `https://github.com/VKCOM/lighthouse.git` |
|  `lighthouse_git_dest`         | Path установки репозитория               | `/usr/share/nginx/lighthouse`             |
|  `lighthouse_git_version`      | Версия репозитория                       | `master`                                  |


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: lighthouse }

License
-------

MIT

Author Information
------------------
Max Maxi is a devops student
