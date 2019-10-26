package routes;

import js.Node;

class Root {
  @getMapping("/health")
  public static function adminPage(req: Request, res: Response, next: Dynamic) {
    return res.send("Socket Hub is online.");
  }
}