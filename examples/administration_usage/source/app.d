import std;
import openai;

/// Demonstrate the Administration Usage API.
void main()
{
    auto client = new OpenAIAdminClient();

    auto costReq = listCostsRequest(Clock.currTime() - 1.days, 3);
    auto costs = client.listCosts(costReq);
    writeln(costs.data);

    auto usageReq = listUsageRequest(Clock.currTime() - 1.days, 3);

    auto completions = client.listUsageCompletions(usageReq);
    writeln(completions.data);

    auto embeddings = client.listUsageEmbeddings(usageReq);
    writeln(embeddings.data);

    auto audios = client.listUsageAudioSpeeches(usageReq);
    writeln(audios.data);

    auto images = client.listUsageImages(usageReq);
    writeln(images.data);
}
