using CVAnalyzer.Api.Data;
using CVAnalyzer.Api.DTOs;
using CVAnalyzer.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace CVAnalyzer.Api.Services;

public class CandidateService : ICandidateService
{
    private readonly ApplicationDbContext _context;
    private readonly ILogger<CandidateService> _logger;

    public CandidateService(ApplicationDbContext context, ILogger<CandidateService> logger)
    {
        _context = context;
        _logger = logger;
    }

    public async Task<CandidateDto> CreateCandidateAsync(CandidateDto candidateDto, string? fileName = null, string? filePath = null, string? rawText = null)
    {
        var candidate = new Candidate
        {
            FullName = candidateDto.FullName,
            Email = candidateDto.Email,
            Phone = candidateDto.Phone,
            Address = candidateDto.Address,
            LinkedIn = candidateDto.LinkedIn,
            GitHub = candidateDto.GitHub,
            Portfolio = candidateDto.Portfolio,
            Summary = candidateDto.Summary,
            YearsOfExperience = candidateDto.YearsOfExperience,
            CurrentPosition = candidateDto.CurrentPosition,
            CurrentCompany = candidateDto.CurrentCompany,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        // Add work experiences
        foreach (var we in candidateDto.WorkExperiences)
        {
            candidate.WorkExperiences.Add(new WorkExperience
            {
                JobTitle = we.JobTitle,
                Company = we.Company,
                Location = we.Location,
                StartDate = we.StartDate,
                EndDate = we.EndDate,
                IsCurrent = we.IsCurrent,
                Description = we.Description
            });
        }

        // Add educations
        foreach (var edu in candidateDto.Educations)
        {
            candidate.Educations.Add(new Education
            {
                Degree = edu.Degree,
                Institution = edu.Institution,
                FieldOfStudy = edu.FieldOfStudy,
                StartDate = edu.StartDate,
                EndDate = edu.EndDate,
                Grade = edu.Grade
            });
        }

        // Add skills
        foreach (var skill in candidateDto.Skills)
        {
            candidate.Skills.Add(new Skill
            {
                Name = skill.Name,
                Category = skill.Category,
                ProficiencyLevel = skill.ProficiencyLevel
            });
        }

        // Add CV file if provided
        if (!string.IsNullOrEmpty(fileName) && !string.IsNullOrEmpty(filePath))
        {
            candidate.CvFiles.Add(new CvFile
            {
                FileName = fileName,
                FilePath = filePath,
                FileType = Path.GetExtension(fileName),
                FileSize = 0, // Would need to be calculated from actual file
                RawText = rawText,
                UploadedAt = DateTime.UtcNow
            });
        }

        _context.Candidates.Add(candidate);
        await _context.SaveChangesAsync();

        return await GetCandidateByIdAsync(candidate.Id) ?? candidateDto;
    }

    public async Task<CandidateDto?> GetCandidateByIdAsync(int id)
    {
        var candidate = await _context.Candidates
            .Include(c => c.WorkExperiences)
            .Include(c => c.Educations)
            .Include(c => c.Skills)
            .FirstOrDefaultAsync(c => c.Id == id);

        if (candidate == null)
            return null;

        return MapToDto(candidate);
    }

    public async Task<CandidateListResponse> GetCandidatesAsync(int page = 1, int pageSize = 10, string? search = null, string? sortBy = null, bool sortDescending = false)
    {
        var query = _context.Candidates
            .Include(c => c.WorkExperiences)
            .Include(c => c.Educations)
            .Include(c => c.Skills)
            .AsQueryable();

        // Search filter
        if (!string.IsNullOrWhiteSpace(search))
        {
            search = search.ToLower();
            query = query.Where(c =>
                c.FullName.ToLower().Contains(search) ||
                c.Email.ToLower().Contains(search) ||
                (c.CurrentPosition != null && c.CurrentPosition.ToLower().Contains(search)) ||
                (c.CurrentCompany != null && c.CurrentCompany.ToLower().Contains(search)) ||
                c.Skills.Any(s => s.Name.ToLower().Contains(search))
            );
        }

        // Sorting
        query = (sortBy?.ToLower(), sortDescending) switch
        {
            ("name", false) => query.OrderBy(c => c.FullName),
            ("name", true) => query.OrderByDescending(c => c.FullName),
            ("email", false) => query.OrderBy(c => c.Email),
            ("email", true) => query.OrderByDescending(c => c.Email),
            ("experience", false) => query.OrderBy(c => c.YearsOfExperience ?? 0),
            ("experience", true) => query.OrderByDescending(c => c.YearsOfExperience ?? 0),
            ("createdat", false) => query.OrderBy(c => c.CreatedAt),
            ("createdat", true) => query.OrderByDescending(c => c.CreatedAt),
            _ => query.OrderByDescending(c => c.CreatedAt) // Default sort
        };

        var totalCount = await query.CountAsync();

        var candidates = await query
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return new CandidateListResponse
        {
            Candidates = candidates.Select(MapToDto).ToList(),
            TotalCount = totalCount,
            Page = page,
            PageSize = pageSize
        };
    }

    public async Task<CandidateDto> UpdateCandidateAsync(int id, CandidateDto candidateDto)
    {
        var candidate = await _context.Candidates
            .Include(c => c.WorkExperiences)
            .Include(c => c.Educations)
            .Include(c => c.Skills)
            .FirstOrDefaultAsync(c => c.Id == id);

        if (candidate == null)
            throw new KeyNotFoundException($"Candidate with ID {id} not found");

        // Update basic info
        candidate.FullName = candidateDto.FullName;
        candidate.Email = candidateDto.Email;
        candidate.Phone = candidateDto.Phone;
        candidate.Address = candidateDto.Address;
        candidate.LinkedIn = candidateDto.LinkedIn;
        candidate.GitHub = candidateDto.GitHub;
        candidate.Portfolio = candidateDto.Portfolio;
        candidate.Summary = candidateDto.Summary;
        candidate.YearsOfExperience = candidateDto.YearsOfExperience;
        candidate.CurrentPosition = candidateDto.CurrentPosition;
        candidate.CurrentCompany = candidateDto.CurrentCompany;
        candidate.UpdatedAt = DateTime.UtcNow;

        // Update work experiences
        _context.WorkExperiences.RemoveRange(candidate.WorkExperiences);
        foreach (var we in candidateDto.WorkExperiences)
        {
            candidate.WorkExperiences.Add(new WorkExperience
            {
                JobTitle = we.JobTitle,
                Company = we.Company,
                Location = we.Location,
                StartDate = we.StartDate,
                EndDate = we.EndDate,
                IsCurrent = we.IsCurrent,
                Description = we.Description
            });
        }

        // Update educations
        _context.Educations.RemoveRange(candidate.Educations);
        foreach (var edu in candidateDto.Educations)
        {
            candidate.Educations.Add(new Education
            {
                Degree = edu.Degree,
                Institution = edu.Institution,
                FieldOfStudy = edu.FieldOfStudy,
                StartDate = edu.StartDate,
                EndDate = edu.EndDate,
                Grade = edu.Grade
            });
        }

        // Update skills
        _context.Skills.RemoveRange(candidate.Skills);
        foreach (var skill in candidateDto.Skills)
        {
            candidate.Skills.Add(new Skill
            {
                Name = skill.Name,
                Category = skill.Category,
                ProficiencyLevel = skill.ProficiencyLevel
            });
        }

        await _context.SaveChangesAsync();

        return MapToDto(candidate);
    }

    public async Task<bool> DeleteCandidateAsync(int id)
    {
        var candidate = await _context.Candidates.FindAsync(id);
        if (candidate == null)
            return false;

        _context.Candidates.Remove(candidate);
        await _context.SaveChangesAsync();
        return true;
    }

    private static CandidateDto MapToDto(Candidate candidate)
    {
        return new CandidateDto
        {
            Id = candidate.Id,
            FullName = candidate.FullName,
            Email = candidate.Email,
            Phone = candidate.Phone,
            Address = candidate.Address,
            LinkedIn = candidate.LinkedIn,
            GitHub = candidate.GitHub,
            Portfolio = candidate.Portfolio,
            Summary = candidate.Summary,
            YearsOfExperience = candidate.YearsOfExperience,
            CurrentPosition = candidate.CurrentPosition,
            CurrentCompany = candidate.CurrentCompany,
            CreatedAt = candidate.CreatedAt,
            UpdatedAt = candidate.UpdatedAt,
            WorkExperiences = candidate.WorkExperiences.Select(we => new WorkExperienceDto
            {
                Id = we.Id,
                JobTitle = we.JobTitle,
                Company = we.Company,
                Location = we.Location,
                StartDate = we.StartDate,
                EndDate = we.EndDate,
                IsCurrent = we.IsCurrent,
                Description = we.Description
            }).ToList(),
            Educations = candidate.Educations.Select(edu => new EducationDto
            {
                Id = edu.Id,
                Degree = edu.Degree,
                Institution = edu.Institution,
                FieldOfStudy = edu.FieldOfStudy,
                StartDate = edu.StartDate,
                EndDate = edu.EndDate,
                Grade = edu.Grade
            }).ToList(),
            Skills = candidate.Skills.Select(skill => new SkillDto
            {
                Id = skill.Id,
                Name = skill.Name,
                Category = skill.Category,
                ProficiencyLevel = skill.ProficiencyLevel
            }).ToList()
        };
    }
}
