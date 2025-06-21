module openai.administration.project_service_accounts;

import mir.serde;
import mir.serde : serdeEnumProxy;
import mir.string_map;
import mir.algebraic;

@safe:

struct ProjectServiceAccount
{
    string object;
    string id;
    string name;
    string role;
    @serdeKeys("created_at") long createdAt;
}

@serdeIgnoreUnexpectedKeys
struct ProjectServiceAccountApiKey
{
    string object;
    string value;
    string name;
    @serdeKeys("created_at") long createdAt;
    string id;
}

struct CreateProjectServiceAccountRequest
{
    string name;
}

/// Convenience constructor for `CreateProjectServiceAccountRequest`.
CreateProjectServiceAccountRequest createProjectServiceAccountRequest(string name)
{
    auto req = CreateProjectServiceAccountRequest();
    req.name = name;
    return req;
}

@serdeIgnoreUnexpectedKeys
struct CreateProjectServiceAccountResponse
{
    string object;
    string id;
    string name;
    string role;
    @serdeKeys("created_at") long createdAt;
    @serdeKeys("api_key") ProjectServiceAccountApiKey apiKey;
}

@serdeIgnoreUnexpectedKeys
struct ProjectServiceAccountDeleteResponse
{
    string object;
    string id;
    bool deleted;
}

@serdeIgnoreUnexpectedKeys
struct ProjectServiceAccountListResponse
{
    string object;
    ProjectServiceAccount[] data;
    @serdeKeys("first_id") string firstId;
    @serdeKeys("last_id") string lastId;
    @serdeKeys("has_more") bool hasMore;
}

struct ListProjectServiceAccountsRequest
{
    @serdeOptional @serdeIgnoreDefault uint limit;
    @serdeOptional @serdeIgnoreDefault string after;
}

/// Convenience constructor for `ListProjectServiceAccountsRequest`.
ListProjectServiceAccountsRequest listProjectServiceAccountsRequest(uint limit)
{
    auto req = ListProjectServiceAccountsRequest();
    req.limit = limit;
    return req;
}

unittest
{
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    enum listExample =
        `{"object":"list","data":[{"object":"organization.project.service_account","id":"svc_acct_abc","name":"Service Account","role":"owner","created_at":1711471533}],"first_id":"svc_acct_abc","last_id":"svc_acct_xyz","has_more":false}`;
    auto list = deserializeJson!ProjectServiceAccountListResponse(listExample);
    assert(list.data.length == 1);
    assert(list.data[0].name == "Service Account");

    enum createExample =
        `{"object":"organization.project.service_account","id":"svc_acct_abc","name":"Production App","role":"member","created_at":1711471533,"api_key":{"object":"organization.project.service_account.api_key","value":"sk-abcdefghijklmnop123","name":"Secret Key","created_at":1711471533,"id":"key_abc"}}`;
    auto create = deserializeJson!CreateProjectServiceAccountResponse(createExample);
    assert(create.apiKey.id == "key_abc");

    enum delExample =
        `{"object":"organization.project.service_account.deleted","id":"svc_acct_abc","deleted":true}`;
    auto del = deserializeJson!ProjectServiceAccountDeleteResponse(delExample);
    assert(del.deleted);

    auto lreq = listProjectServiceAccountsRequest(5);
    assert(serializeJson(lreq) == `{"limit":5}`);
    auto creq = createProjectServiceAccountRequest("My SA");
    assert(serializeJson(creq) == `{"name":"My SA"}`);
}
