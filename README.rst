Tarantool Documentation
=======================

.. figure:: https://badges.crowdin.net/tarantool-docs/localized.svg
   :alt: Translation badge

Tarantool documentation source, published at https://www.tarantool.io/doc/.

How to build Tarantool documentation using Docker
-------------------------------------------------

See `Docker <https://www.docker.com>`_

Prepare for work
~~~~~~~~~~~~~~~~

First of all, pull the image for building the docs.

..  code-block:: bash

    docker pull tarantool/doc-builder

Next, initialize a Makefile for your OS:

..  code-block:: bash

    docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "cmake ."

Update submodules and generate documentation sources from code
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

A big part of documentation sources comes from several other projects,
connected as Git submodules.
To include their latest contents in the docs, run these two steps.

1.  Update the submodules:

    ..  code-block:: bash

        docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make pull-modules"

    This will initialize Git submodules and update them to the top of the stable
    branch in each repository.
    
    You can also do without a Docker container:

    ..  code-block:: bash

        git submodule update --init
        git fetch --recurse-submodules
        git submodule update --remote --checkout

    ``git submodule update`` can sometimes fail, for example,
    when you have changes in submodules' files.
    You can reinitialize submodules to fix the problem.
    
    **Caution:** all untracked changes in submodules will be lost!

    ..  code-block:: bash

        git submodule deinit -f .
        git submodule update --init

2.  Build the submodules content:

    ..  code-block:: bash

        docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make build-modules"

    This command will do two things:

    1.  Generate documentation source files from the source code
    2.  Copy these files to the right places under the ``./doc/`` directory.

    If you're editing submodules locally, repeat this step
    to view the updated results.

Now you're ready to build and preview the documentation locally.

Build and run the documentation on your machine
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When editing the documentation, you can set up a live-reload server.
It will build your documentation and serve it on `127.0.0.1:8000 <http://127.0.0.1:8000>`_.
Every time you make changes in the source files, it will rebuild the docs
and refresh the browser page.

..  code-block:: bash

    docker run --rm -it -p 8000:8000 -v $(pwd):/doc tarantool/doc-builder sh -c "make autobuild"

First build will take some time.
When it's done, open `127.0.0.1:8000 <http://127.0.0.1:8000>`_ in the browser.
Now when you make changes, they will be rebuilt in a few seconds,
and the browser tab with preview will reload automatically.

You can also build the docs manually with ``make html``,
and then serve them using python3 built-in server:

..  code-block:: bash

    docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make html"
    docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make html-ru"
    python3 -m http.server --directory output/html

or python2 built-in server:

..  code-block:: bash

    cd output/html
    python -m SimpleHTTPServer

then go to `localhost:8000 <http://localhost:8000>`_ in your browser.

There are other commands which can run
in the ``tarantool/doc-builder`` container:

..  code-block:: bash

    docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make html"
    docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make html-ru"
    docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make singlehtml"
    docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make singlehtml-ru"
    docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make pdf"
    docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make pdf-ru"
    docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make json"
    docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make json-ru"
    docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make epub"
    docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make epub-ru"
    docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make update-pot"
    docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make update-po"
    docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make update-po-force"

Localization
------------

Terms:

*   **translation unit** (TU) is an atomic piece of text which can be translated.
    A paragraph, a list item, a heading, image's alt-text and so on.

*   **translation source files** are the files with translation units in English only.
    They're located in ``locale/en``.

*   **translation files** are the files which match original text to
    translated text. They're located in ``locale/ru``.

We use Crowdin for continuous localization.
To work with Crowdin CLI, issue an API token in your
`account settings <https://crowdin.com/settings#api-key>`_.
Save it in ``~/.crowdin.yml``:

..  code-block:: yaml

    "api_token": "asdfg12345..."

Upload translation sources any time when they have changed:

..  code-block:: bash

    # first, update the translation sources
    docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make update-pot"

    # next, upload them to Crowdin
    crowdin upload
    # or
    crowdin upload sources

Upload translation files once for each project to pass the existing translations to Crowdin:

..  code-block:: bash

    crowdin upload translations --auto-approve-imported --import-eq-suggestions

Download translation files back when they're done.
Then reformat them to see the real changes.

..  code-block:: bash

    crowdin download
    docker run --rm -it -v $(pwd):/doc tarantool/doc-builder sh -c "make reformat-po"

How to contribute
-----------------

To contribute to documentation, use the
`REST <http://docutils.sourceforge.net/docs/user/rst/quickstart.html>`_
format for drafting and submit your updates as a
`pull request <https://help.github.com/articles/creating-a-pull-request>`_
via GitHub.

To comply with the writing and formatting style, use the
`guidelines <https://www.tarantool.io/en/doc/latest/contributing/docs/>`_
provided in the documentation, common sense and existing documents.

Notes:

*   If you suggest creating a new documentation section (a whole new
    page), it has to be saved to the relevant section at GitHub.

*   If you want to contribute to localizing this documentation (for example, into
    Russian), add your translation strings to ``.po`` files stored in the
    corresponding locale directory (for example, ``/locale/ru/LC_MESSAGES/``
    for Russian). See more about localizing with Sphinx at
    http://www.sphinx-doc.org/en/stable/intl.html.
