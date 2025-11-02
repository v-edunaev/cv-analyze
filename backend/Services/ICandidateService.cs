using CVAnalyzer.Api.DTOs;
using CVAnalyzer.Api.Models;

namespace CVAnalyzer.Api.Services;

public interface ICandidateService
{
    Task<CandidateDto> CreateCandidateAsync(CandidateDto candidateDto, string? fileName = null, string? filePath = null, string? rawText = null);
    Task<CandidateDto?> GetCandidateByIdAsync(int id);
    Task<CandidateListResponse> GetCandidatesAsync(int page = 1, int pageSize = 10, string? search = null, string? sortBy = null, bool sortDescending = false);
    Task<CandidateDto> UpdateCandidateAsync(int id, CandidateDto candidateDto);
    Task<bool> DeleteCandidateAsync(int id);
}
