proc add*(number1, number2: int): int {.exportc, dynlib.} =
  number1 + number2
