# backupd — демон регулярного резервного копирования

`backupd` — учебный проект демона для автоматического резервного копирования каталогов в Linux с интеграцией в `systemd`.
Резервное копирование выполняется **периодически** по расписанию `systemd timer`.

---

## Что умеет

- Хранит настройки в конфигурационном файле `/etc/default/backupd.conf`
- Запускает копирование **по расписанию** через `backupd.timer` → `backupd.service`
- Создаёт резервную копию в каталоге `TARGET` в подпапку с временной меткой вида  
  `ДД_ММ_ГГГГ__ЧЧ_ММ_СС`
- Пишет сообщения в системный журнал `journald` (просмотр через `journalctl` или `backupd log`)
- Даёт команды управления через `/usr/local/bin/backupd`:
  `enable/disable/status/set/run/log/help`
- Проверяет корректность параметров (пути, конфликты source/target, минимальная частота)

---

## Состав проекта

- `code/backupd_run.cpp` — программа копирования (C++17)
- `rootfs/usr/local/bin/backupd_run` — установленный бинарник копирования
- `rootfs/usr/local/bin/backupd` — утилита управления (bash)
- `rootfs/etc/default/backupd.conf` — конфигурационный файл
- `rootfs/etc/systemd/system/backupd.service` — unit сервиса
- `rootfs/etc/systemd/system/backupd.timer` — unit таймера
- `install.sh` — установка в систему
- `uninstall.sh` — удаление из системы

После установки файлы оказываются в:

- `/usr/local/bin/backupd`
- `/usr/local/bin/backupd_run`
- `/etc/default/backupd.conf`
- `/etc/systemd/system/backupd.service`
- `/etc/systemd/system/backupd.timer`

---

## Требования

- Linux с `systemd`
- Компилятор C++ с поддержкой **C++17** (например, `g++`)
- Утилиты: `systemctl`, `journalctl`, `realpath`
- Права администратора для установки/удаления и для изменения настроек

---

## Установка

В каталоге проекта:

```bash
sudo ./install.sh
```

Скрипт:
- компилирует `code/backupd_run.cpp`
- копирует конфиг, units и утилиты в системные каталоги
- выполняет `systemctl daemon-reload`
- по умолчанию **отключает таймер**, чтобы он не стартовал сразу

Проверка после установки:

```bash
backupd status
```

---

## Настройка

Конфигурация хранится в:

```bash
/etc/default/backupd.conf
```

### Изменение настроек через команду `backupd set`

```bash
backupd set source /абсолютный/путь/к/источнику
backupd set target /абсолютный/путь/к/копиям
backupd set frequency 2min
```

#### Ограничения и проверки

**source / target**
- путь должен быть **абсолютным** (начинаться с `/`)
- запрещены опасные каталоги:
  - `/`
  - `/proc`, `/sys`, `/dev`, `/run` (и любые подпапки внутри них)
- `source` **обязан существовать** и быть директорией
- `target` может не существовать (создастся при первом запуске копирования)
- запрещён конфликт:
  - `target` не может быть равен `source`
  - `target` не может лежать внутри `source`

**frequency**
- формат проверяется через `systemd-analyze timespan`
- интервал не может быть меньше `5s`

> Примеры корректного времени: `30s`, `5min`, `1h`, `1day`, `1week`, а также комбинации вроде `1h 30min`.
---

## Запуск и управление

### Включить автокопирование по расписанию

```bash
backupd enable
```
- включает таймер в автозагрузку
- запускает таймер сразу

### Отключить автокопирование

```bash
backupd disable
```

### Посмотреть статус

```bash
backupd status
```

Показывает:
- состояние `backupd.timer` и `backupd.service`
- текущий `/etc/default/backupd.conf`

### Выполнить копирование вручную

```bash
backupd run
```

### Посмотреть журнал

```bash
backupd log
```

Показывает сообщения за последний час по `backupd.timer` и `backupd.service`.

### Справка

```bash
backupd help
# или
backupd --help
# или
backupd -h
```

---

## Журналирование: куда пишутся логи

Проект использует системный журнал `journald`.

Просмотр:

```bash
journalctl -u backupd.timer -u backupd.service
```

или

```bash
backupd log
```
---

## Удаление

```bash
sudo ./uninstall.sh
```

Скрипт отключает таймер, удаляет установленные файлы и выполняет `daemon-reload`.

---
