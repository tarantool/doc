.. _fio-module:

-------------------------------------------------------------------------------
                                   Module `fio`
-------------------------------------------------------------------------------

.. _fio-section:

===============================================================================
                                   Overview
===============================================================================

Tarantool supports file input/output with an API that is similar to POSIX
syscalls. All operations are performed asynchronously. Multiple fibers can
access the same file simultaneously.

The ``fio`` module contains:

* functions for :ref:`common pathname manipulations <fio-pathname>`,
* functions for :ref:`directory or file existence and type checks<fio-checks>`,
* functions for :ref:`common file manipulations <fio-file>`, and
* :ref:`constants <fio-c>` which are the same as POSIX flag values (for example
  ``fio.c.flag.O_RDONLY`` = POSIX O_RDONLY).

===============================================================================
                                    Index
===============================================================================

Below is a list of all ``fio`` functions and members.

.. container:: table

    .. rst-class:: left-align-column-1
    .. rst-class:: left-align-column-2

    .. tabularcolumns:: |\Y{0.5}|\Y{0.5}|

    +--------------------------------------+---------------------------------+
    | Name                                 | Use                             |
    +======================================+=================================+
    | :ref:`fio.pathjoin()                 | Form a path name from one or    |
    | <fio-pathjoin>`                      | more partial strings            |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.basename()                 | Get a file name                 |
    | <fio-basename>`                      |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.dirname()                  | Get a directory name            |
    | <fio-dirname>`                       |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.abspath()                  | Get a directory and file name   |
    | <fio-abspath>`                       |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.path.exists()              | Check if file or directory      |
    | <fio-path_exists>`                   | exists                          |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.path.is_dir()              | Check if file or directory      |
    | <fio-path_is_dir>`                   | is a directory                  |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.path.is_file()             | Check if file or directory      |
    | <fio-path_is_file>`                  | is a file                       |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.path.is_link()             | Check if file or directory      |
    | <fio-path_is_link>`                  | is a link                       |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.path.lexists()             | Check if file or directory      |
    | <fio-path_lexists>`                  | exists                          |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.umask()                    | Set mask bits                   |
    | <fio-umask>`                         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.lstat()                    |                                 |
    | <fio-stat>` |br|                     | Get information about a file    |
    | :ref:`fio.stat()                     | object                          |
    | <fio-stat>`                          |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.mkdir()                    |                                 |
    | <fio-mkdir>` |br|                    | Create or delete a directory    |
    | :ref:`fio.rmdir()                    |                                 |
    | <fio-mkdir>`                         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.chdir()                    | Change working directory        |
    | <fio-chdir>`                         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.listdir()                  | List files in a directory       |
    | <fio-listdir>`                       |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.glob()                     | Get files whose names match     |
    | <fio-glob>`                          | a given string                  |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.tempdir()                  | Get the name of a directory for |
    | <fio-tempdir>`                       | storing temporary files         |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.cwd()                      | Get the name of the current     |
    | <fio-cwd>`                           | working directory               |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.copytree()                 |                                 |
    | <fio-copytree>` |br|                 |                                 |
    | :ref:`fio.mktree()                   |                                 |
    | <fio-mktree>` |br|                   | Create and delete directories   |
    | :ref:`fio.rmtree()                   |                                 |
    | <fio-rmtree>`                        |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.link()                     |                                 |
    | <fio-link>` |br|                     |                                 |
    | :ref:`fio.symlink()                  |                                 |
    | <fio-link>` |br|                     | Create and delete links         |
    | :ref:`fio.readlink()                 |                                 |
    | <fio-link>` |br|                     |                                 |
    | :ref:`fio.unlink()                   |                                 |
    | <fio-link>`                          |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.rename()                   | Rename a file or directory      |
    | <fio-rename>`                        |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.copyfile()                 | Copy a file                     |
    | <fio-copyfile>`                      |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.chown()                    |                                 |
    | <fio-chown>` |br|                    | Manage rights to and ownership  |
    | :ref:`fio.chmod()                    | of file objects                 |
    | <fio-chown>`                         |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.truncate()                 | Reduce the file size            |
    | <fio-truncate>`                      |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.sync()                     | Ensure that changes are written |
    | <fio-sync>`                          | to disk                         |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.open()                     | Open a file                     |
    | <fio-open>`                          |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`file-handle:close()            | Close a file                    |
    | <file_handle-close>`                 |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`file-handle:pread()            |                                 |
    | <file_handle-pread>` |br|            | Perform random-access read or   |
    | :ref:`file-handle:pwrite()           | write on a file                 |
    | <file_handle-pwrite>`                |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`file-handle:read()             |                                 |
    | <file_handle-read>` |br|             | Perform non-random-access read  |
    | :ref:`file-handle:write()            | or write on a file              |
    | <file_handle-write>`                 |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`file-handle:truncate()         | Change the size of an open file |
    | <file_handle-truncate>`              |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`file-handle:seek()             | Change position in a file       |
    | <file_handle-seek>`                  |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`file-handle:stat()             | Get statistics about an open    |
    | <file_handle-stat>`                  | file                            |
    +--------------------------------------+---------------------------------+
    | :ref:`file-handle:fsync()            |                                 |
    | <file_handle-fsync>` |br|            | Ensure that changes made to an  |
    | :ref:`file-handle:fdatasync()        | open file are written to disk   |
    | <file_handle-fsync>`                 |                                 |
    +--------------------------------------+---------------------------------+
    | :ref:`fio.c                          | Table of constants similar to   |
    | <fio-c_table>`                       | POSIX flag values               |
    +--------------------------------------+---------------------------------+

