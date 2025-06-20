/**
OpenAI API Client configuration
*/
module openai.clients.config;

import mir.deser.json;
import mir.ser.json;

@safe:

///
enum ENV_OPENAI_API_KEY = "OPENAI_API_KEY";

///
enum ENV_OPENAI_ORGANIZATION = "OPENAI_ORGANIZATION";

///
enum ENV_OPENAI_API_BASE = "OPENAI_API_BASE";

///
enum ENV_OPENAI_DEPLOYMENT_ID = "OPENAI_DEPLOYMENT_ID";

///
enum ENV_OPENAI_API_VERSION = "OPENAI_API_VERSION";

/// Default Azure OpenAI API version (2025-04-01-preview is also available)
enum DEFAULT_OPENAI_API_VERSION = "2024-10-21";

///
class OpenAIClientConfig
{
    string apiKey;
    string organization;
    string apiBase = "https://api.openai.com/v1";
    string deploymentId;
    string apiVersion = DEFAULT_OPENAI_API_VERSION;

    bool isAzure() const @safe
    {
        import std.algorithm.searching : canFind;

        return apiBase.canFind(".api.cognitive.microsoft.com");
    }

    package this()
    {
        this.apiBase = "https://api.openai.com/v1";
        this.apiVersion = DEFAULT_OPENAI_API_VERSION;
    }

    /// Initialize the configuration with the given API key.
    this(string apiKey)
    {
        this.apiKey = apiKey;
    }

    /// Initialize the configuration with an API key and the
    /// organization identifier used for OpenAI's multi-tenant API.
    this(string apiKey, string organization)
    {
        this.apiKey = apiKey;
        this.organization = organization;
    }

    /**
     * Construct a configuration from environment variables.
     *
     * The following variables are read by default:
     * `OPENAI_API_KEY`, `OPENAI_ORGANIZATION`, `OPENAI_API_BASE`,
     * `OPENAI_DEPLOYMENT_ID` and `OPENAI_API_VERSION`.
     * Alternative variable names can be supplied via the parameters.
     */
    static OpenAIClientConfig fromEnvironment(
        string envApiKeyName = ENV_OPENAI_API_KEY,
        string envOrgName = ENV_OPENAI_ORGANIZATION,
        string envApiBaseName = ENV_OPENAI_API_BASE,
        string envDeploymentName = ENV_OPENAI_DEPLOYMENT_ID,
        string envApiVersionName = ENV_OPENAI_API_VERSION)
    {
        auto config = new OpenAIClientConfig;
        config.loadFromEnvironmentVariables(envApiKeyName, envOrgName,
            envApiBaseName, envDeploymentName, envApiVersionName);
        return config;
    }

    /**
     * Construct a configuration from a JSON file.
     *
     * The file should contain keys such as `apiKey`, `organization`,
     * `apiBase`, `deploymentId` and `apiVersion`.
     */
    static OpenAIClientConfig fromFile(string filePath)
    {
        auto config = new OpenAIClientConfig;
        config.loadFromFile(filePath);
        return config;
    }

    /**
     * Populate this configuration from environment variables.
     *
     * See `fromEnvironment` for the default variable names. Missing
     * values fall back to the OpenAI defaults.
     */
    void loadFromEnvironmentVariables(
        string envApiKeyName = ENV_OPENAI_API_KEY,
        string envOrgName = ENV_OPENAI_ORGANIZATION,
        string envApiBaseName = ENV_OPENAI_API_BASE,
        string envDeploymentName = ENV_OPENAI_DEPLOYMENT_ID,
        string envApiVersionName = ENV_OPENAI_API_VERSION)
    {
        import std.process : environment;

        auto envApiKey = environment.get(envApiKeyName, "");
        auto envOrganization = environment.get(envOrgName, "");
        auto envApiBase = environment.get(envApiBaseName, "");
        auto envDeploymentId = environment.get(envDeploymentName, "");
        auto envApiVersion = environment.get(envApiVersionName, "");

        this.apiKey = envApiKey;
        this.organization = envOrganization;
        this.apiBase = envApiBase.length ? envApiBase : "https://api.openai.com/v1";
        this.deploymentId = envDeploymentId;
        if (envApiVersion.length)
            this.apiVersion = envApiVersion;
    }

    /**
     * Load configuration fields from a JSON file. The format mirrors
     * the one used by `saveToFile` and `fromFile`.
     */
    void loadFromFile(string filePath)
    {
        import std.file;

        auto configText = readText(filePath);

        @serdeIgnoreUnexpectedKeys
        static struct ConfigData
        {
            @serdeIgnoreDefault
            string apiKey;

            @serdeOptional
            @serdeIgnoreDefault
            string organization;

            @serdeOptional
            @serdeIgnoreDefault
            string apiBase;

            @serdeOptional
            @serdeIgnoreDefault
            string deploymentId;

            @serdeOptional
            @serdeIgnoreDefault
            string apiVersion;
        }

        auto config = deserializeJson!ConfigData(configText);
        this.apiKey = config.apiKey;
        this.organization = config.organization;
        if (config.apiBase.length)
            this.apiBase = config.apiBase;
        if (config.deploymentId.length)
            this.deploymentId = config.deploymentId;
        if (config.apiVersion.length)
            this.apiVersion = config.apiVersion;
    }

    /**
     * Write the current configuration to a JSON file. The output
     * can later be reloaded with `loadFromFile`.
     */
    void saveToFile(string filePath)
    {
        import std.file;

        write(filePath, serializeJson(this));
    }
}
