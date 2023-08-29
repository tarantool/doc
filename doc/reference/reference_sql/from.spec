stack (
  line(
    choice(
      line(
        choice(
          None,
          line(' SEQSCAN ')
         ),
        'table-name',
        choice(
          None,
          line(
            choice(
              None,
              ' AS '
            ),
            'table-name'
          )
        ),
        choice(
          None,
          line(' INDEXED ', ' BY ', 'index-name'),
          line(' NOT ', ' INDEXED ')
        ) 
      ),
      line(
        '(', 'select-statement', ')',
        choice(
          None,
          line(
            choice(
              None,
              ' AS '
            ),
            'table-name'
          )
        )
      ),
      line('(', 'join-source', ')')
    )
  )
)
