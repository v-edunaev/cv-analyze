namespace CVAnalyzer.Api.Services;

public class LlmServiceFactory
{
    private readonly IServiceProvider _serviceProvider;
    private readonly IConfiguration _configuration;

    public LlmServiceFactory(IServiceProvider serviceProvider, IConfiguration configuration)
    {
        _serviceProvider = serviceProvider;
        _configuration = configuration;
    }

    public ILlmService CreateLlmService()
    {
        var provider = _configuration["LLM:Provider"]?.ToLower();

        return provider switch
        {
            "openai" => (ILlmService)_serviceProvider.GetService(typeof(OpenAIService))!,
            "gemini" => (ILlmService)_serviceProvider.GetService(typeof(GeminiService))!,
            _ => (ILlmService)_serviceProvider.GetService(typeof(OpenAIService))! // Default to OpenAI
        };
    }
}