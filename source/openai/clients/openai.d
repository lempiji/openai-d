/**
OpenAI API Client
*/
module openai.clients.openai;

import mir.deser.json;
import mir.ser.json;
import std.net.curl;
import std.array : array;

import openai.chat;
import openai.completion;
import openai.embedding;
import openai.models;
import openai.moderation;
import openai.audio;
import openai.images;
import openai.files;
import openai.responses;
import openai.clients.helpers;
import openai.clients.config;

@safe:

///
class OpenAIClient
{
    ///
    OpenAIClientConfig config;

    ///
    this()
    {
        this.config = OpenAIClientConfig.fromEnvironment();
        config.validate();
    }

    ///
    this(OpenAIClientConfig config)
    in (config !is null)
    do
    {
        this.config = config;
        this.config.validate();
    }

    mixin ClientHelpers;

    private string buildListInputItemsUrl(in ListInputItemsRequest request) const @safe
    {
        import std.algorithm : map;

        auto b = QueryParamsBuilder(
            buildUrl("/responses/" ~ request.responseId ~ "/input_items"));
        b.add("limit", request.limit);
        b.add("order", request.order);
        b.add("after", request.after);
        b.add("before", request.before);
        if (request.include !is null && request.include.length)
        {
            import std.conv : to;

            b.add("include",
                request.include.map!(x => to!string(x)).array);
        }
        return b.finish();
    }

    private string buildGetResponseUrl(string responseId, string[] include) const @safe
    {
        import std.algorithm : map;
        import std.array : array;
        import std.conv : to;

        auto b = QueryParamsBuilder(buildUrl("/responses/" ~ responseId));
        if (include !is null && include.length)
            b.add("include", include.map!(x => to!string(x)).array);
        return b.finish();
    }

    private string buildListFilesUrl(in ListFilesRequest request) const @safe
    {
        auto b = QueryParamsBuilder(buildUrl("/files"));
        b.add("purpose", request.purpose);
        b.add("limit", request.limit);
        b.add("order", request.order);
        b.add("after", request.after);
        // 'before' parameter removed in API; no longer supported
        return b.finish();
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
        import std.conv : to;

        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        MultipartPart[] files = [MultipartPart("file", request.file)];
        MultipartPart[] texts;
        texts ~= MultipartPart("model", request.model);
        if (request.language.length)
            texts ~= MultipartPart("language", request.language);
        if (request.prompt.length)
            texts ~= MultipartPart("prompt", request.prompt);
        if (request.responseFormat.length)
            texts ~= MultipartPart("response_format", request.responseFormat);
        if (request.temperature != 0)
            texts ~= MultipartPart("temperature", to!string(request.temperature));
        foreach (inc; request.include)
            texts ~= MultipartPart("include", inc);
        foreach (t; request.timestampGranularities)
            texts ~= MultipartPart("timestamp_granularities", t);
        if (request.stream)
            texts ~= MultipartPart("stream", "true");

        auto body = buildMultipartBody(http, texts, files);

        auto content = post!ubyte(buildUrl("/audio/transcriptions"), body, http);

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
        import std.conv : to;

        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        MultipartPart[] files = [MultipartPart("file", request.file)];
        MultipartPart[] texts;
        texts ~= MultipartPart("model", request.model);
        if (request.prompt.length)
            texts ~= MultipartPart("prompt", request.prompt);
        if (request.responseFormat.length)
            texts ~= MultipartPart("response_format", request.responseFormat);
        if (request.temperature != 0)
            texts ~= MultipartPart("temperature", to!string(request.temperature));

        auto body = buildMultipartBody(http, texts, files);

        auto content = post!ubyte(buildUrl("/audio/translations"), body, http);

        auto text = cast(char[]) content;
        return text.deserializeJson!AudioTextResponse();
    }

    /// Generate an image via `/images/generations`.
    ImageResponse imageGeneration(in ImageGenerationRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.prompt.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");
        http.addRequestHeader("Content-Type", "application/json");

        auto requestJson = serializeJson(request);
        auto content = cast(char[]) post!ubyte(buildUrl("/images/generations"), requestJson, http);

        auto result = content.deserializeJson!ImageResponse();
        return result;
    }

    /// Edit an image via `/images/edits`.
    ImageResponse imageEdit(in ImageEditRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.image.length > 0)
    in (request.prompt.length > 0)
    {
        import std.conv : to;

        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        MultipartPart[] files = [MultipartPart("image", request.image)];
        if (request.mask.length)
            files ~= MultipartPart("mask", request.mask);
        MultipartPart[] texts;
        texts ~= MultipartPart("prompt", request.prompt);
        if (request.model.length)
            texts ~= MultipartPart("model", request.model);
        if (request.n != 0)
            texts ~= MultipartPart("n", to!string(request.n));
        if (request.size.length)
            texts ~= MultipartPart("size", request.size);
        if (request.responseFormat.length)
            texts ~= MultipartPart("response_format", request.responseFormat);
        if (request.user.length)
            texts ~= MultipartPart("user", request.user);

        auto body = buildMultipartBody(http, texts, files);

        auto content = cast(char[]) post!ubyte(buildUrl("/images/edits"), body, http);

        auto result = content.deserializeJson!ImageResponse();
        return result;
    }

