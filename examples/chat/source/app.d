import std.stdio;

import openai;

void main()
{
    auto client = new OpenAIClient;

    const request = chatCompletionRequest(openai.GPT4OMini, [
        systemChatMessage("You are a helpful assistant."),
        userChatMessage("Hello!")
    ], 16, 0);

    auto response = client.chatCompletion(request);
    assert(response.choices.length > 0);
    writefln!"role: %s\ncontent: %s"(response.choices[0].message.tupleof[0 .. 2]);
}
