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
    /// Include encrypted content in reasoning items.
    ReasoningEncryptedContent = "reasoning.encrypted_content",
    /// Include outputs of Python code execution in code interpreter tool calls.
    CodeInterpreterCallOutputs = "code_interpreter_call.outputs",
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

@serdeIgnoreUnexpectedKeys
struct ResponseHostedTool
{
    string type;
}

alias ResponseToolChoice = Algebraic!(string, ResponseHostedTool);

/// Represents a callable function tool.
/// Matches JSON with `"type": "function"` and ignores unexpected keys.
@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "function")
struct ResponsesToolFunction
{
    /// Function name to call.
    string name;
    /// JSON Schema object describing the parameters.
    JsonValue parameters;
    /// Whether to enforce strict schema conformance (default: true).
    bool strict = true;
    /// Optional human-readable description.
    @serdeOptional @serdeIgnoreDefault string description;
}

/// Searches a vector store of uploaded documents.
/// Matches JSON with `"type": "file_search"`.
@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "file_search")
struct ResponsesToolFileSearch
{
    /// IDs of the vector stores to query.
    @serdeKeys("vector_store_ids")
    string[] vectorStoreIds;
    /// Maximum number of results to return.
    @serdeKeys("max_num_results")
    @serdeOptional @serdeIgnoreDefault
    Nullable!uint maxNumResults;
    /// Optional metadata‐based filtering conditions.
    @serdeKeys("filters")
    @serdeOptional @serdeIgnoreDefault
    FileSearchFilters filters;
    /// Optional ranking options for re‐ranking results.
    @serdeKeys("ranking_options")
    @serdeOptional @serdeIgnoreDefault
    RankingOptions rankingOptions;
}

/// Composite filter for file search (AND/OR).
@serdeIgnoreUnexpectedKeys
struct FileSearchFilters
{
    /// Filter combinator: "and" or "or".
    string type;
    /// List of individual filter conditions.
    ResponsesFileSearchFilterCondition[] filters;
}

/// A single metadata filter condition (e.g., eq, gte).
@serdeIgnoreUnexpectedKeys
struct ResponsesFileSearchFilterCondition
{
    /// Operator: "eq", "gte", "lte", etc.
    string type;
    /// Document attribute key.
    string key;
    /// Value to compare against.
    JsonValue value;
}

/// Options to adjust the ranker and score threshold.
@serdeIgnoreUnexpectedKeys
struct RankingOptions
{
    /// Ranker to use, e.g. "auto".
    string ranker;
    /// Minimum score to include.
    @serdeKeys("score_threshold")
    @serdeOptional @serdeIgnoreDefault
    double scoreThreshold;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "approximate")
struct WebSearchUserLocation
{
    @serdeOptional @serdeIgnoreDefault
    string city;
    @serdeOptional @serdeIgnoreDefault
    string country;
    @serdeOptional @serdeIgnoreDefault
    string region;
    @serdeOptional @serdeIgnoreDefault
    string timezone;
}

/// Performs a preview web search (lighter‐weight).
/// Matches JSON with `"type": "web_search_preview"`.
@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "web_search_preview")
struct ResponsesToolWebSearchPreview
{
    // low, medium, high
    @serdeOptional @serdeIgnoreDefault
    @serdeKeys("search_context_size")
    string searchContextSize;

    @serdeOptional @serdeIgnoreDefault
    @serdeKeys("user_location")
    WebSearchUserLocation userLocation;
}

/// Preview mode for computer‐use tool (lighter sandbox).
/// Matches JSON with `"type": "computer_use_preview"`.
@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "computer_use_preview")
struct ResponsesToolComputerUsePreview
{
    @serdeKeys("display_height")
    uint displayHeight;

    @serdeKeys("display_width")
    uint displayWidth;

    string environment;
}

@serdeIgnoreUnexpectedKeys
struct ResponsesToolMcpFilter
{
    @serdeOptional @serdeIgnoreDefault
    @serdeKeys("tool_names")
    string[] toolNames;
}

