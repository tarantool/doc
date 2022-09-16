Authentication
==============

..  _box_protocol-authentication:

Greeting message
----------------

When a client connects to the server instance, the instance responds with
a 128-byte text greeting message, not in MsgPack format: |br|
64-byte Greeting text line 1 |br|
64-byte Greeting text line 2 |br|
44-byte base64-encoded salt |br|
20-byte NULL

The greeting contains two 64-byte lines of ASCII text.
Each line ends with a newline character (:code:`\n`). The first line contains
the instance version and protocol type. The second line contains up to 44 bytes
of base64-encoded random string, to use in the authentication packet, and ends
with up to 23 spaces.

Part of the greeting is a base64-encoded session salt -
a random string which can be used for authentication. The maximum length of an encoded
salt (44 bytes) is more than the amount necessary to create the authentication
message. An excess is reserved for future authentication
schemas.

Authentication is optional -- if it is skipped, then the session user is ``'guest'``
(the ``'guest'`` user does not need a password).

If authentication is not skipped, then at any time an authentication packet
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
