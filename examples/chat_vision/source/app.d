import std.stdio;
import std.file : read;
import std.base64;
import std.conv : to;

import openai;

void main()
{
    // If the argument Config is omitted, it is read from an environment variable 'OPENAI_API_KEY'
    // auto config = OpenAIClientConfig.fromFile("config.json");
    // auto client = new OpenAIClient(config);
    auto client = new OpenAIClient;

    // Load local image and convert to data URL
    auto bytes = cast(ubyte[]) read("assets/cat.png");
    string dataUri = to!string("data:image/png;base64," ~ Base64.encode(bytes));

    auto request = chatCompletionRequest(openai.GPT4OMini /* gpt-4o */ , [
        userChatMessageWithImages("この画像の内容を詳しく説明してください。", [
            dataUri
        ])
    ], 1024, 0);

    auto response = client.chatCompletion(request);
    assert(response.choices.length > 0);

    writeln(response.choices[0].message.content);
}
