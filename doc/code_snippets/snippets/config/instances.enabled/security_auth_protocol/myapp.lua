function connect()
    local connection = require('net.box').connect({
        uri = 'admin:topsecret@127.0.0.1:3301',
        params = { auth_type = 'pap-sha256',
                   transport = 'ssl',
                   ssl_cert_file = 'certs/server.crt',
                   ssl_key_file = 'certs/server.key' }
    })
    return connection
end
