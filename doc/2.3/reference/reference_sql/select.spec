stack (
  line(
    ' SELECT ',
    choice(
      None,
      ' DISTINCT ',
      ' ALL '
    ),
    loop('select-list-column',',')
  ),
  line(
    choice(
      line(' FROM ', 'join-source'),
      None
    )
  ),
  line(
    choice(
      line(' WHERE ', 'expression'),
      None
    )
  ),
  line(
    choice(
      line(' GROUP BY ', loop('expression', ',')),
      None
    )
  ),
  line(
    choice(
      line(' HAVING ', 'expression'),
      None
    )
  ),
  line(
    choice(
      line(' ORDER BY ',loop(line('expression', choice(None,' ASC ',' DESC ')),',')),
      None
    )
  ),
  line(
    choice(
      None,
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
  )
)
