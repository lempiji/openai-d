import std.stdio;
import openai;

void main()
{
    auto client = new OpenAIAdminClient();
    auto list = client.listProjects(listProjectsRequest(20));
    writeln(list.data.length);
}
