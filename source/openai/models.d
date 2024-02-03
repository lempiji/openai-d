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
///
enum GPT432K0613 = "gpt-4-32k-0613";
///
deprecated("'gpt-4-32k-0314' is to be removed by 2024-06-13. Please use 'gpt-4-32k-0613' instead")
enum GPT432K0314 = "gpt-4-32k-0314";
///
enum GPT432K = "gpt-4-32k";
///
enum GPT40613 = "gpt-4-0613";
///
deprecated("'gpt-4-0314' is to be removed by 2024-06-13. Please use 'gpt-4-0613' instead")
enum GPT40314 = "gpt-4-0314";
///
enum GPT4 = "gpt-4";
///
enum GPT3Dot5TurboInstruct = "gpt-3.5-turbo-instruct";
///
enum GPT3Dot5Turbo16K0613 = "gpt-3.5-turbo-16k-0613";
/// 
enum GPT3Dot5Turbo16K = "gpt-3.5-turbo-16k";
///
enum GPT3Dot5Turbo0613 = "gpt-3.5-turbo-0613";
///
deprecated("'gpt-3-turbo-0314' is to be removed by 2024-06-13. Please use 'gpt-3-turbo-0613' instead")
enum GPT3Dot5Turbo0301 = "gpt-3.5-turbo-0301";
///
enum GPT3Dot5Turbo = "gpt-3.5-turbo";
///
enum DavinciInstructBeta = "davinci-instruct-beta";
///
enum CurieInstructBeta = "curie-instruct-beta";

// Embedding
///
enum AdaEmbeddingV2 = "text-embedding-ada-002";
///
enum AdaCodeSearchCode = "ada-code-search-code";
///
enum AdaCodeSearchText = "ada-code-search-text";

// Moderation
///
enum ModerationTextStable = "text-moderation-stable";
///
enum ModerationTextLatest = "text-moderation-latest";
///
enum ModerationText001 = "text-moderation-001";

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
