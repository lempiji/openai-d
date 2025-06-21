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

    // choose a user from the organization
    auto users = client.listUsers(listUsersRequest(20));
    if (users.data.length == 0)
        return;
    auto userId = users.data[0].id;

    // add the user to the project
    auto created = client.createProjectUser(projectId,
        createProjectUserRequest(userId, ProjectUserRole.Member));
    writeln("created: ", created.email);

    // list users in the project
    auto list = client.listProjectUsers(projectId, listProjectUsersRequest(20));
    writeln("project users: ", list.data.length);

    // retrieve the project user
    auto retrieved = client.retrieveProjectUser(projectId, userId);
    writeln("retrieved role: ", retrieved.role);

    // modify the user's role
    auto modified = client.modifyProjectUser(projectId, userId,
        updateProjectUserRequest(ProjectUserRole.Owner));
    writeln("modified role: ", modified.role);

    // delete the user from the project
    auto deleted = client.deleteProjectUser(projectId, userId);
    writeln("deleted: ", deleted.deleted);
}
