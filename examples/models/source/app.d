module app;

import std.stdio;
import std.algorithm;
import std.array;

import openai;

void main()
{
	// If the argument Config is omitted, it is read from an environment variable 'OPENAI_API_KEY'
	// auto config = OpenAIClientConfig.fromFile("config.json");
	// auto client = new OpenAIClient(config);
	auto client = new OpenAIClient;

	auto models = client.listModels();
	auto modelIds = models.data
		.map!"a.id"
		.filter!(a => a.canFind("ada"))
		.array();
	sort(modelIds);
	modelIds.each!writeln();
}
