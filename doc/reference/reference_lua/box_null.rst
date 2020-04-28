.. _box-once:

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

``box.NULL`` is a generic pointer to a C-like NULL. So it is
some not **nil** value, even if it is a pointer to NULL.

Use ``box.NULL`` only with capitalized NULL (``box.null`` is incorrect).

.. NOTE::

    Technically speaking ``box.NULL`` equals to ``ffi.cast('void *', nil)``.

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

    will always execute function ``func()`` (as condition ``box.NULL`` will always
    be not **false** nor **nil**).
