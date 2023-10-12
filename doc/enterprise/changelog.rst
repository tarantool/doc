..  _enterprise_changelog:

Changelog
=========

Versioning policy
-----------------

A Tarantool Enterprise SDK version consists of two parts:

..  code-block:: text

    <TARANTOOL_BASE_VERSION>-r<REVISION>


For example: ``2.11.1-0-gc42d9735b-r589``.

-   ``TARANTOOL_BASE_VERSION`` is the Community version which the Enterprise version is based on.
-   ``REVISION`` is the SDK revision. Besides Tarantool itself, it includes the ``tt`` utility, a set of open and closed source modules, and examples. Learn more from :ref:`Package contents <enterprise-package-contents>`.

579
---

-   Updated cartridge-cli to `2.12.7 <https://github.com/tarantool/cartridge-cli/releases/tag/2.12.7>`__.
-   Updated ``tarantool-2.11`` to 2.11.1.

577
---

-   Added crud `1.2.0 <https://github.com/tarantool/crud/releases/tag/1.2.0>`__.
-   Added ddl `1.6.3 <https://github.com/tarantool/ddl/releases/tag/1.6.3>`__.
-   Added sharded-queue `0.1.0 <https://github.com/tarantool/sharded-queue/releases/tag/0.1.0>`__.
-   Added ddl `1.6.4 <https://github.com/tarantool/ddl/releases/tag/1.6.4>`__.
-   Updated tt-ee to `1.1.2 <https://github.com/tarantool/tt-ee/releases/tag/v1.1.2>`__.
-   Updated cartridge-cli to `2.12.6 <https://github.com/tarantool/cartridge-cli/releases/tag/2.12.6>`__.

563
---

-   Updated ``tarantool-2.10`` to 2.10.7.
-   Updated ``tarantool-2.11`` to 2.11.0.
-   Added kafka `1.6.6 <https://github.com/tarantool/kafka/releases/tag/1.6.6>`__.
-   Added vshard `0.1.24 <https://github.com/tarantool/vshard/releases/tag/0.1.24>`__.
-   Added metrics `1.0.0 <https://github.com/tarantool/metrics/releases/tag/1.0.0>`__.
-   Added cartridge-metrics-role `0.1.0 <https://github.com/tarantool/cartridge-metrics-role/releases/tag/0.1.0>`__.
-   Added cartridge `2.8.0 <https://github.com/tarantool/cartridge/releases/tag/2.8.0>`__.
-   Added http `1.5.0 <https://github.com/tarantool/http/releases/tag/1.5.0>`__.

557
---

-   Added checks `3.3.0 <https://github.com/tarantool/checks/releases/tag/3.3.0>`__.
-   Updated cartridge-cli to `2.12.5 <https://github.com/tarantool/cartridge-cli/releases/tag/2.12.5>`__.

553
---

-   Added ``tt-ee`` and ``tt`` environment configuration.
-   Added crud `1.1.1 <https://github.com/tarantool/crud/releases/tag/1.1.1>`__.
-   Added avro-schema `3.1.1 <https://github.com/tarantool/avro-schema/releases/tag/3.1.0>`__.
-   Added expirationd `1.4.0 <https://github.com/tarantool/expirationd/releases/tag/1.4.0>`__.
-   Added graphql `0.3.0 <https://github.com/tarantool/graphql/releases/tag/0.3.0>`__.
-   Added graphqlapi `0.0.10 <https://github.com/tarantool/graphqlapi/releases/tag/0.0.10>`__.
-   Added metrics `0.17.0 <https://github.com/tarantool/metrics/releases/tag/0.17.0>`__.
-   Added migrations `0.5.0 <https://github.com/tarantool/migrations/releases/tag/0.5.0>`__.
-   Added oracle `1.4.0 <https://github.com/tarantool/oracle/releases/tag/1.4.0>`__.
-   Added cartridge `2.7.9 <https://github.com/tarantool/cartridge/releases/tag/2.7.9>`__.
-   Added vshard `0.1.23 <https://github.com/tarantool/vshard/releases/tag/0.1.23>`__.
-   Added kafka `1.6.5 <https://github.com/tarantool/kafka/releases/tag/1.6.5>`__.

