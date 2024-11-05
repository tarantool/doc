..  _tcm_dev_mode:

Development mode
================

..  include:: index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm_full_name| provides a special mode aimed to use during the development.
This mode extends the web interface with capabilities that can help in development
or testing environments, such as starting and stopping instances or instance promotion.

..  _tcm_dev_mode_enable:

Enabling development mode
-------------------------

You can enable |tcm| development mode in different ways: in its web interface,
in the configuration file, using an environment variable, or using a command-line option.

..  _tcm_dev_mode_enable_web:

Web interface
~~~~~~~~~~~~~

To enable development mode on the running |tcm| instance, use its :ref:`web interface <tcm_ui_overview>`:

#.  Open user settings: click **Settings** under the user name in the header.
#.  Go to the **About** tab.
#.  Click the toggle button beside **tcm/mode**.

..  _tcm_dev_mode_enable_config:

Configuration file
~~~~~~~~~~~~~~~~~~

To start |tcm| in the development mode, specify the ``mode: development`` option
in its :ref:`configuration file <tcm_configuration>`:

.. code-block:: yaml

    # tcm_config.yaml
    mode: development

..  _tcm_dev_mode_enable_cli:

Command-line option
~~~~~~~~~~~~~~~~~~~

To start |tcm| in the development mode, specify the ``--mode=development`` command-line option:

.. code-block:: console

    $ tcm --mode=development


..  _tcm_dev_mode_enable_env:

Environment variable
~~~~~~~~~~~~~~~~~~~~

To make new |tcm| instances start in the development mode by default, set the
``TCM_MODE`` environment variable to ``development``:

.. code-block:: console

    $ export TCM_MODE=development
    $ tcm
