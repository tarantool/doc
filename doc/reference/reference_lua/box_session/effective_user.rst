..  _box_session-effective_user:

box.session.effective_user()
============================

.. module:: box.session

.. function:: effective_user()

    Return the name of the *effective user* -- this user determines the process's permissions at any given moment.
    If the :ref:`current user <authentication-users>` is changed temporarily using the :ref:`box.session.su() <box_session-su>` method,
    `box.session.effective_user()` shows this change.

    See also: :ref:`box.session.euid() <box_session-euid>`

    :return: the current effective user's name

    :rtype: string