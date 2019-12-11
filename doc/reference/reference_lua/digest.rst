.. _digest:

-------------------------------------------------------------------------------
                            Module `digest`
-------------------------------------------------------------------------------

.. module:: digest

===============================================================================
                                   Overview
===============================================================================

A "digest" is a value which is returned by a function (usually a
`Cryptographic hash function`_), applied against a string. Tarantool's ``digest``
module supports several types of cryptographic hash functions (AES_, MD4_,
MD5_, SHA-1_, SHA-2_, PBKDF2_) as well as a checksum function (CRC32_), two
functions for base64_, and two non-cryptographic hash functions (guava_, murmur_).
Some of the digest functionality is also present in the :ref:`crypto <crypto>`.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``digest`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`digest.aes256cbc.encrypt()     | Encrypt a string using AES      |
    | <digest-aes>`                        |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.aes256cbc.decrypt()     | Decrypt a string using AES      |
    | <digest-aes>`                        |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.md4()                   | Get a digest made with MD4      |
    | <digest-md4>`                        |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.md4_hex()               | Get a hexadecimal digest made   |
    | <digest-md4_hex>`                    | with MD4                        |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.md5()                   | Get a digest made with MD5      |
    | <digest-md5>`                        |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.md5_hex()               | Get a hexadecimal digest made   |
    | <digest-md5_hex>`                    | with MD5                        |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.pbkdf2()                | Get a digest made with PBKDF2   |
    | <digest-pbkdf2>`                     |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.sha1()                  | Get a digest made with SHA-1    |
    | <digest-sha1>`                       |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.sha1_hex()              | Get a hexadecimal digest made   |
    | <digest-sha1_hex>`                   | with SHA-1                      |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.sha224()                | Get a 224-bit digest made with  |
    | <digest-sha224>`                     | SHA-2                           |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.sha224_hex()            | Get a 56-byte hexadecimal       |
    | <digest-sha224_hex>`                 | digest made with SHA-2          |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.sha256()                | Get a 256-bit digest made with  |
    | <digest-sha256>`                     | SHA-2                           |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.sha256_hex()            | Get a 64-byte hexadecimal       |
    | <digest-sha256_hex>`                 | digest made with SHA-2          |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.sha384()                | Get a 384-bit digest made with  |
    | <digest-sha384>`                     | SHA-2                           |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.sha384_hex()            | Get a 96-byte hexadecimal       |
    | <digest-sha384_hex>`                 | digest made with SHA-2          |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.sha512()                | Get a 512-bit digest made with  |
    | <digest-sha512>`                     | SHA-2                           |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.sha512_hex()            | Get a 128-byte hexadecimal      |
    | <digest-sha512_hex>`                 | digest made with SHA-2          |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.base64_encode()         | Encode a string to Base64       |
    | <digest-base64_encode>`              |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.base64_decode()         | Decode a Base64-encoded string  |
    | <digest-base64_decode>`              |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.urandom()               | Get an array of random bytes    |
    | <digest-urandom>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.crc32()                 | Get a 32-bit checksum made with |
    | <digest-crc32>`                      | CRC32                           |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.crc32.new()             | Initiate incremental CRC32      |
    | <digest-crc32_new>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.guava()                 | Get a number made with a        |
    | <digest-guava>`                      | consistent hash                 |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.murmur()                | Get a digest made with          |
    | <digest-murmur>`                     | MurmurHash                      |
    +--------------------------------------+---------------------------------+
    | :ref:`digest.murmur.new()            | Initiate incremental MurmurHash |
    | <digest-murmur_new>`                 |                                 |
    +--------------------------------------+---------------------------------+

.. _digest-aes:

.. function:: digest.aes256cbc.encrypt(string, key, iv)
              digest.aes256cbc.decrypt(string, key, iv)

    Returns 256-bit binary string = digest made with AES.

.. _digest-md4:

.. function:: md4(string)

    Returns 128-bit binary string = digest made with MD4.

.. _digest-md4_hex:

