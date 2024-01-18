-- myapp.lua --

-- Create space
function create_space()
    box.schema.space.create('Bands')
    box.space.bands:format({
        { name = 'id', type = 'unsigned' },
        { name = 'band_name', type = 'string' },
        { name = 'year', type = 'unsigned' }
    })
    box.space.bands:create_index('primary', { type = "tree", parts = { 'id' } })
    box.space.bands:create_index('secondary', { type = "tree", parts = { 'band_name' } })
    box.schema.user.grant('guest', 'read,write,execute', 'universe')
end
-- Insert data
function load_data()
    box.space.bands:insert { 1, 'Roxette', 1986 }
    box.space.bands:insert { 2, 'Scorpions', 1965 }
end

local audit = require('audit')
-- Log message string
audit.log('Hello, Alice!')
-- Log format string and arguments
audit.log('Hello, %s!', 'Bob')
-- Log table with audit log field values
audit.log({ type = 'custom_hello', description = 'Hello, World!' })
audit.log({ type = 'custom_farewell', user = 'eve', module = 'custom', description = 'Farewell, Eve!' })
-- Create a new log module
local my_audit = audit.new({ type = 'custom_hello', module = 'my_module' })
my_audit:log('Hello, Alice!')
my_audit:log({ tag = 'admin', description = 'Hello, Bob!' })

-- Log 'Hello!' message with the VERBOSE severity level
audit.log({ severity = 'VERBOSE', description = 'Hello!' })

-- Log 'Hello!' message with a shortcut helper function
audit.verbose('Hello!')

-- Like audit.log(), a shortcut helper function accepts a table of options
audit.verbose({ description = 'Hello!' })

-- Severity levels are available for custom loggers
local my_logger = audit.new({ module = 'my_module' })
my_logger:log({ severity = 'ALARM', description = 'Alarm' })
my_logger:alarm('Alarm')

-- Overwrite session_type and remote fields
audit.log({ type = 'custom_hello', description = 'Hello!',
            session_type = 'my_session', remote = 'my_remote' })
-- End