import std.stdio;
import openai;

void main()
{
    auto client = new OpenAIAdminClient();

    // create a project for the API key
    auto project = client.createProject(projectCreateRequest("example"));

    // create a project API key
    auto key = client.createProjectApiKey(project.id,
        createProjectApiKeyRequest("Example Key"));

    // list project API keys
    auto list = client.listProjectApiKeys(project.id,
        listProjectApiKeysRequest(20));
    writeln("keys: ", list.data.length);

    // retrieve the created key
    auto retrieved = client.retrieveProjectApiKey(key.id);
    writeln("retrieved: ", retrieved.name);

    // modify the API key
    auto modified = client.modifyProjectApiKey(key.id,
        modifyProjectApiKeyRequest("Example Key Updated"));
    writeln("modified: ", modified.name);

    // delete the API key
    auto deleted = client.deleteProjectApiKey(key.id);
    writeln("deleted: ", deleted.deleted);

    // archive the project
    auto archived = client.archiveProject(project.id);
    writeln("archived: ", archived.status);
}
