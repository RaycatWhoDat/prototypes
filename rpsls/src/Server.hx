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
            trace('Server ready.');
            trace("Now listening on port " + expressApp.get("port") + ".");
        });

        webSocketServer.on("connection", (socket: WebSocket) -> {
            socket.on("message", (message: String) -> {
                trace("Received: " + haxe.Json.parse(message));
            });

            var serverMessage = {
                type: UserDefinedSocketType.MOVE.getName(),
                data: {
                    player: 1,
                    move: ValidMoves.ROCK.getName()
                }
            };
            
            socket.send(haxe.Json.stringify(serverMessage));
        });
    }
}
