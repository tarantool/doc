.. _box_introspection-box_cfg:

--------------------------------------------------------------------------------
Submodule `box.cfg`
--------------------------------------------------------------------------------

.. module:: box.cfg

The ``box.cfg`` submodule is for administrators to specify all the server
configuration parameters (see "Configuration reference" for
:ref:`a complete description of all configuration parameters <box_cfg_params>`).
Use ``box.cfg`` without braces to get read-only access to those parameters.

**Example:**

.. code-block:: tarantoolsession

    tarantool> box.cfg
    ---
    - snapshot_count: 6
      too_long_threshold: 0.5
      slab_alloc_factor: 1.1
      slab_alloc_maximal: 1048576
      background: false
      <...>
    ...