@serdeIgnoreUnexpectedKeys
struct ResponsesToolMcpRequireApprovalFilters
{
    @serdeOptional @serdeIgnoreDefault
    ResponsesToolMcpFilter always;

    @serdeOptional @serdeIgnoreDefault
    ResponsesToolMcpFilter never;
}

alias ResponsesToolMcpRequireApproval = Algebraic!(string, ResponsesToolMcpRequireApprovalFilters);

/// Connects to a remote Model Context Protocol (MCP) server.
/// Matches JSON with `"type": "mcp"`.
@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "mcp")
struct ResponsesToolMcp
{
    /// Label for the server.
    @serdeKeys("server_label")
    string serverLabel;
    /// URL of the MCP HTTP endpoint.
    @serdeKeys("server_url")
    string serverUrl;
    /// Optional additional HTTP headers.
    @serdeOptional @serdeIgnoreDefault
    StringMap!string headers;
    /// Optional approval requirement, e.g. "never".
    @serdeKeys("require_approval")
    @serdeOptional @serdeIgnoreDefault
    ResponsesToolMcpRequireApproval requireApproval = "always";
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "auto")
struct CodeInterpreterContainerAuto
{
    @serdeOptional @serdeIgnoreDefault
    @serdeKeys("file_ids")
    string[] fileIds;
}

alias CodeInterpreterContainer = Algebraic!(string, CodeInterpreterContainerAuto);

/// Executes Python code for analysis, data processing, or image manipulation.
/// Matches JSON with `"type": "code_interpreter"`.
@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "code_interpreter")
struct ResponsesToolCodeInterpreter
{
    /// Container configuration (e.g., `{"type":"auto"}`).
    @serdeOptional @serdeIgnoreDefault
    CodeInterpreterContainer container;
}

@serdeIgnoreUnexpectedKeys
struct ResponsesToolImageGenerationInputImageMask
{
    @serdeOptional @serdeIgnoreDefault
    string fileId;

    @serdeOptional @serdeIgnoreDefault
    @serdeKeys("image_url")
    string imageUrl;
}

/// Generates images using the `gpt-image-1` model or edits existing ones.
/// Matches JSON with `"type": "image_generation"`.
@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "image_generation")
struct ResponsesToolImageGeneration
{
    /// Background type for the generated image.
    @serdeOptional @serdeIgnoreDefault
    string background = "auto";

    /// Optional mask for inpainting.
    @serdeOptional @serdeIgnoreDefault
    @serdeKeys("input_image_mask")
    ResponsesToolImageGenerationInputImageMask inputImageMask;

    /// The image generation model to use.
    @serdeOptional @serdeIgnoreDefault
    string model;

    /// Moderation level for the generated image.
    @serdeOptional @serdeIgnoreDefault
    string moderation;

    /// Compression level for the output image.
    @serdeOptional @serdeIgnoreDefault
    @serdeKeys("output_compression")
    Nullable!uint outputCompression;

    /// Output format of the generated image.
    @serdeOptional @serdeIgnoreDefault
    @serdeKeys("output_format")
    string outputFormat;

    /// Number of partial images to return for multi‐turn edits.
    @serdeKeys("partial_images")
    @serdeOptional @serdeIgnoreDefault
    Nullable!uint partialImages;

    /// Quality of the generated image.
    @serdeOptional @serdeIgnoreDefault
    string quality;

    /// Size of the generated image. One of 1024x1024, 1024x1536, 1536x1024, or auto.
    @serdeOptional @serdeIgnoreDefault
    string size;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "local_shell")
struct ResponsesToolLocalShell { }


/// Union of all possible tool definitions for the Responses API.
alias ResponsesTool = Algebraic!(
    ResponsesToolFunction,
    ResponsesToolFileSearch,
    ResponsesToolMcp,
    ResponsesToolImageGeneration,
    ResponsesToolWebSearchPreview,
    ResponsesToolCodeInterpreter,
    ResponsesToolComputerUsePreview,
    ResponsesToolLocalShell
);


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
struct ResponseOutputTextAnnotation
{
    @serdeOptional @serdeIgnoreDefault string type;
    @serdeKeys("start_index") uint startIndex;
    @serdeKeys("end_index") uint endIndex;
    @serdeOptional @serdeIgnoreDefault string title;
    @serdeOptional @serdeIgnoreDefault string url;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "output_text")