549
---

-   Updated ``tarantool-2.10`` to 2.10.6.

545
---

-   Updated ``tarantool-2.11`` to 2.11.0-rc2.

543
---

-   Added the ``tarantool-2.11`` submodule.

542
---

-   Updated ``tarantool-1.10`` to 1.10.15.

541
---

-  Updated ``tarantool-master`` to ``3.0.0-entrypoint``.

540
---

-   Updated ``tarantool-2.10`` to 2.10.5.

539
---

-   Added vshard `0.1.22 <https://github.com/tarantool/vshard/releases/tag/0.1.22>`__.

538
---

-   Updated ``tarantool-2.8`` to apply 2 hotfixes.

537
---

-   Fix non-interactive installation of the ``brew`` package.

-   Changed the owner of the ``/usr/local/bin`` directory.

-   Installed ``awscli@1`` instead of ``awscli`` since it takes much less
    time.

536
---

-   Added the missing property ``2.10`` for scope ``CACHE`` in CMakeLists.txt.

535
---

-   Added expirationd `1.3.1 <https://github.com/tarantool/expirationd/releases/tag/1.3.1>`__.

534
---

-   Added crud `1.0.0 <https://github.com/tarantool/crud/releases/tag/1.0.0>`__.

533
---

-   Use runners with label ``regular`` for builds and the tagged release
    workflow.

532
---

-   Added http `1.4.0 <https://github.com/tarantool/http/releases/tag/1.4.0>`__.
-   Added space-explorer `1.1.7 <https://github.com/tarantool/space-explorer/releases/tag/1.1.7>`__.
-   Added checks `3.2.0 <https://github.com/tarantool/checks/releases/tag/3.2.0>`__.
-   Added metrics `0.16.0 <https://github.com/tarantool/metrics/releases/tag/0.16.0>`__.
-   Added cartridge `2.7.8 <https://github.com/tarantool/cartridge/releases/tag/2.7.8>`__.

531
---

-   Added the ``-DENABLE_LTO=ON``  flag for tarantool-ee@master branch to
    CMakeLists.txt

530
---

-   Upgraded devtoolset from 8 to 9. It was required for upgrading ld from
    2.30 to 2.31+ for LTO.


529
---

-  Updated tarantool’s master branch to a recent revision.

528
---

-  Fixed code style in the Linux and macOS workflows.

527
---

-  Reliably install packages in macOS builds.

526
---

-   Refactored the way that GC64 builds are defined in the build workflow.
    There are no changes to the composition of resulting bundles.

525
---

-   Added alerting failures in builds on stable branches and integration testing
    to VK Teams chats.

524
---

-   Updated to fresh tarantool master (``2.11.0-entrypoint-107-ga18449d``)

523
---

-   Added cartridge `2.7.7 <https://github.com/tarantool/cartridge/releases/tag/2.7.7>`__.

522
---

-   Outdated workflow runs are now canceled to save CI time.

521
---

-   Added crud `0.14.1 <https://github.com/tarantool/crud/releases/tag/0.14.1>`__.
-   Added expirationd `1.3.0 <https://github.com/tarantool/expirationd/releases/tag/1.3.0>`__.
-   Added metrics `0.15.1 <https://github.com/tarantool/metrics/releases/tag/0.15.1>`__.
-   Added queue `1.2.2 <https://github.com/tarantool/queue/releases/tag/1.2.2>`__.

520
---

Release SDK by tags:

-   Run workflow in SDK docker container.
-   Upload SDK files for 1.10, 2.8, 2.10 versions to release folder.
-   Add consistency check for all versions.

519
---

*   On feature branches, SDK is now rebuilt only on relevant changes.

r518
----

