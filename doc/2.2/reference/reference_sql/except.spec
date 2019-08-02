stack (
  line(
    'select-statement', ' EXCEPT ',
    'select-statement',
    choice(
      None,
      'order-by-and-limit-clauses'
    )
  )
)
