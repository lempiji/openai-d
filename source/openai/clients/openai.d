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
            "/responses/" ~ request.responseId ~ "/input_items");
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

        auto b = QueryParamsBuilder("/responses/" ~ responseId);
        if (include !is null && include.length)
            b.add("include", include.map!(x => to!string(x)).array);
        return b.finish();
    }

    private string buildListFilesUrl(in ListFilesRequest request) const @safe
    {
        auto b = QueryParamsBuilder("/files");
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
        return getJson!ModelsResponse("/models");
    }

    /// Call the `/completions` endpoint.
    /// `request.model` must be set and an API key must be present.
    CompletionResponse completion(in CompletionRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.model.length > 0)
    do
    {
        return postJson!CompletionResponse("/completions", request);
    }

    /// Call the `/chat/completions` endpoint.
    /// Requires a model name and valid API key.
    ChatCompletionResponse chatCompletion(in ChatCompletionRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.model.length > 0)
    {
        return postJson!ChatCompletionResponse("/chat/completions", request);
    }

    /// Request vector embeddings via the `/embeddings` endpoint.
    /// The request must specify a model.
    EmbeddingResponse embedding(in EmbeddingRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.model.length > 0)
    {
        return postJson!EmbeddingResponse("/embeddings", request);
    }

    /// Perform content classification using `/moderations`.
    /// `request.input` must not be empty.
    ModerationResponse moderation(in ModerationRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.input.length > 0)
    {
        return postJson!ModerationResponse("/moderations", request);
    }

    /// Convert text to speech using `/audio/speech`.
    /// The request requires `model`, `input` and `voice` fields.
    ubyte[] speech(in SpeechRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.model.length > 0)
    in (request.input.length > 0)
    in (request.voice.length > 0)
    {
        auto http = makeHttp("application/octet-stream", "application/json");

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

        auto http = makeHttp("application/json; charset=utf-8");

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

        auto http = makeHttp("application/json; charset=utf-8");

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
        return postJson!ImageResponse("/images/generations", request);
    }

    /// Edit an image via `/images/edits`.
    ImageResponse imageEdit(in ImageEditRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.image.length > 0)
    in (request.prompt.length > 0)
    {
        import std.conv : to;

        auto http = makeHttp("application/json; charset=utf-8");

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

        auto http = makeHttp("application/json; charset=utf-8");

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
        return getJson!FileListResponse(buildListFilesUrl(request));
    }

    /// Upload a file.
    FileObject uploadFile(in FileUploadRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.file.length > 0)
    in (request.purpose.length > 0)
    {
        auto http = makeHttp("application/json; charset=utf-8");

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
        return getJson!FileObject("/files/" ~ fileId);
    }

    /// Delete a file.
    DeleteFileResponse deleteFile(string fileId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (fileId.length > 0)
    {
        return deleteJson!DeleteFileResponse("/files/" ~ fileId);
    }

    /// Download the file content.
    ubyte[] downloadFileContent(string fileId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (fileId.length > 0)
    {
        auto http = makeHttp("application/octet-stream");

        auto content = get!(HTTP, ubyte)(buildUrl("/files/" ~ fileId ~ "/content"), http);
        return cast(ubyte[]) content;
    }

    ///
    ResponsesResponse createResponse(in CreateResponseRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.model.length > 0)
    {
        return postJson!ResponsesResponse("/responses", request);
    }

    ///
    ResponsesResponse getResponse(string responseId, string[] include = null) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (responseId.length > 0)
    {
        return getJson!ResponsesResponse(buildGetResponseUrl(responseId, include));
    }

    ///
    void deleteResponse(string responseId) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (responseId.length > 0)
    {
        deleteJson!string("/responses/" ~ responseId);
    }

    ///
    ResponsesItemListResponse listInputItems(in ListInputItemsRequest request) @system
    in (config.apiKey != null && config.apiKey.length > 0)
    in (request.responseId.length > 0)
    {
        return getJson!ResponsesItemListResponse(buildListInputItemsUrl(request));
    }

    @("buildUrl variations")
    unittest
    {
        import std.typecons : tuple;

        void checkUrl(string desc, string apiBase, string path, string expected)
        {
            auto cfg = new OpenAIClientConfig;
            cfg.apiKey = "k";
            cfg.apiBase = apiBase;
            cfg.deploymentId = "dep";
            cfg.apiVersion = "2024-05-01";
            auto client = new OpenAIClient(cfg);
            assert(client.buildUrl(path) == expected, desc);
        }

        foreach (t; [
            tuple("openai mode", "https://api.openai.com/v1", "/models",
                "https://api.openai.com/v1/models"),
            tuple("openai mode with trailing slash",
                "https://api.openai.com/v1/", "/models",
                "https://api.openai.com/v1/models"),
            tuple("azure mode",
                "https://westus.api.cognitive.microsoft.com",
                "/chat/completions",
                "https://westus.api.cognitive.microsoft.com/openai/deployments/dep/chat/completions?api-version=2024-05-01"),
            tuple("azure mode with trailing slash",
                "https://westus.api.cognitive.microsoft.com/",
                "/chat/completions",
                "https://westus.api.cognitive.microsoft.com/openai/deployments/dep/chat/completions?api-version=2024-05-01"),
            tuple("transcription - openai", "https://api.openai.com/v1",
                "/audio/transcriptions",
                "https://api.openai.com/v1/audio/transcriptions"),
            tuple("transcription - azure",
                "https://westus.api.cognitive.microsoft.com",
                "/audio/transcriptions",
                "https://westus.api.cognitive.microsoft.com/openai/deployments/dep/audio/transcriptions?api-version=2024-05-01"),
            tuple("translation - openai", "https://api.openai.com/v1",
                "/audio/translations",
                "https://api.openai.com/v1/audio/translations"),
            tuple("translation - azure",
                "https://westus.api.cognitive.microsoft.com",
                "/audio/translations",
                "https://westus.api.cognitive.microsoft.com/openai/deployments/dep/audio/translations?api-version=2024-05-01"),
            tuple("speech - openai", "https://api.openai.com/v1",
                "/audio/speech",
                "https://api.openai.com/v1/audio/speech"),
            tuple("speech - azure",
                "https://westus.api.cognitive.microsoft.com",
                "/audio/speech",
                "https://westus.api.cognitive.microsoft.com/openai/deployments/dep/audio/speech?api-version=2024-05-01"),
            tuple("image generation - openai", "https://api.openai.com/v1",
                "/images/generations",
                "https://api.openai.com/v1/images/generations"),
            tuple("image generation - azure",
                "https://westus.api.cognitive.microsoft.com",
                "/images/generations",
                "https://westus.api.cognitive.microsoft.com/openai/deployments/dep/images/generations?api-version=2024-05-01"),
            tuple("image edit - openai", "https://api.openai.com/v1",
                "/images/edits",
                "https://api.openai.com/v1/images/edits"),
            tuple("image edit - azure",
                "https://westus.api.cognitive.microsoft.com",
                "/images/edits",
                "https://westus.api.cognitive.microsoft.com/openai/deployments/dep/images/edits?api-version=2024-05-01"),
            tuple("image variation - openai", "https://api.openai.com/v1",
                "/images/variations",
                "https://api.openai.com/v1/images/variations"),
            tuple("image variation - azure",
                "https://westus.api.cognitive.microsoft.com",
                "/images/variations",
                "https://westus.api.cognitive.microsoft.com/openai/deployments/dep/images/variations?api-version=2024-05-01")
        ])
        {
            checkUrl(t[0], t[1], t[2], t[3]);
        }
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
