/**
OpenAI API Images

Standards: https://platform.openai.com/docs/api-reference/images
*/
module openai.images;

import mir.serde;

@safe:

// -----------------------------------------------------------------------------
// Enumerations
// -----------------------------------------------------------------------------

/// Square resolution 256x256.
enum ImageSize256x256 = "256x256";
/// Square resolution 512x512.
enum ImageSize512x512 = "512x512";
/// Square resolution 1024x1024.
enum ImageSize1024x1024 = "1024x1024";
/// Landscape resolution 1792x1024.
enum ImageSize1792x1024 = "1792x1024";
/// Portrait resolution 1024x1792.
enum ImageSize1024x1792 = "1024x1792";
/// Landscape resolution 1536x1024.
enum ImageSize1536x1024 = "1536x1024";
/// Portrait resolution 1024x1536.
enum ImageSize1024x1536 = "1024x1536";

/// Standard image quality.
enum ImageQualityStandard = "standard";
/// High definition image quality.
enum ImageQualityHd = "hd";

/// Vivid artistic style.
enum ImageStyleVivid = "vivid";
/// Natural artistic style.
enum ImageStyleNatural = "natural";

/// Return an URL to the generated image.
enum ImageResponseFormatUrl = "url";
/// Return base64 encoded image content.
enum ImageResponseFormatB64Json = "b64_json";

// -----------------------------------------------------------------------------
// Requests
// -----------------------------------------------------------------------------

/// Request for `/images/generations`.
struct ImageGenerationRequest
{
    string prompt;
    @serdeIgnoreDefault
    string model;
    @serdeIgnoreDefault
    uint n = 1;
    @serdeIgnoreDefault
    string quality;
    @serdeIgnoreDefault
    string style;
    @serdeIgnoreDefault
    string size;
    @serdeIgnoreDefault
    @serdeKeys("response_format")
    string responseFormat = ImageResponseFormatUrl;
    @serdeIgnoreDefault
    string user;
}

/// Convenience constructor for image generation requests.
ImageGenerationRequest imageGenerationRequest(string prompt)
{
    auto req = ImageGenerationRequest();
    req.prompt = prompt;
    return req;
}

/// Request for `/images/edits`.
struct ImageEditRequest
{
    string image;
    @serdeIgnoreDefault
    string mask;
    string prompt;
    @serdeIgnoreDefault
    string model;
    @serdeIgnoreDefault
    uint n = 1;
    @serdeIgnoreDefault
    string size;
    @serdeIgnoreDefault
    @serdeKeys("response_format")
    string responseFormat = ImageResponseFormatUrl;
    @serdeIgnoreDefault
    string user;
}

/// Convenience constructor for image edit requests.
ImageEditRequest imageEditRequest(string image, string prompt)
{
    auto req = ImageEditRequest();
    req.image = image;
    req.prompt = prompt;
    return req;
}

/// Request for `/images/variations`.
struct ImageVariationRequest
{
    string image;
    @serdeIgnoreDefault
    string model;
    @serdeIgnoreDefault
    uint n = 1;
    @serdeIgnoreDefault
    string size;
    @serdeIgnoreDefault
    @serdeKeys("response_format")
    string responseFormat = ImageResponseFormatUrl;
    @serdeIgnoreDefault
    string user;
}

/// Convenience constructor for image variation requests.
ImageVariationRequest imageVariationRequest(string image)
{
    auto req = ImageVariationRequest();
    req.image = image;
    return req;
}

// -----------------------------------------------------------------------------
// Responses
// -----------------------------------------------------------------------------

struct GeneratedImage
{
    @serdeOptional
    @serdeKeys("b64_json")
    string b64Json;
    @serdeOptional
    string url;
    @serdeOptional
    @serdeKeys("revised_prompt")
    string revisedPrompt;
}

struct ImageResponse
{
    long created;
    GeneratedImage[] data;
}

// -----------------------------------------------------------------------------
// Unit tests
// -----------------------------------------------------------------------------

unittest
{
    auto req = imageGenerationRequest("A cat");
    import mir.ser.json : serializeJson;

    assert(serializeJson(req) == `{"prompt":"A cat"}`);
}

unittest
{
    import mir.deser.json : deserializeJson;

    const json = `{"created":1,"data":[{"b64_json":"aa"}]}`;
    auto res = deserializeJson!ImageResponse(json);
    assert(res.data.length == 1);
    assert(res.data[0].b64Json == "aa");
}
