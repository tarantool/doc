.. _socket-module:

-------------------------------------------------------------------------------
                            Module `socket`
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

The ``socket`` module allows exchanging data via BSD sockets with a local or
remote host in connection-oriented (TCP) or datagram-oriented (UDP) mode.
Semantics of the calls in the ``socket`` API closely follow semantics of the
corresponding POSIX calls.

The functions for setting up and connecting are ``socket``, ``sysconnect``,
``tcp_connect``. The functions for sending data are ``send``, ``sendto``,
``write``, ``syswrite``. The functions for receiving data are ``recv``,
``recvfrom``, ``read``. The functions for waiting before sending/receiving
data are ``wait``, ``readable``, ``writable``. The functions for setting
flags are ``nonblock``, ``setsockopt``. The functions for stopping and
disconnecting are ``shutdown``, ``close``. The functions for error checking
are ``errno``, ``error``.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``socket`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +-------------------------------------------------------+------------------------------+
    | Name                                                  | Use                          |
    +=======================================================+==============================+
    | :ref:`socket() <socket-socket>`                       | Create a socket              |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket.tcp_connect() <socket-tcp_connect>`      | Connect a socket to a remote |
    |                                                       | host                         |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket.getaddrinfo() <socket-getaddrinfo>`      | Get information about        |
    |                                                       | a remote site                |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket.tcp_server() <socket-tcp_server>`        | Make Tarantool act as a TCP  |
    |                                                       | server                       |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:sysconnect() <socket-sysconnect>` | Connect a socket to a remote |
    |                                                       | host                         |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:send() <socket-send>` |br|        | Send data over a connected   |
    | :ref:`socket_object:write() <socket-send>`            | socket                       |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:syswrite() <socket-syswrite>`     | Write data to the socket     |
    |                                                       | buffer if non-blocking       |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:recv() <socket-recv>`             | Read from a connected socket |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:sysread() <socket-sysread>`       | Read data from the socket    |
    |                                                       | buffer if non-blocking       |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:bind() <socket-bind>`             | Bind a socket to the given   |
    |                                                       | host/port                    |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:listen() <socket-listen>`         | Start listening for          |
    |                                                       | incoming connections         |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:accept() <socket-accept>`         | Accept a client connection + |
    |                                                       | create a connected socket    |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:sendto() <socket-sendto>`         | Send a message on a UDP      |
    |                                                       | socket to a specified host   |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:recvfrom() <socket-recvfrom>`     | Receive a message on a UDP   |
    |                                                       | socket                       |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:shutdown() <socket-shutdown>`     | Shut down a reading end, a   |
    |                                                       | writing end, or both         |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:close() <socket-close>`           | Close a socket               |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:error() <socket-error>` |br|      | Get information about the    |
    | :ref:`socket_object:errno() <socket-error>`           | last error on a socket       |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:setsockopt() <socket-setsockopt>` | Set socket flags             |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:getsockopt() <socket-getsockopt>` | Get socket flags             |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:linger() <socket-linger>`         | Set/clear the SO_LINGER flag |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:nonblock() <socket-nonblock>`     | Set/get the flag value       |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:readable() <socket-readable>`     | Wait until something is      |
    |                                                       | readable                     |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:writable() <socket-writable>`     | Wait until something is      |
    |                                                       | writable                     |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:wait() <socket-wait>`             | Wait until something is      |
    |                                                       | either readable or writable  |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:name() <socket-name>`             | Get information about the    |
    |                                                       | connection's near side       |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket_object:peer() <socket-peer>`             | Get information about the    |
    |                                                       | connection's far side        |
    +-------------------------------------------------------+------------------------------+
    | :ref:`socket.iowait() <socket-iowait>`                | Wait for read/write activity |
    +-------------------------------------------------------+------------------------------+
    | :ref:`LuaSocket wrapper functions <socket-luasocket>` | Several methods for          |
    |                                                       | emulating the LuaSocket API  |
    +-------------------------------------------------------+------------------------------+