.. module:: fio

.. _fio-pathname:

===============================================================================
         Common pathname manipulations
===============================================================================

.. _fio-pathjoin:

.. function:: pathjoin(partial-string [, partial-string ...])

    Concatenate partial string, separated by '/' to form a path name.

    :param string partial-string: one or more strings to be concatenated.
    :return: path name
    :rtype:  string

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fio.pathjoin('/etc', 'default', 'myfile')
        ---
        - /etc/default/myfile
        ...

.. _fio-basename:

.. function:: basename(path-name[, suffix])

    Given a full path name, remove all but the final part (the file name).
    Also remove the suffix, if it is passed.

    :param string path-name: path name
    :param string suffix: suffix

    :return: file name
    :rtype:  string

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fio.basename('/path/to/my.lua', '.lua')
        ---
        - my
        ...

.. _fio-dirname:

.. function:: dirname(path-name)

    Given a full path name, remove the final part (the file name).

    :param string path-name: path name

    :return: directory name, that is, path name except for file name.
    :rtype:  string

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fio.dirname('path/to/my.lua')
        ---
        - 'path/to/'

.. _fio-abspath:

.. function:: abspath(file-name)

    Given a final part (the file name), return the full path name.

    :param string file-name: file name

    :return: directory name, that is, path name including file name.
    :rtype:  string

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fio.abspath('my.lua')
        ---
        - 'path/to/my.lua'
        ...

.. _fio-checks:

===============================================================================
            Directory or file existence and type checks
===============================================================================

Functions in this section are similar to some
`Python os.path <https://docs.python.org/2/library/os.path.htmll>`_
functions.

.. _fio-path_exists:

.. function:: fio.path.exists(path-name)

    :param string path-name: path to directory or file.
    :return: true if path-name refers to a directory or file that exists and is not a broken symbolic link; otherwise false
    :rtype:  boolean

.. _fio-path_is_dir:

.. function:: fio.path.is_dir(path-name)

    :param string path-name: path to directory or file.
    :return: true if path-name refers to a directory; otherwise false
    :rtype:  boolean

.. _fio-path_is_file:

