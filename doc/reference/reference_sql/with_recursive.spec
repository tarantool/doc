stack (
  line(
    ' WITH ', ' RECURSIVE ', 'recursive-table-name', ' AS '
  ),
  line(
    '(',
    'select-statement',
    ' UNION ',
    choice(
      None,
      ' ALL '
     ),
     'select-statement',
     ')'
  ),
  line('statement-that-uses-recursive-table-name')
)
