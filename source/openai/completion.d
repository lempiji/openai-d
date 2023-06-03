/**
OpenAI API Completions

Standards: https://platform.openai.com/docs/api-reference/completions
*/
module openai.completion;

import mir.algebraic;
import mir.serde;
import std.math;

import openai.common;

@safe:

///
struct CompletionRequest
{
    ///
    @serdeIgnoreDefault
    string model;

    ///
    string prompt;

    ///
    @serdeIgnoreDefault
    string suffix = null;

    ///
    @serdeIgnoreDefault
    Nullable!int logProbs = null;

    ///
    @serdeIgnoreDefault
    @serdeKeys("max_tokens")
    uint maxTokens = 16;

    ///
    @serdeIgnoreDefault
    double temperature = 1;

    ///
    @serdeIgnoreDefault
    double topP = 1;

    ///
    @serdeIgnoreDefault
    uint n = 1;

    ///
    @serdeIgnoreDefault
    bool stream = false;

    ///
    @serdeIgnoreDefault
    bool echo = false;

    ///
    @serdeIgnoreDefault
    StopToken stop = null;

    ///
    @serdeIgnoreDefault
    @serdeIgnoreOutIf!isNaN double presencePenalty = 0;

    ///
    @serdeIgnoreDefault
    double frequencyPenalty = 0;

    ///
    @serdeIgnoreDefault
    uint bestOf = 1;
    version (none)
    {
        ///
        @serdeIgnoreDefault
        double[string] logitBias; // TODO test
    }

    ///
    @serdeIgnoreDefault
    string user = null;
}

///
CompletionRequest completionRequest(string model, string prompt, uint maxTokens, double temperature)
{
    auto request = CompletionRequest();
    request.model = model;
    request.prompt = prompt;
    request.maxTokens = maxTokens;
    request.temperature = temperature;
    return request;
}

///
struct CompletionUsage
{
    ///
    @serdeKeys("prompt_tokens")
    uint promptTokens;

    ///
    @serdeKeys("completion_tokens")
    @serdeOptional
    uint completionTokens;

    ///
    @serdeKeys("total_tokens")
    uint totalTokens;
}

///
struct CompletionChoice
{
    ///
    string text;
    ///
    size_t index;
    ///
    @serdeKeys("logprobs")
    Nullable!double logProbs;
    ///
    @serdeKeys("finish_reason")
    string finishReason;
}

///
struct CompletionResponse
{
    ///
    string id;

    ///
    string object;

    ///
    ulong created;

    ///
    string model;

    ///
    CompletionChoice[] choices;

    ///
    CompletionUsage usage;
}
