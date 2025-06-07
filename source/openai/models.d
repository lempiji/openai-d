/**
OpenAI API Models

Standards: https://platform.openai.com/docs/api-reference/models

Remarks:
- For deprecations, refer to: https://platform.openai.com/docs/deprecations
- For model details, refer to: https://platform.openai.com/docs/models/
- If the model is labeled '(Legacy)' or if it's listed under "upgrade"
- Remove the declaration 3 months after the shutdown date
*/
module openai.models;

import mir.serde;

@safe:

// Chat & Completion
// GPT-4o Series
/// gpt-4o
enum GPT4O = "gpt-4o";
/// gpt-4o-2024-05-13
enum GPT4O20240513 = "gpt-4o-2024-05-13";
/// gpt-4o-2024-08-06
enum GPT4O20240806 = "gpt-4o-2024-08-06";
/// gpt-4o-2024-11-20
enum GPT4O20241120 = "gpt-4o-2024-11-20";
/// chatgpt-4o-latest
enum ChatGPT4OLatest = "chatgpt-4o-latest";

// GPT-4o mini Series
/// gpt-4o-mini
enum GPT4OMini = "gpt-4o-mini";
/// gpt-4o-mini-2024-07-18
enum GPT4OMini20240718 = "gpt-4o-mini-2024-07-18";
/// gpt-4o-mini-tts
enum GPT4OMiniTTS = "gpt-4o-mini-tts";
/// gpt-4o-realtime-preview
enum GPT4ORealtimePreview = "gpt-4o-realtime-preview";
/// gpt-4o-audio-preview
enum GPT4OAudioPreview = "gpt-4o-audio-preview";
/// gpt-4o-search-preview
enum GPT4OSearchPreview = "gpt-4o-search-preview";

// o1 and o1-mini Series
/// o1
enum O1 = "o1";
/// o1-2024-12-17
enum O120241217 = "o1-2024-12-17";
/// o1-mini
enum O1Mini = "o1-mini";
/// o1-mini-2024-09-12
enum O1Mini20240912 = "o1-mini-2024-09-12";
/// o1-preview
enum O1Preview = "o1-preview";
/// o1-preview-2024-09-12
enum O1Preview20240912 = "o1-preview-2024-09-12";

// o4-mini Series
/// o4-mini
enum O4Mini = "o4-mini";
/// o4-mini-2025-04-16
enum O4Mini20250416 = "o4-mini-2025-04-16";

// o3 and o3-mini Series
/// o3
enum O3 = "o3";
/// o3-2025-04-16
enum O320250416 = "o3-2025-04-16";
/// o3-mini
enum O3Mini = "o3-mini";
/// o3-mini-2025-01-31
enum O3Mini20250131 = "o3-mini-2025-01-31";

// GPT-4 Turbo Series
/// gpt-4-turbo
enum GPT4Turbo = "gpt-4-turbo";
/// gpt-4-turbo-2024-04-09
enum GPT4Turbo20240409 = "gpt-4-turbo-2024-04-09";
/// gpt-4-turbo-preview
enum GPT4TurboPreview = "gpt-4-turbo-preview";

// GPT-4 Vision Series
/// gpt-4-vision-preview
deprecated("'gpt-4-vision-preview' is to be removed by 2024-12-06. Please use 'gpt-4o' instead")
enum GPT4VisionPreview = "gpt-4-vision-preview";

// GPT-4-32k Series
/// gpt-4-32k
deprecated("'gpt-4-32k' is to be removed by 2025-06-06. Please use 'gpt-4o' instead")
enum GPT432K = "gpt-4-32k";
/// gpt-4-32k-0314
deprecated("'gpt-4-32k-0314' is to be removed by 2025-06-06. Please use 'gpt-4o' instead")
enum GPT432K0314 = "gpt-4-32k-0314";
/// gpt-4-32k-0613
deprecated("'gpt-4-32k-0613' is to be removed by 2025-06-06. Please use 'gpt-4o' instead")
enum GPT432K0613 = "gpt-4-32k-0613";

