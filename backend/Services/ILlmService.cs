using CVAnalyzer.Api.DTOs;

namespace CVAnalyzer.Api.Services;

public interface ILlmService
{
    Task<CandidateDto> ParseCvTextAsync(string cvText);
}

public abstract class LlmServiceBase : ILlmService
{
    protected readonly ILogger _logger;

    protected LlmServiceBase(ILogger logger)
    {
        _logger = logger;
    }

    public abstract Task<CandidateDto> ParseCvTextAsync(string cvText);

    protected string GetExtractionPrompt(string cvText)
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

    protected CandidateDto ParseJsonToCandidate(string jsonContent)
    {
        try
        {
            var options = new System.Text.Json.JsonSerializerOptions
            {
                PropertyNameCaseInsensitive = true
            };

            var candidate = System.Text.Json.JsonSerializer.Deserialize<CandidateDto>(jsonContent, options);
            return candidate ?? new CandidateDto();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error parsing JSON response: {Json}", jsonContent);
            throw new InvalidOperationException("Failed to parse LLM response", ex);
        }
    }
}
