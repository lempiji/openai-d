# OpenAI API for D

[![main CI](https://github.com/lempiji/openai-d/actions/workflows/main-ci.yaml/badge.svg)](https://github.com/lempiji/openai-d/actions/workflows/main-ci.yaml)

This library provides unofficial D clients for [OpenAI API](https://platform.openai.com)

## Features

### Endpoint

- [x] OpenAI
- [ ] Azure OpenAI Service

### API

#### OpenAI

- [x] List models
- [x] Completions
- [x] Chat
  - [x] function_call
- [ ] Edits
- [ ] Images
- [x] Embeddings
- [ ] Audio
- [ ] Files
- [ ] Fine-tunes
- [x] Moderations

### Optimization

- [ ] Switch HTTP client to 'requests'
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
auto message = completionRequest("text-davinci-003", "Hello, D Programming Language!\n", 10, 0);
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
const request = chatCompletionRequest("gpt-3.5-turbo", [
    systemChatMessage("You are a helpful assistant."),
    userChatMessage("Hello!")
], 16, 0);

auto response = client.chatCompletion(request);

writeln(response.choices[0].message.content);
```

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

## OpenAIClientConfig

__Environment variables__

```d name=config_env
import std.process;
import openai;

environment["OPENAI_API_KEY"] = "<Your API Key>";
environment["OPENAI_ORGANIZATION"] = "<Your Organization>";

auto config = OpenAIClientConfig.fromEnvironment();

assert(config.apiKey == "<Your API Key>");
assert(config.organization == "<Your Organization>");
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