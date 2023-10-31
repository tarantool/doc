..  _reference_lua-box_iproto_send:

box.iproto.send()
=================

..  module:: box.iproto

..  function:: send(sid, header[, body])

    Since version :doc:`2.11.0 </release/2.11.0>`.
    Send an :ref:`IPROTO <internals-iproto-format>` packet over the session's socket with the given MsgPack header
    and body.
    The header and body contain exported IPROTO constants from the :ref:`box.iproto() <box_iproto>` submodule.
    Possible IPROTO constant formats:

    *   a lowercase constant without the ``IPROTO_`` prefix (``schema_version``, ``request_type``)
    *   a constant from the corresponding :ref:`box.iproto <box_iproto>` subnamespace (``box.iproto.SCHEMA_VERSION``, ``box.iproto.REQUEST_TYPE``)

    The function works for binary sessions only. For details, see :ref:`box.session.type() <box_session-type>`.

    :param number sid: IPROTO session identifier (see :ref:`box.session.id() <box_session-id>`)
    :param table|string header: a request header encoded as MsgPack
    :param table|string|nil body: a request body encoded as MsgPack

    :return: 0 on success, otherwise an error is raised
    :rtype: number

    **Possible errors:**

    *   :errcode:`ER_SESSION_CLOSED` -- the session is closed.
    *   :errcode:`ER_NO_SUCH_SESSION` -- the session does not exist.
    *   :errcode:`ER_MEMORY_ISSUE` -- out of memory limit has been reached.
    *   :errcode:`ER_WRONG_SESSION_TYPE` -- the session type is not binary.

    For details, see `src/box/errcode.h <https://github.com/tarantool/tarantool/blob/master/src/box/errcode.h>`__.

    **Examples:**

    Send a packet using Lua tables and string IPROTO constants as keys:

    ..  code-block:: lua

        box.iproto.send(box.session.id(), {request_type = box.iproto.type.OK,
                                           sync = 10,
                                           schema_version = box.info.schema_version}),
                        {data = 1}))

    Send a packet using Lua tables and numeric IPROTO constants:

    ..  code-block:: lua

        box.iproto.send(box.session.id(), {[box.iproto.key.REQUEST_TYPE] = box.iproto.type.OK,
                                           [box.iproto.key.SYNC] = 10,
                                           [box.iproto.key.SCHEMA_VERSION] = box.info.schema_version}),
                        {[box.iproto.key.DATA] = 1}))

    Send a packet that contains only the header:

    ..  code-block:: lua

        box.iproto.send(box.session.id(), {request_type = box.iproto.type.OK,
                                           sync = 10,
                                           schema_version = box.info.schema_version}))

