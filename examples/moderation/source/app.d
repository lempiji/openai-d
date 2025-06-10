module app;

import std.stdio;
import std.string;
import openai;

void main()
{
    auto client = new OpenAIClient;

    // POST /moderations
    // Example input: https://platform.openai.com/docs/api-reference/moderations/create
    const request = moderationRequest("I want to kill them.");
    auto response = client.moderation(request);

    writeln(response.results.length);
    writeln(response.results[0]);

    if (response.results[0].flagged)
        writeln("Warning!");
    else
        writeln("Probably safe.");
}
