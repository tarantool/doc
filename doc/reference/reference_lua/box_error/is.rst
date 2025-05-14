.. _box_error-is:

===============================================================================
box.error.is()
===============================================================================

.. function:: box.error.is(object_name)

    **Since:** :doc:`3.2.0 </release/3.2.0>`

    The ``box.error.is`` function allows verify whether the specified argument is an error.

    :param object_name object_name: the subject of the request

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