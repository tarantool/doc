.. _reference_lua-box_iproto_send:

box.iproto.send()
=================

..  module:: box.iproto

..  function:: send(sid, header[, body])

    Since version :doc:`2.11.0 </release/2.11.0>`.
    Send an :ref:`IPROTO <internals-iproto-format>` packet over the session's socket with the given MsgPack header
    and body.

    :param number sid: IPROTO session identifier (see :ref:`box.session.id() <box_session-id>`)
    :param table|string header: a request header encoded as MsgPack
    :param table|string|nil body: a request body encoded as MsgPack

    :return: 0 on success
    :return: 1 on error
    :rtype: number

    **Possible errors:**

    *   Index is not of type 'TREE'.
    *   :errcode:`ER_TRANSACTION_CONFLICT` if a transaction conflict is detected in the
    :ref:`MVCC transaction mode <txn_mode_transaction-manager>`.

    **Complexity factors:** Index size, Index type.

    **Example:**


