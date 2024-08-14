..  _datetime-module:

Module datetime
===============

Since: :doc:`2.10.0 </release/2.10.0>`

The ``datetime`` module provides support for the :ref:`datetime <index-box_datetime>`and :ref:`interval <index-box_interval>` data types.
It allows creating the date and time values either via the object interface
or via parsing string values conforming to the ISO-8601 standard.


.. _uri-module-api-reference:

API Reference
-------------

Below is a list of ``datetime`` functions, properties, and related objects.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 35 65

        *   -   **Functions**
            -

        *   -   :ref:`datetime.new() <datetime-new>`
            -   Create an object of the ``datetime`` type from a table of time units

        *   -   :ref:`datetime.now() <datetime-now>`
            -   Create an object of the ``datetime`` type with the current date and time

        *   -   :ref:`datetime.is_datetime() <datetime-is_datetime>`
            -   Check whether the specified value is a ``datetime`` object

        *   -   :ref:`datetime.parse() <datetime-parse>`
            -   Convert an input string with the date and time information into a ``datetime`` object

        *   -   :ref:`datetime.interval.is_interval() <datetime-interval-is_interval>`
            -   Check whether the specified value is an ``interval`` object

        *   -   :ref:`datetime.interval.new() <datetime-interval-new>`
            -   Create an object of the ``interval`` type from a table of time units

        *   -   **Properties**
            -

        *   -   :ref:`datetime.TZ <datetime-tz>`
            -   A Lua table that maps timezone names and abbreviations to its index and vice-versa.

        *   -   **Methods**
            -

        *   -   :ref:`datetime_object:add() <datetime-add>`
            -   Modify an existing ``datetime`` object by adding values of the input argument

        *   -   :ref:`datetime_object:format() <datetime-format>`
            -   Convert the standard ``datetime`` object presentation into a formatted string

        *   -   :ref:`datetime_object:set() <datetime-set>`
            -   Update the field values in the existing ``datetime`` object

        *   -   :ref:`datetime_object:sub() <datetime-sub>`
            -   Modify an existing ``datetime`` object by subtracting values of the input argument

        *   -   :ref:`datetime_object:totable() <datetime-totable>`
            -   Convert the information from a ``datetime`` object into the table format

        *   -   :ref:`interval_object:totable() <interval-totable>`
            -   Convert the information from an ``interval`` object into the table format






..  _datetime-module-api-reference-functions:

Functions
~~~~~~~~~

..  _datetime-new:

