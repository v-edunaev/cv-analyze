using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CVAnalyzer.Api.Data;
using CVAnalyzer.Api.DTOs;
using CVAnalyzer.Api.Models;
using CVAnalyzer.Api.Services;
using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;

namespace CVAnalyzer.Tests.Services;

public class CandidateServiceTests
{
    private ApplicationDbContext CreateInMemoryContext()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: System.Guid.NewGuid().ToString())
            .Options;

        return new ApplicationDbContext(options);
    }

    [Fact]
    public async Task CreateCandidateAsync_WithValidData_ShouldCreateCandidate()
    {
        // Arrange
        using var context = CreateInMemoryContext();
        var loggerMock = new Mock<ILogger<CandidateService>>();
        var service = new CandidateService(context, loggerMock.Object);

        var dto = new CandidateDto
        {
            FullName = "John Smith",
            Email = "john.smith@email.com",
            Phone = "+1 (555) 123-4567",
            Summary = "Experienced software engineer",
            YearsOfExperience = 8,
            WorkExperiences = new List<WorkExperienceDto>
            {
                new WorkExperienceDto
                {
                    JobTitle = "Senior Software Engineer",
                    Company = "Tech Solutions Inc.",
                    StartDate = new System.DateTime(2020, 1, 1),
                    EndDate = null,
                    Description = "Led development teams"
                }
            },
            Educations = new List<EducationDto>
            {
                new EducationDto
                {
                    Degree = "Bachelor of Science",
                    Institution = "Stanford University",
                    FieldOfStudy = "Computer Science"
                }
            },
            Skills = new List<SkillDto>
            {
                new SkillDto { Name = "C#", ProficiencyLevel = "Expert" },
                new SkillDto { Name = "React", ProficiencyLevel = "Advanced" }
            }
        };

        // Act
        var result = await service.CreateCandidateAsync(dto, "sample.txt", null, "raw cv text");

        // Assert
        result.Should().NotBeNull();
        result.FullName.Should().Be("John Smith");
        result.WorkExperiences.Should().HaveCount(1);
        result.Educations.Should().HaveCount(1);
        result.Skills.Should().HaveCount(2);

        var savedCandidate = await context.Candidates
            .Include(c => c.WorkExperiences)
            .Include(c => c.Educations)
            .Include(c => c.Skills)
            .FirstOrDefaultAsync(c => c.Id == result.Id);

        savedCandidate.Should().NotBeNull();
    }

    [Fact]
    public async Task GetCandidatesAsync_WithPagination_ShouldReturnPagedResults()
    {
        // Arrange
        using var context = CreateInMemoryContext();
        var loggerMock = new Mock<ILogger<CandidateService>>();
        var service = new CandidateService(context, loggerMock.Object);

        // Add test candidates
        for (int i = 1; i <= 15; i++)
        {
            context.Candidates.Add(new Candidate
            {
                FullName = $"Test Candidate {i}",
                Email = $"test{i}@email.com",
                CreatedAt = System.DateTime.UtcNow.AddDays(-i)
            });
        }
        await context.SaveChangesAsync();

        // Act
        var result = await service.GetCandidatesAsync(page: 1, pageSize: 10);

        // Assert
        result.Candidates.Should().HaveCount(10);
        result.TotalCount.Should().Be(15);
        result.Page.Should().Be(1);
        result.PageSize.Should().Be(10);
    }

    [Fact]
    public async Task GetCandidatesAsync_WithSearch_ShouldFilterResults()
    {
        // Arrange
        using var context = CreateInMemoryContext();
        var loggerMock = new Mock<ILogger<CandidateService>>();
        var service = new CandidateService(context, loggerMock.Object);

        context.Candidates.Add(new Candidate
        {
            FullName = "John Smith",
            Email = "john@email.com",
            Skills = new List<Skill>
            {
                new Skill { Name = "C#" },
                new Skill { Name = "React" }
            }
        });

        context.Candidates.Add(new Candidate
        {
            FullName = "Jane Doe",
            Email = "jane@email.com",
            Skills = new List<Skill>
            {
                new Skill { Name = "Python" },
                new Skill { Name = "Django" }
            }
        });

        await context.SaveChangesAsync();

        // Act
        var result = await service.GetCandidatesAsync(search: "John");

        // Assert
        result.Candidates.Should().HaveCount(1);
        result.Candidates.First().FullName.Should().Be("John Smith");
    }

    [Fact]
    public async Task GetCandidatesAsync_WithSorting_ShouldSortResults()
    {
        // Arrange
        using var context = CreateInMemoryContext();
        var loggerMock = new Mock<ILogger<CandidateService>>();
        var service = new CandidateService(context, loggerMock.Object);

        context.Candidates.Add(new Candidate
        {
            FullName = "Alice",
            Email = "alice@email.com",
            YearsOfExperience = 5
        });

        context.Candidates.Add(new Candidate
        {
            FullName = "Bob",
            Email = "bob@email.com",
            YearsOfExperience = 10
        });

        context.Candidates.Add(new Candidate
        {
            FullName = "Charlie",
            Email = "charlie@email.com",
            YearsOfExperience = 3
        });

        await context.SaveChangesAsync();

        // Act
        var result = await service.GetCandidatesAsync(sortBy: "experience", sortDescending: true);

        // Assert
        result.Candidates.Should().HaveCount(3);
        result.Candidates.First().FullName.Should().Be("Bob");
        result.Candidates.Last().FullName.Should().Be("Charlie");
    }

    [Fact]
    public async Task GetCandidateByIdAsync_WithExistingId_ShouldReturnCandidate()
    {
        // Arrange
        using var context = CreateInMemoryContext();
        var loggerMock = new Mock<ILogger<CandidateService>>();
        var service = new CandidateService(context, loggerMock.Object);

        var candidate = new Candidate
        {
            FullName = "John Smith",
            Email = "john@email.com"
        };
        context.Candidates.Add(candidate);
        await context.SaveChangesAsync();

        // Act
        var result = await service.GetCandidateByIdAsync(candidate.Id);

        // Assert
        result.Should().NotBeNull();
        result!.FullName.Should().Be("John Smith");
    }

    [Fact]
    public async Task GetCandidateByIdAsync_WithNonExistingId_ShouldReturnNull()
    {
        // Arrange
        using var context = CreateInMemoryContext();
        var loggerMock = new Mock<ILogger<CandidateService>>();
        var service = new CandidateService(context, loggerMock.Object);

        // Act
        var result = await service.GetCandidateByIdAsync(999);

        // Assert
        result.Should().BeNull();
    }

    [Fact]
    public async Task UpdateCandidateAsync_WithValidData_ShouldUpdateCandidate()
    {
        // Arrange
        using var context = CreateInMemoryContext();
        var loggerMock = new Mock<ILogger<CandidateService>>();
        var service = new CandidateService(context, loggerMock.Object);

        var candidate = new Candidate
        {
            FullName = "John Smith",
            Email = "john@email.com",
            YearsOfExperience = 5
        };
        context.Candidates.Add(candidate);
        await context.SaveChangesAsync();

        var updateDto = new CandidateDto
        {
            Id = candidate.Id,
            FullName = "John Smith Jr.",
            Email = "john.jr@email.com",
            YearsOfExperience = 8
        };

        // Act
        var result = await service.UpdateCandidateAsync(candidate.Id, updateDto);

        // Assert
        result.Should().NotBeNull();
        result!.FullName.Should().Be("John Smith Jr.");
        result.YearsOfExperience.Should().Be(8);
    }

    [Fact]
    public async Task DeleteCandidateAsync_WithExistingId_ShouldDeleteCandidate()
    {
        // Arrange
        using var context = CreateInMemoryContext();
        var loggerMock = new Mock<ILogger<CandidateService>>();
        var service = new CandidateService(context, loggerMock.Object);

        var candidate = new Candidate
        {
            FullName = "John Smith",
            Email = "john@email.com"
        };
        context.Candidates.Add(candidate);
        await context.SaveChangesAsync();

        // Act
        var result = await service.DeleteCandidateAsync(candidate.Id);

        // Assert
        result.Should().BeTrue();
        var deletedCandidate = await context.Candidates.FindAsync(candidate.Id);
        deletedCandidate.Should().BeNull();
    }

    [Fact]
    public async Task DeleteCandidateAsync_WithNonExistingId_ShouldReturnFalse()
    {
        // Arrange
        using var context = CreateInMemoryContext();
        var loggerMock = new Mock<ILogger<CandidateService>>();
        var service = new CandidateService(context, loggerMock.Object);

        // Act
        var result = await service.DeleteCandidateAsync(999);

        // Assert
        result.Should().BeFalse();
    }
}
