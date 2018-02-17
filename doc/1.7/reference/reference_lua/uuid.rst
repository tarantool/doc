-------------------------------------------------------------------------------
                            Module `uuid`
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

A "UUID" is a `Universally unique identifier`_. If an application requires that
a value be unique only within a single computer or on a single database, then a
simple counter is better than a UUID, because getting a UUID is time-consuming
(it requires a syscall_). For clusters of computers, or widely distributed
applications, UUIDs are better.

===============================================================================
                                    Index
===============================================================================

Below is list of all ``uuid`` functions and members.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`uuid.nil <uuid-nil>`           | A nil object                    |
    +--------------------------------------+---------------------------------+
    | :ref:`uuid() <uuid-__call>` |br|     |                                 |
    | :ref:`uuid.bin() <uuid-bin>` |br|    | Get a UUID                      |
    | :ref:`uuid.str() <uuid-str>`         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`uuid.fromstr()                 |                                 |
    | <uuid-fromstr>` |br|                 |                                 |
    | :ref:`uuid.frombin()                 |                                 |
    | <uuid-frombin>` |br|                 | Get a converted UUID            |
    | :ref:`uuid_object:bin()              |                                 |
    | <uuid-object_bin>` |br|              |                                 |
    | :ref:`uuid_object:str()              |                                 |
    | <uuid-object_str>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`uuid_object:isnil()            | Check if a UUID is an all-zero  |
    | <uuid-isnil>`                        | value                           |
    +--------------------------------------+---------------------------------+

.. module:: uuid

.. _uuid-nil:

.. data:: nil

    A nil object

.. _uuid-__call:

.. function:: __call()

    :return: a UUID
    :rtype: cdata

.. _uuid-bin:

.. function:: bin()

    :return: a UUID
    :rtype: 16-byte string

.. _uuid-str:

.. function:: str()

    :return: a UUID
    :rtype: 36-byte binary string

.. _uuid-fromstr:

.. function:: fromstr(uuid_str)

    :param uuid_str: UUID in 36-byte hexadecimal string
    :return: converted UUID
    :rtype: cdata

.. _uuid-frombin:

.. function:: frombin(uuid_bin)

    :param uuid_str: UUID in 16-byte binary string
    :return: converted UUID
    :rtype: cdata

.. class:: uuid_object

    .. _uuid-object_bin:

    .. method:: bin([byte-order])

        ``byte-order`` can be one of next flags:

        * 'l' - little-endian,
        * 'b' - big-endian,
        * 'h' - endianness depends on host (default),
        * 'n' - endianness depends on network

        :param string byte-order: one of ``'l'``, ``'b'``, ``'h'`` or ``'n'``.

        :return: UUID converted from cdata input value.
        :rtype: 16-byte binary string

    .. _uuid-object_str:

    .. method:: str()

        :return: UUID converted from cdata input value.
        :rtype: 36-byte hexadecimal string

    .. _uuid-isnil:

    .. method:: isnil()

        The all-zero UUID value can be expressed as uuid.NULL, or as
        ``uuid.fromstr('00000000-0000-0000-0000-000000000000')``.
        The comparison with an all-zero value can also be expressed as
        ``uuid_with_type_cdata == uuid.NULL``.

        :return: true if the value is all zero, otherwise false.
        :rtype: bool

=================================================
                    Example
=================================================

.. code-block:: tarantoolsession

    tarantool> uuid = require('uuid')
    ---
    ...
    tarantool> uuid(), uuid.bin(), uuid.str()
    ---
    - 16ffedc8-cbae-4f93-a05e-349f3ab70baa
    - !!binary FvG+Vy1MfUC6kIyeM81DYw==
    - 67c999d2-5dce-4e58-be16-ac1bcb93160f
    ...
    tarantool> uu = uuid()
    ---
    ...
    tarantool> #uu:bin(), #uu:str(), type(uu), uu:isnil()
    ---
    - 16
    - 36
    - cdata
    - false
    ...

.. _Universally unique identifier: https://en.wikipedia.org/wiki/Universally_unique_identifier
.. _syscall: https://en.wikipedia.org/wiki/Syscall
