/**
OpenAI API Client
*/
module openai.common;

import mir.algebraic;
import mir.algebraic_alias.json : JsonAlgebraic;
import std.traits;

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
    static JsonValue object_(string description, JsonValue[string] properties, string[] required, bool additionalProperties)
    {
        import std.algorithm : map;
        import std.array : array;

        return JsonValue([
            "type": JsonValue("object"),
            "description": JsonValue(description),
            "properties": JsonValue(properties),
            "required": JsonValue(required.map!(x => JsonValue(x)).array),
            "additionalProperties": JsonValue(additionalProperties),
        ]);
    }

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
    static JsonValue object_(JsonValue[string] properties, string[] required, bool additionalProperties)
    {
        import std.algorithm : map;
        import std.array : array;

        return JsonValue([
            "type": JsonValue("object"),
            "properties": JsonValue(properties),
            "required": JsonValue(required.map!(x => JsonValue(x)).array),
            "additionalProperties": JsonValue(additionalProperties),
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
    static JsonValue object_(string description, JsonValue[string] properties, bool additionalProperties)
    {
        return JsonValue([
            "type": JsonValue("object"),
            "description": JsonValue(description),
            "properties": JsonValue(properties),
            "additionalProperties": JsonValue(additionalProperties),
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
    static JsonValue object_(JsonValue[string] properties, bool additionalProperties)
    {
        return JsonValue([
            "type": JsonValue("object"),
            "properties": JsonValue(properties),
            "additionalProperties": JsonValue(additionalProperties),
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
    static JsonValue string_(string[] enum_)
    {
        import std.algorithm : map;
        import std.array : array;

        return JsonValue([
            "type": JsonValue("string"),
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
    auto weatherSchema = JsonSchema.object_(
        [
        "location": JsonSchema.string_("The city and state, e.g. San Francisco, CA"),
        "unit": JsonSchema.string_("string", ["celsius", "fahrenheit"]),
    ], ["location"]);
}

@("simple weather schema with strict")
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
        "additionalProperties": false,
    },
    */
    auto weatherSchema = JsonSchema.object_(
        [
        "location": JsonSchema.string_("The city and state, e.g. San Francisco, CA"),
        "unit": JsonSchema.string_("string", ["celsius", "fahrenheit"]),
    ], ["location"], false);
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
    auto get_current_weather_params = JsonSchema.object_(
        [
        "location": JsonSchema.string_("The city and state, e.g. San Francisco, CA"),
        "format": JsonSchema.string_("The temperature unit to use. Infer this from the users location.", [
            "celcius", "farenheit"
        ])
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
    auto get_n_day_weather_forecast_params = JsonSchema.object_(
        [
        "location": JsonSchema.string_("The city and state, e.g. San Francisco, CA"),
        "format": JsonSchema.string_("The temperature unit to use. Infer this from the users location.", [
            "celcius", "farenheit"
        ]),
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

private string getFieldDescription(T, string field)()
{
    alias attrs = __traits(getAttributes, __traits(getMember, T, field));
    foreach (uda; attrs)
    {
        static if (is(typeof(uda) == string))
        {
            return uda;
        }
    }
    return null;
}

private enum isStaticString(alias x) = is(typeof(x) == string);

///
JsonValue parseJsonSchema(T)(string description = null)
{
    import std.meta : Filter;

    alias TAttributes = __traits(getAttributes, T);
    alias TAttributesStr = Filter!(isStaticString, TAttributes);
    enum hasStrAttributes = TAttributesStr.length > 0;

    JsonValue schema;

    static if (is(T == string))
    {
        schema = description ? JsonSchema.string_(description) : JsonSchema.string_();
    }
    else static if (is(T == enum))
    {
        string[] members;
        alias enumMembers = EnumMembers!T;
        static if (is(OriginalType!T == string))
        {
            static foreach (i, _; enumMembers)
            {
                members ~= enumMembers[i];
            }
        }
        else
        {
            static foreach (i, _; enumMembers)
            {
                members ~= __traits(identifier, enumMembers[i]);
            }
        }
        schema = description ? JsonSchema.string_(description, members) : JsonSchema.string_(members);
    }
    else static if (isIntegral!T)
    {
        schema = description ? JsonSchema.integer_(description) : JsonSchema.integer_();
    }
    else static if (isFloatingPoint!T)
    {
        schema = description ? JsonSchema.number_(description) : JsonSchema.number_();
    }
    else static if (is(T == bool))
    {
        schema = description ? JsonSchema.boolean_(description) : JsonSchema.boolean_();
    }
    else static if (is(T == char) || is(T == wchar) || is(T == dchar))
    {
        schema = description ? JsonSchema.string_(description) : JsonSchema.string_();
    }
    else static if (isArray!T)
    {
        import std.range : ElementType;

        // dfmt off
        schema = description
            ? JsonSchema.array_(description, parseJsonSchema!(ElementType!T))
            : JsonSchema.array_(parseJsonSchema!(ElementType!T));
        // dfmt on
    }
    else
    {
        import std.meta : AliasSeq;
        import std.traits : FieldNameTuple, hasUDA;
        import mir.serde : serdeRequired, serdeIgnoreUnexpectedKeys;

        JsonValue[string] properties;
        string[] required;

        static foreach (field; FieldNameTuple!T)
        {
            {
                enum fieldDescription = getFieldDescription!(T, field)();
                properties[field] = parseJsonSchema!(typeof(__traits(getMember, T.init, field)))(fieldDescription);

                static if (hasUDA!(__traits(getMember, T, field), serdeRequired))
                {
                    required ~= field;
                }
            }
        }

        enum allowAdditionalProperties = hasUDA!(T, serdeIgnoreUnexpectedKeys);

        static if (allowAdditionalProperties)
        {
            if (description)
            {
                // dfmt off
                schema = required.length > 0
                    ? JsonSchema.object_(description, properties, required)
                    : JsonSchema.object_(description, properties);
                // dfmt on
            }
            else
            {
                static if (hasStrAttributes)
                {
                    // dfmt off
                    schema = required.length > 0
                        ? JsonSchema.object_(TAttributesStr[0], properties, required)
                        : JsonSchema.object_(TAttributesStr[0], properties);
                    // dfmt on
                }
                else
                {
                    // dfmt off
                    schema = required.length > 0
                        ? JsonSchema.object_(properties, required)
                        : JsonSchema.object_(properties);
                    // dfmt on
                }
            }
        }
        else
        {
            if (description)
            {
                // dfmt off
                schema = required.length > 0
                    ? JsonSchema.object_(description, properties, required, false)
                    : JsonSchema.object_(description, properties, false);
                // dfmt on
            }
            else
            {
                static if (hasStrAttributes)
                {
                    // dfmt off
                    schema = required.length > 0
                        ? JsonSchema.object_(TAttributesStr[0], properties, required, false)
                        : JsonSchema.object_(TAttributesStr[0], properties, false);
                    // dfmt on
                }
                else
                {
                    // dfmt off
                    schema = required.length > 0
                        ? JsonSchema.object_(properties, required, false)
                        : JsonSchema.object_(properties, false);
                    // dfmt on
                }
            }
        }
    }

    return schema;
}

@("parseJsonSchema builtin primitives")
unittest
{
    import mir.algebraic_alias.json : JsonAlgebraic;

    assert(parseJsonSchema!string() == JsonSchema.string_());
    assert(parseJsonSchema!int() == JsonSchema.integer_());
    assert(parseJsonSchema!long() == JsonSchema.integer_());
    assert(parseJsonSchema!short() == JsonSchema.integer_());
    assert(parseJsonSchema!float() == JsonSchema.number_());
    assert(parseJsonSchema!double() == JsonSchema.number_());
    assert(parseJsonSchema!bool() == JsonSchema.boolean_());
    assert(parseJsonSchema!char() == JsonSchema.string_());
    assert(parseJsonSchema!wchar() == JsonSchema.string_());
    assert(parseJsonSchema!dchar() == JsonSchema.string_());
}

@("parseJsonSchema arrays of builtin types")
unittest
{
    import mir.algebraic_alias.json : JsonAlgebraic;

    assert(parseJsonSchema!(int[])() == JsonSchema.array_(JsonSchema.integer_()));
    assert(parseJsonSchema!(string[])() == JsonSchema.array_(JsonSchema.string_()));
    assert(parseJsonSchema!(bool[])() == JsonSchema.array_(JsonSchema.boolean_()));
    assert(parseJsonSchema!(double[])() == JsonSchema.array_(JsonSchema.number_()));
}

@("parseJsonSchema arrays of structs")
unittest
{
    @("Custom description")
    struct TestStruct
    {
        @("Custom field description 1")
        string name;
        int age;
        @("Custom field description 2")
        bool isCool;
    }

    auto itemSchema = JsonSchema.object_("Custom description", [
        "name": JsonSchema.string_("Custom field description 1"),
        "age": JsonSchema.integer_(),
        "isCool": JsonSchema.boolean_("Custom field description 2"),
    ], false);
    auto schema = JsonSchema.array_(itemSchema);

    auto actual = parseJsonSchema!(TestStruct[])();
    assert(actual == schema, actual.toString() ~ "\n---\n" ~ schema.toString());
}

@("parseJsonSchema structs with builtin types")
unittest
{
    import mir.algebraic_alias.json : JsonAlgebraic;

    struct TestStruct
    {
        string name;
        int age;
        bool isCool;
    }

    auto schema = JsonSchema.object_([
        "name": JsonSchema.string_(),
        "age": JsonSchema.integer_(),
        "isCool": JsonSchema.boolean_(),
    ], false);

    assert(parseJsonSchema!TestStruct() == schema);
}

@("parseJsonSchema structs with nested structs")
unittest
{
    import mir.algebraic_alias.json : JsonAlgebraic;

    @("Address schema")
    struct Address
    {
        string street;
        string city;
        string state;
        string zip;
    }

    struct Person
    {
        string name;
        int age;
        bool isCool;
        Address address;
    }

    auto addressSchema = JsonSchema.object_("Address schema", [
        "street": JsonSchema.string_(),
        "city": JsonSchema.string_(),
        "state": JsonSchema.string_(),
        "zip": JsonSchema.string_(),
    ], false);

    assert(parseJsonSchema!Address() == addressSchema);

    auto addressSchema2 = JsonSchema.object_("Custom description", [
        "street": JsonSchema.string_(),
        "city": JsonSchema.string_(),
        "state": JsonSchema.string_(),
        "zip": JsonSchema.string_(),
    ], false);

    assert(parseJsonSchema!Address("Custom description") == addressSchema2);

    auto personSchema = JsonSchema.object_("Person schema", [
        "name": JsonSchema.string_(),
        "age": JsonSchema.integer_(),
        "isCool": JsonSchema.boolean_(),
        "address": addressSchema,
    ], false);

    assert(parseJsonSchema!Person("Person schema") == personSchema);
}

@("parseJsonSchema structs with description field")
unittest
{
    import mir.algebraic_alias.json : JsonAlgebraic;

    @("Custom description")
    struct TestStruct
    {
        @("Custom field description 1")
        string name;

        int age;
        @("Custom field description 2")
        bool isCool;
    }

    auto schema = JsonSchema.object_("Custom description", [
        "name": JsonSchema.string_("Custom field description 1"),
        "age": JsonSchema.integer_(),
        "isCool": JsonSchema.boolean_("Custom field description 2"),
    ], false);

    auto actual = parseJsonSchema!TestStruct();
    assert(actual == schema, actual.toString());
}

@("parseJsonSchema structs with required fields")
unittest
{
    import mir.algebraic_alias.json : JsonAlgebraic;
    import mir.serde : serdeRequired;

    struct TestStruct
    {
        @serdeRequired
        string name;
        @serdeRequired
        int age;
        bool isCool;
    }

    enum requiredFields = ["name", "age"];

    auto schema = JsonSchema.object_([
        "name": JsonSchema.string_(),
        "age": JsonSchema.integer_(),
        "isCool": JsonSchema.boolean_(),
    ], requiredFields, false);

    assert(parseJsonSchema!TestStruct() == schema);
}

@("parseJsonSchema structs with ignore unexpected keys")
unittest
{
    import mir.algebraic_alias.json : JsonAlgebraic;
    import mir.serde : serdeIgnoreUnexpectedKeys;

    @serdeIgnoreUnexpectedKeys
    struct TestStruct
    {
        string name;
        int age;
        bool isCool;
    }

    auto schema = JsonSchema.object_([
        "name": JsonSchema.string_(),
        "age": JsonSchema.integer_(),
        "isCool": JsonSchema.boolean_(),
    ]);

    auto actual = parseJsonSchema!TestStruct();
    assert(actual == schema, actual.toString() ~ "\n---\n" ~ schema.toString());
}

@("parseJsonSchema structs with full options")
unittest
{
    import mir.algebraic_alias.json : JsonAlgebraic;
    import mir.serde : serdeRequired, serdeIgnoreUnexpectedKeys;

    @("Custom description")
    @serdeIgnoreUnexpectedKeys
    struct TestStruct
    {
        @("Custom field description 1")
        @serdeRequired
        string name;
        int age;
        @("Custom field description 2")
        bool isCool;
    }

    auto schema = JsonSchema.object_("Custom description", [
        "name": JsonSchema.string_("Custom field description 1"),
        "age": JsonSchema.integer_(),
        "isCool": JsonSchema.boolean_("Custom field description 2"),
    ], ["name"]);

    auto actual = parseJsonSchema!TestStruct();
    assert(actual == schema, actual.toString() ~ "\n---\n" ~ schema.toString());
}

@("parseJsonSchema structs from OpenAI API example")
unittest
{
    import mir.serde : serdeRequired, serdeIgnoreUnexpectedKeys;

    struct Step
    {
        @serdeRequired
        string explanation;
        @serdeRequired
        string output;
    }

    struct MathResponse
    {
        @serdeRequired
        Step[] steps;
        @serdeRequired
        string final_answer;
    }

    auto stepSchema = JsonSchema.object_([
        "explanation": JsonSchema.string_(),
        "output": JsonSchema.string_(),
    ], ["explanation", "output"], false);

    auto mathResponseSchema = JsonSchema.object_([
        "steps": JsonSchema.array_(stepSchema),
        "final_answer": JsonSchema.string_(),
    ], ["steps", "final_answer"], false);

    auto actual = parseJsonSchema!MathResponse();
    assert(actual == mathResponseSchema, actual.toString() ~ "\n---\n" ~ mathResponseSchema.toString());
}

@("parseJsonSchema with enum")
unittest
{
    import mir.algebraic_alias.json : JsonAlgebraic;
    import mir.serde : serdeRequired;

    enum TaskState
    {
        ToDo,
        InProgress,
        Done,
    }

    struct Task
    {
        @serdeRequired
        @("task id")
        string id;

        @serdeRequired
        @("task state")
        TaskState state;
    }

    auto schema = JsonSchema.object_([
        "id": JsonSchema.string_("task id"),
        "state": JsonSchema.string_("task state", ["ToDo", "InProgress", "Done"]),
    ], ["id", "state"], false);

    auto actual = parseJsonSchema!Task();

    assert(actual == schema, actual.toString() ~ "\n---\n" ~ schema.toString());
}

@("parseJsonSchema with string enum members")
unittest
{
    import mir.algebraic_alias.json : JsonAlgebraic;
    import mir.serde : serdeRequired;

    enum TaskState
    {
        ToDo = "todo",
        InProgress = "in_progress",
        Done = "done",
    }

    struct Task
    {
        @serdeRequired
        @("task id")
        string id;

        @serdeRequired
        @("task state")
        TaskState state;
    }

    auto schema = JsonSchema.object_([
        "id": JsonSchema.string_("task id"),
        "state": JsonSchema.string_("task state", ["todo", "in_progress", "done"]),
    ], ["id", "state"], false);

    auto actual = parseJsonSchema!Task();

    assert(actual == schema, actual.toString() ~ "\n---\n" ~ schema.toString());
}
