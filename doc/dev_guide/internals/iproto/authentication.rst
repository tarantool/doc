..  _box_protocol-authentication:

Session start
=============

Every iproto session begins with a greeting and optional authentication.


Greeting message
----------------

When a client connects to the server instance, the instance responds with
a 128-byte text greeting message, not in MsgPack format:

..  code-block:: none

    Tarantool <version> (<protocol>) <instance-uuid>
    <salt>

For example:

..  code-block:: none

    Tarantool 2.10.0 (Binary) 29b74bed-fdc5-454c-a828-1d4bf42c639a
    QK2HoFZGXTXBq2vFj7soCsHqTo6PGTF575ssUBAJLAI=

The greeting contains two 64-byte lines of ASCII text.
Each line ends with a newline character (:code:`\n`). If the line content is less than 64 bytes long,
the rest of the line is filled up with symbols with an ASCII code of 0 that aren't displayed in the console.

The first line contains
the instance version and protocol type. The second line contains the session salt --
a base64-encoded random string, which is usually 44 bytes long.
The salt is used in the authentication packet -- the :ref:`IPROTO_AUTH message <box_protocol-auth>`.

Authentication
--------------

If authentication is skipped, then the session user is ``'guest'``
(the ``'guest'`` user does not need a password).

If authentication is not skipped, then at any time an :ref:`authentication packet <box_protocol-auth>`
can be prepared using the greeting, the user's name and password,
and `sha-1 <https://en.wikipedia.org/wiki/SHA-1>`_ functions, as follows.

..  code-block:: none

    PREPARE SCRAMBLE:

        size_of_encoded_salt_in_greeting = 44;
        size_of_salt_after_base64_decode = 32;
         /* sha1() will only use the first 20 bytes */
        size_of_any_sha1_digest = 20;
        size_of_scramble = 20;

    prepare 'chap-sha1' scramble:

        salt = base64_decode(encoded_salt);
        step_1 = sha1(password);
        step_2 = sha1(step_1);
        step_3 = sha1(first_20_bytes_of_salt, step_2);
        scramble = xor(step_1, step_3);
        return scramble;
