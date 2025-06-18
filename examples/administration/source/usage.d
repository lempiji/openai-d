import std.stdio;

import openai;

/// Simple helper demonstrating the Usage API.
void runUsageExample()
{
    auto client = new OpenAIClient();

    auto req = listUsageRequest(0);
    req.limit = 3;

    auto usage = client.listUsageCompletions(req);
    writeln(usage.data.length);
}
