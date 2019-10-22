stack (
  line(
    choice(
      '*',
      line('table-name','.','*'),
      line(
        'expression',
        choice(
          None,
          line(
            choice(' AS ',None),
            'column-name'
          )
        )
      )
    )
  )
)
