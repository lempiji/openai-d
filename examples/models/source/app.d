module app;

import std.stdio;
import std.algorithm;
import std.array;

import openai;

void main()
{
    auto client = new OpenAIClient;

    auto models = client.listModels();
    auto modelIds = models.data
        .map!"a.id"
        .filter!(a => a.canFind("ada"))
        .array();
    sort(modelIds);
    modelIds.each!writeln();
}
