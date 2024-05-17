package main

import (
	"context"
	"fmt"
	"github.com/tarantool/go-tarantool/v2"
	_ "github.com/tarantool/go-tarantool/v2/datetime"
	_ "github.com/tarantool/go-tarantool/v2/decimal"
	_ "github.com/tarantool/go-tarantool/v2/uuid"
	"time"
)

func main() {
	// Connect to the database
	ctx, cancel := context.WithTimeout(context.Background(), time.Second)
	defer cancel()
	dialer := tarantool.NetDialer{
		Address:  "127.0.0.1:3301",
		User:     "sampleuser",
		Password: "123456",
	}
	opts := tarantool.Opts{
		Timeout: time.Second,
	}

	conn, err := tarantool.Connect(ctx, dialer, opts)
	if err != nil {
		fmt.Println("Connection refused:", err)
		return
	}

	// Interact with the database
	// ...
	// Insert data
	tuples := [][]interface{}{
		{1, "Roxette", 1986},
		{2, "Scorpions", 1965},
		{3, "Ace of Base", 1987},
		{4, "The Beatles", 1960},
	}
	var futures []*tarantool.Future
	for _, tuple := range tuples {
		request := tarantool.NewInsertRequest("bands").Tuple(tuple)
		futures = append(futures, conn.Do(request))
	}
	fmt.Println("Inserted tuples:")
	for _, future := range futures {
		result, err := future.Get()
		if err != nil {
			fmt.Println("Got an error:", err)
		} else {
			fmt.Println(result)
		}
	}

	// Select by primary key
	data, err := conn.Do(
		tarantool.NewSelectRequest("bands").
			Limit(10).
			Iterator(tarantool.IterEq).
			Key([]interface{}{uint(1)}),
	).Get()
	if err != nil {
		fmt.Println("Got an error:", err)
	}
	fmt.Println("Tuple selected by the primary key value:", data)

	// Select by secondary key
	data, err = conn.Do(
		tarantool.NewSelectRequest("bands").
			Index("band").
			Limit(10).
			Iterator(tarantool.IterEq).
			Key([]interface{}{"The Beatles"}),
	).Get()
	if err != nil {
		fmt.Println("Got an error:", err)
	}
	fmt.Println("Tuple selected by the secondary key value:", data)

	// Update
	data, err = conn.Do(
		tarantool.NewUpdateRequest("bands").
			Key(tarantool.IntKey{2}).
			Operations(tarantool.NewOperations().Assign(1, "Pink Floyd")),
	).Get()
	if err != nil {
		fmt.Println("Got an error:", err)
	}
	fmt.Println("Updated tuple:", data)

	// Upsert
	data, err = conn.Do(
		tarantool.NewUpsertRequest("bands").
			Tuple([]interface{}{uint(5), "The Rolling Stones", 1962}).
			Operations(tarantool.NewOperations().Assign(1, "The Doors")),
	).Get()
	if err != nil {
		fmt.Println("Got an error:", err)
	}

	// Replace
	data, err = conn.Do(
		tarantool.NewReplaceRequest("bands").
			Tuple([]interface{}{1, "Queen", 1970}),
	).Get()
	if err != nil {
		fmt.Println("Got an error:", err)
	}
	fmt.Println("Replaced tuple:", data)

	// Delete
	data, err = conn.Do(
		tarantool.NewDeleteRequest("bands").
			Key([]interface{}{uint(5)}),
	).Get()
	if err != nil {
		fmt.Println("Got an error:", err)
	}
	fmt.Println("Deleted tuple:", data)

	// Call
	data, err = conn.Do(
		tarantool.NewCallRequest("get_bands_older_than").Args([]interface{}{1966}),
	).Get()
	if err != nil {
		fmt.Println("Got an error:", err)
	}
	fmt.Println("Stored procedure result:", data)

	// Close connection
	conn.CloseGraceful()
	fmt.Println("Connection is closed")
}
