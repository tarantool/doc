.. _box_info_listen:

================================================================================
box.info.listen
================================================================================

.. module:: box.info

.. data:: listen

    Return a real address to which an instance was bound. For example, if
    ``box.cfg{listen}`` was set with a zero port, ``box.info.listen`` will show
    a real port. The address is stored as a string:

    * unix/:<path> for UNIX domain sockets
    * <ip>:<port> for IPv4
    * [ip]:<port> for IPv6

    If an instance does not listen to anything, ``box.info.listen`` is nil.

    **Example:**

    .. code-block:: tarantoolsession

      tarantool> box.cfg{listen=0}
      ---
      ...
      tarantool> box.cfg.listen
      ---
      - '0'
      ...
      tarantool> box.info.listen
      ---
      - 0.0.0.0:44149
      ...

