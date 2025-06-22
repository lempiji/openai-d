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

private struct EmptyRequest
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

private:
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

    string buildListProjectApiKeysUrl(string projectId, in ListProjectApiKeysRequest request) const @safe
    {
        auto b = QueryParamsBuilder("/organization/projects/" ~ projectId ~ "/api_keys");
        b.add("limit", request.limit);
        b.add("after", request.after);
        return b.finish();
    }

    mixin ClientHelpers;

public:
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
        return getJson!ProjectServiceAccountListResponse(buildListProjectServiceAccountsUrl(projectId, request));
    }

    /// Create a project service account.
    CreateProjectServiceAccountResponse createProjectServiceAccount(string projectId, in CreateProjectServiceAccountRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (projectId.length > 0)
    {
        return postJson!CreateProjectServiceAccountResponse(
            "/organization/projects/" ~ projectId ~ "/service_accounts", request);
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
        return getJson!ProjectApiKeyListResponse(buildListProjectApiKeysUrl(projectId, request));
    }

    /// Retrieve a project API key by ID.
    ProjectApiKey retrieveProjectApiKey(string projectId, string keyId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (keyId.length > 0)
    {
        return getJson!ProjectApiKey("/organization/projects/" ~ projectId ~ "/api_keys/" ~ keyId);
    }

    /// Delete a project API key.
    DeleteProjectApiKeyResponse deleteProjectApiKey(string projectId, string keyId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (keyId.length > 0)
    {
        return deleteJson!DeleteProjectApiKeyResponse("/organization/projects/" ~ projectId ~ "/api_keys/" ~ keyId);
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
        return postJson!ProjectRateLimit("/organization/projects/" ~ projectId ~ "/rate_limits", request);
    }

    /// Modify a project rate limit.
    ProjectRateLimit modifyProjectRateLimit(string projectId, string limitId, in ModifyProjectRateLimitRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (limitId.length > 0)
    {
        return postJson!ProjectRateLimit("/organization/projects/" ~ projectId ~ "/rate_limits/" ~ limitId, request);
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
        return postJson!ListCertificatesResponse("/organization/certificates/activate", request);
    }

    /// Deactivate organization certificates.
    ListCertificatesResponse deactivateCertificates(in ToggleCertificatesRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return postJson!ListCertificatesResponse("/organization/certificates/deactivate", request);
    }

    /// Modify a certificate.
    Certificate modifyCertificate(string certificateId, in ModifyCertificateRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (certificateId.length > 0)
    {
        return postJson!Certificate("/organization/certificates/" ~ certificateId, request);
    }

    /// List cost reports for the organization.
    CostsResponse listCosts(in ListCostsRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        return getJson!CostsResponse(buildListCostsUrl(request));
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

@("buildList*Url helpers")
unittest
{
    import std.algorithm.searching : canFind;
    import std.typecons : tuple;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIAdminClient(cfg);

    AuditLogTimeRange range;
    range.gt = 10;
    range.lte = 20;
    auto auditReq = listAuditLogsRequest(5, null, null, null, ["a@example.com"], ["res id"], range);

    auto usageReq = listUsageRequest(1);
    usageReq.bucketWidth = "day";
    usageReq.projectIds = ["p id"];
    usageReq.userIds = ["u id"];
    usageReq.apiKeyIds = ["key id"];
    usageReq.models = ["gpt 4"];
    usageReq.groupBy = ["project_id"];
    usageReq.limit = 3;
    usageReq.page = "foo bar";
    usageReq.batch = true;

    auto costsReq = listCostsRequest(2);
    costsReq.bucketWidth = "month";
    costsReq.projectIds = ["p id"];
    costsReq.groupBy = ["project_id"];
    costsReq.limit = 5;
    costsReq.page = "bar+baz";

    ListInvitesRequest invitesLimit;
    invitesLimit.limit = 2;

    ListInvitesRequest invitesAfter;
    invitesAfter.after = "foo";

    ListInvitesRequest invitesEnc;
    invitesEnc.limit = 3;
    invitesEnc.after = "foo bar";

    ListProjectServiceAccountsRequest svcLimit;
    svcLimit.limit = 2;

    ListProjectServiceAccountsRequest svcAfter;
    svcAfter.after = "foo";

    ListProjectServiceAccountsRequest svcEnc;
    svcEnc.limit = 3;
    svcEnc.after = "foo bar";

    ListProjectRateLimitsRequest rateLimit;
    rateLimit.limit = 2;

    ListProjectRateLimitsRequest rateAfter;
    rateAfter.after = "foo";

    ListProjectRateLimitsRequest rateEnc;
    rateEnc.limit = 3;
    rateEnc.after = "foo bar";

    ListUsersRequest usersLimit;
    usersLimit.limit = 2;

    ListUsersRequest usersAfter;
    usersAfter.after = "foo";

    ListUsersRequest usersEnc;
    usersEnc.limit = 3;
    usersEnc.after = "foo bar";

    ListProjectUsersRequest projectUsersLimit;
    projectUsersLimit.limit = 2;

    ListProjectUsersRequest projectUsersAfter;
    projectUsersAfter.after = "foo";

    ListProjectUsersRequest projectUsersEnc;
    projectUsersEnc.limit = 3;
    projectUsersEnc.after = "foo bar";

    ListAdminApiKeysRequest keysLimit;
    keysLimit.limit = 2;

    ListAdminApiKeysRequest keysAfter;
    keysAfter.after = "foo";

    ListAdminApiKeysRequest keysEnc;
    keysEnc.limit = 3;
    keysEnc.after = "foo bar";

    ListProjectsRequest projectsLimit;
    projectsLimit.limit = 2;

    ListProjectsRequest projectsAfter;
    projectsAfter.after = "foo";
    projectsAfter.includeArchived = true;

    ListProjectsRequest projectsEnc;
    projectsEnc.limit = 3;
    projectsEnc.after = "foo bar";
    projectsEnc.includeArchived = true;

    ListProjectApiKeysRequest projectApiKeysLimit;
    projectApiKeysLimit.limit = 2;

    ListProjectApiKeysRequest projectApiKeysAfter;
    projectApiKeysAfter.after = "foo";

    ListProjectApiKeysRequest projectApiKeysEnc;
    projectApiKeysEnc.limit = 3;
    projectApiKeysEnc.after = "foo bar";

    foreach (t; [
        tuple("audit logs encoded", () => client.buildListAuditLogsUrl(auditReq),
            [
            "actor_emails[]=a%40example.com", "resource_ids[]=res%20id",
            "effective_at[gt]=10", "effective_at[lte]=20"
        ]),
        tuple("usage encoded", () => client.buildListUsageUrl("completions", usageReq),
            [
            "start_time=1", "bucket_width=day", "project_ids=p%20id",
            "user_ids=u%20id", "api_key_ids=key%20id", "models=gpt%204",
            "group_by=project_id", "limit=3", "page=foo%20bar", "batch=true"
        ]),
        tuple("costs encoded", () => client.buildListCostsUrl(costsReq),
            [
            "start_time=2", "bucket_width=month", "project_ids=p%20id",
            "group_by=project_id", "limit=5", "page=bar%2Bbaz"
        ]),
        tuple("invites limit", () => client.buildListInvitesUrl(invitesLimit),
            ["limit=2"]),
        tuple("invites after", () => client.buildListInvitesUrl(invitesAfter),
            ["after=foo"]),
        tuple("invites encoded", () => client.buildListInvitesUrl(invitesEnc),
            ["limit=3", "after=foo%20bar"]),
        tuple("service accounts limit",
            () => client.buildListProjectServiceAccountsUrl("p", svcLimit),
            ["limit=2"]),
        tuple("service accounts after",
            () => client.buildListProjectServiceAccountsUrl("p", svcAfter),
            ["after=foo"]),
        tuple("service accounts encoded",
            () => client.buildListProjectServiceAccountsUrl("p", svcEnc),
            ["limit=3", "after=foo%20bar"]),
        tuple("rate limits limit",
            () => client.buildListProjectRateLimitsUrl("p", rateLimit),
            ["limit=2"]),
        tuple("rate limits after",
            () => client.buildListProjectRateLimitsUrl("p", rateAfter),
            ["after=foo"]),
        tuple("rate limits encoded",
            () => client.buildListProjectRateLimitsUrl("p", rateEnc),
            ["limit=3", "after=foo%20bar"]),
        tuple("users limit", () => client.buildListUsersUrl(usersLimit),
            ["limit=2"]),
        tuple("users after", () => client.buildListUsersUrl(usersAfter),
            ["after=foo"]),
        tuple("users encoded", () => client.buildListUsersUrl(usersEnc),
            ["limit=3", "after=foo%20bar"]),
        tuple("project users limit",
            () => client.buildListProjectUsersUrl("p", projectUsersLimit),
            ["limit=2"]),
        tuple("project users after",
            () => client.buildListProjectUsersUrl("p", projectUsersAfter),
            ["after=foo"]),
        tuple("project users encoded",
            () => client.buildListProjectUsersUrl("p", projectUsersEnc),
            ["limit=3", "after=foo%20bar"]),
        tuple("admin keys limit", () => client.buildListAdminApiKeysUrl(keysLimit),
            ["limit=2"]),
        tuple("admin keys after", () => client.buildListAdminApiKeysUrl(keysAfter),
            ["after=foo"]),
        tuple("admin keys encoded", () => client.buildListAdminApiKeysUrl(keysEnc),
            ["limit=3", "after=foo%20bar"]),
        tuple("projects limit", () => client.buildListProjectsUrl(projectsLimit),
            ["limit=2"]),
        tuple("projects after archived",
            () => client.buildListProjectsUrl(projectsAfter),
            ["after=foo", "include_archived=true"]),
        tuple("projects encoded", () => client.buildListProjectsUrl(projectsEnc),
            ["limit=3", "after=foo%20bar", "include_archived=true"]),
        tuple("project api keys limit",
            () => client.buildListProjectApiKeysUrl("p", projectApiKeysLimit),
            ["limit=2"]),
        tuple("project api keys after",
            () => client.buildListProjectApiKeysUrl("p", projectApiKeysAfter),
            ["after=foo"]),
        tuple("project api keys encoded",
            () => client.buildListProjectApiKeysUrl("p", projectApiKeysEnc),
            ["limit=3", "after=foo%20bar"])
    ])
    {
        auto url = t[1]();
        foreach (part; t[2])
        {
            assert(url.canFind(part), t[0] ~ " - " ~ part);
        }
    }
}