struct ResponsesOutputTextContent
{
    string text;

    @serdeOptional @serdeIgnoreDefault
    ResponseOutputTextAnnotation[] annotations;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "output_image_url")
struct ResponsesOutputImageUrlContent
{
    string url;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "refusal")
struct ResponsesRefusalContent
{
    string refusal;
}

alias ResponsesItemContent = Algebraic!(
    ResponsesInputTextContent,
    ResponsesInputImageUrlContent,
    ResponsesOutputTextContent,
    ResponsesOutputImageUrlContent,
    ResponsesRefusalContent
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
    @serdeOptional @serdeIgnoreDefault ResponsesItemContent[] content;
    /// Message role.
    @serdeOptional @serdeIgnoreDefault string role;
}

alias CreateResponseInput = Algebraic!(string, ResponsesMessage[]);

// -----------------------------------------------------------------------------
// Requests
// -----------------------------------------------------------------------------

@serdeIgnoreUnexpectedKeys
struct CreateResponseRequest
{
    /// User input. May be text or images.
    CreateResponseInput input;
    /// Model name.
    string model;
    /// Optional background type for the response.
    @serdeOptional @serdeIgnoreDefault bool background = false;
    /// Optional extra fields to include.
    @serdeOptional @serdeIgnoreDefault Includable[] include;
    /// Optional instructions for the response.
    @serdeOptional @serdeIgnoreDefault string instructions;
    /// Maximum number of output tokens.
    @serdeOptional @serdeIgnoreDefault @serdeKeys("max_output_tokens") Nullable!uint maxOutputTokens;
    /// Metadata for the response.
    @serdeOptional @serdeIgnoreDefault StringMap!string metadata;
    /// Whether tool calls may run in parallel.
    @serdeOptional @serdeIgnoreDefault @serdeKeys("parallel_tool_calls") bool parallelToolCalls = true;
    /// ID of a previous response to continue.
    @serdeOptional @serdeIgnoreDefault @serdeKeys("previous_response_id") Nullable!string previousResponseId;
    /// Reasoning details for the response.
    @serdeOptional @serdeIgnoreDefault Nullable!ResponseReasoning reasoning;
    /// Service tier for the response.
    @serdeOptional @serdeIgnoreDefault @serdeKeys("service_tier") string serviceTier;
    /// Store the response for later retrieval.
    @serdeOptional @serdeIgnoreDefault bool store = true;
    /// Stream the response as server-sent events.
    @serdeOptional @serdeIgnoreDefault bool stream = false;
    /// Temperature for response generation.
    @serdeOptional @serdeIgnoreDefault double temperature = 1;
    /// Text response configuration.
    @serdeOptional @serdeIgnoreDefault Nullable!ResponseText text;
    /// Tool choice for the response.
    @serdeOptional @serdeIgnoreDefault @serdeKeys("tool_choice") Nullable!ResponseToolChoice toolChoice;
    /// List of tools available for the response.
    @serdeOptional @serdeIgnoreDefault ResponsesTool[] tools;
    /// Top-p sampling parameter for response generation.
    @serdeOptional @serdeIgnoreDefault @serdeKeys("top_p") Nullable!double topP;
    /// Truncation strategy for the response.
    @serdeOptional @serdeIgnoreDefault string truncation = "none";
    /// User ID for the request.
    @serdeOptional @serdeIgnoreDefault Nullable!string user;
}

/// Convenience constructor for `CreateResponseRequest`.
CreateResponseRequest createResponseRequest(string model, string input)
{
    auto req = CreateResponseRequest();
    req.model = model;
    req.input = CreateResponseInput(input);
    return req;
}

/// ditto
CreateResponseRequest createResponseRequest(string model, CreateResponseInput input)
{
    auto req = CreateResponseRequest();
    req.model = model;
    req.input = input;
    return req;
}

