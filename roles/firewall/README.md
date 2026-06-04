Firewall
=========

Данная роль выполняет:
- Добавления access ports на firewalld

Role Variables
--------------


|          Variable              |              Description                 |     Default                      |
| ------------------------------ | ---------------------------------------- | -------------------------------- |
|  `firewall_access_port`        | List доступности портов на firewalld     | `8123/tcp`                       |


Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: firewall }

License
-------

MIT

Author Information
------------------
Max Maxi is a devops student
