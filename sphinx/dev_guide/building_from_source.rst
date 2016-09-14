.. _building_from_source:

-------------------------------------------------------------------------------
                             Building from source
-------------------------------------------------------------------------------

For downloading Tarantool source and building it, the platforms can differ and the
preferences can differ. But the steps are always the same. Here in the manual we'll
explain what the steps are, and after that you can look at some example scripts
on the Internet.

1. Get tools and libraries that will be necessary for building
   and testing.
   
   The absolutely necessary ones are:

   * A program for downloading source repositories. |br| 
     For all platforms, this is ``git``. It allows to download the latest
     complete set of source files from the Tarantool repository at GitHub.

   * A C/C++ compiler. |br| Ordinarily, this is ``gcc`` and ``g++`` version
     4.6 or later. On Mac OS X, this is ``Clang`` version 3.2 or later.

   * A program for managing the build process. |br| For all platforms, this is
     ``CMake``. The CMake version should be 2.8 or later.
     
   * Command-line interpreter for Python-based code (namely, for Tarantool test
     suite). |br| For all platforms, this is ``python``. The Python version
     should be greater than 2.6 -- preferably 2.7 -- and less than 3.0.  

   Here are names of tools and libraries which may have to be installed in advance,
   using ``sudo apt-get`` (for Ubuntu), ``sudo yum install`` (for CentOS), or the
   equivalent on other platforms. Different platforms may use slightly different
   names. Ignore the ones marked `optional, only in Mac OS scripts`
   unless the platform is Mac OS.

   * **gcc** and **g++**, or **clang**        # see above
   * **git**                                  # see above
   * **cmake**                                # see above
   * **python**                               # see above; for test suite
   * **libreadline-dev** or **libreadline6-dev** or **readline-devel**  # for interactive mode
   * **libssl-dev**                           # for `digest` module
   * **autoconf**                             # optional, only in Mac OS scripts
   * **zlib1g** or **zlib**                   # optional, only in Mac OS scripts

2. Set up Python modules for running the test suite.

   This step is optional. Python modules are not necessary for building Tarantool
   itself, unless you intend to use the "Run the test suite" option in step 7. 
   
   You need the following Python modules:

   * `pip <https://pypi.python.org/pypi/pip>`_, any version
   * `dev <https://pypi.python.org/pypi/dev>`_, any version
   * `pyYAML <https://pypi.python.org/pypi/PyYAML>`_ version 3.10
   * `argparse <https://pypi.python.org/pypi/argparse>`_ version 1.1
   * `msgpack-python <https://pypi.python.org/pypi/msgpack-python>`_ version 0.4.6
   * `gevent <https://pypi.python.org/pypi/gevent>`_ version 1.1b5
   * `six <https://pypi.python.org/pypi/six>`_ version 1.8.0

   On Ubuntu, you can get the modules from the repository:

   .. code-block:: bash

     sudo apt-get install python-pip python-dev python-yaml <...>

   On CentOS 6, you can likewise get the modules from the repository:

   .. code-block:: bash

     sudo yum install python26 python26-PyYAML <...>

   If some modules are not available on a repository,
   it is best to set up the modules by getting a tarball and
   doing the setup with ``python setup.py``, thus:

   .. code-block:: bash

     # On some machines, this initial command may be necessary:
     # wget https://bootstrap.pypa.io/ez_setup.py -O - | sudo python

     # Python module for parsing YAML (pyYAML), for test suite:
     # (If wget fails, check at http://pyyaml.org/wiki/PyYAML
     # what the current version is.)
     cd ~
     wget http://pyyaml.org/download/pyyaml/PyYAML-3.10.tar.gz
     tar -xzf PyYAML-3.10.tar.gz
     cd PyYAML-3.10
     sudo python setup.py install

   Finally, use Python :code:`pip` to bring in Python packages
   that may not be up-to-date in the distro repositories.
   (On CentOS 7, it will be necessary to install ``pip`` first,
   with :code:`sudo yum install epel-release` followed by
   :code:`sudo yum install python-pip`.)

   .. code-block:: bash

     pip install tarantool\>0.4 --user

3. Use ``git`` to download the latest Tarantool source code from the
   GitHub repository ``tarantool/tarantool``, branch 1.7. For example, to a
   local directory named `~/tarantool`:
  
   .. code-block:: bash
   
     git clone https://github.com/tarantool/tarantool.git ~/tarantool

