namespace CVAnalyzer.Api.Models;

public class Candidate
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
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    
    // Navigation properties
    public ICollection<WorkExperience> WorkExperiences { get; set; } = new List<WorkExperience>();
    public ICollection<Education> Educations { get; set; } = new List<Education>();
    public ICollection<Skill> Skills { get; set; } = new List<Skill>();
    public ICollection<CvFile> CvFiles { get; set; } = new List<CvFile>();
}

public class WorkExperience
{
    public int Id { get; set; }
    public int CandidateId { get; set; }
    public string JobTitle { get; set; } = string.Empty;
    public string Company { get; set; } = string.Empty;
    public string? Location { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public bool IsCurrent { get; set; }
    public string? Description { get; set; }
    
    public Candidate Candidate { get; set; } = null!;
}

public class Education
{
    public int Id { get; set; }
    public int CandidateId { get; set; }
    public string Degree { get; set; } = string.Empty;
    public string Institution { get; set; } = string.Empty;
    public string? FieldOfStudy { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public string? Grade { get; set; }
    
    public Candidate Candidate { get; set; } = null!;
}

public class Skill
{
    public int Id { get; set; }
    public int CandidateId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Category { get; set; }
    public string? ProficiencyLevel { get; set; }
    
    public Candidate Candidate { get; set; } = null!;
}

public class CvFile
{
    public int Id { get; set; }
    public int CandidateId { get; set; }
    public string FileName { get; set; } = string.Empty;
    public string FilePath { get; set; } = string.Empty;
    public string FileType { get; set; } = string.Empty;
    public long FileSize { get; set; }
    public string? RawText { get; set; }
    public DateTime UploadedAt { get; set; } = DateTime.UtcNow;
    
    public Candidate Candidate { get; set; } = null!;
}
