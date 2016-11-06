.. _building_documentation:

-------------------------------------------------------------------------------
Building documentation
-------------------------------------------------------------------------------

This documentation is built using a simplified markup system named ``Sphinx``
(see http://sphinx-doc.org). You can build a local version of this documentation
and contribute to it.

You need to install:

* ``git`` (a program for downloading source repositories)
* ``CMake`` version 2.8 or later (a program for managing the build process)
* ``Python`` version greater than 2.6 -- preferably 2.7 -- and less than 3.0
  (Sphinx is a Python-based tool)
  
Also, make sure to install the following Python modules:

* `pip <https://pypi.python.org/pypi/pip>`_, any version
* `dev <https://pypi.python.org/pypi/dev>`_, any version
* `pyYAML <https://pypi.python.org/pypi/PyYAML>`_ version 3.10
* `Sphinx <https://pypi.python.org/pypi/Sphinx>`_ version 1.4.4
* `sphinx-intl <https://pypi.python.org/pypi/sphinx-intl>`_ version 0.9.9
* `pelican <https://pypi.python.org/pypi/pelican>`_, any version
* `BeautifulSoup <https://pypi.python.org/pypi/BeautifulSoup>`_, any version
* `gevent <https://pypi.python.org/pypi/gevent>`_ version 1.1b5
  
See installation details in the :ref:`build-from-source <building_from_source>`
section of this documentation. The procedure below implies that all the
prerequisites are met.

1. Use ``git`` to download the latest source code of this documentation from the
   GitHub repository ``tarantool/doc``, branch 1.7. For example, to a local
   directory named `~/tarantool-doc`:

   .. code-block:: bash

     git clone https://github.com/tarantool/doc.git ~/tarantool-doc

2. Use ``CMake`` to initiate the build.

   .. code-block:: bash
   
     cd ~/tarantool-doc
     make clean         # unnecessary, added for good luck
     rm CMakeCache.txt  # unnecessary, added for good luck
     cmake .            # start initiating

3. Build a local version of the existing documentation package.

   Run the ``make`` command with an appropriate option to specify which 
   documentation version to build.

   .. code-block:: bash

     cd ~/tarantool-doc
     make all                # all versions
     make sphinx-html        # multi-page English version
     make sphinx-singlehtml  # one-page English version
     make sphinx-html-ru     # multi-page Russian version
     make sphinx-singlehtml  # one-page Russian version

   Documentation is created and stored at `/www/output`:
   
   * `/www/output/doc` (English versions)
   * `/www/output/doc/ru` (Russian versions)
   
   The entry point for each version is `index.html` file in the appropriate
   directory.

4. Set up a web-server.

   Run the following command to set up a web-server (the example below is for
   Ubuntu, but the procedure is similar for other supported OS's).
   Make sure to run it from the documentation output folder, as specified below:

   .. code-block:: bash

     cd ~/tarantool-doc/www/output
     python -m SimpleHTTPServer 8000

5. Open your browser and enter ``127.0.0.1:8000/doc`` into the address box. If
   your local documentation build is valid, the default version (English
   multi-page) will be displayed in the browser.

6. To contribute to documentation, use the ``.rst`` format for drafting and
   submit your updates as "Pull Requests" via GitHub.

   To comply with the writing and formatting style, use the
   :ref:`guidelines <documentation_guidelines>` provided in the documentation,
   common sense and existing documents.

   Notes:
   
   * If you suggest creating a new documentation section (i.e., a whole new
     page), it has to be saved to the relevant section at GitHub.
     
   * If you want to contribute to localizing this documentation (e.g. into
     Russian), add your translation strings to ``.po`` files stored in the
     corresponding locale directory (e.g. ``/sphinx/locale/ru/LC_MESSAGES/``
     for Russian). See more about localizing with Sphinx at 
     http://www.sphinx-doc.org/en/stable/intl.html
