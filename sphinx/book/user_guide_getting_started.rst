-------------------------------------------------------------------------------
                        Getting started
-------------------------------------------------------------------------------

This chapter shows how to download, how to install, and how to start Tarantool
for the first time.

For production, if possible, you should download a binary (executable) package.
This will ensure that you have the same build of the same version that the
developers have. That makes analysis easier if later you need to report a problem,
and avoids subtle problems that might happen if you used different tools or
different parameters when building from source. The section about binaries is
“:ref:`user_guide_getting_started-downloading_and_installing_a_binary_package`”.

For development, you will want to download a source package and make the binary
by yourself using a C/C++ compiler and common tools. Although this is a bit harder,
it gives more control. And the source packages include additional files, for example
the Tarantool test suite. The section about source is “:ref:`building_from_source`”.

If the installation has already been done, then you should try it out. So we've
provided some instructions that you can use to make a temporary “sandbox”. In a
few minutes you can start the server and type in some database-manipulation
statements. The section about the sandbox is
“:ref:`user_guide_getting_started-first_database`”.

.. _user_guide_getting_started-downloading_and_installing_a_binary_package:

=====================================================================
            Downloading and installing a binary package
=====================================================================

The repositories for the “stable” 1.6.x releases are at
`tarantool.org/dist/1.6 <http://tarantool.org/dist/1.6>`_.
The repositories for the “development” 1.7.x releases are at
`tarantool.org/dist/1.7 <http://tarantool.org/dist/1.7>`_.
Since this is the manual for the 1.7.x releases, all instructions use
`tarantool.org/dist/1.7 <http://tarantool.org/dist/1.7>`_.

An automatic build system creates, tests and publishes packages for every
push into the 1.7 branch. Therefore if you looked at
tarantool.org/dist/1.7 you would see that there are source files and
subdirectories for the packages that will be described in this section.

To download and install the package that's appropriate for your environment,
start a shell (terminal) and enter one of the following sets of command-line
instructions.

More advice for binary downloads is at
`http://tarantool.org/download.html <http://tarantool.org/download.html>`_.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                    Debian GNU/Linux
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There is always an up-to-date Debian repository at
http://tarantool.org/dist/1.7/debian. The repository contains builds for
Debian unstable "Sid", testing "Stretch", stable "Jessie" and old stable
"Wheezy". Add the tarantool.org repository to your apt sources list.
$release is an environment variable which will contain the Debian version code
e.g. "Wheezy":

.. code-block:: bash

    curl http://download.tarantool.org/tarantool/1.7/gpgkey | sudo apt-key add -
    release=`lsb_release -c -s`
    # append two lines to a list of source repositories
    sudo rm -f /etc/apt/sources.list.d/*tarantool*.list
    sudo tee /etc/apt/sources.list.d/tarantool_1_7.list <<- EOF
    deb http://download.tarantool.org/tarantool/1.7/debian/ $release main
    deb-src http://download.tarantool.org/tarantool/1.7/debian/ $release main
    EOF
    # install
    sudo apt-get update
    sudo apt-get -y install tarantool

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        Ubuntu
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Ubuntu repository contains builds for
LTS "Precise", LTS "Trusty", "Wily, and "Xenial".
Add the repository to your apt sources list. $release is an
environment variable which will contain the Ubuntu version code e.g. "precise".
If you want the version that comes with Ubuntu, start with the lines that
follow the '# install' comment:

.. code-block:: bash

    curl http://download.tarantool.org/tarantool/1.7/gpgkey | sudo apt-key add -
    release=`lsb_release -c -s`
    # append two lines to a list of source repositories
    sudo rm -f /etc/apt/sources.list.d/*tarantool*.list
    sudo tee /etc/apt/sources.list.d/tarantool_1_7.list <<- EOF
    deb http://download.tarantool.org/tarantool/1.7/ubuntu/ $release main
    deb-src http://download.tarantool.org/tarantool/1.7/ubuntu/ $release main
    EOF
    # install
    sudo apt-get update
    sudo apt-get -y install tarantool

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        CentOS 6 and RHEL 6
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These instructions are applicable for CentOS version 6 and RHEL version
6 and Amaxon Linux. Pick the CentOS repository which fits your
CentOS/RHEL/Amazon version and your x86 platform.

Add the following section to your yum repository list
(``/etc/yum.repos.d/tarantool.repo``) (in these instructions ``$releasever``
i.e. CentOS release version must be 6 and ``$basearch`` i.e. base
architecture must be either i386 or x86_64):

.. cssclass:: highlight
.. parsed-literal::

    [tarantool_1_7]
    name=EnterpriseLinux-$releasever - Tarantool
    baseurl=http://download.tarantool.org/tarantool/1.7/el/*$releasever*/*$basearch*/
    gpgkey=http://download.tarantool.org/tarantool/1.7/gpgkey
    repo_gpgcheck=1
    gpgcheck=0
    enabled=1
    [tarantool_1_7-source]
    name=EnterpriseLinux-6 - Tarantool Sources
    baseurl=http://download.tarantool.org/tarantool/1.7/el/*$releasever*/SRPMS
    gpgkey=http://download.tarantool.org/tarantool/1.7/gpgkey
    repo_gpgcheck=1
    gpgcheck=0

