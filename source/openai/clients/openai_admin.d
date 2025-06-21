module openai.clients.openai_admin;

import std.net.curl;
import std.format;
import std.uri;
import std.exception : enforce;
import mir.deser.json;
import mir.ser.json;

import openai.administration;
import openai.responses;
import openai.clients.config : OpenAIClientConfig;

import openai.clients.helpers; // for ClientHelpers mixin

@safe:

class OpenAIAdminClient
{
    OpenAIClientConfig config;

    this()
    {
        this.config = OpenAIClientConfig.fromEnvironment();
        config.validate();
        enforce(!config.isAzure, "Administration API is not supported on Azure");
    }

    this(OpenAIClientConfig config)
    in (config !is null)
    {
        this.config = config;
        this.config.validate();
        enforce(!this.config.isAzure, "Administration API is not supported on Azure");
    }

    string buildListAuditLogsUrl(in ListAuditLogsRequest request) const @safe
    {
        auto b = QueryParamsBuilder(buildUrl("/organization/audit_logs"));
        foreach (eventType; request.eventTypes)
        {
            b.add("event_types[]", eventType);
        }
        foreach (projectId; request.projectIds)
        {
            b.add("project_ids[]", projectId);
        }
        foreach (actorId; request.actorIds)
        {
            b.add("actor_ids[]", actorId);
        }
        foreach (actorEmail; request.actorEmails)
        {
            b.add("actor_emails[]", actorEmail);
        }
        foreach (resourceId; request.resourceIds)
        {
            b.add("resource_ids[]", resourceId);
        }
        b.add("effective_at[gt]", request.effectiveAt.gt);
        b.add("effective_at[gte]", request.effectiveAt.gte);
        b.add("effective_at[lt]", request.effectiveAt.lt);
        b.add("effective_at[lte]", request.effectiveAt.lte);
        b.add("limit", request.limit);
        b.add("after", request.after);
        return b.finish();
    }

    string buildListUsageUrl(string type, in ListUsageRequest request) const @safe
    {
        auto b = QueryParamsBuilder(buildUrl("/organization/usage/" ~ type));
        b.add("start_time", request.startTime);
        b.add("end_time", request.endTime);
        b.add("bucket_width", request.bucketWidth);
        b.add("project_ids", request.projectIds);
        b.add("user_ids", request.userIds);
        b.add("api_key_ids", request.apiKeyIds);
        b.add("models", request.models);
        b.add("group_by", request.groupBy);
        b.add("limit", request.limit);
        b.add("page", request.page);
        b.add("batch", request.batch);
        return b.finish();
    }

    string buildListCostsUrl(in ListCostsRequest request) const @safe
    {
        auto b = QueryParamsBuilder(buildUrl("/organization/costs"));
        b.add("start_time", request.startTime);
        b.add("end_time", request.endTime);
        b.add("bucket_width", request.bucketWidth);
        b.add("project_ids", request.projectIds);
        b.add("group_by", request.groupBy);
        b.add("limit", request.limit);
        b.add("page", request.page);
        return b.finish();
    }

    string buildListInvitesUrl(in ListInvitesRequest request) const @safe
    {
        auto b = QueryParamsBuilder(buildUrl("/organization/invites"));
        b.add("limit", request.limit);
        b.add("after", request.after);
        return b.finish();
    }

    string buildListUsersUrl(in ListUsersRequest request) const @safe
    {
        auto b = QueryParamsBuilder(buildUrl("/organization/users"));
        b.add("limit", request.limit);
        b.add("after", request.after);
        return b.finish();
    }

    string buildListProjectUsersUrl(string projectId, in ListProjectUsersRequest request) const @safe
    {
        auto b = QueryParamsBuilder(buildUrl("/organization/projects/" ~ projectId ~ "/users"));
        b.add("limit", request.limit);
        b.add("after", request.after);
        return b.finish();
    }

    string buildListProjectServiceAccountsUrl(string projectId, in ListProjectServiceAccountsRequest request) const @safe
    {
        auto b = QueryParamsBuilder(buildUrl("/organization/projects/" ~ projectId ~ "/service_accounts"));
        b.add("limit", request.limit);
        b.add("after", request.after);
        return b.finish();
    }

