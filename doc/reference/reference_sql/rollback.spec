stack (
  line(
    ' ROLLBACK ',
    choice(
      None,
      line(
        ' TO ',
        choice(' SAVEPOINT ', None),
        'savepoint-name'
      )
    )
  )
)
