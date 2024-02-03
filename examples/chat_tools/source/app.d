module app;

import std.stdio;

import openai;

void main()
{
    // If the argument Config is omitted, it is read from an environment variable 'OPENAI_API_KEY'
    // auto config = OpenAIClientConfig.fromFile("config.json");
    // auto client = new OpenAIClient(config);
    auto client = new OpenAIClient;

    auto request = chatCompletionRequest("gpt-3.5-turbo", [
        systemChatMessage("You are a helpful assistant."),
        userChatMessage("calc 3 + 5 - 2.5")
    ], 200, 1);

    // define tools
    // dfmt off
    request.tools = [
        ChatCompletionTool("function",
            ChatCompletionFunction(
                "add", "add 2 numbers",
                JsonSchema.object_([
                    "a": JsonSchema.number_("lhs"),
                    "b": JsonSchema.number_("rhs"),
                ])
            )
        ),
        ChatCompletionTool("function",
            ChatCompletionFunction(
                "sub", "subtract 2 numbers",
                JsonSchema.object_([
                    "a": JsonSchema.number_("lhs"),
                    "b": JsonSchema.number_("rhs"),
                ])
            )
        ),
    ];
    // dfmt on
    request.toolChoice = "auto";

    // setup tools
    import mir.ser.json;
    import mir.deser.json;

    alias ToolDelegate = string delegate(in string arguments);
    ToolDelegate[string] availableTools;
    availableTools["add"] = (in string arguments) {
        return serializeJson(add(deserializeJson!TwoOperands(arguments)));
    };
    availableTools["sub"] = (in string arguments) {
        return serializeJson(sub(deserializeJson!TwoOperands(arguments)));
    };

    foreach (completionCount; 0 .. 10) // max completions
    {
        auto response = client.chatCompletion(request);
        assert(response.choices.length > 0);

        ChatMessage responseMessage = response.choices[0].message;

        if (responseMessage.toolCalls.length > 0)
        {
            request.messages ~= responseMessage;

            int toolCallCount = 0;
            foreach (toolCall; responseMessage.toolCalls)
            {
                const toolFunctionName = toolCall.function_.name;
                if (toolFunctionName in availableTools)
                {
                    toolCallCount++;
                    auto toolFunction = availableTools[toolFunctionName];
                    auto resultContent = toolFunction(toolCall.function_.arguments);

                    request.messages ~= toolChatMessage(toolFunctionName, resultContent, toolCall.id);
                }
                else
                {
                    writefln!"Error: function(%s) not found"(toolFunctionName);
                    break;
                }
            }
            if (toolCallCount > 0)
            {
                response = client.chatCompletion(request);
            }
        }
        else
        {
            writefln!"Response: %s"(responseMessage.content);
            return;
        }
    }
}

// define functions
struct TwoOperands
{
    double a;
    double b;
}

double add(in TwoOperands args)
{
    return args.a + args.b;
}

double sub(in TwoOperands args)
{
    return args.a - args.b;
}