    string buildListProjectRateLimitsUrl(string projectId, in ListProjectRateLimitsRequest request) const @safe
    {
        auto b = QueryParamsBuilder(buildUrl("/organization/projects/" ~ projectId ~ "/rate_limits"));
        b.add("limit", request.limit);
        b.add("after", request.after);
        return b.finish();
    }

    string buildListAdminApiKeysUrl(in ListAdminApiKeysRequest req) const @safe
    {
        auto b = QueryParamsBuilder(buildUrl("/organization/admin_api_keys"));
        b.add("limit", req.limit);
        b.add("after", req.after);
        return b.finish();
    }

    string buildListProjectsUrl(in ListProjectsRequest req) const @safe
    {
        auto b = QueryParamsBuilder(buildUrl("/organization/projects"));
        b.add("limit", req.limit);
        b.add("after", req.after);
        b.add("include_archived", req.includeArchived);
        return b.finish();
    }

public:
    mixin ClientHelpers;
    /// List organization and project admin API keys.
    AdminApiKeyListResponse listAdminApiKeys(in ListAdminApiKeysRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListAdminApiKeysUrl(request);

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        auto result = content.deserializeJson!AdminApiKeyListResponse();
        return result;
    }

    /// Create an admin API key.
    AdminApiKey createAdminApiKey(in CreateAdminApiKeyRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto body = serializeJson(request);
        auto content = cast(char[]) post!ubyte(buildUrl("/organization/admin_api_keys"), body, http);
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Failed to create admin API key. Response: ", content);
        }
        return content.deserializeJson!AdminApiKey();
    }

    /// Retrieve an admin API key by ID.
    AdminApiKey getAdminApiKey(string keyId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (keyId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        auto content = cast(char[]) get!(HTTP, ubyte)(buildUrl("/organization/admin_api_keys/" ~ keyId), http);
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Failed to retrieve admin API key. Response: ", content);
        }
        return content.deserializeJson!AdminApiKey();
    }

    /// Delete an admin API key.
    DeleteAdminApiKeyResponse deleteAdminApiKey(string keyId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (keyId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        import std.array : appender;

        auto buf = appender!(char[])();
        http.url = buildUrl("/organization/admin_api_keys/" ~ keyId);
        http.method = HTTP.Method.del;
        http.onReceive = (ubyte[] data) { buf.put(cast(char[]) data); return data.length; };
        http.perform();
        auto content = buf.data;
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Failed to delete admin API key. Response: ", content);
        }
        if (content.length == 0)
        {
            return DeleteAdminApiKeyResponse.init; // Return an empty response if no content
        }
        return content.deserializeJson!DeleteAdminApiKeyResponse();
    }

    /// List invites for the organization.
    InviteListResponse listInvites(in ListInvitesRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListInvitesUrl(request);

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Failed to list invites. Response: ", content);
        }
        return content.deserializeJson!InviteListResponse();
    }

    /// Create an invite.
    Invite createInvite(in InviteRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto body = serializeJson(request);
        auto content = cast(char[]) post!ubyte(buildUrl("/organization/invites"), body, http);
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Failed to create invite. Response: ", content);
        }
        return content.deserializeJson!Invite();
    }

    /// Retrieve an invite by ID.
    Invite retrieveInvite(string inviteId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (inviteId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        auto content = cast(char[]) get!(HTTP, ubyte)(buildUrl("/organization/invites/" ~ inviteId), http);
        return content.deserializeJson!Invite();
    }

    /// Delete an invite.
    InviteDeleteResponse deleteInvite(string inviteId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (inviteId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        import std.array : appender;

        auto buf = appender!(char[])();
        http.url = buildUrl("/organization/invites/" ~ inviteId);
        http.method = HTTP.Method.del;
        http.onReceive = (ubyte[] data) { buf.put(cast(char[]) data); return data.length; };
        http.perform();
        auto content = buf.data;
        return content.deserializeJson!InviteDeleteResponse();
    }

    /// List users.
    UserListResponse listUsers(in ListUsersRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListUsersUrl(request);

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        return content.deserializeJson!UserListResponse();
    }

    /// Retrieve a user by ID.
    User retrieveUser(string userId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (userId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        auto content = cast(char[]) get!(HTTP, ubyte)(buildUrl("/organization/users/" ~ userId), http);
        return content.deserializeJson!User();
    }

    /// Modify a user.
    User modifyUser(string userId, in UpdateUserRoleRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (userId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto body = serializeJson(request);
        auto content = cast(char[]) post!ubyte(buildUrl("/organization/users/" ~ userId), body, http);
        return content.deserializeJson!User();
    }

    /// Delete a user.
    UserDeleteResponse deleteUser(string userId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (userId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        import std.array : appender;

        auto buf = appender!(char[])();
        http.url = buildUrl("/organization/users/" ~ userId);
        http.method = HTTP.Method.del;
        http.onReceive = (ubyte[] data) { buf.put(cast(char[]) data); return data.length; };
        http.perform();
        auto content = buf.data;
        return content.deserializeJson!UserDeleteResponse();
    }

    /// List audit logs for the organization.
    ListAuditLogsResponse listAuditLogs(in ListAuditLogsRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        import std.format : format;
        import std.algorithm : map;
        import std.conv : to;
        import std.uri : encodeComponent;

        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListAuditLogsUrl(request);
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Audit logs URL: ", url);
        }

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Failed to list audit logs. Response: ", content);
        }
        return content.deserializeJson!ListAuditLogsResponse();
    }

    /// List projects.
    ProjectListResponse listProjects(in ListProjectsRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListProjectsUrl(request);

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        return content.deserializeJson!ProjectListResponse();
    }

    /// Create a project.
    Project createProject(in CreateProjectRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto body = serializeJson(request);
        auto content = cast(char[]) post!ubyte(buildUrl("/organization/projects"), body, http);
        return content.deserializeJson!Project();
    }

    /// Retrieve a project by ID.
    Project retrieveProject(string projectId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        auto content = cast(char[]) get!(HTTP, ubyte)(buildUrl("/organization/projects/" ~ projectId), http);
        return content.deserializeJson!Project();
    }

    /// Modify a project.
    Project modifyProject(string projectId, in ModifyProjectRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto body = serializeJson(request);
        auto content = cast(char[]) post!ubyte(buildUrl("/organization/projects/" ~ projectId), body, http);
        return content.deserializeJson!Project();
    }

    /// Archive a project.
    Project archiveProject(string projectId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        auto content = cast(char[]) post!ubyte(buildUrl("/organization/projects/" ~ projectId ~ "/archive"), "{}", http);
        return content.deserializeJson!Project();
    }

    /// List users in a project.
    ProjectUserListResponse listProjectUsers(string projectId, in ListProjectUsersRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListProjectUsersUrl(projectId, request);

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        return content.deserializeJson!ProjectUserListResponse();
    }

    /// Add a user to a project.
    ProjectUser createProjectUser(string projectId, in CreateProjectUserRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto url = buildUrl("/organization/projects/" ~ projectId ~ "/users");
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Creating project user: ", url);
        }
        auto body = serializeJson(request);
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Request body: ", body);
        }
        auto content = cast(char[]) post!ubyte(url, body, http);
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Failed to create project user. Response: ", content);
        }
        return content.deserializeJson!ProjectUser();
    }

    /// Retrieve a project user by ID.
    ProjectUser retrieveProjectUser(string projectId, string userId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    in (userId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        auto content = cast(char[]) get!(HTTP, ubyte)(
            buildUrl("/organization/projects/" ~ projectId ~ "/users/" ~ userId), http);
        return content.deserializeJson!ProjectUser();
    }

    /// Modify a project user's role.
    ProjectUser modifyProjectUser(string projectId, string userId, in UpdateProjectUserRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    in (userId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto body = serializeJson(request);
        auto content = cast(char[]) post!ubyte(buildUrl("/organization/projects/" ~ projectId ~ "/users/" ~ userId), body, http);
        return content.deserializeJson!ProjectUser();
    }

    /// Delete a user from a project.
    DeleteProjectUserResponse deleteProjectUser(string projectId, string userId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    in (userId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        import std.array : appender;

        auto buf = appender!(char[])();
        http.url = buildUrl("/organization/projects/" ~ projectId ~ "/users/" ~ userId);
        http.method = HTTP.Method.del;
        http.onReceive = (ubyte[] data) { buf.put(cast(char[]) data); return data.length; };
        http.perform();
        auto content = buf.data;
        return content.deserializeJson!DeleteProjectUserResponse();
    }

    /// List service accounts for a project.
    ProjectServiceAccountListResponse listProjectServiceAccounts(string projectId, in ListProjectServiceAccountsRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListProjectServiceAccountsUrl(projectId, request);

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        return content.deserializeJson!ProjectServiceAccountListResponse();
    }

    /// Create a project service account.
    CreateProjectServiceAccountResponse createProjectServiceAccount(string projectId, in CreateProjectServiceAccountRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto body = serializeJson(request);
        auto content = cast(char[]) post!ubyte(
            buildUrl("/organization/projects/" ~ projectId ~ "/service_accounts"), body, http);
        return content.deserializeJson!CreateProjectServiceAccountResponse();
    }

    /// Retrieve a project service account by ID.
    ProjectServiceAccount retrieveProjectServiceAccount(string projectId, string serviceAccountId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    in (serviceAccountId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        auto content = cast(char[]) get!(HTTP, ubyte)(
            buildUrl("/organization/projects/" ~ projectId ~ "/service_accounts/" ~ serviceAccountId), http);
        return content.deserializeJson!ProjectServiceAccount();
    }

    /// Delete a project service account.
    ProjectServiceAccountDeleteResponse deleteProjectServiceAccount(string projectId, string serviceAccountId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    in (serviceAccountId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        import std.array : appender;

        auto buf = appender!(char[])();
        http.url = buildUrl("/organization/projects/" ~ projectId ~ "/service_accounts/" ~ serviceAccountId);
        http.method = HTTP.Method.del;
        http.onReceive = (ubyte[] data) { buf.put(cast(char[]) data); return data.length; };
        http.perform();
        auto content = buf.data;
        return content.deserializeJson!ProjectServiceAccountDeleteResponse();
    }

    /// List API keys for a project.
    ProjectApiKeyListResponse listProjectApiKeys(string projectId, in ListProjectApiKeysRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        import std.format : format;
        import std.uri : encodeComponent;

        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildUrl("/organization/projects/" ~ projectId ~ "/api_keys");
        string sep = "?";
        if (request.limit)
            url ~= format("%slimit=%s", sep, request.limit), sep = "&";
        if (request.after.length)
            url ~= format("%safter=%s", sep, encodeComponent(request.after));
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Project API keys URL: ", url);
        }
        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Failed to list project API keys. Response: ", content);
        }
        return content.deserializeJson!ProjectApiKeyListResponse();
    }

    /// Retrieve a project API key by ID.
    ProjectApiKey retrieveProjectApiKey(string projectId, string keyId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (keyId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        auto content = cast(char[]) get!(HTTP, ubyte)(
            buildUrl("/organization/projects/" ~ projectId ~ "/api_keys/" ~ keyId), http);
        return content.deserializeJson!ProjectApiKey();
    }

    /// Delete a project API key.
    DeleteProjectApiKeyResponse deleteProjectApiKey(string projectId, string keyId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (keyId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        auto url = buildUrl("/organization/projects/" ~ projectId ~ "/api_keys/" ~ keyId);
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Deleting project API key: ", url);
        }
        http.url = url;
        http.method = HTTP.Method.del;
        import std.array : appender;

        auto buf = appender!(char[])();
        http.onReceive = (ubyte[] data) { buf.put(cast(char[]) data); return data.length; };
        http.perform();
        auto content = buf.data;
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Failed to delete project API key. Response: ", content);
        }
        return content.deserializeJson!DeleteProjectApiKeyResponse();
    }

    /// List rate limits for a project.
    ProjectRateLimitListResponse listProjectRateLimits(string projectId, in ListProjectRateLimitsRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListProjectRateLimitsUrl(projectId, request);
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Project rate limits URL: ", url);
        }

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Failed to list project rate limits. Response: ", content);
        }

        return content.deserializeJson!ProjectRateLimitListResponse();
    }

    /// Create a project rate limit.
    ProjectRateLimit createProjectRateLimit(string projectId, in CreateProjectRateLimitRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto url = buildUrl("/organization/projects/" ~ projectId ~ "/rate_limits");
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Creating project rate limit: ", url);
        }
        auto body = serializeJson(request);
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Request body: ", body);
        }
        auto content = cast(char[]) post!ubyte(url, body, http);
        return content.deserializeJson!ProjectRateLimit();
    }

    /// Modify a project rate limit.
    ProjectRateLimit modifyProjectRateLimit(string projectId, string limitId, in ModifyProjectRateLimitRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (limitId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto body = serializeJson(request);
        auto content = cast(char[]) post!ubyte(
            buildUrl("/organization/projects/" ~ projectId ~ "/rate_limits/" ~ limitId), body, http);
        return content.deserializeJson!ProjectRateLimit();
    }

    /// List organization certificates.
    ListCertificatesResponse listCertificates() @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        auto content = cast(char[]) get!(HTTP, ubyte)(buildUrl("/organization/certificates"), http);
        return content.deserializeJson!ListCertificatesResponse();
    }

    /// Activate organization certificates.
    ListCertificatesResponse activateCertificates(in ToggleCertificatesRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto body = serializeJson(request);
        auto content = cast(char[]) post!ubyte(buildUrl("/organization/certificates/activate"), body, http);
        return content.deserializeJson!ListCertificatesResponse();
    }

    /// Deactivate organization certificates.
    ListCertificatesResponse deactivateCertificates(in ToggleCertificatesRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto body = serializeJson(request);
        auto content = cast(char[]) post!ubyte(buildUrl("/organization/certificates/deactivate"), body, http);
        return content.deserializeJson!ListCertificatesResponse();
    }

    /// Modify a certificate.
    Certificate modifyCertificate(string certificateId, in ModifyCertificateRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (certificateId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto body = serializeJson(request);
        auto content = cast(char[]) post!ubyte(buildUrl("/organization/certificates/" ~ certificateId), body, http);
        return content.deserializeJson!Certificate();
    }

    /// List cost reports for the organization.
    UsageResponse listCosts(in ListCostsRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListCostsUrl(request);
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Costs URL: ", url);
        }

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        debug scope (exit)
        {
            import std.stdio : writeln;

            writeln("Failed to list costs. Response: ", content);
        }

        return content.deserializeJson!UsageResponse();
    }

    /// List usage reports for a specific type.
    UsageResponse listUsageCompletions(in ListUsageRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListUsageUrl("completions", request);
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Usage completions URL: ", url);
        }

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        debug scope (failure)
        {
            import std.stdio : writeln;

            writeln("Failed to list usage completions. Response: ", content);
        }

        return content.deserializeJson!UsageResponse();
    }

    ///
    UsageResponse listUsageEmbeddings(in ListUsageRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListUsageUrl("embeddings", request);

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        return content.deserializeJson!UsageResponse();
    }

    ///
    UsageResponse listUsageImages(in ListUsageRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListUsageUrl("images", request);

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        return content.deserializeJson!UsageResponse();
    }

    ///
    UsageResponse listUsageModerations(in ListUsageRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListUsageUrl("moderations", request);

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        return content.deserializeJson!UsageResponse();
    }

    ///
    UsageResponse listUsageAudioSpeeches(in ListUsageRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListUsageUrl("audio_speeches", request);

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        return content.deserializeJson!UsageResponse();
    }

    ///
    UsageResponse listUsageAudioTranscriptions(in ListUsageRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListUsageUrl("audio_transcriptions", request);

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        return content.deserializeJson!UsageResponse();
    }

    ///
    UsageResponse listUsageVectorStores(in ListUsageRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListUsageUrl("vector_stores", request);

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        return content.deserializeJson!UsageResponse();
    }

    ///
    UsageResponse listUsageCodeInterpreterSessions(in ListUsageRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListUsageUrl("code_interpreter_sessions", request);

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        return content.deserializeJson!UsageResponse();
    }
}

