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

struct EmptyRequest
{
}

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
        auto b = QueryParamsBuilder("/organization/audit_logs");
        b.add("event_types[]", request.eventTypes);
        b.add("project_ids[]", request.projectIds);
        b.add("actor_ids[]", request.actorIds);
        b.add("actor_emails[]", request.actorEmails);
        b.add("resource_ids[]", request.resourceIds);
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
        auto b = QueryParamsBuilder("/organization/usage/" ~ type);
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
        auto b = QueryParamsBuilder("/organization/costs");
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
        auto b = QueryParamsBuilder("/organization/invites");
        b.add("limit", request.limit);
        b.add("after", request.after);
        return b.finish();
    }

    string buildListUsersUrl(in ListUsersRequest request) const @safe
    {
        auto b = QueryParamsBuilder("/organization/users");
        b.add("limit", request.limit);
        b.add("after", request.after);
        return b.finish();
    }

    string buildListProjectUsersUrl(string projectId, in ListProjectUsersRequest request) const @safe
    {
        auto b = QueryParamsBuilder("/organization/projects/" ~ projectId ~ "/users");
        b.add("limit", request.limit);
        b.add("after", request.after);
        return b.finish();
    }

    string buildListProjectServiceAccountsUrl(string projectId, in ListProjectServiceAccountsRequest request) const @safe
    {
        auto b = QueryParamsBuilder("/organization/projects/" ~ projectId ~ "/service_accounts");
        b.add("limit", request.limit);
        b.add("after", request.after);
        return b.finish();
    }

    string buildListProjectRateLimitsUrl(string projectId, in ListProjectRateLimitsRequest request) const @safe
    {
        auto b = QueryParamsBuilder("/organization/projects/" ~ projectId ~ "/rate_limits");
        b.add("limit", request.limit);
        b.add("after", request.after);
        return b.finish();
    }

    string buildListAdminApiKeysUrl(in ListAdminApiKeysRequest req) const @safe
    {
        auto b = QueryParamsBuilder("/organization/admin_api_keys");
        b.add("limit", req.limit);
        b.add("after", req.after);
        return b.finish();
    }

    string buildListProjectsUrl(in ListProjectsRequest req) const @safe
    {
        auto b = QueryParamsBuilder("/organization/projects");
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
        return getJson!AdminApiKeyListResponse(buildListAdminApiKeysUrl(request));
    }

    /// Create an admin API key.
    AdminApiKey createAdminApiKey(in CreateAdminApiKeyRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return postJson!AdminApiKey("/organization/admin_api_keys", request);
    }

    /// Retrieve an admin API key by ID.
    AdminApiKey getAdminApiKey(string keyId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (keyId.length > 0)
    {
        return getJson!AdminApiKey("/organization/admin_api_keys/" ~ keyId);
    }

    /// Delete an admin API key.
    DeleteAdminApiKeyResponse deleteAdminApiKey(string keyId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (keyId.length > 0)
    {
        return deleteJson!DeleteAdminApiKeyResponse("/organization/admin_api_keys/" ~ keyId);
    }

    /// List invites for the organization.
    InviteListResponse listInvites(in ListInvitesRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return getJson!InviteListResponse(buildListInvitesUrl(request));
    }

    /// Create an invite.
    Invite createInvite(in InviteRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return postJson!Invite("/organization/invites", request);
    }

    /// Retrieve an invite by ID.
    Invite retrieveInvite(string inviteId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (inviteId.length > 0)
    {
        return getJson!Invite("/organization/invites/" ~ inviteId);
    }

    /// Delete an invite.
    InviteDeleteResponse deleteInvite(string inviteId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (inviteId.length > 0)
    {
        return deleteJson!InviteDeleteResponse("/organization/invites/" ~ inviteId);
    }

    /// List users.
    UserListResponse listUsers(in ListUsersRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return getJson!UserListResponse(buildListUsersUrl(request));
    }

    /// Retrieve a user by ID.
    User retrieveUser(string userId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (userId.length > 0)
    {
        return getJson!User("/organization/users/" ~ userId);
    }

    /// Modify a user.
    User modifyUser(string userId, in UpdateUserRoleRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (userId.length > 0)
    {
        return postJson!User("/organization/users/" ~ userId, request);
    }

    /// Delete a user.
    UserDeleteResponse deleteUser(string userId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (userId.length > 0)
    {
        return deleteJson!UserDeleteResponse("/organization/users/" ~ userId);
    }

    /// List audit logs for the organization.
    ListAuditLogsResponse listAuditLogs(in ListAuditLogsRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return getJson!ListAuditLogsResponse(buildListAuditLogsUrl(request));
    }

    /// List projects.
    ProjectListResponse listProjects(in ListProjectsRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return getJson!ProjectListResponse(buildListProjectsUrl(request));
    }

    /// Create a project.
    Project createProject(in CreateProjectRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return postJson!Project("/organization/projects", request);
    }

    /// Retrieve a project by ID.
    Project retrieveProject(string projectId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        return getJson!Project("/organization/projects/" ~ projectId);
    }

    /// Modify a project.
    Project modifyProject(string projectId, in ModifyProjectRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        return postJson!Project("/organization/projects/" ~ projectId, request);
    }

    /// Archive a project.
    Project archiveProject(string projectId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        return postJson!Project("/organization/projects/" ~ projectId ~ "/archive", EmptyRequest());
    }

    /// List users in a project.
    ProjectUserListResponse listProjectUsers(string projectId, in ListProjectUsersRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        return getJson!ProjectUserListResponse(buildListProjectUsersUrl(projectId, request));
    }

    /// Add a user to a project.
    ProjectUser createProjectUser(string projectId, in CreateProjectUserRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        return postJson!ProjectUser("/organization/projects/" ~ projectId ~ "/users", request);
    }

    /// Retrieve a project user by ID.
    ProjectUser retrieveProjectUser(string projectId, string userId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    in (userId.length > 0)
    {
        return getJson!ProjectUser("/organization/projects/" ~ projectId ~ "/users/" ~ userId);
    }

    /// Modify a project user's role.
    ProjectUser modifyProjectUser(string projectId, string userId, in UpdateProjectUserRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    in (userId.length > 0)
    {
        return postJson!ProjectUser("/organization/projects/" ~ projectId ~ "/users/" ~ userId, request);
    }

    /// Delete a user from a project.
    DeleteProjectUserResponse deleteProjectUser(string projectId, string userId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    in (userId.length > 0)
    {
        return deleteJson!DeleteProjectUserResponse("/organization/projects/" ~ projectId ~ "/users/" ~ userId);
    }

    /// List service accounts for a project.
    ProjectServiceAccountListResponse listProjectServiceAccounts(string projectId, in ListProjectServiceAccountsRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        return getJson!ProjectServiceAccountListResponse(
            buildListProjectServiceAccountsUrl(projectId, request));
    }

    /// Create a project service account.
    CreateProjectServiceAccountResponse createProjectServiceAccount(string projectId, in CreateProjectServiceAccountRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        return postJson!CreateProjectServiceAccountResponse(
            "/organization/projects/" ~ projectId ~ "/service_accounts",
            request);
    }

    /// Retrieve a project service account by ID.
    ProjectServiceAccount retrieveProjectServiceAccount(string projectId, string serviceAccountId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    in (serviceAccountId.length > 0)
    {
        return getJson!ProjectServiceAccount(
            "/organization/projects/" ~ projectId ~ "/service_accounts/" ~ serviceAccountId);
    }

    /// Delete a project service account.
    ProjectServiceAccountDeleteResponse deleteProjectServiceAccount(string projectId, string serviceAccountId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    in (serviceAccountId.length > 0)
    {
        return deleteJson!ProjectServiceAccountDeleteResponse(
            "/organization/projects/" ~ projectId ~ "/service_accounts/" ~ serviceAccountId);
    }

    /// List API keys for a project.
    ProjectApiKeyListResponse listProjectApiKeys(string projectId, in ListProjectApiKeysRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        auto b = QueryParamsBuilder("/organization/projects/" ~ projectId ~ "/api_keys");
        b.add("limit", request.limit);
        b.add("after", request.after);
        return getJson!ProjectApiKeyListResponse(b.finish());
    }

    /// Retrieve a project API key by ID.
    ProjectApiKey retrieveProjectApiKey(string projectId, string keyId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (keyId.length > 0)
    {
        return getJson!ProjectApiKey(
            "/organization/projects/" ~ projectId ~ "/api_keys/" ~ keyId);
    }

    /// Delete a project API key.
    DeleteProjectApiKeyResponse deleteProjectApiKey(string projectId, string keyId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (keyId.length > 0)
    {
        return deleteJson!DeleteProjectApiKeyResponse(
            "/organization/projects/" ~ projectId ~ "/api_keys/" ~ keyId);
    }

    /// List rate limits for a project.
    ProjectRateLimitListResponse listProjectRateLimits(string projectId, in ListProjectRateLimitsRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        return getJson!ProjectRateLimitListResponse(
            buildListProjectRateLimitsUrl(projectId, request));
    }

    /// Create a project rate limit.
    ProjectRateLimit createProjectRateLimit(string projectId, in CreateProjectRateLimitRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        return postJson!ProjectRateLimit(
            "/organization/projects/" ~ projectId ~ "/rate_limits",
            request);
    }

    /// Modify a project rate limit.
    ProjectRateLimit modifyProjectRateLimit(string projectId, string limitId, in ModifyProjectRateLimitRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (limitId.length > 0)
    {
        return postJson!ProjectRateLimit(
            "/organization/projects/" ~ projectId ~ "/rate_limits/" ~ limitId,
            request);
    }

    /// List organization certificates.
    ListCertificatesResponse listCertificates() @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return getJson!ListCertificatesResponse("/organization/certificates");
    }

    /// Activate organization certificates.
    ListCertificatesResponse activateCertificates(in ToggleCertificatesRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return postJson!ListCertificatesResponse(
            "/organization/certificates/activate", request);
    }

    /// Deactivate organization certificates.
    ListCertificatesResponse deactivateCertificates(in ToggleCertificatesRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return postJson!ListCertificatesResponse(
            "/organization/certificates/deactivate", request);
    }

    /// Modify a certificate.
    Certificate modifyCertificate(string certificateId, in ModifyCertificateRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (certificateId.length > 0)
    {
        return postJson!Certificate(
            "/organization/certificates/" ~ certificateId, request);
    }

    /// List cost reports for the organization.
    UsageResponse listCosts(in ListCostsRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return getJson!UsageResponse(buildListCostsUrl(request));
    }

    /// List usage reports for a specific type.
    UsageResponse listUsageCompletions(in ListUsageRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return getJson!UsageResponse(buildListUsageUrl("completions", request));
    }

    ///
    UsageResponse listUsageEmbeddings(in ListUsageRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return getJson!UsageResponse(buildListUsageUrl("embeddings", request));
    }

    ///
    UsageResponse listUsageImages(in ListUsageRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return getJson!UsageResponse(buildListUsageUrl("images", request));
    }

    ///
    UsageResponse listUsageModerations(in ListUsageRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return getJson!UsageResponse(buildListUsageUrl("moderations", request));
    }

    ///
    UsageResponse listUsageAudioSpeeches(in ListUsageRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return getJson!UsageResponse(buildListUsageUrl("audio_speeches", request));
    }

    ///
    UsageResponse listUsageAudioTranscriptions(in ListUsageRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return getJson!UsageResponse(buildListUsageUrl("audio_transcriptions", request));
    }

    ///
    UsageResponse listUsageVectorStores(in ListUsageRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return getJson!UsageResponse(buildListUsageUrl("vector_stores", request));
    }

    ///
    UsageResponse listUsageCodeInterpreterSessions(in ListUsageRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return getJson!UsageResponse(buildListUsageUrl("code_interpreter_sessions", request));
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
