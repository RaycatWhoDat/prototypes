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

    public static function attachButtonListeners() {
        var document = Browser.document.body;
        var buttons = document.querySelectorAll(".moves button");
        for (button in buttons) {
            var buttonElement = cast (button, js.html.DOMElement);
            var validMoveRegex = ~/(rock|paper|scissors|lizard|spock)/g;
            validMoveRegex.match(buttonElement.classList.value);

            var selectedMove = switch (validMoveRegex.matched(0)) {
                case "rock": ValidMoves.ROCK;
                case "paper": ValidMoves.PAPER;
                case "scissors": ValidMoves.SCISSORS;
                case "lizard": ValidMoves.LIZARD;
                case "spock": ValidMoves.SPOCK;
                case _: throw "Not a valid move.";
            };

            button.addEventListener("click", () -> {
                var message: SocketMessage = {
                    type: UserDefinedSocketType.MOVE,
                    data: { player: 2, move: selectedMove }
                };
                
                ws.send(haxe.Json.stringify(message));
            });
        }
    }
    
    public static function main() {
        Client.connectWebSocket();
        Client.attachButtonListeners();
    }
}

