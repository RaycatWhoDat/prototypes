use v6;
use NativeCall;

sub add(int32, int32) returns int32 is native('addition/target/debug/addition') { * }

for 0..100 -> $first, $second {
    say add($first, $second);
}