// GPT-4 Series
/// gpt-4
enum GPT4 = "gpt-4";
/// gpt-4-0314
deprecated("'gpt-4-0314' is to be removed by 2024-06-13. Please use 'gpt-4o' instead")
enum GPT40314 = "gpt-4-0314";
/// gpt-4-0613
enum GPT40613 = "gpt-4-0613";
/// gpt-4-0125-preview
enum GPT40125Preview = "gpt-4-0125-preview";
/// gpt-4-1106-preview
enum GPT41106Preview = "gpt-4-1106-preview";

// GPT-4.1 Series
/// gpt-4.1
enum GPT4Dot1 = "gpt-4.1";
/// gpt-4.1-mini
enum GPT4Dot1Mini = "gpt-4.1-mini";
/// gpt-4.1-nano
enum GPT4Dot1Nano = "gpt-4.1-nano";

// GPT-3.5 Turbo Series
/// gpt-3.5-turbo
enum GPT3Dot5Turbo = "gpt-3.5-turbo";
/// gpt-3.5-turbo-instruct
enum GPT3Dot5TurboInstruct = "gpt-3.5-turbo-instruct";
/// gpt-3.5-turbo-0125
enum GPT350Turbo0125 = "gpt-3.5-turbo-0125";
/// gpt-3.5-turbo-1106
enum GPT350Turbo1106 = "gpt-3.5-turbo-1106";
/// gpt-3.5-turbo-0301
deprecated("'gpt-3-turbo-0301' is to be removed by 2024-06-13. Please use 'gpt-3-turbo' instead")
enum GPT3Dot5Turbo0301 = "gpt-3.5-turbo-0301";
/// gpt-3.5-turbo-0613
deprecated("'gpt-3.5-turbo-0613' is to be removed by 2024-09-13. Please use 'gpt-3.5-turbo' instead")
enum GPT3Dot5Turbo0613 = "gpt-3.5-turbo-0613";

// GPT-3.5 Turbo 16k Series
/// gpt-3.5-turbo-16k
enum GPT3Dot5Turbo16K = "gpt-3.5-turbo-16k";
/// gpt-3.5-turbo-16k-0613
deprecated("'gpt-3.5-turbo-16k-0613' is to be removed by 2024-09-13. Please use 'gpt-3.5-turbo' instead")
enum GPT3Dot5Turbo16K0613 = "gpt-3.5-turbo-16k-0613";

/// davinci-instruct-beta
enum DavinciInstructBeta = "davinci-instruct-beta";
/// curie-instruct-beta
enum CurieInstructBeta = "curie-instruct-beta";

// Embedding
/// text-embedding-3-large
enum TextEmbedding3Large = "text-embedding-3-large";
/// text-embedding-3-small
enum TextEmbedding3Small = "text-embedding-3-small";
/// text-embedding-ada-002
enum AdaEmbeddingV2 = "text-embedding-ada-002";

// Moderation
/// text-moderation-stable
enum ModerationTextStable = "text-moderation-stable";
/// text-moderation-latest
enum ModerationTextLatest = "text-moderation-latest";
/// text-moderation-007
enum ModerationText007 = "text-moderation-007";

// GPT base
/// babbage-002
enum Babbage002 = "babbage-002";
/// davinci-002
enum Davinci002 = "davinci-002";

/// Describes an OpenAI model offering that can be used with the API.
@serdeIgnoreUnexpectedKeys
struct Model
{
    /// The model identifier, which can be referenced in the API endpoints.
    string id;

    /// The Unix timestamp (in seconds) when the model was created.
    ulong created;

    /// The object type, which is always "model".
    string object;

    /// The organization that owns the model.
    @serdeKeys("owned_by")
    string ownedBy;
}

///
struct ModelsResponse
{
    ///
    Model[] data;
    ///
    string object;
}
