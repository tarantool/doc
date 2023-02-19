.. _compat-option-json-slash:

JSON encode escape forward slash
================================

For unknown reason in upstream lua_cjson '/' was escaped.
But according to the ``rfc4627`` standard, it is unnecessary and is questionably compatible with other implementations.

Old and new behavior
--------------------

``compat`` allows you to chose between json encoder escaping '/' and not by toggling the ``json_escape_forward_slash`` compat option:

[TBD] formatting of output for '"foo\/bar"'

..  code-block:: lua

    tarantool> require('compat').json_escape_forward_slash = 'old'
    ---
    ...

    tarantool> require('json').encode('foo/bar')
    ---
    - '"foo\/bar"'
    ...

    tarantool> require('compat').json_escape_forward_slash = 'new'
    ---
    ...

    tarantool> require('json').encode('foo/bar')
    ---
    - '"foo/bar"'
    ...

The option affects both the global serializer instance and serializers created with json.new().
It also affects the way log messages are encoded when written to the log in the json format (box.cfg.log_format is set to 'json').

Known compatibility issues
--------------------------

At this point we do not know any incompatible modules.

Detecting issues in you codebase
--------------------------------

Both encoding styles are correct from JSON standart's standpoint, but if your module relies on encodings results bytewise, it may break with this change. Be cautious if you do the following:

*   hash results of json.encode()
