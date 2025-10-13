..  _tcm_integrity_check:

Integrity check
================

..  include:: index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm| supports the integrity check mechanism.
The integrity check mechanism in TCM verifies the digital signature of centralized configuration files.
It ensures that TCM only applies configurations that are signed with a trusted private key.

This mechanism allows TCM to:

* Allows updating the configuration with integrity check support.
* Detect unauthorized changes in centralized configuration.

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
   * - :ref:`security.integrity-check <tcm_configuration_reference_security_integrity-check>`
     - Enables signature validation
     - ``bool``
     - ``false``
   * - :ref:`security.signature-private-key-file <tcm_configuration_reference_security_signature-private-key-file>`
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
You can configure it directly in the |tcm| configuration file:

.. code-block:: yaml

    # tcm.yaml
    security:
        integrity-check: true
        signature-private-key-file: /etc/tcm/private_key.pem
