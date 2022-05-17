.. _merger-module:

-------------------------------------------------------------------------------
                            Module merger
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

The ``merger`` module takes a stream of tuples and provides access
to them as tables.

===============================================================================
                                    Index
===============================================================================

The four functions for creating a merger object instance are:

* :ref:`merger.new_tuple_source() <merger-new_tuple_source>`,
* :ref:`merger.new_buffer_source() <merger-new_buffer_source>`,
* :ref:`merger.new_table_source <merger-new_table_source>`,
* :ref:`merger.new(merger_source...) <merger-new_merger_source>`.

The methods for using a merger object are:

* :ref:`merger_object:select() <merger-select>`,
* :ref:`merger_object:pairs() <merger-pairs>`.

.. module:: merger

.. _merger-new_tuple_source:

.. function:: new_tuple_source(gen, param, state)

    Create a new merger instance from a tuple source.

    A tuple source just returns one tuple.

    The generator function ``gen()`` allows creation of multiple tuples
    via an iterator.

    The ``gen()`` function should return:

    * state, tuple each time it is called and a new tuple is available,
    * nil when no more tuples are available.

    :param gen:   function for iteratively returning tuples
    :param param: parameter for the gen function

    :return: merger-object :ref:`a merger object <merger-object>`

    Example: see :ref:`merger_object:pairs() <merger-pairs>` method.

.. _merger-new_buffer_source:

.. function:: new_buffer_source(gen, param, state)

    Create a new merger instance from a buffer source.

    Parameters and return:
    same as for :ref:`merger.new_tuple_source <merger-new_tuple_source>`.

    To set up a buffer, or a series of buffers,
    use :ref:`the buffer module <buffer-module>`.

.. _merger-new_table_source:

.. function:: new_table_source(gen, param, state)

    Create a new merger instance from a table source.

    Parameters and return:
    same as for :ref:`merger.new_tuple_source <merger-new_tuple_source>`.

    Example: see :ref:`merger_object:select() <merger-select>` method.

.. _merger-new_merger_source:

.. function:: new(key_def, sources, options)

    Create a new merger instance from a merger source.

    A merger source is created from a
    :ref:`key_def <key_def-module>`
    object and a set of (tuple or buffer or table or merger)
    sources. It performs a kind of merge sort.
    It chooses a source with a minimal / maximal tuple on each step,
    consumes a tuple from this source, and repeats.

    :param key_def:     object created with ``key_def``
    :param source:      parameter for the ``gen()`` function
    :param options:     ``reverse=true`` if descending, false or nil if ascending

    :return: merger-object :ref:`a merger object <merger-object>`

    A ``key_def`` can be cached across requests with the same ordering rules
    (typically these would be requests accessing the same space).

    Example: see :ref:`merger_object:pairs() <merger-pairs>` method.

.. _merger-object:

.. class:: merger_object

    A merger object is an object returned by:

    * :ref:`merger.new_tuple_source() <merger-new_tuple_source>` or
    * :ref:`merger.new_buffer_source() <merger-new_buffer_source>` or
    * :ref:`merger.new_table_source <merger-new_table_source>` or
    * :ref:`merger.new(merger_source...) <merger-new_merger_source>`.

    It has methods:

    * :ref:`merger_object:select() <merger-select>` or
    * :ref:`merger_object:pairs() <merger-pairs>`.

    .. _merger-select:

    .. method:: select([buffer [, limit]])

        Access the contents of a merger object with familiar ``select`` syntax.

        :param buffer: as in ``net.box`` client :ref:`conn:select <conn-select>` method
        :param limit: as in ``net.box`` client :ref:`conn:select <conn-select>` method

        :return: a table of tuples, similar to what ``select`` would return

        **Example with new_table_source():**

        .. code-block:: lua

            -- Source via new_table_source, simple generator function
            -- tarantool> s:select()
            -- ---
            -- - - [100]
            --   - [200]
            -- ...
            merger=require('merger')
            k=0
            function merger_function(param)
              k = k + 1
              if param[k] == nil then return nil end
              return box.NULL, param[k]
              end
            chunks={}
            chunks[1] = {{100}} chunks[2] = {{200}} chunks[3] = nil
            s = merger.new_table_source(merger_function, chunks)
            s:select()

    .. _merger-pairs:

    .. method:: pairs()

        The ``pairs()`` method (or the equivalent ``ipairs() alias`` method)
        returns a luafun iterator. It is a Lua
        iterator, but also provides a set of handy methods to operate in
        functional style.

        :param table tuple: tuple or Lua table with field contents

        :return: the tuples that can be found with a standard ``pairs()`` function

        **Example with new_tuple_source():**

        .. code-block:: lua

            -- Source via new_tuple_source, from a space of tables
            -- The result will look like this:
            -- tarantool> so:pairs():totable()
            -- ---
            -- - - [100]
            --   - [200]
            -- ...
            merger = require('merger')
            box.schema.space.create('s')
            box.space.s:create_index('i')
            box.space.s:insert({100})
            box.space.s:insert({200})
            so = merger.new_tuple_source(box.space.s:pairs())
            so:pairs():totable()

        **Example with two mergers:**

        .. code-block:: lua

            -- Source via key_def, and table data

            -- Create the key_def object
            merger = require('merger')
            key_def_lib = require('key_def')
            key_def = key_def_lib.new({{
                fieldno = 1,
                type = 'string',
            }})
            -- Create the table source
            data = {{'a'}, {'b'}, {'c'}}
            source = merger.new_source_fromtable(data)
            i1 = merger.new(key_def, {source}):pairs()
            i2 = merger.new(key_def, {source}):pairs()
            -- t1 will be 'a' (tuple 1 from merger 1)
            t1 = i1:head():totable()
            -- t3 will be 'c' (tuple 3 from merger 2)
            t3 = i2:head():totable()
            -- t2 will be 'b' (tuple 2 from merger 1)
            t2 = i1:head():totable()
            -- i1:is_null() will be true (merger 1 ends)
            i1:is_null()
            -- i2:is_null() will be true (merger 2 ends)
            i2:is_null()

        **More examples:**

        See
        `https://github.com/Totktonada/tarantool-merger-examples <https://github.com/Totktonada/tarantool-merger-examples>`_
        which, in addition to discussing the merger API in detail,
        shows Lua code for handling many more situations than are
        in this manual's brief examples.
