module openai.clients.helpers;

mixin template ClientHelpers()
{
    import std.net.curl;
    import std.array : Appender, appender, array;
    import std.stdio : File;
    import std.algorithm.iteration : joiner;

    import openai.responses;
    import openai.administration;
    import openai.files;
    import openai.clients.openai : OpenAIClientConfig;

    private string buildListInputItemsUrl(in ListInputItemsRequest request) const @safe
    {
        import std.format : format;
        import std.algorithm : map;
        import std.uri : encodeComponent;

        string url = buildUrl("/responses/" ~ request.responseId ~ "/input_items");
        string sep = "?";
        url ~= format("%slimit=%s", sep, request.limit);
        sep = "&";
        if (request.order.length)
            url ~= format("%sorder=%s", sep, encodeComponent(request.order)), sep = "&";
        if (request.after.length)
            url ~= format("%safter=%s", sep, encodeComponent(request.after)), sep = "&";
        if (request.before.length)
            url ~= format("%sbefore=%s", sep, encodeComponent(request.before)), sep = "&";
        if (request.include !is null && request.include.length) // Cast enum values to strings to ensure proper serialization into query parameters.
            url ~= format("%sinclude=%s", sep,
                request.include
                    .map!(x => encodeComponent(cast(string) x))
                    .joiner(",")
                    .array);
        return url;
    }

    private string buildGetResponseUrl(string responseId, string[] include) const @safe
    {
        import std.algorithm : map;
        import std.conv : to;
        import std.uri : encodeComponent;

        string url = buildUrl("/responses/" ~ responseId);
        if (include !is null && include.length)
            url ~= "?include="
                ~ to!string(
                    include
                        .map!(x => encodeComponent(cast(string) x))
                        .joiner(",")
                        .array);
        return url;
    }

    private string buildListAuditLogsUrl(in ListAuditLogsRequest request) const @safe
    {
        import std.format : format;
        import std.algorithm : map;
        import std.uri : encodeComponent;

        string url = buildUrl("/organization/audit_logs");
        string sep = "?";
        if (request.projectIds !is null && request.projectIds.length)
            url ~= format("%sproject_ids=%s", sep,
                request.projectIds.map!encodeComponent.joiner(",")), sep = "&";
        if (request.eventTypes !is null && request.eventTypes.length)
            url ~= format("%sevent_types=%s", sep,
                request.eventTypes.map!encodeComponent.joiner(",")), sep = "&";
        if (request.actorIds !is null && request.actorIds.length)
            url ~= format("%sactor_ids=%s", sep,
                request.actorIds.map!encodeComponent.joiner(",")), sep = "&";
        if (request.actorEmails !is null && request.actorEmails.length)
            url ~= format("%sactor_emails=%s", sep,
                request.actorEmails.map!encodeComponent.joiner(",")), sep = "&";
        if (request.resourceIds !is null && request.resourceIds.length)
            url ~= format("%sresource_ids=%s", sep,
                request.resourceIds.map!encodeComponent.joiner(",")), sep = "&";
        if (request.effectiveAt.gt)
            url ~= format("%seffective_at[gt]=%s", sep, request.effectiveAt.gt), sep = "&";
        if (request.effectiveAt.gte)
            url ~= format("%seffective_at[gte]=%s", sep, request.effectiveAt.gte), sep = "&";
        if (request.effectiveAt.lt)
            url ~= format("%seffective_at[lt]=%s", sep, request.effectiveAt.lt), sep = "&";
        if (request.effectiveAt.lte)
            url ~= format("%seffective_at[lte]=%s", sep, request.effectiveAt.lte), sep = "&";
        if (request.limit)
            url ~= format("%slimit=%s", sep, request.limit), sep = "&";
        if (request.after.length)
            url ~= format("%safter=%s", sep, encodeComponent(request.after)), sep = "&";
        return url;
    }

    private string buildListUsageUrl(string type, in ListUsageRequest request) const @safe
    {
        import std.format : format;
        import std.algorithm : map;
        import std.uri : encodeComponent;

        string url = buildUrl("/organization/usage/" ~ type);
        string sep = "?";
        url ~= format("%sstart_time=%s", sep, request.startTime);
        sep = "&";
        if (request.endTime)
            url ~= format("%send_time=%s", sep, request.endTime), sep = "&";
        if (request.bucketWidth.length)
            url ~= format("%sbucket_width=%s", sep, encodeComponent(request.bucketWidth)), sep = "&";
        if (request.projectIds !is null && request.projectIds.length)
            url ~= format("%sproject_ids=%s", sep,
                request.projectIds.map!encodeComponent.joiner(",")), sep = "&";
        if (request.userIds !is null && request.userIds.length)
            url ~= format("%suser_ids=%s", sep,
                request.userIds.map!encodeComponent.joiner(",")), sep = "&";
        if (request.apiKeyIds !is null && request.apiKeyIds.length)
            url ~= format("%sapi_key_ids=%s", sep,
                request.apiKeyIds.map!encodeComponent.joiner(",")), sep = "&";
        if (request.models !is null && request.models.length)
            url ~= format("%smodels=%s", sep,
                request.models.map!encodeComponent.joiner(",")), sep = "&";
        if (request.groupBy !is null && request.groupBy.length)
            url ~= format("%sgroup_by=%s", sep,
                request.groupBy.map!encodeComponent.joiner(",")), sep = "&";
        if (request.limit)
            url ~= format("%slimit=%s", sep, request.limit), sep = "&";
        if (request.page.length)
            url ~= format("%spage=%s", sep, encodeComponent(request.page)), sep = "&";
        if (request.batch)
            url ~= format("%sbatch=true", sep);
        return url;
    }

    private string buildListCostsUrl(in ListCostsRequest request) const @safe
    {
        import std.format : format;
        import std.algorithm : map;
        import std.uri : encodeComponent;

        string url = buildUrl("/organization/costs");
        string sep = "?";
        url ~= format("%sstart_time=%s", sep, request.startTime);
        sep = "&";
        if (request.endTime)
            url ~= format("%send_time=%s", sep, request.endTime), sep = "&";
        if (request.bucketWidth.length)
            url ~= format("%sbucket_width=%s", sep, encodeComponent(request.bucketWidth)), sep = "&";
        if (request.projectIds !is null && request.projectIds.length)
            url ~= format("%sproject_ids=%s", sep,
                request.projectIds.map!encodeComponent.joiner(",")), sep = "&";
        if (request.groupBy !is null && request.groupBy.length)
            url ~= format("%sgroup_by=%s", sep,
                request.groupBy.map!encodeComponent.joiner(",")), sep = "&";
        if (request.limit)
            url ~= format("%slimit=%s", sep, request.limit), sep = "&";
        if (request.page.length)
            url ~= format("%spage=%s", sep, encodeComponent(request.page));
        return url;
    }

    private string buildListFilesUrl(in ListFilesRequest request) const @safe
    {
        import std.format : format;
        import std.uri : encodeComponent;

        string url = buildUrl("/files");
        string sep = "?";
        if (request.purpose.length)
            url ~= format("%spurpose=%s", sep, encodeComponent(request.purpose)), sep = "&";
        if (request.limit)
            url ~= format("%slimit=%s", sep, request.limit), sep = "&";
        if (request.order.length)
            url ~= format("%sorder=%s", sep, encodeComponent(request.order)), sep = "&";
        if (request.after.length)
            url ~= format("%safter=%s", sep, encodeComponent(request.after)), sep = "&";
        // 'before' parameter removed in API; no longer supported
        return url;
    }

    private string buildListInvitesUrl(in ListInvitesRequest request) const @safe
    {
        import std.format : format;
        import std.uri : encodeComponent;

        string url = buildUrl("/organization/invites");
        string sep = "?";
        if (request.limit)
        {
            url ~= format("%slimit=%s", sep, request.limit);
            sep = "&";
        }
        if (request.after.length)
            url ~= format("%safter=%s", sep, encodeComponent(request.after));
        return url;
    }

    private string buildListUsersUrl(in ListUsersRequest request) const @safe
    {
        import std.format : format;
        import std.uri : encodeComponent;

        string url = buildUrl("/organization/users");
        string sep = "?";
        if (request.limit)
        {
            url ~= format("%slimit=%s", sep, request.limit);
            sep = "&";
        }
        if (request.after.length)
            url ~= format("%safter=%s", sep, encodeComponent(request.after));
        return url;
    }

    private string buildListProjectUsersUrl(string projectId, in ListProjectUsersRequest request) const @safe
    {
        import std.format : format;
        import std.uri : encodeComponent;

        string url = buildUrl("/organization/projects/" ~ projectId ~ "/users");
        string sep = "?";
        if (request.limit)
        {
            url ~= format("%slimit=%s", sep, request.limit);
            sep = "&";
        }
        if (request.after.length)
            url ~= format("%safter=%s", sep, encodeComponent(request.after));
        return url;
    }

    private string buildListProjectServiceAccountsUrl(string projectId, in ListProjectServiceAccountsRequest request) const @safe
    {
        import std.format : format;
        import std.uri : encodeComponent;

        string url = buildUrl("/organization/projects/" ~ projectId ~ "/service_accounts");
        string sep = "?";
        if (request.limit)
        {
            url ~= format("%slimit=%s", sep, request.limit);
            sep = "&";
        }
        if (request.after.length)
            url ~= format("%safter=%s", sep, encodeComponent(request.after));
        return url;
    }

    private string buildListProjectRateLimitsUrl(string projectId, in ListProjectRateLimitsRequest request) const @safe
    {
        import std.format : format;
        import std.uri : encodeComponent;

        string url = buildUrl("/organization/projects/" ~ projectId ~ "/rate_limits");
        string sep = "?";
        if (request.limit)
        {
            url ~= format("%slimit=%s", sep, request.limit);
            sep = "&";
        }
        if (request.after.length)
            url ~= format("%safter=%s", sep, encodeComponent(request.after));
        return url;
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

    private void appendFileChunked(scope ref Appender!(ubyte[])

        

        body,
        string boundary,
        string name,
        string filePath) @system
    {
        import std.path : baseName;

        body.put(cast(ubyte[])("--" ~ boundary ~ "\r\n"));
        body.put(cast(ubyte[])(
                "Content-Disposition: form-data; name=\"" ~ name ~ "\"; filename=\"" ~ baseName(filePath) ~ "\"\r\n"));
        body.put(cast(ubyte[])("Content-Type: application/octet-stream\r\n\r\n"));
        auto file = File(filePath, "rb");
        scope (exit)
            file.close();
        foreach (chunk; file.byChunk(8192))
            body.put(chunk);
        body.put(cast(ubyte[]) "\r\n");
    }

    private struct MultipartPart
    {
        string name;
        string value;
    }

    private ubyte[] buildMultipartBody(scope ref HTTP http,
        scope MultipartPart[] textParts,
        scope MultipartPart[] fileParts) @system
    {
        import std.array : appender;
        import std.conv : to;
        import std.random : uniform;

        auto boundary = "--------------------------" ~ to!string(uniform(0, int.max));
        http.addRequestHeader("Content-Type",
            "multipart/form-data; boundary=" ~ boundary);

        auto body = appender!(ubyte[])();

        foreach (fp; fileParts)
            if (fp.value.length)
                appendFileChunked(body, boundary, fp.name, fp.value);

        foreach (tp; textParts)
            if (tp.value.length)
            {
                body.put(cast(ubyte[])("--" ~ boundary ~ "\r\n"));
                body.put(cast(ubyte[])("Content-Disposition: form-data; name=\"" ~ tp.name ~ "\"\r\n\r\n"));
                body.put(cast(ubyte[]) tp.value);
                body.put(cast(ubyte[]) "\r\n");
            }

        body.put(cast(ubyte[])("--" ~ boundary ~ "--\r\n"));
        // dfmt off
            return body.data;
            // dfmt on
    }
}
