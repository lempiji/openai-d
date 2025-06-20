module openai.clients.helpers;

/**
    Helper struct for building query strings with optional parameters.
*/
@safe:

struct QueryParamsBuilder
{
    import std.format : format;
    import std.algorithm : map, joiner;
    import std.array : array;
    import std.conv : to;
    import std.uri : encodeComponent;
    import std.traits : isIntegral;

    private string _url;
    private string _sep = "?";

    this(string base)
    {
        _url = base;
    }

    /// Return the final URL with encoded query parameters.
    string finish() const
    {
        return _url;
    }

    /// Add a string parameter when not empty.
    void add(string key, string value)
    {
        if (value.length)
        {
            _url ~= format("%s%s=%s", _sep, key, encodeComponent(value));
            _sep = "&";
        }
    }

    /// Add a boolean flag parameter when true.
    void add(string key, bool value)
    {
        if (value)
        {
            _url ~= format("%s%s=true", _sep, key);
            _sep = "&";
        }
    }

    /// Add an integral parameter when non-zero.
    void add(T)(string key, T value) if (isIntegral!T && !is(T == bool))
    {
        if (value)
        {
            _url ~= format("%s%s=%s", _sep, key, value);
            _sep = "&";
        }
    }

    /// Add a list of values when not empty. Each element is encoded.
    void add(T)(string key, T[] values)
    {
        static assert(is(typeof(encodeComponent(to!string(values[0])))),
            "value type unsupported");
        if (values !is null && values.length)
        {
            _url ~= format("%s%s=%s", _sep, key,
                values.map!(v => encodeComponent(to!string(v))).joiner(",").array);
            _sep = "&";
        }
    }
}

mixin template ClientHelpers()
{
    import std.net.curl;
    import std.array : Appender, appender, array;
    import std.stdio : File;
    import std.algorithm.iteration : joiner;

    import openai.responses;
    import openai.administration;
    import openai.files;
    import openai.clients.config : OpenAIClientConfig;

    private string buildListAuditLogsUrl(in ListAuditLogsRequest request) const @safe
    {

        auto b = QueryParamsBuilder(buildUrl("/organization/audit_logs"));
        b.add("project_ids", request.projectIds);
        b.add("event_types", request.eventTypes);
        b.add("actor_ids", request.actorIds);
        b.add("actor_emails", request.actorEmails);
        b.add("resource_ids", request.resourceIds);
        b.add("effective_at[gt]", request.effectiveAt.gt);
        b.add("effective_at[gte]", request.effectiveAt.gte);
        b.add("effective_at[lt]", request.effectiveAt.lt);
        b.add("effective_at[lte]", request.effectiveAt.lte);
        b.add("limit", request.limit);
        b.add("after", request.after);
        return b.finish();
    }

    private string buildListUsageUrl(string type, in ListUsageRequest request) const @safe
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

    private string buildListCostsUrl(in ListCostsRequest request) const @safe
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

    private string buildListInvitesUrl(in ListInvitesRequest request) const @safe
    {
        auto b = QueryParamsBuilder(buildUrl("/organization/invites"));
        b.add("limit", request.limit);
        b.add("after", request.after);
        return b.finish();
    }

    private string buildListUsersUrl(in ListUsersRequest request) const @safe
    {
        auto b = QueryParamsBuilder(buildUrl("/organization/users"));
        b.add("limit", request.limit);
        b.add("after", request.after);
        return b.finish();
    }

    private string buildListProjectUsersUrl(string projectId, in ListProjectUsersRequest request) const @safe
    {
        auto b = QueryParamsBuilder(buildUrl("/organization/projects/" ~ projectId ~ "/users"));
        b.add("limit", request.limit);
        b.add("after", request.after);
        return b.finish();
    }

    private string buildListProjectServiceAccountsUrl(string projectId, in ListProjectServiceAccountsRequest request) const @safe
    {
        auto b = QueryParamsBuilder(buildUrl("/organization/projects/" ~ projectId ~ "/service_accounts"));
        b.add("limit", request.limit);
        b.add("after", request.after);
        return b.finish();
    }

    private string buildListProjectRateLimitsUrl(string projectId, in ListProjectRateLimitsRequest request) const @safe
    {
        auto b = QueryParamsBuilder(buildUrl("/organization/projects/" ~ projectId ~ "/rate_limits"));
        b.add("limit", request.limit);
        b.add("after", request.after);
        return b.finish();
    }

    private void setupHttpByConfig(scope ref HTTP http) @system
    {

        if (config.isAzure)
        {
            http.addRequestHeader("api-key", config.apiKey);
        }
        else
        {
            http.addRequestHeader("Authorization", "Bearer " ~ config.apiKey);
            if (config.organization.length > 0)
            {
                http.addRequestHeader("OpenAI-Organization", config.organization);
            }
        }
    }

    private string buildUrl(string path) const @safe
    {
        import std.format : format;
        import std.string : endsWith;

        string base = config.apiBase;
        if (base.endsWith("/"))
            base = base[0 .. $ - 1];
        if (config.isAzure)
        {
            return format("%s/openai/deployments/%s%s?api-version=%s",
                base, config.deploymentId, path, config.apiVersion);
        }
        else
        {
            return base ~ path;
        }
    }

}
