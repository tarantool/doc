.. _tt-connect:

Connecting to a Tarantool instance
==================================

..  code-block:: bash

    tt connect URI|INSTANCE_NAME [flags]


``tt connect`` connects to a Tarantool instance by its URI or name specified
during its startup (``tt start``).

Flags
-----

..  container:: table

    ..  list-table::
        :widths: 30 70
        :header-rows: 0

        *   -   ``-u``

                ``--username``
            -   Username
        *   -   ``-p``

                ``--password``
            -   Password
        *   -   ``-f``

                ``--file``
            -   Connect and evaluate the script from a file.

                ``-`` – read the script from stdin.

Details
-------

To connect to an instance, ``tt`` typically needs its URI -- the host name or IP address
and the port.

You can also connect to instances in the same ``tt`` environment
(that is, those that use the same :ref:`configuration file <tt-config_file>` and Tarantool installation)
by their instance names.

If authentication is required, specify the username and the password using the ``-u`` (``--username``)
and ``-p`` (``--password``) options.

By default, ``tt connect`` opens an interactive Tarantool console. Alternatively, you
can open a connection to evaluate a Lua script from a file or stdin. To do this,
pass the file path in the ``-f`` (``--file``) option or use ``-f -`` to take the script
from stdin.


Examples
--------

*   Connect to the ``app`` instance in the same environment:

    ..  code-block:: bash

        tt connect app

*   Connect to the ``master`` instance of the ``app`` application in the same environment:

    ..  code-block:: bash

        tt connect app:master

*   Connect to the ``192.168.10.10`` host on port ``3301`` with authentication:

    ..  code-block:: bash

        tt connect 192.168.10.10:3301 -u myuser -p p4$$w0rD

*   Connect to the ``app`` instance and evaluate the code from the ``test.lua`` file:

    ..  code-block:: bash

        tt connect app -f test.lua

*   Connect to the ``app`` instance and evaluate the code from stdin:

    ..  code-block:: bash

        echo "function test() return 1 end" | tt connect app -f - # Create the test() function
        echo "test()" | tt connect app -f -                       # Call this function