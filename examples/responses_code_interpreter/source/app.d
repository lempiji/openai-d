module app;

import std.stdio;
import std.algorithm : filter;

import openai;

void main()
{
    auto client = new OpenAIClient();

    auto req = createResponseRequest(openai.GPT4O, "Run this Python code:\nprint(40 + 2)");

    ResponsesToolCodeInterpreter codeTool;
    req.tools = [ResponsesTool(codeTool)];
    req.include = [Includable.CodeInterpreterCallOutputs];

    ResponsesResponse res = client.createResponse(req);
    scope (exit)
        client.deleteResponse(res.id);

    foreach (ref msg; res.output.filter!(x => x.status == ResponseStatusCompleted))
        writeln(msg.content);
}