@("buildUrl helper")
unittest
{
    import std.typecons : tuple;

    void checkUrl(string desc, string path, string expected)
    {
        auto cfg = new OpenAIClientConfig;
        cfg.apiKey = "k";
        auto client = new OpenAIAdminClient(cfg);
        assert(client.buildUrl(path) == expected, desc);
    }

    foreach (t; [
        tuple("audit logs", "/organization/audit_logs",
            "https://api.openai.com/v1/organization/audit_logs"),
        tuple("usage", "/organization/usage/completions",
            "https://api.openai.com/v1/organization/usage/completions"),
        tuple("projects", "/organization/projects",
            "https://api.openai.com/v1/organization/projects")
    ])
    {
        checkUrl(t[0], t[1], t[2]);
    }
}

@("buildListAuditLogsUrl encodes new query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIAdminClient(cfg);

    AuditLogTimeRange range;
    range.gt = 10;
    range.lte = 20;

    auto req = listAuditLogsRequest(5, null, null, null, ["a@example.com"],
        ["res id"], range);
    auto url = client.buildListAuditLogsUrl(req);

    assert(url.canFind("actor_emails[]=a%40example.com"));
    assert(url.canFind("resource_ids[]=res%20id"));
    assert(url.canFind("effective_at[gt]=10"));
    assert(url.canFind("effective_at[lte]=20"));
}

