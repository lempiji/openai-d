module openai.administration.invites;

import mir.serde;
import mir.serde : serdeEnumProxy;
import mir.string_map;
import mir.algebraic;

@safe:

@serdeEnumProxy!string enum InviteStatus : string
{
    Accepted = "accepted",
    Expired = "expired",
    Pending = "pending",
}

struct InviteProject
{
    string id;
    string role;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("object", "organization.invite")
struct Invite
{
    string id;
    string email;
    string role;
    @serdeOptional @serdeKeys("created_at") long createdAt;
    @serdeKeys("expires_at") long expiresAt;
    @serdeOptional @serdeKeys("accepted_at") Nullable!long acceptedAt;
    InviteStatus status;
    @serdeOptional @serdeIgnoreDefault InviteProject[] projects;
}

@serdeIgnoreUnexpectedKeys
struct ListInviteResponse
{
    string object;
    Invite[] data;
    @serdeOptional @serdeKeys("first_id") string firstId;
    @serdeOptional @serdeKeys("last_id") string lastId;
    @serdeKeys("has_more") bool hasMore;
}

@serdeIgnoreUnexpectedKeys
struct DeleteInviteResponse
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

/// ditto
ListInvitesRequest listInvitesRequest(uint limit, string after)
{
    auto req = listInvitesRequest(limit);
    req.after = after;
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
    auto list = deserializeJson!ListInviteResponse(example);
    assert(list.data.length == 1);
    assert(list.data[0].id == "invite-abc");

    auto req = inviteRequest("user@example.com", "owner");
    assert(serializeJson(req) == `{"email":"user@example.com","role":"owner"}`);
}

unittest
{
    import mir.ser.json : serializeJson;

    auto req = listInvitesRequest(5, "next");
    assert(serializeJson(req) == `{"limit":5,"after":"next"}`);
}

unittest
{
    enum json = `{
  "object": "list",
  "data": [
    {
      "object": "organization.invite",
      "id": "invite-id",
      "email": "user@example.com",
      "role": "owner",
      "created_at": 1750481517,
      "expires_at": 1751086317,
      "accepted_at": null,
      "status": "pending",
      "projects": []
    }
  ],
  "first_id": "invite-id",
  "last_id": "invite-id",
  "has_more": false
}`;
    import mir.deser.json : deserializeJson;

    auto list = deserializeJson!ListInviteResponse(json);
    assert(list.data.length == 1);
    assert(list.data[0].id == "invite-id");
    assert(list.data[0].email == "user@example.com");
    assert(list.data[0].role == "owner");
    assert(list.data[0].status == InviteStatus.Pending);
    assert(list.data[0].createdAt == 1_750_481_517);
    assert(list.data[0].expiresAt == 1_751_086_317);
    assert(list.data[0].acceptedAt.isNull);
    assert(list.data[0].projects.length == 0);
    assert(list.firstId == "invite-id");
    assert(list.lastId == "invite-id");
    assert(!list.hasMore);
}
