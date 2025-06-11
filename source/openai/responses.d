/**
OpenAI Responses API

Standards: https://platform.openai.com/docs/api-reference/responses
*/
module openai.responses;

import mir.algebraic;
import mir.serde;
import mir.string_map;
import std.typecons : Nullable;

import openai.common;
import openai.chat : ChatMessageContent, ChatUserMessageContentItem,
    ChatUserMessageTextContent, ChatUserMessageImageContent,
    ChatUserMessageImageUrl, ChatCompletionToolChoice,
    ChatCompletionTool;

@safe:

// -----------------------------------------------------------------------------
// Enumerations
// -----------------------------------------------------------------------------

/// Possible extra fields to include in responses.
enum Includable : string
{
    /// Include file search results for file_search_call.
    FileSearchCallResults = "file_search_call.results",
    /// Include image URLs for message.input_image.
    MessageInputImageUrl = "message.input_image.image_url",
    /// Include image URLs from the computer call output.
    ComputerCallOutputImageUrl = "computer_call_output.output.image_url",
}

/// Status of a response.
enum ResponseStatusCompleted = "completed";
enum ResponseStatusFailed = "failed";
enum ResponseStatusInProgress = "in_progress";
enum ResponseStatusIncomplete = "incomplete";

/// Text response format type.
enum TextResponseFormatType : string
{
    /// Plain text output.
    Text = "text",
    /// JSON schema output.
    JsonSchema = "json_schema",
    /// JSON object output.
    JsonObject = "json_object",
}

// -----------------------------------------------------------------------------
// Requests
// -----------------------------------------------------------------------------

@serdeIgnoreUnexpectedKeys
struct TextResponseFormatConfiguration
{
    /// Format type.
    TextResponseFormatType type = TextResponseFormatType.Text;
}

@serdeIgnoreUnexpectedKeys
struct ResponseText
{
    /// Text output configuration.
    TextResponseFormatConfiguration format;
}

/// Input message content can be null, plain text, or a list of items such as
/// text and image URLs.
alias InputMessageContentItem = ChatUserMessageContentItem;
alias InputMessageContent = ChatMessageContent;

@serdeIgnoreUnexpectedKeys
struct InputMessage
{
    /// Always `"message"`.
    string type = "message";
    /// Message role.
    string role;
    /// Item status.
    @serdeOptional @serdeIgnoreDefault string status;
    /// Content parts for this item.
    InputMessageContent content;
    /// Message ID returned from the API.
    @serdeOptional @serdeIgnoreDefault string id;
}

@serdeIgnoreUnexpectedKeys
struct ResponseItemList
{
    /// Resource type.
    string object;
    /// List items.
    InputMessage[] data;
    /// Indicates there are more items.
    @serdeKeys("has_more") bool hasMore;
    /// ID of the first item in the list.
    @serdeKeys("first_id") string firstId;
    /// ID of the last item in the list.
    @serdeKeys("last_id") string lastId;
}

alias CreateResponseInput = Algebraic!(string, InputMessage[]);

@serdeIgnoreUnexpectedKeys
struct CreateResponseRequest
{
    /// User input. May be text or images.
    CreateResponseInput input;
    /// Model name.
    string model;
    /// Optional extra fields to include.
    @serdeOptional @serdeIgnoreDefault Includable[] include;
    /// Whether tool calls may run in parallel.
    @serdeOptional @serdeIgnoreDefault @serdeKeys("parallel_tool_calls") bool parallelToolCalls = true;
    /// Store the response for later retrieval.
    @serdeOptional @serdeIgnoreDefault bool store = true;
    /// Stream the response as server-sent events.
    @serdeOptional @serdeIgnoreDefault bool stream = false;
}

@serdeIgnoreUnexpectedKeys
struct ListInputItemsRequest
{
    string responseId;
    @serdeOptional @serdeIgnoreDefault size_t limit = 20;
    @serdeOptional @serdeIgnoreDefault string order = "asc";
    @serdeOptional @serdeIgnoreDefault string after;
    @serdeOptional @serdeIgnoreDefault string before;
    @serdeOptional @serdeIgnoreDefault Includable[] include;
}

/// Convenience constructor for `ListInputItemsRequest`.
ListInputItemsRequest listInputItemsRequest(string responseId)
{
    auto req = ListInputItemsRequest();
    req.responseId = responseId;
    return req;
}

