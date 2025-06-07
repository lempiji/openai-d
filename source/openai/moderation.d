/**
OpenAI API Moderations

Standards: https://platform.openai.com/docs/api-reference/moderations
*/
module openai.moderation;

import mir.serde;

@safe:

///
struct ModerationRequest
{
    ///
    string input;

    ///
    @serdeIgnoreDefault
    string model;
}

///
ModerationRequest moderationRequest(string input)
{
    auto request = ModerationRequest();
    request.input = input;
    return request;
}

/+
// moderation response format
{
  "id": "modr-AB8CjOTu2jiq12hp1AQPfeqFWaORR",
  "model": "text-moderation-007",
  "results": [
    {
      "flagged": true,
      "categories": {
        "sexual": false,
        "hate": false,
        "harassment": true,
        "self-harm": false,
        "sexual/minors": false,
        "hate/threatening": false,
        "violence/graphic": false,
        "self-harm/intent": false,
        "self-harm/instructions": false,
        "harassment/threatening": true,
        "violence": true
      },
      "category_scores": {
        "sexual": 0.000011726012417057063,
        "hate": 0.22706663608551025,
        "harassment": 0.5215635299682617,
        "self-harm": 2.227119921371923e-6,
        "sexual/minors": 7.107352217872176e-8,
        "hate/threatening": 0.023547329008579254,
        "violence/graphic": 0.00003391829886822961,
        "self-harm/intent": 1.646940972932498e-6,
        "self-harm/instructions": 1.1198755256458526e-9,
        "harassment/threatening": 0.5694745779037476,
        "violence": 0.9971134662628174
      }
    }
  ]
}
+/

/// @serdeIgnoreUnexpectedKeys
struct ModerationCategories
{
    /// "sexual": false
    bool sexual;

    /// "sexual/minors": false
    @serdeKeys("sexual/minors")
    bool sexualMinors;

    /// "hate": false
    bool hate;

    /// "hate/threatening": false
    @serdeKeys("hate/threatening")
    bool hateThreatening;

    /// "harassment": true
    bool harassment;

    /// "harassment/threatening": true
    @serdeKeys("harassment/threatening")
    bool harassmentThreatening;

    /// "self-harm": false
    @serdeKeys("self-harm")
    bool selfHarm;

    /// "self-harm/intent": false
    @serdeKeys("self-harm/intent")
    bool selfHarmIntent;

    /// "self-harm/instructions": false
    @serdeKeys("self-harm/instructions")
    bool selfHarmInstructions;

    /// "violence": true
    bool violence;

    /// "violence/graphic": false
    @serdeKeys("violence/graphic")
    bool violenceGraphic;
}

/// @serdeIgnoreUnexpectedKeys
struct ModerationCategoryScores
{
    /// "sexual": 0.000011726012417057063
    float sexual;

    /// "sexual/minors": 7.107352217872176e-8
    @serdeKeys("sexual/minors")
    float sexualMinors;

    /// "hate": 0.22706663608551025
    float hate;

    /// "hate/threatening": 0.023547329008579254
    @serdeKeys("hate/threatening")
    float hateThreatening;

    /// "harassment": 0.5215635299682617
    float harassment;

    /// "harassment/threatening": 0.5694745779037476
    @serdeKeys("harassment/threatening")
    float harassmentThreatening;

    /// "self-harm": 2.227119921371923e-6
    @serdeKeys("self-harm")
    float selfHarm;

    /// "self-harm/intent": 1.646940972932498e-6
    @serdeKeys("self-harm/intent")
    float selfHarmIntent;

    /// "self-harm/instructions": 1.1198755256458526e-9
    @serdeKeys("self-harm/instructions")
    float selfHarmInstructions;

    /// "violence": 0.9971134662628174
    float violence;

    /// "violence/graphic": 0.00003391829886822961
    @serdeKeys("violence/graphic")
    float violenceGraphic;
}

///
struct ModerationResult
{
    ///
    ModerationCategories categories;

    ///
    @serdeKeys("category_scores")
    ModerationCategoryScores categoryScores;

    ///
    bool flagged;
}

///
struct ModerationResponse
{

    ///
    string id;

    ///
    string model;

    ///
    ModerationResult[] results;
}
