stack (
  line(
    choice(
      None,
      line(' CONSTRAINT ', 'name')
    )
  ),
  line(
    choice(
      line(' PRIMARY ', ' KEY '),
      line(' NOT NULL '),
      line(' UNIQUE '),
      line(' DEFAULT ', 'expression'),
      line('foreign-key-clause')
    )
  )
)
