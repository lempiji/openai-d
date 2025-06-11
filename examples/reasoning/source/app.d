import std.stdio;
import openai;

void main()
{
    auto client = new OpenAIClient();
    auto request = chatCompletionRequest(
        openai.O4Mini, // or openai.O3
        [
            systemChatMessage("You are a reasoning assistant."),
            userChatMessage(
                "A snail is at the bottom of a 20\xE2\x80\x91meter well. " ~
                "It climbs 5 meters each day and slips back 3 each night. " ~
                "On which day does it escape? Explain step by step."
            )
    ],
        1000, 1); // sets maxCompletionTokens and temperature
    request.reasoningEffort = ReasoningEffortLow;

    auto response = client.chatCompletion(request);
    writeln(response.choices[0].message.content);
}