Typically a socket session will begin with the setup functions, will set one
or more flags, will have a loop with sending and receiving functions, will
end with the teardown functions -- as an example at the end of this section
will show. Throughout, there may be error-checking and waiting functions for
synchronization. To prevent a fiber containing socket functions from "blocking"
other fibers, the :ref:`implicit yield rules <atomic-implicit-yields>`
will cause a yield so that other processes
may take over, as is the norm for :ref:`cooperative multitasking <atomic-cooperative_multitasking>`.

For all examples in this section the socket name will be sock and
the function invocations will look like ``sock:function_name(...)``.

.. module:: socket

.. _socket-socket:

.. function:: __call(domain, type, protocol)

    Create a new TCP or UDP socket. The argument values
    are the same as in the `Linux socket(2) man page <http://man7.org/linux/man-pages/man2/socket.2.html>`_.

    :return: an unconnected socket, or nil.
    :rtype:  userdata

    **Example:**

    .. code-block:: lua

        socket('AF_INET', 'SOCK_STREAM', 'tcp')

.. _socket-tcp_connect:

.. function:: tcp_connect(host[, port[, timeout]])

    Connect a socket to a remote host.

    :param string host: URL or IP address
    :param number port: port number
    :param number timeout: timeout
    :return: a connected socket, if no error.
    :rtype: userdata

    **Example:**

    .. code-block:: lua

        socket.tcp_connect('127.0.0.1', 3301)

.. _socket-getaddrinfo:

.. function:: getaddrinfo(host, port[, timeout[, {option-list}]])
.. function:: getaddrinfo(host, port[, {option-list}])

    The ``socket.getaddrinfo()`` function is useful for finding information
    about a remote site so that the correct arguments for
    ``sock:sysconnect()`` can be passed.
    This function may use the :ref:`worker_pool_threads <cfg_basic-worker_pool_threads>`
    configuration parameter.

    :param string host: URL or IP address
    :param number port: port number or a string pointing to a port
    :param number timeout: maximum number of seconds to wait
    :param table options: * ``type`` -- preferred socket type
                          * ``family`` -- desired address family for the
                            returned addresses
                          * ``protocol``
                          * ``flags`` -- additional options (see details `here <https://man7.org/linux/man-pages/man3/getaddrinfo.3.html>`_)
    :return: A table containing these fields: "host", "family", "type", "protocol", "port".
    :rtype:  table

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> socket.getaddrinfo('tarantool.org', 'http')
        ---
        - - host: 188.93.56.70
            family: AF_INET
            type: SOCK_STREAM
            protocol: tcp
            port: 80
          - host: 188.93.56.70
            family: AF_INET
            type: SOCK_DGRAM
            protocol: udp
            port: 80
        ...
        -- To find the available values for the options use the following:
        tarantool> socket.internal.AI_FLAGS -- or SO_TYPE, or DOMAIN
        ---
        - AI_ALL: 256
          AI_PASSIVE: 1
          AI_NUMERICSERV: 4096
          AI_NUMERICHOST: 4
          AI_V4MAPPED: 2048
          AI_ADDRCONFIG: 1024
          AI_CANONNAME: 2
        ...

.. _socket-tcp_server:

