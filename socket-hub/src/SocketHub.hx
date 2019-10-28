package;

import RouteGenerator;
import routes.Root;

import externs.Cors;

// TODO: Paths
// TODO: thx.core, utest, and haxe-files
// TODO: build system

// TODO: Enum for WebSocket events
// TODO: Type for WebSocket messages
// TODO: Class for sending messages

class SocketHub {
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

        RouteGenerator.attachRoutes(Root, expressApp);

        expressApp.use("/admin", Express.Static("assets/dashboard.html"));
        
        expressApp.listen(Std.parseInt(expressApp.get("port")), () -> {
            trace("Now listening on port " + expressApp.get("port"));
        });

        webSocketServer.on("connection", (socket: WebSocket) -> {
            socket.on("message", (message: String) -> {
                trace("received: " + message);
            });
            
            socket.send("something");
        });
    }
}
