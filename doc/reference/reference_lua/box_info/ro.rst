..  _box_info_ro:

================================================================================
box.info.ro
================================================================================

..  module:: box.info

..  data:: ro

    The current mode of the instance (writable or read-only).
    Learn more in :ref:`box_info_ro-reason`.

    :rtype: boolean

    **Example**

    ..  code-block:: tarantoolsession

        sharded_cluster_crud:storage-a-002> box.info.ro
        ---
        - true
        ...
