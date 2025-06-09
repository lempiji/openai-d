import std.stdio;

import openai;

void main(string[] args)
{
    string file = args.length > 1 ? args[1] : "audio.mp3";
    auto client = new OpenAIClient;

    auto request = transcriptionRequest(file, "whisper-1");
    auto response = client.transcription(request);
    writeln(response.text);
}
