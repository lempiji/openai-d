module openai.administration.usage;

import mir.serde;
import mir.serde : serdeEnumProxy;
import mir.string_map;
import mir.algebraic;

@safe:

// -----------------------------------------------------------------------------
// Usage and Cost Reporting
// -----------------------------------------------------------------------------

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("object", "organization.usage.completions.result")
struct UsageCompletionsResult
{
    string object;
    @serdeKeys("input_tokens") int inputTokens;
    @serdeKeys("output_tokens") int outputTokens;
    @serdeOptional @serdeKeys("input_cached_tokens") int inputCachedTokens;
    @serdeOptional @serdeKeys("input_audio_tokens") int inputAudioTokens;
    @serdeOptional @serdeKeys("output_audio_tokens") int outputAudioTokens;
    @serdeKeys("num_model_requests") int numModelRequests;
    @serdeOptional @serdeKeys("project_id") string projectId;
    @serdeOptional @serdeKeys("user_id") string userId;
    @serdeOptional @serdeKeys("api_key_id") string apiKeyId;
    @serdeOptional string model;
    @serdeOptional bool batch;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("object", "organization.usage.embeddings.result")
struct UsageEmbeddingsResult
{
    string object;
    @serdeKeys("input_tokens") int inputTokens;
    @serdeKeys("num_model_requests") int numModelRequests;
    @serdeOptional @serdeKeys("project_id") string projectId;
    @serdeOptional @serdeKeys("user_id") string userId;
    @serdeOptional @serdeKeys("api_key_id") string apiKeyId;
    @serdeOptional string model;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("object", "organization.usage.images.result")
struct UsageImagesResult
{
    string object;
    int images;
    @serdeKeys("num_model_requests") int numModelRequests;
    @serdeOptional string source;
    @serdeOptional string size;
    @serdeOptional @serdeKeys("project_id") string projectId;
    @serdeOptional @serdeKeys("user_id") string userId;
    @serdeOptional @serdeKeys("api_key_id") string apiKeyId;
    @serdeOptional string model;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("object", "organization.usage.moderations.result")
struct UsageModerationsResult
{
    string object;
    @serdeKeys("input_tokens") int inputTokens;
    @serdeKeys("num_model_requests") int numModelRequests;
    @serdeOptional @serdeKeys("project_id") string projectId;
    @serdeOptional @serdeKeys("user_id") string userId;
    @serdeOptional @serdeKeys("api_key_id") string apiKeyId;
    @serdeOptional string model;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("object", "organization.usage.audio_speeches.result")
struct UsageAudioSpeechesResult
{
    string object;
    int characters;
    @serdeKeys("num_model_requests") int numModelRequests;
    @serdeOptional @serdeKeys("project_id") string projectId;
    @serdeOptional @serdeKeys("user_id") string userId;
    @serdeOptional @serdeKeys("api_key_id") string apiKeyId;
    @serdeOptional string model;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("object", "organization.usage.audio_transcriptions.result")
struct UsageAudioTranscriptionsResult
{
    string object;
    int seconds;
    @serdeKeys("num_model_requests") int numModelRequests;
    @serdeOptional @serdeKeys("project_id") string projectId;
    @serdeOptional @serdeKeys("user_id") string userId;
    @serdeOptional @serdeKeys("api_key_id") string apiKeyId;
    @serdeOptional string model;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("object", "organization.usage.vector_stores.result")
struct UsageVectorStoresResult
{
    string object;
    @serdeKeys("usage_bytes") int usageBytes;
    @serdeOptional @serdeKeys("project_id") string projectId;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("object", "organization.usage.code_interpreter_sessions.result")
struct UsageCodeInterpreterSessionsResult
{
    string object;
    @serdeKeys("num_sessions") int numSessions;
    @serdeOptional @serdeKeys("project_id") string projectId;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("object", "organization.costs.result")
struct CostsResult
{
    string object;
    @serdeIgnoreUnexpectedKeys static struct Amount
    {
        double value;
        string currency;
    }

