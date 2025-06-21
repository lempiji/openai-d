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

    // list project rate limits
    auto list = client.listProjectRateLimits(projectId,
        listProjectRateLimitsRequest(100));
    writeln("limits: ", list.data.length);

    // modify the rate limit
    /+
        60% of the default rate limit
        "max_requests_per_1_minute": 300,
        "max_tokens_per_1_minute": 18000,
        "max_images_per_1_minute": 30000,
        "batch_1_day_max_input_tokens": 54000
    +/
    ModifyProjectRateLimitRequest req;
    req.maxRequestsPer1Minute = 300;
    req.maxTokensPer1Minute = 18_000;
    req.maxImagesPer1Minute = 30_000;
    req.batch1DayMaxInputTokens = 54_000;
    auto modified = client.modifyProjectRateLimit(projectId, "rl-gpt-4o", req);
    writeln("modified: ", modified);
}