/// ditto
CreateResponseRequest createResponseRequest(string model, ResponsesMessage[] input)
{
    auto req = CreateResponseRequest();
    req.model = model;
    req.input = CreateResponseInput(input);
    return req;
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

// -----------------------------------------------------------------------------
// Response objects
// -----------------------------------------------------------------------------

@serdeIgnoreUnexpectedKeys
struct ResponsesOutputMessage
{
    /// Message ID returned from the API.
    @serdeOptional @serdeIgnoreDefault string id;
    /// Message type.
    string type;
    /// Item status.
    @serdeOptional @serdeIgnoreDefault string status;
    /// Content parts for this item.
    @serdeOptional @serdeIgnoreDefault ResponsesItemContent[] content;
    /// Message role.
    @serdeOptional @serdeIgnoreDefault string role;
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
    ResponsesOutputMessage[] output;
    @serdeKeys("parallel_tool_calls") bool parallelToolCalls;
    @serdeOptional @serdeKeys("previous_response_id") Nullable!string previousResponseId;
    ResponseReasoning reasoning;
    bool store;
    double temperature;
    ResponseText text;
    @serdeKeys("tool_choice") ChatCompletionToolChoice toolChoice;
    ResponsesTool[] tools;
    @serdeKeys("top_p") double topP;
    string truncation;
    ResponseUsage usage;
    @serdeOptional Nullable!string user;
    @serdeOptional @serdeIgnoreDefault StringMap!string metadata;
}


@serdeIgnoreUnexpectedKeys
struct ResponsesItemListResponse
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

    auto list = deserializeJson!ResponsesItemListResponse(json);
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
    auto msg = deserializeJson!ResponsesMessage(json);
    assert(msg.id == "msg_1");
    assert(msg.content.length == 1);
    assert(msg.content[0].get!ResponsesOutputTextContent().text == "Hello");
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
    assert(res.output[0].content[0].get!ResponsesOutputTextContent().text == "Hello");
}

