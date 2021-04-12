.. _box_ctl-on_shutdown:

===============================================================================
box.ctl.on_shutdown()
===============================================================================

.. module:: box.ctl

The ``box.ctl`` submodule also contains two functions for the two
:ref:`server trigger <triggers>` definitions: ``on_shutdown`` and ``on_schema_init``.
Please, familiarize yourself with the mechanism of trigger functions before using them.

.. function:: on_shutdown(trigger-function [, old-trigger-function])

     Create a "shutdown :ref:`trigger <triggers>`".
     The ``trigger-function`` will be executed
     whenever   :ref:`os.exit() <os-exit>` happens, or when the server is
     shut down after receiving a SIGTERM or SIGINT or SIGHUP signal
     (but not after SIGSEGV or SIGABORT or any signal that causes
     immediate program termination).

     :param function     trigger-function: function which will become the
                                           trigger function
     :param function old-trigger-function: existing trigger function which
                                           will be replaced by
                                           trigger-function
     :return: nil or function pointer

     If the parameters are (nil, old-trigger-function), then the old
     trigger is deleted.

     Details about trigger characteristics are in the :ref:`triggers <triggers-box_triggers>` section.

