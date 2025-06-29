import std.stdio;
import std.file : read;
import std.base64;
import std.conv : to;

import openai;

void main()
{
    auto client = new OpenAIClient();

    ChatUserMessageContentItem[] contents;
    contents ~= messageContentItem("この画像の内容を詳しく説明してください。");
    contents ~= messageContentItemFromImageFile("assets/cat.png");

    auto request = chatCompletionRequest(openai.GPT4OMini /* gpt-4o */ , [
        userChatMessage(contents)
    ], 1024, 0);

    auto response = client.chatCompletion(request);
    assert(response.choices.length > 0);

    writeln(response.choices[0].message.content);
}
