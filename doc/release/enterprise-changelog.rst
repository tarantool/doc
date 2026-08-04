..  _release-enterprise-changelog:

Enterprise SDK changelog
========================

Versioning policy
-----------------

A :ref:`Tarantool Enterprise SDK <tarantool_enterprise>` version consists of two parts:

..  code-block:: text

    <TARANTOOL_BASE_VERSION>-r<REVISION>


For example: ``2.11.1-0-gc42d9735b-r589``.

-   ``TARANTOOL_BASE_VERSION`` is the Community version which the Enterprise version is based on.
-   ``REVISION`` is the SDK revision. Besides Tarantool itself, it includes the ``tt`` utility, a set of open and closed source modules, and examples. Learn more from :ref:`Package contents <enterprise-package-contents>`.

r708
----

В релизе обновлены ключевые зависимости платформы: Tarantool до 2.11.9, модуль ``metrics`` до 1.7.0,
а также утилита tt-ee до 2.12.0. Дополнительно обновлён модуль ``graphqlapi-helpers`` до 0.0.11-1.

Tarantool 2.11 -> 2.11.9
~~~~~~~~~~~~~~~~~~~~~~~~~~

Это bugfix-релиз: исправлено 34 проблемы с предыдущей версии.

* Версия 2.x — старая стабильная ветка; рекомендуется обновляться до 3.x.
* Совместимость: Tarantool 2.x и 3.x совместимы с точки зрения формата бинарных данных, клиент-серверного протокола и протокола репликации.
  Это означает, что обновление можно выполнить без простоя для операций чтения, а для операций записи простой будет порядка сетевой задержки (см. `upgrade procedure <https://www.tarantool.io/en/doc/latest/book/admin/upgrades/>`__).

LuaJIT memory and platform profilers
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Добавлены флаги ``misc.memprof.available`` и ``misc.sysprof.available`` для
  определения доступности соответствующего профайлера в текущей сборке.
  Подробнее про профайлеры в разделах `LuaJIT memory profiler <https://www.tarantool.io/en/doc/latest/tooling/luajit_memprof/>`__ и `LuaJIT platform profiler <https://www.tarantool.io/en/doc/latest/tooling/luajit_memprof/>`__.

Core
^^^^

**Добавлено:**

* Новое встроенное системное событие ``box.wal_error``, которое
  рассылается каждый раз, когда Tarantool не удаётся зафиксировать
  транзакцию в журнале предзаписи (WAL).

**Исправлено:**

* Ошибка, из-за которой Tarantool мог зависать при использовании ``box.watch``.
* Ошибка, при которой файлы ``.xlog.inprogress`` не удалялись
  автоматически во время запуска сервера, если ``wal_dir`` задан и отличается от значения по умолчанию.
* Ошибка, при которой локальный спейс нельзя было очистить
  (truncate), если спейс ``_truncate`` настроен как синхронный (synchronous).


Выбор лидера
^^^^^^^^^^^^

* Если при записи в WAL возникает ``ER_WAL_IO``, текущий лидер при первом же
  таком случае отказывается от своей роли.

LuaJIT
^^^^^^

**Добавлено:**

* Поддержка ``ffi.abi("dualnum")`` для определения режима LuaJIT (dual-number: различение целых int64 и double).

**Исправлено:**

* Некорректная генерация ``IR_TBAR`` на aarch64.
* Обработка переполнения стека при выходе из trace.
* «Висячие» ссылки на ``CType``.
* Закрытие состояния VM после раннего OOM.
* Генерация ``IR_MUL`` на x86/x64.
* Некорректное объединение  инструкций ``stp``/ ``ldp`` на
  aarch64.
* Инвалидизация записи SCEV при возврате в более низкий фрейм.
* Сборка на macOS 15/Clang 16.
* Генерация ``IR_HREFK`` на aarch64.
* Проверки стека в varargs-вызовах в сборке GC64.
* Проверки стека в ``pcall()``/ ``xpcall()`` в сборке GC64.
* Лимит аллокаций для сборки без JIT.
* Обработка ошибок OOM при расширении стека в ``coroutine.resume()``
  и ``lua_checkstack()``.
* Запись (recording) циклов со значением шага ``-0`` или управляющими
  значениями ``NaN``.
* Формирование сообщений об ошибках, когда ошибка возникает во время
  обработки ошибки.
* «Висячая» ссылка для FFI callback.
* ``BC_UNM`` для аргумента ``-0`` в режиме ``dual-number``.
* Сужение (narrowing) унарного минуса в режиме ``dual-number``.
* Запись (recording) ``string.byte()``, ``string.sub()`` и
  ``string.find()``.
* Отсутствие преобразования типов для слотов ``BC_FORI`` в режиме
  ``dual-number``.
* Различные пограничные случаи в ``VM events``.
* Запись разрешения индекса конструктора в JIT-компиляторе.
* Предупреждение UBSan в ``unpack()``.

Модуль Datetime
^^^^^^^^^^^^^^^

**Исправлено:**

* Падение из-за срабатывания ``assert`` при разборе неоднозначной
  даты: когда в тексте одновременно указаны день года (``yday``, который
  неявно задаёт месяц и день месяца) и календарный месяц (без дня месяца).
  Теперь такие случаи распознаются, и выбрасывается ошибка.