.. function:: fio.path.is_file(path-name)

    :param string path-name: path to directory or file.
    :return: true if path-name refers to a file; otherwise false
    :rtype:  boolean

.. _fio-path_is_link:

.. function:: fio.path.is_link(path-name)

    :param string path-name: path to directory or file.
    :return: true if path-name refers to a symbolic link; otherwise false
    :rtype:  boolean

.. _fio-path_lexists:

.. function:: fio.path.lexists(path-name)

    :param string path-name: path to directory or file.
    :return: true if path-name refers to a directory or file that exists or is a broken symbolic link; otherwise false
    :rtype:  boolean

.. _fio-file:

===============================================================================
            Common file manipulations
===============================================================================

.. _fio-umask:

.. function:: umask(mask-bits)

    Set the mask bits used when creating files or directories. For a detailed
    description type ``man 2 umask``.

    :param number mask-bits: mask bits.
    :return: previous mask bits.
    :rtype:  number

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fio.umask(tonumber('755', 8))
        ---
        - 493
        ...

.. _fio-stat:

.. function:: lstat(path-name)
               stat(path-name)

    Returns information about a file object. For details type ``man 2 lstat`` or
    ``man 2 stat``.

    :param string path-name: path name of file.
    :return: (If no error) table of fields which describe the file's block size,
             creation time, size, and other attributes. |br|
             (If error) two return values: null, error message.
    :rtype:  table.

    Additionally, the result of ``fio.stat('file-name')`` will include methods
    equivalent to POSIX macros:

    * ``is_blk()`` = POSIX macro S_ISBLK,
    * ``is_chr()`` = POSIX macro S_ISCHR,
    * ``is_dir()`` = POSIX macro S_ISDIR,
    * ``is_fifo()`` = POSIX macro S_ISFIFO,
    * ``is_link()`` = POSIX macro S_ISLINK,
    * ``is_reg()`` = POSIX macro S_ISREG,
    * ``is_sock()`` = POSIX macro S_ISSOCK.

    For example, ``fio.stat('/'):is_dir()`` will return true.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fio.lstat('/etc')
        ---
        - inode: 1048577
          rdev: 0
          size: 12288
          atime: 1421340698
          mode: 16877
          mtime: 1424615337
          nlink: 160
          uid: 0
          blksize: 4096
          gid: 0
          ctime: 1424615337
          dev: 2049
          blocks: 24
        ...

.. The following is a workaround for a Sphinx bug.

.. _fio-mkdir:

.. function:: mkdir(path-name[, mode])
              rmdir(path-name)

    Create or delete a directory. For details type
    ``man 2 mkdir`` or ``man 2 rmdir``.

    :param string path-name: path of directory.
    :param number mode: Mode bits can be passed as a number or as string
                        constants, for example ``S_IWUSR``. Mode bits can be
                        combined by enclosing them in braces.
    :return: (If no error) true. |br|
             (If error) two return values: false, error message.
    :rtype:  boolean

    **Example:**

    .. code-block:: tarantoolsession

         tarantool> fio.mkdir('/etc')
         ---
         - false
         ...

.. _fio-chdir:

.. function:: chdir(path-name)

    Change working directory. For details type
    ``man 2 chdir``.

    :param string path-name: path of directory.
    :return: (If success) true. (If failure) false.
    :rtype:  boolean

    **Example:**

    .. code-block:: tarantoolsession

         tarantool> fio.chdir('/etc')
         ---
         - true
         ...

.. _fio-listdir:

.. function:: listdir(path-name)

    List files in directory.
    The result is similar to the ``ls`` shell command.

    :param string path-name: path of directory.
    :return: (If no error) a list of files. |br|
             (If error) two return values: null, error message.
    :rtype:  table

    **Example:**

    .. code-block:: tarantoolsession

         tarantool> fio.listdir('/usr/lib/tarantool')
         ---
         - - mysql
         ...

.. _fio-glob:

.. function:: glob(path-name)

    Return a list of files that match an input string. The list is constructed
    with a single flag that controls the behavior of the function:
    ``GLOB_NOESCAPE``. For details type ``man 3 glob``.

    :param string path-name: path-name, which may contain wildcard characters.
    :return: list of files whose names match the input string
    :rtype:  table

    **Possible errors:** nil.

    **Example:**

    .. code-block:: tarantoolsession

         tarantool> fio.glob('/etc/x*')
         ---
         - - /etc/xdg
           - /etc/xml
           - /etc/xul-ext
         ...

.. _fio-tempdir:

.. function:: tempdir()

    Return the name of a directory that can be used to store temporary files.

    **Example:**

    .. code-block:: tarantoolsession

         tarantool> fio.tempdir()
         ---
         - /tmp/lG31e7
         ...

.. _fio-cwd:

.. function:: cwd()

    Return the name of the current working directory.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fio.cwd()
        ---
        - /home/username/tarantool_sandbox
        ...

.. _fio-copytree:

.. function:: copytree(from-path, to-path)

    Copy everything in the from-path, including subdirectory
    contents, to the to-path.
    The result is similar to the ``cp -r`` shell command.
    The to-path should not be empty.

    :param string from-path: path-name.
    :param string to-path: path-name.
    :return: (If no error) true. |br|
             (If error) two return values: false, error message.
    :rtype:  boolean

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fio.copytree('/home/original','/home/archives')
        ---
        - true
        ...

.. _fio-mktree:

.. function:: mktree(path-name)

    Create the path, including parent directories, but without file contents.
    The result is similar to the ``mkdir -p`` shell command.

    :param string path-name: path-name.
    :return: (If no error) true. |br|
             (If error) two return values: false, error message.
    :rtype:  boolean

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fio.mktree('/home/archives')
        ---
        - true
        ...

.. _fio-rmtree:

.. function:: rmtree(path-name)

    Remove the directory indicated by path-name, including subdirectories.
    The result is similar to the ``rmdir -r`` shell command.
    The directory should not be empty.

    :param string path-name: path-name.
    :return: (If no error) true. |br|
             (If error) two return values: null, error message.
    :rtype:  boolean

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fio.rmtree('/home/archives')
        ---
        - true
        ...

.. _fio-link:

.. function:: link     (src, dst)
              symlink  (src, dst)
              readlink (src)
              unlink   (src)

    Functions to create and delete links. For details type ``man readlink``,
    ``man 2 link``, ``man 2 symlink``, ``man 2 unlink``.

    :param string src: existing file name.
    :param string dst: linked name.

    :return: (If no error) ``fio.link`` and ``fio.symlink`` and ``fio.unlink``
             return true, ``fio.readlink`` returns the link value. |br|
             (If error) two return values: false|null, error message.

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fio.link('/home/username/tmp.txt', '/home/username/tmp.txt2')
        ---
        - true
        ...
        tarantool> fio.unlink('/home/username/tmp.txt2')
        ---
        - true
        ...

.. _fio-rename:

.. function:: rename(path-name, new-path-name)

    Rename a file or directory. For details type ``man 2 rename``.

    :param string     path-name: original name.
    :param string new-path-name: new name.

    :return: (If no error) true. |br|
             (If error) two return values: false, error message.
    :rtype:  boolean

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fio.rename('/home/username/tmp.txt', '/home/username/tmp.txt2')
        ---
        - true
        ...

.. _fio-copyfile:

.. function:: copyfile(path-name, new-path-name)

    Copy a file.
    The result is similar to the ``cp`` shell command.

    :param string     path-name: path to original file.
    :param string new-path-name: path to new file.

    :return: (If no error) true. |br|
             (If error) two return values: false, error message.
    :rtype:  boolean

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fio.copyfile('/home/user/tmp.txt', '/home/usern/tmp.txt2')
        ---
        - true
        ...

.. _fio-chown:

