package types;

// enum ValidMoves {
//     ROCK;
//     PAPER;
//     SCISSORS;
//     LIZARD;
//     SPOCK;
// }

@:enum
abstract ValidMoves(String) {
    var ROCK = "ROCK";
    var PAPER = "PAPER";
    var SCISSORS = "SCISSORS";
    var LIZARD = "LIZARD";
    var SPOCK = "SPOCK";
}
