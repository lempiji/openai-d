import std.stdio;

import openai;
import mir.serde;
import mir.deser.json;
import mir.algebraic;

void main()
{
    auto client = new OpenAIClient;

    auto request = chatCompletionRequest(openai.GPT4OMini, [
        developerChatMessage("You are a helpful math tutor. Guide the user through the solution step by step."),
        userChatMessage("how can I solve 8x + 7 = -23")
    ], 16, 0);

    request.responseFormat = jsonResponseFormat("mathResponse", parseJsonSchema!MathResponse);

    auto response = client.chatCompletion(request);
    assert(response.choices.length > 0);

    // dfmt off
    response.choices[0].message.content.match!(
        (string content) {
            writeln(content);

            auto mathResponse = deserializeJson!MathResponse(content);
            writeln(mathResponse);
        },
        _ => writeln("Unexpected response type")
    );
    // dfmt on
}

/+
class Step(BaseModel):
  explanation: str
  output: str

class MathResponse(BaseModel):
  steps: list[Step]
  final_answer: str
+/

struct Step
{
    @serdeRequired
    string explanation;
    @serdeRequired
    string output;
}

struct MathResponse
{
    @serdeRequired
    Step[] steps;
    @serdeRequired
    string final_answer;
}
