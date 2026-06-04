# Домашнее задание к занятию 4 «Работа с roles»

## Описание

Проект автоматизирует развертывание инфраструктуры мониторинга и сбора логов с использованием система управления конфигурациями Ansible.

В состав инфраструктуры входят:

- ClickHouse — NoSQL база данных, хранилище логов
- Vector — агент сбора и доставки логов в ClickHouse
- Nginx — веб-сервер
- Lighthouse — веб-интерфейс для ClickHouse
- Firewall — управление правилами firewalld, исключительно access port
- Website — демонстрационная web-страница со статусом сервисов

Инфраструктура разворачивается на виртуальных машинах Yandex Cloud, подготовленных Terraform. Конфигурация выполняется через Ansible роли.

---

## Схема deploy и взаимодействия

```text
                    +----------------+
                    |   Lighthouse   |
                    |  Web UI        |
                    +--------+-------+
                             |
                             |
                             v
+-------------+      +---------------+
|   Vector    +----->+  ClickHouse   |
| Log Agent   |      | Logs Storage  |
+------+------+      +-------+-------+
       ^
       |
       |
+------+------+
|    Nginx    |
| Access Logs |
+-------------+
```

---

## Структура Ansible проекта

```text
.
├── inventory/
│   └── dev.yml
├── group_vars/
│   ├── all.yml
│   ├── clickhouse.yml
│   ├── vector.yml
│   ├── nginx.yml
│   ├── lighthouse.yml
│   ├── website.yml
│   └── firewall.yml
├── host_vars/
│   ├── clickhouse-01.yml
│   ├── web-01.yml
│   └── lighthouse-01.yml
├── roles/
│   ├── clickhouse/
│   ├── vector/
│   ├── nginx/
│   ├── lighthouse/
│   ├── website/
│   └── firewall/
├── requirements.yml
└── site.yml
```

---

## Описание inventory Ansible проекта

### Inventory hosts roles

| Host | Role |
|--------|--------|
| clickhouse-01 | ClickHouse |
| web-01 | Nginx + Website + Vector |
| lighthouse-01 | Lighthouse + Nginx |

---

## Inventory Groups

| Group | Description |
|---------|-------------|
| clickhouse | ClickHouse server |
| vector | Vector agent |
| nginx | Nginx servers |
| website | Demo monitoring page |
| lighthouse | Lighthouse UI |
| firewall | Firewall management |

Конфигурация инвентаря описана в `inventory/dev.yml`.

---

## Roles

### ClickHouse

Роль выполняет:

- Установку ClickHouse
- Настройку репозитория
- Конфигурирование сервера
- Создание базы данных
- Создание таблицы логов
- Проверку доступности Native TCP интерфейсов

Основные параметры:

```yaml
# Default variable применяемые в group_vars and host_vars
clickhouse_version: "22.3.3.44" # Версия 

// Переменные для проверки доступности ClickHouse //
clickhouse_nativ_port: 9000 # Порт по умолчанию Native TCP
clickhouse_nativ_host: "127.0.0.1" # Адрес интерфейса
clickhouse_nativ_delay: 2 # Timeout при старте проверки
clickhouse_nativ_timeout: 30 # Timeout ожидания получения ответа

// Переменные для создания базы данных и таблицы //
clickhouse_db_name: "nginx" # Имя базы данных
clickhouse_table_name: "my_access_logs" # Имя таблицы в базе данных

# Фиксированные переменные (vars)
clickhouse_template_src: "templates/listen_host.xml.j2" # Template к основной конфигурации >
# ClickHouse (добавляет возможность прослушивания на всех интерфейсах) 
clickhouse_template_mode: "0644" # Права файла конфигурации на instance
clickhouse_packages: # List устанавливаемых пакетов
  - clickhouse-client
  - clickhouse-server
  - clickhouse-common-static

```
---

### Vector

Роль выполняет:

- Установку Vector
- Настройку репозитория
- Настройку Vector Pipeline
- Сбор логов Nginx
- Отправку логов в ClickHouse

Основные параметры:

```yaml
# Default variable применяемые в group_vars and host_vars
vector_repo_url: "http://repo" # Адрес репозитория
vector_repo_arch: "x86_64" # Архитектура ОС instance
vector_include_logs: "/var/log/nginx/my_access.log" # Path файла лога для сбора
vector_conf_dest: "/etc/vector/vector.yaml" # Path файла конфигурации на instance

// Переменные подключения к ClickHouse //
vector_clickhouse_http_host: "127.0.0.1" # Адрес ClickHouse
vector_clickhouse_http_port: "8123" # HTTP порт ClickHouse
vector_clickhouse_db_name: "nginx" # Имя базы данных
vector_clickhouse_table_name: "my_access_logs" # Имя таблицы базы данных

# Фиксированные переменные (vars)
vector_repo_dest: "/tmp/vector.rpm" # Path хранения скаченного репозитория
vector_dir_mod: "0755" # Права файла скаченного репозитория 
vector_timeout: 30 # Timeout получения ответа при скачивании репозитории

// Установка репозитория //
vector_dnf_repo_name: "/tmp/vector.rpm" # ath хранения скаченного репозитория
vector_dnf_state: "present" # Режим добавления репозитория
vector_dnf_gpg_check: true # Включить проверку GPG-подписи RPM-пакетов из репозитория

// Template конфигурации Vector//
vector_template_src: "templates/vector.yaml.j2" # Template конфигурации
vector_template_mode: "0644" # Права файла крнфигурации

// Переменные для проверки доступности ClickHouse //
vector_clickhouse_http_delay: 2 # Timeout при старте проверки
vector_clickhouse_http_timeout: 30 # Timeout ожидания получения ответа
```
---

