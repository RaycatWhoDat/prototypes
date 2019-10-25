package;

import Types;
import Routes;

class SocketHub {
    public static function main() {
        var app = new Application();
        var port = process.env.get("PORT") != null ? process.env.get("PORT") : "8080";

        app.set("port", port);

        app.use(BodyParser.json());
        app.use(BodyParser.urlencoded({ extended: true }));

        Routes.attachRoutes(app);
        
        app.listen(Std.parseInt(app.get("port")), () -> {
            trace("Now listening on port " + app.get("port"));
        });
    }
}
