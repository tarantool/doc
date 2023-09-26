.. _tt-export:

Exporting data
==============

..  admonition:: Enterprise Edition
    :class: fact

    This command is supported by the `Enterprise Edition <https://www.tarantool.io/compare/>`_ only.


..  code-block:: console

    $ tt [crud] export URI FILE SPACE [EXPORT_OPTION ...]

``tt [crud] export`` exports a space's data to a file.
The ``crud`` command is optional and can be used to export a cluster's data by using the `CRUD <https://github.com/tarantool/crud>`_ module. Without ``crud``, data is exported using the :ref:`box.space <box_space>` API.

``tt [crud] export`` takes the following arguments:

*   ``URI``: The URI of a router instance if ``crud`` is used. Otherwise, it should specify the URI of a storage.
*   ``FILE``: The name of a file for storing exported data.
*   ``SPACE``: The name of a space from which data is exported.

..  NOTE::

    :ref:`Read access <authentication-owners_privileges>` to the space is required to export its data.

.. _tt-export-limitations:

Limitations
-----------

Exporting isn't supported for the :ref:`interval <index-box_interval>` field type.


.. _tt-export-default:

Exporting with default settings
-------------------------------

The command below exports data of the ``customers`` space to the ``customers.csv`` file:

.. code-block:: console

    $ tt crud export localhost:3301 customers.csv customers

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

To export data with a space's field names in the first row, use the ``--header`` option:

.. code-block:: console

    $ tt crud export localhost:3301 customers.csv customers \
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

By default, ``tt`` exports empty values for fields containing compound data such as arrays or maps.
To export compound values in a specific format, use the ``--compound-value-format`` option.
For example, the command below exports compound values serialized in JSON:

.. code-block:: console

    $ tt crud export localhost:3301 customers.csv customers \
                     --compound-value-format json


.. _tt-export-options:

Options
-------

..  option:: --batch-queue-size INT

    The maximum number of tuple batches in a queue between a fetch and write threads (the default is ``32``).

    ``tt`` exports data using two threads:

    *   A *fetch* thread makes requests and receives data from a Tarantool instance.
    *   A *write* thread encodes received data and writes it to the output.

    The fetch thread uses a queue to pass received tuple batches to the write thread.
    If a queue is full, the fetch thread waits until the write thread takes a batch from the queue.

..  option:: --batch-size INT

    The number of tuples to transfer per request (the default is ``10000``).

..  option:: --compound-value-format STRING

    A format used to export compound values like arrays or maps.
    By default, ``tt`` exports empty values for fields containing such values.

    Supported formats: ``json``.

    See also: :ref:`Exporting compound data <tt-export-compound-data>`.

..  option:: --header

    Add field names in the first row.

    See also: :ref:`Exporting headers <tt-export-header>`.

..  option:: --password STRING

    A password used to connect to the instance.

..  option:: --readview

    Export data using a `read view <https://www.tarantool.io/en/enterprise_doc/read_views/>`_.

..  option:: --username STRING

    A username for connecting to the instance.