..  function:: datetime.new( [{ units }] )

    Create an object of the :ref:`datetime type <index-box_datetime>` from a table of time units.
    See the :ref:`description of units <datetime-new-args>` and :ref:`examples <datetime-new-example>` below.

    :param table units: Table of :ref:`time units <datetime-new-args>`.
                                If an empty table or no arguments are passed, the ``datetime`` object with the default values corresponding to Unix Epoch is created: ``1970-01-01T00:00:00Z``.

    :return: :ref:`datetime object <datetime_obj>`
    :rtype: cdata

    ..  _datetime-new-args:

    **Possible input time units for datetime.new()**

    ..  container:: table

        ..  list-table::
            :widths: 20 50 20 10
            :header-rows: 1

            *   -   Name
                -   Description
                -   Type
                -   Default

            *   -   nsec (usec, msec)
                -   Fractional part of the last second. You can specify either nanoseconds (``nsec``), or microseconds (``usec``), or milliseconds (``msec``).
                    Specifying two of these units simultaneously or all three ones lead to an error.
                -   number
                -   0

            *   -   sec
                -   Seconds. Value range: 0 - 60. A leap second is supported, see a section :ref:`leap second <leap-second>`.
                -   number
                -   0

            *   -   min
                -   Minutes. Value range: 0 - 59.
                -   number
                -   0

            *   -   hour
                -   Hours. Value range: 0 - 23.
                -   number
                -   0

            *   -   day
                -   Day number. Value range: 1 - 31. The special value ``-1`` generates the last day of a particular month (see :ref:`example below <datetime-new-example>`).
                -   number
                -   1

            *   -   month
                -   Month number. Value range: 1 - 12.
                -   number
                -   1

            *   -   year
                -   Year.
                -   number
                -   1970

            *   -   timestamp
                -   Timestamp, in seconds. Similar to the Unix timestamp, but can have a fractional part that is converted in nanoseconds in the resulting ``datetime`` object.
                    If the fractional part for the last second is set via the ``nsec``, ``usec``, or ``msec`` units, the timestamp value should be integer otherwise an error occurs.
                    The timestamp is not allowed if you already set time and/or date via specific units, namely, ``sec``, ``min``, ``hour``, ``day``, ``month``, and ``year``.
                -   number
                -   0

            *   -   tzoffset
                -   A time zone offset from UTC, in minutes. Value range: -720 - 840 inclusive.
                    If both ``tzoffset`` and ``tz`` are specified, ``tz`` has the preference and the ``tzoffset``
                    value is ignored. See a section :ref:`timezone <timezone>`.
                -   number
                -   0

            *   -   tz
                -   A time zone name according to the Time Zone Database. See the :ref:`timezone` section.
                -   string
                -   -

    ..  _datetime-new-example:

    **Examples:**

    ..  code-block:: tarantoolsession

        tarantool> datetime.new {
                    nsec = 123456789,

                    sec = 20,
                    min = 25,
                    hour = 18,

                    day = 20,
                    month = 8,
                    year = 2021,

                    tzoffset  = 180
                    }
        ---
        - 2021-08-20T18:25:20.123456789+0300
        ...

        tarantool> datetime.new {
                    nsec = 123456789,

                    sec = 20,
                    min = 25,
                    hour = 18,

                    day = 20,
                    month = 8,
                    year = 2021,

                    tzoffset = 60,
                    tz = 'Europe/Moscow'
                    }
        ---
        - 2021-08-20T18:25:20.123456789 Europe/Moscow
        ...

        tarantool> datetime.new {
                    day = -1,
                    month = 2,
                    year = 2021,
                    }
        ---
        - 2021-02-28T00:00:00Z
        ...

        tarantool> datetime.new {
                    timestamp = 1656664205.123,
                    tz = 'Europe/Moscow'
                    }
        ---
        - 2022-07-01T08:30:05.122999906 Europe/Moscow
        ...

        tarantool> datetime.new {
                    nsec = 123,
                    timestamp = 1656664205,
                    tz = 'Europe/Moscow'
                    }
        ---
        - 2022-07-01T08:30:05.000000123 Europe/Moscow
        ...


..  _datetime-now:

..  function:: datetime.now()

    Create an object of the ``datetime`` type with the current date and time.

    :return: :ref:`datetime object <datetime_obj>`
    :rtype: cdata

..  _datetime-is_datetime:

..  function:: datetime.is_datetime([value])

    Check whether the specified value is a ``datetime`` object.

    :param any value: the value to check

    :return: ``true`` if the specified value is a ``datetime`` object; otherwise, ``false``
    :rtype: boolean

..  _datetime-parse:

..  function:: datetime.parse( 'input_string'[, {format, tzoffset} ] )

    Convert an input string with the date and time information into a ``datetime`` object.
    The input string should be formatted according to one of the following standards:

    *   ISO 8601
    *   RFC 3339
    *   extended `strftime <https://www.freebsd.org/cgi/man.cgi?query=strftime&sektion=3>`__ -- see description of the :ref:`format() <datetime-format>` for details.

    By default fields that are not specified are equal to appropriate values in a Unix time.

    Leap second is supported, see a section :ref:`leap second <leap-second>`.

    :param string input_string: string with the date and time information.
    :param string format: indicator of the ``input_string`` format.
                          Possible values: 'iso8601', 'rfc3339', or ``strptime``-like format string.
                          If no value is set, the default formatting is used (``"%F %T %Z"``).
                          Note that only a part of possible ISO 8601 and RFC 3339 formats are supported.
                          To parse unsupported formats, you can specify a format string manually using
                          `conversion specifications <https://www.freebsd.org/cgi/man.cgi?query=strftime&sektion=3>`__
                          and ordinary characters.
    :param number tzoffset: time zone offset from UTC, in minutes.

    :return: a datetime_object
    :rtype: cdata
    :return: a number of parsed characters
    :rtype: number

    **Example:**

    ..  code-block:: tarantoolsession

        tarantool> datetime.parse('1970-01-01T00:00:00Z')
        ---
        - 1970-01-01T00:00:00Z
        - 20
        ...

        tarantool> t = datetime.parse('1970-01-01T00:00:00', {format = 'iso8601', tzoffset = 180})

        tarantool> t
        ---
        - 1970-01-01T00:00:00+0300
        ...

        tarantool> t = datetime.parse('2017-12-27T18:45:32.999999-05:00', {format = 'rfc3339'})

        tarantool> t
        ---
        - 2017-12-27T18:45:32.999999-0500
        ...

        tarantool> T = datetime.parse('Thu Jan  1 03:00:00 1970', {format = '%c'})

        tarantool> T
        ---
        - 1970-01-01T03:00:00Z
        ...

        tarantool> T = datetime.parse('12/31/2020', {format = '%m/%d/%y'})

        tarantool> T
        ---
        - 2020-12-31T00:00:00Z
        ...

        tarantool> T = datetime.parse('1970-01-01T03:00:00.125000000+0300', {format = '%FT%T.%f%z'})

        tarantool> T
        ---
        - 1970-01-01T03:00:00.125+0300
        ...

        tarantool> dt = datetime.parse('01:01:01 MSK', {format ='%H:%M:%S %Z'})

        ---
        ...

        tarantool> dt.year
        ---
        - 1970
        ...

        tarantool> dt.month
        ---
        - 1
        ...

        tarantool> dt.wday
        ---
        - 5
        ...

        tarantool> dt.tz
        ---
        - MSK
        ...

..  _datetime-interval-is_interval:

..  function:: datetime.interval.is_interval([value])

    Since: :doc:`3.2.0 </release/3.2.0>`

    Check whether the specified value is an ``interval`` object.

    :param any value: the value to check

    :return: ``true`` if the specified value is an ``interval`` object; otherwise, ``false``
    :rtype: boolean

    **Examples:**

    If a numeric value is passed to ``is_interval()``, it returns ``false``:

    ..  code-block:: tarantoolsession

        tarantool> datetime = require('datetime')
        ---
        ...
        tarantool> datetime.interval.is_interval(123)
        ---
        - false
        ...

    If an interval object is passed to ``is_interval()``, it returns ``true``:

    ..  code-block:: tarantoolsession

        tarantool> datetime.interval.is_interval(datetime.interval.new())
        ---
        - true
        ...

..  _datetime-interval-new:

..  function:: datetime.interval.new()

    Create an object of the :ref:`interval type <index-box_interval>` from a table of time units.
    See :ref:`description of units <interval-new-args>` and :ref:`examples <interval-new-example>` below.

    :param table input: Table with :ref:`time units and parameters<interval-new-args>`. For all possible time units, the values are not restricted.
                                If an empty table or no arguments are passed, the ``interval`` object with the default value ``0 seconds`` is created.

    :return: interval_object
    :rtype: cdata

    ..  _interval-new-args:

    **Possible input time units and parameters for datetime.interval.new()**

    ..  container:: table

        ..  list-table::
            :widths: 20 50 20 10
            :header-rows: 1

            *   -   Name
                -   Description
                -   Type
                -   Default

            *   -   nsec (usec, msec)
                -   Fractional part of the last second. You can specify either nanoseconds (``nsec``), or microseconds (``usec``), or milliseconds (``msec``).
                    Specifying two of these units simultaneously or all three ones lead to an error.
                -   number
                -   0

            *   -   sec
                -   Seconds
                -   number
                -   0

            *   -   min
                -   Minutes
                -   number
                -   0

            *   -   hour
                -   Hours
                -   number
                -   0

            *   -   day
                -   Day number
                -   number
                -   0

            *   -   week
                -   Week number
                -   number
                -   0

            *   -   month
                -   Month number
                -   number
                -   0

            *   -   year
                -   Year
                -   number
                -   0

            *   -   adjust
                -   Defines how to round days in a month after an arithmetic operation.
                -   string
                -   'none'

    ..  _interval-new-example:

    **Examples:**

    ..  code-block:: tarantoolsession

        tarantool> datetime.interval.new()

        ---
        - 0 seconds
        ...

        tarantool> datetime.interval.new {
                    month = 6,
                    year = 1
                    }
        ---
        - +1 years, 6 months
        ...

        tarantool> datetime.interval.new {
                    day = -1
                    }
        ---
        - -1 days
        ...




..  _datetime-module-api-reference-properties:

Properties
~~~~~~~~~~

..  _datetime-tz:

..  data:: TZ

    Since: :doc:`2.11.0 </release/2.11.0>`

    A Lua table that maps timezone names (like ``Europe/Moscow``) and
    timezone abbreviations (like ``MSK``) to its index and vice-versa.
    See the :ref:`timezone` section.

    ..  code-block:: tarantoolsession

        tarantool> datetime.TZ['Europe/Moscow']
        ---
        - 947
        ...

        tarantool> datetime.TZ[947]
        ---
        - Europe/Moscow
        ...

..  _datetime-module-api-reference-objects:

Related objects
~~~~~~~~~~~~~~~

.. _datetime_obj:

datetime_object
***************