* Вычисления ``tzoffset`` для случаев вида
  ``new({timestamp=x, tz='Zone'})``.
* Неконсистентность между датами, создаваемыми
  ``new({tzoffset=x})``, и ``d:set({tzoffset=x})``, когда ``d.tz ~= ''`` идёт
  перед ``set()``.
* Теперь ``datetime.new()`` и ``datetime_object:set()`` проверяют, что значение
  ``timestamp`` находится в допустимом диапазоне.
* Проверка типа ``timestamp`` в ``set()``.

Для обратной совместимости добавлена опция
``compat.datetime_setfn_timestamp_type_check``. Сейчас она по умолчанию
выключена («старое» поведение), то есть проверка типа не выполняется. «Новое»
поведение с проверкой типа планируется сделать значением по умолчанию в версии 4.x.

..  note::

    Ниже приведены модули, затронутые изменениями в этом релизе.
    Отсутствие модуля означает, что обновления для него не выпускались.


crud 1.6.1 → 1.7.5
~~~~~~~~~~~~~~~~~~

**Добавлено:**

* Метод ``crud.locate()`` для определения, где находится кортеж — в движке memtx или vinyl. Работает для спейсов, управляемых enterprise-модулем ``cooler``.
* В ``crud.len`` добавлена поддержка опций: ``mode``, ``balance``, ``prefer_replica``, ``request_timeout``.
* ``safe mode``, предотвращающий запись данных в неверный набор реплик во время ребалансировки vshard.
* Метрика ``tnt_crud_router_cache_clear_ts``, помогающая корректно отключать ``safe mode`` в кластере.
* Автоматическое переключение в ``safe mode`` при старте ребалансировки.
* Возможность вручную вернуть ``fast mode``.
* Метрика ``tnt_crud_storage_nil_bucket_id_compat_total`` для отслеживания операций, выполненных без ``bucket_ref`` (режим совместимости со старыми роутерами).

**Исправлено:**

* Операции только для чтения (``get``, ``select``, ``pairs``, ``count``, ``min``, ``max``) теперь выполняются через здоровые реплики, даже если все мастера в кластере недоступны.
* Совместимость узлов хранилища с роутерами версии < 1.7.0: в ``get``, ``update``, ``delete`` корректно обрабатывается ``bucket_id = nil``. В этом случае storage пропускает ``bucket referencing`` и пишет ``rate-limited`` предупреждение о сниженной безопасности ребаланса во время rolling upgrade.
* Ошибка ``bucket_ref`` в методах ``crud.*_many`` теперь возвращается в виде массива.
* Вызов ``bucket_unref`` вынесен из транзакции.
* Предотвращено создание дублирующихся метрик при повторном вызове ``init``.
* Предотвращено создание дублирующихся триггеров на спейсe ``_crud_settings_local`` при повторном вызове ``init``.
* Взаимная блокировка в ``crud.schema()`` после ошибки перезагрузки схемы.
* Удалена метрика ``tnt_crud_storage_safe_mode_enabled`` с роутера.
* Убрана обёртка ``wrap_box_space_func_result`` для сокращения аллокаций и ускорения вызовов узла хранилища.

**Изменено:**

* При переключении в ``safe mode`` прекращена практика пометки/остановки iproto файберов fast mode; корректность операций на узле хранилища проверяется через ``yield_checks`` в тестах.
* Переключение в safe mode перенесено с триггера ``on_commit`` на ``on_replace``.
* Спейсы на движке vinyl всегда работают в ``safe mode``.

vshard 0.1.37 → 0.1.39
~~~~~~~~~~~~~~~~~~~~~~

Версия 0.1.39 полностью совместима с предыдущими версиями vshard.

**Добавлено:**

* Возможность отключать ограничитель частоты логирования (log rate limiter) через модуль ``consts``.

**Исправлено:**

* Проблема, из‑за которой старый мастер не мог обнаружить нового мастера в пределах набора реплик.
* Утечка соединений: соединение не освобождалось сборщиком мусора после реконфигурации или перезагрузки.
* Ограничение транзакций при работе с ``_bucket``: ранее ``on_commit``‑триггер на ``_bucket`` блокировал запись в другие спейсы в
  рамках той же транзакции (например, из ``on_replace``‑триггеров). Теперь такие сценарии разрешены — в ``on_commit`` пропускаются изменения, относящиеся к «чужим» спейсам.

metrics 1.6.2 → 1.7.0
~~~~~~~~~~~~~~~~~~~~~

*   ``graphite``: добавлена возможность отправлять метрики на несколько серверов.
*   Обратная совместимость с предыдущей версией плагина сохранена.
*   Изменения в поведении:

    -   ``init`` теперь присваивает уникальное имя создаваемому файберу ``fiber`` на основе входных опций ``graphite server`` (если переданы).
    -   добавлен метод ``stop()`` для остановки всех файберов ``fibers``, запущенных плагином.


tt-ee v2.11.4 -> v2.12.0
~~~~~~~~~~~~~~~~~~~~~~~~

*  Исправления, выявленные CVE-линтерами.
* ``tt pack``: добавлена поддержка вложенных файлов ``.packignore`` в корне
  окружения tt.
