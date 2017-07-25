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

   * `ReadLine <http://www.gnu.org/software/readline/>`_ library, any version
   * `ncurses <https://www.gnu.org/software/ncurses/>`_ library, any version
   * `OpenSSL <https://www.openssl.org>`_ library, version 1.0.1+
   * `cURL <https://curl.haxx.se/>`_ library, version 0.725+
   * `LibYAML <http://pyyaml.org/wiki/LibYAML>`_ library, version 0.1.4+

   * Python and modules. |br| Python interpreter is not necessary for building
     Tarantool itself, unless you intend to use the "Run the test suite"
     option in step 5. For all platforms, this is ``python``. The Python
     version should be greater 2.7 -- and less than 3.0. You need the
     following Python modules:
      + `pyYAML <https://pypi.python.org/pypi/PyYAML>`_ version 3.10
      + `argparse <https://pypi.python.org/pypi/argparse>`_ version 1.1
      + `msgpack-python <https://pypi.python.org/pypi/msgpack-python>`_ version 0.4.6
      + `gevent <https://pypi.python.org/pypi/gevent>`_ version 1.1.2
      + `six <https://pypi.python.org/pypi/six>`_ version 1.8.0

   On Debian/Ubuntu distributions you can use the command below to install
   all required dependencies:

   .. code-block:: bash

    apt install -y build-essential cmake coreutils sed \
        libreadline-dev libncurses5-dev libyaml-dev libssl-dev \
        libcurl4-openssl-dev libunwind-dev \
        python python-pip python-setuptools python-dev \
        python-msgpack python-yaml python-argparse python-six python-gevent

   On RHEL/CentOS/Fedora distributions you can use the command below to install
   all required dependencies:

   .. code-block:: bash

    yum install -y gcc gcc-c++ cmake coreutils sed \
        readline-devel ncurses-devel libyaml-devel openssl-devel \
        libcurl-devel libunwind-devel \
        python python-pip python-setuptools python-devel \
        python-msgpack python-yaml python-argparse python-six python-gevent

   If some Python modules are not available on a repository,
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

    pip install -r https://raw.githubusercontent.com/tarantool/test-run/master/requirements.txt --user

   This step is only necessary once, the first time you do a download.

2. Use ``git`` to download the latest Tarantool source code from the
   GitHub repository ``tarantool/tarantool``, branch 1.7. For example, to a
   local directory named `~/tarantool`:

   .. code-block:: bash

     git clone --recursive https://github.com/tarantool/tarantool.git -b 1.7 ~/tarantool

   On rare occasions, the submodules will need to be updated again with the
   command:

   .. code-block:: bash

     git submodule update --init --recursive

3. Use CMake to initiate the build.

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

4. Use ``make`` to complete the build.

   .. code-block:: bash

     make

   This creates the 'tarantool' executable in the directory `src/`

   Next, it's highly recommended to say ``make install`` to install Tarantool to
   the `/usr/local` directory and keep your system clean. However, it is
   possible to run the Tarantool executable without installation.

5. Run the test suite.

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

6. Make RPM and Debian packages.

   This step is optional. It's only for people who want to redistribute
   Tarantool. We highly recommend to use official packages from
   `tarantool.org <https://tarantool.org/download.html>`_ web-site.
   However, you can build RPM and Debian package using
   `PackPack <https://github.com/packpack/packpack`_ or using
   `dpkg-buildpackage` or `rpmbuild` tools. Please consult
   `dpkg` or `rpmbuild` documentation for details.

7. Verify your Tarantool installation.

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
