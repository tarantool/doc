stack (
  line(
    ' CREATE ', ' TABLE ',
    choice(
      None,
      line(' IF ', ' NOT ', ' EXISTS ')
    ),
    'table-name'
  ),
  line(
    '(',
    loop(line(choice('column-definition','table-constraint')),','),
    ')'
  ),
  choice(
    None,
    line(' WITH ', ' ENGINE ', ' = ', 'string')
  )
)
