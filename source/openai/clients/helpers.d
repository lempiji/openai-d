module openai.clients.helpers;

import std.array : Appender;
import std.net.curl : HTTP;

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
            _url ~= _sep ~ key ~ "=";
            bool first = true;
            foreach (value; values)
            {
                if (!first)
                    _url ~= ",";
                _url ~= encodeComponent(to!string(value));
                first = false;
            }
            _sep = "&";
        }
    }
}

@system struct MultipartPart
{
    string name;
    string value;
}

@system void appendFileChunked(scope ref Appender!(ubyte[])

    

    body,
    string boundary,
    string name,
    string filePath)
{
    import std.path : baseName;
    import std.stdio : File;

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

@system ubyte[] buildMultipartBody(scope ref HTTP http,
    scope MultipartPart[] textParts,
    scope MultipartPart[] fileParts)
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
