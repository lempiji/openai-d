import std.stdio;

import openai;

void main()
{
    auto client = new OpenAIClient();
    // Filter audit logs by event type
    auto request = listAuditLogsRequest(20, null, ["login.failed"]);
    auto logs = client.listAuditLogs(request);
    writeln(logs.data.length);
}
