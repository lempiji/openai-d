import std.stdio;
import openai;

void main()
{
    auto client = new OpenAIClient();

    // create a project for the user operations
    auto project = client.createProject(projectCreateRequest("example"));

    // choose a user from the organization
    auto users = client.listUsers(listUsersRequest(20));
    if (users.data.length == 0)
        return;
    auto userId = users.data[0].id;

    // add the user to the project
    auto created = client.createProjectUser(project.id,
        projectUserCreateRequest(userId, ProjectUserRole.Member));
    writeln("created: ", created.email);

    // list users in the project
    auto list = client.listProjectUsers(project.id, listProjectUsersRequest(20));
    writeln("project users: ", list.data.length);

    // retrieve the project user
    auto retrieved = client.retrieveProjectUser(project.id, userId);
    writeln("retrieved role: ", retrieved.role);

    // modify the user's role
    auto modified = client.modifyProjectUser(project.id, userId,
        projectUserUpdateRequest(ProjectUserRole.Owner));
    writeln("modified role: ", modified.role);

    // delete the user from the project
    auto deleted = client.deleteProjectUser(project.id, userId);
    writeln("deleted: ", deleted.deleted);

    // archive the project
    auto archived = client.archiveProject(project.id);
    writeln("archived: ", archived.status);
}
