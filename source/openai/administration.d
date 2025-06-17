module openai.administration;

import mir.serde;
import mir.serde : serdeEnumProxy;
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
    @serdeOptional @serdeIgnoreDefault string after;
    @serdeOptional @serdeIgnoreDefault uint limit;
}

/// Convenience constructor for `ListAdminApiKeysRequest`.
ListAdminApiKeysRequest listAdminApiKeysRequest(uint limit)
{
    auto req = ListAdminApiKeysRequest();
    req.limit = limit;
    return req;
}

struct CreateAdminApiKeyRequest
{
    string name;
}

/// Convenience constructor for `CreateAdminApiKeyRequest`.
CreateAdminApiKeyRequest createAdminApiKeyRequest(string name)
{
    auto req = CreateAdminApiKeyRequest();
    req.name = name;
    return req;
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

struct ProjectCreateRequest
{
    string name;
}

/// Convenience constructor for `ProjectCreateRequest`.
ProjectCreateRequest projectCreateRequest(string name)
{
    auto req = ProjectCreateRequest();
    req.name = name;
    return req;
}

struct ProjectUpdateRequest
{
    string name;
}

/// Convenience constructor for `ProjectUpdateRequest`.
ProjectUpdateRequest projectUpdateRequest(string name)
{
    auto req = ProjectUpdateRequest();
    req.name = name;
    return req;
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

/// Convenience constructor for `ToggleCertificatesRequest`.
ToggleCertificatesRequest toggleCertificatesRequest(string[] ids)
{
    auto req = ToggleCertificatesRequest();
    req.data = ids;
    return req;
}

struct ModifyCertificateRequest
{
    string name;
}

/// Convenience constructor for `ModifyCertificateRequest`.
ModifyCertificateRequest modifyCertificateRequest(string name)
{
    auto req = ModifyCertificateRequest();
    req.name = name;
    return req;
}

@serdeIgnoreUnexpectedKeys
struct DeleteCertificateResponse
{
    string object;
    string id;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogProject
{
    string id;
    string name;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogActorUser
{
    string id;
    string email;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogActorServiceAccount
{
    string id;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogActorSession
{
    AuditLogActorUser user;
    @serdeKeys("ip_address") string ipAddress;
    @serdeOptional @serdeKeys("user_agent") string userAgent;
}

@serdeEnumProxy!string enum AuditLogActorType : string
{
    Session = "session",
    ApiKey = "api_key",
}

@serdeEnumProxy!string enum AuditLogApiKeyType : string
{
    User = "user",
    ServiceAccount = "service_account",
}

@serdeIgnoreUnexpectedKeys
struct AuditLogActorApiKey
{
    string id;
    AuditLogApiKeyType type;
    @serdeOptional AuditLogActorUser user;
    @serdeOptional @serdeKeys("service_account") AuditLogActorServiceAccount serviceAccount;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogApiKeyCreated
{
    string id;
    @serdeIgnoreUnexpectedKeys static struct Data
    {
        string[] scopes;
    }

    Data data;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogApiKeyUpdated
{
    string id;
    @serdeIgnoreUnexpectedKeys static struct ChangesRequested
    {
        string[] scopes;
    }

    @serdeKeys("changes_requested") ChangesRequested changesRequested;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogApiKeyDeleted
{
    string id;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogCheckpointPermissionCreated
{
    string id;
    @serdeIgnoreUnexpectedKeys static struct Data
    {
        @serdeKeys("project_id") string projectId;
        @serdeKeys("fine_tuned_model_checkpoint") string fineTunedModelCheckpoint;
    }

    Data data;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogCheckpointPermissionDeleted
{
    string id;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogInviteSent
{
    string id;
    @serdeIgnoreUnexpectedKeys static struct Data
    {
        string email;
        string role;
    }

    Data data;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogInviteAccepted
{
    string id;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogInviteDeleted
{
    string id;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogLoginSucceeded
{
}

@serdeIgnoreUnexpectedKeys
struct AuditLogLoginFailed
{
    @serdeKeys("error_code") string errorCode;
    @serdeKeys("error_message") string errorMessage;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogLogoutSucceeded
{
}

@serdeIgnoreUnexpectedKeys
struct AuditLogLogoutFailed
{
    @serdeKeys("error_code") string errorCode;
    @serdeKeys("error_message") string errorMessage;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogOrganizationUpdated
{
    string id;
    @serdeIgnoreUnexpectedKeys static struct ChangesRequested
    {
        string title;
        string description;
        string name;
        @serdeIgnoreUnexpectedKeys static struct Settings
        {
            @serdeKeys("threads_ui_visibility") string threadsUiVisibility;
            @serdeKeys("usage_dashboard_visibility") string usageDashboardVisibility;
        }

        @serdeOptional Settings settings;
    }

    @serdeKeys("changes_requested") ChangesRequested changesRequested;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogProjectCreated
{
    string id;
    @serdeIgnoreUnexpectedKeys static struct Data
    {
        string name;
        string title;
    }

    Data data;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogProjectUpdated
{
    string id;
    @serdeIgnoreUnexpectedKeys static struct ChangesRequested
    {
        string title;
    }

    @serdeKeys("changes_requested") ChangesRequested changesRequested;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogProjectArchived
{
    string id;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogServiceAccountCreated
{
    string id;
    @serdeIgnoreUnexpectedKeys static struct Data
    {
        string role;
    }

    Data data;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogServiceAccountUpdated
{
    string id;
    @serdeIgnoreUnexpectedKeys static struct ChangesRequested
    {
        string role;
    }

    @serdeKeys("changes_requested") ChangesRequested changesRequested;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogServiceAccountDeleted
{
    string id;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogRateLimitUpdated
{
    string id;
    @serdeIgnoreUnexpectedKeys static struct ChangesRequested
    {
        @serdeKeys("max_requests_per_1_minute") long maxRequestsPer1Minute;
        @serdeKeys("max_tokens_per_1_minute") long maxTokensPer1Minute;
        @serdeKeys("max_images_per_1_minute") long maxImagesPer1Minute;
        @serdeKeys("max_audio_megabytes_per_1_minute") long maxAudioMegabytesPer1Minute;
        @serdeKeys("max_requests_per_1_day") long maxRequestsPer1Day;
        @serdeKeys("batch_1_day_max_input_tokens") long batch1DayMaxInputTokens;
    }

    @serdeKeys("changes_requested") ChangesRequested changesRequested;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogRateLimitDeleted
{
    string id;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogUserAdded
{
    string id;
    @serdeIgnoreUnexpectedKeys static struct Data
    {
        string role;
    }

    Data data;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogUserUpdated
{
    string id;
    @serdeIgnoreUnexpectedKeys static struct ChangesRequested
    {
        string role;
    }

    @serdeKeys("changes_requested") ChangesRequested changesRequested;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogUserDeleted
{
    string id;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogCertificateCreated
{
    string id;
    string name;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogCertificateUpdated
{
    string id;
    string name;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogCertificateDeleted
{
    string id;
    string name;
    string certificate;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogEventCertificate
{
    string id;
    string name;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogCertificatesActivated
{
    AuditLogEventCertificate[] certificates;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogCertificatesDeactivated
{
    AuditLogEventCertificate[] certificates;
}

@serdeIgnoreUnexpectedKeys
struct AuditLogActor
{
    AuditLogActorType type;
    @serdeOptional AuditLogActorSession session;
    @serdeOptional @serdeKeys("api_key") AuditLogActorApiKey apiKey;
}

enum AuditLogEventType
{
    ApiKeyCreated = "api_key.created",
    ApiKeyUpdated = "api_key.updated",
    ApiKeyDeleted = "api_key.deleted",
    CheckpointPermissionCreated = "checkpoint_permission.created",
    CheckpointPermissionDeleted = "checkpoint_permission.deleted",
    InviteSent = "invite.sent",
    InviteAccepted = "invite.accepted",
    InviteDeleted = "invite.deleted",
    LoginSucceeded = "login.succeeded",
    LoginFailed = "login.failed",
    LogoutSucceeded = "logout.succeeded",
    LogoutFailed = "logout.failed",
    OrganizationUpdated = "organization.updated",
    ProjectCreated = "project.created",
    ProjectUpdated = "project.updated",
    ProjectArchived = "project.archived",
    ServiceAccountCreated = "service_account.created",
    ServiceAccountUpdated = "service_account.updated",
    ServiceAccountDeleted = "service_account.deleted",
    RateLimitUpdated = "rate_limit.updated",
    RateLimitDeleted = "rate_limit.deleted",
    UserAdded = "user.added",
    UserUpdated = "user.updated",
    UserDeleted = "user.deleted",
}

@serdeIgnoreUnexpectedKeys
struct AuditLog
{
    string id;
    string type;
    @serdeKeys("effective_at") long effectiveAt;
    @serdeOptional AuditLogProject project;
    AuditLogActor actor;
    @serdeOptional @serdeKeys("api_key.created") AuditLogApiKeyCreated apiKeyCreated;
    @serdeOptional @serdeKeys("api_key.updated") AuditLogApiKeyUpdated apiKeyUpdated;
    @serdeOptional @serdeKeys("api_key.deleted") AuditLogApiKeyDeleted apiKeyDeleted;
    @serdeOptional @serdeKeys("checkpoint_permission.created") AuditLogCheckpointPermissionCreated checkpointPermissionCreated;
    @serdeOptional @serdeKeys("checkpoint_permission.deleted") AuditLogCheckpointPermissionDeleted checkpointPermissionDeleted;
    @serdeOptional @serdeKeys("invite.sent") AuditLogInviteSent inviteSent;
    @serdeOptional @serdeKeys("invite.accepted") AuditLogInviteAccepted inviteAccepted;
    @serdeOptional @serdeKeys("invite.deleted") AuditLogInviteDeleted inviteDeleted;
    @serdeOptional @serdeKeys("login.succeeded") AuditLogLoginSucceeded loginSucceeded;
    @serdeOptional @serdeKeys("login.failed") AuditLogLoginFailed loginFailed;
    @serdeOptional @serdeKeys("logout.succeeded") AuditLogLogoutSucceeded logoutSucceeded;
    @serdeOptional @serdeKeys("logout.failed") AuditLogLogoutFailed logoutFailed;
    @serdeOptional @serdeKeys("organization.updated") AuditLogOrganizationUpdated organizationUpdated;
    @serdeOptional @serdeKeys("project.created") AuditLogProjectCreated projectCreated;
    @serdeOptional @serdeKeys("project.updated") AuditLogProjectUpdated projectUpdated;
    @serdeOptional @serdeKeys("project.archived") AuditLogProjectArchived projectArchived;
    @serdeOptional @serdeKeys("service_account.created") AuditLogServiceAccountCreated serviceAccountCreated;
    @serdeOptional @serdeKeys("service_account.updated") AuditLogServiceAccountUpdated serviceAccountUpdated;
    @serdeOptional @serdeKeys("service_account.deleted") AuditLogServiceAccountDeleted serviceAccountDeleted;
    @serdeOptional @serdeKeys("rate_limit.updated") AuditLogRateLimitUpdated rateLimitUpdated;
    @serdeOptional @serdeKeys("rate_limit.deleted") AuditLogRateLimitDeleted rateLimitDeleted;
    @serdeOptional @serdeKeys("user.added") AuditLogUserAdded userAdded;
    @serdeOptional @serdeKeys("user.updated") AuditLogUserUpdated userUpdated;
    @serdeOptional @serdeKeys("user.deleted") AuditLogUserDeleted userDeleted;
    @serdeOptional @serdeKeys("certificate.created") AuditLogCertificateCreated certificateCreated;
    @serdeOptional @serdeKeys("certificate.updated") AuditLogCertificateUpdated certificateUpdated;
    @serdeOptional @serdeKeys("certificate.deleted") AuditLogCertificateDeleted certificateDeleted;
    @serdeOptional @serdeKeys("certificates.activated") AuditLogCertificatesActivated certificatesActivated;
    @serdeOptional @serdeKeys("certificates.deactivated") AuditLogCertificatesDeactivated certificatesDeactivated;
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

struct AuditLogTimeRange
{
    @serdeOptional @serdeIgnoreDefault long gt;
    @serdeOptional @serdeIgnoreDefault long gte;
    @serdeOptional @serdeIgnoreDefault long lt;
    @serdeOptional @serdeIgnoreDefault long lte;
}

struct ListAuditLogsRequest
{
    @serdeOptional @serdeIgnoreDefault string[] projectIds;
    @serdeOptional @serdeIgnoreDefault string[] eventTypes;
    @serdeOptional @serdeIgnoreDefault string[] actorIds;
    @serdeOptional @serdeIgnoreDefault
    @serdeKeys("actor_emails")
    string[] actorEmails;
    @serdeOptional @serdeIgnoreDefault
    @serdeKeys("resource_ids")
    string[] resourceIds;
    @serdeOptional @serdeIgnoreDefault
    @serdeKeys("effective_at")
    AuditLogTimeRange effectiveAt;
    @serdeOptional @serdeIgnoreDefault uint limit;
    @serdeOptional @serdeIgnoreDefault string after;
    @serdeOptional @serdeIgnoreDefault string before;
}

/// Convenience constructor for `ListAuditLogsRequest`.
ListAuditLogsRequest listAuditLogsRequest(
    uint limit,
    string[] projectIds = null,
    string[] eventTypes = null,
    string[] actorIds = null,
    string[] actorEmails = null,
    string[] resourceIds = null,
    AuditLogTimeRange effectiveAt = AuditLogTimeRange.init,
    string after = "",
    string before = "")
{
    auto req = ListAuditLogsRequest();
    req.limit = limit;
    if (projectIds !is null)
        req.projectIds = projectIds;
    if (eventTypes !is null)
        req.eventTypes = eventTypes;
    if (actorIds !is null)
        req.actorIds = actorIds;
    if (actorEmails !is null)
        req.actorEmails = actorEmails;
    if (resourceIds !is null)
        req.resourceIds = resourceIds;
    req.effectiveAt = effectiveAt;
    if (after.length)
        req.after = after;
    if (before.length)
        req.before = before;
    return req;
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

unittest
{
    import mir.ser.json : serializeJson;

    auto req = createAdminApiKeyRequest("main-key");
    assert(serializeJson(req) == `{"name":"main-key"}`);
}

unittest
{
    import mir.ser.json : serializeJson;

    auto req = listProjectsRequest(10, true);
    assert(serializeJson(req) == `{"limit":10,"include_archived":true}`);
}

unittest
{
    import mir.deser.json : deserializeJson;
    import mir.algebraic_alias.json : JsonAlgebraic;

    enum example = `{"id":"req_xxx_20240101","type":"api_key.created","effective_at":1720804090,"actor":{"type":"session","session":{"user":{"id":"user-xxx","email":"user@example.com"},"ip_address":"127.0.0.1","user_agent":"Mozilla/5.0"}},"api_key.created":{"id":"key_xxxx","data":{"scopes":["resource.operation"]}}}`;
    auto log = deserializeJson!AuditLog(example);
    assert(log.id == "req_xxx_20240101");
    assert(log.type == AuditLogEventType.ApiKeyCreated);
    assert(log.actor.type == AuditLogActorType.Session);
    assert(log.actor.session.ipAddress == "127.0.0.1");
    assert(log.apiKeyCreated.id == "key_xxxx");
    assert(log.apiKeyCreated.data.scopes[0] == "resource.operation");
}

unittest
{
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    AuditLogActor actor;
    actor.type = AuditLogActorType.ApiKey;
    actor.apiKey.id = "key1";
    actor.apiKey.type = AuditLogApiKeyType.User;

    auto js = serializeJson(actor);

    auto back = deserializeJson!AuditLogActor(js);
    assert(back.type == AuditLogActorType.ApiKey);
    assert(back.apiKey.type == AuditLogApiKeyType.User);
    assert(back.apiKey.id == "key1");
}
