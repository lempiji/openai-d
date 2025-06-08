import std.stdio;

import openai.audio;

void main()
{
    auto speech = SpeechRequest("gpt-4o-mini-tts", "Hello world", VoiceAlloy);
    import mir.ser.json : serializeJson;

    writeln("speech json: ", serializeJson(speech));

    const json = `{"text":"Hello from audio"}`;
    import mir.deser.json : deserializeJson;

    auto resp = deserializeJson!AudioTextResponse(json);
    writeln("text: ", resp.text);
}
