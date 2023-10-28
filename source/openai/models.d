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
deprecated("'text-davinci-003' is to be removed by 2024-01-04. Please use 'gpt-3.5-turbo-instruct' instead")
enum TextDavinci003 = "text-davinci-003";
///
deprecated("'text-davinci-002' is to be removed by 2024-01-04. Please use 'gpt-3.5-turbo-instruct' instead")
enum TextDavinci002 = "text-davinci-002";
///
deprecated("'text-curie-001' is to be removed by 2024-01-04. Please use 'gpt-3.5-turbo-instruct' instead")
enum TextCurie001 = "text-curie-001";
///
deprecated("'text-babbage-001' is to be removed by 2024-01-04. Please use 'gpt-3.5-turbo-instruct' instead")
enum TextBabbage001 = "text-babbage-001";
///
deprecated("'text-ada-001' is to be removed by 2024-01-04. Please use 'gpt-3.5-turbo-instruct' instead")
enum TextAda001 = "text-ada-001";
///
deprecated("'text-ada-001' is to be removed by 2024-01-04. Please use 'gpt-3.5-turbo-instruct' instead")
enum TextDavinci001 = "text-davinci-001";
///
enum DavinciInstructBeta = "davinci-instruct-beta";
///
deprecated("'davinci' is to be removed by 2024-01-04. Please use 'gpt-3.5-turbo-instruct' instead")
enum Davinci = "davinci";
///
enum CurieInstructBeta = "curie-instruct-beta";
///
deprecated("'curie' is to be removed by 2024-01-04. Please use 'gpt-3.5-turbo-instruct' instead")
enum Curie = "curie";
///
deprecated("'ada' is to be removed by 2024-01-04. Please use 'gpt-3.5-turbo-instruct' instead")
enum Ada = "ada";
///
deprecated("'babbage' is to be removed by 2024-01-04. Please use 'gpt-3.5-turbo-instruct' instead")
enum Babbage = "babbage";

// Embedding
///
enum AdaEmbeddingV2 = "text-embedding-ada-002";
///
deprecated("'text-similarity-ada-001' is to be removed by 2024-01-04. Please use 'text-embedding-ada-002' instead")
enum AdaSimilarity = "text-similarity-ada-001";
///
deprecated("'text-similarity-ada-001' is to be removed by 2024-01-04. Please use 'text-embedding-ada-002' instead")
enum BabbageSimilarity = "text-similarity-babbage-001";
///
deprecated("'text-similarity-ada-001' is to be removed by 2024-01-04. Please use 'text-embedding-ada-002' instead")
enum CurieSimilarity = "text-similarity-curie-001";
///
deprecated("'text-similarity-ada-001' is to be removed by 2024-01-04. Please use 'text-embedding-ada-002' instead")
enum DavinciSimilarity = "text-similarity-davinci-001";
///
deprecated("'text-similarity-ada-001' is to be removed by 2024-01-04. Please use 'text-embedding-ada-002' instead")
enum AdaSearchDocument = "text-search-ada-doc-001";
///
deprecated("'text-similarity-ada-001' is to be removed by 2024-01-04. Please use 'text-embedding-ada-002' instead")
enum AdaSearchQuery = "text-search-ada-query-001";
///
deprecated("'text-similarity-ada-001' is to be removed by 2024-01-04. Please use 'text-embedding-ada-002' instead")
enum BabbageSearchDocument = "text-search-babbage-doc-001";
///
deprecated("'text-similarity-ada-001' is to be removed by 2024-01-04. Please use 'text-embedding-ada-002' instead")
enum BabbageSearchQuery = "text-search-babbage-query-001";
///
deprecated("'text-similarity-ada-001' is to be removed by 2024-01-04. Please use 'text-embedding-ada-002' instead")
enum CurieSearchDocument = "text-search-curie-doc-001";
///
deprecated("'text-similarity-ada-001' is to be removed by 2024-01-04. Please use 'text-embedding-ada-002' instead")
enum CurieSearchQuery = "text-search-curie-query-001";
///
deprecated("'text-similarity-ada-001' is to be removed by 2024-01-04. Please use 'text-embedding-ada-002' instead")
enum DavinciSearchDocument = "text-search-davinci-doc-001";
///
deprecated("'text-similarity-ada-001' is to be removed by 2024-01-04. Please use 'text-embedding-ada-002' instead")
enum DavinciSearchQuery = "text-search-davinci-query-001";
///
enum AdaCodeSearchCode = "ada-code-search-code";
///
deprecated("'text-similarity-ada-001' is to be removed by 2024-01-04. Please use 'text-embedding-ada-002' instead")
enum AdaCodeSearchCode001 = "code-search-ada-code-001";
///
enum AdaCodeSearchText = "ada-code-search-text";
///
deprecated("'text-similarity-ada-001' is to be removed by 2024-01-04. Please use 'text-embedding-ada-002' instead")
enum AdaCodeSearchText001 = "code-search-ada-text-001";
///
deprecated("'text-similarity-ada-001' is to be removed by 2024-01-04. Please use 'text-embedding-ada-002' instead")
enum BabbageCodeSearchCode = "code-search-babbage-code-001";
///
deprecated("'text-similarity-ada-001' is to be removed by 2024-01-04. Please use 'text-embedding-ada-002' instead")
enum BabbageCodeSearchCode001 = "code-search-babbage-code-001";
///
deprecated("'text-similarity-ada-001' is to be removed by 2024-01-04. Please use 'text-embedding-ada-002' instead")
enum BabbageCodeSearchText = "code-search-babbage-text-001";
///
deprecated("'text-similarity-ada-001' is to be removed by 2024-01-04. Please use 'text-embedding-ada-002' instead")
enum BabbageCodeSearchText001 = "code-search-babbage-text-001";

// Moderation
///
enum ModerationTextStable = "text-moderation-stable";
///
enum ModerationTextLatest = "text-moderation-latest";
///
enum ModerationText001    = "text-moderation-001";

///
@serdeIgnoreUnexpectedKeys
struct ModelPermission
{
    ///
    string id;
    ///
    string object;
    ///
    ulong created;
    ///
    @serdeKeys("allow_create_engine")
    bool allowCreateEngine;
    ///
    @serdeKeys("allow_sampling")
    bool allowSampling;
    ///
    @serdeKeys("allow_logprobs")
    bool allowLogprobs;
    ///
    @serdeKeys("allow_search_indices")
    bool allowSearchIndices;
    ///
    @serdeKeys("allow_view")
    bool allowView;
    ///
    @serdeKeys("allow_fine_tuning")
    bool allowFineTuning;
    ///
    string organization;
    // FIXME Unknown type
    //string group;
    ///
    @serdeKeys("is_blocking")
    bool isBlocking;
}

///
@serdeIgnoreUnexpectedKeys
struct Model
{
    ///
    string id;
    ///
    string object;
    ///
    @serdeKeys("owned_by")
        ///
    string ownedBy;
    ///
    ModelPermission[] permission;
    ///
    string root;
    // FIXME Unknown type
    //string parent;
}

///
struct ModelsResponse
{
    ///
    Model[] data;
    ///
    string object;
}
