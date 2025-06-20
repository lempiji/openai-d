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
    bool clean = false;
    string[] params;

    foreach (arg; args[1 .. $])
    {
        if (arg == "--clean")
            clean = true;
        else
            params ~= arg;
    }

    if (params.length > 0)
    {
        auto first = params[0];
        if (first == "all" || first == "core")
        {
            mode = first;
            groups = params[1 .. $];
        }
        else
        {
            groups = params;
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

        if (clean)
        {
            auto cleanPid = spawnProcess(["dub", "clean"], null, Config.none, workDir);
            wait(cleanPid);

            string bin = buildPath(workDir, dir);
            if (exists(bin))
                remove(bin);
            string binExe = bin ~ ".exe";
            if (exists(binExe))
                remove(binExe);

            string selections = buildPath(workDir, "dub.selections.json");
            if (exists(selections))
                remove(selections);
        }
    }
}