* ``tt status``: добавлена опция ``--format`` для вывода в форматах JSON и YAML
  (машиночитаемый вывод).


cartridge 2.16.4 → 2.16.6
~~~~~~~~~~~~~~~~~~~~~~~~~

**Изменено:**

* На странице кода дерево файлов больше не раскрывается автоматически по умолчанию.
* Зависимость ``vshard`` до версии 0.1.39.
* Зависимость ``membership`` до версии 2.5.3.
* Зависимость ``cartridge-metrics-role`` до версии 0.1.3.
* Зависимость ``graphql`` до версии 0.3.1.
* Ззависимость ``http`` до версии 1.9.0.

**Исправлено:**

* Мониторинг синхронных спейсов с учётом фактического режима ``failover``:
  предупреждение о синхронных спейсах теперь пишется в журнад только если ``failover`` настроен в режиме, который их не поддерживает (например, ``eventual`` или ``stateful`` без ``synchro_mode``), а не всегда при старте экземпляра;
  в модуль ``cartridge.failover`` добавлена функция ``is_sync_spaces_supported()``; синхронные спейсы теперь определяются динамически, включая спейсы, добавленные во время работы.

http 1.8.0 → 1.9.0
~~~~~~~~~~~~~~~~~~

**Добавлено:**

* Опция ``ssl_verify_client`` .

**Исправлено:**

* Сервер больше не пересоздаётся, если его адрес и порт не изменились.
* Применение параметров сервера при перезагрузке конфигурации: сервер больше не остаётся без изменений после обновления настроек.

**Несовместимое изменение (Breaking change):**

* При указании ``ca_file`` взаимная TLS-аутентификация (mTLS) теперь включается по умолчанию.


graphqlapi-helpers
~~~~~~~~~~~~~~~~~~

* Обновление модуля ``graphqlapi-helpers`` с 0.0.9-1 на 0.0.11-1. Новая версия работает без зависимостей от ``ddl-ee`` и ``crud-ee``.


r703
----

-   Bumped ``checks`` version to 3.4.0.
-   Bumped Cartridge version to `2.16.4 <https://github.com/tarantool/cartridge/releases/tag/2.16.4>`__.
-   Bumped ``vshard`` version to `0.1.37 <https://github.com/tarantool/vshard/releases/tag/0.1.37>`__.

r702
----

-   Bumped ``tarantool-2.11`` series to 2.11.8.

r696
----
-   Moved CI files from ``sdk-ci`` repository.

r695
----

-   Bumped ``tt-ee`` version to v2.11.0.

r694
----

-   Replaced Cartridge EE with Cartridge CE `2.16.3 <https://github.com/tarantool/cartridge/releases/tag/2.16.3>`__.
-   Added CRUD CE `1.6.1 <https://github.com/tarantool/crud/releases/tag/1.6.1>`__.
-   Added  ``expirationd`` CE `1.7.0 <https://github.com/tarantool/expirationd/releases/tag/1.7.0>`__.
-   Added ``ddl`` CE `1.7.1 <https://github.com/tarantool/ddl/releases/tag/1.7.1>`__.
-   Bumped ``metrics`` version to `1.5.0 <https://github.com/tarantool/metrics/releases/tag/1.5.0>`__.
-   Added ``migrations`` CE `1.1.0 <https://github.com/tarantool/migrations/releases/tag/1.1.0>`__.
-   Added ``vshard`` CE `0.1.36 <https://github.com/tarantool/vshard/releases/tag/0.1.36>`__.
-   Moved to Community Edition modules.

r693
----

-   Fixed ``glibc`` package URL to archived.

r692
----

-   Added manual trigger job to run tests to generate ``certificate of compliance``. Ready for Astra Linux.

r691
----

-   Bumped Cartridge version to `2.16.2 <https://github.com/tarantool/cartridge/releases/tag/2.16.2>`__.
-   Bumped ``metrics`` version to `1.4.0 <https://github.com/tarantool/metrics/releases/tag/1.4.0>`__.
-   Bumped ``http`` version to 1.8.0.
-   Bumped ``crud-ee`` version to 1.7.4.

r690
----

-   Bumped ``tt-ee`` version to v2.10.1.

r689
----

-   Bumped Cartridge version to `2.16.0 <https://github.com/tarantool/cartridge/releases/tag/2.16.0>`__.

r688
----

-   Bumped ``vshard-ee`` version to 0.1.34.

r687
----

-   Bumped Cartridge version to `2.15.4 <https://github.com/tarantool/cartridge/releases/tag/2.15.4>`__.

r686
----

-   Bumped ``tt-ee`` version to v2.10.0.

r685
----

-   Bumped ``migrations-ee`` version to 1.3.2.

r684
----

-   Bumped ``tarantool-2.11`` series to 2.11.7.

r683
----

-   Bumped Kafka version to `1.6.10 <https://github.com/tarantool/kafka/releases/tag/1.6.10>`__.

r682
----

-   Bumped Cartridge version to `2.15.3 <https://github.com/tarantool/cartridge/releases/tag/2.15.3>`__.

r681
----

-   Bumped ``vshard-ee`` version to 0.1.33.

r680
----

-   Bumped ``tt-ee`` version to v2.9.1.

r679
----

