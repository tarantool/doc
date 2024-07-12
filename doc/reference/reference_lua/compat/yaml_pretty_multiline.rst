.. _compat-option-lyaml:

Lua-YAML prettier multiline output
==================================

Option: ``yaml_pretty_multiline``

The ``lua-yaml`` encoder selects the string style automatically, but in Tarantool context, it can be beneficial to enforce them, for example, for better readability.
The ``yaml_pretty_multiline`` compat option allows to encode multiline strings in a block style.

Old and new behavior
--------------------

The ``compat`` module allows you to chose between the ``lua-yaml`` encodes multiline strings as usual or in the enforced block scalar style:

..  code-block:: lua

    tarantool> compat.yaml_pretty_multiline = 'old'
    ---
    ...

    tarantool> return "Title: xxx\n- Item 1\n- Item 2\n"
    ---
    - 'Title: xxx

      - Item 1

      - Item 2

      '
    ...

    tarantool> compat.yaml_pretty_multiline = 'new'
    ---
    ...

    tarantool> return "Title: xxx\n- Item 1\n- Item 2\n"
    ---
    - |
      Title: xxx
      - Item 1
      - Item 2
    ...

You can select the new/old behavior in ``compat``. It affects the global YAML encoder.

Known compatibility issues
--------------------------

At this point, no incompatible modules are known.

Detecting issues in your codebase
---------------------------------

Both encoding styles are correct from the YAML standard standpoint, but if your module relies on encodings results bytewise, it may break with this change.
Be cautious if you do the following:

*   Compare results of YAML encoding as strings.
*   Hash results of yaml encoding.
