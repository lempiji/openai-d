import std.stdio;
import openai;

void main()
{
    auto client = new OpenAIClient();
    auto req = fileUploadRequest("input.jsonl", FilePurpose.FineTune);
    client.uploadFile(req);
    auto list = client.listFiles(listFilesRequest());
    writeln(list.data.length);
}
