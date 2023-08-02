.. _interactive_console:

Interactive console
===================

The interactive console is Tarantool's basic command-line interface for entering requests
and seeing results.
It is what users see when they start the server
without an :ref:`instance file <admin-instance_file>`,
or start :ref:`tarantoolctl <tarantoolctl>` with ``enter``.
The interactive console is often called the Lua console to distinguish it from the administrative console,
but in fact it can handle both Lua and SQL input.

The majority of examples in this manual show what users see with the interactive console.
It includes:

*   ``tarantool>`` prompt
*   instruction (a Lua request or an SQL statement)
*   response (a display in either YAML or Lua format)

.. code-block:: none

    -- Interactive console example with Lua input and YAML output
    tarantool> box.info().replication
    ---
    - 1:
        id: 1
        uuid: a5d22f66-2d28-4a35-b78f-5bf73baf6c8a
        lsn: 0
    ...

.. _interactive_console_input_output:

Interactive console input and output
------------------------------------

The **input language** can be either Lua (default) or SQL. To change the input
language, run ``\set language <language>``, for example:

..  code-block:: tarantoolsession

    tarantool> \set language sql

The **delimiter** can be changed to any character with ``\set delimiter <character>``.
By default, the delimiter is empty, which means the input does not need to end
with a delimiter.
For example, a common recommendation for SQL input is to use the semicolon delimiter:

..  code-block:: tarantoolsession

    tarantool> \set delimiter ;

The **output format** can be either `YAML <http://yaml.org/spec>`_ (default) or Lua.
To change the output format, run ``\set output <format>``, for example:

..  code-block:: tarantoolsession

    tarantool> \set output lua

The default YAML output format is the following:

*   The output starts from a document-start line ``"---"``.
*   Each item begins on a separate line starting with ``"- "``.
*   Each sub-item in a nested structure is indented.
*   The output ends with a document-end line ``"..."``.

The alternative Lua format for console output is the following:

*   There are no lines for document-start or document-end.
*   Items are separated by commas.
*   Each sub-item in a nested structure is placed inside "``{}``" braces.

So, when an input is a Lua object description, the output in the Lua format equals it.

For the Lua output format, you can specify an **end of statement** symbol.
It is added to the end of each output statement in the current session and
can be used for parsing the output by scripts. By default, the end of statement
symbol is empty. You can change it to any character or character sequence.
To set an end of statement symbol for the current session, run `\`set output lua,local_eos=<symbol>``,
for example:

..  code-block:: tarantoolsession

    tarantool> set output lua,local_eos=#

To switch back to the empty end of statement symbol:

..  code-block:: tarantoolsession

    tarantool> set output lua,local_eos=``.


The YAML output has better readability.
The Lua output can be reused in requests.
The table below shows output examples in these formats compared with the MsgPack
format, which is good for database storage.

..  container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2
    .. rst-class:: left-align-column-3
    .. rst-class:: left-align-column-4
    .. rst-class:: left-align-column-5

    ..  list-table::
        :widths: 15 15 15 20 35
        :header-rows: 1

        *   -   Type
            -   Lua input
            -   Lua output
            -   YAML output
            -   MsgPack storage

        *   -   scalar
            -   :code:`1`
            -   :code:`1`

            -   | :code:`---`
                | :code:`- 1`
                | :code:`...`

            -   :code:`\x01`

        *   -   scalar sequence
            -   :code:`1, 2, 3`
            -   :code:`1, 2, 3`

            -   | :code:`---`
                | :code:`- 1`
                | :code:`- 2`
                | :code:`- 3`
                | :code:`...`

            -   :code:`\x01 \x02 \x03`

        *   -   2-element table
            -   :code:`{1, 2}`
            -   :code:`{1, 2}`

            -   | :code:`---`
                | :code:`- - 1`
                | :literal:`\   - 2`
                | :code:`...`

            -   :code:`0x92 0x01 0x02`

        *   -   map
            -   :code:`{key = 1}`
            -   :code:`{key = 1}`

            -   | :code:`---`
                | :code:`- key: 1`
                | :code:`...`

            -   :code:`\x81 \xa3 \x6b \x65 \x79 \x01`

The console parameters of a Tarantool instance can also be changed from another
instance using the :ref:`console <console-module>` built-in module functions.

.. _interactive_console-shortcuts:

Keyboard shortcuts
------------------

Since :doc:`2.10.0 </release/2.10.0>`.

..  list-table::
    :widths: 25 75
    :header-rows: 1

    *   - Keyboard shortcut
        - Effect

    *   - ``CTRL+C``
        - Discard current input with the ``SIGINT`` signal in the console mode and
          jump to a new line with a default prompt.

    *   - ``CTRL+D``
        - Quit Tarantool interactive console.

..  important::

    Keep in mind that ``CTRL+C`` shortcut will shut Tarantool down if there is any currently running command
    in the console.
    The :ref:`SIGINT <admin-server_signals>` signal stops the instance running in a daemon mode.