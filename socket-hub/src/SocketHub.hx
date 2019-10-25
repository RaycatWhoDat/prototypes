package;

import RouteGenerator;
import routes.Root;

import externs.Cors;

class SocketHub {
    public static function main() {
        var expressApp = new Application();
        
        var port = process.env.get("PORT") != null ? process.env.get("PORT") : "8080";

        expressApp.set("port", port);

        expressApp.use(new Cors());
        
        expressApp.use(BodyParser.json());
        expressApp.use(BodyParser.urlencoded({ extended: true }));

        RouteGenerator.attachRoutes(Root, expressApp);
        
        expressApp.listen(Std.parseInt(expressApp.get("port")), () -> {
            trace("Now listening on port " + expressApp.get("port"));
          });
    }
}
