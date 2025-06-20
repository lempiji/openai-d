import std.stdio;
import std.file;
import std.algorithm : sort;
import std.path;
import std.string;
import std.array;

void main()
{
    auto scriptDir = dirName(__FILE__).absolutePath;
    auto rootDir = buildPath(scriptDir, "..");
    auto reflectionsDir = buildPath(rootDir, ".codex", "reflections");

    auto files = dirEntries(reflectionsDir, "*.md", SpanMode.shallow)
        .map!(a => a.name)
        .array;
    sort(files);

    foreach (fileName; files)
    {
        auto lines = readText(fileName).splitLines();
        bool collect = false;
        string[] improvements;
        foreach (line; lines)
        {
            auto trimmed = line.strip;
            if (!collect && trimmed == "#### :bulb: Proposed Improvement")
            {
                collect = true;
                continue;
            }
            else if (collect)
            {
                if (trimmed.length == 0 || trimmed.startsWith("#"))
                    break;
                improvements ~= line.strip;
            }
        }

        if (improvements.length)
        {
            writeln(baseName(fileName));
            foreach (imp; improvements)
                writeln(imp);
            writeln();
        }
    }
}
