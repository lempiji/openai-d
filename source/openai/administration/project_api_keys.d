module openai.administration.project_api_keys;

import mir.serde;
import mir.serde : serdeEnumProxy;
import mir.string_map;
import std.typecons : Nullable;
import mir.algebraic;

public import openai.administration.api_keys : OwnerInfo;

@safe:

@serdeIgnoreUnexpectedKeys
struct ProjectApiKey
{
    string object;
    string id;
    string name;
    @serdeKeys("redacted_value") string redactedValue;
    @serdeKeys("created_at") long createdAt;
    @serdeKeys("last_used_at") long lastUsedAt;
    @serdeOptional OwnerInfo owner;
    @serdeOptional string value;
}

@serdeIgnoreUnexpectedKeys
struct ProjectApiKeyListResponse
{
    string object;
    ProjectApiKey[] data;
    @serdeKeys("first_id") string firstId;
    @serdeKeys("last_id") string lastId;
    @serdeKeys("has_more") bool hasMore;
}

struct ListProjectApiKeysRequest
{
    @serdeOptional @serdeIgnoreDefault uint limit;
    @serdeOptional @serdeIgnoreDefault string after;
}

/// Convenience constructor for `ListProjectApiKeysRequest`.
ListProjectApiKeysRequest listProjectApiKeysRequest(uint limit)
{
    auto req = ListProjectApiKeysRequest();
    req.limit = limit;
    return req;
}

struct CreateProjectApiKeyRequest
{
    string name;
}

/// Convenience constructor for `CreateProjectApiKeyRequest`.
CreateProjectApiKeyRequest createProjectApiKeyRequest(string name)
{
    auto req = CreateProjectApiKeyRequest();
    req.name = name;
    return req;
}

struct ModifyProjectApiKeyRequest
{
    string name;
}

/// Convenience constructor for `ModifyProjectApiKeyRequest`.
ModifyProjectApiKeyRequest modifyProjectApiKeyRequest(string name)
{
    auto req = ModifyProjectApiKeyRequest();
    req.name = name;
    return req;
}

@serdeIgnoreUnexpectedKeys
struct DeleteProjectApiKeyResponse
{
    string object;
    string id;
    bool deleted;
}

@serdeIgnoreUnexpectedKeys

unittest
{
    import mir.ser.json : serializeJson;

    auto req = listProjectApiKeysRequest(5);
    assert(serializeJson(req) == `{"limit":5}`);
}

unittest
{
    import mir.ser.json : serializeJson;

    auto req = createProjectApiKeyRequest("My Key");
    assert(serializeJson(req) == `{"name":"My Key"}`);
}

unittest
{
    import mir.ser.json : serializeJson;

    auto req = modifyProjectApiKeyRequest("New Name");
    assert(serializeJson(req) == `{"name":"New Name"}`);
}

unittest
{
    import mir.deser.json : deserializeJson;

    enum example =
        `{"object":"list","data":[{"object":"organization.project.api_key","id":"key_abc","name":"Key","redacted_value":"sk-abc","created_at":1,"last_used_at":2,"owner":{"type":"user","id":"user_abc","name":"Owner"}}],"first_id":"key_abc","last_id":"key_abc","has_more":false}`;
    auto list = deserializeJson!ProjectApiKeyListResponse(example);
    assert(list.data.length == 1);
    assert(list.data[0].id == "key_abc");
}
