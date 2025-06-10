module app;

import std.datetime;
import std.stdio;
import std.typecons;

import openai;
import d2sqlite3;

void main()
{
    auto client = new OpenAIClient;

    auto db = Database(":memory:");

    scope (exit)
    {
        auto tableNames = execute_query(db, `SELECT name FROM sqlite_master WHERE type='table';`);
        writeln(tableNames);

        import std.format;

        import mir.algebraic;
        import mir.string_map;

        auto name = tableNames[0].get!(StringMap!JsonValue)()["name"];
        writeln("name: ", name);
        auto dataset = execute_query(db, format!"SELECT * FROM %s"(name));
        writeln(dataset);
    }

    // make dummy data
    auto request = chatCompletionRequest("gpt-4o-mini", [
        systemChatMessage("You are a helpful SQL assistant."),
        userChatMessage(
            "Create a sample database table using sqlite3 with dummy product data for a car dealership in Japan.")
    ], 400, 1);

    // define tools
    // dfmt off
    request.tools = [
        ChatCompletionTool(
            "function",
            ChatCompletionFunction(
                "execute_query",
                "Executes a given SQL query using sqlite3. Supports various query types such as CREATE TABLE, SELECT, DELETE, etc. On successful execution of a SELECT query, it returns the fetched records.",
                JsonSchema.object_([
                    "query": JsonSchema.string_("statement"),
                ], ["query"])
            )
        ),
    ];
    // dfmt on
    request.toolChoice = "auto";

    foreach (completionCount; 0 .. 5) // max completions
    {
        writeln("start: ", completionCount + 1);
        scope (exit)
            writeln("end");

        auto response = client.chatCompletion(request);
        assert(response.choices.length > 0);

        ChatMessage responseMessage = response.choices[0].message;

        import mir.algebraic;

        if (responseMessage.toolCalls.length == 0)
        {
            writeln("Answer: ", responseMessage.content);
            break;
        }

        request.messages ~= responseMessage;

        import mir.deser.json;
        import mir.ser.json;

        foreach (toolCall; responseMessage.toolCalls)
        {
            switch (toolCall.function_.name)
            {
            case "execute_query":
                auto params = deserializeJson!ExecuteQueryParams(toolCall.function_.arguments);
                writefln!"query: '%s'"(params.query);
                auto queryResult = execute_query(db, params.query);
                request.messages ~= toolChatMessage(toolCall.function_.name, serializeJson(queryResult), toolCall.id);
                break;
            default:
                writefln!"Error: function(%s) not found"(toolCall.function_.name);
                break;
            }
        }
    }
}

// functions

struct ExecuteQueryParams
{
    string query;
}

JsonValue[] execute_query(scope Database db, string query)
{
    JsonValue[] records;
    db.run(query, (ResultRange results) {
        foreach (result; results)
        {
            JsonValue[string] record;
            foreach (i; 0 .. result.length)
            {
                final switch (result.columnType(i))
                {
                case SqliteType.INTEGER:
                    record[result.columnName(i)] = JsonValue(result.peek!long(i));
                    break;
                case SqliteType.FLOAT:
                    record[result.columnName(i)] = JsonValue(result.peek!double(i));
                    break;

                case SqliteType.TEXT:
                    record[result.columnName(i)] = JsonValue(result.peek!string(i));
                    break;

                case SqliteType.BLOB:
                    record[result.columnName(i)] = JsonValue("<BLOB...>");
                    //record[result.columnName(i)] = result.peek!(Blob, PeekMode.copy)(index);
                    break;

                case SqliteType.NULL:
                    record[result.columnName(i)] = JsonValue(null);
                    break;
                }
            }
            records ~= JsonValue(record);
        }
        return true;
    });
    return records;
}
