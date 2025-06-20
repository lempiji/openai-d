import std.stdio;

import openai;

/// Demonstrate the Administration Usage API.
void main()
{
    auto client = new OpenAIAdminClient();

    auto req = listUsageRequest(0);
    req.limit = 3;

    auto completions = client.listUsageCompletions(req);
    writeln(completions.data.length);
}
