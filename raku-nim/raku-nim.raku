use v6;
use NativeCall;

sub add(int32, int32) returns int32 is native('addition') { * };

for 1..100 -> $firstNumber, $secondNumber {
    say add($firstNumber, $secondNumber);
}
