module openai.administration.audit;

import mir.serde;
import mir.serde : serdeEnumProxy;
import mir.string_map;
import std.typecons : Nullable;
import mir.algebraic;

@safe:

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
    /// Not part of the OpenAPI schema but shown in documentation examples.
    @serdeOptional @serdeKeys("user_agent") string userAgent;
    @serdeOptional string ja3;
    @serdeOptional string ja4;
    @serdeOptional @serdeKeys("ip_address_details") AuditLogActorSessionIpAddressDetails ipAddressDetails;

    @serdeIgnoreUnexpectedKeys static struct AuditLogActorSessionIpAddressDetails
    {
        string country;
        string city;
        string region;
        @serdeKeys("region_code") string regionCode;
        string asn;
        string latitude;
        string longitude;
    }
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
    /// Present in the AuditLog schema but missing from the official
    /// `AuditLogEventType` enum in OpenAPI 2.3.0.
    CertificateCreated = "certificate.created",
    CertificateUpdated = "certificate.updated",
    CertificateDeleted = "certificate.deleted",
    CertificatesActivated = "certificates.activated",
    CertificatesDeactivated = "certificates.deactivated",
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

    enum exampleCert =
        `{"id":"req_cert","type":"certificate.created","effective_at":1,"actor":{"type":"session","session":{"user":{"id":"user-cert","email":"cert@example.com"},"ip_address":"127.0.0.1"}},"certificate.created":{"id":"cert-abc","name":"my-cert"}}`;
    auto log = deserializeJson!AuditLog(exampleCert);
    assert(log.type == AuditLogEventType.CertificateCreated);
    assert(log.certificateCreated.id == "cert-abc");
    assert(log.certificateCreated.name == "my-cert");
}

unittest
{
    import mir.deser.json : deserializeJson;

    enum example =
        `{"id":"req_ja4","type":"login.succeeded","effective_at":0,"actor":{"type":"session","session":{"user":{"id":"user","email":"u@example.com"},"ip_address":"127.0.0.1","user_agent":"UA","ja3":"ja3hash","ja4":"ja4hash","ip_address_details":{"country":"US","city":"SF","region":"CA","region_code":"CA","asn":"1234","latitude":"37.77","longitude":"-122.42"}}}}`;
    auto log = deserializeJson!AuditLog(example);
    assert(log.actor.session.ja3 == "ja3hash");
    assert(log.actor.session.ja4 == "ja4hash");
    assert(log.actor.session.ipAddressDetails.country == "US");
    assert(log.actor.session.ipAddressDetails.city == "SF");
}

unittest
{
    import mir.ser.json : serializeJson;
    import std.algorithm.searching : canFind;

    AuditLogActorSession.AuditLogActorSessionIpAddressDetails details;
    details.country = "US";
    details.city = "SF";
    details.region = "CA";
    details.regionCode = "CA";
    details.asn = "1234";
    details.latitude = "1";
    details.longitude = "2";

    AuditLogActorSession session;
    session.user.id = "u";
    session.user.email = "e@example.com";
    session.ipAddress = "127.0.0.1";
    session.userAgent = "UA";
    session.ja3 = "h3";
    session.ja4 = "h4";
    session.ipAddressDetails = details;

    auto js = serializeJson(session);
    assert(js.canFind("\"ja3\":\"h3\""));
    assert(js.canFind("\"ja4\":\"h4\""));
    assert(js.canFind("\"ip_address_details\":{\"country\":\"US\""));
}

unittest
{
    import mir.ser.json : serializeJson;
    import mir.deser.json : deserializeJson;

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
