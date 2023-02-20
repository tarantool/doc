.. _compat-option-json-slash:

JSON encode escape forward slash
================================

For some reason, in the upstream ``lua_cjson``, the '/' sign is escaped.
But according to the ``rfc4627`` standard, it is unnecessary and questionably compatible with other implementations.

Old and new behavior
--------------------

By toggling the ``json_escape_forward_slash`` compat option, you can chose either the json encoder escapes the '/' sign or it does not:

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

The option affects both the global serializer instance and serializers created with ``json.new()``.
It also affects the way log messages are encoded when written to the log in the json format (the ``box.cfg.log_format`` option is set to 'json').

Known compatibility issues
--------------------------

At this point, no incompatible modules are known.

Detecting issues in you codebase
--------------------------------

Both encoding styles are correct from the JSON standard standpoint, but if your module relies on encodings results bytewise, it may break with this change.
Be cautious if you do the following:

*   Hash results of ``json.encode()``.
