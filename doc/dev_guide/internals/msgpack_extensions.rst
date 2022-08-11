.. _internals-msgpack_ext:

.. _msgpack_ext-decimal:

----------------------------
MessagePack extensions
----------------------------

Tarantool uses predefined MessagePack extension types to represent some
of the special values. Extension types include ``MP_DECIMAL``, ``MP_UUID``,
``MP_ERROR``, ``MP_DATETIME``, and ``MP_INTERVAL``.
These types require special attention from the connector developers,
as they must be treated separately from the default MessagePack types,
and correctly mapped to programming language types.

*******************************
The DECIMAL type
*******************************

The MessagePack EXT type ``MP_EXT`` together with the extension type
``MP_DECIMAL`` is a header for values of the DECIMAL type.

``MP_DECIMAL`` is 1.

`MessagePack spec <https://github.com/msgpack/msgpack/blob/master/spec.md>`_
defines two kinds of types:

* ``fixext 1/2/4/8/16`` types have fixed length so the length is not encoded explicitly;
* ``ext 8/16/32`` types require the data length to be encoded.

``MP_EXP`` + optional ``length`` imply using one of these types.

The decimal MessagePack representation looks like this:

.. code-block:: none

    +--------+-------------------+------------+===============+
    | MP_EXT | length (optional) | MP_DECIMAL | PackedDecimal |
    +--------+-------------------+------------+===============+

Here ``length`` is the length of ``PackedDecimal`` field, and it is of type
``MP_UINT``, when encoded explicitly (i.e. when the type is ``ext 8/16/32``).

``PackedDecimal`` has the following structure:

.. code-block:: none

     <--- length bytes -->
    +-------+=============+
    | scale |     BCD     |
    +-------+=============+

Here ``scale`` is either ``MP_INT`` or ``MP_UINT``. |br|
``scale`` = number of digits after the decimal point

``BCD`` is a sequence of bytes representing decimal digits of the encoded number
(each byte has two decimal digits each encoded using 4-bit ``nibbles``),
so ``byte >> 4`` is the first digit and ``byte & 0x0f`` is the second digit.
The leftmost digit in the array is the most significant.
The rightmost digit in the array is the least significant.

The first byte of the ``BCD`` array contains the first digit of the number,
represented as follows:

.. code-block:: none

    |  4 bits           |  4 bits           |
       = 0x                = the 1st digit

(The first ``nibble`` contains 0 if the decimal number has an even number of digits.)
The last byte of the ``BCD`` array contains the last digit of the number and the
final ``nibble``, represented as follows:

.. code-block:: none

    |  4 bits           |  4 bits           |
       = the last digit    = nibble

The final ``nibble`` represents the number's sign:

* ``0x0a``, ``0x0c``, ``0x0e``, ``0x0f`` stand for plus,
* ``0x0b`` and ``0x0d`` stand for minus.

**Examples**

The decimal ``-12.34`` will be encoded as ``0xd6,0x01,0x02,0x01,0x23,0x4d``:

.. code-block:: none

    |MP_EXT (fixext 4) | MP_DECIMAL | scale |  1   |  2,3 |  4 (minus) |
    |       0xd6       |    0x01    | 0x02  | 0x01 | 0x23 | 0x4d       |

The decimal 0.000000000000000000000000000000000010
will be encoded as ``0xc7,0x03,0x01,0x24,0x01,0x0c``:

.. code-block:: none

    | MP_EXT (ext 8) | length | MP_DECIMAL | scale |  1   | 0 (plus) |
    |      0xc7      |  0x03  |    0x01    | 0x24  | 0x01 | 0x0c     |


.. _msgpack_ext-uuid:

**********************************
The UUID type
**********************************

The MessagePack EXT type ``MP_EXT`` together with the extension type
``MP_UUID`` for values of the UUID type. Since version :doc:`2.4.1 </release/2.4.1>`.

``MP_UUID`` is 2.

The `MessagePack spec <https://github.com/msgpack/msgpack/blob/master/spec.md>`_
defines ``d8`` to mean fixext with size 16, and a uuid's size is always 16.
So the uuid MessagePack representation looks like this:

.. code-block:: none

    +--------+------------+-----------------+
    | MP_EXT | MP_UUID    | UuidValue       |
    | = d8   | = 2        | = 16-byte value |
    +--------+------------+-----------------+


The 16-byte value has 2 digits per byte.
Typically it consists of 11 fields, which are encoded as big endian
unsigned integers in the following order: time_low (4 bytes), time_mid
(2 bytes), time_hi_and_version (2 bytes), clock_seq_hi_and_reserved (1
byte), clock_seq_low (1 byte), node[0], ..., node[5] (1 byte each).

Some of the functions in :ref:`Module uuid <uuid-module>` can produce values
which are compatible with the UUID data type.
For example, after

.. code-block:: none

    uuid = require('uuid')
    box.schema.space.create('t')
    box.space.t:create_index('i', {parts={1,'uuid'}})
    box.space.t:insert{uuid.fromstr('f6423bdf-b49e-4913-b361-0740c9702e4b')}
    box.space.t:select()

a peek at the server response packet will show that it contains

.. code-block:: none

    d8 02 f6 42 3b df b4 9e 49 13 b3 61 07 40 c9 70 2e 4b

.. _msgpack_ext-error:

****************************************************
The ERROR type
****************************************************

