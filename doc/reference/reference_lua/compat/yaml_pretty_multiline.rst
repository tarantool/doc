.. _compat-option-lyaml:

Lua-YAML prettier multiline output
==================================

The ``lua-yaml`` encoder selects the string style automatically, but in Tarantool context, it can be beneficial to enforce them, for example, for better readability.
The ``yaml_pretty_multiline`` compat option allows to encode multiline strings in a block style.

Old and new behavior
--------------------

``compat`` lets you chose between ``lua-yaml`` encoding multiline strings as usual or in enforced block scalar style:

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

You can select new/old behavior in compat. It will affect global yaml encoder.

Known compatibility issues
--------------------------

At this point we do not know any incompatible modules.

Detecting issues in you codebase
--------------------------------

Both encoding styles are correct from YAML standard standpoint, but if your module relies on encodings results bytewise, it may break with this change. Be cautious if you do the following:

*   compare results of yaml encoding as strings
*   hash results of yaml encoding.