.. function:: tcp_server(host, port, handler-function-or-table [, timeout])

    The ``socket.tcp_server()`` function makes Tarantool act as a server that
    can accept connections. Usually the same objective
    is accomplished with :ref:`box.cfg{listen=...} <cfg_basic-listen>`.

    :param string         host: host name or IP
    :param number         port: host port, may be 0
    :param function/table handler-function-or-table: what to execute when a
                                                     connection occurs
    :param number         timeout: number of seconds to wait before
                                   timing out

    The handler-function-or-table parameter may be simply a function name
    / function declaration:
    :code:`handler_function`. Or it may be a table:
    :code:`{handler =`
    :samp:`{handler_function} [, prepare = {prepare_function}] [, name = {name}]`
    :code:`}`.
    ``handler_function`` is mandatory; it may have a
    parameter = the socket;
    it is executed once after accept() happens (once per connection);
    it is for continuous
    operation after the connection is made.
    ``prepare_function`` is optional;
    it may have parameters = the socket object and a table with client information;
    it should return either a backlog value or nothing;
    it is executed only once before bind() on the listening socket
    (not once per connection).
    Examples:

    .. code-block:: none

        socket.tcp_server('localhost', 3302, function (s) loop_loop() end)
        socket.tcp_server('localhost', 3302, {handler=hfunc, name='name'})
        socket.tcp_server('localhost', 3302, {handler=hfunc, prepare=pfunc})

    For fuller examples see
    :ref:`Use tcp_server to accept file contents sent with socat <socket_socat>`
    and
    :ref:`Use tcp_server with handler and prepare <socket_handler_prepare>`.

