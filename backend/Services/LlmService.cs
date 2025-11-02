using System.Text;
using System.Text.Json;
using CVAnalyzer.Api.DTOs;

namespace CVAnalyzer.Api.Services;

public class LlmService : ILlmService
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;
    private readonly ILogger<LlmService> _logger;

    public LlmService(HttpClient httpClient, IConfiguration configuration, ILogger<LlmService> logger)
    {
        _httpClient = httpClient;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<CandidateDto> ParseCvTextAsync(string cvText)
    {
        var provider = _configuration["LLM:Provider"];

        return provider?.ToLower() switch
        {
            "openai" => await ParseWithOpenAIAsync(cvText),
            "gemini" => await ParseWithGeminiAsync(cvText),
            _ => await ParseWithOpenAIAsync(cvText) // Default to OpenAI
        };
    }

    private async Task<CandidateDto> ParseWithOpenAIAsync(string cvText)
    {
        var apiKey = _configuration["LLM:OpenAI:ApiKey"];
        var model = _configuration["LLM:OpenAI:Model"] ?? "gpt-4o-mini";

        if (string.IsNullOrEmpty(apiKey))
        {
            throw new InvalidOperationException("OpenAI API key is not configured");
        }

        var prompt = GetExtractionPrompt(cvText);

        var requestBody = new
        {
            model = model,
            messages = new[]
            {
                new { role = "system", content = "You are a CV/Resume parser. Extract structured information from resumes and return it in JSON format." },
                new { role = "user", content = prompt }
            },
            temperature = 0.3,
            response_format = new { type = "json_object" }
        };

        _httpClient.DefaultRequestHeaders.Clear();
        _httpClient.DefaultRequestHeaders.Add("Authorization", $"Bearer {apiKey}");

        var response = await _httpClient.PostAsJsonAsync("https://api.openai.com/v1/chat/completions", requestBody);
        response.EnsureSuccessStatusCode();

        var result = await response.Content.ReadFromJsonAsync<OpenAIResponse>();
        var content = result?.Choices?[0]?.Message?.Content ?? "{}";

        return ParseJsonToCandidate(content);
    }

    private async Task<CandidateDto> ParseWithGeminiAsync(string cvText)
    {
        var apiKey = _configuration["LLM:Gemini:ApiKey"];
        var model = _configuration["LLM:Gemini:Model"] ?? "gemini-1.5-flash";

        if (string.IsNullOrEmpty(apiKey))
        {
            throw new InvalidOperationException("Gemini API key is not configured");
        }

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

        var url = $"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={apiKey}";
        
        var response = await _httpClient.PostAsJsonAsync(url, requestBody);
        response.EnsureSuccessStatusCode();

        var result = await response.Content.ReadFromJsonAsync<GeminiResponse>();
        var content = result?.Candidates?[0]?.Content?.Parts?[0]?.Text ?? "{}";

        return ParseJsonToCandidate(content);
    }

    private string GetExtractionPrompt(string cvText)
    {
        return $@"Extract the following information from this CV/Resume and return it as a JSON object:

CV Text:
{cvText}

Return a JSON object with this exact structure:
{{
  ""fullName"": ""string"",
  ""email"": ""string"",
  ""phone"": ""string or null"",
  ""address"": ""string or null"",
  ""linkedin"": ""string or null (full URL)"",
  ""github"": ""string or null (full URL)"",
  ""portfolio"": ""string or null (full URL)"",
  ""summary"": ""string or null (professional summary/objective)"",
  ""yearsOfExperience"": number or null,
  ""currentPosition"": ""string or null"",
  ""currentCompany"": ""string or null"",
  ""workExperiences"": [
    {{
      ""jobTitle"": ""string"",
      ""company"": ""string"",
      ""location"": ""string or null"",
      ""startDate"": ""YYYY-MM-DD"",
      ""endDate"": ""YYYY-MM-DD or null"",
      ""isCurrent"": boolean,
      ""description"": ""string or null""
    }}
  ],
  ""educations"": [
    {{
      ""degree"": ""string"",
      ""institution"": ""string"",
      ""fieldOfStudy"": ""string or null"",
      ""startDate"": ""YYYY-MM-DD or null"",
      ""endDate"": ""YYYY-MM-DD or null"",
      ""grade"": ""string or null""
    }}
  ],
  ""skills"": [
    {{
      ""name"": ""string"",
      ""category"": ""string or null (e.g., Programming, Tools, Soft Skills)"",
      ""proficiencyLevel"": ""string or null (e.g., Beginner, Intermediate, Expert)""
    }}
  ]
}}

Important:
- Extract all available information
- If information is not available, use null
- For dates, use ISO format (YYYY-MM-DD). If only year or month-year is available, use YYYY-01-01 or YYYY-MM-01
- Calculate yearsOfExperience based on work history if not explicitly stated
- Return ONLY the JSON object, no additional text";
    }

    private CandidateDto ParseJsonToCandidate(string jsonContent)
    {
        try
        {
            var options = new JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            };

            var candidate = JsonSerializer.Deserialize<CandidateDto>(jsonContent, options);
            return candidate ?? new CandidateDto();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error parsing JSON response: {Json}", jsonContent);
            throw new InvalidOperationException("Failed to parse LLM response", ex);
        }
    }

    // Response models for API calls
    private class OpenAIResponse
    {
        public Choice[]? Choices { get; set; }
    }

    private class Choice
    {
        public Message? Message { get; set; }
    }

    private class Message
    {
        public string? Content { get; set; }
    }

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
