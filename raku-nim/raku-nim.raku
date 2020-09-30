use v6;
use NativeCall;

constant LIBRARY_NAME = "./extramath";

sub add(int32, int32 --> int32) is native(LIBRARY_NAME) { * }
sub subtract(int32, int32 --> int32) is native(LIBRARY_NAME) { * }
sub multiply(int32, int32 --> int32) is native(LIBRARY_NAME) { * }
sub divide(int32, int32 --> int32) is native(LIBRARY_NAME) { * }

say divide(subtract(multiply(add(1, 2), 3), 4), 5);
