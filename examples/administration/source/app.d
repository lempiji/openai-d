import std.stdio;
import openai;

void main()
{
    auto client = new OpenAIClient();
    auto list = client.listProjects(ListProjectsRequest());
    writeln(list.data.length);
}
