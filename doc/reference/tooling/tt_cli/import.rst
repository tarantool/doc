.. _tt-import:

Importing data
==============

..  admonition:: Enterprise Edition
    :class: fact

    This command is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.


.. code-block:: console

    $ tt [crud] import URI FILE:SPACE [IMPORT_OPTION ...]
    # or
    $ tt [crud] import URI :SPACE < FILE [IMPORT_OPTION ...]

``tt [crud] import`` imports data from a file to a space.
The ``crud`` command is optional and can be used to import data to a cluster by using the `CRUD <https://github.com/tarantool/crud>`_ module. Without ``crud``, data is imported using the :ref:`box.space <box_space>` API.

This command takes the following arguments:

*   ``URI``: The URI of a router instance if ``crud`` is used. Otherwise, it should specify the URI of a storage.
*   ``FILE``: The name of a file containing data to be imported.
*   ``SPACE``: The name of a space to which data is imported.

..  NOTE::

    :ref:`Write access <authentication-owners_privileges>` to the space and `execute` access to `universe` are required to import data.


.. _tt-import-limitations:

Limitations
-----------

Importing isn't supported for the :ref:`interval <index-box_interval>` field type.


.. _tt-import-match-fields:

Matching of input and space fields
----------------------------------


.. _tt-import-match-fields-auto:

Automatic matching
~~~~~~~~~~~~~~~~~~

Suppose that you have the ``customers.csv`` file with a header containing field names in the first row:

.. code-block:: text

    id,firstname,lastname,age
    1,Andrew,Fuller,38
    2,Michael,Suyama,46
    3,Robert,King,33
    # ...

If the target ``customers`` space has fields with the same names, you can import data using the ``--header`` and ``--match`` options specified as follows:

.. code-block:: console

    $ tt crud import localhost:3301 customers.csv:customers \
                     --header \
                     --match=header

In this case, fields in the input file and the target space are matched automatically.
You can also match fields :ref:`manually <tt-import-match-fields-manual>` if field names in the input file and the target space differ.
Note that if you're importing data into a cluster, you don't need to specify the ``bucket_id`` field.
The CRUD module generates ``bucket_id`` values automatically.

.. _tt-import-match-fields-manual:

Manual matching
~~~~~~~~~~~~~~~

The ``--match`` option enables importing data by matching field names in the input file and the target space manually.
Suppose that you have the following ``customers.csv`` file with four fields:

.. code-block:: text

    customer_id,name,surname,customer_age
    1,Andrew,Fuller,38
    2,Michael,Suyama,46
    3,Robert,King,33
    # ...

If the target ``customers`` space has the ``id``, ``firstname``, ``lastname``, and ``age`` fields,
you can configure mapping as follows:

.. code-block:: console

    $ tt crud import localhost:3301 customers.csv:customers \
                     --header \
                     --match "id=customer_id;firstname=name;lastname=surname;age=customer_age"

Similarly, you can configure mapping using numeric field positions in the input file:

.. code-block:: console

    $ tt crud import localhost:3301 customers.csv:customers \
                     --header \
                     --match "id=1;firstname=2;lastname=3;age=4"

Below are the rules if some fields are missing in input data or space:

*   If a space has fields that are not specified in input data, ``tt [crud] import`` tries to insert ``null`` values.
*   If input data contains fields missing in a target space, these fields are ignored.

.. _tt-import-duplicate-error:

Handling duplicate primary key errors
-------------------------------------

The ``--on-exist`` option enables you to control data import when a duplicate primary key error occurs.
In the example below, values already existing in the space are replaced with new ones:

.. code-block:: console

    $ tt crud import localhost:3301 customers.csv:customers \
                     --on-exist replace

.. _tt-import-parsing-error:

Handling parsing errors
-----------------------

To skip rows whose data cannot be parsed correctly, use the ``--on-error`` option as follows:

.. code-block:: console

    $ tt crud import localhost:3301 customers.csv:customers \
                     --on-error skip


