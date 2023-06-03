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
    @serdeIgnoreDefault
    string model;

    ///
    EmbeddingInput input;

    ///
    @serdeIgnoreDefault
    string user;
}

///
EmbeddingRequest embeddingRequest(string model, string input)
{
    auto request = EmbeddingRequest();
    request.model = model;
    request.input = input;
    return request;
}

///
EmbeddingRequest embeddingRequest(string model, string[] inputs)
{
    auto request = EmbeddingRequest();
    request.model = model;
    request.input = inputs;
    return request;
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