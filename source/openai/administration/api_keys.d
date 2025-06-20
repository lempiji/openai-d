module openai.administration.api_keys;

import mir.serde;
import mir.serde : serdeEnumProxy;
import mir.string_map;
import std.typecons : Nullable;
import mir.algebraic;

@safe:

// Data structures

// Data structures
@serdeIgnoreUnexpectedKeys
struct OwnerInfo
{
    string type;
    string id;
    @serdeOptional string name;
}

@serdeIgnoreUnexpectedKeys
struct AdminApiKey
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
struct AdminApiKeyListResponse
{
    string object;
    AdminApiKey[] data;
    @serdeKeys("first_id") string firstId;
    @serdeKeys("last_id") string lastId;
    @serdeKeys("has_more") bool hasMore;
}

struct ListAdminApiKeysRequest
{
    @serdeOptional @serdeIgnoreDefault string after;
    @serdeOptional @serdeIgnoreDefault uint limit;
}

/// Convenience constructor for `ListAdminApiKeysRequest`.
ListAdminApiKeysRequest listAdminApiKeysRequest(uint limit)
{
    auto req = ListAdminApiKeysRequest();
    req.limit = limit;
    return req;
}

struct CreateAdminApiKeyRequest
{
    string name;
}

/// Convenience constructor for `CreateAdminApiKeyRequest`.
CreateAdminApiKeyRequest createAdminApiKeyRequest(string name)
{
    auto req = CreateAdminApiKeyRequest();
    req.name = name;
    return req;
}

@serdeIgnoreUnexpectedKeys
struct DeleteAdminApiKeyResponse
{
    string id;
    string object;
    bool deleted;
}

unittest
{
    import mir.deser.json : deserializeJson;

    enum json = "{\"object\":\"list\",\"data\":[{\"object\":\"organization.admin_api_key\",\"id\":\"key_abc\",\"name\":\"Main Admin Key\",\"redacted_value\":\"sk-admin...def\",\"created_at\":1,\"last_used_at\":2}] ,\"first_id\":\"key_abc\",\"last_id\":\"key_abc\",\"has_more\":false}";
    auto list = deserializeJson!AdminApiKeyListResponse(json);
    assert(list.data.length == 1);
    assert(list.data[0].id == "key_abc");
}

unittest
{
    import mir.ser.json : serializeJson;

    auto req = createAdminApiKeyRequest("main-key");
    assert(serializeJson(req) == `{"name":"main-key"}`);
}
