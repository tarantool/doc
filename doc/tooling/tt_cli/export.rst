.. _tt-export:

Exporting data
==============

..  admonition:: Enterprise Edition
    :class: fact

    This command is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.


..  code-block:: console

    $ tt [crud|tdg2] export URI SPACE:FILE ... [EXPORT_OPTION ...]

``tt [crud|tdg2] export`` exports a space's data to a file. Three export commands
cover the following cases:

*   ``tt export`` exports data from a replica set using the :ref:`box.space <box_space>` API.
*   ``tt crud export`` exports data from a sharded cluster through a router using the `CRUD <https://github.com/tarantool/crud>`_ module.
*   ``tt tdg2 export`` exports data from a `Tarantool Data Grid 2 <https://www.tarantool.io/ru/tdg/latest/>`_ cluster
    through its `connector <https://www.tarantool.io/ru/tdg/latest/architecture/#connector>`_ using `TDG2 Repository API <https://www.tarantool.io/en/tdg/latest/reference/sandbox/repository-api/#repository-api>`_.

``tt [crud|tdg2] export`` takes the following arguments:

*   ``URI``: The URI of a router instance if ``crud`` is used. Otherwise, it should specify the URI of a storage.
*   ``FILE``: The name of a file for storing exported data.
*   ``SPACE``: The name of a space from which data is exported.

..  NOTE::

    :ref:`Read access <authentication-owners_privileges>` to the space is required to export its data.

.. _tt-export-output-format:

Output format
-------------

``tt export`` exports data in the following formats:

*   ``tt export`` and ``tt crud export``: CSV
*   ``tt tdg2 export``: JSON lines

.. _tt-export-limitations:

Limitations
-----------

Exporting isn't supported for the :ref:`interval <index-box_interval>` field type.


.. _tt-export-default:

Exporting with default settings
-------------------------------

The command below exports data of the ``customers`` space to the ``customers.csv`` file:

.. code-block:: console

    $ tt crud export localhost:3301 customers:customers.csv

If the ``customers`` space has five fields (``id``, ``bucket_id``, ``firstname``, ``lastname``, and ``age``), the file with exported data might look like this:

.. code-block:: text

    1,477,Andrew,Fuller,38
    2,401,Michael,Suyama,46
    3,2804,Robert,King,33
    # ...

If a tuple contains a ``null`` value, for example, ``[1, 477, 'Andrew', null, 38]``, it is exported as an empty value:

.. code-block:: text

    1,477,Andrew,,38


.. _tt-export-header:

Exporting headers
-----------------

To export data with a space's field names in the first row of the CSV file, use the ``--header`` option:

.. code-block:: console

    $ tt crud export localhost:3301 customers:customers.csv  \
                     --header

In this case, field values start from the second row, for example:

.. code-block:: text

    id,bucket_id,firstname,lastname,age
    1,477,Andrew,Fuller,38
    2,401,Michael,Suyama,46
    3,2804,Robert,King,33
    # ...


.. _tt-export-compound-data:

Exporting compound data
-----------------------

In the CSV format, ``tt`` exports empty values by default for fields containing compound data such as arrays or maps.
To export compound values in a specific format, use the ``--compound-value-format`` option.
For example, the command below exports compound values to CSV serialized in JSON:

.. code-block:: console

    $ tt crud export localhost:3301 customers:customers.csv  \
                     --compound-value-format json

.. _tt-export-tdg2:

Exporting from Tarantool Data Grid 2
------------------------------------

.. note::

    In the TDG2 data model, a **type** represents a Tarantool space, and an **object**
    of a type represents a tuple in the type's underlying space.

The command below exports data of the ``customers`` type from a TDG2 cluster to
the ``customers.jsonl`` file:

.. code-block:: console

    $ tt tdg2 export localhost:3301 customers:customers.jsonl

If token authentication is enabled in TDG2, pass the application token in the ``--token`` option:

.. code-block:: console

    $ tt tdg2 export localhost:3301 customers:customers.jsonl \
                     --token=2fc136cf-8cae-4655-a431-7c318967263d

If the ``customers`` type has four fields (``id``, ``firstname``, ``lastname``, and ``age``),
the file with exported data might look like this:

.. code-block:: json

    {"age":30,"first_name":"Samantha","id":1,"second_name":"Carter"}
    {"age":41,"first_name":"Fay","id":2,"second_name":"Rivers"}
    {"age":74,"first_name":"Milo","id":4,"second_name":"Walters"}

``null`` field values are skipped:

.. code-block:: json

    {"age":13,"first_name":"Zachariah","id":3}

Object fields that contain maps with non-string keys are converted to maps with string keys.

TDG2 sets a limit on the number of objects transferred from each storage during a query execution
(the `hard-limits.returned <https://www.tarantool.io/en/tdg/latest/reference/config/config_logic/#hard-limits>`_
TDG2 configuration parameter). If an export batch size (``--batch-size`` parameter)
is greater than this limit, it is possible that more than ``hard-limits.returned`` objects
will be requested from one storage and export will fail.
To make sure that ``hard-limits.returned`` is never exceeded during an export operation,
set the export batch size less or equal to this limit.

