package;

import haxe.macro.Context;
import haxe.macro.Expr;

import massive.sys.io.File.*;

class BuildMacros {
  public static var sourceRootDirectory = "src/";
  public static var assetsDirectory = "assets/";
  public static var pagesDirectory = "pages/";
  public static var destinationDirectory = "dist/";
  
  public static macro function moveAssets() {
    var sourceDirectory = Path.of('${BuildMacros.sourceRootDirectory}${BuildMacros.assetsDirectory}');
    var destinationDirectory = Path.of('${BuildMacros.destinationDirectory}${BuildMacros.assetsDirectory}');

    trace('Copying assets in ${sourceDirectory.parent} to ${destinationDirectory.parent}...');

    if (destinationDirectory.exists()) destinationDirectory.toDir().delete(true);
    sourceDirectory.toDir().copyTo(destinationDirectory);
    
    trace("Done.");

    return macro null;
  }

  public static macro function movePages() {
    // var sourceRootDirectory = BuildMacros.sourceRootDirectory;
    // var pagesDirectory = BuildMacros.pagesDirectory;
    // var destinationDirectory = BuildMacros.destinationDirectory;
    // for (directory in readDirectory(Path.join([sourceRootDirectory, pagesDirectory]))) {
    //   trace('Copying $directory/ to $destinationDirectory...');
    // }
    // trace("Done.");
    return macro null;
  }
}

