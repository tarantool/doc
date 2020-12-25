.. _box_space-run_triggers:

===============================================================================
space_object:run_triggers()
===============================================================================

.. module:: box.space

.. class:: space_object

    .. method:: run_triggers(true|false)

        At the time that a :ref:`trigger <triggers>` is defined, it is automatically enabled -
        that is, it will be executed. :ref:`Replace <box_space-on_replace>` triggers can be disabled with
        :samp:`box.space.{space-name}:run_triggers(false)` and re-enabled with
        :samp:`box.space.{space-name}:run_triggers(true)`.

        :return: nil

        **Example:**

        The following series of requests will associate an existing function named `F`
        with an existing space named `T`, associate the function a second time with the
        same space (so it will be called twice), disable all triggers of `T`, and delete
        each trigger by replacing with ``nil``.

        .. code-block:: tarantoolsession

            tarantool> box.space.T:on_replace(F)
            tarantool> box.space.T:on_replace(F)
            tarantool> box.space.T:run_triggers(false)
            tarantool> box.space.T:on_replace(nil, F)
            tarantool> box.space.T:on_replace(nil, F)
