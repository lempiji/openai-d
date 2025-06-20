import std.stdio;
import std.file;
import std.path;
import std.array;
import std.algorithm : sort, canFind, filter, map;
import std.string;
import std.process;
import core.stdc.stdlib : exit;

void main(string[] args)
{
    auto scriptDir = dirName(__FILE__).absolutePath;
    auto examplesDir = buildPath(scriptDir, "..", "examples");

    string mode = "all";
    string[] groups;

    if (args.length > 1)
    {
        auto first = args[1];
        if (first == "all" || first == "core")
        {
            mode = first;
            groups = args[2 .. $];
        }
        else
        {
            groups = args[1 .. $];
        }
    }

    string[] allDirs = dirEntries(examplesDir, SpanMode.shallow)
        .filter!(d => d.isDir)
        .map!(d => baseName(d.name))
        .array;
    sort(allDirs);

    string[] targets;
    foreach (dir; allDirs)
    {
        bool include = true;
        if (groups.length > 0)
        {
            include = false;
            foreach (g; groups)
            {
                if (dir == g || dir.startsWith(g ~ "_"))
                {
                    include = true;
                    break;
                }
            }
        }

        if (include)
        {
            if (mode == "core")
            {
                if (!dir.canFind('_'))
                    targets ~= dir;
            }
            else
            {
                targets ~= dir;
            }
        }
    }

    if (targets.length == 0)
    {
        stderr.writeln("No example targets matched.");
        return;
    }

    foreach (dir; targets)
    {
        stderr.writeln("\n## Building " ~ dir);
        auto workDir = buildPath(examplesDir, dir);
        auto pid = spawnProcess(["dub", "build"], null, Config.none, workDir);
        auto status = wait(pid);
        if (status != 0)
        {
            writeln("dub build failed for " ~ dir);
            exit(status);
        }
    }
}
