package;

import haxe.macro.Context;
import haxe.macro.Expr;

import haxe.io.Path;

import sys.FileSystem.createDirectory;
import sys.FileSystem.readDirectory;
import sys.FileSystem.exists;
import sys.FileSystem.deleteFile;

import sys.io.File.getContent;
import sys.io.File.saveContent;

using haxe.macro.Tools;

class BuildMacros {
  public static macro function moveStaticFiles() {
    trace("Copying static files in html/ to dist/...");

    var sourceParent = "src/";
    var sourceDirectory = "html/";
    var destinationDirectory = "dist/";

    createDirectory(Path.join([destinationDirectory, sourceDirectory]));
    
    for (file in readDirectory(Path.join([sourceParent, sourceDirectory]))) {
      var sourcePath = Path.join([sourceParent + sourceDirectory, file]);
      var destinationPath = Path.join([destinationDirectory + sourceDirectory, file]);
      
      if (exists(destinationPath)) deleteFile(destinationPath);
      saveContent(destinationPath, getContent(sourcePath));
    }
    
    trace("Done.");

    return macro null;
  }
}

