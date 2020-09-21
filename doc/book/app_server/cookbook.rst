.. _cookbook:

--------------------------------------------------------------------------------
Cookbook recipes
--------------------------------------------------------------------------------

Here are contributions of Lua programs for some frequent or tricky situations.

You can execute any of these programs by copying the code into a ``.lua`` file,
and then entering :samp:`chmod +x ./{program-name}.lua`
and :samp:`./{program-name}.lua` on the terminal.

The first line is a "hashbang":

.. code-block:: lua

   #!/usr/bin/env tarantool

This runs  Tarantool Lua application server, which should be on the execution
path.

This section contains the following recipes:

.. contents::
   :local:

Use freely.

.. _cookbook-hello_world:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
hello_world.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The standard example of a simple program.

.. code-block:: lua

    #!/usr/bin/env tarantool

    print('Hello, World!')

.. _cookbook-console-start:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
console_start.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use :ref:`box.once() <box-once>` to initialize a database
(creating spaces) if this is the first time the server has been run.
Then use :ref:`console.start() <console-start>` to start interactive mode.

.. code-block:: lua

    #!/usr/bin/env tarantool

    -- Configure database
    box.cfg {
        listen = 3313
    }

    box.once("bootstrap", function()
        box.schema.space.create('tweedledum')
        box.space.tweedledum:create_index('primary',
            { type = 'TREE', parts = {1, 'unsigned'}})
    end)

    require('console').start()

.. _cookbook-fio_read:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fio_read.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the :ref:`fio module <fio-module>` to open, read, and close a file.

.. code-block:: lua

    #!/usr/bin/env tarantool

    local fio = require('fio')
    local errno = require('errno')
    local f = fio.open('/tmp/xxxx.txt', {'O_RDONLY' })
    if not f then
        error("Failed to open file: "..errno.strerror())
    end
    local data = f:read(4096)
    f:close()
    print(data)

.. _cookbook-fio_write:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fio_write.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the :ref:`fio module <fio-module>` to open, write, and close a file.

.. code-block:: lua

    #!/usr/bin/env tarantool

    local fio = require('fio')
    local errno = require('errno')
    local f = fio.open('/tmp/xxxx.txt', {'O_CREAT', 'O_WRONLY', 'O_APPEND'},
        tonumber('0666', 8))
    if not f then
        error("Failed to open file: "..errno.strerror())
    end
    f:write("Hello\n");
    f:close()

.. _cookbook-ffi_printf:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ffi_printf.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the `LuaJIT ffi library <http://luajit.org/ext_ffi.html>`_ to call a C built-in function: printf().
(For help understanding ffi, see the `FFI tutorial <http://luajit.org/ext_ffi_tutorial.html>`_.)

.. code-block:: lua

    #!/usr/bin/env tarantool

    local ffi = require('ffi')
    ffi.cdef[[
        int printf(const char *format, ...);
    ]]

    ffi.C.printf("Hello, %s\n", os.getenv("USER"));

.. _cookbook-ffi_gettimeofday:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ffi_gettimeofday.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the `LuaJIT ffi library <http://luajit.org/ext_ffi.html>`_ to call a C function: gettimeofday().
This delivers time with millisecond precision, unlike the time function in
Tarantool's :ref:`clock module <clock-module>`.

.. code-block:: lua

    #!/usr/bin/env tarantool

    local ffi = require('ffi')
    ffi.cdef[[
        typedef long time_t;
        typedef struct timeval {
        time_t tv_sec;
        time_t tv_usec;
    } timeval;
        int gettimeofday(struct timeval *t, void *tzp);
    ]]

    local timeval_buf = ffi.new("timeval")
    local now = function()
        ffi.C.gettimeofday(timeval_buf, nil)
        return tonumber(timeval_buf.tv_sec * 1000 + (timeval_buf.tv_usec / 1000))
    end

.. _cookbook-ffi_zlib:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ffi_zlib.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the `LuaJIT ffi library <http://luajit.org/ext_ffi.html>`_ to call a C library function.
(For help understanding ffi, see the `FFI tutorial <http://luajit.org/ext_ffi_tutorial.html>`_.)

