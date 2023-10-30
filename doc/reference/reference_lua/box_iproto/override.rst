.. _reference_lua-box_iproto_override:

box.iproto.override()
=====================

..  module:: box.iproto

..  function:: override(request_type, handler)

    Since version :doc:`2.11.0 </release/2.11.0>`.
    Set the IPROTO request handler callbacks.

    :param uint32_t     request_type:
    :param iproto_handler_t     handler:

    :return: 0 on success or -1 on error (check box_error_last())
    :rtype: number

    **Example:**

