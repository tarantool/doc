.. _tarantool-module:

-------------------------------------------------------------------------------
                            Module tarantool
-------------------------------------------------------------------------------

.. module:: tarantool

By saying ``require('tarantool')``, one can answer some questions about how the
tarantool server was built, such as "what flags were used", or "what was the
version of the compiler".

.. _tarantool-build:

Additionally one can see the uptime and the server version and the process id.
Those information items can also be accessed with :ref:`box.info()
<box_introspection-box_info>` but use of
the tarantool module is recommended.

**Example:**

.. code-block:: tarantoolsession

    tarantool> tarantool = require('tarantool')
    ---
    ...
    tarantool> tarantool
    ---
    - version: 2.4.0-35-g57f6fc932
      build:
        target: Linux-x86_64-RelWithDebInfo
        options: cmake . -DCMAKE_INSTALL_PREFIX=/opt/tarantool-install
    -DENABLE_BACKTRACE=ON
        mod_format: so
        flags: ' -fexceptions -funwind-tables -fno-omit-frame-pointer
    -fno-stack-protector
          -fno-common -fopenmp -msse2 -std=c11 -Wall -Wextra
    -Wno-strict-aliasing -Wno-char-subscripts
          -Wno-format-truncation -fno-gnu89-inline -Wno-cast-function-type'
        compiler: /usr/bin/cc /usr/bin/c++
      pid: 'function: 0x40016cd0'
      package: Tarantool
      uptime: 'function: 0x40016cb0'
    ...
    tarantool> tarantool.pid()
    ---
    - 30155
    ...
    tarantool> tarantool.uptime()
    ---
    - 108.64641499519
    ...
