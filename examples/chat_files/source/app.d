import std.stdio;
import openai;

void main()
{
    auto client = new OpenAIClient();

    ChatUserMessageContentItem[] contents;
    contents ~= messageContentItem("Summarize the contents of the file in a single sentence.");
    contents ~= messageContentItemFromFile("input.pdf");

    auto request = chatCompletionRequest("gpt-4o", [userChatMessage(contents)], 200, 1.0);

    auto response = client.chatCompletion(request);
    writeln(response.choices[0].message.content);
}
