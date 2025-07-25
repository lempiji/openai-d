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

/// Response format `json` used by transcription and translation endpoints.
enum AudioResponseFormatJson = "json";
/// Response format `text`.
enum AudioResponseFormatText = "text";
/// Response format `srt` for subtitle output.
enum AudioResponseFormatSrt = "srt";
/// Response format `verbose_json` with word-level timestamps.
enum AudioResponseFormatVerboseJson = "verbose_json";
/// Response format `vtt` for WebVTT subtitles.
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

/// Text-to-speech voice `alloy`.
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

/// Include token log probabilities in the response.
enum TranscriptionIncludeLogprobs = "logprobs";

/// Timestamp granularity `word`.
enum TranscriptionTimestampGranularityWord = "word";
/// Timestamp granularity `segment`.
enum TranscriptionTimestampGranularitySegment = "segment";

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

/**
 * Convenience constructor for creating a `SpeechRequest` used with the
 * `/audio/speech` endpoint.
 *
 * Params:
 *     model = ID of the text-to-speech model.
 *     input = Text to synthesize.
 *     voice = Voice identifier. The request defaults to MP3 format at speed 1.0.
 *
 * Returns: Request object suitable for `OpenAIClient.speech`.
 */
SpeechRequest speechRequest(string model, string input, string voice)
{
    auto request = SpeechRequest();
    request.model = model;
    request.input = input;
    request.voice = voice;
    return request;
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

    /// Extra items to include in the response.
    @serdeIgnoreDefault
    @serdeKeys("include")
    string[] include;

    /// Timestamp granularities to return.
    @serdeIgnoreDefault
    @serdeKeys("timestamp_granularities")
    string[] timestampGranularities = [TranscriptionTimestampGranularitySegment];

    /// Stream the response using SSE.
    @serdeIgnoreDefault
    bool stream = false;
}

/**
 * Convenience constructor for `TranscriptionRequest` objects sent to the
 * `/audio/transcriptions` endpoint.
 *
 * Params:
 *     file  = Path to the audio file to transcribe.
 *     model = Whisper model identifier.
 *
 * Default values such as JSON response format and temperature are taken from
 * `TranscriptionRequest`.
 *
 * Returns: Request object usable with `OpenAIClient.transcription`.
 */
TranscriptionRequest transcriptionRequest(string file, string model)
{
    auto request = TranscriptionRequest();
    request.file = file;
    request.model = model;
    return request;
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

/**
 * Convenience constructor for `TranslationRequest` objects used with the
 * `/audio/translations` endpoint.
 *
 * Params:
 *     file  = Path to the audio file to translate.
 *     model = Whisper model identifier.
 *
 * Returns: Request object suitable for `OpenAIClient.translation`.
 */
TranslationRequest translationRequest(string file, string model)
{
    auto request = TranslationRequest();
    request.file = file;
    request.model = model;
    return request;
}

// -----------------------------------------------------------------------------
// Responses
// -----------------------------------------------------------------------------

/// Basic transcription or translation response.
struct AudioTextResponse
{
    /// The generated text.
    string text;
    /// Optional token log probabilities.
    @serdeOptional
    TranscriptionLogProb[] logprobs;
}

/// Details about token log probabilities.
struct TranscriptionLogProb
{
    /// Transcribed token.
    string token;
    /// Log probability of the token.
    double logprob;
    /// UTF-8 bytes of the token.
    uint[] bytes;
}

/// Detailed word timestamps.
struct TranscriptionWord
{
    string word;
    double start;
    double end;
}

/// Detailed segment information.
struct TranscriptionSegment
{
    int id;
    int seek;
    double start;
    double end;
    string text;
    int[] tokens;
    double temperature;
    @serdeKeys("avg_logprob")
    double avgLogprob;
    @serdeKeys("compression_ratio")
    double compressionRatio;
    @serdeKeys("no_speech_prob")
    double noSpeechProb;
}

/// Verbose transcription response.
struct TranscriptionVerboseResponse
{
    string language;
    double duration;
    string text;
    TranscriptionWord[] words;
    TranscriptionSegment[] segments;
}

// -----------------------------------------------------------------------------
// Unit tests
// -----------------------------------------------------------------------------

unittest
{
    auto req = speechRequest("gpt-4o-mini-tts", "Hello", VoiceAlloy);
    import mir.ser.json : serializeJson;

    assert(serializeJson(req) ==
            `{"model":"gpt-4o-mini-tts","input":"Hello","voice":"alloy"}`);
}

unittest
{
    auto req = transcriptionRequest("audio.mp3", "whisper-1");
    import mir.ser.json : serializeJson;

    assert(serializeJson(req) ==
            `{"file":"audio.mp3","model":"whisper-1"}`);
}

unittest
{
    auto req = translationRequest("audio.mp3", "whisper-1");
    import mir.ser.json : serializeJson;

    assert(serializeJson(req) ==
            `{"file":"audio.mp3","model":"whisper-1"}`);
}

unittest
{
    auto req = TranscriptionRequest("audio.mp3", "whisper-1");
    req.include = [TranscriptionIncludeLogprobs];
    req.timestampGranularities = [
        TranscriptionTimestampGranularityWord,
        TranscriptionTimestampGranularitySegment
    ];
    import mir.ser.json : serializeJson;

    assert(serializeJson(req) ==
            `{"file":"audio.mp3","model":"whisper-1","include":["logprobs"],"timestamp_granularities":["word","segment"]}`);
}

unittest
{
    import mir.deser.json : deserializeJson;

    const json = `{"text":"hello"}`;
    auto res = deserializeJson!AudioTextResponse(json);
    assert(res.text == "hello");
}

unittest
{
    import mir.deser.json : deserializeJson;

    const json = `{"language":"english","duration":1.2,"text":"hello","words":[{"word":"hello","start":0.0,"end":0.5}],"segments":[{"id":0,"seek":0,"start":0.0,"end":0.5,"text":"hello","tokens":[1],"temperature":0.0,"avg_logprob":-0.1,"compression_ratio":1.0,"no_speech_prob":0.0}]}`;
    auto res = deserializeJson!TranscriptionVerboseResponse(json);
    assert(res.text == "hello");
    assert(res.words.length == 1);
    assert(res.segments.length == 1);
}
