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
/// Identifier for the `gpt-4o` model.
enum GPT4O = "gpt-4o";
/// Identifier for the dated `gpt-4o-2024-05-13` snapshot.
enum GPT4O20240513 = "gpt-4o-2024-05-13";
/// Identifier for the dated `gpt-4o-2024-08-06` snapshot.
enum GPT4O20240806 = "gpt-4o-2024-08-06";
/// Identifier for the dated `gpt-4o-2024-11-20` snapshot.
enum GPT4O20241120 = "gpt-4o-2024-11-20";
/// Always points to the most recent GPT‑4o model.
enum ChatGPT4OLatest = "chatgpt-4o-latest";

// GPT-4o mini Series
/// Identifier for the `gpt-4o-mini` model.
enum GPT4OMini = "gpt-4o-mini";
/// Identifier for the dated `gpt-4o-mini-2024-07-18` snapshot.
enum GPT4OMini20240718 = "gpt-4o-mini-2024-07-18";
/// Use to request the TTS‑optimised variant.
enum GPT4OMiniTTS = "gpt-4o-mini-tts";
/// Preview model for real‑time usage.
enum GPT4ORealtimePreview = "gpt-4o-realtime-preview";
/// Preview model specialised for audio input.
enum GPT4OAudioPreview = "gpt-4o-audio-preview";
/// Preview model specialised for search.
enum GPT4OSearchPreview = "gpt-4o-search-preview";

// o1 and o1-mini Series
/// Identifier for the `o1` model.
enum O1 = "o1";
/// Dated snapshot `o1-2024-12-17`.
enum O120241217 = "o1-2024-12-17";
/// Identifier for the `o1-mini` model.
enum O1Mini = "o1-mini";
/// Dated snapshot `o1-mini-2024-09-12`.
enum O1Mini20240912 = "o1-mini-2024-09-12";
/// Identifier for the `o1-preview` model.
enum O1Preview = "o1-preview";
/// Dated snapshot `o1-preview-2024-09-12`.
enum O1Preview20240912 = "o1-preview-2024-09-12";

// o4-mini Series
/// Identifier for the `o4-mini` model.
enum O4Mini = "o4-mini";
/// Dated snapshot `o4-mini-2025-04-16`.
enum O4Mini20250416 = "o4-mini-2025-04-16";

// o3 and o3-mini Series
/// Identifier for the `o3` model.
enum O3 = "o3";
/// Dated snapshot `o3-2025-04-16`.
enum O320250416 = "o3-2025-04-16";
/// Identifier for the `o3-mini` model.
enum O3Mini = "o3-mini";
/// Dated snapshot `o3-mini-2025-01-31`.
enum O3Mini20250131 = "o3-mini-2025-01-31";

// GPT-4 Turbo Series
/// Identifier for the `gpt-4-turbo` model.
enum GPT4Turbo = "gpt-4-turbo";
/// Dated snapshot `gpt-4-turbo-2024-04-09`.
enum GPT4Turbo20240409 = "gpt-4-turbo-2024-04-09";
/// Preview build of GPT‑4 Turbo.
enum GPT4TurboPreview = "gpt-4-turbo-preview";

// GPT-4 Vision Series
/// Deprecated: will be removed by 2024‑12‑06. Use `GPT4O` instead.
deprecated("'gpt-4-vision-preview' is to be removed by 2024-12-06. Please use 'gpt-4o' instead")
enum GPT4VisionPreview = "gpt-4-vision-preview";

// GPT-4-32k Series
/// Deprecated: will be removed by 2025‑06‑06. Use `GPT4O` instead.
deprecated("'gpt-4-32k' is to be removed by 2025-06-06. Please use 'gpt-4o' instead")
enum GPT432K = "gpt-4-32k";
/// Deprecated: will be removed by 2025‑06‑06. Use `GPT4O` instead.
deprecated("'gpt-4-32k-0314' is to be removed by 2025-06-06. Please use 'gpt-4o' instead")
enum GPT432K0314 = "gpt-4-32k-0314";
/// Deprecated: will be removed by 2025‑06‑06. Use `GPT4O` instead.
deprecated("'gpt-4-32k-0613' is to be removed by 2025-06-06. Please use 'gpt-4o' instead")
enum GPT432K0613 = "gpt-4-32k-0613";

