..  _tcm_cluster_security:

Security settings
=================

..  include:: ../index.rst
    :start-after: ee_note_tcm_start
    :end-before: ee_note_tcm_end

|tcm_full_name| includes a web interface for managing security settings of connected
clusters. It is available on the **Cluster** > **Security** page. On this page,
you can manage the following security features in the cluster:

-   *Authentication settings*: protocol (CHAP or PAP), number of retries, and
    the delay after a failed authentication attempt (:ref:`security.auth_* <configuration_reference_security>`
    configuration options). To learn more about Tarantool authentication settings, see :ref:`configuration_authentication`.
-   *Password policy*: minimal password length, required characters, expiration
    period, and other settings (:ref:`security.password_* <configuration_reference_security>`
    configuration options). To learn more about Tarantool password policy, see :ref:`enterprise-password-policy`.
-   *Guest access*: whether unauthenticated or :ref:`guest <authentication-passwords>`
    users can connect to cluster (:ref:`security.disable_guest <configuration_reference_security_disable_guest>`
    configuration option).
-   *Secure erasing*: whether to delete data files securely so that they cannot be restored
    (:ref:`security.secure_erasing <configuration_reference_security_secure_erasing>` configuration option).
-   *Audit log*: configure audit logging in the cluster
    (:ref:`audit_log.* <configuration_reference_audit>` configuration options).
    To learn how to manage audit logging in the cluster, see :ref:`enterprise_audit_module`.