4. Use ``git`` again so that third-party contributions will be seen as well.

   The build depends on the following external libraries:

   * Readline development files (``libreadline-dev/readline-devel`` package).
   * OpenSSL development files (``libssl-dev/openssl-devel`` package).
   * ``libyaml`` (``libyaml-dev/libyaml-devel`` package).
   * ``liblz4`` (``liblz4-dev/lz4-devel`` package).
   * GNU ``bfd`` which is the part of GNU ``binutils``
     (``binutils-dev/binutils-devel`` package).
   
   This step is only necessary once, the first time you do a download.

   .. code-block:: bash

     cd ~/tarantool
     git submodule init
     git submodule update --recursive
     cd ../

   On rare occasions, the submodules will need to be updated again with the
   command:
   
   .. code-block:: bash
     
     git submodule update --init --recursive

   Note: There is an alternative -- to say ``git clone --recursive`` earlier in
   step 3, -- but we prefer the method above because it works with older
   versions of ``git``.

5. Use CMake to initiate the build.

   .. code-block:: bash

     cd ~/tarantool
     make clean         # unnecessary, added for good luck
     rm CMakeCache.txt  # unnecessary, added for good luck
     cmake .            # start initiating with build type=Debug

   On some platforms, it may be necessary to specify the C and C++ versions,
   for example:
   
   .. code-block:: bash
      
     CC=gcc-4.8 CXX=g++-4.8 cmake .
   
   The CMake option for specifying build type is :samp:`-DCMAKE_BUILD_TYPE={type}`,
   where :samp:`{type}` can be:
   
   * ``Debug`` -- used by project maintainers
   * ``Release`` -- used only if the highest performance is required
   * ``RelWithDebInfo`` -- used for production, also provides debugging capabilities

   The CMake option for hinting that the result will be distributed is 
   :code:`-DENABLE_DIST=ON`. If this option is on, then later ``make install`` 
   will install tarantoolctl files in addition to tarantool files.

6. Use ``make`` to complete the build.

   .. code-block:: bash

     make

   This creates the 'tarantool' executable in the directory `src/`

   Next, it's highly recommended to say ``make install`` to install Tarantool to
   the `/usr/local` directory and keep your system clean. However, it is
   possible to run the Tarantool executable without installation.

7. Run the test suite.

   This step is optional. Tarantool's developers always run the test suite
   before they publish new versions. You should run the test suite too, if you
   make any changes in the code. Assuming you downloaded to ``~/tarantool``, the
   principal steps are:

   .. code-block:: bash

     # make a subdirectory named `bin`
     mkdir ~/tarantool/bin
     # link python to bin (this may require superuser privilege)
     ln /usr/bin/python ~/tarantool/bin/python
     # get on the test subdirectory
     cd ~/tarantool/test
     # run tests using python
     PATH=~/tarantool/bin:$PATH ./test-run.py

   The output should contain reassuring reports, for example:

   .. code-block:: bash

     ======================================================================
     TEST                                            RESULT
     ------------------------------------------------------------
     box/bad_trigger.test.py                         [ pass ]
     box/call.test.py                                [ pass ]
     box/iproto.test.py                              [ pass ]
     box/xlog.test.py                                [ pass ]
     box/admin.test.lua                              [ pass ]
     box/auth_access.test.lua                        [ pass ]
     ... etc.

   To prevent later confusion, clean up what's in the `bin` subdirectory:

   .. code-block:: bash

     rm ~/tarantool/bin/python
     rmdir ~/tarantool/bin

8. Make an rpm package.

   This step is optional. It's only for people who want to redistribute
   Tarantool. Package maintainers who want to build with ``rpmbuild`` should
   consult the ``rpm-build`` instructions for the appropriate platform.

9. Verify your Tarantool installation.

   .. code-block:: bash

     tarantool $ ./src/tarantool

   This will start Tarantool in the interactive mode.

For your added convenience, we provide OS-specific README files with example
scripts at GitHub:

* `README.FreeBSD <https://github.com/tarantool/tarantool/blob/1.7/README.FreeBSD>`_ for FreeBSD 10.1

* `README.MacOSX <https://github.com/tarantool/tarantool/blob/1.7/README.MacOSX>`_ for Mac OS X `El Capitan`

* `README.md <https://github.com/tarantool/tarantool/blob/1.7/README.md>`_ for generic GNU/Linux

These example scripts assume that the intent is to download from the 1.7
branch, build the server and run tests after build.
