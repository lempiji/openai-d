import std.stdio;

import openai;

void main()
{
    auto client = new OpenAIClient();
    auto list = client.listUsers(listUsersRequest(20));
    writeln(list.data.length);
}
