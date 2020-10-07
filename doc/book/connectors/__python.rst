=====================================================================
                            Python
=====================================================================

`tarantool-python <http://github.com/tarantool/tarantool-python>`_
is the official Python connector for Tarantool. It is not supplied as part
of the Tarantool repository and must be installed separately (see below for details).

Here is a complete Python program that inserts ``[99999,'Value','Value']`` into
space ``examples`` via the high-level Python API.

.. code-block:: python

    #!/usr/bin/python
    from tarantool import Connection

    c = Connection("127.0.0.1", 3301)
    result = c.insert("examples",(99999,'Value', 'Value'))
    print result

To prepare, paste the code into a file named :file:`example.py` and install
the ``tarantool-python`` connector with either :samp:`pip install tarantool\>0.4`
to install in :file:`/usr` (requires **root** privilege) or
:samp:`pip install tarantool\>0.4 --user` to install in :file:`~` i.e. user's
default directory.

Before trying to run, check that the server instance is :ref:`listening <cfg_basic-listen>` at
``localhost:3301`` and that the space ``examples`` exists, as
:ref:`described earlier <index-connector_setting>`.
To run the program, say :samp:`python example.py`. The program will connect
to the Tarantool server, will send the :ref:`INSERT<box_space-insert>` request, and will not throw any exception if
all went well. If the tuple already exists, the program will throw
``tarantool.error.DatabaseError: (3, "Duplicate key exists in unique index 'primary' in space 'examples'")``.

The example program only shows one request and does not show all that's
necessary for good practice. For that, please see
`tarantool-python <http://github.com/tarantool/tarantool-python>`_ project at GitHub.
For an example of using Python API with
`queue managers for Tarantool <https://github.com/tarantool/queue>`_, see
`queue-python <https://github.com/tarantool/queue-python>`_ project at GitHub.

Also there are several community-driven Python connectors:

* `asynctnt <https://github.com/igorcoding/asynctnt>`_ with asyncio support
* `aiotarantool <https://github.com/shveenkov/aiotarantool>`_ also with asyncio support
* `gtarantool <https://github.com/shveenkov/gtarantool>`_ with gevent support **no active maintenance**
