/**
OpenAI API Audio

Standards: https://platform.openai.com/docs/api-reference/audio
*/
module openai.audio;

import mir.serde;

@safe:

// -----------------------------------------------------------------------------
// Enumerations
// -----------------------------------------------------------------------------

/// Response format `json`.
enum AudioResponseFormatJson = "json";
/// Response format `text`.
enum AudioResponseFormatText = "text";
/// Response format `srt`.
enum AudioResponseFormatSrt = "srt";
/// Response format `verbose_json`.
enum AudioResponseFormatVerboseJson = "verbose_json";
/// Response format `vtt`.
enum AudioResponseFormatVtt = "vtt";

/// Speech format `mp3`.
enum SpeechFormatMp3 = "mp3";
/// Speech format `opus`.
enum SpeechFormatOpus = "opus";
/// Speech format `aac`.
enum SpeechFormatAac = "aac";
/// Speech format `flac`.
enum SpeechFormatFlac = "flac";
/// Speech format `wav`.
enum SpeechFormatWav = "wav";
/// Speech format `pcm`.
enum SpeechFormatPcm = "pcm";

/// Voice `alloy`.
enum VoiceAlloy = "alloy";
/// Voice `ash`.
enum VoiceAsh = "ash";
/// Voice `ballad`.
enum VoiceBallad = "ballad";
/// Voice `coral`.
enum VoiceCoral = "coral";
/// Voice `echo`.
enum VoiceEcho = "echo";
/// Voice `fable`.
enum VoiceFable = "fable";
/// Voice `onyx`.
enum VoiceOnyx = "onyx";
/// Voice `nova`.
enum VoiceNova = "nova";
/// Voice `sage`.
enum VoiceSage = "sage";
/// Voice `shimmer`.
enum VoiceShimmer = "shimmer";
/// Voice `verse`.
enum VoiceVerse = "verse";

// -----------------------------------------------------------------------------
// Requests
// -----------------------------------------------------------------------------

/// Request for text-to-speech generation.
struct SpeechRequest
{
    /// Model to use.
    string model;

    /// Text input.
    string input;

    /// Voice id.
    string voice;

    /// Additional instructions.
    @serdeIgnoreDefault
    string instructions;

    /// Response format.
    @serdeIgnoreDefault
    @serdeKeys("response_format")
    string responseFormat = SpeechFormatMp3;

    /// Playback speed.
    @serdeIgnoreDefault
    double speed = 1;
}

/// Request for audio transcription.
struct TranscriptionRequest
{
    /// Path to the audio file.
    string file;

    /// Model to use.
    string model;

    /// Language of the input audio.
    @serdeIgnoreDefault
    string language;

    /// Optional prompt.
    @serdeIgnoreDefault
    string prompt;

    /// Response format.
    @serdeIgnoreDefault
    @serdeKeys("response_format")
    string responseFormat = AudioResponseFormatJson;

    /// Sampling temperature.
    @serdeIgnoreDefault
    double temperature = 0;
}

/// Request for audio translation.
struct TranslationRequest
{
    /// Path to the audio file.
    string file;

    /// Model to use.
    string model;

    /// Optional prompt.
    @serdeIgnoreDefault
    string prompt;

    /// Response format.
    @serdeIgnoreDefault
    @serdeKeys("response_format")
    string responseFormat = AudioResponseFormatJson;

    /// Sampling temperature.
    @serdeIgnoreDefault
    double temperature = 0;
}

// -----------------------------------------------------------------------------
// Responses
// -----------------------------------------------------------------------------

/// Basic transcription or translation response.
struct AudioTextResponse
{
    /// The generated text.
    string text;
}

// -----------------------------------------------------------------------------
// Unit tests
// -----------------------------------------------------------------------------

unittest
{
    auto req = SpeechRequest("gpt-4o-mini-tts", "Hello", VoiceAlloy);
    import mir.ser.json : serializeJson;

    assert(serializeJson(req) ==
            `{"model":"gpt-4o-mini-tts","input":"Hello","voice":"alloy"}`);
}

unittest
{
    auto req = TranscriptionRequest("audio.mp3", "whisper-1");
    import mir.ser.json : serializeJson;

    assert(serializeJson(req) ==
            `{"file":"audio.mp3","model":"whisper-1"}`);
}

unittest
{
    import mir.deser.json : deserializeJson;

    const json = `{"text":"hello"}`;
    auto res = deserializeJson!AudioTextResponse(json);
    assert(res.text == "hello");
}
