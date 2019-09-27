.. _release_notes:

********************************************************************************
Release Notes
********************************************************************************

The Release Notes are summaries of significant changes introduced in Tarantool
:ref:`1.10.4 <whats_new_1104>`,
:ref:`1.10.3 <whats_new_1103>`,
:ref:`1.10.2 <whats_new_1102>`,
:ref:`1.9.0 <whats_new_190>`,
:ref:`1.7.6 <whats_new_176>`,
:ref:`1.7.5 <whats_new_175>`,
:ref:`1.7.4 <whats_new_174>`,
:ref:`1.7.3 <whats_new_173>`,
:ref:`1.7.2 <whats_new_172>`,
:ref:`1.7.1 <whats_new_171>`,
:ref:`1.6.9 <whats_new_169>`,
:ref:`1.6.8 <whats_new_168>`, and
:ref:`1.6.6 <whats_new_166>`.

For smaller feature changes and bug fixes, see closed
`milestones <https://github.com/tarantool/tarantool/milestones?state=closed>`_
at GitHub.

.. _whats_new_110:

--------------------------------------------------------------------------------
Version 1.10
--------------------------------------------------------------------------------

.. _whats_new_1104:

**Release 1.10.4**

Release type: stable (lts). Release date: 2019-09-26.  Tag: 1-10-4.

Announcement: https://github.com/tarantool/tarantool/releases/tag/1.10.4.

Overview

1.10.4 is the next :ref:`stable (lts) <release-policy>` release in the 1.10 series.
The label 'stable' means we have had systems running in production without known crashes,
bad results or other showstopper bugs for quite a while now.

This release resolves about 50 issues since 1.10.3.

Compatibility

Tarantool 1.10.x is backward compatible with Tarantool 1.9.x in binary data layout,
client-server protocol and replication protocol.
Please :ref:`upgrade <admin-upgrades>` using the ``box.schema.upgrade()``
procedure to unlock all the new features of the 1.10.x series when migrating
from 1.9 version.

Functionality added or changed

* (Engines) Improve dump start/stop logging. When initiating memory dump, print
  how much memory is going to be dumped, expected dump rate, ETA, and the recent
  write rate. Upon dump completion, print observed dump rate in addition to dump
  size and duration.
* (Engines) Look up key in reader thread. If a key isn't found in the tuple cache,
  we fetch it from a run file. In this case disk read and page decompression is
  done by a reader thread, however key lookup in the fetched page is still
  performed by the TX thread. Since pages are immutable, this could as well
  be done by the reader thread, which would allow us to save some precious CPU
  cycles for TX.
  Issue `4257 <https://github.com/tarantool/tarantool/issues/4257>`_.
* (Core) Improve :ref:`box.stat.net <box_introspection-box_stat>`.
  Issue `4150 <https://github.com/tarantool/tarantool/issues/4150>`_.
* (Core) Add ``idle`` to downstream status in ``box.info``.
  When a relay sends a row it updates ``last_row_time`` value with the
  current time. When ``box.info()`` is called, ``idle`` is set to
  ``current_time`` - ``last_row_time``.
* (Replication) Print corrupted rows on decoding error.
  Improve row printing to log. Print the header row by row, 16 bytes in a row,
  and format output to match ``xxd`` output:

  .. code-block:: bash

      [001] 2019-04-05 18:22:46.679 [11859] iproto V> Got a corrupted row:
      [001] 2019-04-05 18:22:46.679 [11859] iproto V> 00000000: A3 02 D6 5A E4 D9 E7 68 A1 53 8D 53 60 5F 20 3F
      [001] 2019-04-05 18:22:46.679 [11859] iproto V> 00000010: D8 E2 D6 E2 A3 02 D6 5A E4 D9 E7 68 A1 53 8D 53

* (Lua) Add type of operation to space :ref:`trigger parameters <box_space-on_replace>`.
  For example, a trigger function may now look like this:

  .. code-block:: lua

      function before_replace_trig(old, new, space_name, op_type)
          if op_type == 'INSERT' then
              return old
          else
              return new
          end
      end

  Issue `4099 <https://github.com/tarantool/tarantool/issues/4099>`_.
* (Lua) Add ``debug.sourcefile()`` and ``debug.sourcedir()`` helpers
  (and ``debug.__file__`` and ``debug.__dir__ shortcuts``) to determine
  the location of a current Lua source file.
  Part of issue `4193 <https://github.com/tarantool/tarantool/issues/4193>`_.
* (HTTP client) Add ``max_total_connections`` option in addition to
  ``max_connections`` to allow more fine-grained tuning of ``libcurl``
  connection cache. Don't restrict the total connections` with a constant value
  by default, but use ``libcurl``'s default, which scales the threshold according
  to easy handles count.
  Issue `3945 <https://github.com/tarantool/tarantool/issues/3945>`_.

Bugs fixed

* (Vinyl) Fix assertion failure in `vy_tx_handle_deferred_delete`.
  Issue `4294 <https://github.com/tarantool/tarantool/issues/4294>`_.
* (Vinyl) Don't purge deleted runs from vylog on compaction.
  Cherry-picked from issue `4218 <https://github.com/tarantool/tarantool/issues/4218>`_.
* (Vinyl) Don't throttle DDL.
  Issue `4238 <https://github.com/tarantool/tarantool/issues/4238>`_.
* (Vinyl) Fix deferred DELETE statement lost on commit.
  Issue `4248 <https://github.com/tarantool/tarantool/issues/4248>`_.
* (Vinyl) Fix assertion while recovering dumped statement.
  Issue `4222 <https://github.com/tarantool/tarantool/issues/4222>`_.
* (Vinyl) Reset dump watermark after updating memory limit.
  Issue `3864 <https://github.com/tarantool/tarantool/issues/3864>`_.
* (Vinyl) Be pessimistic about write rate when setting dump watermark.
  Issue `4166 <https://github.com/tarantool/tarantool/issues/4166>`_.
* (Vinyl) Fix crash if space is dropped while space.get is reading from it.
  Issue `4109 <https://github.com/tarantool/tarantool/issues/4109>`_.
* (Vinyl) Fix crash during index build.
  Issue `4152 <https://github.com/tarantool/tarantool/issues/4152>`_.
* (Vinyl) Don't compress L1 runs.
  Issue `2389 <https://github.com/tarantool/tarantool/issues/2389>`_.
* (Vinyl) Account statements skipped on read.
* (Vinyl) Take into account primary key lookup in latency accounting.
* (Vinyl) Fix ``vy_range_update_compaction_priority`` hang.
* (Vinyl) Free region on vylog commit instead of resetting it and clean up
  region after allocating surrogate statement.
* (Vinyl) Increase even more the open file limit in ``systemd`` unit file.
* (Vinyl) Increment min range size to 128MB
* (Memtx) Cancel checkpoint thread at exit.
  Issue `4170 <https://github.com/tarantool/tarantool/issues/4170>`_.
* (Core) Fix crash for update with empty tuple.
  Issue `4041 <https://github.com/tarantool/tarantool/issues/4041>`_.
* (Core) Fix use-after-free in ``space_truncate``.
  Issue `4093 <https://github.com/tarantool/tarantool/issues/4093>`_.
* (Core) Fix error while altering index with sequence.
  Issue `4214 <https://github.com/tarantool/tarantool/issues/4214>`_.
* (Core) Detect a new invalid json path case.
  Issue `4419 <https://github.com/tarantool/tarantool/issues/4419>`_.
* (Core) Fix empty password authentication.
  Issue `4327 <https://github.com/tarantool/tarantool/issues/4327>`_.
* (Core) Fix ``txn::sub_stmt_begin`` array size.
* (Core) Account ``index.pairs`` in ``box.stat.SELECT()``.
* (Replication) Disallow bootstrap of read-only masters.
  Issue `4321 <https://github.com/tarantool/tarantool/issues/4321>`_.
* (Replication) Enter orphan mode on manual replication configuration change.
  Issue `4424 <https://github.com/tarantool/tarantool/issues/4424>`_.
* (Replication) Set ``last_row_time`` to ``now`` in ``relay_new`` and ``relay_start``.
  PR `4431 <https://github.com/tarantool/tarantool/pull/4431>`_.
* (Replication) Stop relay on subscribe error.
  Issue `4399 <https://github.com/tarantool/tarantool/issues/4399>`_.
* (Replication) Init ``coio`` watcher before join/subscribe.
  Issue `4110 <https://github.com/tarantool/tarantool/issues/4110>`_.
* (Replication) Allow to change instance id during join.
  Issue `4107 <https://github.com/tarantool/tarantool/issues/4107>`_.