*   Added frontend core `8.2.1 <https://github.com/tarantool/frontend-core/releases/tag/8.2.1>`__.
*   Added vshard `0.1.21 <https://github.com/tarantool/vshard/releases/tag/0.1.21>`__.
*   Added http `1.3.0 <https://github.com/tarantool/http/releases/tag/1.3.0>`__.
*   Added cartridge `2.7.6 <https://github.com/tarantool/cartridge/releases/tag/2.7.6>`__.

r517
----

*   Updated Tarantool EE to `2.10.4 <https://github.com/tarantool/tarantool-ee/releases/tag/2.10.4>`__.

r516
----

*   Updated bundled OpenSSL to version 1.1.1q.

r515
----

*   Removed support of Tarantool 2.7.
*   Started using ``tarantool/actions/prepare-checkout`` to make builds more stable.

r514
----

*   Remove the local registry and setup using GitHub registry.
*   Sync rocks cache to s3 and back.
*   Setup using shared runners.
*   Refactor and format ``ci-linux.yml`` and ``ci-macos.yml``.

r513
----

*   Removed kafka 1.5.0 due to a build issue with Tarantool 2.10.3 and higher.
*   Updated kafka to version `1.6.2 <https://github.com/tarantool/kafka/releases/tag/1.6.2>`__.

r512
----

* Updated tuple-keydef to version `0.0.3 <https://github.com/tarantool/tuple-keydef/releases/tag/0.0.3>`__.

r511
----

*   Enabled parallel build of rocks for macOS in CI.

r510
----

*   Updated Tarantool to :doc:`2.10.3 </release/2.10.3>`.
*   Added a readable error for the case when the flight recoder fails
    to write data due to insufficient free space on the disk device.
    Previously, it was sending a `SIGBUS` error (:tarantool-ee-issue:`196`).
*   Fixed a crash in the flight recorder caused by non-thread-safe log
    recording from multiple threads (:tarantool-ee-issue:`226`).

r502
----

*   Updated Tarantool to :doc:`2.10.2 </release/2.10.2>`.
*   Increased resolution of stored entries in flight recorder (:tarantool-ee-issue:`193`).
*   Fixed a bug in the flight recorder that resulted in skipping log entries in case
    ``box.cfg.log_level`` is less than ``flightrec_log_level`` (:tarantool-ee-issue:`201`).

r498
----

*   Updated Tarantool to :doc:`2.10.1 </release/2.10.1>`.
*   Updated Cyrus SASL to version 2.1.28.
*   Updated OpenLDAP to version 2.5.13.
*   Updated LZ4 to version 1.9.3. Fixed `CVE-2021-3520 <https://github.com/advisories/GHSA-gmc7-pqv9-966m>`__.
*   Fixed replication reconnect failure after disabling SSL encryption (:tarantool-ee-issue:`137`).
*   Fixed a crash that occurred while tyring to start an instance that has
    a compressed memtx space (:tarantool-ee-issue:`171`).
*   Fixed `CVE-2022-29242 <https://www.cve.org/CVERecord?id=CVE-2022-29242>`__ in GOST SSL engine.
*   Fixed a bug in the flight recorder reader implementation that resulted in
    a hang or error while trying to open an empty section (:tarantool-ee-issue:`187`).

r467
----

Breaking changes
~~~~~~~~~~~~~~~~

*   Default audit log format was changed to CSV.

Functionality added or changed
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Enterprise
^^^^^^^^^^

*   Implemented user-defined audit events. Now it's possible to log custom
    messages to the audit log from Lua (:tarantool-ee-issue:`65`).

*   **[Breaking change]** Switched the default audit log format to CSV. The
    format can be switched back to JSON using the new ``box.cfg.audit_format``
    configuration option (:tarantool-ee-issue:`66`).

*   Implemented the audit log filter. Now, it's possible to enable logging only
    for a subset of all audit events using the new ``box.cfg.audit_filter``
    configuration option (:tarantool-ee-issue:`67`).

Core
^^^^

*   Implement constraints and foreign keys. Now a user can create function constraints and foreign key relations
    (:tarantool-issue:`6436`).