unittest
{
    import mir.deser.json : deserializeJson;

    enum json = `{
  "id": "resp_1234567xllkkjjiihhggffeeddccbbaah8g7f6e5d4c3b2a1",
  "object": "response",
  "created_at": 1749979742,
  "status": "completed",
  "background": false,
  "error": null,
  "incomplete_details": null,
  "instructions": null,
  "max_output_tokens": null,
  "model": "gpt-4.1-2025-04-14",
  "output": [
    {
      "id": "ws_1234567xllkkjjiihhggffeeddccbbaah8g7f6e5d4c3b2a1",
      "type": "web_search_call",
      "status": "completed"
    },
    {
      "id": "msg_1234567xllkkjjiihhggffeeddccbbaah8g7f6e5d4c3b2a1",
      "type": "message",
      "status": "completed",
      "content": [
        {
          "type": "output_text",
          "annotations": [
            {
              "type": "url_citation",
              "end_index": 499,
              "start_index": 420,
              "title": "Best autumn leaf viewing spots in Kyoto",
              "url": "https://www.japan-guide.com/e/e3953.html?utm_source=openai"
            },
            {
              "type": "url_citation",
              "end_index": 824,
              "start_index": 745,
              "title": "Best autumn leaf viewing spots in Kyoto",
              "url": "https://www.japan-guide.com/e/e3953.html?utm_source=openai"
            },
            {
              "type": "url_citation",
              "end_index": 1152,
              "start_index": 1073,
              "title": "Best autumn leaf viewing spots in Kyoto",
              "url": "https://www.japan-guide.com/e/e3953.html?utm_source=openai"
            },
            {
              "type": "url_citation",
              "end_index": 1482,
              "start_index": 1403,
              "title": "Best autumn leaf viewing spots in Kyoto",
              "url": "https://www.japan-guide.com/e/e3953.html?utm_source=openai"
            },
            {
              "type": "url_citation",
              "end_index": 1808,
              "start_index": 1708,
              "title": "Top 10 Spots to Witness Autumn Leaves in Kyoto",
              "url": "https://preparetravelplans.com/autumn-leaves-in-kyoto/?utm_source=openai"
            }
          ],
          "text": "Kyoto is renowned for its stunning autumn foliage, with numerous locations offering breathtaking views of vibrant red and orange leaves. Here are some of the best spots to experience the beauty of autumn in Kyoto:\n\n\n\n**Tofukuji Temple**  \nFamous for its Tsutenkyo Bridge, which spans a valley filled with approximately 2,000 maple trees. The view from the bridge during mid to late November is particularly spectacular. ([japan-guide.com](https://www.japan-guide.com/e/e3953.html?utm_source=openai))\n\n\n\n\n**Arashiyama**  \nThis district offers picturesque views of autumn colors along the Katsura River and surrounding mountains. The Togetsukyo Bridge provides a panoramic view of the foliage, typically best from late November to early December. ([japan-guide.com](https://www.japan-guide.com/e/e3953.html?utm_source=openai))\n\n\n\n\n**Kiyomizudera Temple**  \nPerched on a hillside, this temple offers panoramic views of Kyoto amidst vibrant autumn colors. The wooden terrace is an excellent spot to admire the foliage, usually at its peak from late November to early December. ([japan-guide.com](https://www.japan-guide.com/e/e3953.html?utm_source=openai))\n\n\n\n\n**Eikando Temple**  \nKnown as the \"Temple of Maple Leaves,\" Eikando features approximately 3,000 maple trees. The temple is renowned for its evening illuminations during the autumn season, creating a magical atmosphere from mid to late November. ([japan-guide.com](https://www.japan-guide.com/e/e3953.html?utm_source=openai))\n\n\n\n\n**Rurikoin Temple**  \nThis hidden gem opens only twice a year, including the autumn season. Its gardens and the famous \"reflection room,\" where fall foliage is mirrored in polished floors, offer a mesmerizing experience. ([preparetravelplans.com](https://preparetravelplans.com/autumn-leaves-in-kyoto/?utm_source=openai))\n\n\nThese locations provide some of the most picturesque settings to enjoy Kyoto's autumn foliage. Keep in mind that peak viewing times can vary slightly each year, so it's advisable to check the latest forecasts before planning your visit. "
        }
      ],
      "role": "assistant"
    }
  ],
  "parallel_tool_calls": true,
  "previous_response_id": null,
  "reasoning": {
    "effort": null,
    "summary": null
  },
  "service_tier": "default",
  "store": true,
  "temperature": 1.0,
  "text": {
    "format": {
      "type": "text"
    }
  },
  "tool_choice": "auto",
  "tools": [
    {
      "type": "web_search_preview",
      "search_context_size": "medium",
      "user_location": {
        "type": "approximate",
        "city": "Kyoto",
        "country": "JP",
        "region": null,
        "timezone": null
      }
    }
  ],
  "top_p": 1.0,
  "truncation": "disabled",
  "usage": {
    "input_tokens": 313,
    "input_tokens_details": {
      "cached_tokens": 0
    },
    "output_tokens": 468,
    "output_tokens_details": {
      "reasoning_tokens": 0
    },
    "total_tokens": 781
  },
  "user": null,
  "metadata": {}
}`;
    auto content = deserializeJson!ResponsesResponse(json);
    assert(content.output.length == 2);
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
    auto list = deserializeJson!ResponsesItemListResponse(json);
    assert(list.data.length == 1);
    assert(list.data[0].content[0].get!ResponsesInputTextContent().text == "Hello!");
    assert(!list.hasMore);
    assert(list.firstId == "msg_202020202020202020202020202020202020202020202020");
    assert(list.lastId == "msg_202020202020202020202020202020202020202020202020");
}

unittest
{
    // tool use
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    ResponsesToolFunction tool;
    tool.name = "test_function";
    tool.parameters = JsonValue("test_param");
    tool.strict = true;
    tool.description = "A test function";
    auto jsonString = serializeJson(tool);
    assert(jsonString == `{"type":"function","name":"test_function","parameters":"test_param","strict":true,"description":"A test function"}`);
    auto back = deserializeJson!ResponsesToolFunction(jsonString);
    assert(back.name == "test_function");
    assert(back.parameters == JsonValue("test_param"));
    assert(back.strict);
    assert(back.description == "A test function");
}

