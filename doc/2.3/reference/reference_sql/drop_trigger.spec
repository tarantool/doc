stack (
  line(
    ' DROP ', ' TRIGGER ',
    choice(
      None,
      line(' IF ', ' EXISTS ')
    ),
    'trigger-name'
  )
)
