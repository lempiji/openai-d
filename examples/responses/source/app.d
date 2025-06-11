import std.stdio;

import openai;

void main()
{
    auto client = new OpenAIClient();

    auto req = createResponseRequest(openai.GPT4O, CreateResponseInput("Hello!"));
    auto res = client.createResponse(req);
    writeln(res.output[0].content);

    auto fetched = client.getResponse(res.id);
    assert(fetched.id == res.id);

    auto list = client.listInputItems(listInputItemsRequest(res.id));
    writeln(list.data.length);

    client.deleteResponse(res.id);
}
