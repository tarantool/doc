
.. _box_session-push:

================================================================================
box.session.push()
================================================================================

.. module:: box.session


.. function:: box.session.push(message [, sync])

    **Deprecated since** :doc:`3.0.0 </release/3.0.0>`.

    Generate an out-of-band message. By "out-of-band" we mean an extra
    message which supplements what is passed in a network via the usual
    channels. Although ``box.session.push()`` can be called at any time, in
    practice it is used with networks that are set up with
    :ref:`module net.box <net_box-module>`, and
    it is invoked by the server (on the "remote database system" to use
    our terminology for net.box), and the client has options for getting
    such messages.

    This function returns an error if the session is disconnected.

    :param any-Lua-type message: what to send
    :param int sync: an optional argument to indicate what the session is,
                     as taken from an earlier call to
                     :doc:`/reference/reference_lua/box_session/sync`.
                     If it is omitted, the default is the current ``box.session.sync()`` value.
                     In Tarantool version :doc:`2.4.2 </release/2.4.2>`, ``sync``
                     is **deprecated** and its use will cause a warning.
                     Since version 2.5.1, its use will cause an error.

    :rtype: {nil, error} or true:

            * If the result is an error, then the first part of the return is
              ``nil`` and the second part is the error object.
            * If the result is not an error, then the return is the boolean value ``true``.
            * When the return is ``true``, the message has gone to the network
              buffer as a :ref:`packet <box_protocol-iproto_protocol>`
              with a different header code
              so the client can distinguish from an ordinary Okay response.

    The server's sole job is to call ``box.session.push()``, there is no
    automatic mechanism for showing that the message was received.

    The client's job is to check for such messages after it sends
    something to the server. The major client methods --
    :ref:`conn:call <net_box-call>`, :ref:`conn:eval <net_box-eval>`,
    :ref:`conn:select <conn-select>`, :ref:`conn:insert <conn-insert>`,
    :ref:`conn:replace <conn-replace>`, :ref:`conn:update <conn-update>`,
    :ref:`conn:upsert <conn-upsert>`, :ref:`delete <conn-delete>` --
    may cause the server to send a message.

    Situation 1: when the client calls synchronously with the default
    ``{async=false}`` option. There are two optional additional options:
    :samp:`on_push={function-name}`, and :samp:`on_push_ctx={function-argument}`.
    When the client receives an out-of-band message for the session,
    it invokes "function-name(function-argument)". For example, with
    options ``{on_push=table.insert, on_push_ctx=messages}``, the client
    will insert whatever it receives into a table named 'messages'.

    Situation 2: when the client calls asynchronously with the non-default
    ``{async=true}`` option. Here ``on_push`` and ``on_push_ctx`` are not allowed, but
    the messages can be seen by calling ``pairs()`` in a loop.

    Situation 2 complication: ``pairs()`` is subject to timeout. So there
    is an optional argument = timeout per iteration. If timeout occurs before
    there is a new message or a final response, there is an error return.
    To check for an error one can use the first loop parameter (if the loop
    starts with "for i, message in future:pairs()" then the first loop parameter
    is i). If it is ``box.NULL`` then the second parameter (in our example, "message")
    is the error object.

    **Example:**

    .. code-block:: lua

        -- Make two shells. On Shell#1 set up a "server", and
        -- in it have a function that includes box.session.push:
        box.cfg{listen=3301}
        box.schema.user.grant('guest','read,write,execute','universe')
        x = 0
        fiber = require('fiber')
        function server_function() x=x+1; fiber.sleep(1); box.session.push(x); end

        -- On Shell#2 connect to this server as a "client" that
        -- can handle Lua (such as another Tarantool server operating
        -- as a client), and initialize a table where we'll get messages:
        net_box = require('net.box')
        conn = net_box.connect(3301)
        messages_from_server = {}

        -- On Shell#2 remotely call the server function and receive
        -- a SYNCHRONOUS out-of-band message:
        conn:call('server_function', {},
                  {is_async = false,
                   on_push = table.insert,
                   on_push_ctx = messages_from_server})
        messages_from_server
        -- After a 1-second pause that is caused by the fiber.sleep()
        -- request inside server_function, the result in the
        --  messages_from_server table will be: 1. Like this:
        -- tarantool> messages_from_server
        -- ---
        -- - - 1
        -- ...
        -- Good. That shows that box.session.push(x) worked,
        -- because we know that x was 1.

        -- On Shell#2 remotely call the same server function and
        -- get an ASYNCHRONOUS out-of-band message. For this we cannot
        -- use on_push and on_push_ctx options, but we can use pairs():
        future = conn:call('server_function', {}, {is_async = true})
        messages = {}
        keys = {}
        for i, message in future:pairs() do
            table.insert(messages, message) table.insert(keys, i) end
        messages
        future:wait_result(1000)
        for i, message in future:pairs() do
            table.insert(messages, message) table.insert(keys, i) end
        messages
        -- There is no pause because conn:call does not wait for
        -- server_function to finish. The first time that we go through
        -- the pairs() loop, we see the messages table is empty. Like this:
        -- tarantool> messages
        -- ---
        -- - - 2
        --   - []
        -- ...
        -- That is okay because the server hasn't yet called
        -- box.session.push(). The second time that we go through
        -- the pairs() loop, we see the value of x at the time of
        -- the second call to box.session.push(). Like this:
        -- tarantool> messages
        -- ---
        -- - - 2
        --   - &0 []
        --   - 2
        --   - *0
        -- ...
        -- Good. That shows that the message was asynchronous, and
        -- that box.session.push() did its job.
