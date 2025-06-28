import std.stdio;
import openai;

void main()
{
    auto client = new OpenAIClient();

    auto upload1 = client.uploadFile(uploadFileRequest("data/file1.txt", FilePurpose.UserData));
    scope (exit)
        client.deleteFile(upload1.id);

    auto upload2 = client.uploadFile(uploadFileRequest("data/file2.txt", FilePurpose.UserData));
    scope (exit)
        client.deleteFile(upload2.id);

    auto request = chatCompletionRequest(
        openai.GPT4OMini,
        [
        userChatMessageWithFiles(
            "Summarize the contents of both files.",
            [upload1.id, upload2.id])
    ],
        128,
        0);

    auto response = client.chatCompletion(request);
    writeln(response.choices[0].message.content);
}
