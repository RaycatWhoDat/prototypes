package;

import tink.Cli;
import tink.cli.*;
import tink.cli.Prompt;
import tink.cli.prompt.*;

class GitOfACat {
    public var branch: String;
    public var repo: String;
    public var folder: String;

    public function new() {}
    
    public static function main() {
        Cli.process(Sys.args(), new GitOfACat()).handle(Cli.exit);
    }

    public static function executeCommands(folder: String, repo: String, branch: String) {
        Sys.println('Spinning off subdirectory.');
        var ORIGINAL_REPO_NAME = 'git@github.com:RayMPerry/prototypes.git';

        var commandArguments = [
            'filter-branch -f --prune-empty --subdirectory-filter $folder $branch',
            'remote set-url origin $repo',
            'push -u origin master',
            'remote set-url origin $ORIGINAL_REPO_NAME',
            'fetch --all',
            'reset --hard origin/master'
        ];

        for (argument in commandArguments) {
            if (Sys.command("git", [argument]) != 0) {
                Sys.println('Something went wrong when running "git $argument".');
                break;
            }
        }
    }
    
    @:defaultCommand
    public function run() {
        if (branch.length <= 1 || repo.length <= 1 || folder.length <= 1) {
            Sys.println('Spinning off a subdirectory requires a qualified folder name, branch name, and repo name.');
            return;
        }

        var CONFIRMATION_MESSAGE = 'Would you like to spinoff $folder from $branch into $repo?';

        var confirmationPrompt = new DefaultPrompt()
            .prompt(MultipleChoices(CONFIRMATION_MESSAGE, ['y', 'N']));
        
        confirmationPrompt.handle(result -> {
            switch result {
            case Success('y'|'Y'): GitOfACat.executeCommands(folder, repo, branch);
            case _:
            }
        });
    }
}