.. class:: socket_object

    .. _socket-sysconnect:

    .. method:: sysconnect(host, port)

        Connect an existing socket to a remote host. The argument values are the same as
        in :ref:`tcp_connect() <socket-tcp_connect>`.
        The host must be an IP address.

        Parameters:
          * Either:
             * host - a string representation of an IPv4 address
               or an IPv6 address;
             * port - a number.
          * Or:
             * host - a string containing "unix/";
             * port - a string containing a path to a unix socket.
          * Or:
             * host - a number, 0 (zero), meaning "all local
               interfaces";
             * port - a number. If a port number is 0 (zero),
               the socket will be bound to a random local port.


        :return: the socket object value may change if sysconnect() succeeds.
        :rtype:  boolean

        **Example:**

        .. code-block:: lua

            socket = require('socket')
            sock = socket('AF_INET', 'SOCK_STREAM', 'tcp')
            sock:sysconnect(0, 3301)

    .. _socket-send:

    .. method:: send(data)
                write(data)

        Send data over a connected socket.

        :param string data: what is to be sent
        :return: the number of bytes sent.
        :rtype:  number

        Possible errors: nil on error.

    .. _socket-syswrite:

    .. method:: syswrite(size)

        Write as much data as possible to the socket buffer if non-blocking.
        Rarely used. For details see `this description`_.

    .. _socket-recv:

    .. method:: recv(size)

        Read ``size`` bytes from a connected socket. An internal read-ahead
        buffer is used to reduce the cost of this call.

        :param integer size: maximum number of bytes to receive. See :ref:`Recommended size <socket-recommended>`.
        :return: a string of the requested length on success.
        :rtype:  string

        Possible errors: On error, returns an empty string, followed by status,
        errno, errstr. In case the writing side has closed its
        end, returns the remainder read from the socket (possibly
        an empty string), followed by "eof" status.

    .. _socket-read:

    .. method:: read(limit [, timeout])
                read(delimiter [, timeout])
                read({options} [, timeout])

        Read from a connected socket until some condition is true, and return
        the bytes that were read.
        Reading goes on until ``limit`` bytes have been read, or a delimiter
        has been read, or a timeout has expired.
        Unlike ``socket_object:recv`` (which uses an internal read-ahead buffer),
        ``socket_object:read`` depends on the socket's buffer.

        :param integer    limit: maximum number of bytes to read, for
                                 example 50 means "stop after 50 bytes"
        :param string delimiter: separator for example
                                 '?' means "stop after a question mark"
        :param number   timeout: maximum number of seconds to wait, for
                                 example 50 means "stop after 50 seconds".
        :param table    options: :samp:`chunk={limit}` and/or
                                 :samp:`delimiter={delimiter}`,
                                 for example :code:`{chunk=5,delimiter='x'}`.

        :return: an empty string if there is nothing more to read, or a nil
                 value if error, or a string up to ``limit`` bytes long,
                 which may include the bytes that matched the ``delimiter``
                 expression.
        :rtype: string

    .. _socket-sysread:

    .. method:: sysread(size)

        Return data from the socket buffer if non-blocking.
        In case the socket is blocking, ``sysread()`` can block the calling process.
        Rarely used. For details, see also
        `this description <https://github.com/tarantool/tarantool/wiki/sockets%201.6>`_.

        :param integer size: maximum number of bytes to read, for
                             example 50 means "stop after 50 bytes"

        :return: an empty string if there is nothing more to read, or a nil
                 value if error, or a string up to ``size`` bytes long.
        :rtype:  string

    .. _socket-bind:

    .. method:: bind(host [, port])

        Bind a socket to the given host/port. A UDP socket after binding
        can be used to receive data (see :ref:`socket_object.recvfrom <socket-recvfrom>`).
        A TCP socket can be used to accept new connections, after it has
        been put in listen mode.

        :param string host: URL or IP address
        :param number port: port number

        :return: true for success, false for error.
                 If return is false, use :ref:`socket_object:errno() <socket-error>`
                 or :ref:`socket_object:error() <socket-error>` to see details.
        :rtype:  boolean

    .. _socket-listen:

    .. method:: listen(backlog)

        Start listening for incoming connections.

        :param backlog: on Linux the listen ``backlog`` backlog may be from
                        ``/proc/sys/net/core/somaxconn``, on BSD the backlog
                        may be ``SOMAXCONN``.

        :return: true for success, false for error.
        :rtype: boolean.

    .. _socket-accept:

    .. method:: accept()

        Accept a new client connection and create a new connected socket.
        It is good practice to set the socket's blocking mode explicitly
        after accepting.

        :return: new socket if success.
        :rtype: userdata

        Possible errors: nil.

    .. _socket-sendto:

    .. method:: sendto(host, port, data)

        Send a message on a UDP socket to a specified host.

        :param string host: URL or IP address
        :param number port: port number
        :param string data: what is to be sent

        :return: the number of bytes sent.
        :rtype:  number

        Possible errors: on error, returns nil and may return status, errno, errstr.

    .. _socket-recvfrom:

    .. method:: recvfrom(size)

        Receive a message on a UDP socket.

        :param integer size: maximum number of bytes to receive. See :ref:`Recommended size <socket-recommended>`.
        :return: message, a table containing "host", "family" and "port" fields.
        :rtype:  string, table

        Possible errors: on error, returns status, errno, errstr.

        **Example:**

        After ``message_content, message_sender = recvfrom(1)``
        the value of ``message_content`` might be a string containing 'X' and
        the value of ``message_sender`` might be a table containing

        .. code-block:: lua

            message_sender.host = '18.44.0.1'
            message_sender.family = 'AF_INET'
            message_sender.port = 43065

    .. _socket-shutdown:

    .. method:: shutdown(how)

        Shutdown a reading end, a writing end, or both ends of a socket.

        :param how: socket.SHUT_RD, socket.SHUT_WR, or socket.SHUT_RDWR.

        :return: true or false.
        :rtype:  boolean

    .. _socket-close:

    .. method:: close()

        Close (destroy) a socket. A closed socket should not be used any more.
        A socket is closed automatically when the Lua garbage collector removes
        its user data.

        :return: true on success, false on error. For example, if
                 sock is already closed, sock:close() returns false.
        :rtype:  boolean

    .. _socket-error:

    .. method:: error()
                errno()

        Retrieve information about the last error that occurred on a socket, if any.
        Errors do not cause throwing of exceptions so these functions are usually necessary.

        :return: result for ``sock:errno()``, result for ``sock:error()``.
                 If there is no error, then ``sock:errno()`` will return 0 and ``sock:error()``.
        :rtype:  number, string

    .. _socket-setsockopt:

    .. method:: setsockopt(level, name, value)

        Set socket flags. The argument values are the same as in the
        `Linux getsockopt(2) man page <http://man7.org/linux/man-pages/man2/setsockopt.2.html>`_.
        The ones that Tarantool accepts are:

        * SO_ACCEPTCONN
        * SO_BINDTODEVICE
        * SO_BROADCAST
        * SO_DEBUG
        * SO_DOMAIN
        * SO_ERROR
        * SO_DONTROUTE
        * SO_KEEPALIVE
        * SO_MARK
        * SO_OOBINLINE
        * SO_PASSCRED
        * SO_PEERCRED
        * SO_PRIORITY
        * SO_PROTOCOL
        * SO_RCVBUF
        * SO_RCVBUFFORCE
        * SO_RCVLOWAT
        * SO_SNDLOWAT
        * SO_RCVTIMEO
        * SO_SNDTIMEO
        * SO_REUSEADDR
        * SO_SNDBUF
        * SO_SNDBUFFORCE
        * SO_TIMESTAMP
        * SO_TYPE

        Setting SO_LINGER is done with ``sock:linger(active)``.

    .. _socket-getsockopt:

    .. method:: getsockopt(level, name)

        Get socket flags. For a list of possible flags see ``sock:setsockopt()``.

    .. _socket-linger:

    .. method:: linger([active])

        Set or clear the SO_LINGER flag. For a description of the flag, see
        the `Linux man page <http://man7.org/linux/man-pages/man1/loginctl.1.html>`_.

        :param boolean active:

        :return: new active and timeout values.

    .. _socket-nonblock:

    .. method:: nonblock([flag])

        * ``sock:nonblock()`` returns the current flag value.
        * ``sock:nonblock(false)`` sets the flag to false and returns false.
        * ``sock:nonblock(true)`` sets the flag to true and returns true.

        This function may be useful before invoking a function which might
        otherwise block indefinitely.

    .. _socket-readable:

    .. method:: readable([timeout])

        Wait until something is readable, or until a timeout value expires.

        :return: true if the socket is now readable, false if timeout expired;

    .. _socket-writable:

    .. method:: writable([timeout])

        Wait until something is writable, or until a timeout value expires.

        :return: true if the socket is now writable, false if timeout expired;

    .. _socket-wait:

    .. method:: wait([timeout])

        Wait until something is either readable or writable, or until a timeout value expires.

        :return: 'R' if the socket is now readable, 'W' if the socket is now writable, 'RW' if the socket is now both readable and writable, '' (empty string) if timeout expired;

    .. _socket-name:

    .. method:: name()

        The ``sock:name()`` function is used to get information about the
        near side of the connection. If a socket was bound to ``xyz.com:45``,
        then ``sock:name`` will return information about ``[host:xyz.com, port:45]``.
        The equivalent POSIX function is ``getsockname()``.

        :return: A table containing these fields: "host", "family", "type", "protocol", "port".
        :rtype:  table

    .. _socket-peer:

    .. method:: peer()

        The ``sock:peer()`` function is used to get information about the far side of a connection.
        If a TCP connection has been made to a distant host ``tarantool.org:80``, ``sock:peer()``
        will return information about ``[host:tarantool.org, port:80]``.
        The equivalent POSIX function is ``getpeername()``.

        :return: A table containing these fields: "host", "family", "type", "protocol", "port".
        :rtype:  table

