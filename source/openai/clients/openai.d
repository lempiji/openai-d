/**
OpenAI API Client
*/
module openai.clients.openai;

import mir.deser.json;
import mir.ser.json;
import std.net.curl;
import std.algorithm.iteration : joiner;
import std.array : array, Appender;

import openai.chat;
import openai.completion;
import openai.embedding;
import openai.models;
import openai.moderation;
import openai.audio;
import openai.responses;

@safe:

///
enum ENV_OPENAI_API_KEY = "OPENAI_API_KEY";

///
enum ENV_OPENAI_ORGANIZATION = "OPENAI_ORGANIZATION";

///
enum ENV_OPENAI_API_BASE = "OPENAI_API_BASE";

///
enum ENV_OPENAI_DEPLOYMENT_ID = "OPENAI_DEPLOYMENT_ID";

///
enum ENV_OPENAI_API_VERSION = "OPENAI_API_VERSION";

/// Default Azure OpenAI API version (2025-04-01-preview is also available)
enum DEFAULT_OPENAI_API_VERSION = "2024-10-21";

///
class OpenAIClientConfig
{
    string apiKey;
    string organization;
    string apiBase = "https://api.openai.com/v1";
    string deploymentId;
    string apiVersion = DEFAULT_OPENAI_API_VERSION;

    bool isAzure() const @safe
    {
        import std.algorithm.searching : canFind;

        return apiBase.canFind(".api.cognitive.microsoft.com");
    }

    private this()
    {
        this.apiBase = "https://api.openai.com/v1";
        this.apiVersion = DEFAULT_OPENAI_API_VERSION;
    }

    /// Initialize the configuration with the given API key.
    this(string apiKey)
    {
        this.apiKey = apiKey;
    }

    /// Initialize the configuration with an API key and the
    /// organization identifier used for OpenAI's multi-tenant API.
    this(string apiKey, string organization)
    {
        this.apiKey = apiKey;
        this.organization = organization;
    }

    /**
     * Construct a configuration from environment variables.
     *
     * The following variables are read by default:
     * `OPENAI_API_KEY`, `OPENAI_ORGANIZATION`, `OPENAI_API_BASE`,
     * `OPENAI_DEPLOYMENT_ID` and `OPENAI_API_VERSION`.
     * Alternative variable names can be supplied via the parameters.
     */
    static OpenAIClientConfig fromEnvironment(
        string envApiKeyName = ENV_OPENAI_API_KEY,
        string envOrgName = ENV_OPENAI_ORGANIZATION,
        string envApiBaseName = ENV_OPENAI_API_BASE,
        string envDeploymentName = ENV_OPENAI_DEPLOYMENT_ID,
        string envApiVersionName = ENV_OPENAI_API_VERSION)
    {
        auto config = new OpenAIClientConfig;
        config.loadFromEnvironmentVariables(envApiKeyName, envOrgName,
            envApiBaseName, envDeploymentName, envApiVersionName);
        return config;
    }

    /**
     * Construct a configuration from a JSON file.
     *
     * The file should contain keys such as `apiKey`, `organization`,
     * `apiBase`, `deploymentId` and `apiVersion`.
     */
    static OpenAIClientConfig fromFile(string filePath)
    {
        auto config = new OpenAIClientConfig;
        config.loadFromFile(filePath);
        return config;
    }

