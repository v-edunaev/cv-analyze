using CVAnalyzer.Api.DTOs;

namespace CVAnalyzer.Api.Services;

public interface ILlmService
{
    Task<CandidateDto> ParseCvTextAsync(string cvText);
}
