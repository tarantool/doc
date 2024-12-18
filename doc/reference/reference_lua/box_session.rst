.. _box_session:

-------------------------------------------------------------------------------
                            Submodule box.session
-------------------------------------------------------------------------------

The ``box.session`` submodule allows querying the session state, writing to a
session-specific temporary Lua table, or sending out-of-band messages, or
setting up triggers which will fire when a session starts or ends.

A *session* is an object associated with each client connection.

Below is a list of all ``box.session`` functions and members.

..  container:: table

    ..  rst-class:: left-align-column-1
    ..  rst-class:: left-align-column-2

    ..  list-table::
        :widths: 25 75
        :header-rows: 1

        *   - Name
            - Use

        *  - :doc:`./box_session/id`
           - Get the current session's ID

        *  - :doc:`./box_session/exists`
           - Check if a session exists

        *  - :doc:`./box_session/peer`
           - Get the session peer's host address and port

        *  - :doc:`./box_session/sync`
           - Get the sync integer constant

        *  - :doc:`./box_session/user`
           - Get the current user's name

        *  - :doc:`./box_session/type`
           - Get the connection type or cause of action

        *  - :doc:`./box_session/su`
           - Change the current user

        *  - :doc:`./box_session/uid`
           - Get the current user's ID

        *  - :doc:`./box_session/euid`
           - 	Get the current effective user's ID

        *  - :doc:`./box_session/storage`
           - Table with session-specific names and values

        *  - :doc:`./box_session/on_connect`
           - Define a connect trigger

        *  - :doc:`./box_session/on_disconnect`
           - Define a disconnect trigger

        *  - :doc:`./box_session/on_auth`
           - 	Define an authentication trigger

        *  - :doc:`./box_session/on_access_denied`
           - 	Define a trigger to report restricted actions

        *  - :doc:`./box_session/push`
           - (Deprecated) Send an out-of-band message

.. toctree::
    :hidden:

    box_session/id
    box_session/exists
    box_session/peer
    box_session/sync
    box_session/user
    box_session/type
    box_session/su
    box_session/uid
    box_session/euid
    box_session/storage
    box_session/on_connect
    box_session/on_disconnect
    box_session/on_auth
    box_session/on_access_denied
    box_session/push
