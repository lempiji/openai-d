module openai.administration.project_api_keys;

import mir.serde;
import mir.serde : serdeEnumProxy;
import mir.string_map;
import mir.algebraic;

@safe:

@serdeIgnoreUnexpectedKeys
struct ProjectApiKeyOwnerInfo
{
    @serdeOptional string id;
    @serdeOptional string email;
    @serdeOptional string name;
    @serdeOptional @serdeKeys("created_at") Nullable!long createdAt;
    @serdeOptional string role;
}

@serdeIgnoreUnexpectedKeys
struct ProjectApiKeyServiceAccountInfo
{
    @serdeOptional string id;
    @serdeOptional string name;
    @serdeOptional @serdeKeys("created_at") Nullable!long createdAt;
    @serdeOptional string role;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "user")
struct ProjectApiKeyOwnerUser
{
    @serdeOptional ProjectApiKeyOwnerInfo user;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "service_account")
struct ProjectApiKeyOwnerServiceAccount
{
    @serdeOptional @serdeKeys("service_account") ProjectApiKeyServiceAccountInfo serviceAccount;
}

alias ProjectApiKeyOwner = Algebraic!(ProjectApiKeyOwnerUser, ProjectApiKeyOwnerServiceAccount);

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("object", "organization.project.api_key")
struct ProjectApiKey
{
    string id;
    string name;
    @serdeKeys("redacted_value") string redactedValue;
    @serdeKeys("created_at") long createdAt;
    @serdeOptional @serdeKeys("last_used_at") Nullable!long lastUsedAt;
    ProjectApiKeyOwner owner;
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

/// ditto
ListProjectApiKeysRequest listProjectApiKeysRequest(uint limit, string after)
{
    auto req = ListProjectApiKeysRequest();
    req.limit = limit;
    req.after = after;
    return req;
}

@serdeIgnoreUnexpectedKeys
struct DeleteProjectApiKeyResponse
{
    @serdeOptional string object;
    string id;
    bool deleted;
}

unittest
{
    import mir.ser.json : serializeJson;

    auto req = listProjectApiKeysRequest(5);
    assert(serializeJson(req) == `{"limit":5}`);
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

unittest
{
    enum json = `{
  "object": "list",
  "data": [
    {
      "object": "organization.project.api_key",
      "redacted_value": "sk-proj-********************************************************************************************************************************************************excA",
      "id": "key_key1",
      "name": "My Test Key All",
      "created_at": 1750493476,
      "last_used_at": null,
      "owner": {
        "type": "user",
        "user": {
          "id": "user-user1",
          "email": "user@example.com",
          "name": "lempiji",
          "created_at": 1615456045,
          "role": "owner"
        }
      }
    },
    {
      "object": "organization.project.api_key",
      "redacted_value": "sk-proj-********************************************************************************************************************************************************hWgA",
      "id": "key_key2",
      "name": "Me Test Key Restricted",
      "created_at": 1750493530,
      "last_used_at": null,
      "owner": {
        "type": "user",
        "user": {
          "id": "user-user1",
          "email": "user@example.com",
          "name": "lempiji",
          "created_at": 1615456045,
          "role": "owner"
        }
      }
    },
    {
      "object": "organization.project.api_key",
      "redacted_value": "sk-proj-********************************************************************************************************************************************************VIcA",
      "id": "key_key3",
      "name": "My Test Key Read only",
      "created_at": 1750493548,
      "last_used_at": null,
      "owner": {
        "type": "user",
        "user": {
          "id": "user-user1",
          "email": "user@example.com",
          "name": "lempiji",
          "created_at": 1615456045,
          "role": "owner"
        }
      }
    },
    {
      "object": "organization.project.api_key",
      "redacted_value": "sk-svcac***********************************************************************************************************************************************************380A",
      "id": "key_key4",
      "name": "My Service Account Key",
      "created_at": 1750494142,
      "last_used_at": null,
      "owner": {
        "type": "service_account",
        "service_account": {
          "id": "user-service_account1",
          "name": "My Service Account Key",
          "created_at": 1750494142,
          "role": "owner"
        }
      }
    }
  ],
  "first_id": "key_key1",
  "last_id": "key_key4",
  "has_more": false
}`;

    import mir.deser.json : deserializeJson;

    auto list = deserializeJson!ProjectApiKeyListResponse(json);
    assert(list.data.length == 4);
    assert(list.data[0].id == "key_key1");
    assert(list.data[1].id == "key_key2");
    assert(list.data[2].id == "key_key3");
    assert(list.data[3].id == "key_key4");
    assert(list.data[0].name == "My Test Key All");
    assert(list.data[1].name == "Me Test Key Restricted");
    assert(list.data[2].name == "My Test Key Read only");
    assert(list.data[3].name == "My Service Account Key");
    assert(list.data[0].redactedValue == "sk-proj-********************************************************************************************************************************************************excA");
    assert(list.data[1].redactedValue == "sk-proj-********************************************************************************************************************************************************hWgA");
    assert(list.data[2].redactedValue == "sk-proj-********************************************************************************************************************************************************VIcA");
    assert(list.data[3].redactedValue == "sk-svcac***********************************************************************************************************************************************************380A");
    assert(list.data[0].owner.get!(ProjectApiKeyOwnerUser).user.id == "user-user1");
    assert(list.data[0].owner.get!(ProjectApiKeyOwnerUser).user.email == "user@example.com");
    assert(list.data[1].owner.get!(ProjectApiKeyOwnerUser).user.id == "user-user1");
    assert(list.data[1].owner.get!(ProjectApiKeyOwnerUser).user.email == "user@example.com");
    assert(list.data[2].owner.get!(ProjectApiKeyOwnerUser).user.id == "user-user1");
    assert(list.data[2].owner.get!(ProjectApiKeyOwnerUser).user.email == "user@example.com");
    assert(list.data[3].owner.get!(ProjectApiKeyOwnerServiceAccount).serviceAccount.id == "user-service_account1");
    assert(list.data[3].owner.get!(ProjectApiKeyOwnerServiceAccount).serviceAccount.name == "My Service Account Key");
    assert(list.data[3].owner.get!(ProjectApiKeyOwnerServiceAccount).serviceAccount.createdAt == 1750494142);
    assert(list.data[3].owner.get!(ProjectApiKeyOwnerServiceAccount).serviceAccount.role == "owner");
}
