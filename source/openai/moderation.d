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

///
@serdeIgnoreUnexpectedKeys
struct ModerationCategories
{
    ///
    bool hate;

    ///
    @serdeKeys("hate/threatening")
    bool hateThreatening;

    ///
    @serdeKeys("self-harm")
    bool selfHarm;

    ///
    bool sexual;

    ///
    @serdeKeys("sexual/minors")
    bool sexualMinors;

    ///
    bool violence;

    ///
    @serdeKeys("violence/graphic")
    bool violenceGraphic;
}

///
@serdeIgnoreUnexpectedKeys
struct ModerationCategoryScores
{
    ///
    float hate;

    ///
    @serdeKeys("hate/threatening")
    float hateThreatening;

    ///
    @serdeKeys("self-harm")
    float selfHarm;

    ///
    float sexual;

    ///
    @serdeKeys("sexual/minors")
    float sexualMinors;

    ///
    float violence;

    ///
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