    /**
     * Populate this configuration from environment variables.
     *
     * See `fromEnvironment` for the default variable names. Missing
     * values fall back to the OpenAI defaults.
     */
    void loadFromEnvironmentVariables(
        string envApiKeyName = ENV_OPENAI_API_KEY,
        string envOrgName = ENV_OPENAI_ORGANIZATION,
        string envApiBaseName = ENV_OPENAI_API_BASE,
        string envDeploymentName = ENV_OPENAI_DEPLOYMENT_ID,
        string envApiVersionName = ENV_OPENAI_API_VERSION)
    {
        import std.process : environment;

        auto envApiKey = environment.get(envApiKeyName, "");
        auto envOrganization = environment.get(envOrgName, "");
        auto envApiBase = environment.get(envApiBaseName, "");
        auto envDeploymentId = environment.get(envDeploymentName, "");
        auto envApiVersion = environment.get(envApiVersionName, "");

        this.apiKey = envApiKey;
        this.organization = envOrganization;
        this.apiBase = envApiBase.length ? envApiBase : "https://api.openai.com/v1";
        this.deploymentId = envDeploymentId;
        if (envApiVersion.length)
            this.apiVersion = envApiVersion;
    }

    /**
     * Load configuration fields from a JSON file. The format mirrors
     * the one used by `saveToFile` and `fromFile`.
     */
    void loadFromFile(string filePath)
    {
        import std.file;

        auto configText = readText(filePath);

        @serdeIgnoreUnexpectedKeys
        static struct ConfigData
        {
            @serdeIgnoreDefault
            string apiKey;

            @serdeOptional
            @serdeIgnoreDefault
            string organization;

            @serdeOptional
            @serdeIgnoreDefault
            string apiBase;

            @serdeOptional
            @serdeIgnoreDefault
            string deploymentId;

            @serdeOptional
            @serdeIgnoreDefault
            string apiVersion;
        }

        auto config = deserializeJson!ConfigData(configText);
        this.apiKey = config.apiKey;
        this.organization = config.organization;
        if (config.apiBase.length)
            this.apiBase = config.apiBase;
        if (config.deploymentId.length)
            this.deploymentId = config.deploymentId;
        if (config.apiVersion.length)
            this.apiVersion = config.apiVersion;
    }

    /**
     * Write the current configuration to a JSON file. The output
     * can later be reloaded with `loadFromFile`.
     */
    void saveToFile(string filePath)
    {
        import std.file;

        write(filePath, serializeJson(this));
    }
}

///
class OpenAIClient
{
    ///
    OpenAIClientConfig config;

    ///
    this()
    {
        this.config = OpenAIClientConfig.fromEnvironment();
        validateConfig();
    }

    ///
    this(OpenAIClientConfig config)
    in (config !is null)
    do
    {
        this.config = config;
        validateConfig();
    }

    private void validateConfig()
    {
        import std.exception : enforce;

        if (config.isAzure)
        {
            enforce(config.deploymentId.length > 0,
                "OPENAI_DEPLOYMENT_ID is required for Azure mode");
        }
    }

