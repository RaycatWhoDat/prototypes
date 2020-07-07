#!/usr/bin/env nim
import strutils

mode = ScriptMode.Silent

proc spinoffSubdirectory(folder, branch, repo: string) =
  const ORIGINAL_REPO_NAME = "git@github.com:RayMPerry/prototypes.git"
  echo "Spinning off subdirectory."

  let commandsToRun = @[
    "filter-branch -f --prune-empty --subdirectory-filter " & folder & " " & branch,
    "remote set-url origin " & repo,
    "push -u origin master",
    "remote set-url origin " & ORIGINAL_REPO_NAME,
    "fetch --all",
    "reset --hard origin/master"
  ]
    
  for command in commandsToRun:
    var (output, exitCode) = gorgeEx("git " & command)
    if exitCode != 0:
      echo output
      break

var
  folder = ""
  branch = ""
  repo = ""

for paramIndex in 0..paramCount():
  var param = paramStr(paramIndex).split(":")
  if param.len > 1:
    case param[0]
    of "--folder", "-f":
      folder = param[1]
    of "--branch", "-b":
      branch = param[1]
    of "--repo", "-r":
      repo = param[1]

if folder.isEmptyOrWhitespace:
  echo "Please specify a folder to spin-off."
elif branch.isEmptyOrWhitespace:
  echo "Please specify a branch to spin-off."
elif repo.isEmptyOrWhitespace:
  echo "Please specify a repo to spin-off."
else:
  var answer = ""
  while answer != "n" or answer != "N":
    echo "Would you like to spinoff " & folder & " from " & branch & " into " & repo & "? [y/N] "
    answer = readLineFromStdin()
    case answer
    of "n", "N":
      echo "Exiting."
      break
    of "y", "Y":
      spinoffSubdirectory(folder, branch, repo)
      break
    else:
      continue
