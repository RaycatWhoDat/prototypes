use v6;

constant $sourceDirectory = "src";
constant $destinationDirectory = "dist";

sub generatePage(IO() $filePath) {
    my $fileName = $filePath.basename.split(".").head;
    spurt "$destinationDirectory/" ~ $fileName ~ ".html", $filePath.slurp;
}

given "$destinationDirectory".IO { .mkdir if not .e }
generatePage($_) for "$sourceDirectory".IO.dir;

react {
    whenever "$sourceDirectory".IO.watch -> (:$event, :$path) {
        next if $event ~~ FileRenamed;
        my $newFileName = $path.split("/").tail;
        say "Found $newFileName.";
        generatePage($path);
    }
}