unittest
{
    // tool use - file search
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;
    ResponsesToolFileSearch tool;
    tool.vectorStoreIds = ["store1", "store2"];
    tool.maxNumResults = 10;
    tool.filters = FileSearchFilters("and", [
        ResponsesFileSearchFilterCondition("eq", "author", JsonValue("Alice")),
        ResponsesFileSearchFilterCondition("gte", "date", JsonValue("2023-01-01"))
    ]);
    tool.rankingOptions = RankingOptions("auto", 0.5);
    auto jsonString = serializeJson(tool);
    assert(jsonString == `{"type":"file_search","vector_store_ids":["store1","store2"],"max_num_results":10,"filters":{"type":"and","filters":[{"type":"eq","key":"author","value":"Alice"},{"type":"gte","key":"date","value":"2023-01-01"}]},"ranking_options":{"ranker":"auto","score_threshold":0.5}}`);
}

unittest
{
    // tool use - web search preview
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    ResponsesToolWebSearchPreview tool;
    tool.searchContextSize = "medium";
    tool.userLocation = WebSearchUserLocation("New York", "USA", "NY", "America/New_York");
    auto jsonString = serializeJson(tool);
    assert(jsonString == `{"type":"web_search_preview","search_context_size":"medium","user_location":{"type":"approximate","city":"New York","country":"USA","region":"NY","timezone":"America/New_York"}}`, "jsonString: " ~ jsonString);
}

unittest
{
    // tool use - computer use preview
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    ResponsesToolComputerUsePreview tool;
    tool.displayHeight = 1080;
    tool.displayWidth = 1920;
    tool.environment = "linux";
    auto jsonString = serializeJson(tool);
    assert(jsonString == `{"type":"computer_use_preview","display_height":1080,"display_width":1920,"environment":"linux"}`);
}

unittest
{
    // tool use - MCP
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    ResponsesToolMcp tool;
    tool.serverLabel = "Test MCP";
    tool.serverUrl = "https://mcp.example.com";
    tool.headers["Authorization"] = "Bearer token";
    tool.requireApproval = ResponsesToolMcpRequireApprovalFilters(
        ResponsesToolMcpFilter(["tool1", "tool2"]),
        ResponsesToolMcpFilter(["tool3"])
    );
    auto jsonString = serializeJson(tool);
    assert(jsonString == `{"type":"mcp","server_label":"Test MCP","server_url":"https://mcp.example.com","headers":{"Authorization":"Bearer token"},"require_approval":{"always":{"tool_names":["tool1","tool2"]},"never":{"tool_names":["tool3"]}}}`);
}

unittest
{
    // tool use - code interpreter
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    ResponsesToolCodeInterpreter tool;
    tool.container = CodeInterpreterContainerAuto(["file1", "file2"]);
    auto jsonString = serializeJson(tool);
    assert(jsonString == `{"type":"code_interpreter","container":{"type":"auto","file_ids":["file1","file2"]}}`, "jsonString: " ~ jsonString);
}

unittest
{
    // tool use - image generation
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    ResponsesToolImageGeneration tool;
    tool.background = "transparent";
    tool.model = "gpt-image-1";
    tool.moderation = "high";
    tool.outputCompression = 90;
    tool.outputFormat = "jpeg";
    tool.partialImages = 2;
    tool.quality = "high";
    tool.size = "1024x1024";

    auto jsonString = serializeJson(tool);
    assert(jsonString == `{"type":"image_generation","background":"transparent","model":"gpt-image-1","moderation":"high","output_compression":90,"output_format":"jpeg","partial_images":2,"quality":"high","size":"1024x1024"}`, "jsonString: " ~ jsonString);
}

unittest
{
    // tool use - local shell
    import mir.deser.json : deserializeJson;
    import mir.ser.json : serializeJson;

    ResponsesToolLocalShell tool;
    auto jsonString = serializeJson(tool);
    assert(jsonString == `{"type":"local_shell"}`);
}
