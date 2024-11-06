.. _tt-import:

Importing data
==============

..  admonition:: Enterprise Edition
    :class: fact

    This command is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.


.. code-block:: console

    $ tt [crud|tdg2] import URI FILE:SPACE [IMPORT_OPTION ...]
    # or
    $ tt [crud|tdg2] import URI :SPACE < FILE [IMPORT_OPTION ...]

``tt [crud|tdg] import`` imports data from a file to a space. Three import commands
cover the following cases:

*   ``tt import`` imports data into a replica set through its master instance using the :ref:`box.space <box_space>` API.
*   ``tt crud import`` imports data into a sharded cluster through a router using the `CRUD <https://github.com/tarantool/crud>`_ module.
*   ``tt tdg2 import`` imports data into a `Tarantool Data Grid 2 <https://www.tarantool.io/ru/tdg/latest/>`_ cluster
    through its router using the ``repository.put`` function of the `TDG2 Repository API <https://www.tarantool.io/en/tdg/latest/reference/sandbox/repository-api/#repository-api>`_.

``tt [crud|tdg2] import`` takes the following arguments:

*   ``URI``: The URI of a router instance if ``crud`` is used. Otherwise, it should specify the URI of a storage.
*   ``FILE``: The name of a file containing data to be imported.
*   ``SPACE``: The name of a space to which data is imported.

..  NOTE::

    :ref:`Write access <authentication-owners_privileges>` to the space and `execute` access to `universe` are required to import data.

.. _tt-import-format:

Input file format
-----------------

``tt import`` imports data from the following formats:

*   ``tt import`` and ``tt crud import``: CSV
*   ``tt tdg2 import``: JSON lines

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

.. _tt-import-bucket-id:

Importing bucket_id into sharded clusters
-----------------------------------------

When importing data into a CRUD-enabled sharded cluster, ``tt crud import`` ignores
the ``bucket_id`` field values from the input file. This allows CRUD to automatically
manage data distribution in the cluster by generating new ``bucket_id`` for tuples
during import.

If you need to preserve the original ``bucket_id`` values, use the ``--keep-bucket-id`` option:

.. code-block:: console

    $ tt crud import localhost:3301 customers.csv:customers \
                     --keep-bucket-id \
                     --header \
                     --match=header

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

.. _tt-import-tdg2:

Importing into Tarantool Data Grid 2
------------------------------------

.. note::

    In the TDG2 data model, a **type** represents a Tarantool space, and an **object**
    of a type represents a tuple in the type's underlying space.

The command below imports objects of the ``customers`` type into a TDG2 cluster.
The objects are described in the ``customers.jsonl`` file.

.. code-block:: console

    $ tt tdg2 import localhost:3301 customers.jsonl:customers

If token authentication is enabled in TDG2, pass the application token in the ``--token`` option:

.. code-block:: console

    $ tt tdg2 import localhost:3301 customers.jsonl:customers \
                     --token=2fc136cf-8cae-4655-a431-7c318967263d

The input file can look like this:

.. code-block:: json

    {"age":30,"first_name":"Samantha","id":1,"second_name":"Carter"}
    {"age":41,"first_name":"Fay","id":2,"second_name":"Rivers"}
    {"age":74,"first_name":"Milo","id":4,"second_name":"Walters"}

.. note::

    Since JSON describes objects in maps with string keys, there is no way to
    import a field value that is a map with a non-string key.

In case of an error during TDG2 import, ``tt tdg2 import`` rolls back the changes made
*within the current batch* on the *storage where the error has happened* (per-storage rollback)
and reports an error. On other storages, objects from the same batch can be successfully
imported. So, the rollback process of ``tt tdg2 import``
is the same as the one of ``tt crud import`` with the ``--rollback-on-error`` option.

Since object batches can be imported partially (per-storage rollback), the absence
of error matching complicates the debugging in case of errors. To minimize this
effect, the default batch size (``--batch-size``) for ``tt tdg2 import`` is 1.
This makes the debugging straightforward: you always know which object caused the error.
On the other hand, this decreases the performance in comparison to import in larger batches.

If you increase the batch size, ``tt`` informs you about the possible issues and
asks for an explicit confirmation to proceed.
To automatically confirm a batch import operation, add the ``--force`` option:

.. code-block:: console

    $ tt tdg2 import localhost:3301 customers.jsonl:customers \
                     --batch-size=100 \
                     --force


.. _tt-import-auth:

Authentication
--------------

When connecting to the cluster with enabled authentication, specify access credentials
in the ``--username`` and ``--password`` command options:

.. code-block:: console

    $ tt crud import localhost:3301 customers.csv:customers \
                     --header --match=header \
                     --username myuser --password p4$$w0rD

.. _tt-import-ssl:

Encrypted connection
--------------------

To connect to instances that use :ref:`SSL encryption <configuration_connections_ssl>`,
provide the SSL certificate and SSL key files in the ``--sslcertfile`` and ``--sslkeyfile`` options.
If necessary, add other SSL parameters in the ``--ssl*`` options.

