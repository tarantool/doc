.. _tt-download:

Downloading Tarantool Enterprise SDK
====================================

..  code-block:: console

    $ tt download VERSION [OPTION ...]

``tt download`` downloads Tarantool Enterprise SDK from the customer zone.

The ``VERSION`` is a part of the SDK archive name between ``tarantool-enterprise-sdk-``
and the platform identifier. For example, to download ``tarantool-enterprise-sdk-gc64-3.0.0-0-gf58f7d82a-r23.linux.x86_64.tar.gz``,
run:

..  code-block:: console

    $ tt download gc64-3.0.0-0-gf58f7d82a-r23

``tt`` automatically chooses the bundle for the current platform.

.. _tt-download-authentication:

Authentication
~~~~~~~~~~~~~~

To download the Tarantool Enterprise SDK using ``tt download``, you need to provide
access credentials for the Tarantool customer zone. Use one of the following ways to pass
the username and the password:

*   A text file specified in the ``ee.credentials_path`` parameter of the
    :ref:`tt environment configuration <tt-config_file>`:

    ..  code-block:: yaml

        # tt.yaml
        # ...
        ee:
          credential_path: cred.txt

    `cred.txt` should contain a username and a password on separate lines:

    .. code-block:: text

        myuser@tarantool.io
        p4$$w0rD

*   Environment variables ``TT_CLI_EE_USERNAME`` and ``TT_CLI_EE_PASSWORD``:

    ..  code-block:: console

        $ export TT_CLI_EE_USERNAME=myuser@tarantool.io
        $ export TT_CLI_EE_PASSWORD=p4$$w0rD
        $ tt download gc64-3.0.0-0-gf58f7d82a-r23

Options
-------

.. option:: --dev

    Download a development build.

.. option:: --directory-prefix STRING

    The downloaded SDK location. Default: ``.`` (current directory).
