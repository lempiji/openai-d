module openai.administration;

import mir.serde;
import mir.string_map;
import std.typecons : Nullable;

@safe:

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
    @serdeOptional string after;
    @serdeOptional uint limit;
}

struct CreateAdminApiKeyRequest
{
    string name;
}

@serdeIgnoreUnexpectedKeys
struct DeleteAdminApiKeyResponse
{
    string id;
    string object;
    bool deleted;
}

@serdeIgnoreUnexpectedKeys
struct Project
{
    string id;
    string object;
    string name;
    @serdeKeys("created_at") long createdAt;
    @serdeOptional @serdeKeys("archived_at") Nullable!long archivedAt;
    string status;
}

@serdeIgnoreUnexpectedKeys
struct ProjectListResponse
{
    string object;
    Project[] data;
    @serdeKeys("first_id") string firstId;
    @serdeKeys("last_id") string lastId;
    @serdeKeys("has_more") bool hasMore;
}

struct ListProjectsRequest
{
    @serdeOptional uint limit;
    @serdeOptional string after;
    @serdeOptional @serdeKeys("include_archived") bool includeArchived;
}

struct ProjectCreateRequest
{
    string name;
}

struct ProjectUpdateRequest
{
    string name;
}

@serdeIgnoreUnexpectedKeys
struct CertificateDetails
{
    @serdeKeys("valid_at") long validAt;
    @serdeKeys("expires_at") long expiresAt;
    @serdeOptional string content;
}

@serdeIgnoreUnexpectedKeys
struct Certificate
{
    string object;
    string id;
    string name;
    bool active;
    @serdeKeys("created_at") long createdAt;
    @serdeKeys("certificate_details") CertificateDetails certificateDetails;
}

@serdeIgnoreUnexpectedKeys
struct ListCertificatesResponse
{
    string object;
    Certificate[] data;
    @serdeKeys("first_id") string firstId;
    @serdeKeys("last_id") string lastId;
    @serdeKeys("has_more") bool hasMore;
}

struct ToggleCertificatesRequest
{
    string[] data;
}

struct ModifyCertificateRequest
{
    string name;
}

@serdeIgnoreUnexpectedKeys
struct DeleteCertificateResponse
{
    string object;
    string id;
}

@serdeIgnoreUnexpectedKeys
struct AuditLog
{
    string id;
    string type;
    @serdeKeys("effective_at") long effectiveAt;
}

@serdeIgnoreUnexpectedKeys
struct ListAuditLogsResponse
{
    string object;
    AuditLog[] data;
    @serdeKeys("first_id") string firstId;
    @serdeKeys("last_id") string lastId;
    @serdeKeys("has_more") bool hasMore;
}

struct ListAuditLogsRequest
{
    @serdeOptional string[] projectIds;
    @serdeOptional string[] eventTypes;
    @serdeOptional string[] actorIds;
    @serdeOptional uint limit;
    @serdeOptional string after;
    @serdeOptional string before;
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
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    ProjectCreateRequest req;
    req.name = "proj";
    auto js = serializeJson(req);
    assert(js == `{"name":"proj"}`);
    auto back = deserializeJson!ProjectCreateRequest(js);
    assert(back.name == "proj");
}
