..  module:: fiber

..  function:: create(function [, function-arguments])

    Create and start a fiber. The fiber is created and begins to run immediately.

    :param function: the function to be associated with the fiber
    :param function-arguments: what will be passed to function.

    :return: created fiber object
    :rtype: userdata

    **Example:**

    ..  code-block:: tarantoolsession

        tarantool> fiber = require('fiber')
        ---
        ...
        tarantool> function function_name()
                 >   print("I'm a fiber")
                 > end
        ---
        ...
        tarantool> fiber_object = fiber.create(function_name); print("Fiber started")
        I'm a fiber
        Fiber started
        ---
        ...
