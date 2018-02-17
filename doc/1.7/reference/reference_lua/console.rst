.. _console-module:

-------------------------------------------------------------------------------
                                   Module `console`
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

The console module allows one Tarantool instance to access another Tarantool
instance, and allows one Tarantool instance to start listening on an
:ref:`admin port <admin-security>`.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``console`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`console.connect()              | Connect to an instance          |
    | <console-connect>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`console.listen()               | Listen for incoming requests    |
    | <console-listen>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`console.start()                | Start the console               |
    | <console-start>`                     |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`console.ac()                   | Set the auto-completion flag    |
    | <console-ac>`                        |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`console.delimiter()            | Set a delimiter                 |
    | <console-delimiter>`                 |                                 |
    +--------------------------------------+---------------------------------+

.. module:: console

.. _console-connect:

.. function:: connect(uri)

    Connect to the instance at :ref:`URI <index-uri>`, change the prompt from
    '``tarantool>``' to ':samp:`{uri}>`', and act henceforth as a client
    until the user ends the session or types ``control-D``.

    The console.connect function allows one Tarantool instance, in interactive
    mode, to access another Tarantool instance. Subsequent requests will appear
    to be handled locally, but in reality the requests are being sent to the
    remote instance and the local instance is acting as a client. Once connection
    is successful, the prompt will change and subsequent requests are sent to,
    and executed on, the remote instance. Results are displayed on the local
    instance. To return to local mode, enter ``control-D``.

    If the Tarantool instance at :samp:`uri` requires authentication, the
    connection might look something like:
    ``console.connect('admin:secretpassword@distanthost.com:3301')``.

    There are no restrictions on the types of requests that can be entered,
    except those which are due to privilege restrictions -- by default the
    login to the remote instance is done with user name = 'guest'. The remote
    instance could allow for this by granting at least one privilege:
    ``box.schema.user.grant('guest','execute','universe')``.

    :param string uri: the URI of the remote instance
    :return: nil

    Possible errors: the connection will fail if the target Tarantool instance
    was not initiated with ``box.cfg{listen=...}``.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> console = require('console')
        ---
        ...
        tarantool> console.connect('198.18.44.44:3301')
        ---
        ...
        198.18.44.44:3301> -- prompt is telling us that instance is remote

.. _console-listen:

.. function:: listen(uri)

    Listen on :ref:`URI <index-uri>`. The primary way of listening for incoming
    requests is via the connection-information string, or URI, specified in
    ``box.cfg{listen=...}``. The alternative way of listening is via the URI
    specified in ``console.listen(...)``. This alternative way is called
    "administrative" or simply :ref:`"admin port" <admin-security>`.
    The listening is usually over a local host with a Unix domain socket.

    :param string uri: the URI of the local instance

    The "admin" address is the URI to listen on. It has no default value, so it
    must be specified if connections will occur via an admin port. The parameter
    is expressed with URI = Universal Resource Identifier format, for example
    "/tmpdir/unix_domain_socket.sock", or a numeric TCP port. Connections are
    often made with telnet. A typical port value is 3313.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> console = require('console')
        ---
        ...
        tarantool> console.listen('unix/:/tmp/X.sock')
        ... main/103/console/unix/:/tmp/X I> started
        ---
        - fd: 6
          name:
            host: unix/
            family: AF_UNIX
            type: SOCK_STREAM
            protocol: 0
            port: /tmp/X.sock
        ...

.. _console-start:

.. function:: start()

    Start the console on the current interactive terminal.

    **Example:**

    A special use of ``console.start()`` is with :ref:`initialization files
    <index-init_label>`. Normally, if one starts the Tarantool instance with
    :samp:`tarantool {initialization file}` there is no console. This can be
    remedied by adding these lines at the end of the initialization file:

    .. code-block:: lua

        local console = require('console')
        console.start()

.. _console-ac:

.. function:: ac([true|false])

   Set the auto-completion flag. If auto-completion is `true`, and the user is
   using Tarantool as a client or the user is using Tarantool via
   ``console.connect()``, then hitting the TAB key may cause tarantool to
   complete a word automatically. The default auto-completion value is `true`.

.. _console-delimiter:

.. function:: delimiter(marker)

   Set a custom end-of-request marker for Tarantool console.

   The default end-of-request marker is a newline (line feed).
   Custom markers are not necessary because Tarantool can tell when a multi-line
   request has not ended (for example, if it sees that a function declaration
   does not have an end keyword). Nonetheless for special needs, or for
   entering multi-line requests in older Tarantool versions, you can change the
   end-of-request marker. As a result, newline alone is not treated as
   end of request.

   To go back to normal mode, say: ``console.delimiter('')<marker>``

   :param string marker: a custom end-of-request marker for Tarantool console

   **Example:**

   .. code-block:: tarantoolsession

       tarantool> console = require('console'); console.delimiter('!')
       ---
       ...
       tarantool> function f ()
                > statement_1 = 'a'
                > statement_2 = 'b'
                > end!
       ---
       ...
       tarantool> console.delimiter('')!
       ---
       ...
