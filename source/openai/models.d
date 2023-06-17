/**
OpenAI API Models

Standards: https://platform.openai.com/docs/api-reference/models
*/
module openai.models;

import mir.serde;

@safe:

// Chat & Completion
///
enum GPT432K0613 = "gpt-4-32k-0613";
///
enum GPT432K0314 = "gpt-4-32k-0314";
///
enum GPT432K = "gpt-4-32k";
///
enum GPT40613 = "gpt-4-0613";
///
enum GPT40314 = "gpt-4-0314";
///
enum GPT4 = "gpt-4";
///
enum GPT3Dot5Turbo16K0613 = "gpt-3.5-turbo-16k-0613";
/// 
enum GPT3Dot5Turbo16K = "gpt-3.5-turbo-16k";
///
enum GPT3Dot5Turbo0613 = "gpt-3.5-turbo-0613";
///
enum GPT3Dot5Turbo0301 = "gpt-3.5-turbo-0301";
///
enum GPT3Dot5Turbo = "gpt-3.5-turbo";
///
enum TextDavinci003 = "text-davinci-003";
///
enum TextDavinci002 = "text-davinci-002";
///
enum TextCurie001 = "text-curie-001";
///
enum TextBabbage001 = "text-babbage-001";
///
enum TextAda001 = "text-ada-001";
///
enum TextDavinci001 = "text-davinci-001";
///
enum DavinciInstructBeta = "davinci-instruct-beta";
///
enum Davinci = "davinci";
///
enum CurieInstructBeta = "curie-instruct-beta";
///
enum Curie = "curie";
///
enum Ada = "ada";
///
enum Babbage = "babbage";

// Codex
///
enum CodeDavinci002 = "code-davinci-002";
///
enum CodeCushman001 = "code-cushman-001";
///
enum CodeDavinci001 = "code-davinci-001";

// Embedding
///
enum AdaSimilarity = "text-similarity-ada-001";
///
enum BabbageSimilarity = "text-similarity-babbage-001";
///
enum CurieSimilarity = "text-similarity-curie-001";
///
enum DavinciSimilarity = "text-similarity-davinci-001";
///
enum AdaSearchDocument = "text-search-ada-doc-001";
///
enum AdaSearchQuery = "text-search-ada-query-001";
///
enum BabbageSearchDocument = "text-search-babbage-doc-001";
///
enum BabbageSearchQuery = "text-search-babbage-query-001";
///
enum CurieSearchDocument = "text-search-curie-doc-001";
///
enum CurieSearchQuery = "text-search-curie-query-001";
///
enum DavinciSearchDocument = "text-search-davinci-doc-001";
///
enum DavinciSearchQuery = "text-search-davinci-query-001";
///
enum AdaCodeSearchCode = "code-search-ada-code-001";
///
enum AdaCodeSearchText = "code-search-ada-text-001";
///
enum BabbageCodeSearchCode = "code-search-babbage-code-001";
///
enum BabbageCodeSearchText = "code-search-babbage-text-001";
///
enum AdaEmbeddingV2 = "text-embedding-ada-002";

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
