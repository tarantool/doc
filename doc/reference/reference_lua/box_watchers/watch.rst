.. _box-watch:

================================================================================
box.watch()
================================================================================

..  function:: box.watch(key, func)

    Subscribe to events broadcast by a remote host.

    :param string key: a key name to subscribe to
    :param function func: a callback to invoke when the key value is updated

    :return: a watcher handle that can be used to unregister the watcher
    :rtype: ?