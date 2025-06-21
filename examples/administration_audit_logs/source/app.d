import std.stdio;

import openai;

void main()
{
    auto client = new OpenAIAdminClient();
    // Filter audit logs by event type
    auto request = listAuditLogsRequest(20, null, ["api_key.created", "api_key.deleted"]);
    auto logs = client.listAuditLogs(request);
    writeln(logs.data);
}
