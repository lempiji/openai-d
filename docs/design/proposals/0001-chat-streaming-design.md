---
title: Chat Streaming Design
date: 2025-06-27
status: Draft
---

# Proposal: Chat Streaming Design

## Motivation
Streaming chat responses improves user experience for long or complex prompts by delivering partial results as soon as they are available. The OpenAI API already supports server-sent events (SSE) for this purpose, but the library currently only exposes a blocking call that waits for the full response.

## Goals
- Support SSE so that chat completions are received incrementally.
- Allow callers to handle errors that occur mid-stream.
- Preserve the existing synchronous API for callers that do not want streaming.

## Non-Goals
- Streaming for endpoints other than `/chat/completions`.
- Advanced flow-control or reconnection logic.

## Solution Sketch
Expose a `chatCompletionStream` function that yields `ChatCompletionChunk` values. Two consumption styles are supported:

1. **Iterator style** – returns a lazy range that can be iterated over.
2. **Callback style** – accepts a delegate invoked with each chunk.

Both approaches allow the caller to stop early and handle errors gracefully. When `request.stream` is set, the client connects using SSE and returns the chosen interface.

## Alternatives
- Continue offering only the blocking synchronous API.
- Implement a single consumption pattern and force all callers to adapt to it.

## Impact & Risks
- Error handling must ensure the underlying connection is closed properly.
- The API surface grows slightly but remains backward compatible.

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

## Next Steps
- Gather feedback on the proposed interfaces.
- Finalize design and update documentation.
- Implement `chatCompletionStream` and associated tests.
