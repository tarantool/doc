.. _compat-option-binary-decoding:

Decoding binary objects
=======================

Option: ``binary_data_decoding``

Starting from version 3.0, Tarantool has the :ref:`varbinary <varbinary_module>` module
for handling binary objects of arbitrary lengths.
The ``binary_data_decoding`` compat option allows to define the format in which
varbinary field values are returned for handling in Lua: plain strings or ``varbinary``
objects.

Old and new behavior
--------------------

New behavior: ``varbinary`` field values are returned as ``varbinary`` objects.

..  code-block:: tarantoolsession

    tarantool> compat.binary_data_decoding = 'new'
    ---
    ...

    tarantool> varbinary.is(msgpack.decode('\xC4\x02\xFF\xFE'))
    ---
    - true
    ...

Old behavior: ``varbinary`` field values are returned as plain strings.

..  code-block:: tarantoolsession

    tarantool> compat.binary_data_decoding = 'old'
    ---
    ...

    tarantool> varbinary.is(msgpack.decode('\xC4\x02\xFF\xFE'))
    ---
    - false
    ...

    tarantool> varbinary.is(yaml.decode('!!binary //4='))
    ---
    - false
    ...

Known compatibility issues
--------------------------

At this point, no incompatible modules are known.

Detecting issues in your codebase
---------------------------------

TBD
