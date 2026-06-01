..  _release-enterprise-changelog:

Enterprise SDK changelog
========================

    .. NOTE::

        The Enterprise SDK changelog for Tarantool 2.x is available in the `version 2.11 documentation <https://www.tarantool.io/en/doc/latest/release/enterprise-changelog/>`__.
        The Enterprise SDK changelog for Tarantool 3.x is currently under development.

Versioning policy
-----------------

A :ref:`Tarantool Enterprise SDK <tarantool_enterprise>` version consists of two parts:

..  code-block:: text

    <TARANTOOL_BASE_VERSION>-r<REVISION>


For example: ``3.6.1-0-gc42d9735b-r589``.

-   ``TARANTOOL_BASE_VERSION`` is the Community version which the Enterprise version is based on.
-   ``REVISION`` is the SDK revision. Besides Tarantool itself, it includes the ``tt`` utility, a set of open and closed source modules, and examples. Learn more from :ref:`Package contents <enterprise-package-contents>`.
