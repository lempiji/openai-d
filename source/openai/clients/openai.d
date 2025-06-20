/**
OpenAI API Client
*/
module openai.clients.openai;

import mir.deser.json;
import mir.ser.json;
import std.net.curl;
import std.algorithm.iteration : joiner;
import std.array : array, Appender;
import std.stdio : File;

import openai.chat;
import openai.completion;
import openai.embedding;
import openai.models;
import openai.moderation;
import openai.audio;
import openai.images;
import openai.files;
import openai.responses;
import openai.administration;
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

        enforce(config.apiKey.length > 0,
            "OPENAI_API_KEY is required");

        if (config.isAzure)
        {
            enforce(config.deploymentId.length > 0,
                "OPENAI_DEPLOYMENT_ID is required for Azure mode");
        }
    }

    mixin ClientHelpers;

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
        if (request.include !is null && request.include.length)
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

@("buildMultipartBody") @system unittest
{
    import std.file : write, remove, exists;
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);
    auto http = HTTP();

    auto tmp = "tmp_multi.txt";
    write(tmp, "hi");
    scope (exit)
        if (exists(tmp))
            remove(tmp);

    OpenAIClient.MultipartPart[] files = [OpenAIClient.MultipartPart("file", tmp)];
    OpenAIClient.MultipartPart[] texts = [
        OpenAIClient.MultipartPart("model", "m"),
        OpenAIClient.MultipartPart("prompt", "p")
    ];

    auto body = client.buildMultipartBody(http, texts, files);
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

@("buildListAuditLogsUrl encodes new query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    AuditLogTimeRange range;
    range.gt = 10;
    range.lte = 20;

    auto req = listAuditLogsRequest(5, null, null, null, ["a@example.com"],
        ["res id"], range);
    auto url = client.buildListAuditLogsUrl(req);

    assert(url.canFind("actor_emails=a%40example.com"));
    assert(url.canFind("resource_ids=res%20id"));
    assert(url.canFind("effective_at[gt]=10"));
    assert(url.canFind("effective_at[lte]=20"));
}

@("buildListFilesUrl")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    auto req = listFilesRequest();
    auto url = client.buildListFilesUrl(req);

    assert(!url.canFind("after="));

    req.after = "a";
    url = client.buildListFilesUrl(req);
    assert(url.canFind("after=a"));

    req.after = "";
    url = client.buildListFilesUrl(req);
    assert(!url.canFind("after="));
}

@("buildListFilesUrl encodes query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    auto req = listFilesRequest();
    req.purpose = "fine tune";
    req.after = "foo bar";
    auto url = client.buildListFilesUrl(req);

    assert(url.canFind("purpose=fine%20tune"));
    assert(url.canFind("after=foo%20bar"));
}

@("buildListUsageUrl encodes query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    auto req = listUsageRequest(1);
    req.bucketWidth = "day";
    req.projectIds = ["p id"];
    req.userIds = ["u id"];
    req.apiKeyIds = ["key id"];
    req.models = ["gpt 4"];
    req.groupBy = ["project_id"];
    req.limit = 3;
    req.page = "foo bar";
    req.batch = true;
    auto url = client.buildListUsageUrl("completions", req);

    assert(url.canFind("start_time=1"));
    assert(url.canFind("bucket_width=day"));
    assert(url.canFind("project_ids=p%20id"));
    assert(url.canFind("user_ids=u%20id"));
    assert(url.canFind("api_key_ids=key%20id"));
    assert(url.canFind("models=gpt%204"));
    assert(url.canFind("group_by=project_id"));
    assert(url.canFind("limit=3"));
    assert(url.canFind("page=foo%20bar"));
    assert(url.canFind("batch=true"));
}

@("buildListCostsUrl encodes query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    auto req = listCostsRequest(2);
    req.bucketWidth = "month";
    req.projectIds = ["p id"];
    req.groupBy = ["project_id"];
    req.limit = 5;
    req.page = "bar+baz";
    auto url = client.buildListCostsUrl(req);

    assert(url.canFind("start_time=2"));
    assert(url.canFind("bucket_width=month"));
    assert(url.canFind("project_ids=p%20id"));
    assert(url.canFind("group_by=project_id"));
    assert(url.canFind("limit=5"));
    assert(url.canFind("page=bar%2Bbaz"));
}

