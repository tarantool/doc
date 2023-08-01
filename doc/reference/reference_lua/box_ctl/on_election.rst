..  _box_ctl-on_election:

===============================================================================
box.ctl.on_election()
===============================================================================

..  module:: box.ctl

..  function:: on_election(trigger-function)

    **Since:** :doc:`2.10.0 </release/2.10.0>`

    Create a :ref:`trigger <triggers>` executed every time
    the current state of a replica set node in regard to :ref:`leader election <repl_leader_elect>` changes.
    The current state is available in the :ref:`box.info.election <box_info_election>` table.

    The trigger doesn't accept any parameters.
    You can see the changes in ``box.info.election`` and
    :ref:`box.info.synchro <box_info_synchro>`.

    :param function     trigger-function: a trigger function

    :return: ``nil`` or a function pointer