@("buildListUsageUrl encodes query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIAdminClient(cfg);

    auto req = listUsageRequest(1);
    req.bucketWidth = "day";
    req.projectIds = ["p id"];
    req.userIds = ["u id"];
    req.apiKeyIds = ["key id"];
    req.models = ["gpt 4"];
    req.groupBy = ["project_id"];
    req.limit = 3;
    req.page = "foo bar";
    req.batch = true;
    auto url = client.buildListUsageUrl("completions", req);

    assert(url.canFind("start_time=1"));
    assert(url.canFind("bucket_width=day"));
    assert(url.canFind("project_ids=p%20id"));
    assert(url.canFind("user_ids=u%20id"));
    assert(url.canFind("api_key_ids=key%20id"));
    assert(url.canFind("models=gpt%204"));
    assert(url.canFind("group_by=project_id"));
    assert(url.canFind("limit=3"));
    assert(url.canFind("page=foo%20bar"));
    assert(url.canFind("batch=true"));
}

@("buildListCostsUrl encodes query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIAdminClient(cfg);

    auto req = listCostsRequest(2);
    req.bucketWidth = "month";
    req.projectIds = ["p id"];
    req.groupBy = ["project_id"];
    req.limit = 5;
    req.page = "bar+baz";
    auto url = client.buildListCostsUrl(req);

    assert(url.canFind("start_time=2"));
    assert(url.canFind("bucket_width=month"));
    assert(url.canFind("project_ids=p%20id"));
    assert(url.canFind("group_by=project_id"));
    assert(url.canFind("limit=5"));
    assert(url.canFind("page=bar%2Bbaz"));
}

