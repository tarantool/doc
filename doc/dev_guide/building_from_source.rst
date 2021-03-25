.. _building_from_source:

-------------------------------------------------------------------------------
                             Building from source
-------------------------------------------------------------------------------

For downloading Tarantool source and building it, the platforms can differ and
the preferences can differ. But strategically the steps are always the same:

1.  Get tools and libraries that will be necessary for building
    and testing:

    *   A program for downloading source repositories.

        For all platforms, this is ``git``. It allows downloading the latest
        complete set of source files from the Tarantool repository on GitHub.

    *   A C/C++ compiler.

        Ordinarily, this is ``gcc`` and ``g++`` version 4.6 or later.
        On Mac OS X, this is ``Clang`` version 3.2+.

    *   cmake

    *   autoconf automake libtool

    *   make

    *   Python and modules.

        Python interpreter is not necessary for building Tarantool itself, unless you
        intend to use the “Run the test suite". For all platforms, this is python
        version 3.x. You need the following Python modules:

        *   pyyaml
        *   gevent
        *   six

    To install all required dependencies, follow the instructions for your OS:

    *   For Debian/Ubuntu, say:

        ..  code-block:: console

            $ apt-get install -y \
              git build-essential cmake make coreutils autoconf automake libtool sed \
              python3 python3-yaml python3-six python3-gevent

    *   For RHEL/CentOS (versions under 8)/Fedora, say:

        ..  code-block:: console

            $ yum install -y \
              git perl gcc cmake make gcc-c++ libstdc++-static autoconf automake libtool \
              python3-yaml python3-six python3-gevent

    *   For CentOS 8, say:

        ..  code-block:: console

            $ yum install epel-release
            $ curl -s https://packagecloud.io/install/repositories/packpack/backports/script.rpm.sh | sudo bash
            $ yum install -y \
              git perl gcc cmake make gcc-c++ libstdc++-static autoconf automake libtool \
              python3-yaml python3-six python3-gevent

    *   For Mac OS X:

        Before you start please install default Xcode Tools by Apple:

        ..  code-block:: console

            $ xcode-select --install
            $ xcode-select -switch /Applications/Xcode.app/Contents/Developer

        Install brew using command from
        `Homebrew repository instructions <https://github.com/Homebrew/inst>`_.

        After that run next script:

        ..  code-block:: console

            $ brew install autoconf automake libtool cmake
            $ pip --user -r test-run/requirements.txt

        ..  NOTE::

            Read how to manually build tarantool using external package managers
            (Homebrew or MacPorts) for Mac OS on
            `GitHub <https://github.com/tarantool/tarantool/blob/master/README.MacOSX>`_.

    *   For FreeBSD (instructions below are for FreeBSD 10.4+ release
        and FreeBSD 11 release), say:

        ..  code-block:: console

            $ pkg install git cmake gmake readline icu \
              python27 py27-yaml py27-daemon py27-msgpack

    If some Python modules are not available in a repository,
    it is best to set up the modules by getting a tarball and
    doing the setup with ``python setup.py`` like this:

    ..  code-block:: console

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

    Finally, use Python ``pip`` to bring in Python packages that may not be
    up-to-date in the distro repositories. (On CentOS 7, it will be necessary
    to install ``pip`` first:

    ..  code-block:: console

        $ sudo yum install epel-release
        $ sudo yum install python-pip
        $ pip install --user --force-reinstall -r test-run/requirements.txt

    This step is only necessary once, the first time you do a download.

2.  Use ``git`` to download the latest Tarantool source code from the
    GitHub repository ``tarantool/tarantool``, branch ``master``, to a
    local directory named ``~/tarantool``, for example:

    ..  code-block:: console

        $ git clone https://github.com/tarantool/tarantool.git --recursive

    Update submodules:

    ..  code-block:: console

        $ cd ~/tarantool
        $ git submodule update --init --recursive

3.  Use CMake to initiate the build:

    ..  code-block:: console

        $ cd ~/tarantool
        $ make clean         # unnecessary, added for good luck
        $ rm CMakeCache.txt  # unnecessary, added for good luck
        $ cmake .            # start initiating with build type=Debug

    On some platforms, it may be necessary to specify the C and C++ versions,
    for example:

    ..  code-block:: console

        $ CC=gcc-4.8 CXX=g++-4.8 cmake .

    The CMake option for specifying build type is :samp:`-DCMAKE_BUILD_TYPE={type}`,
    where :samp:`{type}` can be:

   * ``Debug`` -- used by project maintainers
   * ``RelWithDebInfo`` -- used for production, also provides debugging capabilities

    The CMake option for hinting that the result will be distributed is
    :code:`-DENABLE_DIST=ON`. If this option is on, then later ``make install``
    will install ``tarantoolctl`` files in addition to ``tarantool`` files.

4.  Use ``make`` to complete the build.

    ..  code-block:: console

        $ make

    ..  NOTE::

        For FreeBSD, use ``gmake`` instead.

    This creates the 'tarantool' executable in the ``src/`` directory.

    ..  NOTE::

        If you encounter a ``curl`` or ``OpenSSL`` errors on this step try
        installing ``openssl111`` package of the specific ``1.1.1d`` version.

    Next, it's highly recommended to say ``make install`` to install Tarantool to
    the ``/usr/local`` directory and keep your system clean. However, it is
    possible to run the Tarantool executable without installation.

..  _run_test_suite:

5.  Run the test suite.

    This step is optional. Tarantool's developers always run the test suite
    before they publish new versions. You should run the test suite too, if you
    make any changes in the code. Assuming you downloaded to ``~/tarantool``, say:

    ..  code-block:: console

        $ make test

6.  Make RPM and Debian packages.

    This step is optional. It's only for people who want to redistribute
    Tarantool. We highly recommend to use official packages from the
    `tarantool.org <https://tarantool.org/download.html>`_ web-site.
    However, you can build RPM and Debian packages using
    `PackPack <https://github.com/packpack/packpack>`_. Consult
    `Build RPM or Deb package using packpack
    <https://github.com/tarantool/tarantool/wiki/Build-RPM-or-Deb-package-using-packpack>`_
    for details.

7.  Verify your Tarantool installation:

    .. code-block:: bash

        $ # if you installed tarantool locally after build
        $ tarantool
        $ # - OR -
        $ # if you didn't install tarantool locally after build
        $ ./src/tarantool

    This starts Tarantool in the interactive mode.

See also:

* `Tarantool README.md <https://github.com/tarantool/tarantool/blob/master/README.md>`_

