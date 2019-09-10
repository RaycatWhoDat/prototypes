use v6;

grammar RakuLisp::Parser {
    token TOP { ^^ <statement> $$ }
    rule statement { <atom> | <sexp> }
    rule sexp { '(' ~ ')' <statement>* }

    proto token bool { * }
    token bool:sym<true>    {  '#t'  }
    token bool:sym<false>   {  '#f'  }
    
    proto token number { * }
    token number:sym<int> { <[-+]>? \d+ }

    proto token atom { * }
    token atom:sym<bool>   { <bool>   }
    token atom:sym<number> { <number> }
    token atom:sym<string> { <string> }
    token atom:sym<quote>  { <quote>  }
    token atom:sym<symbol> { <symbol> }

    token quote { \c[APOSTROPHE] <statement> }
    token string { \c[QUOTATION MARK] ~ \c[QUOTATION MARK] [ <str> | \\ <str=.str_escape> ]* }
    token str { <-[\c[QUOTATION MARK]\\\t\n]>+ }
    token str_escape { <[\c[QUOTATION MARK]\\/bfnrt]> }
    token symbol { <-[\c[APOSTROPHE]()\s]>+ }
}

class RakuLisp::Actions {
    method atom:sym<bool>($/) { say "This is a boolean: " ~ $/ }
    method atom:sym<symbol>($/) { say "This is a symbol: " ~ $/ }
    method atom:sym<string>($/) { say "This is a string: " ~ $/ }
    method atom:sym<number>($/) { say "This is a number: " ~ $/ }
}

sub MAIN() {
    my $raw-lisp = '(define test-func () "This is a test func." (interactive) (message "Test fun.") (+ 1 2))';
    my $parsed-lisp = RakuLisp::Parser.parse($raw-lisp, actions => RakuLisp::Actions.new);

    say $parsed-lisp;
} 

# Local Variables:
# compile-command: "perl6 raku-lisp.p6"
# End:
