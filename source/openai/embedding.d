/**
OpenAI API Embeddings

Standards: https://platform.openai.com/docs/api-reference/embeddings
*/
module openai.embedding;

import mir.algebraic;
import mir.serde;

import openai.common;

@safe:

///
alias EmbeddingInput = Algebraic!(string, string[]);

///
struct EmbeddingRequest
{
    ///
    EmbeddingInput input;

    ///
    @serdeIgnoreDefault
    string model;

    ///
    @serdeIgnoreDefault
    @serdeKeys("encoding_format")
    string encodingFormat;

    @serdeIgnoreDefault
    uint dimensions;

    ///
    @serdeIgnoreDefault
    string user;
}

/**
 * Constructs an `EmbeddingRequest` for the `/embeddings` endpoint using a
 * single input string.
 *
 * Params:
 *     model = Embedding model identifier.
 *     input = Text to embed.
 *
 * Returns: Request object for `OpenAIClient.embedding`.
 */
EmbeddingRequest embeddingRequest(string model, string input)
{
    auto request = EmbeddingRequest();
    request.model = model;
    request.input = input;
    return request;
}

///
unittest
{
    auto request = embeddingRequest("text-embedding-ada-002", "Hello, D Programming Language!");

    import mir.ser.json : serializeJson;

    string requestJson = request.serializeJson();

    assert(
        requestJson == `{"input":"Hello, D Programming Language!","model":"text-embedding-ada-002"}`);
}

/**
 * Constructs an `EmbeddingRequest` with a specified embedding dimension for the
 * `/embeddings` endpoint.
 *
 * Params:
 *     model      = Embedding model identifier.
 *     input      = Text to embed.
 *     dimensions = Size of the output vector.
 *
 * Returns: Request object for `OpenAIClient.embedding`.
 */
EmbeddingRequest embeddingRequest(string model, string input, uint dimensions)
{
    auto request = EmbeddingRequest();
    request.model = model;
    request.input = input;
    request.dimensions = dimensions;
    return request;
}

///
unittest
{
    auto request = embeddingRequest("text-embedding-3-small", "Hello, D Programming Language!", 512);

    import mir.ser.json : serializeJson;

    string requestJson = request.serializeJson();

    assert(
        requestJson == `{"input":"Hello, D Programming Language!","model":"text-embedding-3-small","dimensions":512}`);
}

/**
 * Creates an `EmbeddingRequest` for multiple input strings for the
 * `/embeddings` endpoint.
 *
 * Params:
 *     model  = Embedding model identifier.
 *     inputs = Array of texts to embed.
 *
 * Returns: Request object for `OpenAIClient.embedding`.
 */
EmbeddingRequest embeddingRequest(string model, string[] inputs)
{
    auto request = EmbeddingRequest();
    request.model = model;
    request.input = inputs;
    return request;
}

///
unittest
{
    auto inputs = ["Hello,", "D", "Programming", "Language!"];
    auto request3 = embeddingRequest("text-embedding-ada-003", inputs);

    import mir.ser.json : serializeJson;

    string requestJson3 = request3.serializeJson();

    assert(
        requestJson3 == `{"input":["Hello,","D","Programming","Language!"],"model":"text-embedding-ada-003"}`);
}

/**
 * Variant of `embeddingRequest` that allows specifying multiple inputs and the
 * output vector size for the `/embeddings` endpoint.
 *
 * Params:
 *     model      = Embedding model identifier.
 *     inputs     = Array of texts to embed.
 *     dimensions = Size of the output vector.
 *
 * Returns: Request object for `OpenAIClient.embedding`.
 */
EmbeddingRequest embeddingRequest(string model, string[] inputs, uint dimensions)
{
    auto request = EmbeddingRequest();
    request.model = model;
    request.input = inputs;
    request.dimensions = dimensions;
    return request;
}

///
unittest
{
    auto inputs = ["Hello,", "D", "Programming", "Language!"];
    auto request4 = embeddingRequest("text-embedding-3-small", inputs, 256);

    import mir.ser.json : serializeJson;

    string requestJson = request4.serializeJson();

    assert(
        requestJson == `{"input":["Hello,","D","Programming","Language!"],"model":"text-embedding-3-small","dimensions":256}`);
}

///
struct EmbeddingUsage
{
    ///
    @serdeKeys("prompt_tokens")
    uint promptTokens;

    ///
    @serdeKeys("total_tokens")
    uint totalTokens;
}

///
@serdeIgnoreUnexpectedKeys
struct EmbeddingResponse
{
    static struct Embedding
    {
        string object;
        float[] embedding;
        size_t index;
    }

    ///
    string object;

    ///
    Embedding[] data;

    ///
    string model;

    ///
    EmbeddingUsage usage;
}
