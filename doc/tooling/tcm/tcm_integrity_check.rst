..  _tcm_integrity_check:

Integrity check
================

..  include:: index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm| supports the integrity check mechanism.
This feature ensures that the environment, application files, and centralized configuration have not been tampered with after packaging and publishing.

The integrity check mechanism is used to:

* Ensure the environment and application files haven’t been modified.
* Prevent launching or running TCM in a compromised state.
* Detect unauthorized changes in centralized configuration.

..  _tcm_integrity_check_enable:

Enabling integrity check
------------------------

To enable integrity checks, you must sign the application and configuration:

#. Package the application with integrity checks:

    .. code-block:: console

        tt pack --with-integrity-check

#. Publish configuration with integrity metadata:

    .. code-block:: console

        tt cluster publish --with-integrity-check

..  _tcm_integrity_check_configure:

Configure integrity check
-------------------------

Configuration parameters
~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1
   :widths: 35 45 10 10

   * - Parameter
     - Description
     - Type
     - Default
   * - :ref:`security.integrity-check <tcm_configuration_reference_security_integrity-check`
     - Enables signature validation
     - ``bool``
     - ``false``
   * - :ref:`security.signature-private-key-file` <tcm_configuration_reference_security_signature-private-key-file`
     - Path to the private key for signing configuration
     - ``string``
     - ``""``

Environment variables
~~~~~~~~~~~~~~~~~~~~~

.. list-table::
   :header-rows: 1
   :widths: 40 60

   * - Variable
     - Description
   * - ``TCM_SECURITY_INTEGRITY_CHECK``
     - Enables integrity check via environment variable
   * - ``TCM_SECURITY_SIGNATURE_PRIVATE_KEY_FILE``
     - Path to the private key for signing configuration


Example configuration
~~~~~~~~~~~~~~~~~~~~~

Integrity check in |tcm| can be enabled and customized using several methods.
You can configure it directly in the |tcm| configuration file or through environment variables when starting the application.

* In configuration file:

    .. code-block:: yaml

        # tcm.yaml
        security:
            integrity-check: true
            signature-private-key-file: /etc/tcm/private_key.pem


* Environment variables:

    .. code-block:: console

        export TCM_SECURITY_INTEGRITY_CHECK=true
        export TCM_SECURITY_SIGNATURE_PRIVATE_KEY_FILE=/etc/tcm/private_key.pem

        tt --integrity-check /etc/tcm/public_key.pem start tcm
