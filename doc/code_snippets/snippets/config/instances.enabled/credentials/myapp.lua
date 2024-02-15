function create_spaces()
    box.schema.space.create('writers')
    box.space.writers:format({
        { name = 'id', type = 'unsigned' },
        { name = 'name', type = 'string' }
    })
    box.space.writers:create_index('primary', { parts = { 'id' } })

    box.schema.space.create('books')
    box.space.books:format({
        { name = 'id', type = 'unsigned' },
        { name = 'title', type = 'string' },
        { name = 'author_id', foreign_key = { space = 'writers', field = 'id' } },
    })
    box.space.books:create_index('primary', { parts = { 'id' } })
end

function load_data()
    box.space.writers:insert { 1, 'Leo Tolstoy' }
    box.space.writers:insert { 2, 'Fyodor Dostoevsky' }
    box.space.writers:insert { 3, 'Alexander Pushkin' }

    box.space.books:insert { 1, 'War and Peace', 1 }
    box.space.books:insert { 2, 'Anna Karenina', 1 }
    box.space.books:insert { 3, 'Resurrection', 1 }
    box.space.books:insert { 4, 'Crime and Punishment', 2 }
    box.space.books:insert { 5, 'The Idiot', 2 }
    box.space.books:insert { 6, 'The Brothers Karamazov', 2 }
    box.space.books:insert { 7, 'Eugene Onegin', 3 }
    box.space.books:insert { 8, 'The Captain\'s Daughter', 3 }
    box.space.books:insert { 9, 'Boris Godunov', 3 }
    box.space.books:insert { 10, 'Ruslan and Ludmila', 3 }
end

create_spaces()
load_data()
