using Microsoft.EntityFrameworkCore;
using CVAnalyzer.Api.Models;

namespace CVAnalyzer.Api.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    public DbSet<Candidate> Candidates { get; set; }
    public DbSet<WorkExperience> WorkExperiences { get; set; }
    public DbSet<Education> Educations { get; set; }
    public DbSet<Skill> Skills { get; set; }
    public DbSet<CvFile> CvFiles { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Candidate>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.FullName).IsRequired().HasMaxLength(200);
            entity.Property(e => e.Email).IsRequired().HasMaxLength(200);
            entity.HasIndex(e => e.Email);
            entity.Property(e => e.Phone).HasMaxLength(50);
            entity.Property(e => e.Address).HasMaxLength(500);
            entity.Property(e => e.LinkedIn).HasMaxLength(500);
            entity.Property(e => e.GitHub).HasMaxLength(500);
            entity.Property(e => e.Portfolio).HasMaxLength(500);
            entity.Property(e => e.CurrentPosition).HasMaxLength(200);
            entity.Property(e => e.CurrentCompany).HasMaxLength(200);
        });

        modelBuilder.Entity<WorkExperience>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasOne(e => e.Candidate)
                  .WithMany(c => c.WorkExperiences)
                  .HasForeignKey(e => e.CandidateId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Education>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasOne(e => e.Candidate)
                  .WithMany(c => c.Educations)
                  .HasForeignKey(e => e.CandidateId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<Skill>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasOne(e => e.Candidate)
                  .WithMany(c => c.Skills)
                  .HasForeignKey(e => e.CandidateId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<CvFile>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.HasOne(e => e.Candidate)
                  .WithMany(c => c.CvFiles)
                  .HasForeignKey(e => e.CandidateId)
                  .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
