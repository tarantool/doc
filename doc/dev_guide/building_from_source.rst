.. _building_from_source:

-------------------------------------------------------------------------------
                             Building from source
-------------------------------------------------------------------------------

For downloading Tarantool source and building it, the platforms can differ and
the preferences can differ. But strategically the steps are always the same.

1. Get tools and libraries that will be necessary for building
   and testing.

   The absolutely necessary ones are:

   * A program for downloading source repositories. |br|
     For all platforms, this is ``git``. It allows downloading the latest
     complete set of source files from the Tarantool repository on GitHub.

   * A C/C++ compiler. |br| Ordinarily, this is ``gcc`` and ``g++`` version
     4.6 or later. On Mac OS X, this is ``Clang`` version 3.2+.

   * A program for managing the build process. |br| For all platforms, this is
     ``CMake`` version 2.8+.

   * A build automation tool. |br| For all platforms this is ``GNU Make``.

   * `ReadLine <http://www.gnu.org/software/readline/>`_ library, any version
   * `ncurses <https://www.gnu.org/software/ncurses/>`_ library, any version
   * `OpenSSL <https://www.openssl.org>`_ library, version 1.0.1+
   * `ICU <http://site.icu-project.org/download>`_ library, recent version
   * `Autoconf <https://www.gnu.org/software/autoconf/>`_ library, any version
   * `Automake <https://www.gnu.org/software/automake/>`_ library, any version
   * `Libtool <https://www.gnu.org/software/libtool/>`_ library, any version
   * `Zlib-devel <https://www.zlib.net/>`_ library, any version

   * Python and modules. |br| Python interpreter is not necessary for building
     Tarantool itself, unless you intend to use the "Run the test suite"
     option in step 5. For all platforms, this is ``python`` version 2.7+
     (but not 3.x). You need the following Python modules:

       * `pyyaml <https://pypi.python.org/pypi/PyYAML>`_ version 3.10
       * `argparse <https://pypi.python.org/pypi/argparse>`_ version 1.1
       * `msgpack-python <https://pypi.python.org/pypi/msgpack-python>`_ version 0.4.6
       * `gevent <https://pypi.python.org/pypi/gevent>`_ version 1.1.2
       * `six <https://pypi.python.org/pypi/six>`_ version 1.8.0

   To install all required dependencies, follow the instructions for your OS:

   * For Debian/Ubuntu, say:

     .. code-block:: console

        $ apt install -y build-essential cmake make coreutils sed \
              autoconf automake libtool zlib1g-dev \
              libreadline-dev libncurses5-dev libssl-dev \
              libunwind-dev libicu-dev \
              python python-pip python-setuptools python-dev \
              python-msgpack python-yaml python-argparse python-six python-gevent

   * For RHEL/CentOS/Fedora, say:

     .. code-block:: console

         $ yum install -y gcc gcc-c++ cmake make coreutils sed \
               autoconf automake libtool zlib-devel \
               readline-devel ncurses-devel openssl-devel \
               libunwind-devel libicu-devel \
               python python-pip python-setuptools python-devel \
               python-msgpack python-yaml python-argparse python-six python-gevent

   * For Mac OS X (instructions below are for OS X El Capitan):

     If you're using Homebrew as your package manager, say:

     .. code-block:: console

         $ brew install cmake make autoconf binutils zlib \
                autoconf automake libtool \
                readline ncurses openssl libunwind-headers icu4c \
                && pip install python-daemon \
                msgpack-python pyyaml configargparse six gevent

     .. NOTE::

         You can not install `zlib-devel <https://www.zlib.net/>`_  package this way.

     Alternatively, download Apple's default Xcode toolset:

     .. code-block:: console

         $ xcode-select --install
         $ xcode-select -switch /Applications/Xcode.app/Contents/Developer

   * For FreeBSD (instructions below are for FreeBSD 10.1+ release), say:

     .. code-block:: console

         $ pkg install -y sudo git cmake gmake gcc coreutils \
               autoconf automake libtool \
               readline ncurses openssl libunwind icu \
               python27 py27-pip py27-setuptools py27-daemon \
               py27-msgpack py27-yaml py27-argparse py27-six py27-gevent

   If some Python modules are not available in a repository,
   it is best to set up the modules by getting a tarball and
   doing the setup with ``python setup.py`` like this:

   .. code-block:: console

       $ # On some machines, this initial command may be necessary:
       $ wget https://bootstrap.pypa.io/ez_setup.py -O - | sudo python

       $ # Python module for parsing YAML (pyYAML), for test suite:
       $ # (If wget fails, check at http://pyyaml.org/wiki/PyYAML
       $ # what the current version is.)
       $ cd ~
       $ wget http://pyyaml.org/download/pyyaml/PyYAML-3.10.tar.gz
       $ tar -xzf PyYAML-3.10.tar.gz
       $ cd PyYAML-3.10
       $ sudo python setup.py install

   Finally, use Python ``pip`` to bring in Python packages
   that may not be up-to-date in the distro repositories.
   (On CentOS 7, it will be necessary to install ``pip`` first,
   with :code:`sudo yum install epel-release` followed by
   :code:`sudo yum install python-pip`.)

   .. code-block:: console

       $ pip install -r \
             https://raw.githubusercontent.com/tarantool/test-run/master/requirements.txt \
             --user

   This step is only necessary once, the first time you do a download.