-   Bumped ``tt-ee`` version to v2.9.0.
-   Bumped Cartridge version to `2.15.2 <https://github.com/tarantool/cartridge/releases/tag/2.15.2>`__.
-   Bumped ``membership`` version to `2.5.2 <https://github.com/tarantool/membership/releases/tag/2.5.2>`__.

r677
----

-   Bumped Cartridge version to `2.15.1 <https://github.com/tarantool/cartridge/releases/tag/2.15.1>`__.
-   Bumped ``tt-ee`` version to v2.8.1.
-   Bumped ``vshard-ee`` version to 0.1.32.

r673
----

-   Bumped Cartridge version to `2.15.0 <https://github.com/tarantool/cartridge/releases/tag/2.15.0>`__.
-   Bumped ``membership`` version to 2.5.1.
-   Bumped ``expirationd-ee`` version to 1.8.0.

r672
----

-   Bumped ``tarantool-2.11`` series to 2.11.6.
-   Bumped ``tt-ee`` version to v2.8.0.
-   Bumped ``migrations-ee`` version to 1.3.1.

r669
----

-   Bumped Cartridge version to `2.14.0 <https://github.com/tarantool/cartridge/releases/tag/2.14.0>`__.
-   Bumped ``membership`` version to `2.4.6 <https://github.com/tarantool/membership/releases/tag/2.4.6>`__.

r662
----

-   Bumped ``vshard-ee`` version to 0.1.31.
-   Bumped ``tt-ee`` version to v2.7.0.

r660
----

-   Bumped ``tt-ee`` version to v2.6.0.
-   Bumped Cartridge version to `2.13.0 <https://github.com/tarantool/cartridge/releases/tag/2.13.0>`__.
-   Bumped ``vshard`` version to `0.1.30 <https://github.com/tarantool/vshard/releases/tag/0.1.30>`__.
-   Bumped ``http`` version to `1.7.0 <https://github.com/tarantool/http/releases/tag/1.7.0>`__.

r659
----

-   Bumped ``tarantool-2.11`` series to 2.11.5.
-   Bumped ``tt-ee`` version to v2.5.2.
-   Updated Kafka to `1.6.9 <https://github.com/tarantool/kafka/releases/tag/1.6.9>`__.
-   Bumped ``tt-ee`` version to v2.5.1.
-   Bumped ``tt-ee`` version to v2.5.0.

r654
----

-   Moved ``cartridge-auth-extension`` to **stable** directory.
-   Bumped ``crud-ee`` version to 1.7.1.
-   Bumped ``migrations-ee`` version to 1.3.0.

r653
----

-   Bumped Cartridge version to `2.12.4 <https://github.com/tarantool/cartridge/releases/tag/2.12.4>`__.
-   Bumped ``vshard`` version to `0.1.29 <https://github.com/tarantool/vshard/releases/tag/0.1.29>`__.
-   Bumped ``http`` version to `1.6.0 <https://github.com/tarantool/http/releases/tag/1.6.0>`__.

r652
----

-   Bumped ``tarantool-2.11`` series to 2.11.4.
-   Bumped Cartridge version to `2.12.3 <https://github.com/tarantool/cartridge/releases/tag/2.12.3>`__.

r650
----

-   Bumped ``tt-ee`` version to v2.4.0.
-   Bumped ``queue`` version to `1.4.2 <https://github.com/tarantool/queue/releases/tag/1.4.2>`__.
-   Added Migration Guide to bundle.

r647
----

-   Updated Oracle to 1.5.0 for x86_64.
-   Updated ``oci`` to 21.14 for x86_64.

r646
----

-   Moved to Enterprise Edition modules.
-   Fixed Docker image due to CentOS 7 EOL.
-   Fixed CI/CD workflows running inside CentOS 7.

r643
----

-   Bumped ``tt-ee`` version to v2.3.1.
-   Enabled ``tt`` bash completion.
-   Updated Kafka to `1.6.8 <https://github.com/tarantool/kafka/releases/tag/1.6.8>`__.

r640
----

-   Updated Docker image.
-   Updated CMake to 3.20.6.
-   Installed dependencies for building OpenSSL.
-   Fixed installation of Python 3.6.

r639
----

-   Enabled back ``aarch64`` jobs.
-   Temporary disabled ``aarch64`` jobs.

r637
----

-   Updated ``metrics`` to `1.1.0 <https://github.com/tarantool/metrics/releases/tag/1.1.0>`__.
-   Updated ``queue`` to `1.4.1 <https://github.com/tarantool/queue/releases/tag/1.4.1>`__.
-   Updated CRUD to `1.5.2 <https://github.com/tarantool/crud/releases/tag/1.5.2>`__.

r636
----

-   Updated Cartridge to `2.11.0 <https://github.com/tarantool/cartridge/releases/tag/2.11.0>`__.
-   Updated ``ddl`` to `1.7.1 <https://github.com/tarantool/ddl/releases/tag/1.7.1>`__.
-   Updated ``vshard`` to `0.1.27 <https://github.com/tarantool/vshard/releases/tag/0.1.27>`__.

r635
----

-   Adjusted CI workflows for ``1.x-2.x`` development branch.
-   Deleted ``tarantool-master`` submodule.

r633
----

