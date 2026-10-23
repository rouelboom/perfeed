# Переименование инфраструктуры perfeed и переезд на собственный домен

## Meta
- Status: backlog
- Repo: /Users/pavel/Dev/pets/perfeed
- Branches: main
- Created: 2026-10-23 23:59
- Updated: 2026-10-23 23:59
- Owner: Claude
- Icon: terminal

## Goal
После стабильного релиза сайта unlimited position убрать из инфраструктуры имя perfeed и подготовить переезд с perf-kaluga.site на собственный домен без потери старых ссылок.

## Scope
- Переименовать переменные `PERFEED_*` в `deploy.sh` и `.github/workflows/deploy.yml`, секреты GitHub `PERFEED_SSH_PRIVATE_KEY` и `PERFEED_SSH_KNOWN_HOSTS`.
- Переименовать каталоги на сервере (`/var/www/perfeed`, `/var/www/perfeed-backups`), nginx-сайт `perfeed`, навык `.codex/skills/deploy-perfeed`, имя пакета в `package.json`.
- Переезд на домен: поменять `site` в `astro.config.mjs`, выпустить сертификат, настроить на perf-kaluga.site 301 на новый домен с сохранением пути.
- Настоящие 301 в nginx для старых путей, если они понадобятся.

## Out of Scope
- Изменения контента и дизайна сайта.

## Context
- Основной план: `docs/plans/active/2026-10-23-unlimited-position-site.md` (шаг 14).
- Деплой: `.codex/skills/deploy-perfeed/scripts/deploy.sh`, `.github/workflows/deploy.yml`.
- Ограничение: делать отдельно от контентных изменений, с бэкапом и проверкой отката.

## Plan
- [ ] Дождаться стабильной работы релиза unlimited position.
- [ ] Согласовать новые имена и, если есть, новый домен.
- [ ] Переименовать переменные, секреты, каталоги и nginx-сайт по одному шагу с проверкой после каждого.
- [ ] Перенести сайт на новый домен и настроить 301 со старого.

## Decisions
- Пока нет

## Progress Log
- 2026-10-23 23:59 План создан как шаг 14 основного плана.

## Validation
- Команды проверки пока не добавлены

## Touched Files
- Пока нет

## Next Step
Убедиться, что релиз unlimited position работает стабильно, и согласовать с пользователем новые имена и домен.

## Resume
1. Прочитать этот файл целиком.
2. Проверить секции `Decisions`, `Progress Log`, `Validation`, `Next Step`.
3. Убедиться, что текущая Git-ветка входит в `Meta -> Branches`; если нет, не начинать изменения без явного безопасного переключения.
4. Открыть только файлы из `Context` и `Touched Files`.
5. Продолжить работу с `Next Step`.
