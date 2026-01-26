..  _index_connector_java:

Java
====

The following Java connectors are available:

*   `tarantool-java-SDK <https://tarantool.github.io/tarantool-java-sdk/>`__ is
    the primary connector that is actively being developed and maintained. This
    connector supports current Tarantool versions and features. The
    `Spring Data <https://projects.spring.io/spring-data/>`__ and
    `Testcontainers <https://www.testcontainers.org/>`__ are implemented as modules within the
    Tarantool Java SDK project, providing seamless integration with these frameworks.

    Separate documentation is available for each major and minor Tarantool Java SDK version,
    for example: https://tarantool.github.io/tarantool-java-sdk/1.5.*/.

    For the most up-to-date documentation (including the latest changes and features),
    please refer to the dev version: https://tarantool.github.io/tarantool-java-sdk/dev/.

.. NOTE::

   The connectors below are either deprecated or are planned for deprecation.

*   `cartridge-java <http://github.com/tarantool/cartridge-java/>`__
    supports both single Tarantool nodes and clusters,
    as well as applications built using the
    `Cartridge framework <https://github.com/tarantool/cartridge>`__ and its modules.
    The Tarantool team actively updates this module with the newest Tarantool features.
*   `tarantool-java <http://github.com/tarantool/tarantool-java/>`__
    works with early Tarantool versions (1.6 and later)
    and offers JDBC interface support for single Tarantool nodes.
    This module *isn't currently maintained* and
    does not support the newest 2.x Tarantool features or Tarantool clusters.