.. _tt-import-options:

Options
-------

..  option:: --dec-sep STRING

    The string of symbols that defines decimal separators for numeric data (the default is ``.,``).

    .. NOTE::

        Symbols specified in this option cannot intersect with ``--th-sep``.

..  option:: --delimiter STRING

    A symbol that defines a field value delimiter.
    For CSV, the default delimiter is a comma (``,``).
    To use a tab character as a delimiter, set this value as ``tab``:

    .. code-block:: console

        $ tt crud import localhost:3301 customers.csv:customers \
                         --delimiter tab

    .. NOTE::

        A delimiter cannot be ``\r``, ``\n``, or the Unicode replacement character (``U+FFFD``).

..  option:: --error STRING

    The name of a file containing rows that are not imported (the default is ``error``).

    See also: :ref:`Handling parsing errors <tt-import-parsing-error>`.

..  option:: --format STRING

    A format of input data.

    Supported formats: ``csv``.

..  option:: --header

    Process the first line as a header containing field names.
    In this case, field values start from the second line.

    See also: :ref:`Matching of input and space fields <tt-import-match-fields>`.

..  option:: --log STRING

    The name of a log file containing information about import errors (the default is ``import``).
    If the log file already exists, new data is written to this file.

..  option:: --match STRING

    Configure matching between field names in the input file and the target space.

    See also: :ref:`Matching of input and space fields <tt-import-match-fields>`.

..  option:: --null STRING

    A value to be interpreted as ``null`` when importing data.
    By default, an empty value is interpreted as ``null``.
    For example, a tuple imported from the following row ...

    .. code-block:: text

        1,477,Andrew,,38

    ... should look as follows: ``[1, 477, 'Andrew', null, 38]``.

..  option:: --on-error STRING

    An action performed if a row to be imported cannot be parsed correctly.
    Possible values:

    *   ``stop``: stop importing data.
    *   ``skip``: skip rows whose data cannot be parsed correctly.

    Duplicate primary key errors are handled using the ``--on-exist`` option.

    See also: :ref:`Handling parsing errors <tt-import-parsing-error>`.

..  option:: --on-exist STRING

    An action performed if a duplicate primary key error occurs.
    Possible values:

    *   ``stop``: stop importing data.
    *   ``skip``: skip existing values when importing.
    *   ``replace``: replace existing values when importing.

    Other errors are handled using the ``--on-error`` option.

    See also: :ref:`Handling duplicate primary key errors <tt-import-duplicate-error>`.

..  option:: --password STRING

    A password used to connect to the instance.

..  option:: --progress STRING

    The name of a progress file that stores the following information:

    *   The positions of lines that were not imported at the last launch.
    *   The last position that was processed at the last launch.

    If a file with the specified name exists, it is taken into account when importing data.
    ``tt import`` tries to insert lines that were not imported and then continues importing from the last position.

    At each launch, the content of a progress file with the specified name is overwritten.
    If the file with the specified name does not exist, a progress file is created with the results of this run.

    .. NOTE::

        If the option is not set, then this mechanism is not used.

..  option:: --quote STRING

    A symbol that defines a quote.
    For CSV, double quotes are used by default (``"``).
    The double symbol of this option acts as the escaping symbol within input data.

..  option:: -success STRING

    The name of a file with rows that were imported (the default is ``success``).
    Overwrites the file if it already exists.

..  option:: --th-sep STRING

    The string of symbols that define thousand separators for numeric data.
    The default value includes a space and a backtick `````.
    This means that ``1 000 000`` and ``1`000`000`` are both imported as ``1000000``.

    .. NOTE::

        Symbols specified in this option cannot intersect with ``--dec-sep``.

..  option:: --username STRING

    A username for connecting to the instance.

..  option:: --rollback-on-error

    Applicable only when ``crud`` is used.

    Specify whether any operation failed on a router leads to rollback on a storage where the operation is failed.