.. function:: md4_hex(string)

    Returns 32-byte string = hexadecimal of a digest calculated with md4.

.. _digest-md5:

.. function:: md5(string)

    Returns 128-bit binary string = digest made with MD5.

.. _digest-md5_hex:

.. function:: md5_hex(string)

    Returns 32-byte string = hexadecimal of a digest calculated with md5.

.. _digest-pbkdf2:

.. function:: pbkdf2(string, salt [,iterations [,digest-length]])

    Returns binary string = digest made with PBKDF2. |br|
    For effective encryption the ``iterations`` value should be
    at least several thousand. The ``digest-length`` value
    determines the length of the resulting binary string.

.. _digest-sha1:

.. function:: sha1(string)

    Returns 160-bit binary string = digest made with SHA-1.

.. _digest-sha1_hex:

.. function:: sha1_hex(string)

    Returns 40-byte string = hexadecimal of a digest calculated with sha1.

.. _digest-sha224:

.. function:: sha224(string)

    Returns 224-bit binary string = digest made with SHA-2.

.. _digest-sha224_hex:

.. function:: sha224_hex(string)

    Returns 56-byte string = hexadecimal of a digest calculated with sha224.

.. _digest-sha256:

.. function:: sha256(string)

    Returns 256-bit binary string =  digest made with SHA-2.

.. _digest-sha256_hex:

.. function:: sha256_hex(string)

    Returns 64-byte string = hexadecimal of a digest calculated with sha256.

.. _digest-sha384:

.. function:: sha384(string)

    Returns 384-bit binary string =  digest made with SHA-2.

.. _digest-sha384_hex:

.. function:: sha384_hex(string)

    Returns 96-byte string = hexadecimal of a digest calculated with sha384.

.. _digest-sha512:

.. function:: sha512(string)

    Returns 512-bit binary tring = digest made with SHA-2.

.. _digest-sha512_hex:

.. function:: sha512_hex(string)

    Returns 128-byte string = hexadecimal of a digest calculated with sha512.

.. _digest-base64_encode:

.. function:: base64_encode(string[, opts])

    Returns base64 encoding from a regular string.

    The possible options are:

    * ``nopad`` -- result must not include '=' for padding at the end,
    * ``nowrap`` -- result must not include line feed for splitting lines
      after 72 characters,
    * ``urlsafe`` -- result must not include '=' or line feed, and may contain
      '-' or '_' instead of '+' or '/' for positions 62 and 63 in the index table.


    Options may be ``true`` or ``false``, the default value is ``false``.

    For example:

    .. code-block:: lua

        digest.base64_encode(string_variable,{nopad=true})

.. _digest-base64_decode:

.. function:: base64_decode(string)

    Returns a regular string from a base64 encoding.

.. _digest-urandom:

.. function:: urandom(integer)

    Returns array of random bytes with length = integer.

.. _digest-crc32:

.. function:: crc32(string)

    Returns 32-bit checksum made with CRC32.

    The ``crc32`` and ``crc32_update`` functions use the `Cyclic Redundancy Check`_
    polynomial value: ``0x1EDC6F41`` / ``4812730177``.
    (Other settings are: input = reflected, output = reflected, initial value = 0xFFFFFFFF, final xor value = 0x0.)
    If it is necessary to be
    compatible with other checksum functions in other programming languages,
    ensure that the other functions use the same polynomial value.

    For example, in Python, install the ``crcmod`` package and say:

    .. code-block:: python

        >>> import crcmod
        >>> fun = crcmod.mkCrcFun('4812730177')
        >>> fun('string')
        3304160206L

    In Perl, install the ``Digest::CRC`` module and run the following code:

    .. code-block:: perl

      use Digest::CRC;
      $d = Digest::CRC->new(width => 32, poly => 0x1EDC6F41, init => 0xFFFFFFFF, refin => 1, refout => 1);
      $d->add('string');
      print $d->digest;

    (the expected output is 3304160206).

.. _digest-crc32_new:

