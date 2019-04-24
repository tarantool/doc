stack (
  line(
    ' LIMIT ', 'integer',
    choice(
      None,
      line(
        choice(' OFFSET ', ','), 'integer'
      )
    )
  )
)