/// Convenience constructor for `CreateResponseRequest`.
CreateResponseRequest createResponseRequest(string model, CreateResponseInput input)
{
    auto req = CreateResponseRequest();
    req.model = model;
    req.input = input;
    return req;
}

// -----------------------------------------------------------------------------
// Response objects
// -----------------------------------------------------------------------------

@serdeIgnoreUnexpectedKeys
struct OutputTextContent
{
    string type = "output_text";
    string text;
    /// Text annotations such as citations.
    JsonValue[] annotations;
}

@serdeIgnoreUnexpectedKeys
struct RefusalContent
{
    string type = "refusal";
    string refusal;
}

alias OutputContent = Algebraic!(OutputTextContent, RefusalContent);

@serdeIgnoreUnexpectedKeys
struct OutputMessage
{
    /// Item ID.
    string id;
    /// Always `"message"`.
    string type;
    /// Role of the message.
    string role;
    /// Generated content parts.
    OutputContent[] content;
    /// Status of the item.
    string status;
}

@serdeIgnoreUnexpectedKeys
struct ResponseUsage
{
    @serdeKeys("input_tokens") uint inputTokens;
    @serdeKeys("output_tokens") uint outputTokens;
    @serdeKeys("total_tokens") uint totalTokens;
}

@serdeIgnoreUnexpectedKeys
struct ResponseError
{
    string code;
    string message;
}

@serdeIgnoreUnexpectedKeys
struct ResponseReasoning
{
    @serdeOptional @serdeIgnoreDefault string effort;
    @serdeOptional string summary;
}

@serdeIgnoreUnexpectedKeys
struct ResponseIncompleteDetails
{
    string reason;
}

@serdeIgnoreUnexpectedKeys
struct ResponsesResponse
{
    string id;
    string object;
    @serdeKeys("created_at") ulong createdAt;
    string status;
    @serdeOptional Nullable!ResponseError error;
    @serdeOptional Nullable!ResponseIncompleteDetails incompleteDetails;
    string instructions;
    @serdeKeys("max_output_tokens") uint maxOutputTokens;
    string model;
    OutputMessage[] output;
    @serdeKeys("parallel_tool_calls") bool parallelToolCalls;
    @serdeKeys("previous_response_id") string previousResponseId;
    ResponseReasoning reasoning;
    bool store;
    double temperature;
    ResponseText text;
    @serdeKeys("tool_choice") ChatCompletionToolChoice toolChoice;
    ChatCompletionTool[] tools;
    @serdeKeys("top_p") double topP;
    string truncation;
    ResponseUsage usage;
    string user;
    StringMap!string metadata;
}

// -----------------------------------------------------------------------------
// Unit tests
// -----------------------------------------------------------------------------

unittest
{
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    auto req = createResponseRequest("gpt-4.1", CreateResponseInput("Hello"));
    assert(serializeJson(req) == `{"input":"Hello","model":"gpt-4.1"}`);
}

unittest
{
    import mir.deser.json : deserializeJson;

    enum json = "{\"object\":\"list\",\"data\":[],\"first_id\":null,\"last_id\":null,\"has_more\":false}";

    auto list = deserializeJson!ResponseItemList(json);
    assert(!list.hasMore);
}

unittest
{
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    InputMessage msg;
    msg.role = "user";
    msg.content = "hello";

    auto jsonString = serializeJson(msg);
    assert(jsonString == `{"type":"message","role":"user","content":"hello"}`);

    auto back = deserializeJson!InputMessage(jsonString);
    assert(back.content.get!string() == "hello");
}

unittest
{
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    InputMessage msg;
    msg.role = "user";

    ChatUserMessageTextContent t;
    t.text = "Check";
    ChatUserMessageImageContent img;
    img.imageUrl = ChatUserMessageImageUrl("https://example.com/image.png");
    msg.content = [ChatUserMessageContentItem(t), ChatUserMessageContentItem(img)];

    string jsonString = serializeJson(msg);
    assert(jsonString == `{"type":"message","role":"user","content":[{"type":"text","text":"Check"},{"type":"image_url","image_url":{"url":"https://example.com/image.png"}}]}`);
}

unittest
{
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    InputMessage msg;
    msg.role = "system";
    msg.content = ChatMessageContent(null);

    auto jsonString = serializeJson(msg);
    assert(jsonString == `{"type":"message","role":"system","content":null}`);

    auto back = deserializeJson!InputMessage(jsonString);
    assert(back.content.isNull);
}
