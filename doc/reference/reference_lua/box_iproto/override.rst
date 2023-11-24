..  _reference_lua-box_iproto_override:

box.iproto.override()
=====================

..  module:: box.iproto

..  function:: override(request_type, handler)

    Since version :doc:`2.11.0 </release/2.11.0>`.
    Set a new IPROTO request handler callback for the given request type.

    :param number request_type: a request type code. Possible values:

                                *   a type code from :ref:`box.iproto.type <reference_lua-box_iproto_type>` (except
                                    ``box.iproto.type.UNKNOWN``) -- override the existing request type handler.

                                *   ``box.iproto.type.UNKNOWN`` -- override the handler of unknown request types.

    :param function handler: IPROTO request handler.
                             The signature of a handler function: ``function(sid, header, body)``, where

                             *  ``header`` (userdata): a request header encoded as a :ref:`msgpack_object <msgpack-object-methods>`
                             *  ``body`` (userdata): a request body encoded as a :ref:`msgpack_object <msgpack-object-methods>`

                             Returns ``true`` on success, otherwise ``false``. On ``false``, there is a fallback
                             to the default handler. Also, you can indicate an error by throwing an exception.
                             In this case, the return value is ``false``, but this does not always mean a failure.

                             To reset the request handler, set the ``handler`` parameter to ``nil``.

    :return: none

    **Possible errors:**

    If a Lua handler throws an exception, the behavior is similar to that of a remote procedure call.
    The following errors are returned to the client over IPROTO (see `src/lua/utils.h <https://github.com/tarantool/tarantool/blob/dec0e0221e183fa972efa65bb0fb658112f2196f/src/lua/utils.h#L366-L371>`__):

    *   :errcode:`ER_PROC_LUA` -- an exception is thrown from a Lua handler, diagnostic is not set.
    *   diagnostics from ``src/box/errcode.h`` -- an exception is thrown, diagnostic is set.

    For details, see `src/box/errcode.h <https://github.com/tarantool/tarantool/blob/master/src/box/errcode.h>`__.

    ..  warning::

        When using ``box.iproto.override()``, it is important that you follow the wire protocol.
        That is, the server response should match the return value types of the corresponding request type.
        Otherwise, it could lead to peer breakdown or undefined behavior.

    **Example:**

    Define a handler function for the ``box.iproto.type.SELECT`` request type:

    ..  code-block:: lua

        local function iproto_select_handler_lua(header, body)
            if body.space_id == 512 then
                box.iproto.send(box.session.id(),
                        { request_type = box.iproto.type.OK,
                          sync = header.SYNC,
                          schema_version = box.info.schema_version },
                        { data = { 1, 2, 3 } })
                return true
            end
            return false
        end

    Override ``box.iproto.type.SELECT`` handler:

    ..  code-block:: lua

        box.iproto.override(box.iproto.type.SELECT, iproto_select_handler_lua)

    Reset ``box.iproto.type.SELECT`` handler:

    ..  code-block:: lua

        box.iproto.override(box.iproto.type.SELECT, nil)

    Override a handler function for the unknown request type:

    ..  code-block:: lua

        box.iproto.override(box.iproto.type.UNKNOWN, iproto_unknown_request_handler_lua)
