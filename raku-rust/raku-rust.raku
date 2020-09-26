use v6;
use NativeCall;

constant LIBRARY_PATH = IO::Path.new: "addition/lib/release";

sub add(int32, int32) returns int32 is native(LIBRARY_PATH.add("addition").path) { * }

for 1..100 -> $firstNumber, $secondNumber {
    say add($firstNumber, $secondNumber);
}
