stack (
  line(
    choice(
      line(' BOOL '),
      line(' BOOLEAN '),
      line(' DOUBLE '),
      line(' INT '),
      line(' INTEGER '),
      line(' NUMBER '),
      line(
        line(' SCALAR '),
        choice(
          line(None),
          line('collation-clause')
        )
      ),
      line(
        line(' STRING '),
        choice(
          line(None),
          line('collation-clause')
        )
      ),
      line(
        line(' TEXT '),
        choice(
          line(None),
          line('collation-clause')
        )
      ),
      line(' UNSIGNED '),
      line(' UUID '),
      line(' VARBINARY '),
      line(
        line(' VARCHAR ','(', 'integer', ')'),
        choice(
          line(None),
          line('collation-clause')
        )
      )
    )
  )
)
