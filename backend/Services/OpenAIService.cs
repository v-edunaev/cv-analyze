using System.Text.Json;
using CVAnalyzer.Api.DTOs;
using OpenAI.Chat;

namespace CVAnalyzer.Api.Services;

public class OpenAIService : LlmServiceBase
{
    private readonly ChatClient _chatClient;
    private readonly string _model;

    public OpenAIService(IConfiguration configuration, ILogger<OpenAIService> logger) : base(logger)
    {
        var apiKey = configuration["LLM:OpenAI:ApiKey"];
        _model = configuration["LLM:OpenAI:Model"] ?? "gpt-4o-mini";

        if (string.IsNullOrEmpty(apiKey))
        {
            throw new InvalidOperationException("OpenAI API key is not configured");
        }

        _chatClient = new ChatClient(_model, apiKey);
    }

    public override async Task<CandidateDto> ParseCvTextAsync(string cvText)
    {
        var prompt = GetExtractionPrompt(cvText);

        var messages = new List<ChatMessage>
        {
            ChatMessage.CreateSystemMessage("You are a CV/Resume parser. Extract structured information from resumes and return it in JSON format."),
            ChatMessage.CreateUserMessage(prompt)
        };

        var options = new ChatCompletionOptions
        {
            Temperature = 0.3f,
            ResponseFormat = ChatResponseFormat.CreateJsonObjectFormat()
        };

        try
        {
            var response = await _chatClient.CompleteChatAsync(messages, options);
            var content = response.Value.Content[0].Text ?? "{}";
            
            _logger.LogDebug("OpenAI response: {Content}", content);
            
            return ParseJsonToCandidate(content);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error calling OpenAI API");
            throw new InvalidOperationException("Failed to parse CV with OpenAI", ex);
        }
    }
}