*   Changed log level of some information messages from critical to info
    (:tarantool-issue:`4675`).
*   Added predefined system events: ``box.status``, ``box.id``, ``box.election``
    and ``box.schema`` (:tarantool-issue:`6260`).
*   Introduced transaction isolation levels in Lua and IPROTO (:tarantool-issue:`6930`).

Vinyl
^^^^^

*   Disabled the deferred DELETE optimization in Vinyl to avoid possible
    performance degradation of secondary index reads. Now, to enable the
    optimization, one has to set the ``defer_deletes`` flag in space options
    (:tarantool-issue:`4501`).

Lua
^^^

*   Added support of console autocompletion for net.box objects ``stream``
    and ``future`` (:tarantool-issue:`6305`).

Datetime
^^^^^^^^

*   Parse method to allow converting string literals in extended iso-8601
     or rfc3339 formats (:tarantool-issue:`6731`).
*   The range of supported years has been extended in all parsers to cover
     fully -5879610-06-22..5879611-07-11 (:tarantool-issue:`6731`).

Build
^^^^^

*   Added bundling of *GNU libunwind* to support backtrace feature on
    *AARCH64* architecture and distributives that don't provide *libunwind*
    package.
*   Re-enabled backtrace feature for all *RHEL* distributions by default, except
    for *AARCH64* architecture and ancient *GCC* versions, which lack compiler
    features required for backtrace (gh-4611).

Bugs fixed
~~~~~~~~~~

Enterprise
^^^^^^^^^^

*   Disabled audit log unless explicitly configured (:tarantool-ee-issue:`39`). Before this change,
    audit events were written to stderr if ``box.cfg.audit_log`` wasn't set. Now,
    audit log is disabled in this case.
*   Disabled audit logging of replicated events (:tarantool-ee-issue:`59`). Now, replicated events
    (for example, user creation) are logged only on the origin, never on a
    replica.

Core
^^^^

*   Banned DDL operations in space on_replace triggers, since they could lead
    to a crash (:tarantool-issue:`6920`).
*   Fixed a bug due to which all fibers created with ``fiber_attr_setstacksize()``
    leaked until the thread exit. Their stacks also leaked except when
    ``fiber_set_joinable(..., true)`` was used.
*   Fixed a crash in mvcc connected with secondary index conflict (:tarantool-issue:`6452`).
*   Fixed a bug which resulted in wrong space count (:tarantool-issue:`6421`).
*   Select in RO transaction now reads confirmed data, like a standalone (auotcommit) select does
    (:tarantool-issue:`6452`).

Replication
^^^^^^^^^^^

*   Fixed potential obsolete data write in synchronious replication
    due to race in accessing terms while disk write operation is in
    progress and not yet completed.
*   Fixed replicas failing to bootstrap when master is just re-started (:tarantool-issue:`6966`).

Lua
^^^

*   Fixed the behavior of tarantool console on SIGINT. Now Ctrl+C discards
    the current input and prints the new prompt (:tarantool-issue:`2717`).

Triggers
^^^^^^^^

*   Fixed assertion or segfault when MP_EXT received via net.box (:tarantool-issue:`6766`).
*   Now ROUND() properly support INTEGER and DECIMAL as the first
    argument (:tarantool-issue:`6988`).

Datetime
^^^^^^^^

*   Intervals received after datetime arithmetic operations may be improperly
    normalized if result was negative

    ..  code-block:: tarantoolsession

        tarantool> date.now() - date.now()
        ---
        - -1.000026000 seconds
        ...

    I.e. 2 immediately called ``date.now()`` produce very close values, whose
    difference should be close to 0, not 1 second (gh-6882).

Net.box
^^^^^^^

*   Changed the type of the error returned by net.box on timeout
    from ClientError to TimedOut (:tarantool-issue:`6144`).

r457
----

-   Fixed some binary protocol encryption bugs.

r455
----

-   Added :ref:`binary protocol encryption <enterprise-iproto-encryption>`.
-   Added :doc:`tuple field compression <tuple_compression>`.