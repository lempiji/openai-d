import std.stdio;
import std.file : write;

import openai;

void main()
{
    string text = "Hello! こんにちは。お元気ですか？";
    auto client = new OpenAIClient;

    auto request = speechRequest(openai.GPT4OMiniTTS, text, VoiceAlloy);
    auto data = client.speech(request);
    write("speech.mp3", data);
    writeln("saved speech.mp3: ", data.length, " bytes");
}
