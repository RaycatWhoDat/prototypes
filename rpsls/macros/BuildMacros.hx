package;

class BuildMacros {
    public static macro function copyPages() {
        trace("Copying src/pages/* to dist/*...");
        Sys.command("cp", ["-r", "src/pages", "dist"]);
        trace("Done.");
        return macro null;
    }
}