For example, if you have CentOS 6 x86-64, you can add the new section thus:

.. code-block:: bash

    sudo rm -f /etc/yum.repos.d/*tarantool*.repo
    echo "[tarantool_1_7]" | \
    sudo tee /etc/yum.repos.d/tarantool_1_7.repo
    echo "name=EnterpriseLinux-6 - Tarantool"| sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "baseurl=http://download.tarantool.org/tarantool/1.7/el/6/x86_64/" | \
    sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "gpgkey=http://download.tarantool.org/tarantool/1.7/gpgkey" | \
    sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "repo_gpgcheck=1" | sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "gpgcheck=0" | sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "enabled=1" | sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "[tarantool_1_7-source]" | \
    sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "name=EnterpriseLinux-6 - Tarantool Sources" | \
    sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "baseurl=http://download.tarantool.org/tarantool/1.7/el/6/SRPMS" | \
    sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "gpgkey=http://download.tarantool.org/tarantool/1.7/gpgkey" | \
    sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "repo_gpgcheck=1" | \
    sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "gpgcheck=0" | \
    sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo

Then enable the EPEL repository, if this has not already been done:

.. code-block:: bash

    sudo yum -y install http://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
    sed 's/enabled=.*/enabled=1/g' -i /etc/yum.repos.d/epel.repo

Then install with:

.. code-block:: bash

    sudo yum makecache -y --disablerepo='*' --enablerepo='tarantool_1_7' --enablerepo='epel'
    sudo yum -y install tarantool

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        CentOS 7 and RHEL 7
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These instructions are applicable for CentOS version 7 and RHEL version
7. Pick the CentOS repository which fits your CentOS/RHEL version and
your x86 platform.

Add the following section to your yum repository list
(``/etc/yum.repos.d/tarantool.repo``) (in these instructions ``$releasever``
i.e. CentOS release version must be 7 and ``$basearch`` i.e. base
architecture must be either i386 or x86_64):

.. cssclass:: highlight
.. parsed-literal::

    [tarantool_1_7]
    name=EnterpriseLinux-$releasever - Tarantool
    baseurl=http://download.tarantool.org/tarantool/1.7/el/*$releasever*/*$basearch*/
    gpgkey=http://download.tarantool.org/tarantool/1.7/gpgkey
    repo_gpgcheck=1
    gpgcheck=0
    enabled=1
    [tarantool_1_7-source]
    name=EnterpriseLinux-6 - Tarantool Sources
    baseurl=http://download.tarantool.org/tarantool/1.7/el/*$releasever*/SRPMS
    gpgkey=http://download.tarantool.org/tarantool/1.7/gpgkey
    repo_gpgcheck=1
    gpgcheck=0

For example, if you have CentOS 7 x86-64, you can add the new section thus:

