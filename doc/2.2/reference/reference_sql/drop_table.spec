stack (
  line(
    ' DROP ', ' TABLE ',
    choice(
      None,
      line(' IF ', ' EXISTS ')
    ),
    'table-name'
  )
)
