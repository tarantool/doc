.. _box_index_examples:

===============================================================================
Examples for `box.index`
===============================================================================

*******************************************************************************
Example showing use of the box functions
*******************************************************************************

This example will work with the sandbox configuration described in the preface.
That is, there is a space named tester with a numeric primary key. The example
function will:

* select a tuple whose key value is 1000;
* raise an error if the tuple already exists and already has 3 fields;
* Insert or replace the tuple with:
    * field[1] = 1000
    * field[2] = a uuid
    * field[3] = number of seconds since 1970-01-01;
* Get field[3] from what was replaced;
* Format the value from field[3] as yyyy-mm-dd hh:mm:ss.ffff;
* Return the formatted value.

The function uses Tarantool box functions
:ref:`box.space...select <box_space-select>`,
:ref:`box.space...replace <box_space-replace>`, :ref:`fiber.time <fiber-time>`,
:ref:`uuid.str <uuid-str>`. The function uses
Lua functions `os.date() <http://www.lua.org/pil/22.1.html>`_ and
`string.sub() <http://www.lua.org/pil/20.html>`_.

.. code-block:: lua

    function example()
      local a, b, c, table_of_selected_tuples, d
      local replaced_tuple, time_field
      local formatted_time_field
      local fiber = require('fiber')
      table_of_selected_tuples = box.space.tester:select{1000}
      if table_of_selected_tuples ~= nil then
        if table_of_selected_tuples[1] ~= nil then
          if #table_of_selected_tuples[1] == 3 then
            box.error({code=1, reason='This tuple already has 3 fields'})
          end
        end
      end
      replaced_tuple = box.space.tester:replace
        {1000,  require('uuid').str(), tostring(fiber.time())}
      time_field = tonumber(replaced_tuple[3])
      formatted_time_field = os.date("%Y-%m-%d %H:%M:%S", time_field)
      c = time_field % 1
      d = string.sub(c, 3, 6)
      formatted_time_field = formatted_time_field .. '.' .. d
      return formatted_time_field
    end

... And here is what happens when one invokes the function:

.. code-block:: tarantoolsession

    tarantool> box.space.tester:delete(1000)
    ---
    - [1000, '264ee2da03634f24972be76c43808254', '1391037015.6809']
    ...
    tarantool> example(1000)
    ---
    - 2014-01-29 16:11:51.1582
    ...
    tarantool> example(1000)
    ---
    - error: 'This tuple already has 3 fields'
    ...

.. _box_index_example_iterator:

*******************************************************************************
Example showing a user-defined iterator
*******************************************************************************

Here is an example that shows how to build one's own iterator. The
``paged_iter`` function is an "iterator function", which will only be understood
by programmers who have read the Lua manual section `Iterators and Closures
<https://www.lua.org/pil/7.1.html>`_. It does paginated retrievals, that is, it
returns 10 tuples at a time from a table named "t", whose primary key was
defined with ``create_index('primary',{parts={1,'string'}})``.

