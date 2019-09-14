#!/usr/bin/env rdmd

import std.stdio;
import std.getopt;
import std.algorithm;
import std.string;
import std.utf;
import std.process;
import std.format;
import std.typecons;

int main(string[] args) {
  const string ORIGINAL_REPO_NAME = "git@github.com:RayMPerry/prototypes.git";
  string FOLDER_NAME, BRANCH_NAME, REPO_NAME;

  getopt(args,
         "folder", &FOLDER_NAME,
         "branch", &BRANCH_NAME,
         "repo", &REPO_NAME);

  if ([FOLDER_NAME.length, BRANCH_NAME.length, REPO_NAME.length].any!`a < 1`) {
    writeln("--folder, --branch, and --repo must be specified.");
    return 1;
  }
  
  writef("Would you like to spinoff %s from %s into %s? [y/N] ", FOLDER_NAME, BRANCH_NAME, REPO_NAME);

  int spinoffSubdirectory(string folderName, string branchName, string repoName) {
    writeln("Spinning off subdirectory.");

    bool hasSucceeded(Tuple!(int, "status", string, "output") executedCommand) {
      writeln(executedCommand.output);
      return executedCommand.status == 0;
    }

    auto filterBranch = execute(["git", "filter-branch", "-f", "--prune-empty", "--subdirectory-filter", folderName, branchName]);
    if (!hasSucceeded(filterBranch)) return 2;
    
    auto setRemote = execute(["git", "remote", "set-url", "origin", repoName]);
    if (!hasSucceeded(setRemote)) return 3;

    auto pushToOrigin = execute(["git", "push", "-u", "origin", "master"]);
    if (!hasSucceeded(pushToOrigin)) return 4;

    auto resetOrigin = execute(["git", "remote", "set-url", "origin", ORIGINAL_REPO_NAME]);
    if (!hasSucceeded(resetOrigin)) return 5;

    auto resetLocal = execute(["git", "reset", "--hard", "origin", "master"]);
    if (!hasSucceeded(resetLocal)) return 6;
    
    return 0;
  }
    
  if (readln().chomp().among("y", "Y")) return spinoffSubdirectory(FOLDER_NAME, BRANCH_NAME, REPO_NAME);
  return 0;
}
