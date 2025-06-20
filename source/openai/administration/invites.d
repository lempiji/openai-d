module openai.administration.invites;

import mir.serde;
import mir.serde : serdeEnumProxy;
import mir.string_map;
import std.typecons : Nullable;
import mir.algebraic;

@safe:

struct InviteProject
{
    string id;
    string role;
}

@serdeIgnoreUnexpectedKeys
struct Invite
{
    string object;
    string id;
    string email;
    string role;
    string status;
    @serdeKeys("invited_at") long invitedAt;
    @serdeKeys("expires_at") long expiresAt;
    @serdeOptional @serdeKeys("accepted_at") long acceptedAt;
    @serdeOptional @serdeIgnoreDefault InviteProject[] projects;
}

@serdeIgnoreUnexpectedKeys
struct InviteListResponse
{
    string object;
    Invite[] data;
    @serdeKeys("first_id") string firstId;
    @serdeKeys("last_id") string lastId;
    @serdeKeys("has_more") bool hasMore;
}

@serdeIgnoreUnexpectedKeys
struct InviteDeleteResponse
{
    string object;
    string id;
    bool deleted;
}

struct ListInvitesRequest
{
    @serdeOptional @serdeIgnoreDefault uint limit;
    @serdeOptional @serdeIgnoreDefault string after;
}

/// Convenience constructor for `ListInvitesRequest`.
ListInvitesRequest listInvitesRequest(uint limit)
{
    auto req = ListInvitesRequest();
    req.limit = limit;
    return req;
}

struct InviteRequest
{
    string email;
    string role;
    @serdeOptional @serdeIgnoreDefault InviteProject[] projects;
}

/// Convenience constructor for `InviteRequest`.
InviteRequest inviteRequest(string email, string role)
{
    auto req = InviteRequest();
    req.email = email;
    req.role = role;
    return req;
}

unittest
{
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    enum example = `{"object":"list","data":[{"object":"organization.invite","id":"invite-abc","email":"user@example.com","role":"owner","status":"accepted","invited_at":1,"expires_at":2,"accepted_at":3}],"first_id":"invite-abc","last_id":"invite-abc","has_more":false}`;
    auto list = deserializeJson!InviteListResponse(example);
    assert(list.data.length == 1);
    assert(list.data[0].id == "invite-abc");

    auto req = inviteRequest("user@example.com", "owner");
    assert(serializeJson(req) == `{"email":"user@example.com","role":"owner"}`);
}
