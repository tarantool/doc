stack (
  line(
    ' DELETE ', ' FROM ', 'table-name',
    choice(
      None,
      line(' WHERE ', 'search-condition')
    )
  )
)
