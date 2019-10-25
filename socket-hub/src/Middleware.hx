package;

import Types;

class Middleware {
    @endpoint("/")
    @getMapping
    public static function test3(req: Request, res: Response, next: Dynamic) {
        trace("Anotha one.");
        next();
    }

    @endpoint("/")
    @getMapping
    public static function test2(req: Request, res: Response, next: Dynamic) {
        trace("Root route requested.");
        res.json("Ready.");
        next();
    }
}