2. Use ``git`` to download the latest Tarantool source code from the
   GitHub repository ``tarantool/tarantool``, branch 1.10, to a
   local directory named ``~/tarantool``, for example:

   .. code-block:: console

       $ git clone --recursive https://github.com/tarantool/tarantool.git -b 1.10 ~/tarantool

   On rare occasions, the submodules need to be updated again with the
   command:

   .. code-block:: console

       cd ~/tarantool
       $ git submodule update --init --recursive

3. Use CMake to initiate the build.

   .. code-block:: console

       $ cd ~/tarantool
       $ make clean         # unnecessary, added for good luck
       $ rm CMakeCache.txt  # unnecessary, added for good luck
       $ cmake .            # start initiating with build type=Debug

   On some platforms, it may be necessary to specify the C and C++ versions,
   for example:

   .. code-block:: console

       $ CC=gcc-4.8 CXX=g++-4.8 cmake .

   The CMake option for specifying build type is :samp:`-DCMAKE_BUILD_TYPE={type}`,
   where :samp:`{type}` can be:

   * ``Debug`` -- used by project maintainers
   * ``Release`` -- used only if the highest performance is required
   * ``RelWithDebInfo`` -- used for production, also provides debugging capabilities

   The CMake option for hinting that the result will be distributed is
   :code:`-DENABLE_DIST=ON`. If this option is on, then later ``make install``
   will install ``tarantoolctl`` files in addition to ``tarantool`` files.

4. Use ``make`` to complete the build.

   .. code-block:: console

       $ make

   .. NOTE::

       For FreeBSD, use ``gmake`` instead.

   This creates the 'tarantool' executable in the ``src/`` directory.

   .. NOTE::

       If you encounter a ``curl`` or ``OpenSSL`` errors on this step try
       installing ``openssl111`` package of the specific ``1.1.1d`` version.

   Next, it's highly recommended to say ``make install`` to install Tarantool to
   the ``/usr/local`` directory and keep your system clean. However, it is
   possible to run the Tarantool executable without installation.

.. _run_test_suite:

5. Run the test suite.

   This step is optional. Tarantool's developers always run the test suite
   before they publish new versions. You should run the test suite too, if you
   make any changes in the code. Assuming you downloaded to ``~/tarantool``, the
   principal steps are:

   .. code-block:: console

       $ # make a subdirectory named `bin`
       $ mkdir ~/tarantool/bin

       $ # link Python to bin (this may require superuser privileges)
       $ ln /usr/bin/python ~/tarantool/bin/python

       $ # get to the test subdirectory
       $ cd ~/tarantool/test

       $ # run tests using Python
       $ PATH=~/tarantool/bin:$PATH ./test-run.py

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

   To prevent later confusion, clean up what's in the ``bin`` subdirectory:

   .. code-block:: console

       $ rm ~/tarantool/bin/python
       $ rmdir ~/tarantool/bin

6. Make RPM and Debian packages.

   This step is optional. It's only for people who want to redistribute
   Tarantool. We highly recommend to use official packages from the
   `tarantool.org <https://tarantool.org/download.html>`_ web-site.
   However, you can build RPM and Debian packages using
   `PackPack <https://github.com/packpack/packpack>`_ or using the
   ``dpkg-buildpackage`` or ``rpmbuild`` tools. Please consult
   ``dpkg`` or ``rpmbuild`` documentation for details.

7. Verify your Tarantool installation.

   .. code-block:: bash

       $ # if you installed tarantool locally after build
       $ tarantool
       $ # - OR -
       $ # if you didn't install tarantool locally after build
       $ ./src/tarantool

   This starts Tarantool in the interactive mode.

See also:

* `Tarantool README.md <https://github.com/tarantool/tarantool/blob/1.10/README.md>`_
