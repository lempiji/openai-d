module app;

import std.stdio;
import std.string;
import openai;

void main()
{
	// If the argument Config is omitted, it is read from an environment variable 'OPENAI_API_KEY'
	auto config = OpenAIClientConfig.fromFile("config.json");
	auto client = new OpenAIClient(config);
	// auto client = new OpenAIClient;

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
