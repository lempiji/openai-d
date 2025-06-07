/**
OpenAI API Client
*/
module openai.clients.openai;

import mir.deser.json;
import mir.ser.json;
import std.net.curl;

import openai.chat;
import openai.completion;
import openai.embedding;
import openai.models;
import openai.moderation;

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

    ///
    this(string apiKey)
    {
        this.apiKey = apiKey;
    }

    ///
    this(string apiKey, string organization)
    {
        this.apiKey = apiKey;
        this.organization = organization;
    }

    ///
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

    ///
    static OpenAIClientConfig fromFile(string filePath)
    {
        auto config = new OpenAIClientConfig;
        config.loadFromFile(filePath);
        return config;
    }

    ///
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
        auto envApiBase = environment.get(envApiBaseName, "https://api.openai.com/v1");
        auto envDeploymentId = environment.get(envDeploymentName, "");
        auto envApiVersion = environment.get(envApiVersionName, "");

        this.apiKey = envApiKey;
        this.organization = envOrganization;
        this.apiBase = envApiBase.length ? envApiBase : "https://api.openai.com/v1";
        this.deploymentId = envDeploymentId;
        if (envApiVersion.length)
            this.apiVersion = envApiVersion;
    }

    ///
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

    ///
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

    ///
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

    ///
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

    ///
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

    ///
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

    ///
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
}

@("config from environment - openai mode")
unittest
{
    import std.process : environment;

    environment[ENV_OPENAI_API_KEY] = "k";
    scope(exit) environment.remove(ENV_OPENAI_API_KEY);
    environment.remove(ENV_OPENAI_API_BASE);
    scope(exit) environment.remove(ENV_OPENAI_API_BASE);
    auto cfg = OpenAIClientConfig.fromEnvironment();

    assert(!cfg.isAzure);
    assert(cfg.apiBase == "https://api.openai.com/v1");
}

@("config from environment - azure mode")
unittest
{
    import std.process : environment;

    environment[ENV_OPENAI_API_KEY] = "k";
    scope(exit) environment.remove(ENV_OPENAI_API_KEY);
    environment[ENV_OPENAI_API_BASE] = "https://example.api.cognitive.microsoft.com";
    scope(exit) environment.remove(ENV_OPENAI_API_BASE);
    environment[ENV_OPENAI_DEPLOYMENT_ID] = "dep";
    scope(exit) environment.remove(ENV_OPENAI_DEPLOYMENT_ID);
    environment[ENV_OPENAI_API_VERSION] = "2024-05-01";
    scope(exit) environment.remove(ENV_OPENAI_API_VERSION);

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
    scope(exit) environment.remove(ENV_OPENAI_API_KEY);
    environment[ENV_OPENAI_API_BASE] = "https://example.api.cognitive.microsoft.com";
    scope(exit) environment.remove(ENV_OPENAI_API_BASE);
    environment.remove(ENV_OPENAI_DEPLOYMENT_ID);
    scope(exit) environment.remove(ENV_OPENAI_DEPLOYMENT_ID);

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
    scope(exit) if (exists(tmp)) remove(tmp);
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
    scope(exit) if (exists(tmp)) remove(tmp);
    cfg.saveToFile(tmp);

    auto loaded = OpenAIClientConfig.fromFile(tmp);
    assert(loaded.isAzure);
    assert(loaded.apiKey == "k");
    assert(loaded.apiBase == "https://example.api.cognitive.microsoft.com");
    assert(loaded.deploymentId == "dep");
    assert(loaded.apiVersion == "2024-05-01");
}
