import std.stdio;
import openai;

void main()
{
    auto client = new OpenAIClient();

    // create a project for the rate limit
    auto project = client.createProject(projectCreateRequest("example"));

    // create a project rate limit
    auto limit = client.createProjectRateLimit(project.id,
        createProjectRateLimitRequest(60, 1_000, 5, 100, 1_000, 5_000));

    // list project rate limits
    auto list = client.listProjectRateLimits(project.id,
        listProjectRateLimitsRequest(20));
    writeln("limits: ", list.data.length);

    // retrieve the created rate limit
    auto retrieved = client.retrieveProjectRateLimit(limit.id);
    writeln("retrieved: ", retrieved.id);

    // modify the rate limit
    auto modified = client.modifyProjectRateLimit(limit.id,
        updateProjectRateLimitRequest(120, 2_000, 10, 200, 2_000, 10_000));
    writeln("modified: ", modified.maxRequestsPer1Minute);

    // delete the rate limit
    auto deleted = client.deleteProjectRateLimit(limit.id);
    writeln("deleted: ", deleted.deleted);

    // archive the project
    auto archived = client.archiveProject(project.id);
    writeln("archived: ", archived.status);
}
