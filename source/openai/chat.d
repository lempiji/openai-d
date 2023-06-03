/**
OpenAI API Chat Completions

Standards: https://platform.openai.com/docs/api-reference/completions
*/
module openai.chat;

import mir.serde;
import std.math;

import openai.common;
import openai.completion : CompletionUsage;

@safe:

///
struct ChatMessage
{
    /// **Required**
    string role;

    /// **Required**
    string content;

    /// Optional
    @serdeOptional
    @serdeIgnoreDefault
    string name = null;
}

///
ChatMessage systemChatMessage(string content, string name = null)
{
    return ChatMessage("system", content, name);
}

///
ChatMessage userChatMessage(string content, string name = null)
{
    return ChatMessage("user", content, name);
}

///
ChatMessage assitantChatMessage(string content, string name = null)
{
    return ChatMessage("assistant", content, name);
}

///
struct ChatCompletionRequest
{
    ///
    @serdeIgnoreDefault
    string model;

    ///
    ChatMessage[] messages;

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
ChatCompletionRequest chatCompletionRequest(return scope string model, return scope ChatMessage[] messages, uint maxTokens, double temperature)
{
    auto request = ChatCompletionRequest();
    request.model = model;
    request.messages = messages;
    request.maxTokens = maxTokens;
    request.temperature = temperature;
    return request;
}

///
struct ChatChoice
{
    ///
    size_t index;

    ///
    ChatMessage message;

    ///
    @serdeKeys("finish_reason")
    string finishReason;
}

///
struct ChatCompletionResponse
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
    ChatChoice[] choices;

    ///
    CompletionUsage usage;
}