-   Updated CRUD to `1.5.1 <https://github.com/tarantool/crud/releases/tag/1.5.1>`__.
-   Updated ``sideservice`` to 0.2.1.
-   Updated ``httpgo`` to 0.2.2.
-   Updated ``httpgo-crud`` to 0.1.1.

r632
----

-   Updated ``cartridge-cli`` to `2.12.12 <https://github.com/tarantool/cartridge-cli/releases/tag/2.12.12>`__.
-   ``tt`` used instead of ``tarantoolctl`` for build/test routines.
-   Made Tarantool and bundle versions correct.
-   Bumped ``tarantool-2.11`` to 2.11.3.

r628
----

-   Updated Cartridge to `2.10.0  <https://github.com/tarantool/cartridge/releases/tag/2.10.0>`__.
-   Updated ``membership`` to `2.4.4  <https://github.com/tarantool/membership/releases/tag/2.4.4>`__.
-   Updated ``ddl`` to `1.7.0  <https://github.com/tarantool/ddl/releases/tag/1.7.0>`__.
-   Updated ``graphqlapi`` to `0.0.11 <https://github.com/tarantool/graphqlapi/releases/tag/0.0.11>`__.

r627
----

-   Updated ``expirationd`` to `1.6.0 <https://github.com/tarantool/expirationd/releases/tag/1.6.0>`__.
-   Updated ``sharded-queue`` to `1.0.0 <https://github.com/tarantool/sharded-queue/releases/tag/1.0.0>`__.
-   Dropped building MacOS bundles.
-   Updated ``cartridge-cli`` to `2.12.11 <https://github.com/tarantool/cartridge-cli/releases/tag/2.12.11>`__.

r623
----

-   Updated ``tt-ee`` to 2.2.1.
-   Updated CRUD to `1.5.0 <https://github.com/tarantool/crud/releases/tag/1.5.0>`__.
-   Updated ``membership`` to `2.4.3 <https://github.com/tarantool/membership/releases/tag/2.4.3>`__.
-   Updated Cartridge to `2.9.0 <https://github.com/tarantool/cartridge/releases/tag/2.9.0>`__.

r619
----

-   Updated bundle ``tt-ee`` aarch64.
-   Updated ``tt-ee`` to 2.2.0.
-   Fixed running Tarantool tests on RED OS.

r616
----

-   Updated CRUD to `1.4.3 <https://github.com/tarantool/crud/releases/tag/1.4.3>`__.
-   Updated ``luatest`` to `1.0.1 <https://github.com/tarantool/luatest/releases/tag/1.0.1>`__.
-   Updated ``migrations`` to `0.7.0 <https://github.com/tarantool/migrations/releases/tag/0.7.0>`__.
-   Updated ``tt-ee`` to 2.1.2.

r613
----

-   Updated Cartridge to `2.8.5 <https://github.com/tarantool/cartridge/releases/tag/2.8.5>`__.
-   Updated CRUD to `1.4.2 <https://github.com/tarantool/crud/releases/tag/1.4.2>`__.
-   Added ``frontend-core`` `8.2.2 <https://github.com/tarantool/frontend-core/releases/tag/8.2.2>`__.
-   Updated ``membership`` to `2.4.2 <https://github.com/tarantool/membership/releases/tag/2.4.2>`__.
-   Updated ``sideservice`` to 0.2.0.
-   Updated ``tt-ee`` to 2.1.1.
-   Updated ``vshard`` to `0.1.26 <https://github.com/tarantool/vshard/releases/tag/0.1.26>`__.

r609
----

-   Updated ``httpgo`` to 0.2.1.
-   Added ``httpgo-crud`` 0.1.0.
-   Updated ``tarantool-2.11`` to 2.11.2.

r606
----

-   Updated ``tarantool-master`` to ``3.0.0-beta1``.

r605
----

-   Updated Cartridge to `2.8.4 <https://github.com/tarantool/cartridge/releases/tag/2.8.4>`__.
-   Updated CRUD to `1.4.1 <https://github.com/tarantool/crud/releases/tag/1.4.1>`__.
-   Updated ``ddl`` to `1.6.5 <https://github.com/tarantool/ddl/releases/tag/1.6.5>`__.
-   Added ``httpgo`` 0.2.0.
-   Updated ``tt-ee`` to 2.0.0.

r598
----

-   Updated ``cartridge-cli`` to `2.12.9 <https://github.com/tarantool/cartridge-cli/releases/tag/2.12.7>`__.
-   Updated ``tt-ee`` to 1.3.1.

r595
----

-   Updated ``tt-ee`` to 1.3.0.
-   Updated Cartridge to `2.8.3 <https://github.com/tarantool/cartridge/releases/tag/2.8.3>`__.
-   Updated ``cartridge-cli-extensions`` to `1.1.2 <https://github.com/tarantool/cartridge-cli-extensions/releases/tag/1.1.2>`__.
-   Updated CRUD to `1.3.0 <https://github.com/tarantool/crud/releases/tag/1.3.0>`__.
-   Updated ``queue`` to `1.3.3 <https://github.com/tarantool/queue/releases/tag/1.3.3>`__.
-   Updated ``sharded-queue`` to `0.1.1 <https://github.com/tarantool/sharded-queue/releases/tag/0.1.1>`__.
-   Updated ``membership`` to `2.4.1 <https://github.com/tarantool/membership/releases/tag/2.4.1>`__.
-   Added tests for Astra Linux 1.7.


