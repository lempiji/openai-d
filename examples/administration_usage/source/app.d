import std;
import openai;

/// Demonstrate the Administration Usage API.
void main()
{
    auto client = new OpenAIAdminClient();

    auto costReq = listCostsRequest(Clock.currTime() - 1.days, 20);
    auto costs = client.listCosts(costReq);

    const totalCost = costs.data
        .map!"a.results"()
        .joiner()
        .fold!"a + b.amount.value"(0.0);
    writeln("Total cost: ", totalCost);

    auto usageReq = listUsageRequest(Clock.currTime() - 1.days, 20);

    auto usageCompletions = client.listUsageCompletions(usageReq)
        .data
        .map!"a.results"()
        .joiner()
        .map!(a => a.get!UsageCompletionsResult);

    auto usageEmbeddings = client.listUsageEmbeddings(usageReq)
        .data
        .map!"a.results"()
        .joiner()
        .map!(a => a.get!UsageEmbeddingsResult);

    auto usageAudioSpeeches = client.listUsageAudioSpeeches(usageReq)
        .data
        .map!"a.results"()
        .joiner()
        .map!(a => a.get!UsageAudioSpeechesResult);

    auto usageImages = client.listUsageImages(usageReq)
        .data
        .map!"a.results"()
        .joiner()
        .map!(a => a.get!UsageImagesResult);

    writeln("Completions:     ", usageCompletions);
    writeln("Embeddings:      ", usageEmbeddings);
    writeln("Audios(speechs): ", usageAudioSpeeches);
    writeln("Images:          ", usageImages);
}
