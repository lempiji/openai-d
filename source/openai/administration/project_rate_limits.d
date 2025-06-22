module openai.administration.project_rate_limits;

import mir.serde;
import mir.serde : serdeEnumProxy;
import mir.string_map;
import mir.algebraic;

@safe:

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("object", "project.rate_limit")
struct ProjectRateLimit
{
    string id;
    @serdeOptional @serdeKeys("max_requests_per_1_minute") long maxRequestsPer1Minute;
    @serdeOptional @serdeKeys("max_requests_per_1_day") long maxRequestsPer1Day;
    @serdeOptional @serdeKeys("max_tokens_per_1_minute") long maxTokensPer1Minute;
    @serdeOptional @serdeKeys("max_tokens_per_1_day") long maxTokensPer1Day;
    @serdeOptional @serdeKeys("max_images_per_1_minute") long maxImagesPer1Minute;
    @serdeOptional @serdeKeys("batch_1_day_max_input_tokens") long batch1DayMaxInputTokens;
}

@serdeIgnoreUnexpectedKeys
struct ListProjectRateLimitResponse
{
    string object;
    ProjectRateLimit[] data;
    @serdeKeys("first_id") string firstId;
    @serdeKeys("last_id") string lastId;
    @serdeKeys("has_more") bool hasMore;
}

struct ListProjectRateLimitsRequest
{
    @serdeOptional @serdeIgnoreDefault uint limit;
    @serdeOptional @serdeIgnoreDefault string after;
}

/// Convenience constructor for `ListProjectRateLimitsRequest`.
ListProjectRateLimitsRequest listProjectRateLimitsRequest(uint limit)
{
    auto req = ListProjectRateLimitsRequest();
    req.limit = limit;
    return req;
}

/// ditto
ListProjectRateLimitsRequest listProjectRateLimitsRequest(uint limit, string after)
{
    auto req = listProjectRateLimitsRequest(limit);
    req.after = after;
    return req;
}

struct CreateProjectRateLimitRequest
{
    @serdeKeys("max_requests_per_1_minute") long maxRequestsPer1Minute;
    @serdeKeys("max_tokens_per_1_minute") long maxTokensPer1Minute;
    @serdeKeys("max_images_per_1_minute") long maxImagesPer1Minute;
    @serdeKeys("max_audio_megabytes_per_1_minute") long maxAudioMegabytesPer1Minute;
    @serdeKeys("max_requests_per_1_day") long maxRequestsPer1Day;
    @serdeKeys("batch_1_day_max_input_tokens") long batch1DayMaxInputTokens;
}

/// Convenience constructor for `CreateProjectRateLimitRequest`.
CreateProjectRateLimitRequest createProjectRateLimitRequest(
    long maxRequestsPer1Minute,
    long maxTokensPer1Minute,
    long maxImagesPer1Minute,
    long maxAudioMegabytesPer1Minute,
    long maxRequestsPer1Day,
    long batch1DayMaxInputTokens)
{
    auto req = CreateProjectRateLimitRequest();
    req.maxRequestsPer1Minute = maxRequestsPer1Minute;
    req.maxTokensPer1Minute = maxTokensPer1Minute;
    req.maxImagesPer1Minute = maxImagesPer1Minute;
    req.maxAudioMegabytesPer1Minute = maxAudioMegabytesPer1Minute;
    req.maxRequestsPer1Day = maxRequestsPer1Day;
    req.batch1DayMaxInputTokens = batch1DayMaxInputTokens;
    return req;
}

struct ModifyProjectRateLimitRequest
{
    @serdeOptional @serdeIgnoreDefault
    @serdeKeys("max_requests_per_1_minute") long maxRequestsPer1Minute;
    @serdeOptional @serdeIgnoreDefault
    @serdeKeys("max_tokens_per_1_minute") long maxTokensPer1Minute;
    @serdeOptional @serdeIgnoreDefault
    @serdeKeys("max_images_per_1_minute") long maxImagesPer1Minute;
    @serdeOptional @serdeIgnoreDefault
    @serdeKeys("max_audio_megabytes_per_1_minute") long maxAudioMegabytesPer1Minute;
    @serdeOptional @serdeIgnoreDefault
    @serdeKeys("max_requests_per_1_day") long maxRequestsPer1Day;
    @serdeOptional @serdeIgnoreDefault
    @serdeKeys("batch_1_day_max_input_tokens") long batch1DayMaxInputTokens;
}

/// Convenience constructor for `ModifyProjectRateLimitRequest`.
ModifyProjectRateLimitRequest modifyProjectRateLimitRequest(
    long maxRequestsPer1Minute,
    long maxTokensPer1Minute,
    long maxImagesPer1Minute,
    long maxAudioMegabytesPer1Minute,
    long maxRequestsPer1Day,
    long batch1DayMaxInputTokens)
{
    auto req = ModifyProjectRateLimitRequest();
    req.maxRequestsPer1Minute = maxRequestsPer1Minute;
    req.maxTokensPer1Minute = maxTokensPer1Minute;
    req.maxImagesPer1Minute = maxImagesPer1Minute;
    req.maxAudioMegabytesPer1Minute = maxAudioMegabytesPer1Minute;
    req.maxRequestsPer1Day = maxRequestsPer1Day;
    req.batch1DayMaxInputTokens = batch1DayMaxInputTokens;
    return req;
}

unittest
{
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    enum listExample =
        `{"object":"list","data":[{"object":"organization.project.rate_limit","id":"rl_abc","max_requests_per_1_minute":10,"max_tokens_per_1_minute":100,"max_images_per_1_minute":5,"max_audio_megabytes_per_1_minute":20,"max_requests_per_1_day":50,"batch_1_day_max_input_tokens":1000}],"first_id":"rl_abc","last_id":"rl_abc","has_more":false}`;
    auto list = deserializeJson!ListProjectRateLimitResponse(listExample);
    assert(list.data.length == 1);
    assert(list.data[0].id == "rl_abc");

    auto lreq = listProjectRateLimitsRequest(5);
    assert(serializeJson(lreq) == `{"limit":5}`);
    auto lafter = listProjectRateLimitsRequest(5, "last");
    assert(serializeJson(lafter) == `{"limit":5,"after":"last"}`);

    auto creq = createProjectRateLimitRequest(1, 2, 3, 4, 5, 6);
    assert(serializeJson(creq) == `{"max_requests_per_1_minute":1,"max_tokens_per_1_minute":2,"max_images_per_1_minute":3,"max_audio_megabytes_per_1_minute":4,"max_requests_per_1_day":5,"batch_1_day_max_input_tokens":6}`);

    auto ureq = modifyProjectRateLimitRequest(1, 2, 3, 4, 5, 6);
    assert(serializeJson(ureq) == `{"max_requests_per_1_minute":1,"max_tokens_per_1_minute":2,"max_images_per_1_minute":3,"max_audio_megabytes_per_1_minute":4,"max_requests_per_1_day":5,"batch_1_day_max_input_tokens":6}`);
}
