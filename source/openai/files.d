/**
OpenAI API Files

Standards: https://platform.openai.com/docs/api-reference/files
*/
module openai.files;

import mir.serde;
import mir.algebraic;

@safe:

// -----------------------------------------------------------------------------
// Enumerations
// -----------------------------------------------------------------------------

/// Allowed file purposes.
enum FilePurpose : string
{
    /// For fine-tuning files.
    FineTune = "fine-tune",
    /// Fine-tune results.
    FineTuneResults = "fine-tune-results",
    /// For Assistants API.
    Assistants = "assistants",
    /// Output files generated by Assistants.
    AssistantsOutput = "assistants_output",
    /// For batch jobs input files.
    Batch = "batch",
    /// Output files from batch jobs.
    BatchOutput = "batch_output",
    /// For vision fine-tuning.
    Vision = "vision",
    /// User provided data for retrieval.
    UserData = "user_data",
    /// Evaluation datasets.
    Evals = "evals",
}

// -----------------------------------------------------------------------------
// Requests
// -----------------------------------------------------------------------------

struct UploadFileRequest
{
    string file;
    string purpose;
}

struct ListFilesRequest
{
    @serdeOptional @serdeIgnoreDefault string purpose;
    @serdeOptional @serdeIgnoreDefault size_t limit = 10_000;
    @serdeOptional @serdeIgnoreDefault string order = "desc";
    @serdeOptional @serdeIgnoreDefault string after;
}

/// Convenience constructor for `ListFilesRequest`.
ListFilesRequest listFilesRequest()
{
    return ListFilesRequest();
}

/// ditto
ListFilesRequest listFilesRequest(
    string purpose,
    size_t limit = ListFilesRequest.init.limit,
    string order = ListFilesRequest.init.order,
    string after = null)
{
    auto req = listFilesRequest();
    req.purpose = purpose;
    req.limit = limit;
    req.order = order;
    req.after = after;
    return req;
}

/// Convenience constructor for `UploadFileRequest`.
UploadFileRequest uploadFileRequest(string file, string purpose)
{
    auto req = UploadFileRequest();
    req.file = file;
    req.purpose = purpose;
    return req;
}

// -----------------------------------------------------------------------------
// Responses
// -----------------------------------------------------------------------------

@serdeIgnoreUnexpectedKeys
struct FileObject
{
    string id;
    ulong bytes;
    @serdeKeys("created_at") ulong createdAt;
    @serdeOptional @serdeKeys("expires_at") Nullable!ulong expiresAt;
    string filename;
    string object;
    string purpose;
    string status;
    @serdeOptional @serdeKeys("status_details") string statusDetails;
}

@serdeIgnoreUnexpectedKeys
struct ListFileResponse
{
    string object;
    FileObject[] data;
    @serdeKeys("first_id") string firstId;
    @serdeKeys("last_id") string lastId;
    @serdeKeys("has_more") bool hasMore;
}

@serdeIgnoreUnexpectedKeys
struct DeleteFileResponse
{
    string id;
    string object;
    bool deleted;
}

// -----------------------------------------------------------------------------
// Unit tests
// -----------------------------------------------------------------------------

unittest
{
    import mir.ser.json : serializeJson;

    auto req = uploadFileRequest("input.jsonl", FilePurpose.FineTune);
    assert(serializeJson(req) == `{"file":"input.jsonl","purpose":"fine-tune"}`);
}

unittest
{
    import mir.ser.json : serializeJson;

    auto req = listFilesRequest("assistants", 5, "asc", "f1");
    assert(serializeJson(req) == `{"purpose":"assistants","limit":5,"order":"asc","after":"f1"}`);
}

unittest
{
    import mir.deser.json : deserializeJson;

    enum json = `{"id":"file-1","object":"file","bytes":10,"created_at":1,"filename":"f.txt","purpose":"assistants","status":"processed"}`;
    auto obj = deserializeJson!FileObject(json);
    assert(obj.id == "file-1");
    assert(obj.bytes == 10);
    assert(obj.createdAt == 1);
    assert(obj.filename == "f.txt");
    assert(obj.purpose == "assistants");
    assert(obj.status == "processed");
}

unittest
{
    import mir.deser.json : deserializeJson;

    enum json = `{"object":"list","data":[{"id":"file-1","object":"file","bytes":1,"created_at":1,"filename":"f.txt","purpose":"assistants","status":"processed"}],"first_id":"file-1","last_id":"file-1","has_more":false}`;
    auto list = deserializeJson!ListFileResponse(json);
    assert(list.data.length == 1);
    assert(list.firstId == "file-1");
    assert(!list.hasMore);
}

unittest
{
    import mir.deser.json : deserializeJson;

    enum json = `{"id":"file-123","object":"file","deleted":true}`;
    auto resp = deserializeJson!DeleteFileResponse(json);
    assert(resp.id == "file-123");
    assert(resp.object == "file");
    assert(resp.deleted);
}