For example, if your TDG2 cluster has a 1000 objects ``hard-limits.returned`` limit:

.. code-block:: yaml

    # tdg2 config.yaml
    # ...
    hard-limits.returned: 1000

Set the ``tt tdg2 export`` batch size less or equal to 1000:

.. code-block:: console

    $ tt tdg2 export localhost:3301 customers:customers.jsonl --batch-size=1000

.. _tt-export-auth:

Authentication
--------------

When connecting to the cluster with enabled authentication, specify access credentials
in the ``--username`` and ``--password`` command options:

.. code-block:: console

    $ tt crud export localhost:3301 customers:customers.csv \
                     --username myuser --password p4$$w0rD

.. _tt-export-ssl:

Encrypted connection
--------------------

To connect to instances that use :ref:`SSL encryption <configuration_connections_ssl>`,
provide the SSL certificate and SSL key files in the ``--sslcertfile`` and ``--sslkeyfile`` options.
If necessary, add other SSL parameters in the ``--ssl*`` options.

.. code-block:: console

    $ tt crud export localhost:3301 customers:customers.csv \
                     --username myuser --password p4$$w0rD   \
                     --auth pap-sha256 --sslcertfile certs/server.crt \
                     --sslkeyfile certs/server.key

For connections that use SSL but don't require additional parameters, add the ``--use-ssl``
option:

.. code-block:: console

    $ tt crud export localhost:3301 customers:customers.csv \
                     --username myuser --password p4$$w0rD   \
                     --use-ssl

.. _tt-export-options:

Options
-------

..  option:: --auth STRING

    **Applicable to:** ``tt crud export``, ``tt tdg2 export``

    Authentication type: ``chap-sha1``, ``pap-sha256``, or ``auto``.

..  option:: --batch-queue-size INT

    The maximum number of tuple batches in a queue between a fetch and write threads (the default is ``32``).

    ``tt`` exports data using two threads:

    *   A *fetch* thread makes requests and receives data from a Tarantool instance.
    *   A *write* thread encodes received data and writes it to the output.

    The fetch thread uses a queue to pass received tuple batches to the write thread.
    If a queue is full, the fetch thread waits until the write thread takes a batch from the queue.

..  option:: --batch-size INT

    The number of tuples to transfer per request. The default is:

        *   ``10000`` for ``tt export`` and ``tt crud export``.
        *   ``100`` for ``tt tdg2 export``.

    .. important::

        When using ``tt tdg2 export``, make sure that the batch size does not exceed
        the ``hard-limits.returned`` TDG2 parameter value set on the cluster.

..  option:: --compound-value-format STRING

    **Applicable to:** ``tt export``, ``tt crud export``

    A format used to export compound values like arrays or maps.
    By default, ``tt`` exports empty values for fields containing such values.

    Supported formats: ``json``.

    See also: :ref:`Exporting compound data <tt-export-compound-data>`.

..  option:: --header

    **Applicable to:** ``tt export``, ``tt crud export``

    Add field names in the first row.

    See also: :ref:`Exporting headers <tt-export-header>`.

..  option:: --password STRING

    A password used to connect to the instance.

..  option:: --readview

    **Applicable to:** ``tt export``, ``tt crud export``

    Export data using a :ref:`read view <read_views>`.

..  option:: --sslcafile STRING

    **Applicable to:** ``tt crud export``, ``tt tdg2 export``

    The path to a trusted certificate authorities (CA) file for encrypted connections.

    See also :ref:`tt-export-ssl`.

..  option:: --sslcertfile STRING

    **Applicable to:** ``tt crud export``, ``tt tdg2 export``

    The path to an SSL certificate file for encrypted connections.

    See also :ref:`tt-export-ssl`.

..  option:: --sslciphersfile STRING

    **Applicable to:** ``tt crud export``, ``tt tdg2 export``

    The list of SSL cipher suites used for encrypted connections, separated by colons (``:``).

    See also :ref:`tt-export-ssl`.

..  option:: --sslkeyfile STRING

    **Applicable to:** ``tt crud export``, ``tt tdg2 export``

    The path to a private SSL key file for encrypted connections.

    See also :ref:`tt-export-ssl`.

..  option:: --sslpassword STRING

    **Applicable to:** ``tt crud export``, ``tt tdg2 export``

    The password for the SSL key file for encrypted connections.

    See also :ref:`tt-export-ssl`.

..  option:: --sslpasswordfile STRING

    **Applicable to:** ``tt crud export``, ``tt tdg2 export``

    A file with list of passwords to the SSL key file for encrypted connections.

    See also :ref:`tt-export-auth`.

..  option:: --token STRING

    **Applicable to:** ``tt tdg2 export``

    An application token for connecting to TDG2.

..  option:: --use-ssl STRING

    Use SSL without providing any additional SSL parameters.

    See also :ref:`tt-export-ssl`.

..  option:: --username STRING

    A username for connecting to the instance.