    /// Retrieve the list of models available to the API key by
    /// issuing a GET request to `/models`.
    ModelsResponse listModels() @system
    in (config.apiKey != null && config.apiKey.length > 0)
    do
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        auto content = cast(char[]) get!(HTTP, ubyte)(buildUrl("/models"), http);
        auto result = content.deserializeJson!ModelsResponse();
        return result;
    }

    /// Call the `/completions` endpoint.
    /// `request.model` must be set and an API key must be present.
    CompletionResponse completion(in CompletionRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.model.length > 0)
    do
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto requestJson = serializeJson(request);
        debug scope (failure)
        {
            import std.stdio;

            writeln("----------");
            writeln("# completion requestJson");
            writeln(requestJson);
            writeln("----------");
        }
        auto content = cast(char[]) post!ubyte(buildUrl("/completions"), requestJson, http);

        debug scope (failure)
        {
            import std.stdio;

            writeln("-----------");
            writeln("# completion responseContent");
            writeln(content);
            writeln("-----------");
        }

        auto result = content.deserializeJson!CompletionResponse();
        return result;
    }

    /// Call the `/chat/completions` endpoint.
    /// Requires a model name and valid API key.
    ChatCompletionResponse chatCompletion(in ChatCompletionRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.model.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto requestJson = serializeJson(request);
        debug scope (failure)
        {
            import std.stdio;

            writeln("----------");
            writeln("# chatCompletion requestJson");
            writeln(requestJson);
            writeln("----------");
        }
        auto content = cast(char[]) post!ubyte(buildUrl("/chat/completions"), requestJson, http);

        debug scope (failure)
        {
            import std.stdio;

            writeln("-----------");
            writeln("# chatCompletion responseContent");
            writeln(content);
            writeln("-----------");
        }
        auto result = content.deserializeJson!ChatCompletionResponse();
        return result;
    }

    /// Request vector embeddings via the `/embeddings` endpoint.
    /// The request must specify a model.
    EmbeddingResponse embedding(in EmbeddingRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.model.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto requestJson = serializeJson(request);
        auto content = cast(char[]) post!ubyte(buildUrl("/embeddings"), requestJson, http);

        auto result = content.deserializeJson!EmbeddingResponse();
        return result;
    }

    /// Perform content classification using `/moderations`.
    /// `request.input` must not be empty.
    ModerationResponse moderation(in ModerationRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.input.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto requestJson = serializeJson(request);
        auto content = cast(char[]) post!ubyte(buildUrl("/moderations"), requestJson, http);

        // import std.stdio;
        // writeln(content);

        auto result = content.deserializeJson!ModerationResponse();
        return result;
    }

    /// Convert text to speech using `/audio/speech`.
    /// The request requires `model`, `input` and `voice` fields.
    ubyte[] speech(in SpeechRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.model.length > 0)
    in (request.input.length > 0)
    in (request.voice.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/octet-stream");
        http.addRequestHeader("Content-Type", "application/json");

        auto requestJson = serializeJson(request);
        auto content = post!ubyte(buildUrl("/audio/speech"), requestJson, http);
        return cast(ubyte[]) content;
    }

    /// Transcribe an audio file via `/audio/transcriptions`.
    /// Requires a valid file path and model.
    AudioTextResponse transcription(in TranscriptionRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.file.length > 0)
    in (request.model.length > 0)
    {
        import std.array : appender;
        import std.conv : to;
        import std.path : baseName;
        import std.random : uniform;
        import std.stdio : File;

        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        // create multipart body
        auto boundary = "--------------------------" ~ to!string(uniform(0, int.max));
        http.addRequestHeader("Content-Type",
            "multipart/form-data; boundary=" ~ boundary);

        auto body = appender!(ubyte[])();

        void addText(string name, string value)
        {
            body.put(cast(ubyte[])("--" ~ boundary ~ "\r\n"));
            body.put(cast(ubyte[])("Content-Disposition: form-data; name=\"" ~ name ~ "\"\r\n\r\n"));
            body.put(cast(ubyte[]) value);
            body.put(cast(ubyte[]) "\r\n");
        }

        void addFile(string name, string filePath)
        {
            appendFileChunked(body, boundary, name, filePath);
        }

        addFile("file", request.file);
        addText("model", request.model);
        if (request.language.length)
            addText("language", request.language);
        if (request.prompt.length)
            addText("prompt", request.prompt);
        if (request.responseFormat.length)
            addText("response_format", request.responseFormat);
        if (request.temperature != 0)
            addText("temperature", to!string(request.temperature));
        foreach (inc; request.include)
            addText("include", inc);
        foreach (t; request.timestampGranularities)
            addText("timestamp_granularities", t);
        if (request.stream)
            addText("stream", "true");

        body.put(cast(ubyte[])("--" ~ boundary ~ "--\r\n"));

        auto content = post!ubyte(buildUrl("/audio/transcriptions"), body.data, http);

        auto text = cast(char[]) content;
        if (request.responseFormat == AudioResponseFormatVerboseJson)
        {
            auto verbose = text.deserializeJson!TranscriptionVerboseResponse();
            AudioTextResponse simple;
            simple.text = verbose.text;
            simple.logprobs = null;
            return simple;
        }
        return text.deserializeJson!AudioTextResponse();
    }

    /// Translate speech audio using `/audio/translations`.
    /// A file path and model are required.
    AudioTextResponse translation(in TranslationRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.file.length > 0)
    in (request.model.length > 0)
    {
        import std.array : appender;
        import std.conv : to;
        import std.path : baseName;
        import std.random : uniform;
        import std.stdio : File;

        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        // create multipart body
        auto boundary = "--------------------------" ~ to!string(uniform(0, int.max));
        http.addRequestHeader("Content-Type",
            "multipart/form-data; boundary=" ~ boundary);

        auto body = appender!(ubyte[])();

        void addText(string name, string value)
        {
            body.put(cast(ubyte[])("--" ~ boundary ~ "\r\n"));
            body.put(cast(ubyte[])("Content-Disposition: form-data; name=\"" ~ name ~ "\"\r\n\r\n"));
            body.put(cast(ubyte[]) value);
            body.put(cast(ubyte[]) "\r\n");
        }

        void addFile(string name, string filePath)
        {
            appendFileChunked(body, boundary, name, filePath);
        }

        addFile("file", request.file);
        addText("model", request.model);
        if (request.prompt.length)
            addText("prompt", request.prompt);
        if (request.responseFormat.length)
            addText("response_format", request.responseFormat);
        if (request.temperature != 0)
            addText("temperature", to!string(request.temperature));

        body.put(cast(ubyte[])("--" ~ boundary ~ "--\r\n"));

        auto content = post!ubyte(buildUrl("/audio/translations"), body.data, http);

        auto text = cast(char[]) content;
        return text.deserializeJson!AudioTextResponse();
    }

    ///
    ResponsesResponse createResponse(in CreateResponseRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.model.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto requestJson = serializeJson(request);
        auto content = cast(char[]) post!ubyte(buildUrl("/responses"), requestJson, http);

        auto result = content.deserializeJson!ResponsesResponse();
        return result;
    }

    ///
    ResponsesResponse getResponse(string responseId, string[] include = null) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (responseId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildUrl("/responses/" ~ responseId);
        if (include !is null && include.length)
            url ~= "?include=" ~ cast(string) include.joiner(",").array;

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        auto result = content.deserializeJson!ResponsesResponse();
        return result;
    }

    ///
    void deleteResponse(string responseId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (responseId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        del(buildUrl("/responses/" ~ responseId), http);
    }

    ///
    ResponseItemList listInputItems(in ListInputItemsRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.responseId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        import std.string : format;
        import std.algorithm : map;
        import std.conv : to;

        string url = buildUrl("/responses/" ~ request.responseId ~ "/input_items");
        string sep = "?";
        url ~= format("%slimit=%s", sep, request.limit);
        sep = "&";
        if (request.order.length)
            url ~= format("%sorder=%s", sep, request.order), sep = "&";
        if (request.after !is null)
            url ~= format("%safter=%s", sep, request.after), sep = "&";
        if (request.before !is null)
            url ~= format("%sbefore=%s", sep, request.before), sep = "&";
        if (request.include !is null && request.include.length)
            url ~= format("%sinclude=%s", sep,
                cast(string) request.include.map!(x => to!string(x)).joiner(",").array);

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        auto result = content.deserializeJson!ResponseItemList();
        return result;
    }

    private void setupHttpByConfig(scope ref HTTP http) @system
    {
        import std.algorithm.searching : canFind;

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

    @("buildUrl - openai mode")
    unittest
    {
        auto cfg = new OpenAIClientConfig;
        cfg.apiKey = "k";
        auto client = new OpenAIClient(cfg);
        assert(client.buildUrl("/models") == "https://api.openai.com/v1/models");
    }

    @("buildUrl - openai mode with trailing slash")
    unittest
    {
        auto cfg = new OpenAIClientConfig;
        cfg.apiKey = "k";
        cfg.apiBase = "https://api.openai.com/v1/";
        auto client = new OpenAIClient(cfg);
        assert(client.buildUrl("/models") == "https://api.openai.com/v1/models");
    }

    @("buildUrl - azure mode")
    unittest
    {
        auto cfg = new OpenAIClientConfig;
        cfg.apiKey = "k";
        cfg.apiBase = "https://westus.api.cognitive.microsoft.com";
        cfg.deploymentId = "dep";
        cfg.apiVersion = "2024-05-01";
        auto client = new OpenAIClient(cfg);
        assert(client.buildUrl("/chat/completions") ==
                "https://westus.api.cognitive.microsoft.com/openai/deployments/dep/chat/completions?api-version=2024-05-01");
    }

    @("buildUrl - azure mode with trailing slash")
    unittest
    {
        auto cfg = new OpenAIClientConfig;
        cfg.apiKey = "k";
        cfg.apiBase = "https://westus.api.cognitive.microsoft.com/";
        cfg.deploymentId = "dep";
        cfg.apiVersion = "2024-05-01";
        auto client = new OpenAIClient(cfg);
        assert(client.buildUrl("/chat/completions") ==
                "https://westus.api.cognitive.microsoft.com/openai/deployments/dep/chat/completions?api-version=2024-05-01");
    }

    @("buildUrl transcription - openai")
    unittest
    {
        auto cfg = new OpenAIClientConfig;
        cfg.apiKey = "k";
        auto client = new OpenAIClient(cfg);
        assert(client.buildUrl("/audio/transcriptions") == "https://api.openai.com/v1/audio/transcriptions");
    }

    @("buildUrl transcription - azure")
    unittest
    {
        auto cfg = new OpenAIClientConfig;
        cfg.apiKey = "k";
        cfg.apiBase = "https://westus.api.cognitive.microsoft.com";
        cfg.deploymentId = "dep";
        cfg.apiVersion = "2024-05-01";
        auto client = new OpenAIClient(cfg);
        assert(client.buildUrl("/audio/transcriptions") ==
                "https://westus.api.cognitive.microsoft.com/openai/deployments/dep/audio/transcriptions?api-version=2024-05-01");
    }

    @("buildUrl translation - openai")
    unittest
    {
        auto cfg = new OpenAIClientConfig;
        cfg.apiKey = "k";
        auto client = new OpenAIClient(cfg);
        assert(client.buildUrl("/audio/translations") ==
                "https://api.openai.com/v1/audio/translations");
    }

    @("buildUrl translation - azure")
    unittest
    {
        auto cfg = new OpenAIClientConfig;
        cfg.apiKey = "k";
        cfg.apiBase = "https://westus.api.cognitive.microsoft.com";
        cfg.deploymentId = "dep";
        cfg.apiVersion = "2024-05-01";
        auto client = new OpenAIClient(cfg);
        assert(client.buildUrl("/audio/translations") ==
                "https://westus.api.cognitive.microsoft.com/openai/deployments/dep/audio/translations?api-version=2024-05-01");
    }

    @("buildUrl speech - openai")
    unittest
    {
        auto cfg = new OpenAIClientConfig;
        cfg.apiKey = "k";
        auto client = new OpenAIClient(cfg);
        assert(client.buildUrl("/audio/speech") ==
                "https://api.openai.com/v1/audio/speech");
    }

    @("buildUrl speech - azure")
    unittest
    {
        auto cfg = new OpenAIClientConfig;
        cfg.apiKey = "k";
        cfg.apiBase = "https://westus.api.cognitive.microsoft.com";
        cfg.deploymentId = "dep";
        cfg.apiVersion = "2024-05-01";
        auto client = new OpenAIClient(cfg);
        assert(client.buildUrl("/audio/speech") ==
                "https://westus.api.cognitive.microsoft.com/openai/deployments/dep/audio/speech?api-version=2024-05-01");
    }
}

@("config from environment - openai mode")
unittest
{
    import std.process : environment;

    environment[ENV_OPENAI_API_KEY] = "k";
    scope (exit)
        environment.remove(ENV_OPENAI_API_KEY);
    environment.remove(ENV_OPENAI_API_BASE);
    scope (exit)
        environment.remove(ENV_OPENAI_API_BASE);
    auto cfg = OpenAIClientConfig.fromEnvironment();

    assert(!cfg.isAzure);
    assert(cfg.apiBase == "https://api.openai.com/v1");
}

@("config from environment - azure mode")
unittest
{
    import std.process : environment;

    environment[ENV_OPENAI_API_KEY] = "k";
    scope (exit)
        environment.remove(ENV_OPENAI_API_KEY);
    environment[ENV_OPENAI_API_BASE] = "https://example.api.cognitive.microsoft.com";
    scope (exit)
        environment.remove(ENV_OPENAI_API_BASE);
    environment[ENV_OPENAI_DEPLOYMENT_ID] = "dep";
    scope (exit)
        environment.remove(ENV_OPENAI_DEPLOYMENT_ID);
    environment[ENV_OPENAI_API_VERSION] = "2024-05-01";
    scope (exit)
        environment.remove(ENV_OPENAI_API_VERSION);

    auto cfg = OpenAIClientConfig.fromEnvironment();

    assert(cfg.isAzure);
    assert(cfg.deploymentId == "dep");
    assert(cfg.apiVersion == "2024-05-01");
}

@("azure mode requires deployment id")
unittest
{
    import std.process : environment;
    import std.exception : assertThrown;

    environment[ENV_OPENAI_API_KEY] = "k";
    scope (exit)
        environment.remove(ENV_OPENAI_API_KEY);
    environment[ENV_OPENAI_API_BASE] = "https://example.api.cognitive.microsoft.com";
    scope (exit)
        environment.remove(ENV_OPENAI_API_BASE);
    environment.remove(ENV_OPENAI_DEPLOYMENT_ID);
    scope (exit)
        environment.remove(ENV_OPENAI_DEPLOYMENT_ID);

    assertThrown!Exception(new OpenAIClient());
}

@("save & load config file - openai mode")
unittest
{
    import std.file;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    cfg.organization = "org";

    auto tmp = "tmp_cfg.json";
    scope (exit)
        if (exists(tmp))
            remove(tmp);
    cfg.saveToFile(tmp);

    auto loaded = OpenAIClientConfig.fromFile(tmp);
    assert(!loaded.isAzure);
    assert(loaded.apiKey == "k");
    assert(loaded.organization == "org");
}

@("save & load config file - azure mode")
unittest
{
    import std.file;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    cfg.apiBase = "https://example.api.cognitive.microsoft.com";
    cfg.deploymentId = "dep";
    cfg.apiVersion = "2024-05-01";

    auto tmp = "tmp_cfg.json";
    scope (exit)
        if (exists(tmp))
            remove(tmp);
    cfg.saveToFile(tmp);

    auto loaded = OpenAIClientConfig.fromFile(tmp);
    assert(loaded.isAzure);
    assert(loaded.apiKey == "k");
    assert(loaded.apiBase == "https://example.api.cognitive.microsoft.com");
    assert(loaded.deploymentId == "dep");
    assert(loaded.apiVersion == "2024-05-01");
}

@("appendFileChunked") @system unittest
{
    import std.file : write, remove, exists;
    import std.array : appender;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    auto tmp = "tmp_audio.txt";
    write(tmp, "hello");
    scope (exit)
        if (exists(tmp))
            remove(tmp);

    auto body = appender!(ubyte[])();
    client.appendFileChunked(body, "bnd", "file", tmp);

    // Multipart body should contain file data with the exact filename
    auto expected = cast(ubyte[])(
        "--bnd\r\n" ~
            "Content-Disposition: form-data; name=\"file\"; filename=\"tmp_audio.txt\"\r\n" ~
            "Content-Type: application/octet-stream\r\n\r\n" ~
            "hello\r\n");

    assert(body.data == expected);
}