r589
----

-   Updated ``tarantool-2.10`` to 2.10.8.
-   Updated ``tarantool-master`` to ``3.0.0-alpha3``.
-   Updated ``migrations`` to 0.6.0.
-   Updated ``tt-ee`` to 1.2.0.
-   Updated ``space-explorer`` to 1.1.8.
-   Updated ``cartridge-metrics-role`` to `0.1.1 <https://github.com/tarantool/cartridge-metrics-role/releases/tag/0.1.1>`__.
-   Updated Cartridge to `2.8.2 <https://github.com/tarantool/cartridge/releases/tag/2.8.2>`__.
-   Updated ``expirationd`` to `1.5.0 <https://github.com/tarantool/expirationd/releases/tag/1.5.0>`__.
-   Added ``sideservice`` 0.1.0.

r579
----

-   Updated ``cartridge-cli`` to `2.12.7 <https://github.com/tarantool/cartridge-cli/releases/tag/2.12.7>`__.
-   Updated ``tarantool-2.11`` to 2.11.1.

r577
----

-   Added CRUD `1.2.0 <https://github.com/tarantool/crud/releases/tag/1.2.0>`__.
-   Added ``ddl`` `1.6.3 <https://github.com/tarantool/ddl/releases/tag/1.6.3>`__.
-   Added ``sharded-queue`` `0.1.0 <https://github.com/tarantool/sharded-queue/releases/tag/0.1.0>`__.
-   Added ``ddl`` `1.6.4 <https://github.com/tarantool/ddl/releases/tag/1.6.4>`__.
-   Updated ``tt-ee`` to 1.1.2.
-   Updated ``cartridge-cli`` to `2.12.6 <https://github.com/tarantool/cartridge-cli/releases/tag/2.12.6>`__.

r563
----

-   Updated ``tarantool-2.10`` to 2.10.7.
-   Updated ``tarantool-2.11`` to 2.11.0.
-   Added Kafka `1.6.6 <https://github.com/tarantool/kafka/releases/tag/1.6.6>`__.
-   Added ``vshard`` `0.1.24 <https://github.com/tarantool/vshard/releases/tag/0.1.24>`__.
-   Added ``metrics`` `1.0.0 <https://github.com/tarantool/metrics/releases/tag/1.0.0>`__.
-   Added ``cartridge-metrics-role`` `0.1.0 <https://github.com/tarantool/cartridge-metrics-role/releases/tag/0.1.0>`__.
-   Added Cartridge `2.8.0 <https://github.com/tarantool/cartridge/releases/tag/2.8.0>`__.
-   Added ``http`` `1.5.0 <https://github.com/tarantool/http/releases/tag/1.5.0>`__.

r557
----

-   Added checks `3.3.0 <https://github.com/tarantool/checks/releases/tag/3.3.0>`__.
-   Updated ``cartridge-cli`` to `2.12.5 <https://github.com/tarantool/cartridge-cli/releases/tag/2.12.5>`__.

r553
----

-   Added ``tt-ee`` and ``tt`` environment configuration.
-   Added CRUD `1.1.1 <https://github.com/tarantool/crud/releases/tag/1.1.1>`__.
-   Added ``avro-schema`` `3.1.1 <https://github.com/tarantool/avro-schema/releases/tag/3.1.0>`__.
-   Added ``expirationd`` `1.4.0 <https://github.com/tarantool/expirationd/releases/tag/1.4.0>`__.
-   Added ``graphql`` `0.3.0 <https://github.com/tarantool/graphql/releases/tag/0.3.0>`__.
-   Added ``graphqlapi`` `0.0.10 <https://github.com/tarantool/graphqlapi/releases/tag/0.0.10>`__.
-   Added ``metrics`` `0.17.0 <https://github.com/tarantool/metrics/releases/tag/0.17.0>`__.
-   Added ``migrations`` `0.5.0 <https://github.com/tarantool/migrations/releases/tag/0.5.0>`__.
-   Added Oracle 1.4.0.
-   Added Cartridge `2.7.9 <https://github.com/tarantool/cartridge/releases/tag/2.7.9>`__.
-   Added ``vshard`` `0.1.23 <https://github.com/tarantool/vshard/releases/tag/0.1.23>`__.
-   Added Kafka `1.6.5 <https://github.com/tarantool/kafka/releases/tag/1.6.5>`__.

r549
----

-   Updated ``tarantool-2.10`` to 2.10.6.

r545
----

-   Updated ``tarantool-2.11`` to 2.11.0-rc2.

r543
----

-   Added the ``tarantool-2.11`` submodule.

r542
----

-   Updated ``tarantool-1.10`` to 1.10.15.

r541
----

-   Updated ``tarantool-master`` to ``3.0.0-entrypoint``.

r540
----

-   Updated ``tarantool-2.10`` to 2.10.5.

r539
----

-   Added ``vshard`` `0.1.22 <https://github.com/tarantool/vshard/releases/tag/0.1.22>`__.

r538
----

-   Updated ``tarantool-2.8`` to apply 2 hotfixes.

r537
----

