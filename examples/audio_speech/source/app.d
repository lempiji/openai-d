import std.stdio;
import std.file : write;

import openai;

void main()
{
    string text = "Hello world";
    auto client = new OpenAIClient;

    auto request = SpeechRequest(openai.GPT4OMiniTTS, text, VoiceAlloy);
    auto data = client.speech(request);
    write("speech.mp3", data);
    writeln("saved speech.mp3: ", data.length, " bytes");
}
