module openai.administration.admin_api_key;

import mir.serde;
import mir.serde : serdeEnumProxy;
import mir.string_map;
import mir.algebraic;

@safe:

// Data structures

// Data structures
@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("object", "organization.user")
struct OwnerInfo
{
    string type;
    @serdeOptional string id;
    @serdeOptional string name;
    @serdeOptional string email;
    @serdeOptional @serdeKeys("created_at") Nullable!long createdAt;
    @serdeOptional string role;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("object", "organization.admin_api_key")
struct AdminApiKey
{
    string id;
    string name;
    @serdeKeys("redacted_value") string redactedValue;
    @serdeKeys("created_at") long createdAt;
    @serdeOptional @serdeKeys("last_used_at") Nullable!long lastUsedAt;
    @serdeOptional OwnerInfo owner;
    @serdeOptional string value;
}

@serdeIgnoreUnexpectedKeys
struct ListAdminApiKeyResponse
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

/// ditto
ListAdminApiKeysRequest listAdminApiKeysRequest(uint limit, string after)
{
    auto req = listAdminApiKeysRequest(limit);
    req.after = after;
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
    auto list = deserializeJson!ListAdminApiKeyResponse(json);
    assert(list.data.length == 1);
    assert(list.data[0].id == "key_abc");
}

unittest
{
    import mir.ser.json : serializeJson;

    auto req = createAdminApiKeyRequest("main-key");
    assert(serializeJson(req) == `{"name":"main-key"}`);
}

unittest
{
    import mir.ser.json : serializeJson;

    auto req = listAdminApiKeysRequest(5, "k1");
    assert(serializeJson(req) == `{"after":"k1","limit":5}`);
}

unittest
{
    enum json = `{
  "object": "organization.admin_api_key",
  "id": "key_adminapikey_1a",
  "name": "Example Key",
  "redacted_value": "sk-admin*************************************************************************************************************************s1MA",
  "created_at": 1750481917,
  "last_used_at": null,
  "owner": {
    "type": "user",
    "object": "organization.user",
    "id": "user-some-id-here",
    "name": "user name",
    "created_at": 1615456045,
    "role": "owner"
  },
  "value": "sk-admin-o_4n-z_xxxxuyyyyLzzzzz-Uopoiweraijg_itsdengerfieldbutsafe"
}`;
    import mir.deser.json : deserializeJson;

    auto key = deserializeJson!AdminApiKey(json);
    assert(key.id == "key_adminapikey_1a");
    assert(key.name == "Example Key");
    assert(key.redactedValue.length > 0);
    assert(key.value.length > 0);
    assert(key.owner.id == "user-some-id-here");
}