@("buildListInvitesUrl")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIAdminClient(cfg);

    auto req = ListInvitesRequest();
    auto url = client.buildListInvitesUrl(req);

    assert(!url.canFind("limit="));
    assert(!url.canFind("after="));

    req.limit = 2;
    url = client.buildListInvitesUrl(req);
    assert(url.canFind("limit=2"));

    req.limit = 0;
    req.after = "foo";
    url = client.buildListInvitesUrl(req);
    assert(url.canFind("after=foo"));
    assert(!url.canFind("limit="));
}

@("buildListInvitesUrl encodes query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIAdminClient(cfg);

    auto req = ListInvitesRequest();
    req.limit = 3;
    req.after = "foo bar";
    auto url = client.buildListInvitesUrl(req);

    assert(url.canFind("limit=3"));
    assert(url.canFind("after=foo%20bar"));
}

@("buildListProjectServiceAccountsUrl")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIAdminClient(cfg);

    auto req = ListProjectServiceAccountsRequest();
    auto url = client.buildListProjectServiceAccountsUrl("p", req);

    assert(!url.canFind("limit="));
    assert(!url.canFind("after="));

    req.limit = 2;
    url = client.buildListProjectServiceAccountsUrl("p", req);
    assert(url.canFind("limit=2"));

    req.limit = 0;
    req.after = "foo";
    url = client.buildListProjectServiceAccountsUrl("p", req);
    assert(url.canFind("after=foo"));
    assert(!url.canFind("limit="));
}

