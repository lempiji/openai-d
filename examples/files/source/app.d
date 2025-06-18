import std.stdio;
import std.file : write;

import openai;

void main()
{
    auto client = new OpenAIClient();
    auto req = fileUploadRequest("input.jsonl", FilePurpose.FineTune);
    auto uploaded = client.uploadFile(req);

    auto list = client.listFiles(listFilesRequest());
    writeln("files: ", list.data.length);

    auto file = client.retrieveFile(uploaded.id);
    writeln("retrieved: ", file.filename);

    auto content = client.downloadFileContent(uploaded.id);
    write("file-content.jsonl", content);
    writeln("downloaded: ", content.length, " bytes");

    auto res = client.deleteFile(uploaded.id);
    writeln("deleted: ", res.deleted);
}
