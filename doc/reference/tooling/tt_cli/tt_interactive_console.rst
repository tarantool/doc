.. _tt-interactive-console:

tt interactive console
======================

The ``tt`` utility features a command-line console that allows executing requests
and Lua code interactively on the connected Tarantool instances.
It is similar to the :ref:`Tarantool interactive console <interactive_console>` with
one key difference: the ``tt`` console allows connecting to any available instance,
both local and remote. Additionally, it offers more flexible output formatting capabilities.

.. _tt-interactive-console-enter:

Entering the console
--------------------

To connect to a Tarantool instance using the ``tt`` console, run :ref:`tt connect <tt-connect>`.

Specify the instance URI and the user credentials in the corresponding options:

..  code-block:: console

    $ tt connect 192.168.10.10:3301 -u myuser -p p4$$w0rD
       • Connecting to the instance...
       • Connected to 192.168.10.10:3301

    192.168.10.10:3301>

If a user is not specified, the connection is established on behalf of the ``guest`` user.

If the instance runs in the same ``tt`` environment, you can establish a local
connection with it by specifying the ``<application>:<instance>`` string instead of the URI:

..  code-block:: console

   $ tt connect app:storage001
       • Connecting to the instance...
       • Connected to app:storage001

    app:storage001>

Local connections are established on behalf of the ``admin`` user.

To get the list of supported console commands, enter ``\help`` or ``?``.
To quit the console, enter ``\quit`` or ``\q``.

.. _tt-interactive-console-input:

Console input
-------------

Similarly to the :ref:`Tarantool interactive console <interactive_console>`, the
``tt`` console can handle Lua or SQL input. The default is Lua. For Lua input,
the tab-based autocompletion works automatically for loaded modules.

To change the input language to SQL, run ``\set language sql``:

..  code-block:: console

    app:storage001> \set language sql
    app:storage001> select * from bands where id = 1
    ---
    - metadata:
      - name: id
        type: unsigned
      - name: band_name
        type: string
      - name: year
        type: unsigned
      rows:
      - [1, 'Roxette', 1986]
    ...

To change the input language back to Lua, run ``\set language lua``:

..  code-block:: console

    app:storage001> \set language lua
    app:storage001> box.space.bands:select { 1 }
    ---
    - - [1, 'Roxette', 1986]
    ...

.. note::

    You can also specify the input language in the ``tt connect`` call using the
    ``-l``/``--language`` option:

    ..  code-block:: console

        $ tt connect app:storage001 -l sql


.. _tt-interactive-console-output:

Console output
--------------

By default, the ``tt`` console prints the output data in the YAML format, each
tuple on the new line:

..  code-block:: console

    app:storage001> box.space.bands:select { }
    ---
    - - [1, 'Roxette', 1986]
      - [2, 'Scorpions', 1965]
      - [3, 'Ace of Base', 1987]
    ...

You can switch to alternative output formats -- Lua or ASCII (pseudographics) tables --
using the ``\set output`` console command:

..  code-block:: console

    app:storage001> \set output lua
    app:storage001> box.space.bands:select { }
    {{1, "Roxette", 1986}, {2, "Scorpions", 1965}, {3, "Ace of Base", 1987}};
    app:storage001> \set output table
    app:storage001> box.space.bands:select { }
    +------+-------------+------+
    | col1 | col2        | col3 |
    +------+-------------+------+
    | 1    | Roxette     | 1986 |
    +------+-------------+------+
    | 2    | Scorpions   | 1965 |
    +------+-------------+------+
    | 3    | Ace of Base | 1987 |
    +------+-------------+------+

The table output can be printed in the transposed format, where an object's fields
are arranged in columns instead of rows:

..  code-block:: console

    app:storage001> \set output ttable
    app:storage001> box.space.bands:select { }
    +------+---------+-----------+-------------+
    | col1 | 1       | 2         | 3           |
    +------+---------+-----------+-------------+
    | col2 | Roxette | Scorpions | Ace of Base |
    +------+---------+-----------+-------------+
    | col3 | 1986    | 1965      | 1987        |
    +------+---------+-----------+-------------+

