import tarantool

# Connect to the database
conn = tarantool.Connection(host='127.0.0.1',
                            port=3301,
                            user='sampleuser',
                            password='123456')

# Insert data
tuples = [(1, 'Roxette', 1986),
          (2, 'Scorpions', 1965),
          (3, 'Ace of Base', 1987),
          (4, 'The Beatles', 1960)]
print("Inserted tuples:")
for tuple in tuples:
    response = conn.insert(space_name='bands', values=tuple)
    print(response[0])

# Select by primary key
response = conn.select(space_name='bands', key=1)
print('Tuple selected by the primary key value:', response[0])

# Select by secondary key
response = conn.select(space_name='bands', key='The Beatles', index='band')
print('Tuple selected by the secondary key value:', response[0])

# Update
response = conn.update(space_name='bands',
                       key=2,
                       op_list=[('=', 'band_name', 'Pink Floyd')])
print('Updated tuple:', response[0])

# Upsert
conn.upsert(space_name='bands',
            tuple_value=(5, 'The Rolling Stones', 1962),
            op_list=[('=', 'band_name', 'The Doors')])

# Replace
response = conn.replace(space_name='bands', values=(1, 'Queen', 1970))
print('Replaced tuple:', response[0])

# Delete
response = conn.delete(space_name='bands', key=5)
print('Deleted tuple:', response[0])

# Call
response = conn.call('get_bands_older_than', 1966)
print('Stored procedure result:', response[0])

# Close connection
conn.close()
print('Connection is closed')
