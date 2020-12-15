.. _box_session:

-------------------------------------------------------------------------------
                            Submodule `box.session`
-------------------------------------------------------------------------------

===============================================================================
                                   Overview
===============================================================================

The ``box.session`` submodule allows querying the session state, writing to a
session-specific temporary Lua table, or sending out-of-band messages, or
setting up triggers which will fire when a session starts or ends.

A *session* is an object associated with each client connection.

===============================================================================
                                   Contents
===============================================================================

Below is a list of all ``box.session`` functions and members.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`box.session.id()               | Get the current session's ID    |
    | <box_session-id>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.exists()           | Check if a session exists       |
    | <box_session-exists>`                |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.peer()             | Get the session peer's host     |
    | <box_session-peer>`                  | address and port                |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.sync()             | Get the sync integer constant   |
    | <box_session-sync>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.user()             | Get the current user's name     |
    | <box_session-user>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.type()             | Get the connection type or      |
    | <box_session-type>`                  | cause of action                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.su()               | Change the current user         |
    | <box_session-su>`                    |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.uid()              | Get the current user's ID       |
    | <box_session-uid>`                   |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.euid()             | Get the current effective       |
    | <box_session-euid>`                  | user's ID                       |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.storage            | Table with session-specific     |
    | <box_session-storage>`               | names and values                |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.on_connect()       | Define a connect trigger        |
    | <box_session-on_connect>`            |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.on_disconnect()    | Define a disconnect trigger     |
    | <box_session-on_disconnect>`         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.on_auth()          | Define an authentication        |
    | <box_session-on_auth>`               | trigger                         |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.on_access_denied() | Define a trigger to report      |
    | <box_session-on_access_denied>`      | restricted actions              |
    +--------------------------------------+---------------------------------+
    | :ref:`box.session.push()             | Send an out-of-band message     |
    | <box_session-push>`                  |                                 |
    +--------------------------------------+---------------------------------+

.. toctree::
    :hidden:

    box_session/box_session_id
    box_session/box_session_exists
    box_session/box_session_peer
    box_session/box_session_sync
    box_session/box_session_user
    box_session/box_session_type
    box_session/box_session_su
    box_session/box_session_uid
    box_session/box_session_euid
    box_session/box_session_storage
    box_session/box_session_on_connect
    box_session/box_session_on_disconnect
    box_session/box_session_on_auth
    box_session/box_session_on_access_denied
    box_session/box_session_push