module openai.administration.users;

import mir.serde;
import mir.serde : serdeEnumProxy;
import mir.string_map;
import std.typecons : Nullable;
import mir.algebraic;

@safe:

@serdeIgnoreUnexpectedKeys
struct ProjectUser
{
    string object;
    string id;
    string name;
    string email;
    string role;
    @serdeKeys("added_at") long addedAt;
}

@serdeIgnoreUnexpectedKeys
struct ProjectUserListResponse
{
    string object;
    ProjectUser[] data;
    @serdeKeys("first_id") string firstId;
    @serdeKeys("last_id") string lastId;
    @serdeKeys("has_more") bool hasMore;
}

struct ProjectUserCreateRequest
{
    @serdeKeys("user_id") string userId;
    string role;
}

/// Convenience constructor for `ProjectUserCreateRequest`.
ProjectUserCreateRequest projectUserCreateRequest(string userId, string role)
{
    auto req = ProjectUserCreateRequest();
    req.userId = userId;
    req.role = role;
    return req;
}

struct ProjectUserUpdateRequest
{
    string role;
}

/// Convenience constructor for `ProjectUserUpdateRequest`.
ProjectUserUpdateRequest projectUserUpdateRequest(string role)
{
    auto req = ProjectUserUpdateRequest();
    req.role = role;
    return req;
}

@serdeIgnoreUnexpectedKeys
struct ProjectUserDeleteResponse
{
    string object;
    string id;
    bool deleted;
}

@serdeIgnoreUnexpectedKeys
struct User
{
    string object;
    string id;
    string name;
    string email;
    string role;
    @serdeKeys("added_at") long addedAt;
}

@serdeIgnoreUnexpectedKeys
struct UserListResponse
{
    string object;
    User[] data;
    @serdeKeys("first_id") string firstId;
    @serdeKeys("last_id") string lastId;
    @serdeKeys("has_more") bool hasMore;
}

@serdeIgnoreUnexpectedKeys
struct UserDeleteResponse
{
    string object;
    string id;
    bool deleted;
}

struct UserRoleUpdateRequest
{
    string role;
}

/// Convenience constructor for `UserRoleUpdateRequest`.
UserRoleUpdateRequest userRoleUpdateRequest(string role)
{
    auto req = UserRoleUpdateRequest();
    req.role = role;
    return req;
}

struct ListUsersRequest
{
    @serdeOptional @serdeIgnoreDefault uint limit;
    @serdeOptional @serdeIgnoreDefault string after;
}

struct ListProjectUsersRequest
{
    @serdeOptional @serdeIgnoreDefault uint limit;
    @serdeOptional @serdeIgnoreDefault string after;
}

/// Convenience constructor for `ListProjectUsersRequest`.
ListProjectUsersRequest listProjectUsersRequest(uint limit)
{
    auto req = ListProjectUsersRequest();
    req.limit = limit;
    return req;
}

/// Convenience constructor for `ListUsersRequest`.
ListUsersRequest listUsersRequest(uint limit)
{
    auto req = ListUsersRequest();
    req.limit = limit;
    return req;
}

unittest
{
    import mir.deser.json : deserializeJson;

    enum example =
        `{"object":"list","data":[{"object":"organization.user","id":"user-1","name":"Alice","email":"a@example.com","role":"owner","added_at":1}],"first_id":"user-1","last_id":"user-1","has_more":false}`;
    auto list = deserializeJson!UserListResponse(example);
    assert(list.data.length == 1);
    assert(list.data[0].name == "Alice");
}

unittest
{
    import mir.ser.json : serializeJson;

    auto req = listUsersRequest(10);
    assert(serializeJson(req) == `{"limit":10}`);
    auto role = userRoleUpdateRequest("admin");
    assert(serializeJson(role) == `{"role":"admin"}`);
}

unittest
{
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    enum listExample =
        `{"object":"list","data":[{"object":"organization.project.user","id":"user_abc","name":"First Last","email":"user@example.com","role":"owner","added_at":1}],"first_id":"user_abc","last_id":"user_abc","has_more":false}`;
    auto list = deserializeJson!ProjectUserListResponse(listExample);
    assert(list.data.length == 1);
    assert(list.data[0].email == "user@example.com");

    enum delExample =
        `{"object":"organization.project.user.deleted","id":"user_abc","deleted":true}`;
    auto del = deserializeJson!ProjectUserDeleteResponse(delExample);
    assert(del.deleted);

    auto lreq = listProjectUsersRequest(5);
    assert(serializeJson(lreq) == `{"limit":5}`);
    auto creq = projectUserCreateRequest("user_abc", "member");
    assert(serializeJson(creq) == `{"user_id":"user_abc","role":"member"}`);
    auto ureq = projectUserUpdateRequest("owner");
    assert(serializeJson(ureq) == `{"role":"owner"}`);
}
