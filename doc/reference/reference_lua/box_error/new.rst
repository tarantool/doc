.. _box_error-new:

===============================================================================
box.error.new()
===============================================================================

.. function:: box.error.new(code, errtext [, errtext ...])

    Create an error object, but not throw it as
    :doc:`/reference/reference_lua/box_error/error`
    does. This is useful when error information should be saved for later retrieval.
    To set an error as the last explicitly use
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

    Since version :doc:`2.4.1 </release/2.4.1>`, there is a :ref:`session_settings <box_space-session_settings>`
    setting which affects the structure of error objects. If ``error_marshaling_enabled``
    is changed to ``true``, then the object will have the MP_EXT type and the
    MP_ERROR subtype. Using the :ref:`binary protocol <internals-box_protocol>`,
    in the body of a packet that the server could send in response to ``box.error.new()``,
    one will see:
    the encoding of MP_EXT according to the
    `MessagePack specification <https://github.com/msgpack/msgpack/blob/master/spec.md>`_
    (usually 0xc7),
    followed by the encoding of MP_ERROR (0x03),
    followed by the encoding of MP_ERROR_STACK (0x81),
    followed by all of the MP_ERROR_STACK components
    (MP_ARRAY which contains MP_MAP which contains keys MP_ERROR_MESSAGE, MP_ERROR_CODE, etc.)
    that are described and illustrated in section
    :ref:`MessagePack extensions -- The ERROR type <msgpack_ext-error>`.
    The map field for error object "type" will have key = MP_ERROR_TYPE,
    the map field for error object "code" will have key = MP_ERROR_CODE,
    the map field for error object "message" will have key = MP_ERROR_MESSAGE.
