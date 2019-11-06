package;

import externs.Cors;
import js.Node;

using haxe.EnumTools;

class Server {
    public static function main() {
        var expressApp = new Application();
        var webSocketServer = new WebSocketServer({ port: 8081 });
        
        var port = process.env.get("PORT") != null
            ? process.env.get("PORT")
            : "8080";

        expressApp.set("port", port);

        expressApp.use(new Cors());
        expressApp.use(BodyParser.json());
        expressApp.use(BodyParser.urlencoded({ extended: true }));

        expressApp.use("/", Express.Static(Node.__dirname));
        
        expressApp.listen(Std.parseInt(expressApp.get("port")), () -> {
            trace("Server ready.");
            trace("Now listening on port " + expressApp.get("port") + ".");
        });

        webSocketServer.on("connection", (socket: WebSocket) -> {
            socket.on("message", (message: String) -> {
                var clientMove: SocketMessage = haxe.Json.parse(message);

                var counterMove = switch (clientMove.data.move) {
                    case ValidMoves.ROCK: ValidMoves.PAPER;
                    case ValidMoves.PAPER: ValidMoves.SCISSORS;
                    case ValidMoves.SCISSORS: ValidMoves.SPOCK;
                    case ValidMoves.SPOCK: ValidMoves.LIZARD;
                    case ValidMoves.LIZARD: ValidMoves.ROCK;
                    case _: throw "Not a valid move.";
                }

                trace('Got ${clientMove.data.move}. Countering with $counterMove.');
                
                var serverMessage = {
                    type: UserDefinedSocketType.MOVE,
                    data: { player: 1, move: counterMove }
                };

                socket.send(haxe.Json.stringify(serverMessage));
            });
        });
    }
}