.. _socket-iowait:

.. function:: iowait(fd, read-or-write-flags, [timeout])

    The ``socket.iowait()`` function is used to wait until read-or-write activity
    occurs for a file descriptor.

    :param fd: file descriptor
    :param read-or-write-flags: 'R' or 1 = read, 'W' or 2 = write, 'RW' or 3 = read|write.
    :param timeout: number of seconds to wait

    If the fd parameter is nil, then there will be a sleep until the timeout.
    If the timeout parameter is nil or unspecified, then timeout is infinite.

    Ordinarily the return value is the activity that occurred ('R' or 'W' or 'RW' or 1 or 2 or 3).
    If the timeout period goes by without any reading or writing, the
    return is an error = ETIMEDOUT.

    Example: ``socket.iowait(sock:fd(), 'r', 1.11)``

.. _socket-luasocket:

=================================================
             LuaSocket wrapper functions
=================================================

The LuaSocket API has functions that are equivalent to the ones described above,
with different names and parameters, for example ``connect()``
rather than ``tcp_connect()``,
as well as ``getpeername``, ``getsockname``, ``setoption``, ``settimeout``.
Tarantool supports these functions so that
third-party packages which depend on them will work.

The LuaSocket project is on
`github <https://github.com/diegonehab/luasocket>`_.
The API description is in the
`LuaSocket manual <http://w3.impa.br/~diego/software/luasocket/>`_
(click the "introduction" and "reference" links at the
bottom of the manual's main page).

A Tarantool example is
:ref:`Use of a socket with LuaSocket wrapper functions <socket-wrapper>`.

.. _socket-recommended:

=================================================
             Recommended size
=================================================

For ``recv`` and ``recvfrom``: use the
optional ``size`` parameter to limit the number of bytes to
receive. A fixed size such as 512 is often reasonable;
a pre-calculated size that depends on context -- such as the
message format or the state of the network -- is often better.
For ``recvfrom``, be aware that a size greater than the
`Maximum Transmission Unit <https://en.wikipedia.org/wiki/Maximum_transmission_unit>`_
can cause inefficient transport.
For Mac OS X, be aware that the size can be tuned by
changing ``sysctl net.inet.udp.maxdgram``.

If ``size`` is not stated: Tarantool will make an extra
call to calculate how many bytes are necessary. This extra call
takes time, therefore not stating ``size`` may be inefficient.

If ``size`` is stated: on a UDP socket, excess bytes are discarded.
On a TCP socket, excess bytes are not discarded and can be
received by the next call.

=================================================
                    Examples
=================================================

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 Use of a TCP socket over the Internet
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In this example a connection is made over the internet between a Tarantool
instance and tarantool.org, then an HTTP "head" message is sent, and a response
is received: "``HTTP/1.1 200 OK``" or something else if the site has moved.
This is not a useful way to communicate
with this particular site, but shows that the system works.

.. code-block:: tarantoolsession

    tarantool> socket = require('socket')
    ---
    ...
    tarantool> sock = socket.tcp_connect('tarantool.org', 80)
    ---
    ...
    tarantool> type(sock)
    ---
    - table
    ...
    tarantool> sock:error()
    ---
    - null
    ...
    tarantool> sock:send("HEAD / HTTP/1.0\r\nHost: tarantool.org\r\n\r\n")
    ---
    - 40
    ...
    tarantool> sock:read(17)
    ---
    - HTTP/1.1 302 Move
    ...
    tarantool> sock:close()
    ---
    - true
    ...

.. _socket-wrapper:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 Use of a socket with LuaSocket wrapper functions 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This is a variation of the earlier example
"Use of a TCP socket over the Internet".
It uses :ref:`LuaSocket wrapper functions <socket-luasocket>`,
with a too-short timeout so that a "Connection timed out" error is likely.
The more common way to specify timeout is with an option of
:ref:`tcp_connect() <socket-tcp_connect>`.

.. code-block:: tarantoolsession

    tarantool> socket = require('socket')
    ---
    ...
    tarantool> sock = socket.connect('tarantool.org', 80)
    ---
    ...
    tarantool> sock:settimeout(0.001)
    ---
    - 1
    ...
    tarantool> sock:send("HEAD / HTTP/1.0\r\nHost: tarantool.org\r\n\r\n")
    ---
    - 40
    ...
    tarantool> sock:receive(17)
    ---
    - null
    - Connection timed out
    ...
    tarantool> sock:close()
    ---
    - 1
    ...

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Use of a UDP socket on localhost
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is an example with datagrams. Set up two connections on 127.0.0.1
(localhost): ``sock_1`` and ``sock_2``. Using ``sock_2``, send a message
to ``sock_1``. Using ``sock_1``, receive a message. Display the received
message. Close both connections. |br| This is not a useful way for a
computer to communicate with itself, but shows that the system works.

.. code-block:: tarantoolsession

    tarantool> socket = require('socket')
    ---
    ...
    tarantool> sock_1 = socket('AF_INET', 'SOCK_DGRAM', 'udp')
    ---
    ...
    tarantool> sock_1:bind('127.0.0.1')
    ---
    - true
    ...
    tarantool> sock_2 = socket('AF_INET', 'SOCK_DGRAM', 'udp')
    ---
    ...
    tarantool> sock_2:sendto('127.0.0.1', sock_1:name().port,'X')
    ---
    - 1
    ...
    tarantool> message = sock_1:recvfrom(512)
    ---
    ...
    tarantool> message
    ---
    - X
    ...
    tarantool> sock_1:close()
    ---
    - true
    ...
    tarantool> sock_2:close()
    ---
    - true
    ...

.. _socket_socat:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Use tcp_server to accept file contents sent with socat
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is an example of the tcp_server function, reading
strings from the client and printing them. On the client
side, the Linux socat utility will be used to ship a
whole file for the tcp_server function to read.

Start two shells. The first shell will be a server instance.
The second shell will be the client.

On the first shell, start Tarantool and say:

.. code-block:: lua

    box.cfg{}
    socket = require('socket')
    socket.tcp_server('0.0.0.0', 3302,
    {
      handler = function(s)
        while true do
          local request
          request = s:read("\n");
          if request == "" or request == nil then
            break
          end
          print(request)
        end
      end,
      prepare = function()
        print('Initialized')
      end
    }
    )

The above code means:

#. Use ``tcp_server()`` to wait for a connection from any host on port 3302.
#. When it happens, enter a loop that reads on the socket and prints what it
   reads. The "delimiter" for the read function is "\\n" so each ``read()``
   will read a string as far as the next line feed, including the line feed.

On the second shell, create a file that contains a few lines. The contents don't
matter. Suppose the first line contains A, the second line contains B, the third
line contains C. Call this file "tmp.txt".

On the second shell, use the socat utility to ship the
tmp.txt file to the server instance's host and port:

.. code-block:: console

    $ socat TCP:localhost:3302 ./tmp.txt

Now watch what happens on the first shell.
The strings "A", "B", "C" are printed.

.. _socket_handler_prepare:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  Use tcp_server with handler and prepare
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Here is an example of the tcp_server function
using ``handler`` and ``prepare``.

Start two shells. The first shell will be a server instance.
The second shell will be the client.

On the first shell, start Tarantool and say:

.. code-block:: lua

    box.cfg{}
    socket = require('socket')
    sock = socket.tcp_server(
      '0.0.0.0',
      3302,
      {prepare =
         function(sock)
           print('listening on socket ' .. sock:fd())
           sock:setsockopt('SOL_SOCKET','SO_REUSEADDR',true)
           return 5
         end,
       handler =
        function(sock, from)
          print('accepted connection from: ')
          print('  host: ' .. from.host)
          print('  family: ' .. from.family)
          print('  port: ' .. from.port)
        end
      }
    )

The above code means:

#. Use ``tcp_server()`` to wait for a connection from any host on port 3302.
#. Specify that there will be an initial call to ``prepare`` which displays
   something about the server, then calls ``setsockopt(...'SO_REUSEADDR'...)``
   (this is the same option that Tarantool would set if there was no ``prepare``),
   and then returns 5 (this is a rather low backlog queue size).
#. Specify that there will be per-connection calls to ``handler`` which display
   something about the client.

Now watch what happens on the first shell. The display will include something
like 'listening on socket 12'.

On the second shell, start Tarantool and say:

.. code-block:: lua

    box.cfg{}
    require('socket').tcp_connect('127.0.0.1', 3302)

Now watch what happens on the first shell.
The display will include something like
'accepted connection from 
host: 127.0.0.1 family: AF_INET port: 37186'.
