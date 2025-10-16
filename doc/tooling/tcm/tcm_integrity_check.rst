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

* Update the configuration with integrity check support.
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


Example configuration
~~~~~~~~~~~~~~~~~~~~~

Integrity check can be enabled directly in the |tcm| configuration file:

.. code-block:: yaml

    # tcm.yaml
    security:
        integrity-check: true
        signature-private-key-file: /etc/tcm/private_key.pem

.. note::

    The ``integrity-check-period`` option works only in the ``tt`` + Tarantool setup, where tt periodically verifies the integrity of the running instance.
    In TCM, this option is not used, as the component only uploads and verifies configuration signatures and does not interact directly with the database.
    Moreover, TCM cannot stop Tarantool execution in case of an integrity check failure — this behavior is specific to tt when Tarantool
    is started with the ``--integrity-check`` and ``--integrity-check-period`` options.

    Read details about ``tt`` integrity check in :ref:`its documentation <tt-start-integrity-check>`