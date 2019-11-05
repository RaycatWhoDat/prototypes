package;

typedef SocketMessage = {
    var type: UserDefinedSocketType;
    var data: {
        var player: Int;
        var move: ValidMoves;
    }
}

class Client {
    public static function main() {
        var ws = new js.html.WebSocket("ws://localhost:8081");
        
        var onSocketOpen = function () {
            var message: SocketMessage = {
                type: UserDefinedSocketType.MOVE,
                data: {
                    player: 2,
                    move: ValidMoves.PAPER
                }
            };
            
            ws.send(haxe.Json.stringify(message));
        };

        var onSocketMessage = function (event) {
            var _event: haxe.DynamicAccess<Dynamic> = event;
            var data: SocketMessage = haxe.Json.parse(_event.get("data"));

            trace(data);
        }

        ws.onopen = onSocketOpen;
        ws.onmessage = onSocketMessage;
    }
}
