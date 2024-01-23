function connect()
    local connection = require('net.box').connect({
        uri = 'admin:topsecret@127.0.0.1:3301',
        params = { transport = 'ssl',
                   ssl_cert_file = 'certs/instance001/server001.crt',
                   ssl_key_file = 'certs/instance001/server001.key',
                   ssl_password = 'qwerty' }
    })
    return connection
end
