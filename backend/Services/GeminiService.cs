using System.Text.Json;
using CVAnalyzer.Api.DTOs;

namespace CVAnalyzer.Api.Services;

public class GeminiService : LlmServiceBase
{
    private readonly HttpClient _httpClient;
    private readonly string _apiKey;
    private readonly string _model;

    public GeminiService(HttpClient httpClient, IConfiguration configuration, ILogger<GeminiService> logger) : base(logger)
    {
        _httpClient = httpClient;
        _apiKey = configuration["LLM:Gemini:ApiKey"] ?? throw new InvalidOperationException("Gemini API key is not configured");
        _model = configuration["LLM:Gemini:Model"] ?? "gemini-1.5-flash";
    }

    public override async Task<CandidateDto> ParseCvTextAsync(string cvText)
    {
        var prompt = GetExtractionPrompt(cvText);

        var requestBody = new
        {
            contents = new[]
            {
                new
                {
                    parts = new[]
                    {
                        new { text = prompt }
                    }
                }
            },
            generationConfig = new
            {
                temperature = 0.3,
                response_mime_type = "application/json"
            }
        };

        var url = $"https://generativelanguage.googleapis.com/v1beta/models/{_model}:generateContent?key={_apiKey}";

        try
        {
            var response = await _httpClient.PostAsJsonAsync(url, requestBody);
            response.EnsureSuccessStatusCode();

            var result = await response.Content.ReadFromJsonAsync<GeminiResponse>();
            var content = result?.Candidates?[0]?.Content?.Parts?[0]?.Text ?? "{}";

            _logger.LogDebug("Gemini response: {Content}", content);

            return ParseJsonToCandidate(content);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error calling Gemini API");
            throw new InvalidOperationException("Failed to parse CV with Gemini", ex);
        }
    }

    // Response models for Gemini API
    private class GeminiResponse
    {
        public GeminiCandidate[]? Candidates { get; set; }
    }

    private class GeminiCandidate
    {
        public GeminiContent? Content { get; set; }
    }

    private class GeminiContent
    {
        public GeminiPart[]? Parts { get; set; }
    }

    private class GeminiPart
    {
        public string? Text { get; set; }
    }
}