# Сборщик changelog для Enterprise SDK

Бот собирает черновик раздела `rNNN` для
`doc/release/enterprise-changelog.rst` из changelog всех компонентов,
которые обновились в SDK, и открывает draft PR в ветку `2.11`.

Тексты переносятся **как есть, на английском**. Вступление, редактура и
перевод на русский (`locale/ru/LC_MESSAGES/release/enterprise-changelog.po`)
делаются вручную в этом же PR.

## Что собирается

Бот описывает **только компоненты, упомянутые в секции ревизии** в
`CHANGELOG.md` SDK (например, `# [711.0.0]`: `bump crud to 1.7.6`, …). Если
указан `--from`, берутся секции всех ревизий диапазона. Версии «было → стало»
бот берёт не из текста записи, а из файлов SDK на тегах `r710.0.0` и
`r711.0.0`:

| Компонент | Откуда версии | Откуда берёт changelog |
|---|---|---|
| Tarantool | `CHANGELOG.md` SDK (`bump tarantool release series 2.11 to …`) | CE: `tarantool/tarantool` → `changelogs/<версия>.md` (GitLab, иначе GitHub Releases). EE: `tarantool/tarantool-ee` → `changelogs/<версия>.md` (GitHub). CE и EE объединяются по подсистемам |
| tt-ee | `CMakeLists.txt` → `TT_EE_CLI_VERSION` | GitLab `tarantool/tt-ee` → `CHANGELOG.md` |
| cartridge-cli | `CMakeLists.txt` → `CARTRIDGE_CLI_VERSION` | GitHub `tarantool/cartridge-cli` → `CHANGELOG.md` |
| Модули (rocks) | `BundleRocks.cmake` → `add_public_rock` / `add_private_rock` | GitHub, по таблице в `modules.json` |

Компоненты, которые изменились в бандле, но не упомянуты в CHANGELOG SDK, в
черновик не попадают (бот только перечисляет их в терминале). Если секции
ревизии в CHANGELOG ещё нет (тег не создан), список берётся из сообщений
коммитов SDK.

Если у компонента обновилось несколько версий подряд, бот берёт записи всех
промежуточных версий.

Для каждого модуля бот пробует источники по очереди:

1. источник из `modules.json` (`CHANGELOG.md`/`.rst`, GitHub Releases или GitLab);
2. GitHub Releases;
3. список коммитов между тегами версий (помечается в черновике — такой текст
   нужно переписать или удалить).

В черновике над каждым компонентом стоит комментарий `.. Source:` (откуда взят
текст), а где ничего не нашлось — `.. TODO:`. Ссылки на issues ставятся только
для публичных репозиториев GitHub: ссылки на закрытые (tarantool-ee,
graphqlapi-helpers, tt-ee на GitLab) в публичную документацию не попадают.

## Настройка (один раз)

Нужны Python 3.8+ (без дополнительных пакетов), `git` и [GitHub CLI](https://cli.github.com/) (`gh`).

1. **Токен GitLab** (corp): GitLab → аватар → *Preferences* → *Access tokens* →
   *Add new token*, scope **`read_api`**.
2. **Токен GitHub**: github.com → *Settings* → *Developer settings* →
   *Personal access tokens* → *Tokens (classic)* → *Generate new token*,
   scope **`repo`**. Если у организации tarantool включён SSO, после создания
   нажмите *Configure SSO* → *Authorize* напротив tarantool. Нужен доступ к
   закрытым `tarantool/tarantool-ee` и `tarantool/graphqlapi-helpers` и право
   пушить в `tarantool/doc`.
3. Сохраните токены в файл, доступный только вам (не коммитьте его и не
   отправляйте в чаты):

   ```bash
   cat > ~/.sdk-changelog.env <<'EOF'
   export GITLAB_URL="https://<адрес corp GitLab>"
   export GITLAB_TOKEN="<токен GitLab>"
   export GH_TOKEN="<токен GitHub>"
   EOF
   chmod 600 ~/.sdk-changelog.env
   echo 'source ~/.sdk-changelog.env' >> ~/.zshrc
   source ~/.zshrc
   ```

4. Проверьте: `gh auth status` должен показать `Logged in to github.com … (GH_TOKEN)`.

Необязательно: `export SDK_DIR=/путь/к/клону/sdk` — тогда файлы SDK читаются из
локального клона (быстрее), а то, чего в нём нет, — через GitLab API.

## Запуск

Из корня репозитория `doc`:

```bash
# Показать черновик в терминале (ничего не меняет)
python3 tools/sdk_changelog/collect.py r712

# Вставить раздел в doc/release/enterprise-changelog.rst в текущей ветке
python3 tools/sdk_changelog/collect.py r712 --write

# Создать ветку 2.11-r712-changelog от origin/2.11, закоммитить и открыть draft PR
python3 tools/sdk_changelog/collect.py r712 --pr
```

`--pr` работает во временной копии репозитория (git worktree): ваша текущая
ветка и незакоммиченные файлы не затрагиваются.

В Claude Code то же самое делает команда `/sdk-changelog r712`.

Дополнительные параметры:

- `--from r709` — если описываете сразу несколько ревизий (по умолчанию
  предыдущая ревизия = текущая − 1);
- `--new-ref origin/1.x-2.x --old-ref r711.0.0` — если тега новой ревизии ещё
  нет (только с `SDK_DIR`);
- `--all` — описать все компоненты, изменившиеся в бандле, а не только упомянутые в CHANGELOG SDK;
- `--alongside` — если раздел ревизии уже есть, не трогать его, а добавить
  черновик над ним как «rNNN (bot draft)» с плашкой о том, что текст собран
  ботом (якоря с суффиксом `-bot-`, чтобы не конфликтовать);
- `--update` — вместе с `--pr`: если ветка бота уже есть, пересобрать её от
  `2.11` и обновить существующий PR, а не создавать новый;
- `--replace` — заменить раздел ревизии, если он уже есть в файле (например,
  после перетегирования SDK);
- `--base`, `--branch` — другая базовая ветка или имя ветки PR.

Для пуша и PR бот использует HTTPS и токен `gh`, SSH-ключ для GitHub не нужен.

## После запуска

1. Откройте PR и пройдитесь по комментариям `.. TODO:`.
2. Напишите вступление раздела, отредактируйте тексты.
3. Обновите русский перевод в `.po`.
4. Уберите комментарии `.. Source:` и `.. TODO:` и снимите с PR статус draft.

## Новый модуль в SDK

Если в `BundleRocks.cmake` появился rock, которого нет в `modules.json`, бот
ищет его в `tarantool/<имя>` с `CHANGELOG.md`, а затем по цепочке источников.
Если модуль живёт в другом месте или ведёт changelog иначе, добавьте запись в
`modules.json` → `rocks`:

```json
"my-module": {"repo": "owner/repo", "source": "changelog", "file": "CHANGELOG.md"}
```

`source`: `changelog` (файл на GitHub), `gitlab` (файл на corp GitLab),
`releases` (GitHub Releases), `commits` (коммиты между тегами), `manual`
(ничего не искать, оставить TODO).

Новый компонент с версией в `CMakeLists.txt` SDK добавляется в `modules.json` →
`cmake` с полем `var` — имя переменной CMake.
