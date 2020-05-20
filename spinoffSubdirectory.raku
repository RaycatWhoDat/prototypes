#!/usr/bin/env perl6

sub MAIN(
    Str :$folder!, #= The subdirectory you wish to spinoff.
    Str :$branch!, #= The branch you'd like to spinoff.
    Str :repo(:$repository)! #= The URL of the remote repository
) {
    loop {
        my $answer = prompt "Would you like to spinoff $folder from $branch into $repository? [y/N] ";
        redo unless $answer ~~ /:i y|n/;
        if ($answer ~~ /:i n/) { return; }
        last;
    }

    my Str constant $ORIGINAL_REPO_NAME = "git@github.com:RayMPerry/prototypes.git";
    
    say "Spinning off subdirectory.";

    my @commandsToRun = <<filter-branch -f --prune-empty --subdirectory-filter $folder $branch>>,
    <<remote set-url origin $repository>>,
    <push -u origin master>,
    <<remote set-url origin $ORIGINAL_REPO_NAME>>,
    <fetch --all>,
    <reset --hard origin/master>;
    
    for @commandsToRun -> @command {
        last if not so run("git", |@command);
    }
}

# Local Variables:
# compile-command: "perl6 spinoffSubdirectory.p6"
# End:
