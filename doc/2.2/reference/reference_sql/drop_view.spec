stack (
  line(
    ' DROP ', ' VIEW ',
    choice(
      None,
      line(' IF ', ' EXISTS ')
    ),
    'view-name'
  )
)
