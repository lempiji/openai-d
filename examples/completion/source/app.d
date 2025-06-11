import std.stdio;
import std.string;

import openai;

void main()
{
    auto client = new OpenAIClient();

    // POST /completions
    auto message = completionRequest(openai.GPT3Dot5TurboInstruct, "This is a", 16, 0);
    message.stop = [".", "\n"];

    auto response = client.completion(message);
    assert(response.choices.length > 0);

    writeln(response.choices[0].text.chomp());
}
