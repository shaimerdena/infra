# Docker Fundamentals & Containerization

## Содержание

- [Docker Fundamentals \& Containerization](#docker-fundamentals--containerization)
  - [Содержание](#содержание)
  - [1. Containerization: базовые понятия](#1-containerization-базовые-понятия)
    - [VM vs Linux containers](#vm-vs-linux-containers)
    - [Namespaces vs cgroups](#namespaces-vs-cgroups)
  - [2. Docker architecture](#2-docker-architecture)
    - [Что происходит при `docker run nginx`?](#что-происходит-при-docker-run-nginx)
  - [3. Image vs Container](#3-image-vs-container)
  - [4. Dockerfile](#4-dockerfile)
    - [Основные инструкции](#основные-инструкции)
    - [Exec form vs shell form](#exec-form-vs-shell-form)
  - [5. Image layers и build cache](#5-image-layers-и-build-cache)
    - [Почему зависимости копируют раньше кода?](#почему-зависимости-копируют-раньше-кода)
  - [6. Имена образов, registries и multi-platform images](#6-имена-образов-registries-и-multi-platform-images)
    - [Manifest list / multi-platform image](#manifest-list--multi-platform-image)
  - [7. Жизненный цикл контейнера и restart policies](#7-жизненный-цикл-контейнера-и-restart-policies)
    - [Restart policies](#restart-policies)
  - [8. Build context и `.dockerignore`](#8-build-context-и-dockerignore)
  - [9. Multi-stage builds](#9-multi-stage-builds)
  - [10. CMD vs ENTRYPOINT](#10-cmd-vs-entrypoint)
    - [Пример 1](#пример-1)
    - [Пример 2](#пример-2)
  - [11. Docker storage: writable layer, volumes, bind mounts](#11-docker-storage-writable-layer-volumes-bind-mounts)
    - [Volume vs bind mount](#volume-vs-bind-mount)
  - [12. Docker networking](#12-docker-networking)
    - [Коротко о режимах](#коротко-о-режимах)
  - [13. Stateful vs Stateless applications](#13-stateful-vs-stateless-applications)
    - [Stateful application](#stateful-application)
    - [Stateless application](#stateless-application)
    - [Почему в Docker называют stateful applications antipattern?](#почему-в-docker-называют-stateful-applications-antipattern)
    - [Пример архитектуры](#пример-архитектуры)
  - [14. Docker Compose и Docker ecosystem](#14-docker-compose-и-docker-ecosystem)
    - [Docker Compose](#docker-compose)
    - [Только ли Compose для локальной разработки?](#только-ли-compose-для-локальной-разработки)
    - [Docker ecosystem](#docker-ecosystem)
  - [16. Короткая шпаргалка](#16-короткая-шпаргалка)

------------------------------------------------------------------------

## 1. Containerization: базовые понятия

**Containerization** --- способ упаковать приложение и необходимые ему
runtime/dependencies в контейнерный образ, чтобы приложение можно было
запускать предсказуемее в разных окружениях.

Контейнеризация помогает уменьшить ситуацию «у меня на компьютере
работает, а на сервере нет», но **не гарантирует**, что приложение
запустится абсолютно везде. Всё ещё имеют значение архитектура CPU,
ОС/ядро, конфигурация, доступные ресурсы, сети, секреты и внешние
зависимости.

### VM vs Linux containers

-   **Virtual Machine (VM)** запускает собственную гостевую ОС с
    собственным ядром.
-   **Linux container** обычно использует ядро Linux хоста, изолируя
    процессы и другие ресурсы.
-   Контейнеры часто легче и быстрее запускаются, чем полноценные VM,
    потому что не требуют отдельного гостевого ядра для каждого
    контейнера.

На macOS Linux-контейнеры всё равно могут запускаться: Docker Desktop
обычно использует Linux VM под капотом. Поэтому неверно говорить, что
Mac вообще не умеет запускать Docker-контейнеры.

### Namespaces vs cgroups

Это два разных механизма изоляции/контроля Linux:

-   **Namespaces** определяют, что процесс видит: например, PID
    namespace изолирует представление процессов, network namespace ---
    сетевое окружение, mount namespace --- точки монтирования.
-   **cgroups** ограничивают или учитывают потребление ресурсов группой
    процессов: CPU, память, I/O и т. п.

Процесс может выглядеть как PID 1 внутри контейнера и иметь другой PID
на хосте --- это один из эффектов PID namespace.

**Запомнить:** namespaces --- «что процесс видит»; cgroups --- «сколько
ресурсов он использует».

------------------------------------------------------------------------

## 2. Docker architecture

Основные элементы:

-   **Docker CLI / client** --- интерфейс, через который пользователь
    вводит команды, например `docker run nginx`.
-   **Docker daemon / Docker Engine** --- управляет образами,
    контейнерами, сетями, volumes и выполняет операции через Docker API.
-   **Registry** --- место хранения и распространения image, например
    Docker Hub или registry GitLab.

CLI не является самим контейнером и не выполняет приложение внутри себя.
Он отправляет запросы Docker Engine. На Linux клиент обычно общается с
daemon через Unix socket `/var/run/docker.sock`; возможна и удалённая
конфигурация daemon.

### Что происходит при `docker run nginx`?

В общих чертах:

1.  Docker проверяет, доступен ли образ `nginx` локально.
2.  Если образа нет, пытается скачать его из registry.
3.  Создаёт контейнер на основе образа.
4.  Запускает контейнер.

**Docker Hub хранит образы; контейнеры запускаются на Docker Engine, а
не «внутри Docker Hub».**

------------------------------------------------------------------------

## 3. Image vs Container

-   **Image** --- шаблон/пакет, из которого создают контейнеры.
-   **Container** --- запущенный или остановленный экземпляр, созданный
    на основе image.

Из одного image можно создать несколько контейнеров.

Контейнер обычно имеет writable layer поверх слоёв образа. Изменения,
записанные в эту writable layer, не меняют исходный image. Если удалить
контейнер, данные только в writable layer обычно удаляются вместе с ним.

Для важных постоянных данных используй **volume** или **bind mount**.

Пример:

``` bash
docker build -t log-analyzer .
docker run --name analyzer log-analyzer
```

Первая команда собирает image `log-analyzer` из Dockerfile и build
context текущей директории. Вторая создаёт и запускает контейнер с
именем `analyzer`.

------------------------------------------------------------------------

## 4. Dockerfile

Dockerfile описывает, как собрать image.

Пример:

``` dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
ENV APP_ENV=production
USER nobody
CMD ["python", "app.py"]
```

### Основные инструкции

-   `FROM` --- базовый image.
-   `WORKDIR /app` --- устанавливает рабочую директорию внутри image;
    если её нет, Docker обычно создаёт её. Это **не** директория на Mac.
-   `COPY requirements.txt .` --- копирует файл из build context в
    рабочую директорию, в данном примере `/app/requirements.txt`.
-   `RUN ...` --- выполняет команду во время сборки image; например,
    устанавливает зависимости.
-   `COPY . .` --- копирует содержимое build context в рабочую
    директорию, кроме файлов, исключённых через `.dockerignore`. Это не
    означает буквально «все файлы компьютера».
-   `ENV APP_ENV=production` --- задаёт переменную окружения в
    image/container. Она нужна, только если приложение её использует. Не
    помещай секреты в Dockerfile/ENV, если image может распространяться.
-   `USER nobody` --- выбирает пользователя для последующих инструкций и
    запуска контейнера. Этот пользователь должен существовать в image;
    инструкция сама по себе его не создаёт. Работа не от root уменьшает
    потенциальный ущерб, но не является полной гарантией безопасности.
-   `CMD` --- задаёт команду/аргументы по умолчанию; их можно
    переопределить при `docker run`.
-   `ENTRYPOINT` --- задаёт основной исполняемый файл/команду
    контейнера.

### Exec form vs shell form

Exec form:

``` dockerfile
CMD ["python", "app.py"]
```

Обычно запускает процесс без промежуточной shell. Переменные shell
автоматически не раскрываются.

Shell form:

``` dockerfile
CMD python app.py
```

Запускается через shell; обработка сигналов и переменных может
отличаться.

------------------------------------------------------------------------

## 5. Image layers и build cache

Image состоит из переиспользуемых слоёв. При сборке Docker может
использовать cache, если инструкция и нужные ей входные данные
соответствуют ранее собранному шагу и кэш доступен.

Для примера:

``` dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

Концептуально важные filesystem changes здесь включают базовый image,
копирование `requirements.txt`, установку зависимостей и копирование
приложения. Не каждая инструкция Dockerfile создаёт отдельный filesystem
layer: например, `WORKDIR` и `CMD` обычно не создают самостоятельный
слой файловой системы.

### Почему зависимости копируют раньше кода?

Если сначала скопировать `requirements.txt` и установить зависимости, а
затем копировать код приложения, изменение одного исходного файла не
обязательно заставит Docker повторно устанавливать все зависимости. Так
эффективнее используется build cache.

**Нюанс:** cache зависит от инструкций, входных файлов, build context и
доступности сохранённого кэша.

------------------------------------------------------------------------

## 6. Имена образов, registries и multi-platform images

Образ часто обозначается как `repository/image:tag`, например:

-   `python:3.12-slim`
-   `nginx:1.28`

`latest` --- всего лишь имя тега. Оно **не гарантирует**, что образ
является самой новой версией в смысле номера версии или что это лучший
выбор для production.

Registry (например, Docker Hub или GitLab Container Registry) хранит
образы.

**Official image** часто имеет более понятную поддержку и документацию,
но само слово `official` не является абсолютной гарантией безопасности.

### Manifest list / multi-platform image

Один тег может указывать на варианты для разных платформ, например
`linux/amd64` и `linux/arm64`. Docker может выбрать совместимый вариант
для целевой платформы.

Это особенно полезно, когда разработчик использует Mac с Apple Silicon
(ARM64), а сервер может работать на AMD64.

------------------------------------------------------------------------

## 7. Жизненный цикл контейнера и restart policies

Когда основной процесс контейнера завершается, контейнер
останавливается.

Полезные команды:

``` bash
docker ps       # только запущенные контейнеры
docker ps -a    # также остановленные контейнеры
docker stop web # остановить контейнер
docker start web # снова запустить существующий контейнер
docker rm web   # удалить остановленный контейнер
```

`docker stop` не удаляет контейнер. `docker start` запускает
существующий контейнер; `docker rm` удаляет его.

Данные, которые существуют только в writable layer, не сохраняются после
удаления контейнера. Volumes/bind mounts нужны для данных, жизненный
цикл которых должен быть независим от контейнера.

### Restart policies

-   `always`
-   `unless-stopped`
-   `on-failure`

Политика перезапуска влияет на поведение при выходе процесса и в
определённых сценариях рестарта Docker daemon. Точное поведение зависит
от выбранной политики и от того, был ли контейнер остановлен явно.

------------------------------------------------------------------------

## 8. Build context и `.dockerignore`

Команда:

``` bash
docker build -t log-analyzer .
```

Точка `.` означает текущую директорию как **build context** --- набор
файлов, которые Docker получает для сборки. Это не путь внутри
контейнера.

`.dockerignore` исключает ненужные файлы из build context, например
`.git`, логи или локальные файлы окружения. Исключать следует только то,
что не требуется для сборки; не нужно копировать секреты в image.

Практики из лекции:

-   указывать осмысленную версию базового image;
-   уменьшать build context;
-   использовать cache;
-   не включать ненужные большие файлы;
-   рассматривать multi-stage build;
-   обычно держать один основной тип приложения/сервиса на контейнер;
-   не выбирать Alpine автоматически только потому, что image маленький
    --- сначала проверь совместимость и требования приложения.

------------------------------------------------------------------------

## 9. Multi-stage builds

**Multi-stage build** позволяет использовать один этап для сборки
приложения и другой --- для запуска готового артефакта. Так runtime
image может не содержать компилятор, исходники и build-зависимости.

Пример для Go-проекта `log-analyzer`:

``` dockerfile
FROM golang:1.25 AS builder
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/log-analyzer .

FROM scratch
COPY --from=builder /out/log-analyzer /log-analyzer
ENTRYPOINT ["/log-analyzer"]
```

Это учебный пример: `golang:1.25` здесь иллюстративный тег, а для
реального проекта нужно выбрать поддерживаемую версию Go, совместимую с
кодом.

`scratch` --- пустой runtime image. Он подходит не каждому приложению.
Если программе нужны CA certificates для TLS, конфиги, динамические
библиотеки или другие внешние файлы, их надо добавить или выбрать более
подходящий runtime image.

Преимущества более компактного runtime image могут включать меньший
размер, более быструю передачу и меньшую поверхность атаки. Но маленький
image сам по себе не гарантирует безопасность.

------------------------------------------------------------------------

## 10. CMD vs ENTRYPOINT

В exec form `ENTRYPOINT` задаёт основную программу, а `CMD` может
задавать аргументы по умолчанию для неё.

### Пример 1

``` dockerfile
ENTRYPOINT ["python", "app.py"]
```

Запуск:

``` bash
docker run my-app
```

Запускает `python app.py`.

Если выполнить:

``` bash
docker run my-app other.py
```

аргумент добавится к ENTRYPOINT, и получится `python app.py other.py`.

### Пример 2

``` dockerfile
ENTRYPOINT ["python"]
CMD ["app.py"]
```

-   `docker run my-app` → `python app.py`
-   `docker run my-app other.py` → `python other.py`
-   `docker run my-app -V` → `python -V`

Shell-переменные в exec form автоматически не раскрываются. Например,
`CMD ["echo", "$HOME"]` может вывести буквальный `$HOME`. Если нужно
shell expansion, можно явно запустить shell, например
`CMD ["sh", "-c", "echo $HOME"]`.

------------------------------------------------------------------------

## 11. Docker storage: writable layer, volumes, bind mounts

У контейнера есть writable layer поверх image layers. Но она связана с
жизненным циклом контейнера, поэтому не подходит как единственное место
для важных постоянных данных.

Слайды перечисляли storage drivers: `AUFS`, `Btrfs`, `Device mapper`,
`Overlay2`, `ZFS`, `VFS`. Конкретная доступность зависит от Docker
Engine, ОС и конфигурации. Проверить активный storage driver можно
командой:

``` bash
docker info
```

На macOS Docker Desktop использует Linux VM; сведения о Linux storage
driver относятся к Docker Engine внутри неё.

### Volume vs bind mount

-   **Docker volume** --- хранилище, управляемое Docker.
-   **Bind mount** --- конкретный путь хоста, подключённый к пути внутри
    контейнера.

Пример с volume:

``` bash
docker volume create analyzer-logs
docker run --rm \
  --mount source=analyzer-logs,target=/app/logs \
  log-analyzer
```

Пример с bind mount:

``` bash
docker run --rm \
  --mount type=bind,source="$PWD/logs",target=/app/logs \
  log-analyzer
```

В первом случае Docker управляет volume; во втором приложение пишет в
указанную директорию хоста.

------------------------------------------------------------------------

## 12. Docker networking

Слайды перечисляли основные типы сетей:

-   `bridge`
-   `host`
-   `none`
-   `overlay`
-   `macvlan`

### Коротко о режимах

-   **bridge** --- типичный вариант для контейнеров на одном Docker
    host. Пользовательские bridge networks поддерживают обнаружение
    контейнеров по имени через DNS.
-   **host** --- контейнер использует сетевой namespace хоста вместо
    отдельного сетевого namespace контейнера.
-   **none** --- обычная внешняя Docker-сеть не подключена; loopback
    остаётся доступен.
-   **overlay** --- позволяет соединять контейнеры на разных Docker
    hosts в поддерживаемой конфигурации.
-   **macvlan** --- контейнер получает собственный MAC address и может
    выглядеть для сети как отдельное устройство; нужны подходящие
    сетевые условия.

Пример сети для приложения и PostgreSQL:

``` bash
docker network create app-net

docker run -d \
  --name postgres \
  --network app-net \
  -e POSTGRES_PASSWORD=devpassword \
  postgres

docker run --rm --network app-net log-analyzer
```

В пользовательской bridge network приложение может подключаться к базе
по hostname `postgres`. Пароль в примере --- только для локального
учебного сценария, не для production.

------------------------------------------------------------------------

## 13. Stateful vs Stateless applications

Это важное различие, которое мы отдельно разбирали.

**Stateful** и **stateless** описывают поведение приложения --- хранит
ли оно состояние между запросами/запусками, --- а не конкретное место
хранения данных.

### Stateful application

Приложение хранит и поддерживает состояние. Например, PostgreSQL хранит
таблицы, пользователей и транзакции.

Stateful-приложение может хранить файлы в writable layer или в volume.
Само по себе использование writable layer не делает приложение stateful;
оно лишь определяет, где оказались изменения.

### Stateless application

Приложение не хранит собственное постоянное состояние между запросами.
Например, API принимает запрос, обращается к PostgreSQL и возвращает
результат. Контейнер API можно заменить новым, если нужное состояние
хранится отдельно.

**Stateless не означает, что во всей системе нет данных.** Данные могут
храниться во внешней базе, объектном хранилище или другом сервисе.

### Почему в Docker называют stateful applications antipattern?

Stateful-приложения не запрещены и не являются плохими сами по себе.
Антипаттерн --- полагаться на эфемерную writable layer контейнера как на
единственное хранилище постоянных данных.

Если удалить контейнер, изменения только в его writable layer могут
исчезнуть. Если данные базы лежат в отдельном volume, контейнер можно
удалить и пересоздать с тем же volume, чтобы снова получить доступ к
данным.

Нужно соблюдать несколько условий: volume не должен быть удалён, новый
контейнер должен правильно его подключить, версия/конфигурация
PostgreSQL должны быть совместимыми, а данные не должны быть повреждены.
Volume не заменяет резервные копии.

### Пример архитектуры

``` text
API container (stateless)
        |
        v
PostgreSQL container (stateful)
        |
        v
Docker volume (persistent data)
```

Если удалить API-контейнер, записи пользователей останутся в PostgreSQL.
Если удалить PostgreSQL-контейнер, но сохранить volume, данные можно
использовать повторно, создав новый совместимый контейнер и подключив
тот же volume.

Если удалить и контейнер, и volume, простое создание нового пустого
контейнера не вернёт удалённые данные. Для восстановления понадобится
backup или другая копия данных.

------------------------------------------------------------------------

## 14. Docker Compose и Docker ecosystem

### Docker Compose

Compose описывает несколько сервисов и связанные ресурсы в файле
`compose.yaml`/`docker-compose.yml`, а затем позволяет управлять ими
вместе.

Например, API и PostgreSQL удобно описать в одном файле, чтобы не
запускать контейнеры вручную и отдельно не настраивать их сеть и
параметры.

``` yaml
services:
  app:
    build: .
    ports:
      - "8000:8000"
    depends_on:
      - db

  db:
    image: postgres:17
    environment:
      POSTGRES_PASSWORD: devpassword
    volumes:
      - postgres-data:/var/lib/postgresql/data

volumes:
  postgres-data:
```

Запуск:

``` bash
docker compose up -d
```

Это упрощённый учебный пример. `depends_on` сам по себе не гарантирует,
что PostgreSQL уже готов принимать соединения. Для production нужно
продумать health checks/readiness, секреты, backup, безопасность сети,
мониторинг и восстановление.

### Только ли Compose для локальной разработки?

Нет. Compose часто используют локально, потому что удобно поднимать
несколько сервисов сразу, но он может применяться и для развёртывания на
собственном VPS или одном сервере.

Для больших кластеров с несколькими серверами, автоматическим
размещением workloads и расширенными механизмами оркестрации обычно
рассматривают Kubernetes или другую подходящую платформу. Compose сам по
себе не предоставляет полный набор возможностей кластерного
оркестратора.

### Docker ecosystem

Слайды объединяли инструменты в три группы:

-   **Docker Compose** --- описание и запуск нескольких связанных
    сервисов;
-   **Registry** (Docker Hub, GitLab Registry, облачные registries) ---
    хранение образов;
-   **Orchestrators** --- например, HashiCorp Nomad, Kubernetes, Docker
    Swarm; они управляют workloads и сервисами в более сложных
    окружениях.

## 16. Короткая шпаргалка

| Понятие | Главное |
|---|---|
| Image | Шаблон для создания контейнеров |
| Container | Запущенный экземпляр image (образа) |
| Docker CLI | Клиент для отправки команд Docker Engine |
| Registry | Хранилище образов |
| Dockerfile | Инструкции для сборки image |
| Build context | Файлы, предоставленные Docker для сборки |
| Layer | Слой файловой системы image |
| Writable layer | Записываемый слой контейнера; не место для единственной копии важных данных |
| Volume | Хранилище, управляемое Docker |
| Bind mount | Путь на хосте, подключённый к контейнеру |
| `CMD` | Команда или аргументы по умолчанию |
| `ENTRYPOINT` | Основная команда контейнера |
| Multi-stage build | Разделение сборки и runtime image |
| Bridge network | Сеть контейнеров на одном Docker host |
| Stateful | Приложение поддерживает состояние |
| Stateless | Приложение не хранит собственное постоянное состояние между запросами |
| Docker Compose | Описание и совместный запуск нескольких сервисов |