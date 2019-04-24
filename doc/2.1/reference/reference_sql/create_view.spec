stack (
  line(
    ' CREATE ', ' VIEW ',
    choice(
      None,
      line(' IF ', ' NOT ', ' EXISTS ')
    ),
    'view-name'
  ),
  line(
    ' AS ', 'select-statement'
  )
)
