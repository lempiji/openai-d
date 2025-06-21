module openai.administration.projects;

import mir.serde;
import mir.serde : serdeEnumProxy;
import mir.string_map;
import mir.algebraic;

@safe:

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
    @serdeOptional @serdeIgnoreDefault uint limit;
    @serdeOptional @serdeIgnoreDefault string after;
    @serdeOptional @serdeIgnoreDefault @serdeKeys("include_archived") bool includeArchived;
}

/// Convenience constructor for `ListProjectsRequest`.
ListProjectsRequest listProjectsRequest(uint limit, bool includeArchived = false)
{
    auto req = ListProjectsRequest();
    req.limit = limit;
    if (includeArchived)
        req.includeArchived = true;
    return req;
}

struct CreateProjectRequest
{
    string name;
}

/// Convenience constructor for `CreateProjectRequest`.
CreateProjectRequest createProjectRequest(string name)
{
    auto req = CreateProjectRequest();
    req.name = name;
    return req;
}

struct ModifyProjectRequest
{
    string name;
}

/// Convenience constructor for `ModifyProjectRequest`.
ModifyProjectRequest modifyProjectRequest(string name)
{
    auto req = ModifyProjectRequest();
    req.name = name;
    return req;
}

unittest
{
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    CreateProjectRequest req;
    req.name = "proj";
    auto js = serializeJson(req);
    assert(js == `{"name":"proj"}`);
    auto back = deserializeJson!CreateProjectRequest(js);
    assert(back.name == "proj");
}

unittest
{
    import mir.ser.json : serializeJson;

    auto req = listProjectsRequest(10, true);
    assert(serializeJson(req) == `{"limit":10,"include_archived":true}`);
}
