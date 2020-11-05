package main

import (
	"fmt"
	"log"

	"github.com/tarantool/go-tarantool"
)

/*
box.cfg{listen = 3301}
box.schema.user.passwd('pass')

s = box.schema.space.create('tester')
s:format({
    {name = 'id', type = 'unsigned'},
    {name = 'band_name', type = 'string'},
    {name = 'year', type = 'unsigned'}
})
s:create_index('primary', { type = 'hash', parts = {'id'} })
s:create_index('scanner', { type = 'tree', parts = {'id', 'band_name'} })

s:insert{1, 'Roxette', 1986}
s:insert{2, 'Scorpions', 2015}
s:insert{3, 'Ace of Base', 1993}
*/

func main() {
	conn, err := tarantool.Connect("127.0.0.1:3301", tarantool.Opts{
		User: "admin",
		Pass: "pass",
	})

	if err != nil {
		log.Fatalf("Connection refused")
	}
	defer conn.Close()

	spaceName := "tester"
	indexName := "scanner"
	idFn := conn.Schema.Spaces[spaceName].Fields["id"].Id
	bandNameFn := conn.Schema.Spaces[spaceName].Fields["band_name"].Id

	var tuplesPerRequest uint32 = 2
	cursor := []interface{}{}

	for {
		resp, err := conn.Select(spaceName, indexName, 0, tuplesPerRequest, tarantool.IterGt, cursor)
		if err != nil {
			log.Fatalf("Failed to select: %s", err)
		}

		if resp.Code != tarantool.OkCode {
			log.Fatalf("Select failed: %s", resp.Error)
		}

		if len(resp.Data) == 0 {
			break
		}

		fmt.Println("Iteration")

		tuples := resp.Tuples()
		for _, tuple := range tuples {
			fmt.Printf("\t%v\n", tuple)
		}

		lastTuple := tuples[len(tuples)-1]
		cursor = []interface{}{lastTuple[idFn], lastTuple[bandNameFn]}
	}
}
