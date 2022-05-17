.. _box_error-new:

===============================================================================
box.error.new()
===============================================================================

.. function:: box.error.new(code, errtext [, errtext ...])

    Create an error object, but not throw it as
    :doc:`/reference/reference_lua/box_error/error`
    does. This is useful when error information should be saved for later retrieval.
    Since version :doc:`2.4.1 </release/2.4.1>`, to set an error as the last explicitly use
    :doc:`/reference/reference_lua/box_error/set`.

    :param number       code: number of a pre-defined error
    :param string errtext(s): part of the message which will accompany the error

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> e=box.error.new{code=5,reason='A',type='B'}
        ---
        ...
        tarantool> e:unpack()
        ---
        - code: 5
          base_type: CustomError
          type: B
          custom_type: B
          message: A
          trace:
          - file: '[string "e=box.error.new{code=5,reason=''A'',type=''B''}"]'
            line: 1
        ...
        tarantool> box.error.last()
        ---
        - null

    Since version :doc:`2.4.1 </release/2.4.1>`, the ``error_marshaling_enabled`` setting
    has been introduced in :ref:`_session_settings <box_space-session_settings>`.
    The new setting affects the structure of error objects. If ``error_marshaling_enabled``
    is set to ``true``, the object will have the MP_EXT type and the
    MP_ERROR subtype.

    Using the :ref:`binary protocol <internals-box_protocol>`,
    the server can send a packet in response to ``box.error.new()``.
    The body of that packet contains the following data:

    - the encoding of MP_EXT according to the
      `MessagePack specification <https://github.com/msgpack/msgpack/blob/master/spec.md>`_
      (usually 0xc7)
    - the encoding of MP_ERROR (0x03)
    - the encoding of MP_ERROR_STACK (0x81)
    - all of the MP_ERROR_STACK components:
      an MP_ARRAY containing an MP_MAP which, in turn, contains
      keys like MP_ERROR_MESSAGE, MP_ERROR_CODE, etc.
      These components are described and illustrated in the section
      :ref:`MessagePack extensions -- The ERROR type <msgpack_ext-error>`.

    The error object map fields correspond to specific keys:

    - "type" corresponds to MP_ERROR_TYPE
    - "code" corresponds to MP_ERROR_ERRCODE
    - "message" corresponds to MP_ERROR_MESSAGE.