.. function:: chown(path-name, owner-user, owner-group)
              chmod(path-name, new-rights)

    Manage the rights to file objects, or ownership of file objects.
    For details type ``man 2 chown`` or ``man 2 chmod``.

    :param string owner-user: new user uid.
    :param string owner-group: new group uid.
    :param number new-rights: new permissions
    :return: null

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fio.chmod('/home/username/tmp.txt', tonumber('0755', 8))
        ---
        - true
        ...
        tarantool> fio.chown('/home/username/tmp.txt', 'username', 'username')
        ---
        - true
        ...

.. _fio-truncate:

.. function:: truncate(path-name, new-size)

    Reduce file size to a specified value. For details type ``man 2 truncate``.

    :param string path-name:
    :param number new-size:

    :return: (If no error) true. |br|
             (If error) two return values: false, error message.
    :rtype:  boolean

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fio.truncate('/home/username/tmp.txt', 99999)
        ---
        - true
        ...

.. _fio-sync:

.. function:: sync()

    Ensure that changes are written to disk. For details type ``man 2 sync``.

    :return: true if success, false if failure.
    :rtype:  boolean

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fio.sync()
        ---
        - true
        ...

.. The following is a workaround for a Sphinx bug.

.. fio-open:

.. _fio-open:

.. function:: open(path-name[, flags[, mode]])

    Open a file in preparation for reading or writing or seeking.

    :param string path-name: Full path to the file to open.
    :param number flags: Flags can be passed as a number or as string
                         constants, for example '``O_RDONLY``',
                         '``O_WRONLY``', '``O_RDWR``'. Flags can be
                         combined by enclosing them in braces.
                         On Linux the full set of flags
                         as described on the
                         `Linux man page <http://man7.org/linux/man-pages/man2/open.2.html>`_
                         is:

                         * O_APPEND (start at end of file),
                         * O_ASYNC (signal when IO is possible),
                         * O_CLOEXEC (enable a flag related to closing),
                         * O_CREAT (create file if it doesn't exist),
                         * O_DIRECT (do less caching or no caching),
                         * O_DIRECTORY (fail if it's not a directory),
                         * O_EXCL (fail if file cannot be created),
                         * O_LARGEFILE (allow 64-bit file offsets),
                         * O_NOATIME (no access-time updating),
                         * O_NOCTTY (no console tty),
                         * O_NOFOLLOW (no following symbolic links),
                         * O_NONBLOCK (no blocking),
                         * O_PATH (get a path for low-level use),
                         * O_SYNC (force writing if it's possible),
                         * O_TMPFILE (the file will be temporary and nameless),
                         * O_TRUNC (truncate)

                         ... and, always, one of:

                         * O_RDONLY (read only),
                         * O_WRONLY (write only), or
                         * O_RDWR (either read or write).

    :param number mode: Mode bits can be passed as a number or as string
                        constants, for example ``S_IWUSR``. Mode bits
                        are significant if flags include ``O_CREAT`` or
                        ``O_TMPFILE``. Mode bits can be
                        combined by enclosing them in braces.
    :return: (If no error) file handle (abbreviated as 'fh' in later
             description). |br|
             (If error) two return values: null, error message.
    :rtype:  userdata

    **Possible errors:** nil.

    **Example 1:**

    .. code-block:: tarantoolsession

        tarantool> fh = fio.open('/home/username/tmp.txt', {'O_RDWR', 'O_APPEND'})
        ---
        ...
        tarantool> fh -- display file handle returned by fio.open
        ---
        - fh: 11
        ...

    **Example 2:**

    Using ``fio.open()`` with ``tonumber('N', 8)`` to set permissions
    as an octal number:

    .. code-block:: tarantoolsession

        tarantool> fio.open('x.txt', {'O_WRONLY', 'O_CREAT'}, tonumber('644',8))
        ---
        - fh: 12
        ...

.. class:: file-handle

    .. _file_handle-close:

    .. method:: close()

        Close a file that was opened with ``fio.open``. For details type
        ``man 2 close``.

        :param userdata fh: file-handle as returned by ``fio.open()``.
        :return: true if success, false if failure.
        :rtype:  boolean

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> fh:close() -- where fh = file-handle
            ---
            - true
            ...

    .. _file_handle-pread:

    .. method:: pread(count, offset)
                pread(buffer, count, offset)

        Perform random-access read operation on a file, without affecting
        the current seek position of the file.
        For details type ``man 2 pread``.

        :param userdata fh: file-handle as returned by ``fio.open()``
        :param buffer: where to read into (if the format is
                       ``pread(buffer, count, offset)``)
        :param number count: number of bytes to read
        :param number offset: offset within file where reading begins

        If the format is ``pread(count, offset)`` then return a string
        containing the data that was read from the file, or empty string if failure.

        If the format is ``pread(buffer, count, offset)`` then return the data
        to the buffer.
        Buffers can be acquired with :ref:`buffer.ibuf <buffer-module>`.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> fh:pread(25, 25)
            ---
            - |
              elete from t8//
              insert in
            ...

    .. _file_handle-pwrite:

    .. method:: pwrite(new-string, offset)
                pwrite(buffer, count, offset)

        Perform random-access write operation on a file, without affecting
        the current seek position of the file.
        For details type ``man 2 pwrite``.

        :param userdata fh: file-handle as returned by ``fio.open()``
        :param string new-string: value to write (if the format is ``pwrite(new-string, offset)``)
        :param cdata buffer: value to write (if the format is ``pwrite(buffer, count, offset)``)
        :param number count: number of bytes to write
        :param number offset: offset within file where writing begins

        :return: true if success, false if failure.
        :rtype:  boolean

        If the format is ``pwrite(new-string, offset)`` then the returned string
        is written to the file, as far as the end of the string.

        If the format is ``pwrite(buffer, count, offset)`` then the buffer
        contents are written to the file, for ``count`` bytes.
        Buffers can be acquired with :ref:`buffer.ibuf <buffer-module>`.

        .. code-block:: tarantoolsession

            ibuf = require('buffer').ibuf()
            ---
            ...

            tarantool> fh:pwrite(ibuf, 1, 0)
            ---
            - true
            ...

    .. _file_handle-read:

    .. method:: read([count])
                read(buffer, count)

        Perform non-random-access read on a file. For details type
        ``man 2 read`` or ``man 2 write``.

        .. NOTE::

            ``fh:read`` and ``fh:write`` affect the seek position within the
            file, and this must be taken into account when working on the same
            file from multiple fibers. It is possible to limit or prevent file
            access from other fibers with ``fiber.ipc``.

        :param userdata fh: file-handle as returned by ``fio.open()``.
        :param buffer: where to read into (if the format is
                       ``read(buffer, count)``)
        :param number count: number of bytes to read

        :return: * If the format is ``read()`` -- omitting ``count`` -- then read all
                   bytes in the file.

                 * If the format is ``read()``  or ``read([count])`` then return a string
                   containing the data that was read from the file, or empty string if failure.

                 * If the format is ``read(buffer, count)`` then return the data
                   to the buffer.
                   Buffers can be acquired with :ref:`buffer.ibuf <buffer-module>`.

                 * In case of an error the method returns ``nil, err`` and sets
                   the error to ``errno``.

        .. code-block:: tarantoolsession

            ibuf = require('buffer').ibuf()
            ---
            ...

            tarantool> fh:read(ibuf:reserve(5), 5)
            ---
            - 5
            ...

            tarantool> require('ffi').string(ibuf:alloc(5),5)
            ---
            - abcde

    .. _file_handle-write:

    .. method:: write(new-string)
                write(buffer, count)

        Perform non-random-access write on a file. For details type
        ``man 2 write``.

        .. NOTE::

            ``fh:read`` and ``fh:write`` affect the seek position within the
            file, and this must be taken into account when working on the same
            file from multiple fibers. It is possible to limit or prevent file
            access from other fibers with ``fiber.ipc``.

        :param userdata fh: file-handle as returned by ``fio.open()``
        :param string new-string: value to write (if the format is ``write(new-string)``)
        :param cdata buffer: value to write (if the format is ``write(buffer, count)``)
        :param number count: number of bytes to write

        :return: true if success, false if failure.
        :rtype:  boolean

        If the format is ``write(new-string)`` then the returned string
        is written to the file, as far as the end of the string.

        If the format is ``write(buffer, count)`` then the buffer contents
        are written to the file, for ``count`` bytes.
        Buffers can be acquired with :ref:`buffer.ibuf <buffer-module>`.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> fh:write("new data")
            ---
            - true
            ...
            ibuf = require('buffer').ibuf()
            ---
            ...
            tarantool> fh:write(ibuf, 1)
            ---
            - true
            ...

    .. _file_handle-truncate:

    .. method:: truncate(new-size)

        Change the size of an open file. Differs from ``fio.truncate``, which
        changes the size of a closed file.

        :param userdata fh: file-handle as returned by ``fio.open()``.
        :return: true if success, false if failure.
        :rtype:  boolean

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> fh:truncate(0)
            ---
            - true
            ...

    .. _file_handle-seek:

    .. method:: seek(position [, offset-from])

        Shift position in the file to the specified position. For details type
        ``man 2 seek``.

        :param userdata fh: file-handle as returned by ``fio.open()``.
        :param number position: position to seek to
        :param string offset-from: '``SEEK_END``' = end of file, '``SEEK_CUR``'
                    = current position, '``SEEK_SET``' = start of file.
        :return: the new position if success
        :rtype:  number

        **Possible errors:** nil.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> fh:seek(20, 'SEEK_SET')
            ---
            - 20
            ...

    .. _file_handle-stat:

    .. method:: stat()

        Return statistics about an open file. This differs from ``fio.stat``
        which return statistics about a closed file. For details type
        ``man 2 stat``.

        :param userdata fh: file-handle as returned by ``fio.open()``.
        :return: details about the file.
        :rtype:  table

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> fh:stat()
            ---
            - inode: 729866
              rdev: 0
              size: 100
              atime: 140942855
              mode: 33261
              mtime: 1409430660
              nlink: 1
              uid: 1000
              blksize: 4096
              gid: 1000
              ctime: 1409430660
              dev: 2049
              blocks: 8
            ...

    .. _file_handle-fsync:

    .. method:: fsync()
                fdatasync()

        Ensure that file changes are written to disk, for an open file.
        Compare ``fio.sync``, which is for all files. For details type
        ``man 2 fsync`` or ``man 2 fdatasync``.

        :param userdata fh: file-handle as returned by ``fio.open()``.
        :return: true if success, false if failure.

        **Example:**

        .. code-block:: tarantoolsession

            tarantool> fh:fsync()
            ---
            - true
            ...

.. _fio-c:

===============================================================================
         FIO constants
===============================================================================

.. _fio-c_table:

.. data:: c

    Table with constants which are the same as POSIX flag values on the
    target platform (see ``man 2 stat``).

    **Example:**

    .. code-block:: tarantoolsession

        tarantool> fio.c
        ---
        - seek:
            SEEK_SET: 0
            SEEK_END: 2
            SEEK_CUR: 1
          mode:
            S_IWGRP: 16
            S_IXGRP: 8
            S_IROTH: 4
            S_IXOTH: 1
            S_IRUSR: 256
            S_IXUSR: 64
            S_IRWXU: 448
            S_IRWXG: 56
            S_IWOTH: 2
            S_IRWXO: 7
            S_IWUSR: 128
            S_IRGRP: 32
          flag:
            O_EXCL: 2048
            O_NONBLOCK: 4
            O_RDONLY: 0
            <...>
        ...
