.. _interval_obj:

interval_object
===============

..  class:: interval_object

    Since :doc:`2.10.0 </release/2.10.0>`.

    ..  _interval-totable:

    ..  method:: totable()

        Convert the information from an ``interval`` object into the table format.
        Resulting table has the following fields:

        ..  container:: table

            ..  list-table::
                :widths: 30 70
                :header-rows: 1

                *   -   Field name
                    -   Description

                *   -   nsec
                    -   Nanosecods

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

    ..  _interval-is_interval:

    ..  method:: is_interval()

        Returns ``true`` if the specified value is an ``interval`` object;
        otherwise, ``false``.

        See also: :ref:`datetime-interval-new`

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
