package = 'sharded_cluster'
version = 'scm-1'
source  = {
    url = '/dev/null',
}

dependencies = {
    'tarantool',
    'lua >= 5.1',
    'vshard == 0.1.24'
}
build = {
    type = 'none';
}
