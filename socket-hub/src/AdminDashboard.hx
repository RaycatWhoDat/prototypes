package;

class AdminDashboard {
  public static function main() {
    var ws = new js.html.WebSocket("ws://localhost:8081");
                             
    ws.onopen = () -> ws.send("something");
    ws.onmessage = (data) -> trace(data);
  }
}