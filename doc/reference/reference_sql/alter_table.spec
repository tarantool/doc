stack (
  line(
    ' ALTER ', ' TABLE ', 'old-table-name'
  ),
  choice(
    line(
      ' RENAME ', ' TO ', 'new-table-name'
    ),
    line(
      ' ADD ', ' COLUMN ', 'column-name', 'column-definition'
    ),
    line(
      ' ADD ', ' CONSTRAINT ', 'constraint-name', 'constraint-definition'
    ),
    line(
      ' DROP ', ' CONSTRAINT ', 'constraint-name'
    ),
    line(
      choice(' ENABLE ', ' DISABLE '), ' CHECK ', ' CONSTRAINT ', 'constraint-name'
    )
   )
)
