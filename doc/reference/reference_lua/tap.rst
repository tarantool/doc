-------------------------------------------------------------------------------
                                Module `tap`
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

The ``tap`` module streamlines the testing of other modules. It allows writing
of tests in the `TAP protocol`_. The results from the tests can be parsed by
standard TAP-analyzers so they can be passed to utilities such as `prove`_. Thus
one can run tests and then use the results for statistics, decision-making, and
so on.

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``tap`` functions.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`tap.test()                     | Initialize                      |
    | <tap-test>`                          |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`taptest:test()                 | Create a subtest and print the  |
    | <taptest-test>`                      | results                         |
    +--------------------------------------+---------------------------------+
    | :ref:`taptest:plan()                 | Indicate how many tests to      |
    | <taptest-plan>`                      | perform                         |
    +--------------------------------------+---------------------------------+
    | :ref:`taptest:check()                | Check the number of tests       |
    | <taptest-check>`                     | performed                       |
    +--------------------------------------+---------------------------------+
    | :ref:`taptest:diag()                 | Display a diagnostic message    |
    | <taptest-diag>`                      |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`taptest:ok()                   | Evaluate the condition and      |
    | <taptest-ok>`                        | display the message             |
    +--------------------------------------+---------------------------------+
    | :ref:`taptest:fail()                 | Evaluate the condition and      |
    | <taptest-fail>`                      | display the message             |
    +--------------------------------------+---------------------------------+
    | :ref:`taptest:skip()                 | Evaluate the condition and      |
    | <taptest-skip>`                      | display the message             |
    +--------------------------------------+---------------------------------+
    | :ref:`taptest:is()                   | Check if the two arguments are  |
    | <taptest-is>`                        | equal                           |
    +--------------------------------------+---------------------------------+
    | :ref:`taptest:isnt()                 | Check if the two arguments are  |
    | <taptest-isnt>`                      | different                       |
    +--------------------------------------+---------------------------------+
    | :ref:`taptest:is_deeply()            | Recursively check if the two    |
    | <taptest-is_deeply>`                 | arguments are equal             |
    +--------------------------------------+---------------------------------+
    | :ref:`taptest:like()                 | Check if the argument matches a |
    | <taptest-like>`                      | pattern                         |
    +--------------------------------------+---------------------------------+
    | :ref:`taptest:unlike()               | Check if the argument does not  |
    | <taptest-unlike>`                    | match a pattern                 |
    +--------------------------------------+---------------------------------+
    | :ref:`taptest:isnil()                |                                 |
    | <taptest-istype>` |br|               |                                 |
    | :ref:`taptest:isstring()             |                                 |
    | <taptest-istype>` |br|               |                                 |
    | :ref:`taptest:isnumber()             |                                 |
    | <taptest-istype>` |br|               |                                 |
    | :ref:`taptest:istable()              | Check if a value has a          |
    | <taptest-istype>` |br|               | particular type                 |
    | :ref:`taptest:isboolean()            |                                 |
    | <taptest-istype>` |br|               |                                 |
    | :ref:`taptest:isudata()              |                                 |
    | <taptest-istype>` |br|               |                                 |
    | :ref:`taptest:iscdata()              |                                 |
    | <taptest-istype>`                    |                                 |
    +--------------------------------------+---------------------------------+

.. module:: tap

.. _tap-test:

.. function:: test(test-name)

    Initialize.

    The result of ``tap.test`` is an object, which will be called taptest
    in the rest of this discussion, which is necessary for ``taptest:plan()``
    and all the other methods.

    :param string test-name: an arbitrary name to give for the test outputs.
    :return: taptest
    :rtype:  table

    .. code-block:: lua

        tap = require('tap')
        taptest = tap.test('test-name')

