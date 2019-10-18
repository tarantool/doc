stack (
  line(
    choice(
      line(' CONSTRAINT ', 'name'),
      None
    )
  ),
  line(
    choice(
      line(
        ' PRIMARY ', ' KEY ', '(',
        loop(
          'column-name',
          ','
        ),
        ')'
      ),
      line(
        ' UNIQUE ', '(',
        loop(
          'column-name',
          ','
        ),
        ')'
      ),
      line(
        ' CHECK ',
        '(',
        'expression',
        ')'
      ),
      line(
        ' FOREIGN ', ' KEY ', '(',
        loop(
          'column-name',
          ','
        ),
        ')',
        'foreign-key-clause'    
      )
    )
  )
)
