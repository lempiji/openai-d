module openai.administration.usage;

import std.datetime : SysTime;
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
    @serdeKeys("input_tokens") int inputTokens;
    @serdeKeys("output_tokens") int outputTokens;
    @serdeKeys("num_model_requests") int numModelRequests;
    @serdeOptional @serdeKeys("project_id") string projectId;
    @serdeOptional @serdeKeys("user_id") string userId;
    @serdeOptional @serdeKeys("api_key_id") string apiKeyId;
    @serdeOptional string model;
    @serdeOptional Nullable!bool batch;
    @serdeOptional @serdeKeys("input_cached_tokens") int inputCachedTokens;
    @serdeOptional @serdeKeys("input_audio_tokens") int inputAudioTokens;
    @serdeOptional @serdeKeys("output_audio_tokens") int outputAudioTokens;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("object", "organization.usage.embeddings.result")
struct UsageEmbeddingsResult
{
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
    @serdeKeys("usage_bytes") int usageBytes;
    @serdeOptional @serdeKeys("project_id") string projectId;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("object", "organization.usage.code_interpreter_sessions.result")
struct UsageCodeInterpreterSessionsResult
{
    @serdeKeys("num_sessions") int numSessions;
    @serdeOptional @serdeKeys("project_id") string projectId;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("object", "organization.costs.result")
struct CostsResult
{
    @serdeIgnoreUnexpectedKeys static struct Amount
    {
        double value;
        string currency;
    }

    Amount amount;
    @serdeOptional @serdeKeys("line_item") string lineItem;
    @serdeOptional @serdeKeys("project_id") string projectId;
    @serdeOptional @serdeKeys("organization_id") string organizationId;
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
@serdeDiscriminatedField("object", "bucket")
struct UsageTimeBucket
{
    @serdeKeys("start_time") long startTime;
    @serdeKeys("end_time") long endTime;
    @serdeOptional @serdeKeys("results") UsageResult[] results;
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

/// Creates a request to list usage data starting from the specified time.
ListUsageRequest listUsageRequest(SysTime startTime)
{
    return listUsageRequest(startTime.toUnixTime());
}

/// Creates a request to list usage data starting from the specified time with a limit.
ListUsageRequest listUsageRequest(SysTime startTime, uint limit)
{
    return listUsageRequest(startTime.toUnixTime(), limit);
}

/// Creates a request to list usage data starting from the specified time.
ListUsageRequest listUsageRequest(long startTime)
{
    auto req = ListUsageRequest();
    req.startTime = startTime;
    return req;
}

/// Creates a request to list usage data starting from the specified time with a limit.
ListUsageRequest listUsageRequest(long startTime, uint limit)
{
    auto req = listUsageRequest(startTime);
    req.limit = limit;
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

/// Creates a request to list costs starting from the specified time.
ListCostsRequest listCostsRequest(SysTime startTime)
{
    return listCostsRequest(startTime.toUnixTime());
}

/// Creates a request to list costs starting from the specified time with a limit.
ListCostsRequest listCostsRequest(SysTime startTime, uint limit)
{
    return listCostsRequest(startTime.toUnixTime(), limit);
}

/// Creates a request to list costs starting from the specified time.
ListCostsRequest listCostsRequest(long startTime)
{
    auto req = ListCostsRequest();
    req.startTime = startTime;
    return req;
}

/// Creates a request to list costs starting from the specified time with a limit.
ListCostsRequest listCostsRequest(long startTime, uint limit)
{
    auto req = listCostsRequest(startTime);
    req.limit = limit;
    return req;
}

unittest
{
    import mir.deser.json : deserializeJson;

    enum example = `{"object":"page","data":[{"object":"bucket","start_time":1730419200,"end_time":1730505600,"results":[{"object":"organization.usage.audio_speeches.result","characters":45,"num_model_requests":1,"project_id":null,"user_id":null,"api_key_id":null,"model":null}]}],"has_more":false,"next_page":null}`;
    auto res = deserializeJson!UsageResponse(example);
    assert(res.data.length == 1);
    assert(res.data[0].results.length == 1);
    assert(res.data[0].results[0].get!UsageAudioSpeechesResult().characters == 45);
}

unittest
{
    import mir.deser.json : deserializeJson;

    enum example = `{"object":"page","data":[{"object":"bucket","start_time":1730419200,"end_time":1730505600,"results":[{"object":"organization.costs.result","amount":{"value":0.06,"currency":"usd"},"line_item":null,"project_id":null}]}],"has_more":false,"next_page":null}`;
    auto res = deserializeJson!UsageResponse(example);
    assert(res.data[0].results[0].get!CostsResult().amount.value == 0.06);
}

unittest
{
    enum json = `{
  "object": "page",
  "data": [
    {
      "object": "bucket",
      "start_time": 1750420300,
      "end_time": 1750464000,
      "results": []
    },
    {
      "object": "bucket",
      "start_time": 1750464000,
      "end_time": 1750506700,
      "results": []
    }
  ],
  "has_more": false,
  "next_page": null
}`;
    import mir.deser.json : deserializeJson;

    auto res = deserializeJson!UsageResponse(json);
    assert(res.data.length == 2);
    assert(res.data[0].startTime == 1_750_420_300);
    assert(res.data[0].endTime == 1_750_464_000);
    assert(res.data[0].results.length == 0);
    assert(!res.hasMore);
    assert(res.nextPage.isNull);
}

unittest
{
    enum json = `{
  "object": "page",
  "data": [
    {
      "object": "bucket",
      "start_time": 1750420976,
      "end_time": 1750464000,
      "results": []
    },
    {
      "object": "bucket",
      "start_time": 1750464000,
      "end_time": 1750507376,
      "results": [
        {
          "object": "organization.usage.completions.result",
          "input_tokens": 19,
          "output_tokens": 9,
          "num_model_requests": 1,
          "project_id": null,
          "user_id": null,
          "api_key_id": null,
          "model": null,
          "batch": null,
          "input_cached_tokens": 0,
          "input_audio_tokens": 0,
          "output_audio_tokens": 0
        }
      ]
    }
  ],
  "has_more": false,
  "next_page": null
}`;
    import mir.deser.json : deserializeJson;

    auto res = deserializeJson!UsageResponse(json);
    assert(res.data.length == 2);
    assert(res.data[0].startTime == 1_750_420_976);
    assert(res.data[0].endTime == 1_750_464_000);
    assert(res.data[0].results.length == 0);
    assert(res.data[1].results.length == 1);
    auto result = res.data[1].results[0].get!UsageCompletionsResult();
    assert(result.inputTokens == 19);
    assert(result.outputTokens == 9);
}
