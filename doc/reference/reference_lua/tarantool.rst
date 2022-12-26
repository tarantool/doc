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
    - version: 2.10.4-0-g816000e
      build:
        target: Darwin-x86_64-Release
        options: cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/Cellar/tarantool/2.10.4 -DENABLE_BACKTRACE=ON
        linking: dynamic
        mod_format: dylib
        flags: ' -fexceptions -funwind-tables -fno-common -fopenmp -msse2 -Wformat -Wformat-security
          -Werror=format-security -fstack-protector-strong -fPIC -fmacro-prefix-map=/tmp/tarantool-20221113-6655-1clb1lj/tarantool-2.10.4=.
          -std=c11 -Wall -Wextra -Wno-strict-aliasing -Wno-char-subscripts -Wno-format-truncation
          -Wno-gnu-alignof-expression -Wno-cast-function-type'
        compiler: Clang-14.0.0.14000029
      pid: 'function: 0x0102df34f8'
      package: Tarantool
      uptime: 'function: 0x0102df34c0'
    ...
    tarantool> tarantool.pid()
    ---
    - 30155
    ...
    tarantool> tarantool.uptime()
    ---
    - 108.64641499519
    ...
