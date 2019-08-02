stack (
    line(
        ' INSERT ', ' INTO ', 'table-name'
    ),
    choice(line(
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
                ' VALUES ', '(', loop('expression', ','), ')'
            ),
            line(
                'select-statement'
            )
        )
    ),
        line(
            ' DEFAULT ', ' VALUES '
        )
    )
)
