import std;
import openai;

void main()
{
    auto client = new OpenAIAdminClient();

    // Fetch the list of projects
    auto projects = client.listProjects(listProjectsRequest(20));
    auto targetProject = projects.data.filter!(p => p.name == "Example Project").front;
    auto projectId = targetProject.id;
    writeln("project: ", targetProject);

    // create a service account for the project
    auto created = client.createProjectServiceAccount(projectId,
        createProjectServiceAccountRequest("Example Service Account"));
    writeln("created: ", created.id);

    // list service accounts
    auto list = client.listProjectServiceAccounts(projectId,
        listProjectServiceAccountsRequest(20));
    writeln("service accounts: ", list.data.length);

    // retrieve the newly created account
    auto retrieved = client.retrieveProjectServiceAccount(projectId, created.id);
    writeln("retrieved: ", retrieved.name);

    // delete the service account
    auto deleted = client.deleteProjectServiceAccount(projectId, created.id);
    writeln("deleted: ", deleted.deleted);
}
