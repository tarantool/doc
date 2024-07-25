
Admonitions
===========

Sometimes you need to highlight a piece of information. For this purpose we use
admonitions.

In Tarantool we have 3 variants of css-style for admonitions:

*   Note:

    ..  code-block:: rst

        ..  note::

    ..  note::

        This is a note. We use it to highlight extra information that might be
        helpful for users.

        For example, :ref:`here <net_box-new>` we provide a user with extra information
        about using ``net_box.new()`` function.

*   Warning:

    ..  code-block:: rst

        ..  warning::

    ..  warning::

        This is a warning. As you might guess, we use it to warn users about something.

        For example, in the description of :doc:`/reference/reference_lua/box_session/on_connect`
        trigger we warn a user about some consequences of his actions.

*   Important:

    ..  code-block:: rst

        ..  important::

    ..  important::

        This block contains essential information that the user should know while doing something.

*   Custom admonition:

    ..  code-block:: rst

        ..  admonition:: Your title
            :class: fact

    ..  admonition:: Your title
        :class: fact

        This is a fact. ``fact`` is our custom CSS class. Use it when neither note
        nor warning doesn't fit.

        Note that this type requires a title.

        For example, :ref:`here <box-txn_management>` we highlight the rules that
        are necessary to read, and that's why we use ``fact``.

The docutils `documentation <https://docutils.sourceforge.io/docs/ref/rst/directives.html#admonitions>`_
offers many more variants for admonitions, but for now these three are enough for us.
If you think that it is time to create the new style for some of these types,
feel free to contribute or contact us to create a task.