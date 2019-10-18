stack (
  line(
    ' CREATE ', ' TRIGGER ',
    choice(
      None,
      line(' IF ', ' NOT ', ' EXISTS ')
    ),
    'trigger-name'
  ),
  line(
    choice(
      ' BEFORE ',
      ' AFTER ',
      line(' INSTEAD OF ')
    )
  ),
  line(
    choice(
      ' DELETE ',
      ' INSERT ',
      line(
        ' UPDATE ',
        choice(
          None,
          line(
            ' OF ',
            loop(
              'column-name',
              ','
            )
          )
        )
      )
    ),
    ' ON ', 'table-name'
  ),
  line(
    ' FOR ',
    ' EACH ',
    ' ROW ',
    choice(
      None,
      line(' WHEN ', 'expression')
    )
  ),
  line(
    ' BEGIN ',
    loop(
      choice(
        line('update-statement',   ';'),
        line('insert-statement',   ';'),
        line('delete-statement',   ';'),
        line('select-statement',   ';')
      ),
      None
    ),
    ' END '
  )
)