.. code-block:: bash

    sudo rm -f /etc/yum.repos.d/*tarantool*.repo
    echo "[tarantool_1_7]" | \
    sudo tee /etc/yum.repos.d/tarantool_1_7.repo
    echo "name=EnterpriseLinux-7 - Tarantool"| sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "baseurl=http://download.tarantool.org/tarantool/1.7/el/7/x86_64/" | \
    sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "gpgkey=http://download.tarantool.org/tarantool/1.7/gpgkey" | \
    sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "repo_gpgcheck=1" | sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "gpgcheck=0" | sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "enabled=1" | sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "[tarantool_1_7-source]" | \
    sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "name=EnterpriseLinux-7 - Tarantool Sources" | \
    sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "baseurl=http://download.tarantool.org/tarantool/1.7/el/7/SRPMS" | \
    sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "gpgkey=http://download.tarantool.org/tarantool/1.7/gpgkey" | \
    sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "repo_gpgcheck=1" | \
    sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "gpgcheck=0" | \
    sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo

Then install with:

.. code-block:: bash

    sudo yum makecache -y --disablerepo='*' --enablerepo='tarantool_1_7'
    sudo yum -y install tarantool

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                          Fedora
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

These instructions are applicable for Fedora 21, 22 or rawhide.
Add the following section to your yum repository list
(``/etc/yum.repos.d/tarantool.repo``) (in these instructions
``$releasever`` i.e. Fedora release version must be 21 or 22 or rawhide and
``$basearch`` i.e. base architecture must be i386 or x86_64):

.. cssclass:: highlight
.. parsed-literal::

    [tarantool_1_7]
    name=Fedora-$releasever - Tarantool
    baseurl=http://download.tarantool.org/tarantool/1.7/fedora/*$releasever*/*$basearch*/
    gpgkey=http://download.tarantool.org/tarantool/1.7/gpgkey
    repo_gpgcheck=1
    gpgcheck=0
    enabled=1

For example, if you have Fedora version 22 x86-64, you can add the new section thus:

