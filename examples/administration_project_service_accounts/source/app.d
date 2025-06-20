import std.stdio;
import openai;

void main()
{
    auto client = new OpenAIAdminClient();

    // create a project
    auto project = client.createProject(projectCreateRequest("example"));

    // create a service account for the project
    auto created = client.createProjectServiceAccount(project.id,
        projectServiceAccountCreateRequest("Example Service Account"));
    writeln("created: ", created.id);

    // list service accounts
    auto list = client.listProjectServiceAccounts(project.id,
        listProjectServiceAccountsRequest(20));
    writeln("service accounts: ", list.data.length);

    // retrieve the newly created account
    auto retrieved = client.retrieveProjectServiceAccount(project.id, created.id);
    writeln("retrieved: ", retrieved.name);

    // delete the service account
    auto deleted = client.deleteProjectServiceAccount(project.id, created.id);
    writeln("deleted: ", deleted.deleted);

    // archive the project
    auto archived = client.archiveProject(project.id);
    writeln("archived: ", archived.status);
}
