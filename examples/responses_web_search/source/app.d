module app;

import std.stdio;

import openai;

void main()
{
    auto client = new OpenAIClient();

    auto req = createResponseRequest("gpt-4.1", "Where are the best places in Kyoto to see autumn leaves?");
    ResponsesToolWebSearchPreview webSearchTool;
    webSearchTool.userLocation = WebSearchUserLocation("Kyoto", "JP");
    req.tools = [ResponsesTool(webSearchTool)];

    ResponsesResponse res = client.createResponse(req);
    scope (exit)
        client.deleteResponse(res.id);

    import std.algorithm : filter;
    foreach (ref msg; res.output.filter!(x => x.status == "completed"))
    {
        writeln(msg.content);
    }

    auto fetched = client.getResponse(res.id);
    assert(fetched.id == res.id);

    // continue session
    writeln("-------------------------------");
    auto continueReq = createResponseRequest("gpt-4.1", "Which places are the best for taking photos?");
    continueReq.previousResponseId = res.id;

    ResponsesResponse continueRes = client.createResponse(continueReq);

    foreach (ref msg; continueRes.output.filter!(x => x.status == "completed"))
    {
        writeln(msg.content);
    }

    // List input items
    writeln("-------------------------------");
    auto list = client.listInputItems(listInputItemsRequest(continueRes.id));
    writeln(list.data.length);
    writeln(list);
}
