import std.stdio;
import std.file;
import std.path;
import std.process;
import std.datetime;
import std.string : replace;

void main(string[] args)
{
    if (args.length != 2)
    {
        stderr.writeln("Usage: rdmd scripts/archive_reflection.d <reflection-file>");
        return;
    }

    auto scriptDir = dirName(__FILE__).absolutePath;
    auto rootDir = buildPath(scriptDir, "..");

    string refPath = args[1];
    if (!isAbsolute(refPath))
        refPath = buildPath(rootDir, refPath);
    refPath = buildNormalizedPath(refPath);
    if (!exists(refPath))
    {
        stderr.writeln("Reflection not found: " ~ refPath);
        return;
    }

    auto archiveDir = buildPath(rootDir, ".codex", "archive");
    enforce(exists(archiveDir), "Archive directory missing: " ~ archiveDir);
    string dest = buildPath(archiveDir, baseName(refPath));

    auto mvPid = spawnProcess(["git", "mv", refPath, dest], rootDir);
    auto status = wait(mvPid);
    if (status != 0)
        throw new Exception("git mv failed");

    auto now = Clock.currTime();
    auto ts = now.toISOExtString()[0 .. 16].replace("T", " ");
    auto entry = format("- [%s] Archived %s\n", ts, baseName(refPath));

    string historyPath = buildPath(archiveDir, "REFLECTION_HISTORY.md");
    string existing = exists(historyPath) ? readText(historyPath) : "";
    bool addNl = existing.length > 0 && !existing.endsWith("\n");

    auto file = File(historyPath, "a");
    if (addNl)
        file.writeln();
    file.write(entry);
    file.close();
}

