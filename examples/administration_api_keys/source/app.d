import std.stdio;

import openai;

void main()
{
    auto client = new OpenAIAdminClient();

    auto created = client.createAdminApiKey(createAdminApiKeyRequest("Example Key"));
    auto got = client.getAdminApiKey(created.id);
    auto list = client.listAdminApiKeys(listAdminApiKeysRequest(20));
    auto deleted = client.deleteAdminApiKey(created.id);

    writeln(created);
    writeln(got);
    writeln(list.data);
    writeln(deleted);
}
