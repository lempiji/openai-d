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
    string type = TextResponseFormatType.Text;
}

@serdeIgnoreUnexpectedKeys
struct ResponseText
{
    /// Text output configuration.
    TextResponseFormatConfiguration format;
}

///
@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "input_text")
struct ResponsesInputTextContent
{
    string text;
}

///
@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "input_image_url")
struct ResponsesInputImageUrlContent
{
    string imageUrl;

    @serdeOptional
    @serdeIgnoreDefault
    string detail;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "output_text")
struct ResponsesOutputTextContent
{
    string text;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "output_image_url")
struct ResponsesOutputImageUrlContent
{
    string url;
}

alias ResponsesItemContent = Algebraic!(
    ResponsesInputTextContent,
    ResponsesInputImageUrlContent,
    ResponsesOutputTextContent,
    ResponsesOutputImageUrlContent
);

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "message")
struct ResponsesMessage
{
    /// Message ID returned from the API.
    @serdeOptional @serdeIgnoreDefault string id;
    /// Item status.
    @serdeOptional @serdeIgnoreDefault string status;
    /// Content parts for this item.
    ResponsesItemContent[] content;
    /// Message role.
    string role;
}

@serdeIgnoreUnexpectedKeys
struct ResponseItemList
{
    /// Resource type.
    string object;
    /// List items.
    ResponsesMessage[] data;
    /// ID of the first item in the list.
    @serdeKeys("first_id") string firstId;
    /// Indicates there are more items.
    @serdeKeys("has_more") bool hasMore;
    /// ID of the last item in the list.
    @serdeKeys("last_id") string lastId;
}

alias CreateResponseInput = Algebraic!(string, ResponsesMessage[]);

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
@serdeDiscriminatedField("type", "output_text")
struct OutputTextContent
{
    string text;
    /// Text annotations such as citations.
    JsonValue[] annotations;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "refusal")
struct RefusalContent
{
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
    @serdeOptional Nullable!string instructions;
    @serdeOptional @serdeKeys("max_output_tokens") Nullable!uint maxOutputTokens;
    string model;
    OutputMessage[] output;
    @serdeKeys("parallel_tool_calls") bool parallelToolCalls;
    @serdeOptional @serdeKeys("previous_response_id") Nullable!string previousResponseId;
    ResponseReasoning reasoning;
    bool store;
    double temperature;
    ResponseText text;
    @serdeKeys("tool_choice") ChatCompletionToolChoice toolChoice;
    ChatCompletionTool[] tools;
    @serdeKeys("top_p") double topP;
    string truncation;
    ResponseUsage usage;
    @serdeOptional Nullable!string user;
    @serdeOptional @serdeIgnoreDefault StringMap!string metadata;
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

    ResponsesMessage msg;
    msg.role = "user";

    ResponsesInputTextContent t;
    t.text = "hello";
    msg.content = [ResponsesItemContent(t)];

    auto jsonString = serializeJson(msg);
    assert(jsonString == `{"type":"message","content":[{"type":"input_text","text":"hello"}],"role":"user"}`, "jsonString: " ~ jsonString);

    auto back = deserializeJson!ResponsesMessage(jsonString);
    assert(back.content[0].get!ResponsesInputTextContent().text == "hello");
}

unittest
{
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    ResponsesMessage msg;
    msg.role = "user";

    ResponsesInputTextContent t;
    t.text = "Check";
    ResponsesInputImageUrlContent img;
    img.imageUrl = "https://example.com/image.png";
    msg.content = [ResponsesItemContent(t), ResponsesItemContent(img)];

    string jsonString = serializeJson(msg);
    assert(jsonString == `{"type":"message","content":[{"type":"input_text","text":"Check"},{"type":"input_image_url","imageUrl":"https://example.com/image.png"}],"role":"user"}`);
}

unittest
{
    import mir.deser.json : deserializeJson;

    enum json = `{"id":"msg_1","type":"message","role":"assistant","content":[{"type":"output_text","text":"Hello","annotations":[]}],"status":"completed"}`;
    auto msg = deserializeJson!OutputMessage(json);
    assert(msg.id == "msg_1");
    assert(msg.content.length == 1);
    assert(msg.content[0].get!OutputTextContent().text == "Hello");
}

unittest
{
    import mir.deser.json : deserializeJson;

    enum json = `{
      "id": "res_123",
      "object": "response",
      "created_at": 1,
      "status": "completed",
      "error": null,
      "incomplete_details": null,
      "instructions": null,
      "max_output_tokens": null,
      "model": "gpt-4o",
      "output": [{"id":"msg_1","type":"message","role":"assistant","content":[{"type":"output_text","text":"Hello","annotations":[]}],"status":"completed"}],
      "parallel_tool_calls": false,
      "previous_response_id": null,
      "reasoning": {},
      "store": true,
      "temperature": 0.5,
      "text": {"format": {"type":"text"}},
      "tool_choice": "none",
      "tools": [],
      "top_p": 1.0,
      "truncation": "none",
      "usage": {"input_tokens":1,"output_tokens":1,"total_tokens":2},
      "user": null,
      "metadata": null
    }`;
    auto res = deserializeJson!ResponsesResponse(json);
    assert(res.output.length == 1);
    assert(res.output[0].content[0].get!OutputTextContent().text == "Hello");
}

unittest
{
    import mir.deser.json : deserializeJson;

    enum json = `{
  "object": "list",
  "data": [
    {
      "id": "msg_202020202020202020202020202020202020202020202020",
      "type": "message",
      "status": "completed",
      "content": [
        {
          "type": "input_text",
          "text": "Hello!"
        }
      ],
      "role": "user"
    }
  ],
  "first_id": "msg_202020202020202020202020202020202020202020202020",
  "has_more": false,
  "last_id": "msg_202020202020202020202020202020202020202020202020"
}`;
    auto list = deserializeJson!ResponseItemList(json);
    assert(list.data.length == 1);
    assert(list.data[0].content[0].get!ResponsesInputTextContent().text == "Hello!");
    assert(!list.hasMore);
    assert(list.firstId == "msg_202020202020202020202020202020202020202020202020");
    assert(list.lastId == "msg_202020202020202020202020202020202020202020202020");
}
