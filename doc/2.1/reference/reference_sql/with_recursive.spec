stack (
  line(
    ' WITH ', ' RECURSIVE ', 'temporary-table-name', ' AS '
  ),
  line(
    '(',
    'select-statement',
    ' UNION ',
    choice(
      None,
      ' ALL '
     ),
     ')', 'statement'
  )
)
