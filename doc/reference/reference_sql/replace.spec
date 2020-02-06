stack (
    line(
        ' REPLACE ', ' INTO ', 'table-name'
    ),
    choice(line(
stack(
        line(
            choice(

                line(
                    '(', loop('column-name', ','), ')'
                ),
                None
            )

        ),
        choice(
            line(
                ' VALUES ',
  loop(
  line(
                '(', loop('expression', ','), ')'
  )
  ,',')
  ),
            line(
                'select-statement'
            )
        )
)
    ),
        line(
            ' DEFAULT ', ' VALUES '
        )
    )
)
