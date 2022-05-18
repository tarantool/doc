stack (
  line(
    choice(
      line(' ANY '),
      line(' ARRAY '),
      line(' BOOL '),
      line(' BOOLEAN '),
      line(' DECIMAL '),
      line(' DOUBLE '),
      line(' INT '),
      line(' INTEGER '),
      line(' MAP '),
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
