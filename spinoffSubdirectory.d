import std.algorithm.searching;
import std.algorithm.comparison;
import std.getopt;
import std.stdio;
import std.ascii;
import std.string;
import std.typecons;
import std.process;

string directory, branch, repository;
const string ORIGINAL_REPO_NAME = "git@github.com:RayMPerry/prototypes.git";

bool isCommandSuccessful(Tuple!(int, "status", string, "output") executedCommand) {
  writeln(executedCommand.output);
  return executedCommand.status == 0;
}

int spinoffSubdirectory(string directory, string branch, string repository) {
    writeln("Spinning off subdirectory.");

    auto commandsToRun = [
        ["git", "filter-branch", "-f", "--prune-empty", "--subdirectory-filter", directory, branch],
        ["git", "remote", "set-url", "origin", repository],
        ["git", "push", "-u", "origin", "master"],
        ["git", "remote", "set-url", "origin", ORIGINAL_REPO_NAME],
        ["git", "fetch", "--all"],
        ["git", "reset", "--hard", "origin/master"]];

    foreach (command; commandsToRun) {
      if (!isCommandSuccessful(command.execute())) return 1;
    }

    return 0;
}

int main(string[] args) {
  auto scriptOptions = getopt(
      args,
      config.passThrough,
      "directory|d", "The directory you wish to spinoff.", &directory,
      "branch|b", "The branch you wish to spinoff.", &branch,
      "repository|r", "The URL of the remote destination.", &repository);

  if (![directory, branch, repository].all || scriptOptions.helpWanted) {
    defaultGetoptPrinter("This script pushes the commit history of a single directory to a repository.",
                         scriptOptions.options);
    return 0;
  }

  string answer;
  while (!answer.toLower.among!("y", "n")) {
    writef("Would you like to spinoff %s from %s into %s? [y/n] ", directory, branch, repository);
    answer = readln.chomp();
  }
  
  if (answer.toLower == "y") return spinoffSubdirectory(directory, branch, repository);
  return 0;
}
