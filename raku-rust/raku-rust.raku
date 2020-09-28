use v6;

use lib "lib";
use AdditionLib;

for 1..100 -> $firstNumber, $secondNumber {
    say add($firstNumber, $secondNumber);
}