### Nginx

Роль выполняет:

- Установку Nginx
- Развертывание конфигурации
- Создание web-root директории

Основные параметры:
```yaml
# Default variable применяемые в group_vars and host_vars
nginx_user: "nginx" # Пользователь Nginx (применяется в конфигурации и в назначении >
# владельца директории и файлов)
nginx_groups: "nginx" # Группа пользователя Nginx (применяется в назначении >
# владельца директории и файлов)
nginx_create_root_dir: "" # Path create директории размещения статистического >
# контента (определяется условием, если null то директория не создается)
nginx_conf_dest: "/etc/nginx/nginx.conf" # Path файла конфигурации Nginx 

# Фиксированные переменные (vars)
nginx_template_mode: "0644" # Права на файл конфигурации Nginx
nginx_root_dir_mode: "0755" # Права root директории web статистического контента 

// Template //
nginx_template_src: "templates/nginx.conf.j2" # Template файла конфигурации Nginx
```
---

### Website

Роль разворачивает демонстрационную web-страницу и отображает информацию о состоянии сервисов проекта.

Функционал:

- Проверка доступности ClickHouse через HTTP
- Отображение статуса сервисов:
  - Nginx
  - Vector
  - ClickHouse
- Генерация HTML через Jinja2 шаблон

Основные параметры:
```yaml
# Default variable применяемые в group_vars and host_vars
website_web_dest: "/usr/share/nginx/html/index.html" # Path create директории размещения статистического контента
website_clickhouse_server: "http://127.0.0.1:8123" # Адресс ClickHouse для проверки доступности

# Фиксированные переменные (vars)
website_dir_mode: "0644" # Права root директории web статистического контента
website_template_web_src: "templates/index.html.j2" # Template index файла
```
---

### Lighthouse

Роль выполняет:

- Git клонирование репозитория Lighthouse 
- Размещение интерфейса в Nginx
- Настройку доступа к ClickHouse

Основные параметры:

```yaml
# Default variable применяемые в group_vars and host_vars
lighthouse_git_repo: "https://github.com/VKCOM/lighthouse.git" # Адрес репозитория на github
lighthouse_git_dest: "/usr/share/nginx/lighthouse" # Path root директория размещения на Nginx
lighthouse_git_version: "master" # Имя ветки или версии
```
---

### Firewall

Роль выполняет:

- Управление ingress правилами firewalld
- Открытие необходимых TCP портов
- Проверку наличия и состояния firewalld

Открываемые порты определяются через `host_vars`.

Пример:

```yaml
firewall_access_port:
  - 80/tcp
```

```yaml
firewall_access_port:
  - 8123/tcp
```
---

## Variables

### Global

```yaml
clickhouse_http_port: "8123"
set_timezone: "Europe/Moscow"
```
---

### ClickHouse Connection

Vector автоматически получает адрес ClickHouse:

```yaml
vector_clickhouse_http_host: "{{ hostvars['clickhouse-01'].ansible_host }}"
```
---

## Dependencies

Установка ролей:

```bash
ansible-galaxy install -r requirements.yml
```

Используются отдельные Git-репозитории ролей:

- clickhouse-role
- vector-role
- nginx-role
- lighthouse-role
- website-role
- firewall-role

---

## Deployment

### Установка roles

```bash
ansible-galaxy install -r requirements.yml
```

### Запуск playbook

```bash
ansible-playbook -i inventory/dev.yml site.yml
```

---

## Процесс выполнения Playbook

```text
1. ClickHouse
2. Nginx
3. Vector
4. Website
5. Lighthouse
6. Firewall
```
---

## Tags

### ClickHouse

```bash
--tags clickhouse
```

### Vector

```bash
--tags vector
```

### Nginx

```bash
--tags nginx
```

### Website

```bash
--tags website
```

### Lighthouse

```bash
--tags lighthouse
```

### Firewall

```bash
--tags firewall
```

---

## Проверка сервисов

### ClickHouse

```bash
curl http://<clickhouse-host>:8123/ping
```

Expected:

```text
Ok.
```

---

### Vector

```bash
systemctl status vector
```

---

### Nginx

```bash
systemctl status nginx
```

---

### Firewall

```bash
firewall-cmd --list-ports
```

---

## Screenshots

- Website dashboard
<img width="1226" height="468" alt="изображение" src="https://github.com/user-attachments/assets/7acc8a45-82e9-4075-ace8-a929f5d090b0" />

- Lighthouse interface
<img width="1553" height="415" alt="изображение" src="https://github.com/user-attachments/assets/4e311695-e276-4a9f-a1f9-98d95c5a1931" />

---

## Requirements

| Software | Version |
|-----------|----------|
| Ansible | 2.20+ |
| Rocky Linux | 9.x |
| AlmaLinux | 9.x |
| Python | 3.12+ |

---

## License

MIT
