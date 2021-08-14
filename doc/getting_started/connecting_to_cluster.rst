.. _connecting_to_cluster:

================================================================================
Подключаемся к кластеру
================================================================================

В прошлом разделе мы подняли кластер, создали схему и записали данные через HTTP API.
Теперь мы сможем подключиться к кластеру из кода и работать с данными.

.. NOTE::

    Если вы используете Tarantool без Cartridge, то переходите в :ref:`этот раздел<getting_started_connectors>`.

Вы могли обратить внимание, что в коде HTTP обработчиков мы использовали модуль `crud`.
Код выглядел примерно вот так:

.. code:: lua

    local crud = require('crud')

    function add_user(request)
        local result, err = crud.insert_object('users', { user_id = uuid.new(), fullname = fullname })
    end


Этот модуль позволяет работать с данными на кластере и имеет похожий синтаксис,
что предлагает модуль `box` в Tarantool. Про модуль `box` вы узнаете в следующих разделах.

Модуль `crud` содержит набор хранимых процедур и должен быть активирован на всех роутерах
и стораджах как отдельная роль. В прошлом разделе мы ее выбирали в самом начале.
Называются роли соответственно: "crud-router", "crud-storage".

Чтобы писать и читать данные в кластере Tarantool из кода, мы будем вызывать хранимые
процедуры модуля `crud`.

На языке Python это выглядит примерно вот так:

.. code:: python

    res = conn.call('crud.insert', 'users', <uuid>, 'Jim Carrey')
    users = conn.call('crud.select', 'users', { limit: 100 })

Список всех функций модуля `crud` описан `в репозитории на Github`<https://github.com/tarantool/crud/#insert>_`.

В него входит:

- insert
- select
- get
- delete
- min/max
- replace/upsert
- truncate
- и другие

Чтобы узнать, как вызывать хранимые процедуры в вашем языке программирования, смотрите раздел
"Вызов хранимых процедур":

- :ref:`для Python<getting_started-python>`
- :ref:`для Go<getting_started-go>`
- :ref:`для PHP<getting_started-php>`

Для коннекторов к другим языкам, читайте README к `соответствующему коннектору в Github <https://github.com/tarantool>_`.
