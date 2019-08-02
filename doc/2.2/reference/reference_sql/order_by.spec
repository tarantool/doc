stack(
  line(' ORDER BY ',loop(line('expression', choice(None,' ASC ',' DESC ')),','))
)
