## Rock, Paper, Scissors, Lizard, Spock
### WebSocket Edition

This is an attempt to show off a Haxe/JS project. You can click on the buttons at the top to test out the sockets but that's about it.

#### Requirements

* Node 10.x
* Lix
* Haxe 4+

#### Setup/Installation

```
npm i -g lix // if you don't have it installed
lix download
haxe build-all.hxml
node dist/rpsls-server.js
```

In the browser, go to:
```
localhost:8081 // default unless you've set another PORT
```

And that's it.
