# OpenAI API for D

[![main CI](https://github.com/lempiji/openai-d/actions/workflows/main-ci.yaml/badge.svg)](https://github.com/lempiji/openai-d/actions/workflows/main-ci.yaml)
[![codecov](https://codecov.io/gh/lempiji/openai-d/branch/main/graph/badge.svg)](https://codecov.io/gh/lempiji/openai-d)
[![Latest Release](https://img.shields.io/github/v/release/lempiji/openai-d.svg)](https://github.com/lempiji/openai-d/releases)
[![DUB](https://img.shields.io/dub/v/openai-d.svg)](https://code.dlang.org/packages/openai-d)
![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)
![GitHub stars](https://img.shields.io/github/stars/lempiji/openai-d.svg)

This library provides unofficial D clients for [OpenAI API](https://platform.openai.com).
## Overview
Key capabilities are summarized below.


## Installation

Once `dmd` and `dub` are available, add this library to your project:

```
dub add openai-d
```

## Quick Start

```d
import openai;

auto client = new OpenAIClient();
auto res = client.chatCompletion(
    chatCompletionRequest(openai.GPT4O, [userChatMessage("Hello!")]));
writeln(res.choices[0].message.content);
```

See the [examples](examples) directory for full sample programs.

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
  - [x] Project service accounts
  - [x] Project API keys
  - [x] Project rate limits
  - [x] Audit logs
  - [x] Usage
  - [x] Certificates

### Legacy
- [x] Completions (Legacy)

### Deprecated
- Edits
  - Use chat API instead. See: https://platform.openai.com/docs/deprecations/edit-models-endpoint

### Optimization

- [ ] Switch HTTP client to [`requests`](https://code.dlang.org/packages/requests) (TODO)
    - Not adopted because it is less convenient due to Windows' handling of system certificates. Version flag is required for support.
    - Adopting 'requests' is expected to lead to more efficient use of Fiber in vibe.d.


### Completion (Legacy)

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


### Embedding

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

### Files

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

See `examples/files` for the full example.

### Moderation

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

### Transcription

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

See `examples/audio_transcription` for the full example.

### Translation

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

See `examples/audio_translation` for the full example.

### Images

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

See `examples/images` for the full example.

### Administration

```d name=admin_projects
import std;
import openai;

auto client = new OpenAIClient();
auto list = client.listProjects(listProjectsRequest(20));
writeln(list.data.length);
```

Requires an admin API key. See `examples/administration*` for complete examples.



## OpenAIClientConfig

### Environment variables

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


## Development

### Requirements

`dmd` and `dub` must be installed. Use the [official D installer](https://dlang.org/download.html).

## License

This project is released under the [MIT license](LICENSE).