// GPT-4 Series
/// Identifier for the `gpt-4` model.
enum GPT4 = "gpt-4";
/// Deprecated: removed by 2024‑06‑13. Use `GPT4O` instead.
deprecated("'gpt-4-0314' is to be removed by 2024-06-13. Please use 'gpt-4o' instead")
enum GPT40314 = "gpt-4-0314";
/// Identifier for the dated `gpt-4-0613` snapshot.
enum GPT40613 = "gpt-4-0613";
/// Identifier for the preview build `gpt-4-0125-preview`.
enum GPT40125Preview = "gpt-4-0125-preview";
/// Identifier for the preview build `gpt-4-1106-preview`.
enum GPT41106Preview = "gpt-4-1106-preview";

// GPT-4.1 Series
/// Identifier for the experimental `gpt-4.1` model.
enum GPT4Dot1 = "gpt-4.1";
/// Identifier for `gpt-4.1-mini`.
enum GPT4Dot1Mini = "gpt-4.1-mini";
/// Identifier for `gpt-4.1-nano`.
enum GPT4Dot1Nano = "gpt-4.1-nano";

// GPT-3.5 Turbo Series
/// Identifier for the `gpt-3.5-turbo` model.
enum GPT3Dot5Turbo = "gpt-3.5-turbo";
/// Instruction‑tuned variant of `gpt-3.5-turbo`.
enum GPT3Dot5TurboInstruct = "gpt-3.5-turbo-instruct";
/// Dated snapshot `gpt-3.5-turbo-0125`.
enum GPT350Turbo0125 = "gpt-3.5-turbo-0125";
/// Dated snapshot `gpt-3.5-turbo-1106`.
enum GPT350Turbo1106 = "gpt-3.5-turbo-1106";
/// Deprecated: removed by 2024‑06‑13. Use `GPT3Dot5Turbo` instead.
deprecated("'gpt-3-turbo-0301' is to be removed by 2024-06-13. Please use 'gpt-3-turbo' instead")
enum GPT3Dot5Turbo0301 = "gpt-3.5-turbo-0301";
/// Deprecated: removed by 2024‑09‑13. Use `GPT3Dot5Turbo` instead.
deprecated("'gpt-3.5-turbo-0613' is to be removed by 2024-09-13. Please use 'gpt-3.5-turbo' instead")
enum GPT3Dot5Turbo0613 = "gpt-3.5-turbo-0613";

// GPT-3.5 Turbo 16k Series
/// Identifier for the `gpt-3.5-turbo-16k` model.
enum GPT3Dot5Turbo16K = "gpt-3.5-turbo-16k";
/// Deprecated: removed by 2024‑09‑13. Use `GPT3Dot5Turbo` instead.
deprecated("'gpt-3.5-turbo-16k-0613' is to be removed by 2024-09-13. Please use 'gpt-3.5-turbo' instead")
enum GPT3Dot5Turbo16K0613 = "gpt-3.5-turbo-16k-0613";

/// davinci-instruct-beta
enum DavinciInstructBeta = "davinci-instruct-beta";
/// curie-instruct-beta
enum CurieInstructBeta = "curie-instruct-beta";

// Embedding
/// Identifier for the `text-embedding-3-large` model.
enum TextEmbedding3Large = "text-embedding-3-large";
/// Identifier for the `text-embedding-3-small` model.
enum TextEmbedding3Small = "text-embedding-3-small";
/// Identifier for the `text-embedding-ada-002` model.
enum AdaEmbeddingV2 = "text-embedding-ada-002";

// Moderation
/// Stable moderation model.
enum ModerationTextStable = "text-moderation-stable";
/// Latest moderation model.
enum ModerationTextLatest = "text-moderation-latest";
/// Archived moderation model used for testing.
enum ModerationText007 = "text-moderation-007";

// GPT base
/// Identifier for the `babbage-002` model.
enum Babbage002 = "babbage-002";
/// Identifier for the `davinci-002` model.
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
struct ListModelResponse
{
    ///
    Model[] data;
    ///
    string object;
}

unittest
{
    import mir.deser.json;

    const json = `{"object":"list","data":[{"id":"gpt-3.5-turbo","created":0,"object":"model","owned_by":"openai"}]}`;
    auto response = deserializeJson!ListModelResponse(json);

    assert(response.object == "list");
    assert(response.data.length == 1);
    assert(response.data[0].id == "gpt-3.5-turbo");
    assert(response.data[0].ownedBy == "openai");
    assert(response.data[0].object == "model");
}
