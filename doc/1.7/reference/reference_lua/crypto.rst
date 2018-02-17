.. _crypto:

-------------------------------------------------------------------------------
                            Module `crypto`
-------------------------------------------------------------------------------

.. module:: crypto.cipher

===============================================================================
                                   Overview
===============================================================================

"Crypto" is short for "Cryptography", which generally refers to the production
of a digest value from a function (usually a `Cryptographic hash function`_),
applied against a string. Tarantool's ``crypto`` module supports ten types of
cryptographic hash functions (AES_, DES_, DSS_, MD4_, MD5_, MDC2_, RIPEMD_,
SHA-0_, SHA-1_, SHA-2_). Some of the crypto functionality is also present in the
:ref:`digest` module.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``crypto`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +----------------------------------------------------------+---------------------------------+
    | Name                                                     | Use                             |
    +==========================================================+=================================+
    | :ref:`crypto.cipher.{algorithm}.{cipher_mode}.encrypt()  | Encrypt a string                |
    | <crypto-cipher>`                                         |                                 |
    +----------------------------------------------------------+---------------------------------+
    | :ref:`crypto.cipher.{algorithm}.{cipher_mode}.decrypt()  | Decrypt a string                |
    | <crypto-cipher>`                                         |                                 |
    +----------------------------------------------------------+---------------------------------+
    | :ref:`crypto.digest.{algorithm}()                        | Get a digest                    |
    | <crypto-digest>`                                         |                                 |
    +----------------------------------------------------------+---------------------------------+

.. _crypto-cipher:

.. varfunc:: {aes128|aes192|aes256|des}.{cbc|cfb|ecb|ofb}.encrypt(string, key, initialization_vector)
             {aes128|aes192|aes256|des}.{cbc|cfb|ecb|ofb}.decrypt(string, key, initialization_vector)
    :needs_modname: True

    Pass or return a cipher derived from the string, key, and (optionally,
    sometimes) initialization vector. The four choices of algorithms:

    * aes128 - aes-128 (with 192-bit binary strings using AES)
    * aes192 - aes-192 (with 192-bit binary strings using AES)
    * aes256 - aes-256 (with 256-bit binary strings using AES)
    * des    - des (with 56-bit binary strings using DES, though DES is not
      recommended)

    Four choices of block cipher modes are also available:

    * cbc - Cipher Block Chaining
    * cfb - Cipher Feedback
    * ecb - Electronic Codebook
    * ofb - Output Feedback

    For more information, read the article about `Encryption Modes`_

    **Example:**

    .. code-block:: lua

        crypto.cipher.aes192.cbc.encrypt('string', 'key', 'initialization')
        crypto.cipher.aes256.ecb.decrypt('string', 'key', 'initialization')

.. module:: crypto.digest

.. _crypto-digest:

.. varfunc:: {dss|dss1|md4|md5|mdc2|ripemd160}(string)
             {sha|sha1|sha224|sha256|sha384|sha512}(string)
    :needs_modname: True

    Pass or return a digest derived from the string. The twelve choices of
    algorithms:

    * dss - dss (using DSS)
    * dss1 - dss (using DSS-1)
    * md4 - md4 (with 128-bit binary strings using MD4)
    * md5 - md5 (with 128-bit binary strings using MD5)
    * mdc2 - mdc2 (using MDC2)
    * ripemd160 - ripemd (with 160-bit binary strings using RIPEMD-160)
    * sha - sha (with 160-bit binary strings using SHA-0)
    * sha1 - sha-1 (with 160-bit binary strings using SHA-1)
    * sha224 - sha-224 (with 224-bit binary strings using SHA-2)
    * sha256 - sha-256 (with 256-bit binary strings using SHA-2)
    * sha384 - sha-384 (with 384-bit binary strings using SHA-2)
    * sha512 - sha-512(with 512-bit binary strings using SHA-2).

    **Example:**

    .. code-block:: lua

        crypto.digest.md4('string')
        crypto.digest.sha512('string')

========================================
Incremental methods in the crypto module
========================================

Suppose that a digest is done for a string 'A', then a new part 'B' is appended
to the string, then a new digest is required. The new digest could be recomputed
for the whole string 'AB', but it is faster to take what was computed before for
'A' and apply changes based on the new part 'B'. This is called multi-step or
"incremental" digesting, which Tarantool supports for all crypto functions..

.. code-block:: lua

      crypto = require('crypto')

      -- print aes-192 digest of 'AB', with one step, then incrementally
      print(crypto.cipher.aes192.cbc.encrypt('AB', 'key'))
      c = crypto.cipher.aes192.cbc.encrypt.new()
      c:init()
      c:update('A', 'key')
      c:update('B', 'key')
      print(c:result())
      c:free()

      -- print sha-256 digest of 'AB', with one step, then incrementally
      print(crypto.digest.sha256('AB'))
      c = crypto.digest.sha256.new()
      c:init()
      c:update('A')
      c:update('B')
      print(c:result())
      c:free()

=======================================================
Getting the same results from digest and crypto modules
=======================================================

The following functions are equivalent. For example, the ``digest`` function and
the ``crypto`` function will both produce the same result.

.. code-block:: lua

    crypto.cipher.aes256.cbc.encrypt('string', 'key') == digest.aes256cbc.encrypt('string', 'key')
    crypto.digest.md4('string') == digest.md4('string')
    crypto.digest.md5('string') == digest.md5('string')
    crypto.digest.sha('string') == digest.sha('string')
    crypto.digest.sha1('string') == digest.sha1('string')
    crypto.digest.sha224('string') == digest.sha224('string')
    crypto.digest.sha256('string') == digest.sha256('string')
    crypto.digest.sha384('string') == digest.sha384('string')
    crypto.digest.sha512('string') == digest.sha512('string')

.. _AES: https://en.wikipedia.org/wiki/Advanced_Encryption_Standard
.. _DES: https://en.wikipedia.org/wiki/Data_Encryption_Standard
.. _DSS: https://en.wikipedia.org/wiki/Payment_Card_Industry_Data_Security_Standard
.. _SHA-0: https://en.wikipedia.org/wiki/Sha-0
.. _SHA-1: https://en.wikipedia.org/wiki/Sha-1
.. _SHA-2: https://en.wikipedia.org/wiki/Sha-2
.. _MD4: https://en.wikipedia.org/wiki/Md4
.. _MD5: https://en.wikipedia.org/wiki/Md5
.. _MDC2: https://en.wikipedia.org/wiki/MDC-2
.. _RIPEMD: http://homes.esat.kuleuven.be/~bosselae/ripemd160.html
.. _Cryptographic hash function: https://en.wikipedia.org/wiki/Cryptographic_hash_function
.. _Consistent Hashing: https://en.wikipedia.org/wiki/Consistent_hashing
.. _Encryption Modes: https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation
