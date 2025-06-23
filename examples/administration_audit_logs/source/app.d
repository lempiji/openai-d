import std;

import openai;

void main()
{
    auto client = new OpenAIAdminClient();
    // Fetch projects to find the ID of "Example Project"
    auto projects = client.listProjects(listProjectsRequest(20));
    auto targetProject = projects.data.filter!(p => p.name == "Example Project").front;
    auto projectId = targetProject.id;

    // Filter audit logs by project ID and event type
    auto request = listAuditLogsRequest(20, [projectId], [
        "api_key.created", "api_key.deleted"
    ]);
    auto logs = client.listAuditLogs(request);
    writeln(logs.data);
}
