.. _box_error-new:

===============================================================================
box.error.new()
===============================================================================

.. function:: box.error.new(code, errtext [, errtext ...])

    Create an error object, but do not throw.
    This is useful when error information should be saved for later retrieval.
    The parameters are the same as for :doc:`/reference/reference_lua/box_error/error`,
    see the description there.

    :param number       code: number of a pre-defined error
    :param string errtext(s): part of the message which will accompany the error

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> e = box.error.new{code = 555, reason = 'Arbitrary message'}
        ---
        ...
        tarantool> e:unpack()
        ---
        - type: ClientError
          code: 555
          message: Arbitrary message
          trace:
          - file: '[string "e = box.error.new{code = 555, reason = ''Arbit..."]'
            line: 1
        ...
