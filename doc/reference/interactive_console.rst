.. _interactive_console:

--------------------------------------------------------------------------------
Interactive console
--------------------------------------------------------------------------------

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

The **input language** can be changed to SQL with ``\set language sql``
or changed to Lua (the default) with ``\set language lua``.

The **delimiter** can be changed to any character with :samp:`\set delimiter <character>`.
The default is nothing, which means input does not need to end with a delimiter.
But a common recommendation is to say ``set delimiter ;`` especially if input is SQL.

The **output format** can be changed to Lua with ``\set output lua``
or changed to YAML (the default) with ``\set output yaml``.

Ordinarily, output from the console has `YAML format <http://yaml.org/spec>`_.
That means that there is a line for document-start ``"---"``,
and each item begins on a separate line starting with ``"- "``,
and each sub-item in a nested structure is indented,
and there is a line for document-end ``"..."``.

Optionally, output from the console can have Lua format.
That means that there are no lines for document-start or document-end,
and items are not on separate lines (they are only separated by commas),
and each sub-item in a nested structure is placed inside "``{}``" braces.
So, when input is a Lua object description, output will equal input.

YAML is good for readability.
Lua is good for re-using results as requests.
The third format, MsgPack, is good for database storage.
Currently the default output format is YAML but it may be Lua in a future version,
and it may be Lua if
the last :ref:`set_default_output <console-set_default_output>`
call was ``console.set_default_output('lua')``.

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

.. _interactive_console-shortcuts:

Keyboard shortcuts
------------------

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