..  class:: datetime_object

    A ``datetime`` object.

    ..  _datetime-add:

    ..  method:: add( input[, { adjust } ] )

        Modify an existing datetime object by adding values of the input argument.
        See also: :ref:`interval_arithm`. The addition is performed taking ``tzdata``
        into account, when ``tzoffset`` or ``tz`` fields are set, see the :ref:`timezone`.

        :param table input: an :ref:`interval object <interval_obj>` or an equivalent table (see **Example #1**)
        :param string adjust: defines how to round days in a month after an arithmetic operation.
                                Possible values: ``none``, ``last``, ``excess`` (see **Example #2**). Defaults to ``none``.

        :return: datetime_object
        :rtype: cdata

        **Example #1:**

        ..  code-block:: tarantoolsession

            tarantool> dt = datetime.new {
                        day = 26,
                        month = 8,
                        year = 2021,
                        tzoffset  = 180
                        }
            ---
            ...

            tarantool> iv = datetime.interval.new {day = 7}
            ---
            ...

            tarantool> dt, iv
            ---
            - 2021-08-26T00:00:00+0300
            - +7 days
            ...

            tarantool> dt:add(iv)
            ---
            - 2021-09-02T00:00:00+0300
            ...

            tarantool> dt:add{ day = 7 }
            ---
            - 2021-09-09T00:00:00+0300
            ...

        ..  _datetime-add-example2:

        **Example #2:**

        ..  code-block:: tarantoolsession

            tarantool> dt = datetime.new {
                        day = 29,
                        month = 2,
                        year = 2020
                        }
            ---
            ...

            tarantool> dt:add{month = 1, adjust = 'none'}
            ---
            - 2020-03-29T00:00:00Z
            ...

            tarantool> dt = datetime.new {
                        day = 29,
                        month = 2,
                        year = 2020
                        }
            ---
            ...

            tarantool> dt:add{month = 1, adjust = 'last'}
            ---
            - 2020-03-31T00:00:00Z
            ...

            tarantool> dt = datetime.new {
                        day = 31,
                        month = 1,
                        year = 2020
                        }
            ---
            ...

            tarantool> dt:add{month = 1, adjust = 'excess'}
            ---
            - 2020-03-02T00:00:00Z
            ...

    ..  _datetime-format:

    ..  method:: format( ['input_string'] )

        Convert the standard ``datetime`` object presentation into a formatted string.
        The conversion specifications are the same as in the `strftime <https://www.freebsd.org/cgi/man.cgi?query=strftime&sektion=3>`__ function.
        Additional specification for nanoseconds is `%f` which also allows a modifier to control the output precision of fractional part: `%5f` (see the example below).
        If no arguments are set for the method, the default conversions are used: `'%FT%T.%f%z'` (see the example below).

        :param string input_string: string consisting of zero or more conversion specifications and ordinary characters

        :return: string with the formatted date and time information
        :rtype: string

        **Example:**

        ..  code-block:: tarantoolsession

            tarantool> dt = datetime.new {
                        nsec = 123456789,

                        sec = 20,
                        min = 25,
                        hour = 18,

                        day = 20,
                        month = 8,
                        year = 2021,

                        tzoffset  = 180
                        }
            ---
            ...

            tarantool> dt:format('%d.%m.%y %H:%M:%S.%5f')
            ---
            - 20.08.21 18:25:20.12345
            ...

            tarantool> dt:format()
            ---
            - 2021-08-20T18:25:20.123456789+0300
            ...

            tarantool> dt:format('%FT%T.%f%z')
            ---
            - 2021-08-20T18:25:20.123456789+0300
            ...

    ..  _datetime-set:

    ..  method:: set( [{ units }] )

        Update the field values in the existing ``datetime`` object.

        :param table units: Table of time units. The :ref:`time units <datetime-new-args>` are the same as for the ``datetime.new()`` function.

        :return: updated datetime_object
        :rtype: cdata

        **Example:**

        ..  code-block:: tarantoolsession

            tarantool> dt = datetime.new {
                        nsec = 123456789,

                        sec = 20,
                        min = 25,
                        hour = 18,

                        day = 20,
                        month = 8,
                        year = 2021,

                        tzoffset  = 180
                        }

            tarantool> dt:set {msec = 567}
            ---
            - 2021-08-20T18:25:20.567+0300
            ...

            tarantool> dt:set {tzoffset = 60}
            ---
            - 2021-08-20T18:25:20.567+0100
            ...


    ..  _datetime-sub:

    ..  method:: sub( { input[, adjust ] } )

        Modify an existing datetime object by subtracting values of the input argument.
        See also: :ref:`interval_arithm`. The subtraction is performed taking ``tzdata``
        into account, when ``tzoffset`` or ``tz`` fields are set, see the :ref:`timezone`.

        :param table input: an :ref:`interval object <interval_obj>` or an equivalent table (see **Example**)
        :param string adjust: defines how to round days in a month after an arithmetic operation.
                                Possible values: ``none``, ``last``, ``excess``. Defaults to ``none``.
                                The logic is similar to the one of the ``:add()`` method -- see :ref:`Example #2 <datetime-add-example2>`.

        :return: datetime_object
        :rtype: cdata

        **Example:**

        ..  code-block:: tarantoolsession

            tarantool> dt = datetime.new {
                        day = 26,
                        month = 8,
                        year = 2021,
                        tzoffset  = 180
                        }
            ---
            ...

            tarantool> iv = datetime.interval.new {day = 5}
            ---
            ...

            tarantool> dt, iv
            ---
            - 2021-08-26T00:00:00+0300
            - +5 days
            ...

            tarantool> dt:sub(iv)
            ---
            - 2021-08-21T00:00:00+0300
            ...

            tarantool> dt:sub{ day = 1 }
            ---
            - 2021-08-20T00:00:00+0300
            ...


    ..  _datetime-totable:

    ..  method:: totable()

        Convert the information from a ``datetime`` object into the table format.
        The resulting table has the following fields:

        ..  container:: table

            ..  list-table::
                :widths: 30 70
                :header-rows: 1

                *   -   Field name
                    -   Description

                *   -   nsec
                    -   Nanoseconds. Number.

                *   -   sec
                    -   Seconds. Number.

                *   -   min
                    -   Minutes. Number.

                *   -   hour
                    -   Hours. Number.

                *   -   day
                    -   Day number.

                *   -   month
                    -   Month number.

                *   -   year
                    -   Year. Number.

                *   -   wday
                    -   Days since the beginning of the week. Number.

                *   -   yday
                    -   Days since the beginning of the year. Number.

                *   -   isdst
                    -   Is the DST (Daylight Saving Time) applicable for the date,
                        see a section :ref:`timezone <timezone>`. Boolean.

                *   -   tzoffset
                    -   Time zone offset from UTC, see a section :ref:`timezone <timezone>`. Number.

                *   -   tz
                    -   Time zone name or abbreviation, see a section :ref:`timezone <timezone>`. String.

        :return: table with the date and time parameters
        :rtype: table

        **Example:**

        ..  code-block:: tarantoolsession

            tarantool> dt = datetime.new {
                        sec = 20,
                        min = 25,
                        hour = 18,

                        day = 20,
                        month = 8,
                        year = 2021,
                        tz = 'MAGT',
                        }
            ---
            ...

            tarantool> dt:totable()
            ---
            - tz: 'MAGT'
              sec: 20
              min: 25
              yday: 232
              day: 20
              nsec: 0
              isdst: false
              wday: 6
              tzoffset: 600
              month: 8
              year: 2021
              hour: 18
            ...


.. _interval_obj:

interval_object
***************

..  class:: interval_object

    An ``interval`` object.

    ..  _interval-totable:

    ..  method:: totable()

        Convert the information from an ``interval`` object into the table format.
        The resulting table has the following fields:

        ..  container:: table

            ..  list-table::
                :widths: 30 70
                :header-rows: 1

                *   -   Field name
                    -   Description

                *   -   nsec
                    -   Nanoseconds

                *   -   sec
                    -   Seconds

                *   -   min
                    -   Minutes

                *   -   hour
                    -   Hours

                *   -   day
                    -   Day number

                *   -   month
                    -   Month number

                *   -   year
                    -   Year

                *   -   week
                    -   Week number

                *   -   adjust
                    -   Defines how to round days in a month after an arithmetic operation.

        :return: table with the date and time parameters
        :rtype: table

        **Example:**

        ..  code-block:: tarantoolsession

            tarantool> iv = datetime.interval.new{month = 1, adjust = 'last'}
            ---
            ...

            tarantool> iv:totable()
            ---
            - adjust: last
              sec: 0
              nsec: 0
              day: 0
              week: 0
              hour: 0
              month: 1
              year: 0
              min: 0
            ...




.. _interval_arithm:

Datetime and interval arithmetic
--------------------------------

The ``datetime`` module enables creating of objects of two types: ``datetime`` and ``interval``.

If you need to shift the ``datetime`` object values, you can use either the modifier methods, that is, the :ref:`datetime_object:add() <datetime-add>` or :ref:`datetime_object:sub() <datetime-sub>` methods,
or apply interval arithmetic using overloaded ``+`` (``__add``) or ``-`` (``__sub``) methods.

``datetime_object:add()``/``datetime_object:sub()`` modify the current object, but ``+``/``-`` create copy of the object as the operation result.

In the interval operation, each of the interval subcomponents is sequentially calculated starting from the largest (``year``) to the smallest (``nsec``):

*   ``year`` -- years
*   ``month`` -- months
*   ``week`` -- weeks
*   ``day`` -- days
*   ``hour`` -- hours
*   ``min`` -- minutes
*   ``sec`` -- seconds
*   ``nsec`` -- nanoseconds

If the results of the operation exceed the allowed range for any of the components, an exception is raised.

The ``datetime`` and ``interval`` objects can participate in arithmetic operations:

*   The sum of two intervals is an interval object, whose fields are the sum of each particular component of operands.

*   The result of subtraction of two intervals is similar: it's an interval object where each subcomponent is the result of subtraction of particular fields in the original operands.

*   If you add datetime and interval objects, the result is a datetime object. The addition is performed in a determined order from the largest component (``year``) to the smallest (``nsec``).

*   Subtraction of two datetime objects produces an interval object. The difference of two time values is performed not as the difference of the epoch seconds,
    but as difference of all the subcomponents, that is, years, months, days, hours, minutes, and seconds.

*   An untyped table object can be used in each context where the typed datetime or interval objects are used if the left operand is a typed object with an overloaded operation of ``+`` or ``-``.

The matrix of the ``addition`` operands eligibility and their result types:

..  container:: table

    ..  list-table::
        :widths: 25 25 25 25
        :header-rows: 1

        *   -
            -   datetime
            -   interval
            -   table

        *   -   **datetime**
            -   unsupported
            -   datetime
            -   datetime

        *   -   **interval**
            -   datetime
            -   interval
            -   interval


The matrix of the ``subtraction`` operands eligibility and their result types:

..  container:: table

    ..  list-table::
        :widths: 25 25 25 25
        :header-rows: 1

        *   -
            -   datetime
            -   interval
            -   table

        *   -   **datetime**
            -   interval
            -   datetime
            -   datetime

        *   -   **interval**
            -   unsupported
            -   interval
            -   interval

The subtraction and addition of datetime objects are performed taking ``tzdata``
into account ``tzoffset`` or ``tz`` fields are set:

..  code-block:: tarantoolsession

    tarantool> datetime.new({tz='MSK'}) - datetime.new({tz='UTC'})
    ---
    - -180 minutes
    ...

.. _interval_comp:

Datetime and interval comparison
--------------------------------

If you need to compare the ``datetime`` and ``interval`` object values, you can use standard Lua relational operators: ``==``, ``~=``, ``>``, ``<``, ``>=``, and ``<=``. These operators use the overloaded ``__eq``, ``__lt``, and ``__le`` metamethods to compare values.

Support for relational operators for ``interval`` objects has been added since :doc:`2.11.0 </release/2.11.0>`.

**Example 1:**

..  code-block:: tarantoolsession

    tarantool> dt1 = datetime.new({ year = 2010 })
    ---
    ...

    tarantool> dt2 = datetime.new({ year = 2024 })
    ---
    ...

    tarantool> dt1 == dt2
    ---
    - false
    ...

    tarantool> dt1 < dt2
    ---
    - true
    ...

**Example 2:**

..  code-block:: tarantoolsession

    tarantool> iv1 = datetime.interval.new({month = 1})
    ---
    ...

    tarantool> iv2 = datetime.interval.new({month = 2})
    ---
    ...

    tarantool> iv1 < iv2
    ---
    - true
    ...

.. _leap-second:

Leap second
-----------

`Leap seconds <https://en.wikipedia.org/wiki/Leap_second>`__ are a periodic
one-second adjustment of Coordinated Universal Time(UTC) in order to keep
a system's time of day close to the mean solar time. However,
the Earth's rotation speed varies in response to climatic and geological events,
and due to this, UTC leap seconds are irregularly spaced and unpredictable.

Tarantool includes the `Time Zone Database <https://www.iana.org/time-zones>`__
that besides the time zone description files also contains a leapseconds file.
You can use the Lua module :ref:`tarantool <tarantool-module>` to get a used
version of ``tzdata``.

This section describes how the ``datetime`` module supports leap seconds:

*   The function :ref:`datetime.parse() <datetime-parse>` correctly parses
    an input string with 60 seconds:

    ..  code-block:: tarantoolsession

        tarantool> datetime.parse('23:12:60', {format ='%H:%M:%S'})
        ---
        - 1970-01-01T23:13:00Z
        - 8
        ...

*   The :ref:`datetime.new() <datetime-new>` function and the
    :ref:`datetime_object:set() <datetime-set>` method accept a table with the ``sec`` key set to 60 seconds:

    ..  code-block:: tarantoolsession

        tarantool> datetime.new({ sec = 60 })
        ---
        - 1970-01-01T00:01:00Z
        ...

.. _timezone:

Time zones
----------

Full support has been added since :doc:`2.11.0 </release/2.11.0>`.

Tarantool uses the `Time Zone Database <https://www.iana.org/time-zones>`__
(also known as the Olson database and supported by IANA) for timezone support.
You can use the Lua module :ref:`tarantool <tarantool-module>` to get a used version of ``tzdata``.

Every datetime object has three fields that represent timezone support:
``tz``, ``tzoffset``, and ``isdst``:

*   The field ``isdst`` is calculated using tzindex and attributes of the selected
    timezone in the Olson DB timezone.

    ..  code-block:: tarantoolsession

        tarantool> require('datetime').parse('2004-06-01T00:00 Europe/Moscow').isdst
        ---
        - true
        ...

*   The field ``tz`` field can be set to a timezone name or abbreviation. A timezone name
    is a human-readable name based on the Time Zone Database, for example, "Europe/Moscow".
    Timezone abbreviations represent time zones by `alphabetic abbreviations <https://www.timeanddate.com/time/zones/>`__
    such as "EST", "WST", and "F". Both timezone names and abbreviations are available
    via the bidirectional array :ref:`datetime.TZ <datetime-tz>`.

*   The field ``tzoffset`` is calculated automatically using the current Olson rule.
    This means that it takes into account summer time, leap year, and leap seconds information
    when a timezone name is set. However, the ``tzoffset`` field can be set manually when
    an appropriate timezone is not available.

The fields ``tz`` and ``tzoffset`` can be set in :ref:`datetime.new() <datetime-new>`,
:ref:`datetime.parse() <datetime-parse>`, and :ref:`datetime_object:set() <datetime-set>`.
The arithmetic on datetime objects are performed taking ``tzdata`` into account, when
``tzoffset`` or ``tz`` fields are set, see the :ref:`interval_arithm` section.

Limitations
-----------

*   The supported date range is from ``-5879610-06-22`` to ``+5879611-07-11``.

*   There were moments in past history when local mean time in some particular zone
    used a timezone offset not representable in a whole minutes but rather in seconds.
    For example, in Moscow before 1918 there used to be offset +2 hours 31 minutes and 19 seconds.
    See an Olson dump for this period:

    .. code-block:: console

        $ zdump -c1880,1918 -i Europe/Moscow

        TZ="Europe/Moscow"
        -       -       +023017 MMT
        1916-07-03      00:01:02        +023119 MMT
        1917-07-02      00      +033119 MST     1
        1917-12-27      23      +023119 MMT

    Modern ``tzdata`` rules do not use such a tiny fraction, and all timezones differ
    from UTC in units measured in minutes, not seconds. Tarantool datetime module uses
    minutes internally as units for ``tzoffset``. So there might be some loss of precision
    if you try to operate with such ancient timestamps.

References
----------

*   `RFC 3339: Date and Time on the Internet: Timestamps <https://www.rfc-editor.org/rfc/rfc3339>`_

*   `ISO 8601: Date and time format <https://www.iso.org/iso-8601-date-and-time-format.html>`_

*   `Lua 5.1 Reference Manual: 5.8 – Operating System Facilities <https://www.lua.org/manual/5.1/manual.html#pdf-os.date>`_

*   `Lua Programming in Lua: 22.1 – Date and Time <https://www.lua.org/pil/22.1.html>`_
