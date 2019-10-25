package;

import haxe.rtti.Meta;

typedef Route = {
    var ?getMapping: Array<String>;
    var ?postMapping: Array<String>;
    var ?putMapping: Array<String>;
    var ?deleteMapping: Array<String>;
};

class RouteGenerator {
  public static function attachRoutes(routingClass: Class<Dynamic>, app: Application): Application {
        var mappingInfo: haxe.DynamicAccess<Dynamic> = Meta.getStatics(routingClass);

        for (method => route in mappingInfo) {
            var currentRoute: Route = route;
            switch (currentRoute) {
            case { getMapping: endpointList }:
                app.get(endpointList[0], Reflect.field(routingClass, method));
            }
        }

        return app;
    }
}
