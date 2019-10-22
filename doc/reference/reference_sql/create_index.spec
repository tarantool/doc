stack (
  line(
      ' CREATE ',
      choice(
             None,
             ' UNIQUE '),
      ' INDEX ',
      choice(
             None,
             line(' IF ', ' NOT ', 'EXISTS ')),
      'index-name'
  ),
  line(
    ' ON ', 'table-name'
  ),
  line(
    '(', loop('column-name', ','), ')'
  )
)
