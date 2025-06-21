import std.stdio;
import openai;

void main()
{
    auto client = new OpenAIAdminClient();

    // create a project
    auto project = client.createProject(createProjectRequest("example"));

    // list projects
    auto list = client.listProjects(listProjectsRequest(20));
    writeln("projects: ", list.data.length);

    // retrieve the created project
    auto retrieved = client.retrieveProject(project.id);
    writeln("retrieved: ", retrieved.name);

    // modify the project
    auto modified = client.modifyProject(project.id, modifyProjectRequest("example-updated"));
    writeln("modified: ", modified.name);

    // archive the project
    auto archived = client.archiveProject(project.id);
    writeln("archived: ", archived.status);
}