.. class:: taptest

    .. _taptest-test:

    .. method:: test(test-name, func)

        Create a subtest (if no ``func`` argument specified), or
        (if all arguments are specified)
        create a subtest, run the test function and print the result.

        See the :ref:`example <tap-example>`.

        :param string name: an arbitrary name to give for the test outputs.
        :param function fun: the test logic to run.
        :return: taptest
        :rtype:  userdata or string

    .. _taptest-plan:

    .. method:: plan(count)

        Indicate how many tests will be performed.

        :param number count:
        :return: nil

    .. _taptest-check:

    .. method:: check()

        Checks the number of tests performed.

        The result will be a display saying ``# bad plan: ...`` if the number
        of completed tests is not equal to the number of tests specified by
        ``taptest:plan(...)``. (This is a purely Tarantool feature: "bad plan"
        messages are out of the TAP13 standard.)

        This check should only be done after all planned tests are complete,
        so ordinarily ``taptest:check()`` will only appear at the end of a script.
        However, as a Tarantool extension, ``taptest:check()`` may appear at the
        end of any subtest. Therefore there are three ways to cause the check:

        * by calling ``taptest:check()`` at the end of a script,
        * by calling a function which ends with a call to ``taptest:check()``,
        * or by calling taptest:test('...', subtest-function-name) where
          subtest-function-name does not need to end with ``taptest:check()``
          because it can be called after the subtest is complete.

        :return: true or false.
        :rtype:  boolean

    .. _taptest-diag:

    .. method:: diag(message)

        Display a diagnostic message.

        :param string message: the message to be displayed.
        :return: nil

    .. _taptest-ok:

    .. method:: ok(condition, test-name)

        This is a basic function which is used by other functions. Depending
        on the value of ``condition``, print 'ok' or 'not ok' along with
        debugging information. Displays the message.

        :param boolean condition: an expression which is true or false
        :param string  test-name: name of the test

        :return: true or false.
        :rtype:  boolean

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> taptest:ok(true, 'x')
            ok - x
            ---
            - true
            ...
            tarantool> tap = require('tap')
            ---
            ...
            tarantool> taptest = tap.test('test-name')
            TAP version 13
            ---
            ...
            tarantool> taptest:ok(1 + 1 == 2, 'X')
            ok - X
            ---
            - true
            ...

    .. _taptest-fail:

    .. method:: fail(test-name)

        ``taptest:fail('x')`` is equivalent to ``taptest:ok(false, 'x')``.
        Displays the message.

        :param string  test-name: name of the test

        :return: true or false.
        :rtype:  boolean

    .. _taptest-skip:

    .. method:: skip(message)

        ``taptest:skip('x')`` is equivalent to
        ``taptest:ok(true, 'x' .. '# skip')``.
        Displays the message.

        :param string  test-name: name of the test

        :return: nil

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> taptest:skip('message')
            ok - message # skip
            ---
            - true
            ...

    .. _taptest-is:

    .. method:: is(got, expected, test-name)

        Check whether the first argument equals the second argument.
        Displays extensive message if the result is false.

        :param number got: actual result
        :param number expected: expected result
        :param string test-name: name of the test
        :return: true or false.
        :rtype:  boolean

    .. _taptest-isnt:

    .. method:: isnt(got, expected, test-name)

        This is the negation of :ref:`taptest:is() <taptest-is>`.

        :param number got: actual result
        :param number expected: expected result
        :param string test-name: name of the test

        :return: true or false.
        :rtype:  boolean

    .. _taptest-is_deeply:

    .. method:: is_deeply(got, expected, test-name)

        Recursive version of ``taptest:is(...)``, which can be be used to
        compare tables as well as scalar values.

        :return: true or false.
        :rtype:  boolean

        :param lua-value got: actual result
        :param lua-value expected: expected result
        :param string test-name: name of the test

    .. _taptest-like:

    .. method:: like(got, expected, test-name)

        Verify a string against a
        `pattern <http://lua-users.org/wiki/PatternsTutorial>`_.
        Ok if match is found.

        :return: true or false.
        :rtype:  boolean

        :param lua-value got: actual result
        :param lua-value expected: pattern
        :param string test-name: name of the test

    .. code-block:: lua

        test:like(tarantool.version, '^[1-9]', "version")

    .. _taptest-unlike:

    .. method:: unlike(got, expected, test-name)

        This is the negation of :ref:`taptest:like() <taptest-like>`.

        :param number got: actual result
        :param number expected: pattern
        :param string test-name: name of the test

        :return: true or false.
        :rtype:  boolean

    .. _taptest-istype:

    .. method:: isnil(value, test-name)
                isstring(value, test-name)
                isnumber(value, test-name)
                istable(value, test-name)
                isboolean(value, test-name)
                isudata(value, test-name)
                iscdata(value, test-name)

        Test whether a value has a particular type. Displays a long message if
        the value is not of the specified type.

        :param lua-value value:
        :param string test-name: name of the test

        :return: true or false.
        :rtype:  boolean

.. _prove: https://metacpan.org/pod/distribution/Test-Harness/bin/prove
.. _TAP protocol: https://en.wikipedia.org/wiki/Test_Anything_Protocol

.. _tap-example:

=================================================
                     Example
=================================================

To run this example: put the script in a file named ./tap.lua, then make
tap.lua executable by saying ``chmod a+x ./tap.lua``, then execute using
Tarantool as a script processor by saying ./tap.lua.

.. code-block:: lua

    #!/usr/bin/tarantool
    local tap = require('tap')
    test = tap.test("my test name")
    test:plan(2)
    test:ok(2 * 2 == 4, "2 * 2 is 4")
    test:test("some subtests for test2", function(test)
        test:plan(2)
        test:is(2 + 2, 4, "2 + 2 is 4")
        test:isnt(2 + 3, 4, "2 + 3 is not 4")
    end)
    test:check()

The output from the above script will look approximately like this:

.. code-block:: tap

    TAP version 13
    1..2
    ok - 2 * 2 is 4
        # Some subtests for test2
        1..2
        ok - 2 + 2 is 4,
        ok - 2 + 3 is not 4
        # Some subtests for test2: end
    ok - some subtests for test2