    /// Create image variations via `/images/variations`.
    ImageResponse imageVariation(in ImageVariationRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.image.length > 0)
    {
        import std.conv : to;

        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        MultipartPart[] files = [MultipartPart("image", request.image)];
        MultipartPart[] texts;
        if (request.model.length)
            texts ~= MultipartPart("model", request.model);
        if (request.n != 0)
            texts ~= MultipartPart("n", to!string(request.n));
        if (request.size.length)
            texts ~= MultipartPart("size", request.size);
        if (request.responseFormat.length)
            texts ~= MultipartPart("response_format", request.responseFormat);
        if (request.user.length)
            texts ~= MultipartPart("user", request.user);

        auto body = buildMultipartBody(http, texts, files);

        auto content = cast(char[]) post!ubyte(buildUrl("/images/variations"), body, http);

        auto result = content.deserializeJson!ImageResponse();
        return result;
    }

    /// List uploaded files.
    FileListResponse listFiles(in ListFilesRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListFilesUrl(request);

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        return content.deserializeJson!FileListResponse();
    }

    /// Upload a file.
    FileObject uploadFile(in FileUploadRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.file.length > 0)
    in (request.purpose.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        MultipartPart[] files = [MultipartPart("file", request.file)];
        MultipartPart[] texts = [MultipartPart("purpose", request.purpose)];

        auto body = buildMultipartBody(http, texts, files);

        auto content = cast(char[]) post!ubyte(buildUrl("/files"), body, http);
        return content.deserializeJson!FileObject();
    }

