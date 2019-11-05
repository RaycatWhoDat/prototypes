package types;

typedef SocketMessage = {
    var type: UserDefinedSocketType;
    var data: {
        var player: Int;
        var move: ValidMoves;
    }
}
