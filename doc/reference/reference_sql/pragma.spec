stack (
  line(
    ' PRAGMA ',
    choice(
      None,
      line(
        'pragma-name',
        choice(
          None,
          line('=', 'pragma-value'),
          line('(', 'pragma-value', ')')
        )
      )
    )
  )
)