@("buildListProjectServiceAccountsUrl encodes query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIAdminClient(cfg);

    auto req = ListProjectServiceAccountsRequest();
    req.limit = 3;
    req.after = "foo bar";
    auto url = client.buildListProjectServiceAccountsUrl("p", req);

    assert(url.canFind("limit=3"));
    assert(url.canFind("after=foo%20bar"));
}

@("buildListProjectRateLimitsUrl")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIAdminClient(cfg);

    auto req = ListProjectRateLimitsRequest();
    auto url = client.buildListProjectRateLimitsUrl("p", req);

    assert(!url.canFind("limit="));
    assert(!url.canFind("after="));

    req.limit = 2;
    url = client.buildListProjectRateLimitsUrl("p", req);
    assert(url.canFind("limit=2"));

    req.limit = 0;
    req.after = "foo";
    url = client.buildListProjectRateLimitsUrl("p", req);
    assert(url.canFind("after=foo"));
    assert(!url.canFind("limit="));
}

@("buildListProjectRateLimitsUrl encodes query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIAdminClient(cfg);

    auto req = ListProjectRateLimitsRequest();
    req.limit = 3;
    req.after = "foo bar";
    auto url = client.buildListProjectRateLimitsUrl("p", req);

    assert(url.canFind("limit=3"));
    assert(url.canFind("after=foo%20bar"));
}

