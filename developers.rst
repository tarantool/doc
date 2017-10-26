:orphan:
:priority: 1

----------------------
Tarantool - Developers
----------------------

.. container:: p-mainpage

    .. wp_section::
        :class: b-block-gray b-mainhead

        .. raw:: html

            <h2 class="b-mainhead__header-title">Get your data in RAM. Get compute close to data. Enjoy the performance.</h2>
            <div class="b-mainhead__header-editions">
                <div class="b-header-edition">
                    <div class="b-header-edition__commercial-icon"></div>
                    <div class="b-header-edition__title">Commercial Editions</div>
                    <div class="b-header-edition__subtitle">For critical deployments</div>
                    <a href="https://tarantool.io/unwired" class="b-header-edition__button commercial">Unwired IIOT</a>
                    <a href="https://tarantool.io/enterprise" class="b-header-edition__button commercial">Enterprise</a>
                </div>
                <div class="delimiter-line"></div>
                <div class="b-header-edition">
                    <div class="b-header-edition__community-icon"></div>
                    <div class="b-header-edition__title">Community Edition</div>
                    <div class="b-header-edition__subtitle">For emerging businesses</div>
                    <a href="http://github.com/tarantool/tarantool/" class="b-header-edition__button community">
                      Github
                      <i class="github-icon"></i>
                    </a>
                    <a href="download/download.html" class="b-header-edition__button community">
                      Download
                      <i class="download-icon"></i>
                    </a>
                </div>
            </div>

    .. wp_section::
        :class: b-block b-features
        :title: Community features

        .. container:: b-features-container

            .. container:: b-feature

                .. raw:: html

                    <div class="b-feature__icon replacement-icon"></div>

                .. container::

                    .. container:: b-feature-title

                        Compatibility

                    .. container:: b-feature-description

                        A drop-in replacement for Lua 5.1, based on LuaJIT

            .. container:: b-feature

                .. raw:: html

                    <div class="b-feature__icon transactions-icon"></div>

                .. container::

                    .. container:: b-feature-title

                        Transactions

                    .. container:: b-feature-description

                        :ref:`ACID transactions <atomic-atomic_execution>`

            .. container:: b-feature

                .. raw:: html

                    <div class="b-feature__icon query-icon"></div>

                .. container::

                    .. container:: b-feature-title

                        Query language

                    .. container:: b-feature-description

                        ANSI SQL, Lua stored procedures and triggers

                        ..
                            :ref:`server-side scripting and stored procedures <lua_tutorials>`

            .. container:: b-feature

                .. raw:: html

                    <div class="b-feature__icon product-icon"></div>

                .. container::

                    .. container:: b-feature-title

                        Extensibility

                    .. container:: b-feature-description

                        Packages for network and file I/O, HTTP, and more

            .. container:: b-feature

                .. raw:: html

                    <div class="b-feature__icon security-icon"></div>

                .. container::

                    .. container:: b-feature-title

                        Security

                    .. container:: b-feature-description

                        :ref:`authentication and access control <authentication>`

            .. container:: b-feature

                .. raw:: html

                    <div class="b-feature__icon replication-icon"></div>

                .. container::

                    .. container:: b-feature-title

                        High availability

                    .. container:: b-feature-description

                        :ref:`master-master <replication>` and sharding

.. _secondary indexes: doc/book/box/box_index.html
.. _range queries: doc/book/box/box_index.html
.. _index iterators: doc/book/box/box_index.html

.. _ACID transactions: doc/book/box/index.html?highlight=transactions#transaction-control

.. _master-slave: doc/book/administration.html#replication
.. _master-master: doc/book/administration.html#replication

.. _server-side scripting and stored procedures: doc/tutorials/lua_tutorials.html

.. _authentication and access control: doc/book/box/index.html#access-control
