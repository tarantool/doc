.. _app_server-using_ide:

================================================================================
Developing with an IDE
================================================================================

You can use IntelliJ IDEA as an IDE to develop and debug Lua applications for
Tarantool.

1. Download and install the IDE from the
   `official web-site <https://www.jetbrains.com/idea/>`_.

   JetBrains provides specialized editions for particular languages:
   IntelliJ IDEA (Java), PHPStorm (PHP), PyCharm (Python), RubyMine (Ruby),
   CLion (C/C++), WebStorm (Web) and others.
   So, download a version that suits your primary programming language.

   Tarantool integration is supported for all editions.

2. Configure the IDE:

   a. Start IntelliJ IDEA.
   b. Click ``Configure`` button and select ``Plugins``.

      .. image:: ide_1.png
         :align: left
         :scale: 50 %
         :class: frame

   c. Click ``Browse repositories``.

      .. image:: ide_2.png
         :align: left
         :scale: 50 %
         :class: frame

   d. Install ``EmmyLua`` plugin.

      .. NOTE::

         Please don’t be confused with ``Lua`` plugin, which is less powerful
         than ``EmmyLua``.

      .. image:: ide_3.png
         :align: left
         :scale: 50 %
         :class: frame

   e. Restart IntelliJ IDEA.
   f. Click ``Configure``, select ``Project Defaults`` and then
      ``Run Configurations``.

      .. image:: ide_4.png
         :align: left
         :scale: 50 %
         :class: frame

   g. Find ``Lua Application`` in the sidebar at the left.

   h. In ``Program``, type a path to an installed ``tarantool`` binary.

      By default, this is ``tarantool`` or ``/usr/bin/tarantool`` on most
      platforms.

      If you installed ``tarantool`` from sources to a custom directory,
      please specify the proper path here.

      .. image:: ide_5.png
         :align: left
         :scale: 50 %
         :class: frame

      Now IntelliJ IDEA is ready to use with Tarantool.

3. Create a new Lua project.

   .. image:: ide_6.png
      :align: left
      :scale: 50 %
      :class: frame

4. Add a new Lua file, for example ``init.lua``.

   .. image:: ide_7.png
      :align: left
      :scale: 50 %
      :class: frame

5. Write your code, save the file.

6. To run you application, click ``Run -> Run`` in the main menu and select
   your source file in the list.

   .. image:: ide_8.png
      :align: left
      :scale: 50 %
      :class: frame

   Or click ``Run -> Debug`` to start debugging.

   .. NOTE::

      To use Lua debugger, please upgrade Tarantool to version
      1.7.5-29-gbb6170e4b or later.

   .. image:: ide_9.png
      :align: left
      :scale: 50 %
      :class: frame
