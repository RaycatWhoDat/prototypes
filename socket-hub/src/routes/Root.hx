package routes;

import js.Node;

class Root {
  @getMapping("/")
  public static function route3(req: Request, res: Response, next: Dynamic) {
    trace("Sending file.");
    return res.sendFile(Sys.getCwd() + "/dist/html/testbed.html");
  }
}
