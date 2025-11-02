namespace CVAnalyzer.Api.DTOs;

public class CandidateDto
{
    public int Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? Address { get; set; }
    public string? LinkedIn { get; set; }
    public string? GitHub { get; set; }
    public string? Portfolio { get; set; }
    public string? Summary { get; set; }
    public int? YearsOfExperience { get; set; }
    public string? CurrentPosition { get; set; }
    public string? CurrentCompany { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    
    public List<WorkExperienceDto> WorkExperiences { get; set; } = new();
    public List<EducationDto> Educations { get; set; } = new();
    public List<SkillDto> Skills { get; set; } = new();
}

public class WorkExperienceDto
{
    public int Id { get; set; }
    public string JobTitle { get; set; } = string.Empty;
    public string Company { get; set; } = string.Empty;
    public string? Location { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public bool IsCurrent { get; set; }
    public string? Description { get; set; }
}

public class EducationDto
{
    public int Id { get; set; }
    public string Degree { get; set; } = string.Empty;
    public string Institution { get; set; } = string.Empty;
    public string? FieldOfStudy { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public string? Grade { get; set; }
}

public class SkillDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Category { get; set; }
    public string? ProficiencyLevel { get; set; }
}

public class UploadCvRequest
{
    public IFormFile File { get; set; } = null!;
}

public class UploadCvResponse
{
    public bool Success { get; set; }
    public string? Message { get; set; }
    public CandidateDto? Candidate { get; set; }
    public string? RawText { get; set; }
}

public class ConfirmCandidateRequest
{
    public CandidateDto Candidate { get; set; } = null!;
}

public class CandidateListResponse
{
    public List<CandidateDto> Candidates { get; set; } = new();
    public int TotalCount { get; set; }
    public int Page { get; set; }
    public int PageSize { get; set; }
}
