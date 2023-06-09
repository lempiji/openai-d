/**
OpenAI API Client
*/
module openai.common;

import mir.algebraic;

@safe:

///
alias JsonValue = Variant!(typeof(null), bool, string, long, double, string[], long[], double[], This[], This[string]);

///
alias StopToken = Algebraic!(typeof(null), string, string[]);

/// Static utilities for function_call
struct JsonSchema
{
    @disable this();
    @disable this(this);

    ///
    static JsonValue object_(string description, JsonValue[string] properties, string[] required)
    {
        return JsonValue([
            "type": JsonValue("object"),
            "description": JsonValue(description),
            "properties": JsonValue(properties),
            "required": JsonValue(required),
        ]);
    }

    ///
    static JsonValue object_(JsonValue[string] properties, string[] required)
    {
        return JsonValue([
            "type": JsonValue("object"),
            "properties": JsonValue(properties),
            "required": JsonValue(required),
        ]);
    }

    ///
    static JsonValue object_(JsonValue[string] properties)
    {
        return JsonValue([
            "type": JsonValue("object"),
            "properties": JsonValue(properties),
        ]);
    }

    ///
    static JsonValue boolean_(string description)
    {
        return JsonValue([
            "type": JsonValue("boolean"),
            "description": JsonValue(description),
        ]);
    }

    ///
    static JsonValue boolean_()
    {
        return JsonValue([
            "type": JsonValue("boolean"),
        ]);
    }

    ///
    static JsonValue string_(string description, string[] enum_)
    {
        return JsonValue([
            "type": JsonValue("string"),
            "description": JsonValue(description),
            "enum": JsonValue(enum_),
        ]);
    }

    ///
    static JsonValue string_(string description, ulong minLength, ulong maxLength)
    {
        return JsonValue([
            "type": JsonValue("string"),
            "description": JsonValue(description),
            "minLength": JsonValue(minLength),
            "maxLength": JsonValue(maxLength),
        ]);
    }

    ///
    static JsonValue string_(string description, string pattern, ulong minLength, ulong maxLength)
    {
        return JsonValue([
            "type": JsonValue("string"),
            "description": JsonValue(description),
            "pattern": JsonValue(pattern),
            "minLength": JsonValue(minLength),
            "maxLength": JsonValue(maxLength),
        ]);
    }

    ///
    static JsonValue string_(string description, string pattern)
    {
        return JsonValue([
            "type": JsonValue("string"),
            "description": JsonValue(description),
            "pattern": JsonValue(pattern),
        ]);
    }

    ///
    static JsonValue integer_(string description, long minimum, long maximum)
    {
        return JsonValue([
            "type": JsonValue("integer"),
            "description": JsonValue(description),
            "minimum": JsonValue(minimum),
            "maximum": JsonValue(maximum),
        ]);
    }

    ///
    static JsonValue integer_(string description)
    {
        return JsonValue([
            "type": JsonValue("integer"),
            "description": JsonValue(description),
        ]);
    }

    ///
    static JsonValue integer_()
    {
        return JsonValue([
            "type": JsonValue("integer"),
        ]);
    }

    ///
    static JsonValue number_(string description, double minimum, double maximum)
    {
        return JsonValue([
            "type": JsonValue("number"),
            "description": JsonValue(description),
            "minimum": JsonValue(minimum),
            "maximum": JsonValue(maximum),
        ]);
    }

    ///
    static JsonValue number_(string description)
    {
        return JsonValue([
            "type": JsonValue("number"),
            "description": JsonValue(description),
        ]);
    }

    ///
    static JsonValue number_()
    {
        return JsonValue([
            "type": JsonValue("number"),
        ]);
    }

    ///
    static JsonValue array_(string description, JsonValue items, ulong minItems, ulong maxItems)
    {
        return JsonValue([
            "type": JsonValue("array"),
            "description": JsonValue(description),
            "items": JsonValue(items),
            "minItems": JsonValue(minItems),
            "maxItems": JsonValue(maxItems),
        ]);
    }
}
