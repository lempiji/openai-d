import std.stdio;
import std.string;

import openai;

void main()
{
    // If the argument Config is omitted, it is read from an environment variable 'OPENAI_API_KEY'
    // auto config = OpenAIClientConfig.fromFile("config.json");
    // auto client = new OpenAIClient(config);
    auto client = new OpenAIClient;

    // POST /completions
    auto message = completionRequest(openai.GPT3Dot5TurboInstruct, "This is a", 16, 0);
    message.stop = [".", "\n"];

    auto response = client.completion(message);
    assert(response.choices.length > 0);

    writeln(response.choices[0].text.chomp());
}
