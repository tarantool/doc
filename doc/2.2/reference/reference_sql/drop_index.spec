stack (
  line(
    ' DROP ', ' INDEX ',
    choice(
      None,
      line(' IF ', ' EXISTS ')
    ),
    'index-name', ' ON ', 'table-name'
  )
)
