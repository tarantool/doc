-- This script is used to estimate the speed of CRUD operations
-- for different compression algorithms: zstd, lz4, and zlib.

box.cfg {
    memtx_memory = 2 * 1024 * 1024 * 1024,
    log_level = 1,
    wal_mode = 'none'
}
clock = require('clock')

test_space = box.schema.space.create('test_space', { if_not_exists = true })
test_space:format({
    { name = 'id', type = 'unsigned' },
    { name = 'value', type = 'string', compression = 'none' }, -- Possible values: none, zstd, lz4, zlib
})
test_space:create_index(
        'primary',
        {
            parts = { 'id' },
            if_not_exists = true,
        }
)

initial_data = [[
{
	"id": "0001",
	"type": "donut",
	"name": "Cake",
	"ppu": 0.55,
	"batters":
		{
			"batter":
				[
					{ "id": "1001", "type": "Regular" },
					{ "id": "1002", "type": "Chocolate" },
					{ "id": "1003", "type": "Blueberry" },
					{ "id": "1004", "type": "Devil's Food" }
				]
		},
	"topping":
		[
			{ "id": "5001", "type": "None" },
			{ "id": "5002", "type": "Glazed" },
			{ "id": "5005", "type": "Sugar" },
			{ "id": "5007", "type": "Powdered Sugar" },
			{ "id": "5006", "type": "Chocolate with Sprinkles" },
			{ "id": "5003", "type": "Chocolate" },
			{ "id": "5004", "type": "Maple" }
		]
}
]]

new_data = [[
	{
		"id": "0003",
		"type": "donut",
		"name": "Old Fashioned",
		"ppu": 0.55,
		"batters":
			{
				"batter":
					[
						{ "id": "1001", "type": "Regular" },
						{ "id": "1002", "type": "Chocolate" }
					]
			},
		"topping":
			[
				{ "id": "5001", "type": "None" },
				{ "id": "5002", "type": "Glazed" },
				{ "id": "5003", "type": "Chocolate" },
				{ "id": "5004", "type": "Maple" }
			]
	}
]]

space_size = 100000

function insert_bench()
    for i = 1, space_size do
        test_space:insert({i, tostring(initial_data)})
    end
end
insert_rps = space_size / clock.bench(insert_bench)[1]

function full_scan_bench()
    test_space:select(nil, { fullscan = true })
end
full_scan_rps = space_size / clock.bench(full_scan_bench)[1]

function select_bench()
    for i = 1, space_size do
        test_space:get(i)
    end
end
select_rps = space_size / clock.bench(select_bench)[1]

function replace_bench()
    for i = 1, space_size do
        test_space:replace({i, tostring(new_data)})
    end
end
replace_rps = space_size / clock.bench(replace_bench)[1]

print('Insert RPS: ' .. insert_rps)
print('Full scan RPS: ' .. full_scan_rps)
print('Select RPS: ' .. select_rps)
print('Replace RPS: ' .. replace_rps)
print('Space size: ' .. tostring(test_space:bsize()))

os.exit()