.. code-block:: bash

    sudo rm -f /etc/yum.repos.d/*tarantool*.repo
    echo "[tarantool_1_7]" | \
    sudo tee /etc/yum.repos.d/tarantool_1_7.repo
    echo "name=Fedora-22 - Tarantool"| sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "baseurl=http://download.tarantool.org/tarantool/1.7/fedora/22/x86_64/" | \
    sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "gpgkey=http://download.tarantool.org/tarantool/1.7/gpgkey" | \
    sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "repo_gpgcheck=1" | sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "gpgcheck=0" | sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo
    echo "enabled=1" | sudo tee -a /etc/yum.repos.d/tarantool_1_7.repo

Then install with:

.. code-block:: bash

    sudo dnf -q makecache -y --disablerepo='*' --enablerepo='tarantool_1_7'
    sudo dnf -y install tarantool

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                         FreeBSD
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

With your browser go to the FreeBSD ports page
`www.freebsd.org/ports/index.html <http://www.freebsd.org/ports/index.html>`_.
Enter the search term: tarantool.
Choose the package you want.

Also look at `www.freshports.org/databases/tarantool <http://www.freshports.org/databases/tarantool>`_

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                         Mac OS X
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can install tarantool via Homebrew. It contains binaries for OS X 10.09 and higher. Simply use:

.. code-block:: bash

    $ brew install tarantool
    ==> Downloading https://homebrew.bintray.com/bottles/tarantool-1.7.0-593.el_capitan.bottle.tar.gz
    Already downloaded: /Library/Caches/Homebrew/tarantool-1.7.0-593.el_capitan.bottle.tar.gz
    ==> Pouring tarantool-1.7.0-593.el_capitan.bottle.tar.gz
    🍺  /usr/local/Cellar/tarantool/1.7.0-593: 19 files, 2.1M

.. _user_guide_getting_started-first_database:

=====================================================================
        Starting Tarantool and making your first database
=====================================================================

Here is how to create a simple test database after installing.

Create a new directory. It's just for tests, you can delete it when the tests are over.

.. code-block:: console

    $ mkdir ~/tarantool_sandbox
    $ cd ~/tarantool_sandbox

Here is how to create a simple test database after installing.

Start the server. The server name is tarantool.

.. code-block:: console

    $ # if you downloaded a binary with apt-get or yum, say this:
    $ /usr/bin/tarantool
    $ # if you downloaded and untarred a binary
    $ # tarball to ~/tarantool, say this:
    $ ~/tarantool/bin/tarantool
    $ # if you built from a source download, say this:
    $ ~/tarantool/src/tarantool

The server starts in interactive mode and outputs a command prompt.
To turn on the database, :ref:`configure <box_introspection-box_cfg>` it. This minimal example is sufficient:

.. code-block:: tarantoolsession

    tarantool> box.cfg{listen = 3301}

If all goes well, you will see the server displaying progress as it
initializes, something like this:

.. code-block:: tarantoolsession

    tarantool> box.cfg{listen = 3301}
    2015-08-07 09:41:41.077 ... version 1.7.0-1216-g73f7154
    2015-08-07 09:41:41.077 ... log level 5
    2015-08-07 09:41:41.078 ... mapping 1073741824 bytes for a shared arena...
    2015-08-07 09:41:41.079 ... initialized
    2015-08-07 09:41:41.081 ... initializing an empty data directory
    2015-08-07 09:41:41.095 ... creating './00000000000000000000.snap.inprogress'
    2015-08-07 09:41:41.095 ... saving snapshot './00000000000000000000.snap.inprogress'
    2015-08-07 09:41:41.127 ... done
    2015-08-07 09:41:41.128 ... primary: bound to 0.0.0.0:3301
    2015-08-07 09:41:41.128 ... ready to accept requests

Now that the server is up, you could start up a different shell
and connect to its primary port with:

.. code-block:: console

    $ telnet 0 3301

but for example purposes it is simpler to just leave the server
running in "interactive mode". On production machines the
interactive mode is just for administrators, but because it's
convenient for learning it will be used for most examples in
this manual. Tarantool is waiting for the user to type instructions.

To create the first space and the first :ref:`index <box_index>`, try this:

.. code-block:: tarantoolsession

    tarantool> s = box.schema.space.create('tester')
    tarantool> s:create_index('primary', {
             >   type = 'hash',
             >   parts = {1, 'NUM'}
             > })

To insert three “tuples” (our name for “records”) into the first “space” of the database try this:

.. code-block:: tarantoolsession

    tarantool> t = s:insert({1})
    tarantool> t = s:insert({2, 'Music'})
    tarantool> t = s:insert({3, 'Length', 93})

To select a tuple from the first space of the database, using the first defined key, try this:

.. code-block:: tarantoolsession

    tarantool> s:select{3}

Your terminal screen should now look like this:

.. code-block:: tarantoolsession

    tarantool> s = box.schema.space.create('tester')
    2015-06-10 12:04:18.158 ... creating './00000000000000000000.xlog.inprogress'
    ---
    ...
    tarantool>s:create_index('primary', {type = 'hash', parts = {1, 'NUM'}})
    ---
    ...
    tarantool> t = s:insert{1}
    ---
    ...
    tarantool> t = s:insert{2, 'Music'}
    ---
    ...
    tarantool> t = s:insert{3, 'Length', 93}
    ---
    ...
    tarantool> s:select{3}
    ---
    - - [3, 'Length', 93]
    ...
    tarantool> 

Now, to prepare for the example in the next section, try this:

.. code-block:: tarantoolsession

    tarantool> box.schema.user.grant('guest', 'read,write,execute', 'universe')



=====================================================================
        Connecting remotely
=====================================================================

In the previous section the first request was with :code:`box.cfg{listen = 3301}`.
The :code:`listen` value can be any form of URI (uniform resource identifier);
in this case it's just a local port: port 3301.
It's possible to send requests to the listen URI via
(a) telnet,
or (b) a connector (which will be the subject of the ":ref:`index-box_connectors`" chapter),
or (c) another instance of Tarantool via the :ref:`console package <console-package>`,
or (d) ``tarantoolctl connect``.
Let's try (d).

Switch to another terminal.
On Linux, for example, this means starting another instance of a Bash shell.
There is no need to use cd to switch to the :code:`~/tarantool_sandbox` directory.

Start the tarantoolctl utility: |br|
:codenormal:`$` :codebold:`tarantoolctl connect '3301'` |br|
This means "use the :ref:`tarantoolctl connect utility <administration-tarantoolctl_connect>`
to connect to the Tarantool server that's listening
on ``localhost:3301``."

Try this request: |br|
:codenormal:`tarantool>` :codebold:`box.space.tester:select{2}` |br|
This means "send a request to that Tarantool server,
and display the result." The result in this case is
one of the tuples that was inserted earlier.
Your terminal screen should now look like this:

.. code-block:: tarantoolsession

    $ tarantoolctl connect 3301
    /usr/local/bin/tarantoolctl: connected to localhost:3301
    localhost:3301> box.space.tester:select{2}
    ---
    - - [2, 'Music']
    ...

    localhost:3301> 

You can repeat :code:`box.space...:insert{}` and :code:`box.space...:select{}`
indefinitely, on either Tarantool instance.
When the testing is over: To drop the space: :code:`s:drop()`.
To stop tarantoolctl: Ctrl+C or Ctrl+D. To stop tarantool (an alternative):
:ref:`os.exit() <os-exit>`. To stop tarantool (from another terminal):
:code:`sudo pkill -f tarantool`.
To destroy the test: :code:`rm -r ~/tarantool_sandbox`.

To review ... If you followed all the instructions
in this chapter, then so far you have: installed Tarantool
from either a binary or a source repository,
started up the Tarantool server, inserted and selected tuples.


