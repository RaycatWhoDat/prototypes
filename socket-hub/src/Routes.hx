package;

import haxe.rtti.Meta;

import Types;
import Middleware;

// TODO: RoutesGenerator, maybe?
class Routes {
    // TODO: Accept a class as well?
    public static function attachRoutes(app: Application): Application {
        var mappingInfo: haxe.DynamicAccess<Dynamic> = Meta.getStatics(Middleware);

        for (method => route in mappingInfo) {
            var currentRoute: Route = route;
            switch (currentRoute) {
            case { endpoint: endpointList, getMapping: _ }:
                app.get(endpointList[0], Reflect.field(Middleware, method));
            case { endpoint: endpointList, postMapping: _ }:
                app.post(endpointList[0], Reflect.field(Middleware, method));
            case { endpoint: endpointList, putMapping: _ }:
                app.put(endpointList[0], Reflect.field(Middleware, method));
            case { endpoint: endpointList, deleteMapping: _ }:
                app.delete(endpointList[0], Reflect.field(Middleware, method));
            }
        }

        return app;
    }
}
