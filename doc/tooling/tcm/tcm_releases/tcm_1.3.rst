.. _tcm_releases_1_3:

Tarantool Cluster Manager 1.3
=============================

Release date: March 14, 2025

Latest release in series: 1.3.1

|tcm_full_name| 1.3.0 enhances the TCF integration page with minor bug fixes and functional enhancements.
Below is an overview of key updates.

.. _tcm_releases_1_3_0_tcf:

TCF page improvements
------------------------

Starting from version 1.3.0, |tcm| provides additional actions for managing TCF clusters through the web interface.
You can now use **promote** and **demote** operations directly on the **TCF** page without switching to external tools.
Also, the **TCF** page is now disabled by default and must be explicitly enabled if needed.
In addition, |tcm| now supports connections to multiple gRPS servers, which improves integration with distributed cluster infrastructures.


.. _tcm_releases_1_3_0_explorer:
Explorer improvements
------------------------

|tcm| 1.3.0 introduces a new approach to pagination in the Explorer. Instead of using a tuple, the interface now relies on pointers for navigating result pages.
When sending data to the frontend, binary values (varbinary) are now automatically encoded in base64.

Additionally, |tcm| fixes an issue where queries using a datetime key could result in type mismatch errors due to incorrect index part handling.


.. _tcm_releases_1_3_0_etcd:
etcd integration fixes
------------------------

In this version, |tcm| improves its interaction with etcd-based data sources.
Tabs that use etcd for updating can now be refreshed even if some of the etcd endpoints are temporarily unavailable.
To improve stability, a check was added to detect and correctly handle empty tuple arrays, preventing unexpected errors when processing empty data.


.. _tcm_releases_1_3_0_crud:
CRUD and query parsing
------------------------

|tcm| 1.3.0 includes improvements to how search expressions are parsed in `CRUD <https://github.com/tarantool/crud>`__ explorer queries. The CRUD explorer is located on the **Tuples** page.
This release also introduces dedicated tests for the relevant components to ensure consistent behavior in future versions.


Since version 1.3.1, |tcm| includes missing changes that have now been properly delivered.
In addition, several minor issues flagged by the Svacer linter were fixed to improve overall code quality and maintainability.
