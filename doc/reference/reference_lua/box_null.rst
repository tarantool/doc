.. _box-null:

-------------------------------------------------------------------------------
                             Constant `box.NULL`
-------------------------------------------------------------------------------

There are some major problems with using a Lua **nil** value in tuples.
For example: you can't correctly assess length of sparse array (an array with
nullable values set to null) in case of using Lua **nil** value.

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

To overcome this and some other issues use ``box.NULL`` constant instead.

Using box.NULL
--------------

``box.NULL`` is a value of cdata type representing a NULL pointer.
It is similar to ``msgpack.NULL``, ``json.NULL`` and ``ffi.NULL``. So it is
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
      - null
      - 1
      - 2
      - null
    ...

    tarantool> #t
    ---
    - 5
    ...

.. NOTE::

    There is a possible problem induced by using ``box.NULL``.
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

If condition expression ``x == nil`` is **true** the ``x`` could be **nil** or
``box.NULL``.

To check whether ``x`` is a **nil** but not a ``box.NULL`` use the following
condition expression:

.. code-block:: tarantoolsession

    x == nil and type(x) == 'nil'

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
    or by obtaining data from :ref:`storage spaces <box_space> etc.`).
    You must anticipate such behaviour and use proper condition expression.
