..  _uuid-module:

Module uuid
===========

Overview
--------

A "UUID" is a `Universally unique identifier <https://en.wikipedia.org/wiki/Universally_unique_identifier>`_.
If an application requires that
a value be unique only within a single computer or on a single database, then a
simple counter is better than a UUID, because getting a UUID is time-consuming
(it requires a `syscall <https://en.wikipedia.org/wiki/Syscall>`_). For clusters of computers, or widely distributed
applications, UUIDs are better.
Tarantool generates UUIDs following the rules for RFC 4122
`version 4 variant 1 <https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_(random)>`_.

API Reference
-------------

Below is list of all ``uuid`` functions and members.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 30 70
        :header-rows: 1

        *   - Name
            - Use

        *  - :ref:`uuid.NULL <uuid-null>`
           - A nil UUID object

        *  - :ref:`uuid() <uuid-__call>` |br|
             :ref:`uuid.bin() <uuid-bin>` |br|
             :ref:`uuid.str() <uuid-str>`

           - Get a UUID

        *  - :ref:`uuid.new() <uuid-new>`
           - Create a UUID

        *  - :ref:`uuid.fromstr() <uuid-fromstr>` |br|
             :ref:`uuid.frombin() <uuid-frombin>` |br|
             :ref:`uuid_object:bin() <uuid-object_bin>` |br|
             :ref:`uuid_object:str() <uuid-object_str>`

           - Get a converted UUID

        *  - :ref:`uuid.is_uuid() <uuid-is_uuid>`
           - Check if the specified value has UUID type

        *  - :ref:`uuid_object:isnil() <uuid-isnil>`
           - Check if a UUID is an all-zero value


..  module:: uuid

..  _uuid-null:

..  data:: NULL

    A nil UUID object. Contains the all-zero UUID value -- ``00000000-0000-0000-0000-000000000000``.

..  _uuid-new:

..  function:: new()

    Since version :doc:`2.4.1 </release/2.4.1>`.
    Create a UUID sequence. You can use it in an index over a
    :ref:`UUID field <details_about_index_field_types>`.
    For example, to create such index for a space named ``test``, say:

    ..  code-block:: tarantoolsession

        tarantool> box.space.test:create_index("pk", {parts={{field = 1, type = 'uuid'}}})

    Now you can insert UUIDs into the space:

    ..  code-block:: tarantoolsession

        tarantool> box.space.test:insert{uuid.new()}
        ---
        - [e631fdcc-0e8a-4d2f-83fd-b0ce6762b13f]
        ...

        tarantool> box.space.test:insert{uuid.fromstr('64d22e4d-ac92-4a23-899a-e59f34af5479')}
        ---
        - [64d22e4d-ac92-4a23-899a-e59f34af5479]
        ...

        tarantool> box.space.test:select{}
        ---
        - - [64d22e4d-ac92-4a23-899a-e59f34af5479]
        - [e631fdcc-0e8a-4d2f-83fd-b0ce6762b13f]
        ...

    :return: a UUID
    :rtype: cdata

..  _uuid-__call:

..  function:: __call()

    :return: a UUID
    :rtype: cdata

..  _uuid-bin:

..  function:: bin([byte-order])

    :param string byte-order:  Byte order of the resulting UUID:

      * ``'l'`` -- little-endian
      * ``'b'`` -- big-endian
      * ``'h'``, ``'host'`` -- endianness depends on host (default)
      * ``'n'``, ``'network'`` -- endianness depends on network

    :return: a UUID
    :rtype: 16-byte string

..  _uuid-str:

..  function:: str()

    :return: a UUID
    :rtype: 36-byte binary string

..  _uuid-fromstr:

..  function:: fromstr(uuid-str)

    :param string uuid-str: UUID in 36-byte hexadecimal string
    :return: converted UUID
    :rtype: cdata

..  _uuid-frombin:

..  function:: frombin(uuid-bin [, byte-order])

    :param string uuid-bin: UUID in 16-byte binary string
    :param string byte-order:  Byte order of the given string:

      * ``'l'`` -- little-endian,
      * ``'b'`` -- big-endian,
      * ``'h'``, ``'host'`` -- endianness depends on host (default),
      * ``'n'``, ``'network'`` -- endianness depends on network.

    :return: converted UUID
    :rtype: cdata

..  _uuid-is_uuid:

..  method:: is_uuid(value)

    Since version :doc:`2.6.1 </release/2.6.1>`.

    :param value: a value to check
    :return: ``true`` if the specified value is a UUID, and ``false`` otherwise
    :rtype: bool

..  class:: uuid_object

    ..  _uuid-object_bin:

    ..  method:: bin([byte-order])

        :param string byte-order:  Byte order of the resulting UUID:

          * ``'l'`` -- little-endian,
          * ``'b'`` -- big-endian,
          * ``'h'``, ``'host'`` -- endianness depends on host (default),
          * ``'n'``, ``'network'`` -- endianness depends on network.

        :return: UUID converted from cdata input value.
        :rtype: 16-byte binary string

    ..  _uuid-object_str:

    ..  method:: str()

        :return: UUID converted from cdata input value.
        :rtype: 36-byte hexadecimal string

    ..  _uuid-isnil:

    ..  method:: isnil()

        The all-zero UUID value can be expressed as :ref:`uuid.NULL <uuid-null>`, or as
        ``uuid.fromstr('00000000-0000-0000-0000-000000000000')``.
        The comparison with an all-zero value can also be expressed as
        ``uuid_with_type_cdata == uuid.NULL``.

        :return: true if the value is all zero, otherwise false.
        :rtype: bool


Example
-------

..  code-block:: tarantoolsession

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
