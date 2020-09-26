use v6;
use NativeCall;

constant LIBRARY_PATH = IO::Path.new: "addition/target/debug";

sub add(int32, int32) returns int32 is native(LIBRARY_PATH.add("addition").path) { * }

for 0..100 -> $first, $second {
    say add($first, $second);
}
