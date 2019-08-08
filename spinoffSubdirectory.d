#!/usr/bin/env rdmd

import std.stdio;
import std.getopt;
import std.algorithm;
import std.string;
import std.utf;
import std.process;
import std.format;

int main(string[] args) {
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
    
    auto filterBranch = execute(["git", "filter-branch", "--prune-empty", "--subdirectory-filter", folderName, branchName]);
    if (filterBranch.status != 0) {
      writefln("There was a problem filtering the branch. Stopping.");
      return 2;
    }

    auto setRemote = execute(["git", "remote", "set-url", "origin", repoName]);
    if (setRemote.status != 0) {
      writefln("There was a problem setting the new remote. Stopping.");
      return 3;
    }

    auto pushToOrigin = execute(["git", "push", "-u", "origin", "master"]);
    if (pushToOrigin.status != 0) {
      writefln("There was a problem pushing to origin. Stopping.");
      return 4;
    }

    return 0;
  }
    
  if (readln().chomp().among("y", "Y")) {
    spinoffSubdirectory(FOLDER_NAME, BRANCH_NAME, REPO_NAME);
  }

  return 0;
}
