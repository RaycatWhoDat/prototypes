package;

import js.Browser;

class Client {
    public static var ws = new js.html.WebSocket("ws://localhost:8081");
    
    public static function connectWebSocket() {
        var onSocketOpen = function () {
            trace("Connected to :8081.");
        };

        var onSocketMessage = function (event) {
            var _event: haxe.DynamicAccess<Dynamic> = event;
            var serverMove: SocketMessage = haxe.Json.parse(_event.get("data"));

            trace(serverMove.data.move);
        }

        ws.onopen = onSocketOpen;
        ws.onmessage = onSocketMessage;
    }
    
    public static function main() {
        Client.connectWebSocket();

        var document = Browser.document.body;
        var buttons = document.querySelectorAll(".moves button");
        for (button in buttons) {
            var buttonElement = cast (button, js.html.DOMElement);

            var selectedMove;
            if (buttonElement.classList.contains("rock")) selectedMove = ValidMoves.ROCK;
            if (buttonElement.classList.contains("paper")) selectedMove = ValidMoves.PAPER;
            if (buttonElement.classList.contains("scissors")) selectedMove = ValidMoves.SCISSORS;
            if (buttonElement.classList.contains("lizard")) selectedMove = ValidMoves.LIZARD;
            if (buttonElement.classList.contains("spock")) selectedMove = ValidMoves.SPOCK;
            
            button.addEventListener("click", () -> {
                var message: SocketMessage = {
                    type: UserDefinedSocketType.MOVE,
                    data: {
                        player: 2,
                        move: selectedMove
                    }
                };
                
                ws.send(haxe.Json.stringify(message));
            });
        }
    }
}
