:orphan:
:priority: 0.99

----------------
Tarantool - OS X
----------------

.. container:: p-download

    .. include:: header.rst

    .. container:: b-os-installation-body

        .. container:: b-os-installation-menu

            .. include:: menu.rst

        .. wp_section::
          :title: OS X
          :class: b-os-installation-content

          You can install Tarantool using ``homebrew``:

          .. code-block:: bash

              $ brew install tarantool --HEAD
              ==> Cloning https://github.com/tarantool/tarantool.git
              Updating /Users/Me/Library/Caches/Homebrew/tarantool--git
              ==> Checking out branch 1.7
              Synchronizing submodule url for 'lib/msgpack-python'
              Synchronizing submodule url for 'lib/tarantool-python'
              ==> cmake . -DCMAKE_C_FLAGS_RELEASE=-DNDEBUG
                          -DCMAKE_CXX_FLAGS_RELEASE=-DNDEBUG
                          -DCMAKE_INSTALL_PREFIX=/usr/local/Cellar/tarantool/HEAD
                          -DCMAKE_BUILD_TYPE=Release
                          -DCMAKE_FIND_FRAMEWORK=LAST
                          -DCMAKE_VERBOSE_MAKEFILE=ON
                          -Wno-dev -DCMAKE_INSTALL_MANDIR=/usr/share/man
              ==> make
              ==> make install
              /usr/local/Cellar/tarantool/HEAD: 17 files, 2.2M, built in 1 minute 7 seconds
