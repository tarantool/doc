stack (
  line(
    'select-statement', ' UNION ',
    choice(None, ' ALL '),
    'select-statement',
    choice(
      None,
      'order-by-and-limit-clauses'
    )
  )
)
