stack (
  choice(
    line(' NOT NULL '),
    choice(
      line(
        choice(
          None,
          line(' CONSTRAINT ', 'name')
        ),
        choice(
          line(' PRIMARY ', ' KEY '),
          line(' UNIQUE '),
          line(' CHECK ', '(', 'expression', ')'),
          line('foreign-key-clause')
        )
      )
    ),
    line(' DEFAULT ', 'expression')
  )
)