-   Fixed non-interactive installation of the ``brew`` package.
-   Changed the owner of the ``/usr/local/bin`` directory.
-   Installed ``awscli@1`` instead of ``awscli`` since it takes much less
    time.

r536
----

-   Added the missing property ``2.10`` for scope ``CACHE`` in ``CMakeLists.txt``.

r535
----

-   Added ``expirationd`` `1.3.1 <https://github.com/tarantool/expirationd/releases/tag/1.3.1>`__.

r534
----

-   Added CRUD `1.0.0 <https://github.com/tarantool/crud/releases/tag/1.0.0>`__.

r533
----

-   Used runners with label ``regular`` for builds and the tagged release
    workflow.

r532
----

-   Added ``http`` `1.4.0 <https://github.com/tarantool/http/releases/tag/1.4.0>`__.
-   Added ``space-explorer`` 1.1.7.
-   Added ``checks`` `3.2.0 <https://github.com/tarantool/checks/releases/tag/3.2.0>`__.
-   Added ``metrics`` `0.16.0 <https://github.com/tarantool/metrics/releases/tag/0.16.0>`__.
-   Added Cartridge `2.7.8 <https://github.com/tarantool/cartridge/releases/tag/2.7.8>`__.

r531
----

-   Added the ``-DENABLE_LTO=ON``  flag for ``tarantool-ee@master`` branch to
    CMakeLists.txt.

r530
----

-   Upgraded ``devtoolset`` from 8 to 9. It was required for upgrading ``ld`` from
    2.30 to 2.31+ for LTO.


r529
----

-  Updated tarantool’s ``master`` branch to a recent revision.

r528
----

-  Fixed code style in the Linux and MacOS workflows.

r527
----

-  Reliably installed packages in MacOS builds.

r526
----

-   Refactored the way that GC64 builds are defined in the build workflow.
    There are no changes to the composition of resulting bundles.

r525
----

-   Added alerting failures in builds on stable branches and integration testing
    to VK Teams chats.

r524
----

-   Updated to fresh tarantool master (``2.11.0-entrypoint-107-ga18449d``)

r523
----

-   Added Cartridge `2.7.7 <https://github.com/tarantool/cartridge/releases/tag/2.7.7>`__.

r522
----

-   Outdated workflow runs are now canceled to save CI time.

r521
----

-   Added CRUD `0.14.1 <https://github.com/tarantool/crud/releases/tag/0.14.1>`__.
-   Added ``expirationd`` `1.3.0 <https://github.com/tarantool/expirationd/releases/tag/1.3.0>`__.
-   Added ``metrics`` `0.15.1 <https://github.com/tarantool/metrics/releases/tag/0.15.1>`__.
-   Added ``queue`` `1.2.2 <https://github.com/tarantool/queue/releases/tag/1.2.2>`__.

r520
----

Release SDK by tags:

-   Run workflow in SDK docker container.
-   Uploaded SDK files for 1.10, 2.8, 2.10 versions to release folder.
-   Added consistency check for all versions.

r519
----

*   On feature branches, SDK is now rebuilt only on relevant changes.

r518
----

*   Added ``frontend-core`` `8.2.1 <https://github.com/tarantool/frontend-core/releases/tag/8.2.1>`__.
*   Added ``vshard`` `0.1.21 <https://github.com/tarantool/vshard/releases/tag/0.1.21>`__.
*   Added ``http`` `1.3.0 <https://github.com/tarantool/http/releases/tag/1.3.0>`__.
*   Added Cartridge `2.7.6 <https://github.com/tarantool/cartridge/releases/tag/2.7.6>`__.

r517
----

*   Updated Tarantool EE to 2.10.4.

r516
----

*   Updated bundled OpenSSL to version 1.1.1q.

r515
----

*   Removed support of Tarantool 2.7.
*   Started using ``tarantool/actions/prepare-checkout`` to make builds more stable.

r514
----

*   Remove the local registry and setup using GitHub registry.
*   Sync rocks cache to S3 and back.
*   Setup using shared runners.
*   Refactor and format ``ci-linux.yml`` and ``ci-macos.yml``.

r513
----

*   Removed Kafka 1.5.0 due to a build issue with Tarantool 2.10.3 and higher.
*   Updated Kafka to version `1.6.2 <https://github.com/tarantool/kafka/releases/tag/1.6.2>`__.

r512
----

* Updated ``tuple-keydef`` to version `0.0.3 <https://github.com/tarantool/tuple-keydef/releases/tag/0.0.3>`__.

r511
----

*   Enabled parallel build of rocks for MacOS in CI.

r510
----

*   Updated Tarantool to 2.10.3.
*   Added a readable error for the case when the flight recoder fails
    to write data due to insufficient free space on the disk device.
    Previously, it was sending a ``SIGBUS`` error.
*   Fixed a crash in the flight recorder caused by non-thread-safe log
    recording from multiple threads.

r502
----

*   Updated Tarantool to 2.10.2.
*   Increased resolution of stored entries in flight recorder.
*   Fixed a bug in the flight recorder that resulted in skipping log entries in case
    ``box.cfg.log_level`` is less than ``flightrec_log_level``.

r498
----

