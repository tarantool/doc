stack (
  line(
    ' UPDATE ', 'table-name'
  ),
  line(
    ' SET ',
    loop(line('column-name', ' = ', 'expression'), ',')
  ),
  line(
    choice(
      None,
      line(' WHERE ', 'search-condition')
    )
  )
)