    /// Retrieve a file by ID.
    FileObject retrieveFile(string fileId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (fileId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        auto content = cast(char[]) get!(HTTP, ubyte)(buildUrl("/files/" ~ fileId), http);
        return content.deserializeJson!FileObject();
    }

    /// Delete a file.
    DeleteFileResponse deleteFile(string fileId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (fileId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        import std.array : appender;

        auto buf = appender!(char[])();
        http.onReceive = (ubyte[] data) { buf.put(cast(char[]) data); return data.length; };
        del(buildUrl("/files/" ~ fileId), http);
        auto content = buf.data;
        return content.deserializeJson!DeleteFileResponse();
    }

    /// Download the file content.
    ubyte[] downloadFileContent(string fileId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (fileId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/octet-stream");

        auto content = get!(HTTP, ubyte)(buildUrl("/files/" ~ fileId ~ "/content"), http);
        return cast(ubyte[]) content;
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
        debug scope (failure)
        {
            import std.stdio;

            writeln("----------");
            writeln("# createResponse requestJson");
            writeln(requestJson);
            writeln("----------");
        }
        auto content = cast(char[]) post!ubyte(buildUrl("/responses"), requestJson, http);
        debug scope (failure)
        {
            import std.stdio;

            writeln("-----------");
            writeln("# createResponse responseContent");
            writeln(content);
            writeln("-----------");
        }

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

        string url = buildGetResponseUrl(responseId, include);

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
    ResponsesItemListResponse listInputItems(in ListInputItemsRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.responseId.length > 0)
    {
        auto http = HTTP();
        setupHttpByConfig(http);
        http.addRequestHeader("Accept", "application/json; charset=utf-8");

        string url = buildListInputItemsUrl(request);

        auto content = cast(char[]) get!(HTTP, ubyte)(url, http);
        auto result = content.deserializeJson!ResponsesItemListResponse();
        return result;
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

    @("buildUrl image generation - openai")
    unittest
    {
        auto cfg = new OpenAIClientConfig;
        cfg.apiKey = "k";
        auto client = new OpenAIClient(cfg);
        assert(client.buildUrl("/images/generations") ==
                "https://api.openai.com/v1/images/generations");
    }

    @("buildUrl image generation - azure")
    unittest
    {
        auto cfg = new OpenAIClientConfig;
        cfg.apiKey = "k";
        cfg.apiBase = "https://westus.api.cognitive.microsoft.com";
        cfg.deploymentId = "dep";
        cfg.apiVersion = "2024-05-01";
        auto client = new OpenAIClient(cfg);
        assert(client.buildUrl("/images/generations") ==
                "https://westus.api.cognitive.microsoft.com/openai/deployments/dep/images/generations?api-version=2024-05-01");
    }

    @("buildUrl image edit - openai")
    unittest
    {
        auto cfg = new OpenAIClientConfig;
        cfg.apiKey = "k";
        auto client = new OpenAIClient(cfg);
        assert(client.buildUrl("/images/edits") ==
                "https://api.openai.com/v1/images/edits");
    }

    @("buildUrl image edit - azure")
    unittest
    {
        auto cfg = new OpenAIClientConfig;
        cfg.apiKey = "k";
        cfg.apiBase = "https://westus.api.cognitive.microsoft.com";
        cfg.deploymentId = "dep";
        cfg.apiVersion = "2024-05-01";
        auto client = new OpenAIClient(cfg);
        assert(client.buildUrl("/images/edits") ==
                "https://westus.api.cognitive.microsoft.com/openai/deployments/dep/images/edits?api-version=2024-05-01");
    }

    @("buildUrl image variation - openai")
    unittest
    {
        auto cfg = new OpenAIClientConfig;
        cfg.apiKey = "k";
        auto client = new OpenAIClient(cfg);
        assert(client.buildUrl("/images/variations") ==
                "https://api.openai.com/v1/images/variations");
    }

    @("buildUrl image variation - azure")
    unittest
    {
        auto cfg = new OpenAIClientConfig;
        cfg.apiKey = "k";
        cfg.apiBase = "https://westus.api.cognitive.microsoft.com";
        cfg.deploymentId = "dep";
        cfg.apiVersion = "2024-05-01";
        auto client = new OpenAIClient(cfg);
        assert(client.buildUrl("/images/variations") ==
                "https://westus.api.cognitive.microsoft.com/openai/deployments/dep/images/variations?api-version=2024-05-01");
    }
}

@("config from environment - openai mode")
unittest
{
    import std.algorithm.searching : canFind;
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

@("missing API key throws")
unittest
{
    import std.exception : assertThrown;

    assertThrown!Exception(new OpenAIClient(new OpenAIClientConfig()));
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
    import helpers = openai.clients.helpers;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";

    auto tmp = "tmp_audio.txt";
    write(tmp, "hello");
    scope (exit)
        if (exists(tmp))
            remove(tmp);

    auto body = appender!(ubyte[])();
    helpers.appendFileChunked(body, "bnd", "file", tmp);

    // Multipart body should contain file data with the exact filename
    auto expected = cast(ubyte[])(
        "--bnd\r\n" ~
            "Content-Disposition: form-data; name=\"file\"; filename=\"tmp_audio.txt\"\r\n" ~
            "Content-Type: application/octet-stream\r\n\r\n" ~
            "hello\r\n");

    assert(body.data == expected);
}

@("buildMultipartBody") @system unittest
{
    import std.file : write, remove, exists;
    import std.algorithm.searching : canFind;
    import helpers = openai.clients.helpers;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto http = HTTP();

    auto tmp = "tmp_multi.txt";
    write(tmp, "hi");
    scope (exit)
        if (exists(tmp))
            remove(tmp);

    helpers.MultipartPart[] files = [helpers.MultipartPart("file", tmp)];
    helpers.MultipartPart[] texts = [
        helpers.MultipartPart("model", "m"),
        helpers.MultipartPart("prompt", "p")
    ];

    auto body = helpers.buildMultipartBody(http, texts, files);
    auto s = cast(string)
    body;
    assert(s.canFind("filename=\"tmp_multi.txt\""));
    assert(s.canFind("name=\"model\""));
    assert(s.canFind("name=\"prompt\""));
    assert(s.canFind("hi"));
}

@("buildListInputItemsUrl")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    auto req = listInputItemsRequest("resp");
    auto url = client.buildListInputItemsUrl(req);

    assert(!url.canFind("after="));
    assert(!url.canFind("before="));

    req.after = "a";
    url = client.buildListInputItemsUrl(req);
    assert(url.canFind("after=a"));

    req.after = "";
    req.before = "b";
    url = client.buildListInputItemsUrl(req);
    assert(url.canFind("before=b"));
    assert(!url.canFind("after="));
}

@("buildListInputItemsUrl encodes query values")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    auto req = listInputItemsRequest("resp");
    req.order = "custom @order";
    req.after = "foo bar";
    req.before = "bar+baz";
    auto url = client.buildListInputItemsUrl(req);

    assert(url.canFind("order=custom%20%40order"));
    assert(url.canFind("after=foo%20bar"));
    assert(url.canFind("before=bar%2Bbaz"));
}

@("getResponse encodes include values")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    auto url = client.buildGetResponseUrl("resp", ["foo bar", "bar+baz"]);

    assert(url.canFind("include=foo%20bar,bar%2Bbaz"));
}