@("buildListUsersUrl")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIAdminClient(cfg);

    auto req = ListUsersRequest();
    auto url = client.buildListUsersUrl(req);

    assert(!url.canFind("limit="));
    assert(!url.canFind("after="));

    req.limit = 2;
    url = client.buildListUsersUrl(req);
    assert(url.canFind("limit=2"));

    req.limit = 0;
    req.after = "foo";
    url = client.buildListUsersUrl(req);
    assert(url.canFind("after=foo"));
    assert(!url.canFind("limit="));
}

@("buildListUsersUrl encodes query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIAdminClient(cfg);

    auto req = ListUsersRequest();
    req.limit = 3;
    req.after = "foo bar";
    auto url = client.buildListUsersUrl(req);

    assert(url.canFind("limit=3"));
    assert(url.canFind("after=foo%20bar"));
}

@("buildListProjectUsersUrl")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIAdminClient(cfg);

    auto req = ListProjectUsersRequest();
    auto url = client.buildListProjectUsersUrl("p", req);

    assert(!url.canFind("limit="));
    assert(!url.canFind("after="));

    req.limit = 2;
    url = client.buildListProjectUsersUrl("p", req);
    assert(url.canFind("limit=2"));

    req.limit = 0;
    req.after = "foo";
    url = client.buildListProjectUsersUrl("p", req);
    assert(url.canFind("after=foo"));
    assert(!url.canFind("limit="));
}

@("buildListProjectUsersUrl encodes query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIAdminClient(cfg);

    auto req = ListProjectUsersRequest();
    req.limit = 3;
    req.after = "foo bar";
    auto url = client.buildListProjectUsersUrl("p", req);

    assert(url.canFind("limit=3"));
    assert(url.canFind("after=foo%20bar"));
}

@("buildListAdminApiKeysUrl")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIAdminClient(cfg);

    auto req = ListAdminApiKeysRequest();
    auto url = client.buildListAdminApiKeysUrl(req);

    assert(!url.canFind("limit="));
    assert(!url.canFind("after="));

    req.limit = 2;
    url = client.buildListAdminApiKeysUrl(req);
    assert(url.canFind("limit=2"));

    req.limit = 0;
    req.after = "foo";
    url = client.buildListAdminApiKeysUrl(req);
    assert(url.canFind("after=foo"));
    assert(!url.canFind("limit="));
}

@("buildListAdminApiKeysUrl encodes query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIAdminClient(cfg);

    auto req = ListAdminApiKeysRequest();
    req.limit = 3;
    req.after = "foo bar";
    auto url = client.buildListAdminApiKeysUrl(req);

    assert(url.canFind("limit=3"));
    assert(url.canFind("after=foo%20bar"));
}

@("buildListProjectsUrl")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIAdminClient(cfg);

    auto req = ListProjectsRequest();
    auto url = client.buildListProjectsUrl(req);

    assert(!url.canFind("limit="));
    assert(!url.canFind("after="));
    assert(!url.canFind("include_archived="));

    req.limit = 2;
    url = client.buildListProjectsUrl(req);
    assert(url.canFind("limit=2"));

    req.limit = 0;
    req.after = "foo";
    req.includeArchived = true;
    url = client.buildListProjectsUrl(req);
    assert(url.canFind("after=foo"));
    assert(url.canFind("include_archived=true"));
    assert(!url.canFind("limit="));
}

@("buildListProjectsUrl encodes query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIAdminClient(cfg);

    auto req = ListProjectsRequest();
    req.limit = 3;
    req.after = "foo bar";
    req.includeArchived = true;
    auto url = client.buildListProjectsUrl(req);

    assert(url.canFind("limit=3"));
    assert(url.canFind("after=foo%20bar"));
    assert(url.canFind("include_archived=true"));
}