.. note::

    You can also specify the output format in the ``tt connect`` call using the
    ``-x``/``--outputformat`` option:

    ..  code-block:: console

        $ tt connect app:storage001 -x table

For ``table`` and ``ttable`` output, more customizations are possible with the
following commands:

*   ``\set table_format`` -- table format: default (pseudographics, or ASCII table), Markdown,
    or Jira-compatible format:

    ..  code-block:: console

        app:storage001> \set table_format jira
        app:storage001> box.space.bands:select {}
        | col1 | 1 | 2 | 3 |
        | col2 | Roxette | Scorpions | Ace of Base |
        | col3 | 1986 | 1965 | 1987 |

*   ``\set grahpics`` -- enable or disable graphics for table cells in the default format:

    ..  code-block:: console

        app:storage001> \set table_format default
        app:storage001> \set graphics false
        app:storage001> box.space.bands:select {}
         col1  1        2          3
         col2  Roxette  Scorpions  Ace of Base
         col3  1986     1965       1987

*   ``\set table_column_width`` -- maximum column width.

    ..  code-block:: console

        app:storage001> \set table_column_width 6
        app:storage001> box.space.bands:select {}
         col1  1       2       3
         col2  Roxett  Scorpi  Ace of
               +e      +ons    + Base
         col3  1986    1965    1987


.. _tt-interactive-console-commands:

Commands
--------

\\help, ?
~~~~~~~~~

Show help on the ``tt`` console.

\\quit, \\q
~~~~~~~~~~~

Quit the ``tt`` console.

\\shortcuts
~~~~~~~~~~~

Show available keyboard shortcuts.

\\set language {lua|sql}
~~~~~~~~~~~~~~~~~~~~~~~~

Set the input language.
Possible values:

*   ``lua`` (default)
*   ``sql``

An analog of the :ref:`tt connect <tt-connect>` option ``-l``/``--language``.

\\set output FORMAT, \\x{l|t|T|y}, \\x
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Set the output format.
Possible ``FORMAT`` values:

*   ``yaml`` (default) -- each output item is a YAML object. Example: ``[1, 'Roxette', 1986]``.
    Shorthand: ``\xy``.
*   ``lua`` -- each output tuple is a separate Lua table. Example: ``{{1, "Roxette", 1986}};``.
    Shorthand: ``\xl``.
*   ``table`` -- the output is a table where tuples are rows.
    Shorthand: ``\xt``.
*   ``ttable`` -- the output is a transposed table where tuples are columns.
    Shorthand: ``\xT``.

.. note::

    The ``\x`` command switches the output format cyclically in the order
    ``yaml`` > ``lua`` > ``table`` > ``ttable``.

The format of ``table`` and ``ttable`` output can be adjusted using the ``\set table_format``,
``\set graphics``, and ``\set table_colum_width`` commands.

An analog of the :ref:`tt connect <tt-connect>` option ``-x``/``--outputformat``.

\\set table_format
~~~~~~~~~~~~~~~~~~

Set the table format if the output format is ``table`` or ``ttable``.
Possible values:

*   ``default`` -- a pseudographics (ASCII) table.
*   ``markdown`` -- a table in the Markdown format.
*   ``jira`` -- a Jira-compatible table.

\\set graphics {true|false}, \\x{g|G}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Whether to print pseudographics for table cells if the output format is ``table`` or ``ttable``.
Possible values: ``true`` (default) and ``false``.

The shorthands are:

*  ``\xG`` for ``true``
*  ``\xg`` for ``false``

\\set table_colum_width WIDTH, \\xw WIDTH
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Set the maximum printed width of a table cell content. If the length exceeds this value,
it continues on the next line starting from the `+` (plus) sign.

Shorthand: ``\xw``