*   Updated Tarantool to 2.10.1.
*   Updated Cyrus SASL to version 2.1.28.
*   Updated OpenLDAP to version 2.5.13.
*   Updated LZ4 to version 1.9.3. Fixed `CVE-2021-3520 <https://github.com/advisories/GHSA-gmc7-pqv9-966m>`__.
*   Fixed replication reconnect failure after disabling SSL encryption.
*   Fixed a crash that occurred while tyring to start an instance that has
    a compressed ``memtx`` space.
*   Fixed `CVE-2022-29242 <https://www.cve.org/CVERecord?id=CVE-2022-29242>`__ in GOST SSL engine.
*   Fixed a bug in the flight recorder reader implementation that resulted in
    a hang or error while trying to open an empty section.

r467
----

Breaking changes
~~~~~~~~~~~~~~~~

*   Default audit log format was changed to CSV.

Functionality added or changed
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Enterprise
^^^^^^^^^^

*   Implemented user-defined audit events. Now it's possible to log custom
    messages to the audit log from Lua.

*   **[Breaking change]** Switched the default audit log format to CSV. The
    format can be switched back to JSON using the new ``box.cfg.audit_format``
    configuration option.

*   Implemented the audit log filter. Now, it's possible to enable logging only
    for a subset of all audit events using the new ``box.cfg.audit_filter``
    configuration option.

Core
^^^^

*   Implement constraints and foreign keys. Now a user can create function constraints and foreign key relations
    (:tarantool-issue:`6436`).
*   Changed log level of some information messages from critical to info
    (:tarantool-issue:`4675`).
*   Added predefined system events: ``box.status``, ``box.id``, ``box.election``
    and ``box.schema`` (:tarantool-issue:`6260`).
*   Introduced transaction isolation levels in Lua and IPROTO (:tarantool-issue:`6930`).

Vinyl
^^^^^

*   Disabled the deferred DELETE optimization in Vinyl to avoid possible
    performance degradation of secondary index reads. Now, to enable the
    optimization, one has to set the ``defer_deletes`` flag in space options
    (:tarantool-issue:`4501`).

Lua
^^^

*   Added support of console autocompletion for ``net.box`` objects ``stream``
    and ``future`` (:tarantool-issue:`6305`).

Datetime
^^^^^^^^

*   Parse method to allow converting string literals in extended iso-8601
     or rfc3339 formats (:tarantool-issue:`6731`).
*   The range of supported years has been extended in all parsers to cover
     fully -5879610-06-22..5879611-07-11 (:tarantool-issue:`6731`).

Build
^^^^^

*   Added bundling of *GNU libunwind* to support backtrace feature on
    *AARCH64* architecture and distributives that don't provide *libunwind*
    package.
*   Re-enabled backtrace feature for all *RHEL* distributions by default, except
    for *AARCH64* architecture and ancient *GCC* versions, which lack compiler
    features required for backtrace (gh-4611).

Bugs fixed
~~~~~~~~~~

Enterprise
^^^^^^^^^^

*   Disabled audit log unless explicitly configured. Before this change,
    audit events were written to stderr if ``box.cfg.audit_log`` wasn't set. Now,
    audit log is disabled in this case.
*   Disabled audit logging of replicated events. Now, replicated events
    (for example, user creation) are logged only on the origin, never on a
    replica.

Core
^^^^

*   Banned DDL operations in space on_replace triggers, since they could lead
    to a crash (:tarantool-issue:`6920`).
*   Fixed a bug due to which all fibers created with ``fiber_attr_setstacksize()``
    leaked until the thread exit. Their stacks also leaked except when
    ``fiber_set_joinable(..., true)`` was used.
*   Fixed a crash in mvcc connected with secondary index conflict (:tarantool-issue:`6452`).
*   Fixed a bug which resulted in wrong space count (:tarantool-issue:`6421`).
*   Select in RO transaction now reads confirmed data, like a standalone (auotcommit) select does
    (:tarantool-issue:`6452`).

Replication
^^^^^^^^^^^

*   Fixed potential obsolete data write in synchronous replication
    due to race in accessing terms while disk write operation is in
    progress and not yet completed.
*   Fixed replicas failing to bootstrap when master is just re-started (:tarantool-issue:`6966`).

Lua
^^^

*   Fixed the behavior of tarantool console on SIGINT. Now Ctrl+C discards
    the current input and prints the new prompt (:tarantool-issue:`2717`).

Triggers
^^^^^^^^

*   Fixed assertion or segfault when MP_EXT received via net.box (:tarantool-issue:`6766`).
*   Now ROUND() properly support INTEGER and DECIMAL as the first
    argument (:tarantool-issue:`6988`).

Datetime
^^^^^^^^

*   Intervals received after datetime arithmetic operations may be improperly
    normalized if result was negative

    ..  code-block:: tarantoolsession

        tarantool> date.now() - date.now()
        ---
        - -1.000026000 seconds
        ...

    I.e. 2 immediately called ``date.now()`` produce very close values, whose
    difference should be close to 0, not 1 second (gh-6882).

Net.box
^^^^^^^

*   Changed the type of the error returned by net.box on timeout
    from ``ClientError`` to ``TimedOut`` (:tarantool-issue:`6144`).

r457
----

-   Fixed some binary protocol encryption bugs.

r455
----

-   Added :ref:`binary protocol encryption <enterprise-iproto-encryption>`.
-   Added :ref:`tuple field compression <tuple_compression>`.
