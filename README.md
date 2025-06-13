# OpenAI API for D

[![main CI](https://github.com/lempiji/openai-d/actions/workflows/main-ci.yaml/badge.svg)](https://github.com/lempiji/openai-d/actions/workflows/main-ci.yaml)
[![codecov](https://codecov.io/gh/lempiji/openai-d/branch/main/graph/badge.svg)](https://codecov.io/gh/lempiji/openai-d)
[![Latest Release](https://img.shields.io/github/v/release/lempiji/openai-d.svg)](https://github.com/lempiji/openai-d/releases)
[![DUB](https://img.shields.io/dub/v/openai-d.svg)](https://code.dlang.org/packages/openai-d)
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![GitHub stars](https://img.shields.io/github/stars/lempiji/openai-d.svg)

This library provides unofficial D clients for [OpenAI API](https://platform.openai.com)

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
  - [ ] stream
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
- [ ] [Files](https://platform.openai.com/docs/api-reference/files) (TODO)
- [ ] [Uploads](https://platform.openai.com/docs/api-reference/uploads) (TODO)
- [x] [Models](https://platform.openai.com/docs/api-reference/models)
- [x] [Moderations](https://platform.openai.com/docs/api-reference/moderations)
- [ ] [Vector stores](https://platform.openai.com/docs/api-reference/vector-stores) (TODO)
- [ ] [Containers](https://platform.openai.com/docs/api-reference/containers) (TODO)
- [ ] [Assistants (Beta)](https://platform.openai.com/docs/api-reference/assistants) (TODO)
 - [x] [Administration](https://platform.openai.com/docs/api-reference/administration)

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

```
dub add openai-d
```

## OpenAIClient

__Completion__

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

__Embedding__

```d name=embedding
import std;
import openai;

// Load API key from environment variable
auto client = new OpenAIClient();

// POST /embeddings
const request = embeddingRequest("text-embedding-ada-002", "Hello, D Programming Language!");
auto response = client.embedding(request);

float[] embedding = response.data[0].embedding;
writeln(embedding.length); // text-embedding-ada-002 -> 1536
```

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
auto list = client.listProjects(ListProjectsRequest());
writeln(list.data.length);
```


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