.. function:: digest.crc32.new()

    Initiates incremental crc32.
    See :ref:`incremental methods <digest-incremental_digests>` notes.

.. _digest-guava:

.. function:: guava(state, bucket)

    Returns a number made with consistent hash.

    The guava function uses the `Consistent Hashing`_ algorithm of the Google
    guava library. The first parameter should be a hash code; the second
    parameter should be the number of buckets; the returned value will be an
    integer between 0 and the number of buckets. For example,

    .. code-block:: tarantoolsession

        tarantool> digest.guava(10863919174838991, 11)
        ---
        - 8
        ...

.. _digest-murmur:

.. function:: murmur(string)

    Returns 32-bit binary string = digest made with MurmurHash.

.. _digest-murmur_new:

.. function:: digest.murmur.new(opts)

    Initiates incremental MurmurHash.
    See :ref:`incremental methods <digest-incremental_digests>` notes.
    For example:

    .. code-block:: lua

        murmur.new({seed=0})

.. _digest-incremental_digests:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Incremental methods in the ``digest`` module
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Suppose that a digest is done for a string 'A', then a new part 'B' is appended
to the string, then a new digest is required. The new digest could be recomputed
for the whole string 'AB', but it is faster to take what was computed before for
'A' and apply changes based on the new part 'B'. This is called multi-step or
"incremental" digesting, which Tarantool supports with crc32 and with murmur...

.. code-block:: lua

      digest = require('digest')

      -- print crc32 of 'AB', with one step, then incrementally
      print(digest.crc32('AB'))
      c = digest.crc32.new()
      c:update('A')
      c:update('B')
      print(c:result())

      -- print murmur hash of 'AB', with one step, then incrementally
      print(digest.murmur('AB'))
      m = digest.murmur.new()
      m:update('A')
      m:update('B')
      print(m:result())

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Example
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In the following example, the user creates two functions, ``password_insert()``
which inserts a SHA-1_ digest of the word "**^S^e^c^ret Wordpass**" into a tuple
set, and ``password_check()`` which requires input of a password.

.. code-block:: tarantoolsession

    tarantool> digest = require('digest')
    ---
    ...
    tarantool> function password_insert()
             >   box.space.tester:insert{1234, digest.sha1('^S^e^c^ret Wordpass')}
             >   return 'OK'
             > end
    ---
    ...
    tarantool> function password_check(password)
             >   local t = box.space.tester:select{12345}
             >   if digest.sha1(password) == t[2] then
             >     return 'Password is valid'
             >   else
             >     return 'Password is not valid'
             >   end
             > end
    ---
    ...
    tarantool> password_insert()
    ---
    - 'OK'
    ...

If a later user calls the ``password_check()`` function and enters the wrong
password, the result is an error.

.. code-block:: tarantoolsession

    tarantool> password_check('Secret Password')
    ---
    - 'Password is not valid'
    ...

.. _AES: https://en.wikipedia.org/wiki/Advanced_Encryption_Standard
.. _SHA-1: https://en.wikipedia.org/wiki/Sha-1
.. _SHA-2: https://en.wikipedia.org/wiki/Sha-2
.. _MD4: https://en.wikipedia.org/wiki/Md4
.. _MD5: https://en.wikipedia.org/wiki/Md5
.. _CRC32: https://en.wikipedia.org/wiki/Cyclic_redundancy_check
.. _base64: https://en.wikipedia.org/wiki/Base64
.. _Cryptographic hash function: https://en.wikipedia.org/wiki/Cryptographic_hash_function
.. _Consistent Hashing: https://en.wikipedia.org/wiki/Consistent_hashing
.. _Cyclic Redundancy Check: https://en.wikipedia.org/wiki/Cyclic_redundancy_check
.. _guava: https://code.google.com/p/guava-libraries/wiki/HashingExplained
.. _Murmur: https://en.wikipedia.org/wiki/MurmurHash
.. _PBKDF2: https://en.wikipedia.org/wiki/PBKDF2
