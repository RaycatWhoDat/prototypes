proc add*(number1, number2: int): int {.exportc, dynlib.} =
  number1 + number2

proc subtract*(number1, number2: int): int {.exportc, dynlib.} =
  number1 - number2

proc multiply*(number1, number2: int): int {.exportc, dynlib.} =
  number1 * number2

proc divide*(number1, number2: int): int {.exportc, dynlib.} =
  number1 div number2
