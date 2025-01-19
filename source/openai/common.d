/**
OpenAI API Client
*/
module openai.common;

import mir.algebraic;
import mir.algebraic_alias.json : JsonAlgebraic;

@safe:

///
alias JsonValue = JsonAlgebraic;

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
        import std.algorithm : map;
        import std.array : array;

        return JsonValue([
            "type": JsonValue("object"),
            "description": JsonValue(description),
            "properties": JsonValue(properties),
            "required": JsonValue(required.map!(x => JsonValue(x)).array),
        ]);
    }

    ///
    static JsonValue object_(JsonValue[string] properties, string[] required)
    {
        import std.algorithm : map;
        import std.array : array;

        return JsonValue([
            "type": JsonValue("object"),
            "properties": JsonValue(properties),
            "required": JsonValue(required.map!(x => JsonValue(x)).array),
        ]);
    }

    ///
    static JsonValue object_(string description, JsonValue[string] properties)
    {
        return JsonValue([
            "type": JsonValue("object"),
            "description": JsonValue(description),
            "properties": JsonValue(properties),
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
    static JsonValue string_(string description, string pattern)
    {
        return JsonValue([
            "type": JsonValue("string"),
            "description": JsonValue(description),
            "pattern": JsonValue(pattern),
        ]);
    }

    ///
    static JsonValue string_(string description, string[] enum_)
    {
        import std.algorithm : map;
        import std.array : array;

        return JsonValue([
            "type": JsonValue("string"),
            "description": JsonValue(description),
            "enum": JsonValue(enum_.map!(x => JsonValue(x)).array),
        ]);
    }

    ///
    static JsonValue string_(string description)
    {
        return JsonValue([
            "type": JsonValue("string"),
            "description": JsonValue(description),
        ]);
    }

    ///
    static JsonValue string_()
    {
        return JsonValue([
            "type": JsonValue("string"),
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
    static JsonValue integer_(long minimum, long maximum)
    {
        return JsonValue([
            "type": JsonValue("integer"),
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
    static JsonValue number_(double minimum, double maximum)
    {
        return JsonValue([
            "type": JsonValue("number"),
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

    ///
    static JsonValue array_(JsonValue items, ulong minItems, ulong maxItems)
    {
        return JsonValue([
            "type": JsonValue("array"),
            "items": JsonValue(items),
            "minItems": JsonValue(minItems),
            "maxItems": JsonValue(maxItems),
        ]);
    }

    ///
    static JsonValue array_(string description, JsonValue items)
    {
        return JsonValue([
            "type": JsonValue("array"),
            "description": JsonValue(description),
            "items": JsonValue(items),
        ]);
    }

    ///
    static JsonValue array_(JsonValue items)
    {
        return JsonValue([
            "type": JsonValue("array"),
            "items": JsonValue(items),
        ]);
    }

    ///
    static JsonValue array_(string description)
    {
        return JsonValue([
            "type": JsonValue("array"),
            "description": JsonValue(description),
        ]);
    }

    ///
    static JsonValue array_()
    {
        return JsonValue([
            "type": JsonValue("array"),
        ]);
    }

    static JsonValue oneOf(JsonValue[] schemas...)
    in (schemas.length > 0)
    {
        return JsonValue([
            "oneOf": JsonValue(schemas)
        ]);
    }
    
    static JsonValue anyOf(JsonValue[] schemas...)
    in (schemas.length > 0)
    {
        return JsonValue([
            "anyOf": JsonValue(schemas)
        ]);
    }
    
    static JsonValue allOf(JsonValue[] schemas...)
    in (schemas.length > 0)
    {
        return JsonValue([
            "allOf": JsonValue(schemas)
        ]);
    }
    
    static JsonValue not(JsonValue[] schemas...)
    in (schemas.length > 0)
    {
        return JsonValue([
            "not": JsonValue(schemas)
        ]);
    }
}

@("simple weather schema")
unittest
{
    /*
    {
        "type": "object",
        "properties": {
            "location": {
                "type": "string",
                "description": "The city and state, e.g. San Francisco, CA",
            },
            "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]},
        },
        "required": ["location"],
    },
    */
    auto weatherSchema = JsonSchema.object_([
        "location": JsonSchema.string_("The city and state, e.g. San Francisco, CA"),
        "unit": JsonSchema.string_("string", ["celsius", "fahrenheit"]),
    ], ["location"]);
}

@("nested weather schema")
unittest
{
    /*
    {
        "name": "get_current_weather",
        "description": "Get the current weather",
        "parameters": {
            "type": "object",
            "properties": {
                "location": {
                    "type": "string",
                    "description": "The city and state, e.g. San Francisco, CA",
                },
                "format": {
                    "type": "string",
                    "enum": ["celsius", "fahrenheit"],
                    "description": "The temperature unit to use. Infer this from the users location.",
                },
            },
            "required": ["location", "format"],
        },
    },
    */
    auto get_current_weather_params = JsonSchema.object_([
        "location": JsonSchema.string_("The city and state, e.g. San Francisco, CA"),
        "format": JsonSchema.string_("The temperature unit to use. Infer this from the users location.", ["celcius", "farenheit"])
    ], ["location", "format"]);

    /*
    {
        "name": "get_n_day_weather_forecast",
        "description": "Get an N-day weather forecast",
        "parameters": {
            "type": "object",
            "properties": {
                "location": {
                    "type": "string",
                    "description": "The city and state, e.g. San Francisco, CA",
                },
                "format": {
                    "type": "string",
                    "enum": ["celsius", "fahrenheit"],
                    "description": "The temperature unit to use. Infer this from the users location.",
                },
                "num_days": {
                    "type": "integer",
                    "description": "The number of days to forecast",
                }
            },
            "required": ["location", "format", "num_days"]
        },
    },
    */
    auto get_n_day_weather_forecast_params = JsonSchema.object_([
        "location": JsonSchema.string_("The city and state, e.g. San Francisco, CA"),
        "format": JsonSchema.string_("The temperature unit to use. Infer this from the users location.", ["celcius", "farenheit"]),
        "num_days": JsonSchema.integer_("The number of days to forecast"),
    ], ["location", "format", "num_days"]);
}

unittest
{
    import mir.ser.json : serializeJson;

    const schema = JsonSchema.oneOf(
        JsonSchema.string_(),
        JsonSchema.integer_(),
    );

    const json = serializeJson(schema);

    assert(json == `{"oneOf":[{"type":"string"},{"type":"integer"}]}`);
}

unittest
{
    import mir.ser.json : serializeJson;

    const schema = JsonSchema.anyOf(
        JsonSchema.string_(),
        JsonSchema.integer_(),
    );

    const json = serializeJson(schema);

    assert(json == `{"anyOf":[{"type":"string"},{"type":"integer"}]}`);
}

unittest
{
    import mir.ser.json : serializeJson;

    const schema = JsonSchema.allOf(
        JsonSchema.string_("starts with 'a'", "^a.*"),
        JsonSchema.string_("ends with 'z'", ".*z$"),
    );

    const json = serializeJson(schema);

    assert(json == `{"allOf":[{"type":"string","description":"starts with 'a'","pattern":"^a.*"},{"type":"string","description":"ends with 'z'","pattern":".*z$"}]}`);
}

unittest
{
    import mir.ser.json : serializeJson;

    const schema = JsonSchema.not(
        JsonSchema.string_(),
        JsonSchema.integer_(),
    );

    const json = serializeJson(schema);

    assert(json == `{"not":[{"type":"string"},{"type":"integer"}]}`);
}