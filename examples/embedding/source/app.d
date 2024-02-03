import std.stdio;

import openai;

void main()
{
	// If the argument Config is omitted, it is read from an environment variable 'OPENAI_API_KEY'
	// auto config = OpenAIClientConfig.fromFile("config.json");
	// auto client = new OpenAIClient(config);
	auto client = new OpenAIClient;

	auto request = embeddingRequest(openai.AdaEmbeddingV2, "Hello, world!");
	auto response = client.embedding(request);
	float[] embedding = response.data[0].embedding;
	writeln(embedding.length); // text-embedding-ada-002 -> 1536

	auto request2 = embeddingRequest(openai.TextEmbedding3Large, "D is a general-purpose programming language with static typing, systems-level access, and C-like syntax. With the D Programming Language, write fast, read fast, and run fast.", 512);
	auto response2 = client.embedding(request2);
	float[] embedding2 = response2.data[0].embedding;
	writeln(embedding2.length); // 512

	auto request3 = embeddingRequest(openai.TextEmbedding3Small, "D is a general-purpose programming language with static typing, systems-level access, and C-like syntax. With the D Programming Language, write fast, read fast, and run fast.", 512);
	auto response3 = client.embedding(request3);
	float[] embedding3 = response3.data[0].embedding;
	writeln(embedding3.length); // 512

	import std.numeric : cosineSimilarity;
	const similarity = cosineSimilarity(embedding2, embedding3);
	writeln(similarity);
}
