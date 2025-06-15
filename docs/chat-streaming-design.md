# Chat Streaming Design

This document outlines the initial design for enabling streaming responses from `/chat/completions`.

## Requirements

- Support server-sent events (SSE) so that chat completions can be received incrementally.
- Ensure errors during a stream close the connection and surface an exception to the caller.
- The existing `ChatCompletionRequest.stream` flag should enable or disable streaming.

## Proposed Client API

Two approaches are considered:

1. **Iterator interface** – return a lazy range yielding `ChatCompletionChunk` objects.
2. **Callback interface** – accept a delegate that is invoked with each chunk as it arrives.

Both approaches must allow the caller to stop early and handle errors gracefully.

## Usage Examples

### Synchronous (current behaviour)

```d
auto request = chatCompletionRequest(model, messages);
auto response = client.chatCompletion(request); // waits for full response
```

### Streaming

```d
auto request = chatCompletionRequest(model, messages);
request.stream = true;

// Iterator style
foreach (chunk; client.chatCompletionStream(request)) {
    writeln(chunk.choices[0].delta.content);
}

// Callback style
client.chatCompletionStream(request, (chunk) {
    writeln(chunk.choices[0].delta.content);
});
```

