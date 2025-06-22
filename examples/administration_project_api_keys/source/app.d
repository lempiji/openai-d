import std;
import openai;

void main()
{
    auto client = new OpenAIAdminClient();

    // Fetch the list of projects
    auto projects = client.listProjects(listProjectsRequest(20));
    auto targetProject = projects.data.filter!(p => p.name == "Example Project").front;
    writeln("project: ", targetProject);

    auto projectId = targetProject.id;

    // list project API keys
    auto list = client.listProjectApiKeys(projectId, listProjectApiKeysRequest(20));
    writeln("keys: ", list.data);

    // retrieve the created key
    if (list.data.length > 0)
    {
        auto retrieved = client.retrieveProjectApiKey(projectId, list.data[0].id);
        writeln("retrieved: ", retrieved);
        assert(retrieved.id == list.data[0].id);
    }

    // delete the API key
    const timeThreshold = Clock.currTime().roll!"years"(-1);
    const timeThresholdUnix = timeThreshold.toUnixTime;
    writeln("time threshold: ", timeThreshold, " (", timeThresholdUnix, ")");

    bool found = false;
    foreach (key; list.data)
    {
        if (key.createdAt < timeThresholdUnix)
        {
            writeln("deleting key: ", key.id);
            auto deleted = client.deleteProjectApiKey(projectId, key.id);
            writeln("deleted: ", deleted.deleted);
            found = true;
        }
        else
        {
            writeln("not deleting key: ", key.id, " (created at: ", key.createdAt, ")");
        }
    }

    if (found)
    {
        // list project API keys again to confirm deletion
        auto list2 = client.listProjectApiKeys(projectId, listProjectApiKeysRequest(20));
        writeln("keys after deletion: ", list2.data);
        assert(list2.data.length < list.data.length);
    }
    else
    {
        writeln("No key found to delete.");
    }
}