@("buildListInvitesUrl")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    auto req = ListInvitesRequest();
    auto url = client.buildListInvitesUrl(req);

    assert(!url.canFind("limit="));
    assert(!url.canFind("after="));

    req.limit = 2;
    url = client.buildListInvitesUrl(req);
    assert(url.canFind("limit=2"));

    req.limit = 0;
    req.after = "foo";
    url = client.buildListInvitesUrl(req);
    assert(url.canFind("after=foo"));
    assert(!url.canFind("limit="));
}

@("buildListInvitesUrl encodes query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    auto req = ListInvitesRequest();
    req.limit = 3;
    req.after = "foo bar";
    auto url = client.buildListInvitesUrl(req);

    assert(url.canFind("limit=3"));
    assert(url.canFind("after=foo%20bar"));
}

@("buildListProjectServiceAccountsUrl")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    auto req = ListProjectServiceAccountsRequest();
    auto url = client.buildListProjectServiceAccountsUrl("p", req);

    assert(!url.canFind("limit="));
    assert(!url.canFind("after="));

    req.limit = 2;
    url = client.buildListProjectServiceAccountsUrl("p", req);
    assert(url.canFind("limit=2"));

    req.limit = 0;
    req.after = "foo";
    url = client.buildListProjectServiceAccountsUrl("p", req);
    assert(url.canFind("after=foo"));
    assert(!url.canFind("limit="));
}

@("buildListProjectServiceAccountsUrl encodes query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    auto req = ListProjectServiceAccountsRequest();
    req.limit = 3;
    req.after = "foo bar";
    auto url = client.buildListProjectServiceAccountsUrl("p", req);

    assert(url.canFind("limit=3"));
    assert(url.canFind("after=foo%20bar"));
}

@("buildListProjectRateLimitsUrl")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    auto req = ListProjectRateLimitsRequest();
    auto url = client.buildListProjectRateLimitsUrl("p", req);

    assert(!url.canFind("limit="));
    assert(!url.canFind("after="));

    req.limit = 2;
    url = client.buildListProjectRateLimitsUrl("p", req);
    assert(url.canFind("limit=2"));

    req.limit = 0;
    req.after = "foo";
    url = client.buildListProjectRateLimitsUrl("p", req);
    assert(url.canFind("after=foo"));
    assert(!url.canFind("limit="));
}

@("buildListProjectRateLimitsUrl encodes query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    auto req = ListProjectRateLimitsRequest();
    req.limit = 3;
    req.after = "foo bar";
    auto url = client.buildListProjectRateLimitsUrl("p", req);

    assert(url.canFind("limit=3"));
    assert(url.canFind("after=foo%20bar"));
}

@("buildListUsersUrl")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    auto req = ListUsersRequest();
    auto url = client.buildListUsersUrl(req);

    assert(!url.canFind("limit="));
    assert(!url.canFind("after="));

    req.limit = 2;
    url = client.buildListUsersUrl(req);
    assert(url.canFind("limit=2"));

    req.limit = 0;
    req.after = "foo";
    url = client.buildListUsersUrl(req);
    assert(url.canFind("after=foo"));
    assert(!url.canFind("limit="));
}

@("buildListUsersUrl encodes query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    auto req = ListUsersRequest();
    req.limit = 3;
    req.after = "foo bar";
    auto url = client.buildListUsersUrl(req);

    assert(url.canFind("limit=3"));
    assert(url.canFind("after=foo%20bar"));
}

@("buildListProjectUsersUrl")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    auto req = ListProjectUsersRequest();
    auto url = client.buildListProjectUsersUrl("p", req);

    assert(!url.canFind("limit="));
    assert(!url.canFind("after="));

    req.limit = 2;
    url = client.buildListProjectUsersUrl("p", req);
    assert(url.canFind("limit=2"));

    req.limit = 0;
    req.after = "foo";
    url = client.buildListProjectUsersUrl("p", req);
    assert(url.canFind("after=foo"));
    assert(!url.canFind("limit="));
}

@("buildListProjectUsersUrl encodes query parameters")
unittest
{
    import std.algorithm.searching : canFind;

    auto cfg = new OpenAIClientConfig;
    cfg.apiKey = "k";
    auto client = new OpenAIClient(cfg);

    auto req = ListProjectUsersRequest();
    req.limit = 3;
    req.after = "foo bar";
    auto url = client.buildListProjectUsersUrl("p", req);

    assert(url.canFind("limit=3"));
    assert(url.canFind("after=foo%20bar"));
}
