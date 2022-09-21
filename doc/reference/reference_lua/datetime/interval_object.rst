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
