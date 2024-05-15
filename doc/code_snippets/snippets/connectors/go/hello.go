package main

import (
	"context"
	"fmt"
	"github.com/tarantool/go-tarantool/v2"
	"time"
)

func main() {
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

	// Interacting with the database
	// Insert data
	tuple1, err := conn.Do(
		tarantool.NewInsertRequest("bands").
			Tuple([]interface{}{1, "Roxette", 1986}),
	).Get()
	tuple2, err := conn.Do(
		tarantool.NewInsertRequest("bands").
			Tuple([]interface{}{2, "Scorpions", 1965}),
	).Get()
	tuple3, err := conn.Do(
		tarantool.NewInsertRequest("bands").
			Tuple([]interface{}{3, "Ace of Base", 1987}),
	).Get()
	tuple4, err := conn.Do(
		tarantool.NewInsertRequest("bands").
			Tuple([]interface{}{4, "The Beatles", 1960}),
	).Get()
	fmt.Println("Inserted tuples: ", tuple1, tuple2, tuple3, tuple4)

	// Select by primary key
	data, err := conn.Do(
		tarantool.NewSelectRequest("bands").
			Limit(10).
			Iterator(tarantool.IterEq).
			Key([]interface{}{uint(1)}),
	).Get()
	fmt.Println("Tuple selected the primary key value:", data)

	// Select by secondary key
	data, err = conn.Do(
		tarantool.NewSelectRequest("bands").
			Index("band").
			Limit(10).
			Iterator(tarantool.IterEq).
			Key([]interface{}{"The Beatles"}),
	).Get()
	fmt.Println("Tuple selected the secondary key value:", data)

	// Update
	data, err = conn.Do(
		tarantool.NewUpdateRequest("bands").
			Key(tarantool.IntKey{2}).
			Operations(tarantool.NewOperations().Assign(1, "Pink Floyd")),
	).Get()
	fmt.Println("Updated tuple:", data)

	// Upsert
	data, err = conn.Do(
		tarantool.NewUpsertRequest("bands").
			Tuple([]interface{}{uint(5), "The Rolling Stones", 1962}).
			Operations(tarantool.NewOperations().Assign(1, "The Doors")),
	).Get()

	// Replace
	data, err = conn.Do(
		tarantool.NewReplaceRequest("bands").
			Tuple([]interface{}{1, "Queen", 1970}),
	).Get()
	fmt.Println("Replaced tuple:", data)

	// Delete
	data, err = conn.Do(
		tarantool.NewDeleteRequest("bands").
			Key([]interface{}{uint(5)}),
	).Get()
	fmt.Println("Deleted tuple:", data)

	// Call
	data, err = conn.Do(
		tarantool.NewCallRequest("get_bands_older_than").Args([]interface{}{1966}),
	).Get()
	fmt.Println("Stored procedure result:", data)

	// Close connection
	conn.CloseGraceful()
	fmt.Println("Connection is closed")
}
