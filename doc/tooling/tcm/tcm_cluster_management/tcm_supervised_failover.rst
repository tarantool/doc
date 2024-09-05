..  _tcm_supervised_failover:

Using supervised failover
=========================

..  include:: ../index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

For Tarantool clusters that use :ref:`supervised failover <repl_supervised_failover>`,
|tcm_full_name| offers tools for interaction with external failover coordinators from its web interface.

The tools for using supervised failover are located on the **Failovers** page
available from the **Actions** menu on the cluster stateboard.

.. note::

    |tcm| can interact with failover coordinators that are already running.
    There is no way to start or stop coordinators from |tcm|.

..  _tcm_supervised_failover_view:

Viewing failover coordinators
-----------------------------

To view failover coordinators running on the cluster, go to the **Failovers** tab.
On this tab, you can see the information about all Tarantool instances that the cluster
uses as failover coordinators. The information includes:

-   Current coordinator status -- ``Active`` or ``Not active``
-   ``PID`` -- process ID
-   ``Hostname`` -- the host on which the coordinator is running
-   ``UUID`` -- the coordinator ID
-   ``Term`` -- a value that defines the order in which coordinators become active
    (take the lock) over time.


..  _tcm_supervised_failover_commands:

Executing failover commands
---------------------------

To send a failover command to a coordinator, go to the **Commands** tab and click **Add**.
Then, provide the command description in the YAML format. It can include the following
fields:

-   ``command`` -- the command name. Possible value: ``switch`` -- switch master
    in a replica set.
-   ``new_master`` -- the name of the instance to make the new master.
-   ``timeout`` -- the command execution timeout.

Example:

.. code-block:: yaml

    command: switch
    new_master: instance-002
    timeout: 30

After entering the command, click **Save** to send the command for execution.

Tarantool assigns an id to the command and waits for a coordinator to process the command.

All failover commands executed on the cluster are shown on the **Commands** tab with
their ids and statuses. A command can have the following statuses:

-   ``taken`` -- a failover coordinator has started the command execution.
-   ``success`` -- the command has completed successfully.
-   ``failed`` -- an error occurred during the command execution.
    A short error description is shown in the **Reason** field.

To see the command execution details, click this command in the commands list.
