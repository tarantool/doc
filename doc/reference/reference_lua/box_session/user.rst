..  _box_session-user:

box.session.user()
==================

..  module:: box.session

..  function:: user()

    Return the name of the :ref:`current Tarantool user <authentication-users>`.
    If the current user is changed temporarily using the :ref:`box.session.su() <box_session-su>` method,
    `box.session.user()` ignores this change.
    In this case, ``box.session.user()`` returns the initial current user (the user who calls the ``box.session.su()`` function).

    See also: :ref:`box.session.uid() <box_session-uid>`

    :return: the name of the :ref:`current user <authentication-users>`

    :rtype:  string