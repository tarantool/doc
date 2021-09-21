=====================================================================
                            Java
=====================================================================

There are currently two Java connectors available:

* `tarantool-java <http://github.com/tarantool/tarantool-java/>`_, **no active maintenance**. Works with ancient Tarantool versions (1.6+), offers JDBC interface support for single Tarantool nodes. Does not support the newest 2.x Tarantool features and Tarantool clusters.
* `cartridge-java <http://github.com/tarantool/cartridge-java/>`_, based on the asynchronous Netty framework, supports both single Tarantool nodes and clusters, as well as applications built using Cartridge framework and its modules.

Also the following modules exist for supporting the Java libraries and frameworks:

* `Testcontainers module <http://github.com/tarantool/cartridge-java-testcontainers/>`_, adds support for the popular Testcontainers framework used for integration testing of Java applications.
* `Spring Data module <http://github.com/tarantool/cartridge-springdata/>`_, adds support for the Spring framework.

For getting familiar with using Spring Data Tarantool module in real applications,
 check out the `Spring Pet Clinic example project <http://github.com/tarantool/spring-petclinic-tarantool/>`_.
