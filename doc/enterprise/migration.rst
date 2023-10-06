Migration from Tarantool Cartridge
==================================

If your company uses a service based on Tarantool Community Edition and
Tarantool Cartridge, follow the steps below to update these components to
Tarantool Enterprise Edition.

As a reference, the instructions below use a template service created with
:ref:`tt<tt-cli>`, the Tarantool CLI utility.

Service build pipeline
----------------------

Get access to the source code and build pipeline of your service. Here is an
example of what the service build pipeline might look like for CentOS/RHEL 7:

..  code-block:: bash

    curl -L https://tarantool.io/release/2/installer.sh | bash
    yum -y install tarantool tarantool-devel tt git gcc gcc-с++ cmake
    tt pack rpm


Update the pipeline
-------------------

In the installation section of your pipeline, replace open-source ``tarantool``
packages with Tarantool Enterprise SDK:

..  code-block:: bash

    curl -L \
      https://${TOKEN}@download.tarantool.io/enterprise/release/${OS}/${ARCH}/${VERSION}/tarantool-enterprise-sdk-${VERSION_OS_ARCH_POSTFIX}.tar.gz \
      > sdk.tar.gz
    
    # for example, the URL for the Linux build of Tarantool 2.10.4 for the x86_64 platform will be:
    # https://${TOKEN}@download.tarantool.io/enterprise/release/linux/x86_64/2.10/tarantool-enterprise-sdk-gc64-2.10.4-0-r523.linux.x86_64.tar.gz
    
    tar -xvf sdk.tar.gz
    source tarantool-enterprise/env.sh
    tt pack rpm

Now the pipeline will produce a new service artifact, which includes
Tarantool Enterprise.

Update the service
------------------

Update your service to the new version like you usually update Tarantool in
your organization. You don't have to interrupt access to the service.
To learn how to do it with ``ansible-cartridge``,
`check this example <https://github.com/tarantool/ansible-cartridge/blob/master/doc/rolling_update.md>`__.


That's it!
----------

You can now use Tarantool Enterprise features in your installation.
For example, to enable the audit log,
:ref:`set up the audit_log parameter in your node configuration <enterprise-logging>`.
