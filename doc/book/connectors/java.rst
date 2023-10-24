..  _index_connector_java:

Java
====

There are two Java connectors available:

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

The following modules support Java libraries and frameworks:

*   `TestContainers Tarantool module <http://github.com/tarantool/cartridge-java-testcontainers/>`__
    adds support for the popular `TestСontainers framework <https://www.testcontainers.org/>`__
    used for integration testing of Java applications.
*   `Spring Data Tarantool module <http://github.com/tarantool/cartridge-springdata/>`__
    adds support for the `Spring framework <https://projects.spring.io/spring-data/>`__.

    Check out the
    `Spring Pet Clinic project <http://github.com/tarantool/spring-petclinic-tarantool/>`__
    to get familiar with using this module in real applications.