.. code-block:: console

    $ tt crud import localhost:3301 customers.csv:customers \
                     --header --match=header \
                     --username myuser --password p4$$w0rD   \
                     --auth pap-sha256 --sslcertfile certs/server.crt \
                     --sslkeyfile certs/server.key

For connections that use SSL but don't require additional parameters, add the ``--use-ssl``
option:

.. code-block:: console

    $ tt crud import localhost:3301 customers.csv:customers \
                     --header --match=header \
                     --username myuser --password p4$$w0rD   \
                     --use-ssl

.. _tt-import-options:

Options
-------

..  option:: --auth STRING

    **Applicable to:** ``tt crud import``, ``tt tdg2 import``

    Authentication type: ``chap-sha1``, ``pap-sha256``, or ``auto``.

..  option:: --batch-size INT

    **Applicable to:** ``tt crud import``, ``tt tdg2 import``

    The number of tuples to transfer per request. The default is:

        *   ``100`` for ``tt crud import``.
        *   ``1`` for ``tt tdg2 import``. See :ref:`tt-import-tdg2` for details.

..  option:: --dec-sep STRING

    **Applicable to:** ``tt import``, ``tt crud import``

    The string of symbols that defines decimal separators for numeric data (the default is ``.,``).

    .. NOTE::

        Symbols specified in this option cannot intersect with ``--th-sep``.

..  option:: --delimiter STRING

    **Applicable to:** ``tt import``, ``tt crud import``

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

..  option:: --force

    **Applicable to:** ``tt tdg2 import``

    Automatically confirm importing into TDG2 with ``--batch-size`` greater than one.

..  option:: --format STRING

    A format of input data.

    Supported formats: ``csv``.

..  option:: --header

    **Applicable to:** ``tt import``, ``tt crud import``

    Process the first line as a header containing field names.
    In this case, field values start from the second line.

    See also: :ref:`Matching of input and space fields <tt-import-match-fields>`.

..  option:: --keep-bucket-id

    **Applicable to:** ``tt crud import``

    Preserve original values of the ``bucket_id`` field.

    See also: :ref:`tt-import-bucket-id`.

..  option:: --log STRING

    The name of a log file containing information about import errors (the default is ``import``).
    If the log file already exists, new data is written to this file.

..  option:: --match STRING

    **Applicable to:** ``tt import``, ``tt crud import``

    Configure matching between field names in the input file and the target space.

    See also: :ref:`Matching of input and space fields <tt-import-match-fields>`.

..  option:: --null STRING

    **Applicable to:** ``tt import``, ``tt crud import``

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

    **Applicable to:** ``tt import``, ``tt crud import``

    A symbol that defines a quote.
    For CSV, double quotes are used by default (``"``).
    The double symbol of this option acts as the escaping symbol within input data.

..  option:: --rollback-on-error

    **Applicable to:** ``tt crud import``

    Specify whether any operation failed on a storage leads to rolling back batch
    import on this storage.

    .. note::

        ``tt tdg2 import`` always works as if ``--rollback-on-error`` is ``true``.

..  option:: --sslcafile STRING

    **Applicable to:** ``tt crud import``, ``tt tdg2 import``

    The path to a trusted certificate authorities (CA) file for encrypted connections.

    See also :ref:`tt-import-ssl`.

..  option:: --sslcertfile STRING

    **Applicable to:** ``tt crud import``, ``tt tdg2 import``

    The path to an SSL certificate file for encrypted connections.

    See also :ref:`tt-import-ssl`.

..  option:: --sslciphersfile STRING

    **Applicable to:** ``tt crud import``, ``tt tdg2 import``

    The list of SSL cipher suites used for encrypted connections, separated by colons (``:``).

    See also :ref:`tt-import-ssl`.

..  option:: --sslkeyfile STRING

    **Applicable to:** ``tt crud import``, ``tt tdg2 import``

    The path to a private SSL key file for encrypted connections.

    See also :ref:`tt-import-ssl`.

..  option:: --sslpassword STRING

    **Applicable to:** ``tt crud import``, ``tt tdg2 import``

    The password for the SSL key file for encrypted connections.

    See also :ref:`tt-import-ssl`.

..  option:: --sslpasswordfile STRING

    **Applicable to:** ``tt crud import``, ``tt tdg2 import``

    A file with a list of passwords to the SSL key file for encrypted connections.

    See also :ref:`tt-import-auth`.

..  option:: -success STRING

    The name of a file with rows that were imported (the default is ``success``).
    Overwrites the file if it already exists.

..  option:: --th-sep STRING

    **Applicable to:** ``tt import``, ``tt crud import``

    The string of symbols that define thousand separators for numeric data.
    The default value includes a space and a backtick `````.
    This means that ``1 000 000`` and ``1`000`000`` are both imported as ``1000000``.

    .. NOTE::

        Symbols specified in this option cannot intersect with ``--dec-sep``.

..  option:: --token STRING

    **Applicable to:** ``tt tdg2 import``

    An application token for connecting to TDG2.

..  option:: --use-ssl STRING

    Use SSL without providing any additional SSL parameters.

    See also :ref:`tt-import-ssl`.

..  option:: --username STRING

    A username for connecting to the instance.

