..  _box_ctl-on_shutdown_timeout:

===============================================================================
box.ctl.set_on_shutdown_timeout()
===============================================================================

..  module:: box.ctl

..  function:: set_on_shutdown_timeout([timeout])

     Set a timeout for the :ref:`on_shutdown <box_ctl-on_shutdown>` trigger.
     If the timeout has expired, the server stops immediately
     regardless of whether there are any ``on_shutdown`` triggers left.

     :param double timeout: time to wait for the trigger to be completed. The default value is 3 seconds.

     :return: nil

