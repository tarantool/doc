function put_config()
    local fio = require('fio')
    local cluster_config_handle = fio.open('../../source.yaml')
    local cluster_config = cluster_config_handle:read()
    local response = config.storage.put('/myapp/config/all', cluster_config)
    cluster_config_handle:close()
    return response
end

function get_config_by_path()
    local response = config.storage.get('/myapp/config/all')
    return response
end

function get_config_by_prefix()
    local response = config.storage.get('/myapp/')
    return response
end

function make_txn_request()
    local response = config.storage.txn({
        predicates = { { 'value', '==', 'v0', '/myapp/config/all' } },
        on_success = { { 'put', '/myapp/config/all', 'v1' } },
        on_failure = { { 'get', '/myapp/config/all' } }
    })
    return response
end

function delete_config()
    local response = config.storage.delete('/myapp/config/all')
    return response
end

function delete_all_configs()
    local response = config.storage.delete('/')
    return response
end
