stack (
  line(
    'select-statement', ' INTERSECT ',
    'select-statement',
    choice(
      None,
      'order-by-and-limit-clauses'
    )
  )
)