    Amount amount;
    @serdeOptional @serdeKeys("line_item") string lineItem;
    @serdeOptional @serdeKeys("project_id") string projectId;
}

alias UsageResult = Algebraic!(
    UsageCompletionsResult,
    UsageEmbeddingsResult,
    UsageImagesResult,
    UsageModerationsResult,
    UsageAudioSpeechesResult,
    UsageAudioTranscriptionsResult,
    UsageVectorStoresResult,
    UsageCodeInterpreterSessionsResult,
    CostsResult
);

@serdeIgnoreUnexpectedKeys
struct UsageTimeBucket
{
    string object;
    @serdeKeys("start_time") long startTime;
    @serdeKeys("end_time") long endTime;
    @serdeKeys("result") UsageResult[] results;
}

@serdeIgnoreUnexpectedKeys
struct UsageResponse
{
    string object;
    UsageTimeBucket[] data;
    @serdeKeys("has_more") bool hasMore;
    @serdeKeys("next_page") Nullable!string nextPage;
}

struct ListUsageRequest
{
    @serdeKeys("start_time") long startTime;
    @serdeOptional @serdeIgnoreDefault @serdeKeys("end_time") long endTime;
    @serdeOptional @serdeIgnoreDefault @serdeKeys("bucket_width") string bucketWidth;
    @serdeOptional @serdeIgnoreDefault @serdeKeys("project_ids") string[] projectIds;
    @serdeOptional @serdeIgnoreDefault @serdeKeys("user_ids") string[] userIds;
    @serdeOptional @serdeIgnoreDefault @serdeKeys("api_key_ids") string[] apiKeyIds;
    @serdeOptional @serdeIgnoreDefault string[] models;
    @serdeOptional @serdeIgnoreDefault @serdeKeys("group_by") string[] groupBy;
    @serdeOptional @serdeIgnoreDefault uint limit;
    @serdeOptional @serdeIgnoreDefault string page;
    @serdeOptional @serdeIgnoreDefault bool batch;
}

ListUsageRequest listUsageRequest(long startTime)
{
    auto req = ListUsageRequest();
    req.startTime = startTime;
    return req;
}

struct ListCostsRequest
{
    @serdeKeys("start_time") long startTime;
    @serdeOptional @serdeIgnoreDefault @serdeKeys("end_time") long endTime;
    @serdeOptional @serdeIgnoreDefault @serdeKeys("bucket_width") string bucketWidth;
    @serdeOptional @serdeIgnoreDefault @serdeKeys("project_ids") string[] projectIds;
    @serdeOptional @serdeIgnoreDefault @serdeKeys("group_by") string[] groupBy;
    @serdeOptional @serdeIgnoreDefault uint limit;
    @serdeOptional @serdeIgnoreDefault string page;
}

ListCostsRequest listCostsRequest(long startTime)
{
    auto req = ListCostsRequest();
    req.startTime = startTime;
    return req;
}

unittest
{
    import mir.deser.json : deserializeJson;

    enum example = `{"object":"page","data":[{"object":"bucket","start_time":1730419200,"end_time":1730505600,"result":[{"object":"organization.usage.audio_speeches.result","characters":45,"num_model_requests":1,"project_id":null,"user_id":null,"api_key_id":null,"model":null}]}],"has_more":false,"next_page":null}`;
    auto res = deserializeJson!UsageResponse(example);
    assert(res.data.length == 1);
    assert(res.data[0].results.length == 1);
    assert(res.data[0].results[0].get!UsageAudioSpeechesResult().characters == 45);
}

unittest
{
    import mir.deser.json : deserializeJson;

    enum example = `{"object":"page","data":[{"object":"bucket","start_time":1730419200,"end_time":1730505600,"result":[{"object":"organization.costs.result","amount":{"value":0.06,"currency":"usd"},"line_item":null,"project_id":null}]}],"has_more":false,"next_page":null}`;
    auto res = deserializeJson!UsageResponse(example);
    assert(res.data[0].results[0].get!CostsResult().amount.value == 0.06);
}
