module openai.administration.users;

import mir.serde;
import mir.serde : serdeEnumProxy;
import mir.string_map;
import mir.algebraic;

@safe:

@serdeEnumProxy!string enum ProjectUserRole : string
{
    Owner = "owner",
    Member = "member",
}

@serdeIgnoreUnexpectedKeys
struct ProjectUser
{
    string object;
    string id;
    string name;
    string email;
    ProjectUserRole role;
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

struct CreateProjectUserRequest
{
    @serdeKeys("user_id") string userId;
    ProjectUserRole role;
}

/// Convenience constructor for `CreateProjectUserRequest`.
CreateProjectUserRequest createProjectUserRequest(string userId, ProjectUserRole role)
{
    auto req = CreateProjectUserRequest();
    req.userId = userId;
    req.role = role;
    return req;
}

struct UpdateProjectUserRequest
{
    ProjectUserRole role;
}

/// Convenience constructor for `UpdateProjectUserRequest`.
UpdateProjectUserRequest updateProjectUserRequest(ProjectUserRole role)
{
    auto req = UpdateProjectUserRequest();
    req.role = role;
    return req;
}

@serdeIgnoreUnexpectedKeys
struct DeleteProjectUserResponse
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

struct UpdateUserRoleRequest
{
    ProjectUserRole role;
}

/// Convenience constructor for `UpdateUserRoleRequest`.
UpdateUserRoleRequest updateUserRoleRequest(ProjectUserRole role)
{
    auto req = UpdateUserRoleRequest();
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
    auto role = updateUserRoleRequest(ProjectUserRole.Owner);
    assert(serializeJson(role) == `{"role":"owner"}`);
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
    auto del = deserializeJson!DeleteProjectUserResponse(delExample);
    assert(del.deleted);

    auto lreq = listProjectUsersRequest(5);
    assert(serializeJson(lreq) == `{"limit":5}`);
    auto creq = createProjectUserRequest("user_abc", ProjectUserRole.Member);
    assert(serializeJson(creq) == `{"user_id":"user_abc","role":"member"}`);
    auto ureq = updateProjectUserRequest(ProjectUserRole.Owner);
    assert(serializeJson(ureq) == `{"role":"owner"}`);
}
