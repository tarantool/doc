.. _box_info_listen:

================================================================================
box.info.listen
================================================================================

.. module:: box.info

.. data:: listen

    Since: :doc:`2.4.1 </release/2.4.1>`

    A real address to which an instance is bound.
    If an instance does not listen to anything, ``box.info.listen`` is ``nil``.

    To learn how to configure URIs used to listen for incoming requests, see :ref:`iproto.listen <configuration_reference_iproto_listen>`.

    :rtype: string

    **Example**

    ..  code-block:: tarantoolsession

        sharded_cluster_crud:storage-a-002> box.info.listen
        ---
        - 127.0.0.1:3303
        ...
