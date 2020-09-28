use NativeCall;

unit module AdditionLib;

constant LIBRARY_PATH = IO::Path.new: "addition/lib/release";
constant LIBRARY_NAME = "addition";

sub add(int32, int32 --> int32) is native(LIBRARY_PATH.add(LIBRARY_NAME).path) is export { * };
