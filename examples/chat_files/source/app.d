import std.stdio;
import openai;

void main()
{
    auto client = new OpenAIClient();

    auto uploaded = client.uploadFile(uploadFileRequest("draconomicon.pdf", FilePurpose.UserData));

    auto request = chatCompletionRequest(
        openai.GPT4OMini, [
        userChatMessageWithFile("What is the first dragon in the book?", uploaded.id)
    ],
        128, 0);

    auto response = client.chatCompletion(request);
    writeln(response.choices[0].message.content);
}
