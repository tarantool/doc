local log = require('log')
config = require('config')

storage_client = config.storage_client.connect({
    {
        uri = '127.0.0.1:4401',
        login = 'sampleuser',
        password = '123456',
    },
    {
        uri = '127.0.0.1:4402',
        login = 'sampleuser',
        password = '123456',
    },
    {
        uri = '127.0.0.1:4403',
        login = 'sampleuser',
        password = '123456',
    },
})

function register_watchers()
    storage_client:watch('/myapp/config/all', function(_, revision)
        log.info("Configuration stored by the '/myapp/config/all' key is " ..
                 "changed. New revision number is %d.", revision)
    end)
end

register_watchers()

function connect_to_configured_storage()
    -- `config.storage.endpoints` configuration section can be
    -- passed directly as `connect()` options to connect to the
    -- configured config.storage cluster.
    local endpoints = config:get('config.storage.endpoints')
    local storage_client = config.storage_client.connect(endpoints)

    return storage_client
end

function put_config()
    local fio = require('fio')
    local cluster_config_handle = fio.open('../../source.yaml')
    local cluster_config = cluster_config_handle:read()
    local response = storage_client:put('/myapp/config/all', cluster_config)
    cluster_config_handle:close()

    return response
end

function get_config_by_path()
    local response = storage_client:get('/myapp/config/all')

    return response
end

function get_config_by_prefix()
    local response = storage_client:get('/myapp/')

    return response
end

function make_txn_request()
    -- Execute an atomic request on the config.storage cluster.
    local response = storage_client:txn({
        predicates = { { 'value', '==', 'v0', '/myapp/config/all' } },
        on_success = { { 'put', '/myapp/config/all', 'v1' } },
        on_failure = { { 'get', '/myapp/config/all' } }
    })

    return response
end

function delete_config()
    local response = storage_client:delete('/myapp/config/all')

    return response
end

function delete_all_configs()
    local response = storage_client:delete('/')

    return response
end
