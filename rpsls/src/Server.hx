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
                trace("Received a move. Countering.");

                var counterMove = switch (clientMove.data.move) {
                    case ValidMoves.ROCK: ValidMoves.PAPER;
                    case ValidMoves.PAPER: ValidMoves.SCISSORS;
                    case ValidMoves.SCISSORS: ValidMoves.SPOCK;
                    case ValidMoves.SPOCK: ValidMoves.LIZARD;
                    case ValidMoves.LIZARD: ValidMoves.ROCK;
                }

                // var counterMove;
                // if (ValidMoves.ROCK.match(clientMove.data.move)) counterMove = ValidMoves.PAPER;
                // if (ValidMoves.PAPER.match(clientMove.data.move)) counterMove = ValidMoves.SCISSORS;
                // if (ValidMoves.SCISSORS.match(clientMove.data.move)) counterMove = ValidMoves.SPOCK;
                // if (ValidMoves.SPOCK.match(clientMove.data.move)) counterMove = ValidMoves.LIZARD;
                // if (ValidMoves.LIZARD.match(clientMove.data.move)) counterMove = ValidMoves.ROCK;

                // var counterMove = ValidMoves.ROCK;
                
                var serverMessage = {
                    type: UserDefinedSocketType.MOVE,
                    data: {
                        player: 1,
                        move: counterMove
                    }
                };

                socket.send(haxe.Json.stringify(serverMessage));
            });
        });
    }
}
