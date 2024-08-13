module app;

import std.stdio;

import openai;

void main()
{
    // If the argument Config is omitted, it is read from an environment variable 'OPENAI_API_KEY'
    // auto config = OpenAIClientConfig.fromFile("config.json");
    // auto client = new OpenAIClient(config);
    auto client = new OpenAIClient;

    auto request = chatCompletionRequest("gpt-4o-mini", [
        systemChatMessage("You are a helpful assistant."),
        userChatMessage("calc 3 + 5 - 2.5")
    ], 200, 1);

    // define functions
    request.functions = [
        ChatCompletionFunction(
            "add", "add 2 numbers",
            JsonSchema.object_([
                "a": JsonSchema.number_("lhs"),
                "b": JsonSchema.number_("rhs"),
            ])
        ),
        ChatCompletionFunction(
            "sub", "subtract 2 numbers",
            JsonSchema.object_([
                "a": JsonSchema.number_("lhs"),
                "b": JsonSchema.number_("rhs"),
            ])
        ),
        ChatCompletionFunction(
            "reportAnswer", "report the answer",
            JsonSchema.object_([
                "value": JsonSchema.number_("calculation result"),
            ])
        ),
    ];
    request.functionCall = "auto";

    foreach (completionCount; 0 .. 5) // max completions
    {
        writeln("start: ", completionCount + 1);
        scope (exit)
            writeln("end");

        auto response = client.chatCompletion(request);
        assert(response.choices.length > 0);

        ChatMessage responseMessage = response.choices[0].message;

        import mir.algebraic;

        bool shouldContinue = responseMessage.functionCall.match!(
            (in ChatMessageFunctionCall fc) {
            import mir.deser.json;
            import mir.ser.json;

            switch (fc.name)
            {
            case "add":
                request.messages ~= responseMessage;
                request.messages ~= functionChatMessage(fc.name, invoke!(add, TwoOperands)(fc.arguments));
                return true;
            case "sub":
                request.messages ~= responseMessage;
                request.messages ~= functionChatMessage(fc.name, invoke!(sub, TwoOperands)(fc.arguments));
                return true;
            case "reportAnswer":
                reportAnswer(fc.arguments);
                return false;
            default:
                writefln!"Error: function(%s) not found"(fc.name);
                return false;
            }
        }, (typeof(null) _) {
            writefln!"Answer: %s"(responseMessage.content);
            return false;
        });

        if (!shouldContinue)
            break;
    }
}

// functions

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

string invoke(alias fun, T)(in string arguments)
{
    import mir.ser.json;
    import mir.deser.json;

    return serializeJson(fun(deserializeJson!T(arguments)));
}

struct Answer
{
    double value;
}

void reportAnswer(in string arguments)
{
    import mir.deser.json;

    const answer = deserializeJson!Answer(arguments);
    writeln("Answer: ", answer.value);
}