* (Replication) Fix garbage collection logic.
* (Replication) Revert packet boundary checking for iproto.
* (Replication) Do not abort replication on ER_UNKNOWN_REPLICA.
* (Replication) Reduce effects of input buffer fragmentation on large ``cfg.readahead``.
* (Replication) Fix upgrade from 1.7 (it doesn't recognize IPROTO_VOTE request type).
* (Replication) Fix memory leak in call / eval in the case when a transaction
  is not committed.
  Issue `4388 <https://github.com/tarantool/tarantool/issues/4388>`_.
* (Lua) Fix ``fio.mktree()`` error reporting.
  Issue `4044 <https://github.com/tarantool/tarantool/issues/4044>`_.
* (Lua) Fix segfault on ``ffi.C_say()`` without filename.
  Issue `4336 <https://github.com/tarantool/tarantool/issues/4336>`_.
* (Lua) Fix segfault on ``json.encode()`` on a recursive table.
  Issue `4366 <https://github.com/tarantool/tarantool/issues/4366>`_.
* (Lua) Fix ``pwd.getpwall()`` and ``pwd.getgrall()`` hang on CentOS 6
  and FreeBSD 12.
  Issues `4447 <https://github.com/tarantool/tarantool/issues/4447>`_,
  `4428 <https://github.com/tarantool/tarantool/issues/4428>`_.
* (Lua) Fix a segfault during initialization of a cipher from ``crypto`` module.
  Issue `4223 <https://github.com/tarantool/tarantool/issues/4223>`_.
* (HTTP client) Reduce stack consumption during waiting for a DNS resolving result.
  Issue `4179 <https://github.com/tarantool/tarantool/issues/4179>`_.
* (HTTP client) Increase max outgoing header size to 8 KiB.
  Issue `3959 <https://github.com/tarantool/tarantool/issues/3959>`_.
* (HTTP client) Verify "headers" option stronger.
  Issues `4281 <https://github.com/tarantool/tarantool/issues/4281>`_,
  `3679 <https://github.com/tarantool/tarantool/issues/3679>`_.
* (HTTP client) Use bundled ``libcurl`` rather than system-wide by default.
  Issues `4318 <https://github.com/tarantool/tarantool/issues/4318>`_,
  `4180 <https://github.com/tarantool/tarantool/issues/4180>`_,
  `4288 <https://github.com/tarantool/tarantool/issues/4288>`_,
  `4389 <https://github.com/tarantool/tarantool/issues/4389>`_,
  `4397 <https://github.com/tarantool/tarantool/issues/4397>`_.
* (HTTP client) This closes several known problems that were fixed in recent
  ``libcurl`` versions, including segfaults, hangs, memory leaks and performance
  problems.
* (LuaJIT) Fix overflow of snapshot map offset.
  Part of issue `4171 <https://github.com/tarantool/tarantool/issues/4171>`_.
* (LuaJIT) Fix rechaining of pseudo-resurrected string keys.
  Part of issue `4171 <https://github.com/tarantool/tarantool/issues/4171>`_.
* (LuaJIT) Fix fold machinery misbehaves.
  Issue `4376 <https://github.com/tarantool/tarantool/issues/4376>`_.
* (LuaJIT) Fix for `debug.getinfo(1,'>S')`.
  Issue `3833 <https://github.com/tarantool/tarantool/issues/3833>`_.
* (LuaJIT) Fix `string.find` recording.
  Issue `4476 <https://github.com/tarantool/tarantool/issues/4476>`_.
* (LuaJIT) Fixed a segfault when unsinking 64-bit pointers.
* (Misc) Increase even more the open file limit in ``systemd`` unit file.
* (Misc) Raise error in ``tarantoolctl`` when ``box.cfg()`` isn't called.
  Issue `3953 <https://github.com/tarantool/tarantool/issues/3953>`_.
* (Misc) Support ``systemd``’s NOTIFY_SOCKET on OS X.
  Issue `4436 <https://github.com/tarantool/tarantool/issues/4436>`_.
* (Misc) Fix ``coio_getaddrinfo()`` when 0 timeout is passed
  (affects ``netbox``’s ``connect_timeout``).
  Issue `4209 <https://github.com/tarantool/tarantool/issues/4209>`_.
* (Misc) Fix ``coio_do_copyfile()`` to perform truncate of destination
  (affects ``fio.copyfile()``).
  Issue `4181 <https://github.com/tarantool/tarantool/issues/4181>`_.
* (Misc) Make hints in ``coio_getaddrinfo()`` optional.
* (Misc) Validate ``msgpack.decode()`` cdata size argument.
  Issue `4224 <https://github.com/tarantool/tarantool/issues/4224>`_.
* (Misc) Fix linking with static ``openssl`` library.
  Issue `4437 <https://github.com/tarantool/tarantool/issues/4437>`_.

Deprecations

* (Core) Deprecate ``rows_per_wal`` in favor of ``wal_max_size``.
  Part of issue `3762 <https://github.com/tarantool/tarantool/issues/3762>`_.

.. _whats_new_1103:

**Release 1.10.3**

Release type: stable (lts). Release date: 2019-04-01.  Tag: 1-10-3.

Announcement: https://github.com/tarantool/tarantool/releases/tag/1.10.3.

Overview

1.10.3 is the next :ref:`stable (lts) <release-policy>` release in the 1.10 series.
The label 'stable' means we have had systems running in production without known crashes,
bad results or other showstopper bugs for quite a while now.

This release resolves 69 issues since 1.10.2.

Compatibility

Tarantool 1.10.x is backward compatible with Tarantool 1.9.x in binary data layout, client-server protocol and replication protocol.
Please :ref:`upgrade <admin-upgrades>` using the ``box.schema.upgrade()`` procedure to unlock all the new features of the 1.10.x series when migrating from 1.9 version.

Functionality added or changed

* (Engines) Randomize vinyl index compaction
  Issue `3944 <https://github.com/tarantool/tarantool/issues/3944>`_.
* (Engines) Throttle tx thread if compaction doesn't keep up with dumps
  Issue `3721 <https://github.com/tarantool/tarantool/issues/3721>`_.
* (Engines) Do not apply run_count_per_level to the last level
  Issue `3657 <https://github.com/tarantool/tarantool/issues/3657>`_.
* (Server) Report the number of active iproto connections
  Issue `3905 <https://github.com/tarantool/tarantool/issues/3905>`_.
* (Replication) Never keep a dead replica around if running out of disk space
  Issue `3397 <https://github.com/tarantool/tarantool/issues/3397>`_.
* (Replication) Report join progress to the replica log
  Issue `3165 <https://github.com/tarantool/tarantool/issues/3165>`_.
* (Lua) Expose snapshot status in box.info.gc()
  Issue `3935 <https://github.com/tarantool/tarantool/issues/3935>`_.
* (Lua) Show names of Lua functions in backtraces in fiber.info()
  Issue `3538 <https://github.com/tarantool/tarantool/issues/3538>`_.
* (Lua) Check if transaction opened
  Issue `3518 <https://github.com/tarantool/tarantool/issues/3518>`_.

Bugs fixed

* (Engines) Tarantool crashes if DML races with DDL
  Issue `3420 <https://github.com/tarantool/tarantool/issues/3420>`_.
* (Engines) Recovery error if DDL is aborted
  Issue `4066 <https://github.com/tarantool/tarantool/issues/4066>`_.
* (Engines) Tarantool could commit in the read-only mode
  Issue `4016 <https://github.com/tarantool/tarantool/issues/4016>`_.
* (Engines) Vinyl iterator crashes if used throughout DDL
  Issue `4000 <https://github.com/tarantool/tarantool/issues/4000>`_.
* (Engines) Vinyl doesn't exit until dump/compaction is complete
  Issue `3949 <https://github.com/tarantool/tarantool/issues/3949>`_.
* (Engines) After re-creating secondary index no data is visible
  Issue `3903 <https://github.com/tarantool/tarantool/issues/3903>`_.
* (Engines) box.info.memory().tx underflow
  Issue `3897 <https://github.com/tarantool/tarantool/issues/3897>`_.
* (Engines) Vinyl stalls on intensive random insertion
  Issue `3603 <https://github.com/tarantool/tarantool/issues/3603>`_.
* (Server) Newer version of libcurl explodes fiber stack
  Issue `3569 <https://github.com/tarantool/tarantool/issues/3569>`_.
* (Server) SIGHUP crashes tarantool
  Issue `4063 <https://github.com/tarantool/tarantool/issues/4063>`_.
* (Server) checkpoint_daemon.lua:49: bad argument #2 to 'format'
  Issue `4030 <https://github.com/tarantool/tarantool/issues/4030>`_.
* (Server) fiber:name() show only part of name
  Issue `4011 <https://github.com/tarantool/tarantool/issues/4011>`_.
* (Server) Second hot standby switch may fail
  Issue `3967 <https://github.com/tarantool/tarantool/issues/3967>`_.
* (Server) Updating box.cfg.readahead doesn't affect existing connections
  Issue `3958 <https://github.com/tarantool/tarantool/issues/3958>`_.
* (Server) fiber.join() blocks in 'suspended' if fiber has cancelled
  Issue `3948 <https://github.com/tarantool/tarantool/issues/3948>`_.
* (Server) Tarantool can be crashed by sending gibberish to a binary socket
  Issue `3900 <https://github.com/tarantool/tarantool/issues/3900>`_.
* (Server) Stored procedure to produce push-messages never breaks on client disconnect
  Issue `3859 <https://github.com/tarantool/tarantool/issues/3559>`_.
* (Server) Tarantool crashed in lj_vm_return
  Issue `3840 <https://github.com/tarantool/tarantool/issues/3840>`_.
* (Server) Fiber executing box.cfg() may process messages from iproto
  Issue `3779 <https://github.com/tarantool/tarantool/issues/3779>`_.
* (Server) Possible regression on nosqlbench
  Issue `3747 <https://github.com/tarantool/tarantool/issues/3747>`_.
* (Server) Assertion after improper index creation
  Issue `3744 <https://github.com/tarantool/tarantool/issues/3744>`_.
* (Server) Tarantool crashes on vshard startup (lj_gc_step)
  Issue `3725 <https://github.com/tarantool/tarantool/issues/3725>`_.
* (Server) Do not restart replication on box.cfg if the configuration didn't change
  Issue `3711 <https://github.com/tarantool/tarantool/issues/3711>`_.
* (Replication) Applier times out too fast when reading large tuples
  Issue `4042 <https://github.com/tarantool/tarantool/issues/4042>`_.
* (Replication) Vinyl replica join fails
  Issue `3968 <https://github.com/tarantool/tarantool/issues/3968>`_.
* (Replication) Error during replication
  Issue `3910 <https://github.com/tarantool/tarantool/issues/3910>`_.
* (Replication) Downstream status doesn't show up in replication.info unless the channel is broken
  Issue `3904 <https://github.com/tarantool/tarantool/issues/3904>`_.
* (Replication) replication fails: tx checksum mismatch
  Issue `3993 <https://github.com/tarantool/tarantool/issues/3883>`_.
* (Replication) Rebootstrap crashes if master has replica's rows
  Issue `3740 <https://github.com/tarantool/tarantool/issues/3740>`_.
* (Replication) After restart tuples revert back to their old state which was before replica sync
  Issue `3722 <https://github.com/tarantool/tarantool/issues/3722>`_.
* (Replication) Add vclock for safer hot standby switch
  Issue `3002 <https://github.com/tarantool/tarantool/issues/3002>`_.
* (Replication) Master row is skipped forever in case of wal write failure
  Issue `2283 <https://github.com/tarantool/tarantool/issues/2283>`_.
* (Lua) space:frommap():tomap() conversion fail
  Issue `4045 <https://github.com/tarantool/tarantool/issues/4045>`_.
* (Lua) Non-informative message when trying to read a negative count of bytes from socket
  Issue `3979 <https://github.com/tarantool/tarantool/issues/3979>`_.
* (Lua) space:frommap raise "tuple field does not match..." even for nullable field
  Issue `3883 <https://github.com/tarantool/tarantool/issues/3883>`_.
* (Lua) Tarantool crashes on net.box.call after some uptime with vshard internal fiber
  Issue `3751 <https://github.com/tarantool/tarantool/issues/3751>`_.
* (Lua) Heap use after free in lbox_error
  Issue `1955 <https://github.com/tarantool/tarantool/issues/1955>`_.
* (Misc) http.client doesn't honour 'connection: keep-alive'
  Issue `3955 <https://github.com/tarantool/tarantool/issues/3955>`_.
* (Misc) net.box wait_connected is broken
  Issue `3856 <https://github.com/tarantool/tarantool/issues/3856>`_.
* (Misc) Mac build fails on Mojave
  Issue `3797 <https://github.com/tarantool/tarantool/issues/3797>`_.
* (Misc) FreeBSD build error: no SSL support
  Issue `3750 <https://github.com/tarantool/tarantool/issues/3750>`_.
* (Misc) 'http.client' sets invalid (?) reason
  Issue `3681 <https://github.com/tarantool/tarantool/issues/3681>`_.
* (Misc) Http client silently modifies headers when value is not a "string" or a "number"
  Issue `3679 <https://github.com/tarantool/tarantool/issues/3679>`_.
* (Misc) yaml.encode uses multiline format for 'false' and 'true'
  Issue `3662 <https://github.com/tarantool/tarantool/issues/3662>`_.
* (Misc) yaml.encode encodes 'null' incorrectly
  Issue `3583 <https://github.com/tarantool/tarantool/issues/3583>`_.
* (Misc) Error object message is empty
  Issue `3604 <https://github.com/tarantool/tarantool/issues/3604>`_.
* (Misc) Log can be flooded by warning messages
  Issue `2218 <https://github.com/tarantool/tarantool/issues/2218>`_.

Deprecations

* Deprecate ``console=true`` option for :ref:`net.box.new() <net_box-new>`.

.. _whats_new_1102:

**Release 1.10.2**

Release type: stable (lts). Release date: 2018-10-13.  Tag: 1-10-2.

Announcement: https://github.com/tarantool/tarantool/releases/tag/1.10.2.

This is the first :ref:`stable (lts) <release-policy>` release in the 1.10
series.
Also, Tarantool 1.10.2 is a major release that deprecates Tarantool 1.9.2.
It resolves 95 issues since 1.9.2.

Tarantool 1.10.x is backward compatible with Tarantool 1.9.x in binary data
layout, client-server protocol and replication protocol.
You can :ref:`upgrade <admin-upgrades>` using the ``box.schema.upgrade()``
procedure.

The goal of this release is to significantly increase ``vinyl`` stability and
introduce automatic rebootstrap of a Tarantool replica set.

Functionality added or changed:

  * (Engines) support ALTER for non-empty vinyl spaces.
    Issue `1653 <https://github.com/tarantool/tarantool/issues/1653>`_.
  * (Engines) tuples stored in the vinyl cache are not shared among the indexes
    of the same space.
    Issue `3478 <https://github.com/tarantool/tarantool/issues/3478>`_.
  * (Engines) keep a stack of UPSERTS in ``vy_read_iterator``.
    Issue `1833 <https://github.com/tarantool/tarantool/issues/1833>`_.
  * (Engines) ``box.ctl.reset_stat()``, a function to reset vinyl statistics.
    Issue `3198 <https://github.com/tarantool/tarantool/issues/3198>`_.

  * (Server) :ref:`configurable syslog destination <cfg_logging-log>`.
    Issue `3487 <https://github.com/tarantool/tarantool/issues/3487>`_.
  * (Server) allow different nullability in indexes and format.
    Issue `3430 <https://github.com/tarantool/tarantool/issues/3430>`_.
  * (Server) allow to
    :ref:`back up any checkpoint <admin-backups-backup_start>`,
    not just the last one.
    Issue `3410 <https://github.com/tarantool/tarantool/issues/3410>`_.
  * (Server) a way to detect that a Tarantool process was
    started / restarted by ``tarantoolctl``
    (:ref:`TARANTOOLCTL and TARANTOOL_RESTARTED <tarantoolctl-instance_management>`
    env vars).
    Issues `3384 <https://github.com/tarantool/tarantool/issues/3384>`_,
    `3215 <https://github.com/tarantool/tarantool/issues/3215>`_.
  * (Server) :ref:`net_msg_max <cfg_networking-net_msg_max>`
    configuration parameter to restrict the number of allocated fibers.
    Issue `3320 <https://github.com/tarantool/tarantool/issues/3320>`_.

  * (Replication)
    display the connection status if the downstream gets disconnected from
    the upstream
    (:ref:`box.info.replication.downstream.status <box_info_replication>`
    ``= disconnected``).
    Issue `3365 <https://github.com/tarantool/tarantool/issues/3365>`_.
  * (Replication) :ref:`replica-local spaces <replication-local>`
    Issue `3443 <https://github.com/tarantool/tarantool/issues/3443>`_.
  * (Replication)
    :ref:`replication_skip_conflict <cfg_replication-replication_skip_conflict>`,
    a new option in ``box.cfg{}`` to skip conflicting rows in replication.
    Issue `3270 <https://github.com/tarantool/tarantool/issues/3270>`_.
  * (Replication)
    remove old snapshots which are not needed by replicas.
    Issue `3444 <https://github.com/tarantool/tarantool/issues/3444>`_.
  * (Replication)
    log records which tried to commit twice.
    Issue `3105 <https://github.com/tarantool/tarantool/issues/3105>`_.

  * (Lua) new function :ref:`fiber.join() <fiber_object-join>`.
    Issue `1397 <https://github.com/tarantool/tarantool/issues/1397>`_.
  * (Lua) new option ``names_only`` to :ref:`tuple:tomap() <box_tuple-tomap>`.
    Issue `3280 <https://github.com/tarantool/tarantool/issues/3280>`_.
  * (Lua) support custom rock servers (``server`` and ``only-server``
    options for :ref:`tarantoolctl rocks <tarantoolctl-module_management>`
    command).
    Issue `2640 <https://github.com/tarantool/tarantool/issues/2640>`_.

  * (Lua) expose ``on_commit``/``on_rollback`` triggers to Lua;
    Issue `857 <https://github.com/tarantool/tarantool/issues/857>`_.
  * (Lua) new function :ref:`box.is_in_txn() <box-is_in_txn>`
    to check if a transaction is open;
    Issue `3518 <https://github.com/tarantool/tarantool/issues/3518>`_.
  * (Lua) tuple field access via a json path
    (by :ref:`number <box_tuple-field_number>`,
    :ref:`name <box_tuple-field_name>`, and
    :ref:`path <box_tuple-field_path>`);
    Issue `1285 <https://github.com/tarantool/tarantool/issues/1285>`_.
  * (Lua) new function :ref:`space:frommap() <box_space-frommap>`;
    Issue `3282 <https://github.com/tarantool/tarantool/issues/3282>`_.
  * (Lua) new module :ref:`utf8 <utf8-module>` that implements libicu's bindings
    for use in Lua;
    Issues `3290 <https://github.com/tarantool/tarantool/issues/3290>`_,
    `3385 <https://github.com/tarantool/tarantool/issues/3385>`_.

.. _whats_new_19:

--------------------------------------------------------------------------------
Version 1.9
--------------------------------------------------------------------------------

.. _whats_new_190:

**Release 1.9.0**

Release type: stable. Release date: 2018-02-26.  Tag: 1.9.0-4-g195d446.

Announcement: https://github.com/tarantool/tarantool/releases/tag/1.9.0.

This is the successor of the 1.7.6 stable release.
The goal of this release is increased maturity of vinyl and master-master replication,
and it contributes a number of features to this cause. Please follow the download
instructions at https://tarantool.io/en/download/download.html to download and install
a package for your operating system.

Functionality added or changed:

  * (Security) it is now possible to
    :ref:`block/unblock <authentication-owners_privileges>` users.
    Issue `2898 <https://github.com/tarantool/tarantool/issues/2898>`_.
  * (Security) new function :ref:`box.session.euid() <box_session-euid>` to return effective user.
    Effective user can be different from authenticated user in case of ``setuid``
    functions or ``box.session.su``.
    Issue `2994 <https://github.com/tarantool/tarantool/issues/2994>`_.
  * (Security) new :ref:`super <box_space-user>` role, with superuser access. Grant 'super' to guest to
    disable access control.
    Issue `3022 <https://github.com/tarantool/tarantool/issues/3022>`_.
  * (Security) :ref:`on_auth <box_session-on_auth>` trigger is now fired in case of both successful and
    failed authentication.
    Issue `3039 <https://github.com/tarantool/tarantool/issues/3039>`_.
  * (Replication/recovery) new replication configuration algorithm: if replication
    doesn't connect to replication_quorum peers in :ref:`replication_connect_timeout <cfg_replication-replication_connect_timeout>`
    seconds, the server start continues but the server enters the new :ref:`orphan <replication-orphan_status>` status,
    which is basically read-only, until the replicas connect to each other.
    Issues `3151 <https://github.com/tarantool/tarantool/issues/3151>`_ and
    `2958 <https://github.com/tarantool/tarantool/issues/2958>`_.
  * (Replication/recovery) after replication connect at startup, the server does
    not start processing write requests before
    :ref:`syncing up <replication-orphan_status>` syncing up with all connected peers.
  * (Replication/recovery) it is now possible to explicitly set
    :ref:`instance_uuid <cfg_replication-instance_uuid>` and
    :ref:`replica set uuid <cfg_replication-replicaset_uuid>` as configuration parameters.
    Issue `2967 <https://github.com/tarantool/tarantool/issues/2967>`_.
  * (Replication/recovery) :ref:`box.once() <box-once>` no longer fails on a read-only replica
    but waits.
    Issue `2537 <https://github.com/tarantool/tarantool/issues/2537>`_.
  * (Replication/recovery) :ref:`force_recovery <cfg_binary_logging_snapshots-force_recovery>` can now skip a corrupted xlog file.
    Issue `3076 <https://github.com/tarantool/tarantool/issues/3076>`_.
  * (Replication/recovery) improved replication monitoring: :ref:`box.info.replication <box_info_replication>`
    shows peer ip:port and correct replication lag even for idle peers.
    Issues `2753 <https://github.com/tarantool/tarantool/issues/2753>`_ and
    `2689 <https://github.com/tarantool/tarantool/issues/2689>`_.
  * (Application server) new :ref:`before <box_space-before_replace>` triggers which can be used for conflict
    resolution in master-master replication.
    Issue `2993 <https://github.com/tarantool/tarantool/issues/2993>`_.
  * (Application server) :ref:`http client <http-module>` now correctly parses cookies and supports
    http+unix:// paths.
    Issues `3040 <https://github.com/tarantool/tarantool/issues/3040>`_ and
    `2801 <https://github.com/tarantool/tarantool/issues/2801>`_.
  * (Application server) ``fio`` rock now supports ``file_exists()``,
    ``rename()`` works across filesystems, and ``read()`` without arguments
    reads the whole file.
    Issues `2924 <https://github.com/tarantool/tarantool/issues/2924>`_,
    `2751 <https://github.com/tarantool/tarantool/issues/2751>`_ and
    `2925 <https://github.com/tarantool/tarantool/issues/2925>`_.
  * (Application server) ``fio`` rock errors now follow Tarantool function call
    conventions and always return an error message in addition to the error flag.
  * (Application server) ``digest`` rock now supports pbkdf2 password hashing
    algorithm, useful in PCI/DSS compliant applications.
    Issue `2874 <https://github.com/tarantool/tarantool/issues/2874>`_.
  * (Application server) :ref:`box.info.memory() <box_info_memory>` provides a high-level overview of
    server memory usage, including networking, Lua, transaction and index memory.
    Issue `934 <https://github.com/tarantool/tarantool/issues/934>`_.
  * (Database) it is now possible to :ref:`add missing tuple fields <box_space-is_nullable>` to an index,
    which is very useful when adding an index along with the evolution of the
    database schema.
    Issue `2988 <https://github.com/tarantool/tarantool/issues/2988>`_.
  * (Database) lots of improvements in field type support when creating or
    :ref:`altering <box_index-alter>` spaces and indexes.
    Issues `2893 <https://github.com/tarantool/tarantool/issues/2893>`_,
    `3011 <https://github.com/tarantool/tarantool/issues/3011>`_ and
    `3008 <https://github.com/tarantool/tarantool/issues/3008>`_.
  * (Database) it is now possible to turn on :ref:`is_nullable <box_space-is_nullable>` property on a field
    even if the space is not empty, the change is instantaneous.
    Issue `2973 <https://github.com/tarantool/tarantool/issues/2973>`_.
  * (Database) :ref:`logging <log-module>` has been improved in many respects: individual messages
    (issues `1972 <https://github.com/tarantool/tarantool/issues/1972>`_,
    `2743 <https://github.com/tarantool/tarantool/issues/2743>`_,
    `2900 <https://github.com/tarantool/tarantool/issues/2900>`_),
    more logging in cases when it was useful
    (issues `3096 <https://github.com/tarantool/tarantool/issues/3096>`_,
    `2871 <https://github.com/tarantool/tarantool/issues/2871>`_).
  * (Vinyl storage engine) it is now possible to make a :ref:`unique <box_index-unique>` vinyl index
    non-unique without index rebuild.
    Issue `2449 <https://github.com/tarantool/tarantool/issues/2449>`_.
  * (Vinyl storage engine) improved UPDATE, REPLACE and recovery performance in
    presence of secondary keys.
    Issues `2289 <https://github.com/tarantool/tarantool/issues/2289>`_,
    `2875 <https://github.com/tarantool/tarantool/issues/2875>`_ and
    `3154 <https://github.com/tarantool/tarantool/issues/3154>`_.
  * (Vinyl storage engine) :ref:`space:len() <box_space-len>` and
    :ref:`space:bsize() <box_space-bsize>` now work for
    vinyl (although they are still not exact).
    Issue `3056 <https://github.com/tarantool/tarantool/issues/3056>`_.
  * (Vinyl storage engine) recovery speed has improved in presence of secondary
    keys.
    Issue `2099 <https://github.com/tarantool/tarantool/issues/2099>`_.
  * (Builds) Alpine Linux support.
    Issue `3067 <https://github.com/tarantool/tarantool/issues/3067>`_.

.. _whats_new_17:

--------------------------------------------------------------------------------
Version 1.7
--------------------------------------------------------------------------------

.. _whats_new_176:

**Release 1.7.6**

Release type: stable. Release date: 2017-11-07.  Tag: 1.7.6-0-g7b2945d6c.

Announcement: https://groups.google.com/forum/#!topic/tarantool/hzc7O2YDZUc.

This is the next stable release in the 1.7 series.
It resolves more than 75 issues since 1.7.5.

What's new in Tarantool 1.7.6?

  * In addition to :ref:`rollback <box-rollback>` of a transaction, there is now
    rollback to a defined point within a transaction -- :ref:`savepoint <box-savepoint>` support.
  * There is a new object type: :ref:`sequences <index-box_sequence>`.
    The older option, :ref:`auto-increment <box_space-auto_increment>`, will be deprecated.
  * String indexes can have :ref:`collations <index-collation>`.

New options are available for:

  * :ref:`net_box <net_box-module>` (timeouts),
  * :ref:`string <string-module>` functions,
  * space :ref:`formats <box_space-format>` (user-defined field names and types),
  * :ref:`base64 <digest-base64_encode>` (``urlsafe`` option), and
  * index :ref:`creation <box_space-create_index>`
    (collation, :ref:`is-nullable <box_space-is_nullable>`, field names).

Incompatible changes:

  * Layout of ``box.space._index`` has been extended to support
    :ref:`is_nullable <box_space-is_nullable>`
    and :ref:`collation <index-collation>` features.
    All new indexes created on columns with ``is_nullable`` or ``collation``
    properties will have the new definition format.
    Please update your client libraries if you plan to use these new features.
    Issue `2802 <https://github.com/tarantool/tarantool/issues/2802>`_
  * :ref:`fiber_name() <fiber_object-name_get>` now raises an exception instead of truncating long fiber names.
    We found that some Lua modules such as :ref:`expirationd <expirationd-module>` use ``fiber.name()``
    as a key to identify background tasks. If a name is truncated, this fact was
    silently missed. The new behavior allows to detect bugs caused by ``fiber.name()``
    truncation. Please use ``fiber.name(name, { truncate = true })`` to emulate
    the old behavior.
    Issue `2622 <https://github.com/tarantool/tarantool/issues/2622>`_
  * :ref:`space:format() <box_space-format>` is now validated on DML operations.
    Previously ``space:format()`` was only used by client libraries, but starting
    from Tarantoool 1.7.6, field types in ``space:format()`` are validated on the
    server side on every DML operation, and field names can be used in indexes
    and Lua code. If you used ``space:format()`` in a non-standard way,
    please update layout and type names according to the official documentation for
    space formats.

Functionality added or changed:

  * Hybrid schema-less + schemaful data model.
    Earlier Tarantool versions allowed to store arbitrary MessagePack documents in spaces.
    Starting from Tarantool 1.7.6, you can use
    :ref:`space:format() <box_space-format>` to define schema restrictions and constraints
    for tuples in spaces. Defined field types are automatically validated on every DML operation,
    and defined field names can be used instead of field numbers in Lua code.
    A new function :ref:`tuple:tomap() <box_tuple-tomap>` was added to convert a tuple into a key-value Lua dictionary.
  * Collation and Unicode support.
    By default, when Tarantool compares strings, it takes into consideration only the numeric
    value of each byte in the string. To allow the ordering that you see in phone books and dictionaries,
    Tarantool 1.7.6 introduces support for collations based on the
    `Default Unicode Collation Element Table (DUCET) <http://unicode.org/reports/tr10/#Default_Unicode_Collation_Element_Table>`_
    and the rules described in
    `Unicode® Technical Standard #10 Unicode Collation Algorithm (UTS #10 UCA) <http://unicode.org/reports/tr10>`_
    See :ref:`collations <index-collation>`.
  * NULL values in unique and non-unique indexes.
    By default, all fields in Tarantool are  "NOT NULL".
    Starting from Tarantool 1.7.6, you can use
    ``is_nullable`` option in :ref:`space:format() <box_space-format>`
    or :ref:`inside an index part definition <box_space-is_nullable>`
    to allow storing NULL in indexes.
    Tarantool partially implements
    `three-valued logic <https://en.wikipedia.org/wiki/Three-valued_logic>`_
    from the SQL standard and allows storing multiple NULL values in unique indexes.
    Issue `1557 <https://github.com/tarantool/tarantool/issues/1557>`_.
  * Sequences and a new implementation of :ref:`auto_increment() <box_space-auto_increment>`.
    Tarantool 1.7.6 introduces new
    :ref:`sequence number generators <index-box_sequence>` (like CREATE SEQUENCE in SQL).
    This feature is used to implement new persistent auto increment in spaces.
    Issue `389 <https://github.com/tarantool/tarantool/issues/389>`_.
  * Vinyl: introduced gap locks in Vinyl transaction manager.
    The new locking mechanism in Vinyl TX manager reduces the number of conflicts in transactions.
    Issue `2671 <https://github.com/tarantool/tarantool/issues/2671>`_.
  * net.box: :ref:`on_connect <box_session-on_connect>`
    and :ref:`on_disconnect <box_session-on_disconnect>` triggers.
    Issue `2858 <https://github.com/tarantool/tarantool/issues/2858>`_.
  * Structured logging in :ref:`JSON format <cfg_logging-log_format>`.
    Issue `2795 <https://github.com/tarantool/tarantool/issues/2795>`_.
  * (Lua) Lua: :ref:`string.strip() <string-strip>`
    Issue `2785 <https://github.com/tarantool/tarantool/issues/2785>`_.
  * (Lua) added :ref:`base64_urlsafe_encode() <digest-base64_encode>` to ``digest`` module.
    Issue `2777 <https://github.com/tarantool/tarantool/issues/2777>`_.
  * Log conflicted keys in master-master replication.
    Issue `2779 <https://github.com/tarantool/tarantool/issues/2779>`_.
  * Allow to disable backtrace in :ref:`fiber.info() <fiber-info>`.
    Issue `2878 <https://github.com/tarantool/tarantool/issues/2878>`_.
  * Implemented ``tarantoolctl rocks make *.spec``.
    Issue `2846 <https://github.com/tarantool/tarantool/issues/2846>`_.
  * Extended the default loader to look for ``.rocks`` in the parent dir hierarchy.
    Issue `2676 <https://github.com/tarantool/tarantool/issues/2676>`_.
  * ``SOL_TCP`` options support in :ref:`socket:setsockopt() <socket-setsockopt>`.
    Issue `598 <https://github.com/tarantool/tarantool/issues/598>`_.
  * Partial emulation of LuaSocket on top of Tarantool Socket.
    Issue `2727 <https://github.com/tarantool/tarantool/issues/2727>`_.

Developer tools:

  * Integration with IntelliJ IDEA with debugging support.
    Now you can use IntelliJ IDEA as an IDE to develop and debug Lua applications for Tarantool.
    See :ref:`Using IDE <app_server-using_ide>`.
  * Integration with `MobDebug <https://github.com/pkulchenko/MobDebug>`_ remote Lua debugger.
    Issue `2728 <https://github.com/tarantool/tarantool/issues/2728>`_.
  * Configured ``/usr/bin/tarantool`` as an alternative Lua interpreter on Debian/Ubuntu.
    Issue `2730 <https://github.com/tarantool/tarantool/issues/2730>`_.

New rocks:

  * `smtp.client <https://github.com/tarantool/smtp>`_ - support SMTP via ``libcurl``.

.. _whats_new_175:

**Release 1.7.5**

Release type: stable. Release date: 2017-08-22.  Tag: 1.7.5.

Announcement: https://github.com/tarantool/doc/issues/289.

This is a stable release in the 1.7 series.
This release resolves more than 160 issues since 1.7.4.

Functionality added or changed:

  * (Vinyl) a new :ref:`force_recovery <cfg_binary_logging_snapshots-force_recovery>`
    mode to recover broken disk files.
    Use ``box.cfg{force_recovery=true}`` to recover corrupted data files
    after hardware issues or power outages.
    Issue `2253 <https://github.com/tarantool/tarantool/issues/2253>`_.
  * (Vinyl) index options can be changed on the fly without rebuild.
    Now :ref:`page_size <cfg_storage-vinyl_page_size>`,
    :ref:`run_size_ratio <cfg_storage-vinyl_run_size_ratio>`,
    :ref:`run_count_per_level <cfg_storage-vinyl_run_count_per_level>`
    and :ref:`bloom_fpr <cfg_storage-vinyl_bloom_fpr>`
    index options can be dynamically changed via :ref:`index:alter() <box_index-alter>`.
    The changes take effect in newly created data files only.
    Issue `2109 <https://github.com/tarantool/tarantool/issues/2109>`_.
  * (Vinyl) improve :ref:`box.info.vinyl() <box_introspection-box_info>` and ``index:info()`` output.
    Issue `1662 <https://github.com/tarantool/tarantool/issues/1662>`_.
  * (Vinyl) introduce :ref:`box.cfg.vinyl_timeout <cfg_basic-vinyl_timeout>` option to control quota throttling.
    Issue `2014 <https://github.com/tarantool/tarantool/issues/2014>`_.
  * Memtx: stable :ref:`index:pairs() <box_index-index_pairs>` iterators for the TREE index.
    TREE iterators are automatically restored to a proper position after index's modifications.
    Issue `1796 <https://github.com/tarantool/tarantool/issues/1796>`_.
  * (Memtx) :ref:`predictable order <box_index-index_pairs>` for non-unique TREE indexes.
    Non-unique TREE indexes preserve the sort order for duplicate entries.
    Issue `2476 <https://github.com/tarantool/tarantool/issues/2476>`_.
  * (Memtx+Vinyl) dynamic configuration of :ref:`max tuple size <cfg_storage-memtx_max_tuple_size>`.
    Now ``box.cfg.memtx_max_tuple_size`` and ``box.cfg.vinyl_max_tuple_size``
    configuration options can be changed on the fly without need to restart the server.
    Issue `2667 <https://github.com/tarantool/tarantool/issues/2667>`_.
  * (Memtx+Vinyl) new implementation.
    Space :ref:`truncation <box_space-truncate>` doesn't cause re-creation of all indexes any more.
    Issue `618 <https://github.com/tarantool/tarantool/issues/618>`_.
  * Extended the :ref:`maximal length <limitations_length>` of all identifiers from 32 to 65k characters.
    Space, user and function names are not limited by 32 characters anymore.
    Issue `944 <https://github.com/tarantool/tarantool/issues/944>`_.
  * :ref:`Heartbeat <cfg_replication-replication_timeout>` messages for replication.
    Replication client now sends the selective acknowledgments for processed
    records and automatically re-establish stalled connections.
    This feature also changes :ref:`box.info.replication[replica_id].vclock <box_info_replication>`.
    to display committed vclock of remote replica.
    Issue `2484 <https://github.com/tarantool/tarantool/issues/2484>`_.
  * Keep track of remote replicas during WAL maintenance.
    Replication master now automatically preserves xlogs needed for remote replicas.
    Issue `748 <https://github.com/tarantool/tarantool/issues/748>`_.
  * Enabled :ref:`box.tuple.new() <box_tuple-new>` to work without ``box.cfg()``.
    Issue `2047 <https://github.com/tarantool/tarantool/issues/2047>`_.
  * :ref:`box.atomic(fun, ...) <box-atomic>` wrapper to execute function in a transaction.
    Issue `818 <https://github.com/tarantool/tarantool/issues/818>`_.
  * :ref:`box.session.type() <box_session-type>` helper to determine session type.
    Issue `2642 <https://github.com/tarantool/tarantool/issues/2642>`_.
  * Hot code :ref:`reload <box_schema-func_reload>` for stored C stored procedures.
    Use ``box.schema.func.reload('modulename.function')``
    to reload dynamic shared libraries on the fly.
    Issue `910 <https://github.com/tarantool/tarantool/issues/910>`_.
  * :ref:`string.hex() <string-hex>` and ``str:hex()`` Lua API.
    Issue `2522 <https://github.com/tarantool/tarantool/issues/2522>`_.
  * Package manager based on LuaRocks.
    Use ``tarantoolctl rocks install MODULENAME`` to install MODULENAME Lua module
    from https://rocks.tarantool.org/.
    Issue `2067 <https://github.com/tarantool/tarantool/issues/2067>`_.
  * Lua 5.1 command line options.
    Tarantool binary now supports '-i', '-e', '-m' and '-l' command line options.
    Issue `1265 <https://github.com/tarantool/tarantool/issues/1265>`_.
  * Experimental GC64 mode for LuaJIT.
    GC64 mode allow to operate the full address space on 64-bit hosts.
    Enable via ``-DLUAJIT_ENABLE_GC64=ON compile-time`` configuration option.
    Issue `2643 <https://github.com/tarantool/tarantool/issues/2643>`_.
  * Syslog logger now support non-blocking mode.
    :ref:`box.cfg{log_nonblock=true} <cfg_logging-log_nonblock>` now also works for syslog logger.
    Issue `2466 <https://github.com/tarantool/tarantool/issues/2466>`_.
  * Added a VERBOSE :ref:`log level <cfg_logging-log_level>` beyond INFO.
    Issue `2467 <https://github.com/tarantool/tarantool/issues/2467>`_.
  * Tarantool now automatically makes snapshots every hour.
    Please set :ref:`box.cfg{checkpoint_interval=0  <cfg_checkpoint_daemon-checkpoint_interval>` to restore pre-1.7.5 behaviour.
    Issue `2496 <https://github.com/tarantool/tarantool/issues/2496>`_.
  * Increase precision for percentage ratios provoded by :ref:`box.slab.info() <box_slab_info>`.
    Issue `2082 <https://github.com/tarantool/tarantool/issues/2082>`_.
  * Stack traces now contain symbols names on all supported platforms.
    Previous versions of Tarantool didn't display meaningful function names in
    :ref:`fiber.info() <fiber-info>` on non-x86 platforms.
    Issue `2103 <https://github.com/tarantool/tarantool/issues/2103>`_.
  * Allowed to create fiber with custom stack size from C API.
    Issue `2438 <https://github.com/tarantool/tarantool/issues/2438>`_.
  * Added ``ipc_cond`` to public C API.
    Issue `1451 <https://github.com/tarantool/tarantool/issues/1451>`_.

New rocks:

  * :ref:`http.client <http-module>` (built-in) - libcurl-based HTTP client with SSL/TLS support.
    Issue `2083 <https://github.com/tarantool/tarantool/issues/x2083>`_.
  * :ref:`iconv <iconv-converter>` (built-in) - bindings for iconv.
    Issue `2587 <https://github.com/tarantool/tarantool/issues/2587>`_.
  * `authman <https://github.com/mailru/tarantool-authman>`_ - API for
    user registration and login in your site using email and social networks.
  * `document <https://github.com/tarantool/document>`_ - store nested documents in Tarantool.
  * `synchronized <https://github.com/tarantool/synchronized>`_ - critical sections for Lua.

.. _whats_new_174:

**Release 1.7.4**

Release type: release candidate. Release date: 2017-05-12. Release tag: Tag: 1.7.4.

Announcement: https://github.com/tarantool/tarantool/releases/tag/1.7.4
or https://groups.google.com/forum/#!topic/tarantool/3x88ATX9YbY

This is a release candidate in the 1.7 series.
Vinyl Engine, the flagship feature of 1.7.x, is now feature complete.

Incompatible changes

  * ``box.cfg()`` options were changed to add Vinyl support:

    * ``snap_dir`` renamed to ``memtx_dir``
    * ``slab_alloc_arena`` (gigabytes) renamed to ``memtx_memory`` (bytes),
      default value changed from 1Gb to 256MB
    * ``slab_alloc_minimal`` renamed to ``memtx_min_tuple_size``
    * ``slab_alloc_maximal`` renamed to ``memtx_max_tuple_size``
    * ``slab_alloc_factor`` is deprecated, not relevant in 1.7.x
    * ``snapshot_count`` renamed to ``checkpoint_count``
    * ``snapshot_period`` renamed to ``checkpoint_interval``
    * ``logger`` renamed to ``log``
    * ``logger_nonblock`` renamed to ``log_nonblock``
    * ``logger_level`` renamed to ``log_level``
    * ``replication_source`` renamed to ``replication``
    * ``panic_on_snap_error = true`` and ``panic_on_wal_error = true``
      superseded by ``force_recovery = false``

    Until Tarantool 1.8, you can use deprecated parameters for both
    initial and runtime configuration, but such usage will print
    a warning in the server log.
    Issues `1927 <https://github.com/tarantool/tarantool/issues/1927>`_ and
    `2042 <https://github.com/tarantool/tarantool/issues/2042>`_.

  * Hot standy mode is now off by default. Tarantool automatically detects
    another running instance in the same ``wal_dir`` and refuses to start.
    Use ``box.cfg {hot_standby = true}`` to enable the hot standby mode.
    Issue `775 <https://github.com/tarantool/tarantool/issues/775>`_.
  * UPSERT via a secondary key was banned to avoid unclear semantics.
    Issue `2226 <https://github.com/tarantool/tarantool/issues/2226>`_.
  * ``box.info`` and ``box.info.replication`` format was changed to display
    information about upstream and downstream connections
    (Issue `723 <https://github.com/tarantool/tarantool/issues/723>`_):

    * Added ``box.info.replication[instance_id].downstream.vclock`` to display
      the last sent row to remote replica.
    * Added ``box.info.replication[instance_id].id``.
    * Added ``box.info.replication[instance_id].lsn``.
    * Moved ``box.info.replication[instance_id].{vclock,status,error}`` to
      ``box.info.replication[instance_id].upstream.{vclock,status,error}``.
    * All registered replicas from ``box.space._cluster`` are included to
      ``box.info.replication`` output.
    * ``box.info.server.id`` renamed ``box.info.id``
    * ``box.info.server.lsn`` renamed ``box.info.lsn``
    * ``box.info.server.uuid`` renamed ``box.info.uuid``
    * ``box.info.cluster.signature`` renamed to ``box.info.signature``
    * ``box.info.id`` and ``box.info.lsn`` now return `nil` instead of `-1`
      during initial cluster bootstrap.

  * ``net.box``: added per-request options to all requests:

    * ``conn.call(func_name, arg1, arg2,...)`` changed to
      ``conn.call(func_name, {arg1, arg2, ...}, opts)``
    * ``conn.eval(func_name, arg1, arg2,...)`` changed to
      ``conn.eval(func_name, {arg1, arg2, ...}, opts)``

  * All requests now support ``timeout = <seconds>``, ``buffer = <ibuf>`` options.
  * Added ``connect_timeout`` option to ``netbox.connect()``.
  * ``netbox:timeout()`` and ``conn:timeout()`` are now deprecated.
    Use ``netbox.connect(host, port, { call_16 = true })`` for
    1.6.x-compatible behavior.
    Issue `2195 <https://github.com/tarantool/tarantool/issues/2195>`_.
  * systemd configuration changed to support ``Type=Notify`` / ``sd_notify()``.
    Now ``systemctl start tarantool@INSTANCE`` will wait until Tarantool
    has started and recovered from xlogs. The recovery status is reported to
    ``systemctl status tarantool@INSTANCE``.
    Issue `1923 <https://github.com/tarantool/tarantool/issues/1923>`_.
  * ``log`` module now doesn't prefix all messages with the full path to
    tarantool binary when used without ``box.cfg()``.
    Issue `1876 <https://github.com/tarantool/tarantool/issues/1876>`_.
  * ``require('log').logger_pid()`` was renamed to ``require('log').pid()``.
    Issue `2917 <https://github.com/tarantool/tarantool/issues/2917>`_.
  * Removed Lua 5.0 compatible defines and functions
    (Issue `2396 <https://github.com/tarantool/tarantool/issues/2396>`_):

    * ``luaL_reg`` removed in favor of ``luaL_Reg``
    * ``luaL_getn(L, i)`` removed in favor of ``lua_objlen(L, i)``
    * ``luaL_setn(L, i, j)`` removed (was no-op)
    * ``lua_ref(L, lock)`` removed in favor of ``luaL_ref(L, lock)``
    * ``lua_getref(L,ref)`` removed in favor of ``lua_rawgeti(L, LUA_REGISTRYINDEX, (ref))``
    * ``lua_unref(L, ref)`` removed in favor of ``luaL_unref(L, ref)``
    * ``math.mod()`` removed in favor of ``math.fmod()``
    * ``string.gfind()`` removed in favor of ``string.gmatch()``

Functionality added or changed:

  * (Vinyl) multi-level compaction.
    The compaction scheduler now groups runs of the same range into levels to
    reduce the write amplification during compaction. This design allows Vinyl
    to support 1:100+ ram:disk use-cases.
    Issue `1821 <https://github.com/tarantool/tarantool/issues/1821>`_.
  * (Vinyl) bloom filters for sorted runs.
    Bloom filter is a probabilistic data structure which can be used to test
    whether a requested key is present in a run file without reading the actual
    file from the disk. Bloom filter may have false-positive matches but
    false-negative matches are impossible. This feature reduces the number
    of seeks needed for random lookups and speeds up REPLACE/DELETE with
    enabled secondary keys.
    Issue `1919 <https://github.com/tarantool/tarantool/issues/1919>`_.
  * (Vinyl) key-level cache for point lookups and range queries.
    Vinyl storage engine caches selected keys and key ranges instead of
    entire disk pages like in traditional databases. This approach is more
    efficient because the cache is not polluted with raw disk data.
    Issue `1692 <https://github.com/tarantool/tarantool/issues/1692>`_.
  * (Vinyl) implemented the common memory level for in-memory indexes.
    Now all in-memory indexes of a space store pointers to the same tuples
    instead of cached secondary key index data. This feature significantly
    reduces the memory footprint in case of secondary keys.
    Issue `1908 <https://github.com/tarantool/tarantool/issues/1908>`_.
  * (Vinyl) new implementation of initial state transfer of JOIN command in
    replication protocol. New replication protocol fixes problems with
    consistency and secondary keys. We implemented a special kind of low-cost
    database-wide read-view to avoid dirty reads in JOIN procedure. This trick
    wasn't not possible in traditional B-Tree based databases.
    Issue `2001 <https://github.com/tarantool/tarantool/issues/2001>`_.
  * (Vinyl) index-wide mems/runs.
    Removed ranges from in-memory and and the stop layer of LSM tree on disk.
    Issue `2209 <https://github.com/tarantool/tarantool/issues/2209>`_.
  * (Vinyl) coalesce small ranges.
    Before dumping or compacting a range, consider coalescing it with its
    neighbors.
    Issue `1735 <https://github.com/tarantool/tarantool/issues/1735>`_.
  * (Vinyl) implemented transnational journal for metadata.
    Now information about all Vinyl files is logged in a special ``.vylog`` file.
    Issue `1967 <https://github.com/tarantool/tarantool/issues/1967>`_.
  * (Vinyl) implemented consistent secondary keys.
    Issue `2410 <https://github.com/tarantool/tarantool/issues/2410>`_.
  * (Memtx+Vinyl) implemented low-level Lua API to create consistent backups.
    of Memtx + Vinyl data. The new feature provides ``box.backup.start()/stop()``
    functions to create backups of all spaces.
    :ref:`box.backup.start() <admin-backups-backup_start>` pauses the
    Tarantool garbage collector and returns the list of files to copy. These files then
    can be copied be any third-party tool, like cp, ln, tar, rsync, etc.
    ``box.backup.stop()`` lets the garbage collector continue.
    Created backups can be restored instantly by copying into a new directory
    and starting a new Tarantool instance. No special preparation, conversion
    or unpacking is needed.
    Issue `1916 <https://github.com/tarantool/tarantool/issues/1916>`_.
  * (Vinyl) added statistics for background workers to ``box.info.vinyl()``.
    Issue `2005 <https://github.com/tarantool/tarantool/issues/2005>`_.
  * (Memtx+Vinyl) reduced the memory footprint for indexes which keys are
    sequential and start from the first field. This optimization was necessary
    for secondary keys in Vinyl, but we optimized Memtx as well.
    Issue `2046 <https://github.com/tarantool/tarantool/issues/2046>`_.
  * LuaJIT was rebased on the latest 2.1.0b3 with out patches
    (Issue `2396 <https://github.com/tarantool/tarantool/issues/2396>`_):

    * Added JIT compiler backend for ARM64
    * Added JIT compiler backend and interpreter for MIPS64
    * Added some more Lua 5.2 and Lua 5.3 extensions
    * Fixed several bugs
    * Removed Lua 5.0 legacy (see incompatible changes above).

  * Enabled a new smart string hashing algorithm in LuaJIT to avoid significant
    slowdown when a lot of collisions are generated.
    Contributed by Yury Sokolov (@funny-falcon) and Nick Zavaritsky (@mejedi).
    See https://github.com/tarantool/luajit/pull/2.
  * ``box.snapshot()`` now updates mtime of a snapshot file if there were no
    changes to the database since the last snapshot.
    Issue `2045 <https://github.com/tarantool/tarantl/issues/2045>`_.
  * Implemented ``space:bsize()`` to return the memory size utilized by all
    tuples of the space.
    Contributed by Roman Tokarev (@rtokarev).
    Issue `2043 <https://github.com/tarantool/tarantool/issues/2043>`_.
  * Exported new Lua/C functions to public API:

    * ``luaT_pushtuple``, ``luaT_istuple``
      (issue `1878 <https://github.com/tarantool/tarantool/issues/1878>`_)
    * ``luaT_error``, ``luaT_call``, ``luaT_cpcall``
      (issue `2291 <https://github.com/tarantool/tarantool/issues/2291>`_)
    * ``luaT_state``
      (issue `2416 <https://github.com/tarantool/tarantool/issues/2416>`_)

  * Exported new Box/C functions to public API: ``box_key_def``, ``box_tuple_format``,
    ``tuple_compare()``, ``tuple_compare_with_key()``.
    Issue `2225 <https://github.com/tarantool/tarantool/issues/2225>`_.
  * xlogs now can be rotated based on size (``wal_max_size``) as well as
    the number of written rows (``rows_per_wal``).
    Issue `173 <https://github.com/tarantool/tarantool/issues/173>`_.
  * Added ``string.split()``, ``string.startswith()``, ``string.endswith()``,
    ``string.ljust()``, ``string.rjust()``, ``string.center()`` API.
    Issues `2211 <https://github.com/tarantool/tarantool/issues/2211>`_,
    `2214 <https://github.com/tarantool/tarantool/issues/2214>`_,
    `2415 <https://github.com/tarantool/tarantool/issues/2415>`_.
  * Added ``table.copy()`` and ``table.deepcopy()`` functions.
    Issue `2212 <https://github.com/tarantool/tarantool/issues/2412>`_.
  * Added ``pwd`` module to work with UNIX users and groups.
    Issue `2213 <https://github.com/tarantool/tarantool/issues/2213>`_.
  * Removed noisy "client unix/: connected" messages from logs. Use
    ``box.session.on_connect()``/``on_disconnect()`` triggers instead.
    Issue `1938 <https://github.com/tarantool/t`arantool/issues/1938>`_.

    ``box.session.on_connect()``/``on_disconnect()``/``on_auth()`` triggers
    now also fired for admin console connections.

  * tarantoolctl: ``eval``, ``enter``, ``connect`` commands now support UNIX pipes.
    Issue `672 <https://github.com/tarantool/tarantool/issues/672>`_.
  * tarantoolctl: improved error messages and added a new man page.
    Issue `1488 <https://github.com/tarantool/tarantool/issues/1488>`_.
  * tarantoolctl: added filter by ``replica_id`` to ``cat`` and ``play`` commands.
    Issue `2301 <https://github.com/tarantool/tarantool/issues/2301>`_.
  * tarantoolctl: ``start``, ``stop`` and ``restart`` commands now redirect to
    ``systemctl start/stop/restart`` when systemd is enabled.
    Issue `2254 <https://github.com/tarantool/tarantool/issues/2254>`_.
  * net.box: added ``buffer = <buffer>`` per-request option to store raw
    MessagePack responses into a C buffer.
    Issue `2195 <https://github.com/tarantool/tarantool/issues/2195>`_.
  * net.box: added ``connect_timeout`` option.
    Issue `2054 <https://github.com/tarantool/tarantool/issues/2054>`_.
  * net.box: added ``on_schema_reload()`` hook.
    Issue `2021 <https://github.com/tarantool/tarantool/issues/2021>`_.
  * net.box: exposed ``conn.schema_version`` and ``space.connection`` to API.
    Issue `2412 <https://github.com/tarantool/tarantool/issues/2412>`_.
  * log: ``debug()``/``info()``/``warn()``/``error()`` now doesn't fail on
    formatting errors.
    Issue `889 <https://github.com/tarantool/tarantool/issues/889>`_.
  * crypto: added HMAC support.
    Contributed by Andrey Kulikov (@amdei).
    Issue `725 <https://github.com/tarantool/tarantool/issues/725>`_.

.. _whats_new_173:

**Release 1.7.3**

Release type: beta. Release date: 2016-12-24. Release tag: Tag: 1.7.3-0-gf0c92aa.

Announcement: https://github.com/tarantool/tarantool/releases/tag/1.7.3

This is the second beta release in the 1.7 series.

Incompatible changes:

  * Broken ``coredump()`` Lua function was removed.
    Use ``gdb -batch -ex "generate-core-file" -p $PID`` instead.
    Issue `1886 <https://github.com/tarantool/tarantool/issues/1886>`_.
  * Vinyl disk layout was changed since 1.7.2 to add ZStandard compression and improve
    the performance of secondary keys.
    Use the replication mechanism to upgrade from 1.7.2 beta.
    Issue `1656 <https://github.com/tarantool/tarantool/issues/1656>`_.

Functionality added or changed:

  * Substantial progress on stabilizing the Vinyl storage engine:

    * Fix most known crashes and bugs with bad results.
    * Switch to use XLOG/SNAP format for all data files.
    * Enable ZStandard compression for all data files.
    * Squash UPSERT operations on the fly and merge hot keys using a
      background fiber.
    * Significantly improve the performance of index:pairs() and index:count().
    * Remove unnecessary conflicts from transactions.
    * In-memory level was mostly replaced by memtx data structures.
    * Specialized allocators are used in most places.

  * We're still actively working on Vinyl and plan to add multi-level
    compaction and improve the performance of secondary keys in 1.7.4.
    This implies a data format change.
  * Support for DML requests for space:on_replace() triggers.
    Issue `587 <https://github.com/tarantool/tarantool/issues/587>`_.
  * UPSERT can be used with the empty list of operations.
    Issue `1854 <https://github.com/tarantool/tarantool/issues/1854>`_.
  * Lua functions to manipulate environment variables.
    Issue `1718 <https://github.com/tarantool/tarantool/issues/1718>`_.
  * Lua library to read Tarantool snapshots and xlogs.
    Issue `1782 <https://github.com/tarantool/tarantool/issues/1782>`_.
  * New ``play`` and ``cat`` commands in ``tarantoolctl``.
    Issue `1861 <https://github.com/tarantool/tarantool/issues/1861>`_.
  * Improve support for the large number of active network clients.
    Issue#5#1892.
  * Support for ``space:pairs(key, iterator-type)`` syntax.
    Issue `1875 <https://github.com/tarantool/tarantool/issues/1875>`_.
  * Automatic cluster bootstrap now also works without authorization.
    Issue `1589 <https://github.com/tarantool/tarantool/issues/1589>`_.
  * Replication retries to connect to master indefinitely.
    Issue `1511 <https://github.com/tarantool/tarantool/issues/1511>`_.
  * Temporary spaces now work with ``box.cfg { read_only = true }``.
    Issue `1378 <https://github.com/tarantool/tarantool/issues/1378>`_.
  * The maximum length of space names increased to 64 bytes (was 32).
    Issue `2008 <https://github.com/tarantool/tarantool/issues/2008>`_.

.. _whats_new_172:

**Release 1.7.2**

Release type: beta. Release date: 2016-09-29. Release tag: Tag: `1.7.2-1-g92ed6c4`.

Announcement: https://groups.google.com/forum/#!topic/tarantool-ru/qUYUesEhRQg

This is a release in the 1.7 series.

Incompatible changes:

  * A new binary protocol command for CALL, which no more restricts a function
    to returning an array of tuples and allows returning an arbitrary MsgPack/JSON
    result, including scalars, nil and void (nothing).
    The old CALL is left intact for backward compatibility. It will be removed
    in the next major release. All programming language drivers will be gradually
    changed to use the new CALL.
    Issue `1296 <https://github.com/tarantool/tarantool/issues/1296>`_.

Functionality added or changed:

  * Vinyl storage engine finally reached the beta stage.
    This release fixes more than 90 bugs in Vinyl, in particular, removing
    unpredictable latency spikes, all known crashes and bad/lost result bugs.

    * new cooperative multitasking based architecture to eliminate latency spikes,
    * support for non-sequential multi-part keys,
    * support for secondary keys,
    * support for ``auto_increment()``,
    * number, integer, scalar field types in indexes,
    * INSERT, REPLACE and UPDATE return new tuple, like in memtx.

  * We're still actively working on Vinyl and plan to add ``zstd`` compression
    and a new memory allocator for Vinyl in-memory index in 1.7.3.
    This implies a data format change which we plan to implement before 1.7
    becomes generally available.
  * Tab-based autocompletion in the interactive console,
    ``require('console').connect()``, ``tarantoolctl enter`` and
    ``tarantoolctl connect`` commands.
    Issues `86 <https://github.com/tarantool/tarantool/issues/86>`_ and
    `1790 <https://github.com/tarantool/tarantool/issues/1790>`_.
    Use the TAB key to auto complete the names of Lua variables, functions
    and meta-methods.
  * A new implementation of ``net.box`` improving performance and solving problems
    when the Lua garbage collector handles dead connections.
    Issues `799 <https://github.com/tarantool/tarantool/issues/799>`_,
    `800 <https://github.com/tarantool/tarantool/issues/800>`_,
    `1138 <https://github.com/tarantool/tarantool/issues/1138>`_ and
    `1750 <https://github.com/tarantool/tarantool/issues/1750>`_.
  * memtx snapshots and xlog files are now compressed on the fly using the fast
    `ZStandard <https://github.com/facebook/zstd>`_ compression algorithm.
    Compression options are configured automatically to get an optimal trade-off
    between CPU utilization and disk throughput.
  * ``fiber.cond()`` - a new synchronization mechanism for cooperative multitasking.
    Issue `1731 <https://github.com/tarantool/tarantool/issues/1731>`_.
  * Tarantool can now be installed using universal Snappy packages
    (http://snapcraft.io/) with ``snap install tarantool --channel=beta``.

New rocks and packages:

  * `curl <https://github.com/tarantool/tarantool-curl>`_ - non-blocking bindings for libcurl
  * `prometheus <https://github.com/tarantool/prometheus>`_ - Prometheus metric collector for Tarantool
  * `gis <https://github.com/tarantool/gis>`_ - a full-featured geospatial extension for Tarantool
  * `mqtt <https://github.com/tarantool/mqtt>`_ - an MQTT protocol client for Tarantool
  * `luaossl <https://github.com/tarantool/luaossl>`_ - the most comprehensive OpenSSL module in the Lua universe

Deprecated, removed features and minor incompatibilities:

  * ``num`` and ``str`` fields type names are deprecated, use
    ``unsigned`` and ``string`` instead.
    Issue `1534 <https://github.com/tarantool/tarantool/issues/1534>`_.
  * ``space:inc()`` and ``space:dec()`` were removed (deprecated in 1.6.x)
    Issue `1289 <https://github.com/tarantool/tarantool/issues/1289>`_.
  * ``fiber:cancel()`` is now asynchronous and doesn't wait for the fiber to end.
    Issue `1732 <https://github.com/tarantool/tarantool/issues/1732>`_.
  * Implicit error-prone ``tostring()`` was removed from ``digest`` API.
    Issue `1591 <https://github.com/tarantool/tarantool/issues/1591>`_.
  * Support for SHA-0 (``digest.sha()``) was removed due to OpenSSL upgrade.
  * ``net.box`` now uses one-based indexes for ``space.name.index[x].parts``.
    Issue `1729 <https://github.com/tarantool/tarantool/issues/1729>`_.
  * Tarantool binary now dynamically links with ``libssl.so`` during compile time
    instead of loading it at the run time.
  * Debian and Ubuntu packages switched to use native ``systemd`` configuration
    alongside with old-fashioned ``sysvinit`` scripts.

    ``systemd`` provides its own facilities for multi-instance management.
    To upgrade, perform the following steps:

    1. Install new 1.7.2 packages.
    2. Ensure that ``INSTANCENAME.lua`` file is present in ``/etc/tarantool/instace.enabled``.
    3. Stop INSTANCENAME using ``tarantoolctl stop INSTANCENAME``.
    4. Start INSTANCENAME using ``systemctl start tarantool@INSTANCENAME``.
    5. Enable INSTANCENAME during system boot using ``systemctl enable trantool@INTANCENAME``.
    6. Say ``systemctl disable tarantool; update-rc.d tarantool remove`` to disable
       sysvinit-compatible wrappers.

    Refer to issue `1291 <https://github.com/tarantool/tarantool/issues/1291>`_
    comment and :ref:`the administration chapter <admin>` for additional information.

  * Debian and Ubuntu packages start a ready-to-use ``example.lua`` instance on
    a clean installation of the package.
    The default instance grants universe permissions for ``guest`` user and listens
    on "locahost:3313".
  * Fedora 22 packages were deprecated (EOL).

.. _whats_new_171:

**Release 1.7.1**

Release type: alpha. Release date: 2016-07-11.

Announcement: https://groups.google.com/forum/#!topic/tarantool/KGYj3VKJKb8

This is the first alpha in the 1.7 series.
The main feature of this release is a new storage engine, called "vinyl".
Vinyl is a write optimized storage engine, allowing the amount
of data stored exceed the amount of available RAM 10-100x times.
Vinyl is a continuation of the Sophia engine from 1.6, and
effectively a fork and a distant relative of Dmitry Simonenko's
Sophia. Sophia is superseded and replaced by Vinyl.
Internally it is organized as a log structured merge tree.
However, it takes a serious effort to improve on the traditional
deficiencies of log structured storage, such as poor read performance
and unpredictable write latency. A single index
is range partitioned among many LSM data structures, each having its
own in-memory buffers of adjustable size. Range partitioning allows
merges of LSM levels to be more granular, as well as to prioritize
hot ranges over cold ones in access to resources, such as RAM and
I/O. The merge scheduler is designed to minimize write latency
while ensuring read performance stays within acceptable limits.
Vinyl today only supports a primary key index. The index
can consist of up to 256 parts, like in MemTX, up from 8 in
Sophia. Partial key reads are supported.
Support of non-sequential multi part keys, as well as secondary keys
is on the short term todo.
Our intent is to remove all limitations currently present in
Vinyl, making it a first class citizen in Tarantool.

Functionality added or changed:

  * The disk-based storage engine, which was called ``sophia`` or ``phia``
    in earlier versions, is superseded by the ``vinyl`` storage engine.
  * There are new types for indexed fields.
  * The LuaJIT version is updated.
  * Automatic replica set bootstrap (for easier configuration of a new replica set)
    is supported.
  * The ``space_object:inc()`` function is removed.
  * The ``space_object:dec()`` function is removed.
  * The ``space_object:bsize()`` function is added.
  * The ``box.coredump()`` function is removed, for an alternative see
    :ref:`Core dumps <admin-core_dumps>`.
  * The ``hot_standby`` configuration option is added.
  * Configuration parameters revised or renamed:

    * ``slab_alloc_arena`` (in gigabytes) to ``memtx_memory`` (in bytes),
    * ``slab_alloc_minimal`` to ``memtx_min_tuple_size``,
    * ``slab_alloc_maximal`` to ``memtx_max_tuple_size``,
    * ``replication_source`` to ``replication``,
    * ``snap_dir`` to ``memtx_dir``,
    * ``logger`` to ``log``,
    * ``logger_nonblock`` to ``log_nonblock``,
    * ``snapshot_count`` to ``checkpoint_count``,
    * ``snapshot_period`` to ``checkpoint_interval``,
    * ``panic_on_wal_error`` and ``panic_on_snap_error`` united under ``force_recovery``.
  * Until Tarantool 1.8, you can use :ref:`deprecated parameters <cfg_deprecated>`
    for both initial and runtime configuration, but Tarantool will display a warning.
    Also, you can specify both deprecated and up-to-date parameters, provided
    that their values are harmonized. If not, Tarantool will display an error.
  * Automatic replication cluster bootstrap; it's now much
    easier to configure a new replication cluster.
  * New indexable data types: INTEGER and SCALAR.
  * Code refactoring and performance improvements.
  * Updated LuaJIT to 2.1-beta116.

.. _whats_new_16:

-------------------------------------------------------------------------------
Version 1.6
-------------------------------------------------------------------------------

.. _whats_new_169:

**Release 1.6.9**

Release type: maintenance. Release date: 2016-09-27. Release tag: 1.6.9-4-gcc9ddd7.

Since February 15, 2017, due to Tarantool issue#2040
`Remove sophia engine from 1.6 <https://github.com/tarantool/tarantool/issues/2040>`_
there no longer is a storage engine named `sophia`.
It will be superseded in version 1.7 by the `vinyl` storage engine.

Incompatible changes:

  * Support for SHA-0 (``digest.sha()``) was removed due to OpenSSL upgrade.
  * Tarantool binary now dynamically links with libssl.so during compile time
    instead of loading it at the run time.
  * Fedora 22 packages were deprecated (EOL).

Functionality added or changed:

  * Tab-based autocompletion in the interactive console.
    Issue `86 <https://github.com/tarantool/tarantool/issues/86>`_
  * LUA_PATH and LUA_CPATH environment variables taken into account, like in PUC-RIO Lua.
    Issue `1428 <https://github.com/tarantool/tarantool/issues/1428>`_
  * Search for ``.dylib`` as well as for ``.so`` libraries in OS X.
    Issue `810 <https://github.com/tarantool/tarantool/issues/810>`_.
  * A new ``box.cfg { read_only = true }`` option to emulate master-slave behavior.
    Issue `246 <https://github.com/tarantool/tarantool/issues/246>`_
  * ``if_not_exists = true`` option added to box.schema.user.grant.
    Issue `1683 <https://github.com/tarantool/tarantool/issues/1683>`_
  * ``clock_realtime()``/``monotonic()`` functions added to the public C API.
    Issue `1455 <https://github.com/tarantool/tarantool/issues/1455>`_
  * ``space:count(key, opts)`` introduced as an alias for
    ``space.index.primary:count(key, opts)``.
    Issue `1391 <https://github.com/tarantool/tarantool/issues/13918>`_
  * Upgrade script for 1.6.4 -> 1.6.8 -> 1.6.9.
    Issue `1281 <https://github.com/tarantool/tarantool/issues/1281>`_
  * Support for OpenSSL 1.1.
    Issue `1722 <https://github.com/tarantool/tarantool/issues/1722>`_

New rocks and packages:

  * `curl <https://github.com/tarantool/tarantool-curl>`_ - non-blocking bindings for libcurl
  * `prometheus <https://github.com/tarantool/prometheus>`_ - Prometheus metric collector for Tarantool
  * `gis <https://github.com/tarantool/gis>`_ - full-featured geospatial extension for Tarantool.
  * `mqtt <https://github.com/tarantool/mqtt>`_ - MQTT protocol client for Tarantool
  * `luaossl <https://github.com/tarantool/luaossl>`_ - the most comprehensive OpenSSL module in the Lua universe

.. _whats_new_168:

**Release 1.6.8**

Release type: maintenance. Release date: 2016-02-25. Release tag: 1.6.8-525-ga571ac0.

Incompatible changes:

  * RPM packages for CentOS 7 / RHEL 7 and Fedora 22+ now use native systemd
    configuration without legacy sysvinit shell scripts. Systemd provides its own
    facilities for multi-instance management. To upgrade, perform the
    following steps:

    1. Ensure that ``INSTANCENAME.lua`` file is present in ``/etc/tarantool/instace.available``.
    2. Stop INSTANCENAME using ``tarantoolctl stop INSTANCENAME``.
    3. Start INSTANCENAME using ``systemctl start tarantool@INSTANCENAME``.
    4. Enable INSTANCENAME during system boot using ``systemctl enable trantool@INTANCENAME``.

    ``/etc/tarantool/instance.enabled`` directory is now deprecated for systemd-enabled platforms.

    See :ref:`the administration chapter <admin>` for additional information.

  * Sophia was upgraded to v2.1 to fix upsert, memory corruption and other bugs.
    Sophia v2.1 doesn't support old v1.1 data format. Please use Tarantool
    replication to upgrade.
    Issue `1222 <https://github.com/tarantool/tarantool/issues/1222>`_
  * Ubuntu Vivid, Fedora 20, Fedora 21 were deprecated due to EOL.
  * i686 packages were deprecated. Please use our RPM and DEB specs to build
    these on your own infrastructure.
  * Please update your ``yum.repos.d`` and/or apt ``sources.list.d`` according to
    instructions at http://tarantool.org/download.html

Functionality added or changed:

  * Tarantool 1.6.8 fully supports ARMv7 and ARMv8 (aarch64) processors.
    Now it is possible to use Tarantool on a wide range of consumer devices,
    starting from popular Raspberry PI 2 to coin-size embedded boards and
    no-name mini-micro-nano-PCs.
    Issue `1153 <https://github.com/tarantool/tarantool/issues/1153>`_.
    (Also qemu works well, but we don't have real hardware to check.)
  * Tuple comparator functions were optimized, providing up to 30% performance
    boost when an index key consists of 2, 3 or more parts.
    Issue `969 <https://github.com/tarantool/tarantool/issues/969>`_.
  * Tuple allocator changes give another 15% performance improvement.
    Issue `1298 <https://github.com/tarantool/tarantool/issues/1298>`_
  * Replication relay performance was improved by reducing the amount of data
    directory re-scans.
    Issue `11150 <https://github.com/tarantool/tarantool/issues/1150>`_
  * A random delay was introduced into snapshot daemon, reducing the chance
    that multiple instances take a snapshot at the same time.
    Issue `732 <https://github.com/tarantool/tarantool/issues/732>`_.
  * Sophia storage engine was upgraded to v2.1:

    * serializable Snapshot Isolation (SSI),
    * RAM storage mode,
    * anti-cache storage mode,
    * persistent caching storage mode,
    * implemented AMQ Filter,
    * LRU mode,
    * separate compression for hot and cold data,
    * snapshot implementation for Faster Recovery,
    * upsert reorganizations and fixes,
    * new performance metrics.

    Please note "Incompatible changes" above.

  * Allow to remove servers with non-zero LSN from ``_cluster`` space.
    Issue `1219 <https://github.com/tarantool/tarantool/issues/1219>`_.
  * ``net.box`` now automatically reloads space and index definitions.
    Issue `1183 <https://github.com/tarantool/tarantool/issues/1183>`_.
  * The maximal number of indexes in space was increased to 128.
    Issue `1311 <https://github.com/tarantool/tarantool/issues/1311>`_.
  * New native ``systemd`` configuration with support of instance management
    and daemon supervision (CentOS 7 and Fedora 22+ only).
    Please note "Incompatible changes" above.
    Issue `1264 <https://github.com/tarantool/tarantool/issues/1264>`_.
  * Tarantool package was accepted to the official Fedora repositories
    (https://apps.fedoraproject.org/packages/tarantool).
  * Tarantool brew formula (OS X) was accepted to the official
    Homebrew repository (http://brewformulas.org/tarantool).
  * Clang compiler support was added on FreeBSD.
    Issue `786 <https://github.com/tarantool/tarantool/issues/786>`_.
  * Support for musl libc, used by Alpine Linux and Docker images, was added.
    Issue `1249 <https://github.com/tarantool/tarantool/issues/1249>`_.
  * Added support for GCC 6.0.
  * Ubuntu Wily, Xenial and Fedora 22, 23 and 24 are now supported
    distributions for which we build official packages.
  * box.info.cluster.uuid can be used to retrieve cluster UUID.
    Issue `1117 <https://github.com/tarantool/tarantool/issues/1117>`_.
  * Numerous improvements in the documentation, added documentation
    for ``syslog``, ``clock``, ``fiber.storage`` packages, updated
    the built-in tutorial.

New rocks and packages:

  * Tarantool switched to a new Docker-based cloud build infrastructure
    The new buildbot significantly decreases commit-to-package time.
    The official repositories at http://tarantool.org now
    contain the latest version of the server, rocks and connectors.
    See http://github.com/tarantool/build
  * The repositories at http://tarantool.org/download.html were moved to
    http://packagecloud.io cloud hosting (backed by Amazon AWS).
    Thanks to packagecloud.io for their support of open source!
  * ``memcached`` - memcached text and binary protocol implementation for Tarantool.
    Turns Tarantool into a persistent memcached with master-master replication.
    See https://github.com/tarantool/memcached
  * ``migrate`` - a Tarantool rock for migration from Tarantool 1.5 to 1.6.
    See https://github.com/bigbes/migrate
  * ``cqueues`` - a Lua asynchronous networking, threading, and notification
    framework (contributed by @daurnimator).
    PR `1204 <https://github.com/tarantool/tarantool/pull/1204>`_.

.. _whats_new_167:

**Release 1.6.7**

Release type: maintenance. Release date: 2015-11-17.

Incompatible changes:

  * The syntax of ``upsert`` command has been changed
    and an extra ``key`` argument was removed from it. The primary
    key for look up is now always taken from the tuple, which is the
    second argument of upsert. ``upsert()`` was added fairly late at
    a release cycle and the design had an obvious bug which we had
    to fix. Sorry for this.
  * ``fiber.channel.broadcast()`` was removed since it wasn't used by
    anyone and didn't work properly.
  * tarantoolctl ``reload`` command renamed to ``eval``.

Functionality added or changed:

  * ``logger`` option now accepts a syntax for syslog output. Use uri-style
    syntax for file, pipe or syslog log destination.
  * ``replication_source`` now accepts an array of URIs,
    so each replica can have up to 30 peers.
  * RTREE index now accept two types of ``distance`` functions:
    ``euclid`` and ``manhattan``.
  * ``fio.abspath()`` - a new function in ``fio`` rock to convert
    a relative path to absolute.
  * The process title now can be set with an on-board ``title`` rock.
  * This release uses LuaJIT 2.1.

New rocks:

  * ``memcached`` - makes Tarantool understand Memcached binary protocol.
    Text protocol support is in progress and will be added to the rock
    itself, without changes to the server core.

.. _whats_new_166:

**Release 1.6.6**

Release type: maintenance. Release date: 2015-08-28.


Tarantool 1.6 is no longer getting major new features,
although it will be maintained.
The developers are concentrating on Tarantool version 1.9.

Incompatible changes:

  * A new schema of ``_index`` system space which accommodates
    multi-dimensional RTREE indexes. Tarantool 1.6.6 works fine
    with an old snapshot and system spaces, but you will not
    be able to start Tarantool 1.6.5 with a data directory
    created by Tarantool 1.6.6, neither will you be able
    to query Tarantool 1.6.6 schema with 1.6.5 net.box.
  * ``box.info.snapshot_pid`` is renamed to ``box.info.snapshot_in_progress``

Functionality added or changed:

  * Threaded architecture for network. Network I/O has finally
    been moved to a separate thread, increasing single instance
    performance by up to 50%.
  * Threaded architecture for checkpointing. Tarantool no longer
    forks to create a snapshot, but uses a separate thread,
    accessing data via a consistent read view.
    This eliminates all known latency spikes caused by
    snapshotting.
  * Stored procedures in C/C++. Stored procedures in C/C++
    provide speed (3-4 times, compared to a Lua version in
    our measurements), as well as unlimited extensibility
    power. Since C/C++ procedures run in the same memory
    space as the database, they are also an easy tool
    to corrupt database memory.
    See :ref:`The C API description <index-c_api_reference>`.
  * Multidimensional RTREE index. RTREE index type
    now support a large (up to 32) number of dimensions.
    RTREE data structure has been optimized to actually use
    `R\*-TREE <https://en.wikipedia.org/wiki/R*_tree>`_.
    We're working on further improvements of the index,
    in particular, configurable distance function.
    See https://github.com/tarantool/tarantool/wiki/R-tree-index-quick-start-and-usage
  * Sophia 2.1.1, with support of compression and multipart
    primary keys.
    See https://groups.google.com/forum/#!topic/sophia-database/GfcbEC7ksRg
  * New ``upsert`` command available in the binary protocol
    and in stored functions. The key advantage of upsert
    is that it's much faster with write-optimized storage
    (sophia storage engine), but some caveats exists as well.
    See Issue `905 <https://github.com/tarantool/tarantool/issues/905>`_
    for details. Even though upsert performance advantage is most
    prominent with sophia engine, it works with all storage engines.
  * Better memory diagnostics information for fibers, tuple and
    index arena Try a new command ``box.slab.stats()``, for
    detailed information about tuple/index slabs, ``fiber.info()`` now
    displays information about memory used by the fiber.
  * Update and delete now work using a secondary index, if the
    index is unique.
  * Authentication triggers. Set ``box.session.on_auth`` triggers
    to catch authentication events. Trigger API is improved
    to display all defined triggers, easily remove old triggers.
  * Manifold performance improvements of ``net.box`` built-in package.
  * Performance optimizations of BITSET index.
  * ``panic_on_wal_error`` is a dynamic configuration option now.
  * iproto ``sync`` field is available in Lua as ``session.sync()``.
  * ``box.once()`` - a new method to invoke code once in an
    instance and replica set lifetime. Use ``once()`` to set
    up spaces and uses, as well as do schema upgrade in
    production.
  * ``box.error.last()`` to return the last error in a session.

New rocks:

  * ``jit.*``, ``jit.dump``, ``jit.util``, ``jit.vmdef`` modules of LuaJIT 2.0
    are now available as built-ins.
    See http://luajit.org/ext_jit.html
  * ``strict`` built-in package, banning use of undeclared variables in
    Lua. Strict mode is on when Tarantool is compiled with debug.
    Turn on/off with ``require('strict').on()``/``require('strict').off()``.
  * ``pg`` and ``mysql`` rocks, available at http://rocks.tarantool.org -
    working with MySQL and PostgreSQL from Tarantool.
  * ``gperftools`` rock, availble at http://rocks.tarantool.org -
    getting perfromance data using Google's gperf from Tarantool.
  * ``csv`` built-in rock, to parse and load CSV (comma-separated
    values) data.

New supported platforms:

* Fedora 22, Ubuntu Vivid
