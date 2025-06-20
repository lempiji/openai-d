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
        static assert(is(typeof(encodeComponent(to!string(T.init)))),
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
    import openai.clients.config : OpenAIClientConfig;

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
