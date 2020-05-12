.. _box-null:

-------------------------------------------------------------------------------
                             Constant `box.NULL`
-------------------------------------------------------------------------------

There are some major problems with using a Lua **nil** value in tables.
For example: you can't correctly assess length of a table that is not a sequence.

**Example:**

.. code-block:: tarantoolsession

    tarantool> t = {0, nil, 1, 2, nil}
    ---
    ...

    tarantool> t
    ---
    - - 0
      - null
      - 1
      - 2
    ...

    tarantool> #t
    ---
    - 4
    ...

Console output of ``t`` processes **nil** value in the middle and at the end of
the table differently. This is due to undefined behaviour.

.. NOTE::

    Trying to find length for sparse arrays in LuaJIT leads to another
    `undefined behaviour <https://www.lua.org/manual/5.2/manual.html#3.4.6>`_.

To overcome this issue use ``box.NULL`` constant instead of **nil**.
``box.NULL`` is a placeholder for a **nil** value in tables to preserve a key
without a value.

Using box.NULL
--------------

``box.NULL`` is a value of cdata type representing a NULL pointer.
It is similar to ``msgpack.NULL``, ``json.NULL`` and ``yaml.NULL``. So it is
some not **nil** value, even if it is a pointer to NULL.

Use ``box.NULL`` only with capitalized NULL (``box.null`` is incorrect).

.. NOTE::

    Technically speaking ``box.NULL`` equals to ``ffi.cast('void *', 0)``.

**Example:**

.. code-block:: tarantoolsession

    tarantool> t = {0, box.NULL, 1, 2, box.NULL}
    ---
    ...

    tarantool> t
    ---
    - - 0
      - null # cdata
      - 1
      - 2
      - null # cdata
    ...

    tarantool> #t
    ---
    - 5
    ...

.. NOTE::

    Take a notice how t[2] shows the same ``null`` output in both examples.
    However in this example t[2] and t[5] is a cdata type. While in the previous
    example their type was **nil**.

.. important::

    Avoid using implicit comparisons with nullable values when using ``box.NULL``.
    Due to `Lua behaviour <https://www.lua.org/manual/5.1/manual.html#2.4.4>`_
    returning from condition expression anything except **false** or **nil**
    is considered as **true**. And as it was mentioned earlier ``box.NULL`` is a
    pointer by design.

    That is why expression ``box.NULL`` will always be considered true in case
    it is used as condition in comparison. This means that code

    ``if box.NULL then func() end``

    will always execute function ``func()`` (because condition ``box.NULL`` will
    always be neither **false** nor **nil**).

Distinction of nil and box.NULL
-------------------------------

Use expression ``if x == nil`` to check if the ``x`` is either **nil** or ``box.NULL``.

To check whether ``x`` is a **nil** but not a ``box.NULL`` use the following
condition expression:

.. code-block:: tarantoolsession

    type(x) == 'nil'

If its **true** then the ``x`` is a **nil**, but not a ``box.NULL``.

You can use the following for ``box.NULL``:

.. code-block:: tarantoolsession

    x == nil and type(x) == 'cdata'

If the expression above is **true** then the ``x`` is a ``box.NULL``.

.. NOTE::

    By converting data to different format (JSON, YAML, msgpack) you shall expect
    that it is possible, that **nil** in sparse arrays will be converted to
    ``box.NULL``. And it is worth mentioning that such convertation might be
    unexpected (for example: by sending data via :ref:`net.box <net_box-module>`
    or by obtaining data from :ref:`spaces <box_space> etc.`).

    .. code-block:: tarantoolsession

        tarantool> type(({1, nil, 2})[2])
        ---
        - nil
        ...

        tarantool> type(json.decode(json.encode({1, nil, 2}))[2])
        ---
        - cdata
        ...

    You must anticipate such behaviour and use proper condition expression.
    Use explicit comparison ``x == nil`` for checking for NULL in nullable values.
    It will detect both **nil** and ``box.NULL``.
