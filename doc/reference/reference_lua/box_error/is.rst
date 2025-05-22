.. _box_error-is:

===============================================================================
box.error.is()
===============================================================================

.. function:: box.error.is(object)

    **Since:** :doc:`3.2.0 </release/3.2.0>`

    The ``box.error.is`` function allows verify whether the specified argument is an error cdata object.

    :param object object: the object to be verified.

    **Return type:**
    boolean

    **Example**

    ..  code-block:: lua

        tarantool> box.error.is(box.error.new(box.error.UNKNOWN))
        ---
        - true
        ...
        tarantool> box.error.is('foo')
        ---
        - false
        ...