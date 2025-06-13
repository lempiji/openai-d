import std.stdio;
import std.file : write;
import std.base64;

import openai;

void main()
{
    auto client = new OpenAIClient();

    auto request = imageGenerationRequest("A cute baby sea otter");
    request.responseFormat = ImageResponseFormatB64Json;

    auto response = client.imageGeneration(request);
    auto bytes = Base64.decode(response.data[0].b64Json);
    write("image.png", bytes);
    writeln("saved image.png: ", bytes.length, " bytes");
}
