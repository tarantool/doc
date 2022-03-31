(building-from-source)=

# Building to contribute

To build Tarantool from source files, you will need the following tools:

- Git

- GCC. Or Clang for Mac OS

- CMake 3.2+

- GNU Make

- [ReadLine](http://www.gnu.org/software/readline/), any version

- [ncurses](https://www.gnu.org/software/ncurses/), any version

- [OpenSSL](https://www.openssl.org), any version

- [ICU](http://site.icu-project.org/download), any version

- [Zlib-devel](https://www.zlib.net/), any version

- Python3 and modules:

  - pyyaml
  - gevent
  - six

## Quick build

To install all required dependencies, build Tarantool and run tests, choose
your OS and follow the instructions:

- {ref}`Ubuntu/Debian <building_from_source-ubuntu>`
- {ref}`Fedora <building_from_source-fedora>`
- {ref}`RHEL/CentOS 7 <building_from_source-centos>`
- {ref}`CentOS 8 <building_from_source-centos8>`
- {ref}`Mac OS <building_from_source-macos>`
- {ref}`FreeBSD <building_from_source-freebsd>`

Some additional steps might be useful:

- {ref}`-DENABLE_DIST=ON for tarantoolctl installation <building_from_source-tarantoolctl>`
- {ref}`Make RPM and Debian packages <building_from_source-rpm_packages>`
- {ref}`Verify your Tarantool installation <building_from_source-verify_tarantool>`

(building-from-source-ubuntu)=

(building-from-source-debian)=

### Ubuntu/Debian

```console
$ apt-get -y install git build-essential cmake make zlib1g-dev \
  libreadline-dev libncurses5-dev libssl-dev libunwind-dev libicu-dev \
  python3 python3-pyyaml python3-six python3-gevent

$ git clone https://github.com/tarantool/tarantool.git --recursive

$ cd tarantool

$ git submodule update --init --recursive

$ make clean         # unnecessary, added for good luck
$ rm CMakeCache.txt  # unnecessary, added for good luck

$ mkdir build && cd build

$ # start initiating with build type=RelWithDebInfo
$ cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo

$ make

$ make test
```

(building-from-source-fedora)=

### Fedora

```console
$ dnf install -y git gcc gcc-c++ cmake make readline-devel ncurses-devel \
  openssl-devel zlib-devel libunwind-devel libicu-devel \
  python3-pyyaml python3-six python3-gevent

$ git clone https://github.com/tarantool/tarantool.git --recursive

$ cd tarantool

$ git submodule update --init --recursive

$ make clean         # unnecessary, added for good luck
$ rm CMakeCache.txt  # unnecessary, added for good luck

$ mkdir build && cd build

$ # start initiating with build type=RelWithDebInfo
$ cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo

$ make

$ make test
```

(building-from-source-centos)=

### RHEL/CentOS 7

```console
$ yum install -y python-pip
$ yum install -y epel-release

$ curl -s https://packagecloud.io/install/repositories/packpack/backports/script.rpm.sh | bash

$ yum install -y git gcc cmake3 make gcc-c++ zlib-devel readline-devel \
  ncurses-devel openssl-devel libunwind-devel libicu-devel \
  python3-pyyaml python3-six python3-gevent

$ git clone https://github.com/tarantool/tarantool.git --recursive

$ cd tarantool

$ git submodule update --init --recursive

$ make clean         # unnecessary, added for good luck
$ rm CMakeCache.txt  # unnecessary, added for good luck

$ mkdir build && cd build

$ # start initiating with build type=RelWithDebInfo
$ cmake3 .. -DCMAKE_BUILD_TYPE=RelWithDebInfo

$ make

$ make test
```

(building-from-source-centos8)=

### CentOS 8

```console
$ dnf install -y epel-release

$ dnf install -y git gcc cmake3 libarchive make gcc-c++ zlib-devel \
  readline-devel ncurses-devel openssl-devel libunwind-devel libicu-devel \
  python3-pyyaml python3-six python3-gevent

$ git clone https://github.com/tarantool/tarantool.git --recursive

$ cd tarantool

$ git submodule update --init --recursive

$ make clean         # unnecessary, added for good luck
$ rm CMakeCache.txt  # unnecessary, added for good luck

$ mkdir build && cd build

$ # start initiating with build type=RelWithDebInfo
$ cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo

$ make

$ make test
```

(building-from-source-macos)=

### Mac OS

This instruction is for those who use Homebrew. Refer to
the [full instruction for Mac OS](https://github.com/tarantool/tarantool/blob/master/README.MacOSX)
if you use MacPorts.

```console
$ xcode-select --install
$ xcode-select -switch /Applications/Xcode.app/Contents/Developer

$ git clone https://github.com/tarantool/tarantool.git --recursive

$ cd tarantool

$ git submodule update --init --recursive

$ brew install git openssl readline curl icu4c libiconv zlib cmake

$ pip install --user -r test-run/requirements.txt

$ make clean         # unnecessary, added for good luck
$ rm CMakeCache.txt  # unnecessary, added for good luck

$ mkdir build && cd build

$ # start initiating with build type=RelWithDebInfo
$ cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo

$ make

$ make test
```

(building-from-source-freebsd)=

### FreeBSD

```console
$ git clone https://github.com/tarantool/tarantool.git --recursive

$ cd tarantool

$ git submodule update --init --recursive

$ pkg install -y git cmake gmake readline icu

$ pip install --user -r test-run/requirements.txt

$ make clean         # unnecessary, added for good luck
$ rm CMakeCache.txt  # unnecessary, added for good luck

$ mkdir build && cd build

$ # start initiating with build type=RelWithDebInfo
$ cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo

$ gmake

$ gmake test
```

(building-from-source-additional-steps)=

## Additional steps

(building-from-source-tarantoolctl)=

### -DENABLE_DIST=ON for tarantoolctl installation

The CMake option for hinting that the result will be distributed is
{code}`-DENABLE_DIST=ON`. If this option is on, then later `make install`
will install `tarantoolctl` files in addition to `tarantool` files.

(building-from-source-rpm-packages)=

### Make RPM and Debian packages

This step is optional. It's only for people who want to redistribute
Tarantool. We highly recommend to use official packages from the
[tarantool.org](https://tarantool.org/download.html) web-site.
However, you can build RPM and Debian packages using
[PackPack](https://github.com/packpack/packpack). Consult
[Build RPM or Deb package using packpack](https://github.com/tarantool/tarantool/wiki/Build-RPM-or-Deb-package-using-packpack)
for details.

(building-from-source-verify-tarantool)=

### Verify your Tarantool installation

```bash
$ # if you installed tarantool locally after build
$ tarantool
$ # - OR -
$ # if you didn't install tarantool locally after build
$ ./src/tarantool
```

This starts Tarantool in the interactive mode.

### See also

- [Tarantool README.md](https://github.com/tarantool/tarantool/blob/master/README.md)
- [Building Tarantool on MacOS](https://github.com/tarantool/tarantool/blob/master/README.MacOSX)
- [Building Tarantool on FreeBSD](https://github.com/tarantool/tarantool/blob/master/README.FreeBSD)
- [Building Tarantool on OpenBSD](https://github.com/tarantool/tarantool/blob/master/README.OpenBSD)
- [Tarantool static build tooling](https://github.com/tarantool/tarantool/blob/master/static-build/README.md)