Since version :doc:`2.4.1 </release/2.4.1>`, responses for errors have extra information
following what was described in :ref:`Box protocol -- responses for errors
<box_protocol-responses_error>`.
This is a "compatible" enhancement, because clients that expect old-style
server responses should ignore map components that they do not recognize.
Notice, however, that there has been a renaming of a constant:
formerly IPROTO_ERROR in ./box/iproto_constants.h was 0x31,
now IPROTO_ERROR is 0x52 and IPROTO_ERROR_24 is 0x31.

.. code-block:: none

    ++=========================+============================+
    ||                         |                            |
    ||   0x31: IPROTO_ERROR_24 |   0x52: IPROTO_ERROR       |
    || MP_INT: MP_STRING       | MP_MAP: extra information  |
    ||                         |                            |
    ++=========================+============================+
                            MP_MAP

The extra information, most of which is also in :doc:`error object
</reference/reference_lua/box_error/new>` fields, is:

``MP_ERROR_TYPE`` (0x00) (MP_STR) Type that implies source, as in :samp:`{error_object}.base_type`, for example "ClientError".

``MP_ERROR_FILE`` (0x01) (MP_STR)  Source code file where error was caught, as in :samp:`{error_object}.trace`.

``MP_ERROR_LINE`` (0x02) (MP_UINT) Line number in source code file, as in :samp:`{error_object}.trace`.

``MP_ERROR_MESSAGE`` (0x03) (MP_STR) Text of reason, as in :samp:`{error_object}.message`.
The value here will be the same as in the ``IPROTO_ERROR_24`` value.

``MP_ERROR_ERRNO`` (0x04) (MP_UINT) Ordinal number of the error, as in :samp:`{error_object}.errno`.
Not to be confused with ``MP_ERROR_ERRCODE``.

``MP_ERROR_ERRCODE`` (0x05) (MP_UINT) Number of the error as defined in errcode.h, as in :samp:`{error_object}.code`,
which can also be retrieved with the C function :ref:`box_error_code() <capi-box_error_code_code>`.
The value here will be the same as the lower part of the Response-Code-Indicator value.

``MP_ERROR_FIELDS`` (0x06) (MP_MAPs) Additional fields depending on error
type. For example, if ``MP_ERROR_TYPE`` is "AccessDeniedError", then ``MP_ERROR_FIELDS``
will include "object_type", "object_name", "access_type". This field will be
omitted from the response body if there are no additional fields available.

Client and connector programmers should ensure that unknown map keys are ignored,
and should check for addition of new keys in the Tarantool
source code file where error object creation is defined.
In version 2.4.1 the name of this source code file is mp_error.cc.

For example, in version 2.4.1 or later, if we try to create a duplicate space with |br|
``conn:eval([[box.schema.space.create('_space');]])`` |br|
the server response will look like this:

.. code-block:: none

    ce 00 00 00 88                  MP_UINT = HEADER + BODY SIZE
    83                              MP_MAP, size 3 (i.e. 3 items in header)
      00                              Response-Code-Indicator
      ce 00 00 80 0a                  MP_UINT = hexadecimal 800a
      01                              IPROTO_SYNC
      cf 00 00 00 00 00 00 00 05      MP_UINT = sync value
      05                              IPROTO_SCHEMA_VERSION
      ce 00 00 00 4e                  MP_UINT = schema version value
    82                              MP_MAP, size 2
      31                              IPROTO_ERROR_24
      bd 53 70 61 63 etc.             MP_STR = "Space '_space' already exists"
      52                              IPROTO_ERROR
      81                              MP_MAP, size 1
        00                              MP_ERROR_STACK
        91                              MP_ARRAY, size 1
          86                              MP_MAP, size 6
            00                              MP_ERROR_TYPE
            ab 43 6c 69 65 6e 74 etc.       MP_STR = "ClientError"
            02                              MP_ERROR_LINE
            cd                              MP_UINT = line number
            01                              MP_ERROR_FILE
            aa 01 b6 62 75 69 6c etc.       MP_STR "builtin/box/schema.lua"
            03                              MP_ERROR_MESSAGE
            bd 53 70 61 63 65 20 etc.       MP_STR = Space.'_space'.already.exists"
            04                              MP_ERROR_ERRNO
            00                              MP_UINT = error number
            05                              MP_ERROR_ERRCODE
            0a                              MP_UINT = eror code ER_SPACE_EXISTS


.. _msgpack_ext-datetime:

**********************************
The DATETIME type
**********************************

Since version :doc:`2.10.0 </release/2.10.0>`.
``MP_DATETIME`` is 4.

The datetime MessagePack representation looks like this:

.. code-block:: none

    +--------+-------------------+------------+===============+
    | MP_EXT | length (optional) | MP_DECIMAL | PackedDecimal |
    +--------+-------------------+------------+===============+

.. _msgpack_ext-interval:

**********************************
The INTERVAL type
**********************************

The MessagePack EXT type ``MP_EXT`` together with the extension type
``MP_INTERVAL`` is a header for values of the INTERVAL type.
Since version :doc:`2.10.0 </release/2.10.0>`.

``MP_INTERVAL`` is 6.

The interval MessagePack representation looks like this:

.. code-block:: none

    +--------+-------------------+------------+===============+
    | MP_EXT | length (optional) | MP_INTERVAL | PackedDecimal |
    +--------+-------------------+------------+===============+
