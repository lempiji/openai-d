---
title: Chat File Message Support
date: 2025-06-28
status: Approved
---

# Proposal: Chat File Message Support

## Motivation
OpenAI recently introduced support for providing files directly within chat messages. Users can upload PDFs or text documents via the Files API and reference them in a conversation so the model can answer questions about the content. The current library only supports text and image message types, which prevents building assistants that reason over user documents.

## Goals
- Represent file attachments in `ChatMessage` so uploaded documents can be used during chat.
- Mirror the Python API that accepts a `{"type":"file","file":{"file_id":"..."}}` message item.
- Enable a D example that uploads a file and asks a question about it with `chatCompletion`.

## Non-Goals
- Full retrieval or search API integration.
- Client‑side validation of PDF content.

## Solution Sketch
Introduce a new struct similar to `ChatUserMessageTextContent` and `ChatUserMessageImageContent`:

```d
@serdeIgnoreUnexpectedKeys
struct ChatUserMessageFile
{
    @serdeKeys("file_id")
    string fileId;
}

@serdeIgnoreUnexpectedKeys
@serdeDiscriminatedField("type", "file")
struct ChatUserMessageFileContent
{
    @serdeKeys("file")
    ChatUserMessageFile file;
}
```

Extend `ChatUserMessageContentItem` to include this type:

```d
alias ChatUserMessageContentItem = Algebraic!(
    ChatUserMessageTextContent,
    ChatUserMessageImageContent,
    ChatUserMessageFileContent);
```

Add a helper for constructing a user message with file and text parts:

```d
ChatMessage userChatMessageWithFile(string text, string fileId, string name = null)
{
    ChatUserMessageContentItem[] items;

    ChatUserMessageFileContent fileContent;
    fileContent.file.fileId = fileId;
    items ~= ChatUserMessageContentItem(fileContent);

    ChatUserMessageTextContent textContent;
    textContent.text = text;
    items ~= ChatUserMessageContentItem(textContent);

    return ChatMessage("user", ChatMessageContent(items), name);
}
```

Example usage after uploading a PDF:

```d
auto uploaded = client.uploadFile(
    uploadFileRequest("draconomicon.pdf", FilePurpose.UserData));
auto request = chatCompletionRequest(
    openai.GPT4OMini, [
        userChatMessageWithFile("What is the first dragon in the book?", uploaded.id)
    ],
    16, 0);
auto response = client.chatCompletion(request);
```

## Alternatives
- Encode file references as plain text and parse them manually on the server.
- Implement a higher level assistant workflow instead of direct file messages.

## Impact & Risks
- Adds a new variant to `ChatUserMessageContentItem`; serialization must remain backward compatible.
- Requires tests covering deserializing/serializing chat messages with the new file type.

## Next Steps
- None. This proposal was implemented in version 0.9.0.
