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
class OpenAIClientConfig
{
    string apiKey;
    string organization;

    private this()
    {
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
    static OpenAIClientConfig fromEnvironment(string envApiKeyName = ENV_OPENAI_API_KEY, string envOrgName = ENV_OPENAI_ORGANIZATION)
    {
        auto config = new OpenAIClientConfig;
        config.loadFromEnvironmentVariables(envApiKeyName, envOrgName);
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
    void loadFromEnvironmentVariables(string envApiKeyName = ENV_OPENAI_API_KEY, string envOrgName = ENV_OPENAI_ORGANIZATION)
    {
        import std.process : environment;

        auto envApiKey = environment.get(envApiKeyName, "");
        auto envOrganization = environment.get(envOrgName, "");

        this.apiKey = envApiKey;
        this.organization = envOrganization;
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
        }

        auto config = deserializeJson!ConfigData(configText);
        this.apiKey = config.apiKey;
        this.organization = config.organization;
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
    }

    ///
    this(OpenAIClientConfig config)
    in (config !is null)
    do
    {
        this.config = config;
    }

    ///
    ModelsResponse listModels() @system
    in (config.apiKey != null && config.apiKey.length > 0)
    do
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        auto content = cast(char[]) get!(HTTP, ubyte)("https://api.openai.com/v1/models", http);
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
        auto content = cast(char[]) post!ubyte("https://api.openai.com/v1/completions", requestJson, http);

        // import std.stdio;
        // writeln(content);

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
        auto content = cast(char[]) post!ubyte("https://api.openai.com/v1/chat/completions", requestJson, http);

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
        auto content = cast(char[]) post!ubyte("https://api.openai.com/v1/embeddings", requestJson, http);

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
        auto content = cast(char[]) post!ubyte("https://api.openai.com/v1/moderations", requestJson, http);

        // import std.stdio;
        // writeln(content);

        auto result = content.deserializeJson!ModerationResponse();
        return result;
    }

    private void setupHttpByConfig(scope ref HTTP http) @system
    {
        http.addRequestHeader("Authorization", "Bearer " ~ config.apiKey);
        if (config.organization.length > 0)
        {
            http.addRequestHeader("OpenAI-Organization", config.organization);
        }
    }
}
