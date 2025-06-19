# OpenAI API for D

[![main CI](https://github.com/lempiji/openai-d/actions/workflows/main-ci.yaml/badge.svg)](https://github.com/lempiji/openai-d/actions/workflows/main-ci.yaml)
[![codecov](https://codecov.io/gh/lempiji/openai-d/branch/main/graph/badge.svg)](https://codecov.io/gh/lempiji/openai-d)
[![Latest Release](https://img.shields.io/github/v/release/lempiji/openai-d.svg)](https://github.com/lempiji/openai-d/releases)
[![DUB](https://img.shields.io/dub/v/openai-d.svg)](https://code.dlang.org/packages/openai-d)
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![GitHub stars](https://img.shields.io/github/stars/lempiji/openai-d.svg)

This library provides unofficial D clients for [OpenAI API](https://platform.openai.com).

## Features

### Endpoint

- [x] OpenAI
- [x] Azure OpenAI Service

### API

#### OpenAI

- [x] [Responses API](https://platform.openai.com/docs/api-reference/responses)
- [x] [Chat](https://platform.openai.com/docs/api-reference/chat)
  - [x] tools (function_call)
  - [x] structured output
  - [x] input vision
  - [ ] stream [(design)](docs/chat-streaming-design.md)
- [ ] [Realtime (Beta)](https://platform.openai.com/docs/api-reference/realtime) (TODO)
- [x] [Audio](https://platform.openai.com/docs/api-reference/audio)
  - [x] speech
  - [x] transcription
  - [x] translations
- [x] [Images](https://platform.openai.com/docs/api-reference/images)
- [x] [Embeddings](https://platform.openai.com/docs/api-reference/embeddings)
- [ ] [Evals](https://platform.openai.com/docs/api-reference/evals) (TODO)
- [ ] [Fine-tunings](https://platform.openai.com/docs/api-reference/fine-tuning) (TODO)
- [ ] [Graders](https://platform.openai.com/docs/api-reference/graders) (TODO)
- [ ] [Batch](https://platform.openai.com/docs/api-reference/batch) (TODO)
 - [x] [Files](https://platform.openai.com/docs/api-reference/files) — upload, list, retrieve, delete, download
- [ ] [Uploads](https://platform.openai.com/docs/api-reference/uploads) (TODO)
- [x] [Models](https://platform.openai.com/docs/api-reference/models)
- [x] [Moderations](https://platform.openai.com/docs/api-reference/moderations)
- [ ] [Vector stores](https://platform.openai.com/docs/api-reference/vector-stores) (TODO)
- [ ] [Containers](https://platform.openai.com/docs/api-reference/containers) (TODO)
- [ ] [Assistants (Beta)](https://platform.openai.com/docs/api-reference/assistants) (TODO)
- [ ] [Administration](https://platform.openai.com/docs/api-reference/administration) (WIP)
  - [x] Admin API Keys
  - [x] Invites
  - [x] Users
  - [x] Projects
  - [x] Project users
  - [ ] Project service accounts (WIP)
  - [x] Project API keys
  - [ ] Project rate limits (TODO)
  - [x] Audit logs
  - [x] Usage
  - [x] Certificates

__legacy__
- [x] Completions (Legacy)

__deprecated__
- Edits
  - Use chat API instead. See: https://platform.openai.com/docs/deprecations/edit-models-endpoint

### Optimization

- [ ] Switch HTTP client to [`requests`](https://code.dlang.org/packages/requests) (TODO)
    - Not adopted because it is less convenient due to Windows' handling of system certificates. Version flag is required for support.
    - Adopting 'requests' is expected to lead to more efficient use of Fiber in vibe.d.

# Usage

## Installation

Once `dmd` and `dub` are available, add this library to your project:

```
dub add openai-d
```

## OpenAIClient

__Completion (Legacy)__

```d name=completion
import std;
import openai;

// Load API key from environment variable
auto client = new OpenAIClient();

// POST /completions
auto message = completionRequest("gpt-3.5-turbo-instruct", "Hello, D Programming Language!\n", 10, 0);
message.stop = "\n";

auto response = client.completion(message);

writeln(response.choices[0].text.chomp());
```

__Chat__

```d name=chat
import std;
import openai;

// Load API key from environment variable
auto client = new OpenAIClient();

// POST /chat/completions
// You can use the new model constants such as `O4Mini` or `O3`.
auto request = chatCompletionRequest(openai.O4Mini, [
    systemChatMessage("You are a helpful assistant."),
    userChatMessage("Hello!")
], 16, 0); // sets `maxCompletionTokens`
// Optional: control reasoning effort for o-series models
request.reasoningEffort = "high";

auto response = client.chatCompletion(request);

writeln(response.choices[0].message.content);
```

For o-series models such as `O4Mini` or `O3`, use `maxCompletionTokens` instead
of the deprecated `max_tokens` field when creating your requests.

__Responses__

```d name=responses
import std;
import openai;

auto client = new OpenAIClient();
auto req = createResponseRequest(openai.GPT4O, CreateResponseInput("Hello!"));
auto res = client.createResponse(req);
auto got = client.getResponse(res.id);
auto items = client.listInputItems(listInputItemsRequest(res.id));
client.deleteResponse(res.id);

writeln(got.output[0].content);
writeln(items.data.length);
```

See `examples/responses` for a complete example.  
See `examples/responses_web_search` for a web search example.  
See `examples/responses_code_interpreter` for a code interpreter example.

__Embedding__

```d name=embedding
import std;
import openai;

// Load API key from environment variable
auto client = new OpenAIClient();

// POST /embeddings
const request = embeddingRequest("text-embedding-3-small", "Hello, D Programming Language!");
auto response = client.embedding(request);

float[] embedding = response.data[0].embedding;
writeln(embedding.length); // text-embedding-3-small -> 1536
```

__Files__

```d name=files
import std.stdio;
import std.file : write;
import openai;

auto client = new OpenAIClient();
auto up = fileUploadRequest("input.jsonl", FilePurpose.FineTune);
auto uploaded = client.uploadFile(up);

auto retrieved = client.retrieveFile(uploaded.id);
writeln("retrieved: ", retrieved.filename);

auto content = client.downloadFileContent(uploaded.id);
write("copy.jsonl", content);

client.deleteFile(uploaded.id);
```

See `examples/files` for a complete example showing upload, retrieval, download,
and deletion.

__Moderation__

```d name=moderation
import std;
import openai;

// Load API key from environment variable
auto client = new OpenAIClient();

// POST /moderations
const request = moderationRequest("D is a general-purpose programming language with static typing, systems-level access, and C-like syntax. With the D Programming Language, write fast, read fast, and run fast.");
auto response = client.moderation(request);

if (response.results[0].flagged)
    writeln("Warning!");
else
    writeln("Probably safe.");
```

__Transcription__

```d name=transcription
import std;
import openai;

// Load API key from environment variable
auto client = new OpenAIClient();

// POST /audio/transcriptions
auto request = transcriptionRequest("audio.mp3", "whisper-1");
auto response = client.transcription(request);

writeln(response.text);
```

See `examples/audio_transcription` for a complete example.

__Translation__

```d name=translation
import std;
import openai;

// Load API key from environment variable
auto client = new OpenAIClient();

// POST /audio/translations
auto request = translationRequest("audio.mp3", "whisper-1");
auto response = client.translation(request);

writeln(response.text);
```

See `examples/audio_translation` for a complete example.

__Images__

```d name=images
import std;
import openai;

// Load API key from environment variable
auto client = new OpenAIClient();

// POST /images/generations
auto request = imageGenerationRequest("A cute baby sea otter");
request.responseFormat = ImageResponseFormatB64Json;
auto response = client.imageGeneration(request);
write("image.png", Base64.decode(response.data[0].b64Json));
```

See `examples/images` for a complete example.

__Administration__

```d name=admin_projects
import std;
import openai;

auto client = new OpenAIClient();
auto list = client.listProjects(listProjectsRequest(20));
writeln(list.data.length);
```

```d name=admin_invites
import std;
import openai;

auto client = new OpenAIClient();
auto list = client.listInvites(listInvitesRequest(20));
writeln(list.data.length);
```

```d name=admin_users
import std;
import openai;

auto client = new OpenAIClient();
auto list = client.listUsers(listUsersRequest(20));
writeln(list.data.length);
```

```d name=admin_audit_logs
import std;
import openai;

auto client = new OpenAIClient();
auto logs = client.listAuditLogs(listAuditLogsRequest(10));
writeln(logs.data.length);
```

```d name=admin_usage
import std;
import openai;

auto client = new OpenAIClient();
auto req = listUsageRequest(0);
req.limit = 3;
auto usage = client.listUsageCompletions(req);
writeln(usage.data.length);
```

```d name=admin_project_api_keys
import std;
import openai;

auto client = new OpenAIClient();
auto list = client.listProjectApiKeys("<project id>",
    listProjectApiKeysRequest(20));
writeln(list.data.length);
```

Requires an admin API key. See `examples/administration`,
`examples/administration_invites`,
`examples/administration_project_api_keys`,
`examples/administration_project_users`, and
`examples/administration_users` for complete examples.



## OpenAIClientConfig

__Environment variables__

```d name=config_env
import std.process;
import openai;

environment["OPENAI_API_KEY"] = "<Your API Key>";
environment["OPENAI_ORGANIZATION"] = "<Your Organization>";
environment["OPENAI_API_BASE"] = "https://example.api.cognitive.microsoft.com"; // optional
environment["OPENAI_DEPLOYMENT_ID"] = "<Your deployment>"; // Azure only
environment["OPENAI_API_VERSION"] = "2024-10-21"; // Azure only

auto config = OpenAIClientConfig.fromEnvironment();

assert(config.apiKey == "<Your API Key>");
assert(config.organization == "<Your Organization>");
assert(config.apiBase == "https://example.api.cognitive.microsoft.com");
```

__Configuration file__

```d name=config_file
import std.file;
import openai;

write("config.json", `{"apiKey": "<Your API Key>", "organization": null}`);
scope (exit) remove("config.json");

auto config = OpenAIClientConfig.fromFile("config.json");

assert(config.apiKey == "<Your API Key>");
assert(config.organization is null);
```

__Constructor__

```d name=config_direct
import openai;

auto config = new OpenAIClientConfig("<Your OpenAI API Key>");
auto client = new OpenAIClient(config);
```

## Development

### Requirements

`dmd` and `dub` must be installed. Use the [official D installer](https://dlang.org/download.html).

## License

This project is released under the [MIT license](LICENSE).