.. code-block:: lua

    function paged_iter(search_key, tuples_per_page)
      local iterator_string = "GE"
      return function ()
      local page = box.space.t.index[0]:select(search_key,
        {iterator = iterator_string, limit=tuples_per_page})
      if #page == 0 then return nil end
      search_key = page[#page][1]
      iterator_string = "GT"
      return page
      end
    end

Programmers who use ``paged_iter`` do not need to know why it works, they only
need to know that, if they call it within a loop, they will get 10 tuples at a
time until there are no more tuples.

In this example the tuples are merely
printed, a page at a time. But it should be simple to change the functionality,
for example by yielding after each retrieval, or by breaking when the tuples
fail to match some additional criteria.

.. code-block:: lua

    for page in paged_iter("X", 10) do
      print("New Page. Number Of Tuples = " .. #page)
      for i = 1, #page, 1 do
        print(page[i])
      end
    end

.. _box_index-rtree:

***********************************************************************************
Example showing submodule `box.index` with index type = RTREE for spatial searches
***********************************************************************************

This submodule may be used for spatial searches if
the index type is RTREE. There are operations for searching *rectangles*
(geometric objects with 4 corners and 4 sides) and *boxes* (geometric objects
with more than 4 corners and more than 4 sides, sometimes called
hyperrectangles). This manual uses the term *rectangle-or-box* for the whole
class of objects that includes both rectangles and boxes. Only rectangles will
be illustrated.

Rectangles are described according to their X-axis (horizontal axis) and Y-axis
(vertical axis) coordinates in a grid of arbitrary size. Here is a picture of
four rectangles on a grid with 11 horizontal points and 11 vertical points:

.. code-block:: none

               X AXIS
               1   2   3   4   5   6   7   8   9   10  11
            1
            2  #-------+                                           <-Rectangle#1
    Y AXIS  3  |       |
            4  +-------#
            5          #-----------------------+                   <-Rectangle#2
            6          |                       |
            7          |   #---+               |                   <-Rectangle#3
            8          |   |   |               |
            9          |   +---#               |
            10         +-----------------------#
            11                                     #               <-Rectangle#4

The rectangles are defined according to this scheme: {X-axis coordinate of top
left, Y-axis coordinate of top left, X-axis coordinate of bottom right, Y-axis
coordinate of bottom right} -- or more succinctly: {x1,y1,x2,y2}. So in the
picture ... Rectangle#1 starts at position 1 on the X axis and position 2 on
the Y axis, and ends at position 3 on the X axis and position 4 on the Y axis,
so its coordinates are {1,2,3,4}. Rectangle#2's coordinates are {3,5,9,10}.
Rectangle#3's coordinates are {4,7,5,9}. And finally Rectangle#4's coordinates
are {10,11,10,11}. Rectangle#4 is actually a "point" since it has zero width
and zero height, so it could have been described with only two digits: {10,11}.

Some relationships between the rectangles are: "Rectangle#1's nearest neighbor
is Rectangle#2", and "Rectangle#3 is entirely inside Rectangle#2".

Now let us create a space and add an RTREE index.

.. code-block:: tarantoolsession

    tarantool> s = box.schema.space.create('rectangles')
    tarantool> i = s:create_index('primary', {
             >   type = 'HASH',
             >   parts = {1, 'unsigned'}
             > })
    tarantool> r = s:create_index('rtree', {
             >   type = 'RTREE',
             >   unique = false,
             >   parts = {2, 'ARRAY'}
             > })

Field#1 doesn't matter, we just make it because we need a primary-key index.
(RTREE indexes cannot be unique and therefore cannot be primary-key indexes.)
The second field must be an "array", which means its values must represent
{x,y} points or {x1,y1,x2,y2} rectangles. Now let us populate the table by
inserting two tuples, containing the coordinates of Rectangle#2 and Rectangle#4.

.. code-block:: tarantoolsession

    tarantool> s:insert{1, {3, 5, 9, 10}}
    tarantool> s:insert{2, {10, 11}}

And now, following the description of `RTREE iterator types`_, we can search the
rectangles with these requests:

.. _RTREE iterator types:

.. code-block:: tarantoolsession

    tarantool> r:select({10, 11, 10, 11}, {iterator = 'EQ'})
    ---
    - - [2, [10, 11]]
    ...
    tarantool> r:select({4, 7, 5, 9}, {iterator = 'GT'})
    ---
    - - [1, [3, 5, 9, 10]]
    ...
    tarantool> r:select({1, 2, 3, 4}, {iterator = 'NEIGHBOR'})
    ---
    - - [1, [3, 5, 9, 10]]
      - [2, [10, 11]]
    ...

Request#1 returns 1 tuple because the point {10,11} is the same as the rectangle
{10,11,10,11} ("Rectangle#4" in the picture). Request#2 returns 1 tuple because
the rectangle {4,7,5,9}, which was "Rectangle#3" in the picture, is entirely
within{3,5,9,10} which was Rectangle#2. Request#3 returns 2 tuples, because the
NEIGHBOR iterator always returns all tuples, and the first returned tuple will
be {3,5,9,10} ("Rectangle#2" in the picture) because it is the closest neighbor
of {1,2,3,4} ("Rectangle#1" in the picture).

Now let us create a space and index for cuboids, which are rectangle-or-boxes
that have 6 corners and 6 sides.

.. code-block:: tarantoolsession

    tarantool> s = box.schema.space.create('R')
    tarantool> i = s:create_index('primary', {parts = {1, 'unsigned'}})
    tarantool> r = s:create_index('S', {
             >   type = 'RTREE',
             >   unique = false,
             >   dimension = 3,
             >   parts = {2, 'ARRAY'}
             > })

The additional option here is ``dimension=3``. The default dimension is 2, which
is why it didn't need to be specified for the examples of rectangle. The maximum
dimension is 20. Now for insertions and selections there will usually be 6
coordinates. For example:

.. code-block:: tarantoolsession

    tarantool> s:insert{1, {0, 3, 0, 3, 0, 3}}
    tarantool> r:select({1, 2, 1, 2, 1, 2}, {iterator = box.index.GT})

Now let us create a space and index for Manhattan-style spatial objects, which
are rectangle-or-boxes that have a different way to calculate neighbors.

.. code-block:: tarantoolsession

    tarantool> s = box.schema.space.create('R')
    tarantool> i = s:create_index('primary', {parts = {1, 'unsigned'}})
    tarantool> r = s:create_index('S', {
             >   type = 'RTREE',
             >   unique = false,
             >   distance = 'manhattan',
             >   parts = {2, 'ARRAY'}
             > })

The additional option here is ``distance='manhattan'``. The default distance
calculator is 'euclid', which is the straightforward as-the-crow-flies method.
The optional distance calculator is 'manhattan', which can be a more appropriate
method if one is following the lines of a grid rather than traveling in a
straight line.

.. code-block:: tarantoolsession

    tarantool> s:insert{1, {0, 3, 0, 3}}
    tarantool> r:select({1, 2, 1, 2}, {iterator = box.index.NEIGHBOR})

More examples of spatial searching are online in the file
`R tree index quick start and usage <https://github.com/tarantool/tarantool/wiki/R-tree-index-quick-start-and-usage>`_.