.. code-block:: lua

    #!/usr/bin/env tarantool

    local ffi = require("ffi")
    ffi.cdef[[
        unsigned long compressBound(unsigned long sourceLen);
        int compress2(uint8_t *dest, unsigned long *destLen,
        const uint8_t *source, unsigned long sourceLen, int level);
        int uncompress(uint8_t *dest, unsigned long *destLen,
        const uint8_t *source, unsigned long sourceLen);
    ]]
    local zlib = ffi.load(ffi.os == "Windows" and "zlib1" or "z")

    -- Lua wrapper for compress2()
    local function compress(txt)
        local n = zlib.compressBound(#txt)
        local buf = ffi.new("uint8_t[?]", n)
        local buflen = ffi.new("unsigned long[1]", n)
        local res = zlib.compress2(buf, buflen, txt, #txt, 9)
        assert(res == 0)
        return ffi.string(buf, buflen[0])
    end

    -- Lua wrapper for uncompress
    local function uncompress(comp, n)
        local buf = ffi.new("uint8_t[?]", n)
        local buflen = ffi.new("unsigned long[1]", n)
        local res = zlib.uncompress(buf, buflen, comp, #comp)
        assert(res == 0)
        return ffi.string(buf, buflen[0])
    end

    -- Simple test code.
    local txt = string.rep("abcd", 1000)
    print("Uncompressed size: ", #txt)
    local c = compress(txt)
    print("Compressed size: ", #c)
    local txt2 = uncompress(c, #txt)
    assert(txt2 == txt)

.. _cookbook-ffi_meta:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ffi_meta.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the `LuaJIT ffi library <http://luajit.org/ext_ffi.html>`_ to
access a C object via a metamethod (a method which is defined with
a metatable).

.. code-block:: lua

    #!/usr/bin/env tarantool

    local ffi = require("ffi")
    ffi.cdef[[
    typedef struct { double x, y; } point_t;
    ]]

    local point
    local mt = {
      __add = function(a, b) return point(a.x+b.x, a.y+b.y) end,
      __len = function(a) return math.sqrt(a.x*a.x + a.y*a.y) end,
      __index = {
        area = function(a) return a.x*a.x + a.y*a.y end,
      },
    }
    point = ffi.metatype("point_t", mt)

    local a = point(3, 4)
    print(a.x, a.y)  --> 3  4
    print(#a)        --> 5
    print(a:area())  --> 25
    local b = a + point(0.5, 8)
    print(#b)        --> 12.5

.. _cookbook-print_arrays:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
print_arrays.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create Lua tables, and print them.
Notice that for the 'array' table the iterator function
is ipairs(), while for the 'map' table the iterator function
is pairs(). (`ipairs()` is faster than `pairs()`, but pairs()
is recommended for map-like tables or mixed tables.)
The display will look like:
"1 Apple | 2 Orange | 3 Grapefruit | 4 Banana | k3 v3 | k1 v1 | k2 v2".

.. code-block:: lua

    #!/usr/bin/env tarantool

    array = { 'Apple', 'Orange', 'Grapefruit', 'Banana'}
    for k, v in ipairs(array) do print(k, v) end

    map = { k1 = 'v1', k2 = 'v2', k3 = 'v3' }
    for k, v in pairs(map) do print(k, v) end

.. _cookbook-count_array:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
count_array.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the '#' operator to get the number of items in an array-like Lua table.
This operation has O(log(N)) complexity.

.. code-block:: lua

    #!/usr/bin/env tarantool

    array = { 1, 2, 3}
    print(#array)

.. _cookbook-count_array_with_nils:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
count_array_with_nils.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Missing elements in arrays, which Lua treats as "nil"s,
cause the simple "#" operator to deliver improper results.
The "print(#t)" instruction will print "4";
the "print(counter)" instruction will print "3";
the "print(max)" instruction will print "10".
Other table functions, such as :ref:`table.sort() <table-sort>`, will
also misbehave when "nils" are present.

.. code-block:: lua

    #!/usr/bin/env tarantool

    local t = {}
    t[1] = 1
    t[4] = 4
    t[10] = 10
    print(#t)
    local counter = 0
    for k,v in pairs(t) do counter = counter + 1 end
    print(counter)
    local max = 0
    for k,v in pairs(t) do if k > max then max = k end end
    print(max)

.. _cookbook-count_array_with_nulls:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
count_array_with_nulls.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use explicit ``NULL`` values to avoid the problems caused by Lua's
nil == missing value behavior. Although :code:`json.NULL == nil` is
:code:`true`, all the print instructions in this program will print
the correct value: 10.

.. code-block:: lua

    #!/usr/bin/env tarantool

    local json = require('json')
    local t = {}
    t[1] = 1; t[2] = json.NULL; t[3]= json.NULL;
    t[4] = 4; t[5] = json.NULL; t[6]= json.NULL;
    t[6] = 4; t[7] = json.NULL; t[8]= json.NULL;
    t[9] = json.NULL
    t[10] = 10
    print(#t)
    local counter = 0
    for k,v in pairs(t) do counter = counter + 1 end
    print(counter)
    local max = 0
    for k,v in pairs(t) do if k > max then max = k end end
    print(max)

.. _cookbook-count_map:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
count_map.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Get the number of elements in a map-like table.

.. code-block:: lua

    #!/usr/bin/env tarantool

    local map = { a = 10, b = 15, c = 20 }
    local size = 0
    for _ in pairs(map) do size = size + 1; end
    print(size)

.. _cookbook-swap:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
swap.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use a Lua peculiarity to swap two variables without needing a third variable.

.. code-block:: lua

    #!/usr/bin/env tarantool

    local x = 1
    local y = 2
    x, y = y, x
    print(x, y)

.. _cookbook-class:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
class.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Create a class, create a metatable for the class, create an instance of the class.
Another illustration is at `http://lua-users.org/wiki/LuaClassesWithMetatable
<http://lua-users.org/wiki/LuaClassesWithMetatable>`_.

.. code-block:: lua

    #!/usr/bin/env tarantool

    -- define class objects
    local myclass_somemethod = function(self)
        print('test 1', self.data)
    end

    local myclass_someothermethod = function(self)
        print('test 2', self.data)
    end

    local myclass_tostring = function(self)
        return 'MyClass <'..self.data..'>'
    end

    local myclass_mt = {
        __tostring = myclass_tostring;
        __index = {
            somemethod = myclass_somemethod;
            someothermethod = myclass_someothermethod;
        }
    }

    -- create a new object of myclass
    local object = setmetatable({ data = 'data'}, myclass_mt)
    print(object:somemethod())
    print(object.data)

.. _cookbook-garbage:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
garbage.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Activate the `Lua garbage collector <https://www.lua.org/manual/5.1/manual.html#2.10>`_
with the `collectgarbage function <https://www.lua.org/manual/5.1/manual.html#pdf-collectgarbage>`_.

.. code-block:: lua

    #!/usr/bin/env tarantool

    collectgarbage('collect')

.. _cookbook-fiber_producer_and_consumer:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
fiber_producer_and_consumer.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Start one fiber for producer and one fiber for consumer.
Use :ref:`fiber.channel() <fiber_ipc-channel>` to exchange data and synchronize.
One can tweak the channel size (:code:`ch_size` in the program code)
to control the number of simultaneous tasks waiting for processing.

.. code-block:: lua

    #!/usr/bin/env tarantool

    local fiber = require('fiber')
    local function consumer_loop(ch, i)
        -- initialize consumer synchronously or raise an error()
        fiber.sleep(0) -- allow fiber.create() to continue
        while true do
            local data = ch:get()
            if data == nil then
                break
            end
            print('consumed', i, data)
            fiber.sleep(math.random()) -- simulate some work
        end
    end

    local function producer_loop(ch, i)
        -- initialize consumer synchronously or raise an error()
        fiber.sleep(0) -- allow fiber.create() to continue
        while true do
            local data = math.random()
            ch:put(data)
            print('produced', i, data)
        end
    end

    local function start()
        local consumer_n = 5
        local producer_n = 3

        -- Create a channel
        local ch_size = math.max(consumer_n, producer_n)
        local ch = fiber.channel(ch_size)

        -- Start consumers
        for i=1, consumer_n,1 do
            fiber.create(consumer_loop, ch, i)
        end

        -- Start producers
        for i=1, producer_n,1 do
            fiber.create(producer_loop, ch, i)
        end
    end

    start()
    print('started')

.. _cookbook-socket_tcpconnect:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
socket_tcpconnect.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use :ref:`socket.tcp_connect() <socket-tcp_connect>`
to connect to a remote host via TCP.
Display the connection details and the result of a GET request.

.. code-block:: lua

    #!/usr/bin/env tarantool

    local s = require('socket').tcp_connect('google.com', 80)
    print(s:peer().host)
    print(s:peer().family)
    print(s:peer().type)
    print(s:peer().protocol)
    print(s:peer().port)
    print(s:write("GET / HTTP/1.0\r\n\r\n"))
    print(s:read('\r\n'))
    print(s:read('\r\n'))

.. _cookbook-socket_tcp_echo:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
socket_tcp_echo.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use :ref:`socket.tcp_connect() <socket-tcp_connect>`
to set up a simple TCP server, by creating
a function that handles requests and echos them,
and passing the function to
:ref:`socket.tcp_server() <socket-tcp_server>`.
This program has been used to test with 100,000 clients,
with each client getting a separate fiber.

.. code-block:: lua

    #!/usr/bin/env tarantool

    local function handler(s, peer)
        s:write("Welcome to test server, " .. peer.host .."\n")
        while true do
            local line = s:read('\n')
            if line == nil then
                break -- error or eof
            end
            if not s:write("pong: "..line) then
                break -- error or eof
            end
        end
    end

    local server, addr = require('socket').tcp_server('localhost', 3311, handler)

.. _cookbook-getaddrinfo:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
getaddrinfo.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use :ref:`socket.getaddrinfo() <socket-getaddrinfo>` to perform
non-blocking DNS resolution, getting both the AF_INET6 and AF_INET
information for 'google.com'.
This technique is not always necessary for tcp connections because
:ref:`socket.tcp_connect() <socket-tcp_connect>`
performs `socket.getaddrinfo` under the hood,
before trying to connect to the first available address.

.. code-block:: lua

    #!/usr/bin/env tarantool

    local s = require('socket').getaddrinfo('google.com', 'http', { type = 'SOCK_STREAM' })
    print('host=',s[1].host)
    print('family=',s[1].family)
    print('type=',s[1].type)
    print('protocol=',s[1].protocol)
    print('port=',s[1].port)
    print('host=',s[2].host)
    print('family=',s[2].family)
    print('type=',s[2].type)
    print('protocol=',s[2].protocol)
    print('port=',s[2].port)

.. _cookbook-socket_udp_echo:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
socket_udp_echo.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tarantool does not currently have a `udp_server` function,
therefore socket_udp_echo.lua is more complicated than
socket_tcp_echo.lua.
It can be implemented with sockets and fibers.

.. code-block:: lua

    #!/usr/bin/env tarantool

    local socket = require('socket')
    local errno = require('errno')
    local fiber = require('fiber')

    local function udp_server_loop(s, handler)
        fiber.name("udp_server")
        while true do
            -- try to read a datagram first
            local msg, peer = s:recvfrom()
            if msg == "" then
                -- socket was closed via s:close()
                break
            elseif msg ~= nil then
                -- got a new datagram
                handler(s, peer, msg)
            else
                if s:errno() == errno.EAGAIN or s:errno() == errno.EINTR then
                    -- socket is not ready
                    s:readable() -- yield, epoll will wake us when new data arrives
                else
                    -- socket error
                    local msg = s:error()
                    s:close() -- save resources and don't wait GC
                    error("Socket error: " .. msg)
                end
            end
        end
    end

    local function udp_server(host, port, handler)
        local s = socket('AF_INET', 'SOCK_DGRAM', 0)
        if not s then
            return nil -- check errno:strerror()
        end
        if not s:bind(host, port) then
            local e = s:errno() -- save errno
            s:close()
            errno(e) -- restore errno
            return nil -- check errno:strerror()
        end

        fiber.create(udp_server_loop, s, handler) -- start a new background fiber
        return s
    end

A function for a client that connects to this server could
look something like this ...

.. code-block:: lua

    local function handler(s, peer, msg)
        -- You don't have to wait until socket is ready to send UDP
        -- s:writable()
        s:sendto(peer.host, peer.port, "Pong: " .. msg)
    end

    local server = udp_server('127.0.0.1', 3548, handler)
    if not server then
        error('Failed to bind: ' .. errno.strerror())
    end

    print('Started')

    require('console').start()

.. _cookbook-http_get:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
http_get.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the :ref:`http module <http-module>`
to get data via HTTP.

.. code-block:: lua

    #!/usr/bin/env tarantool

    local http_client = require('http.client')
    local json = require('json')
    local r = http_client.get('http://api.openweathermap.org/data/2.5/weather?q=Oakland,us')
    if r.status ~= 200 then
        print('Failed to get weather forecast ', r.reason)
        return
    end
    local data = json.decode(r.body)
    print('Oakland wind speed: ', data.wind.speed)

.. _cookbook-http_send:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
http_send.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the :ref:`http module <http-module>`
to send data via HTTP.

.. code-block:: lua

    #!/usr/bin/env tarantool

    local http_client = require('http.client')
    local json = require('json')
    local data = json.encode({ Key = 'Value'})
    local headers = { Token = 'xxxx', ['X-Secret-Value'] = 42 }
    local r = http_client.post('http://localhost:8081', data, { headers = headers})
    if r.status == 200 then
        print 'Success'
    end

.. _cookbook-http_server:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
http_server.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the `http`_ `rock`_ (which must first be installed)
to turn Tarantool into a web server.

.. code-block:: lua

    #!/usr/bin/env tarantool

    local function handler(self)
        return self:render{ json = { ['Your-IP-Is'] = self.peer.host } }
    end

    local server = require('http.server').new(nil, 8080) -- listen *:8080
    server:route({ path = '/' }, handler)
    server:start()
    -- connect to localhost:8080 and see json

.. _cookbook-generate_html:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
http_generate_html.lua
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Use the `http`_ `rock` (which must first be installed)
to generate HTML pages from templates.
The `http`_ `rock`_ has a fairly simple template engine which allows execution
of regular Lua code inside text blocks (like PHP). Therefore there is no need
to learn new languages in order to write templates.

.. code-block:: lua

    #!/usr/bin/env tarantool

    local function handler(self)
    local fruits = { 'Apple', 'Orange', 'Grapefruit', 'Banana'}
        return self:render{ fruits = fruits }
    end

    local server = require('http.server').new(nil, 8080) -- nil means '*'
    server:route({ path = '/', file = 'index.html.lua' }, handler)
    server:start()

An "HTML" file for this server, including Lua, could look like this
(it would produce "1 Apple | 2 Orange | 3 Grapefruit | 4 Banana").

.. code-block:: bash

    <html>
    <body>
        <table border="1">
            % for i,v in pairs(fruits) do
            <tr>
                <td><%= i %></td>
                <td><%= v %></td>
            </tr>
            % end
        </table>
    </body>
    </html>

.. _cookbook-select-all-go:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
select_all.go
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In Go, there is no one-liner to select all tuples from a Tarantool space.
Yet you can use a script like this one. Call it on the instance you want to
connect to.

.. literalinclude:: cookbook/main.go
  :language: go

.. _rock: http://rocks.tarantool.org/
.. _http: https://github.com/tarantool/http/
.. _nginx-tarantool-upstream: https://github.com/tarantool/nginx_upstream_module
