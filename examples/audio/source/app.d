import std.stdio;

import openai;

void main()
{
    auto client = new OpenAIClient;

    auto speech = SpeechRequest(openai.GPT4OMiniTTS, "Hello world", VoiceAlloy);
    auto data = client.speech(speech);
    writeln("speech bytes: ", data.length);

    const json = `{"text":"Hello from audio"}`;
    import mir.deser.json : deserializeJson;

    auto resp = deserializeJson!AudioTextResponse(json);
    writeln("text: ", resp.text);
}
