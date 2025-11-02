using CVAnalyzer.Api.Data;
using CVAnalyzer.Api.Services;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Database
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Services
builder.Services.AddScoped<ICvProcessingService, CvProcessingService>();
builder.Services.AddScoped<ICandidateService, CandidateService>();

// LLM Services
builder.Services.AddScoped<OpenAIService>();
builder.Services.AddScoped<GeminiService>();
builder.Services.AddScoped<LlmServiceFactory>();
builder.Services.AddScoped<ILlmService>(provider =>
{
    var factory = provider.GetRequiredService<LlmServiceFactory>();
    return factory.CreateLlmService();
});

builder.Services.AddHttpClient<GeminiService>();

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend", policy =>
    {
        policy.WithOrigins("http://localhost:3000", "http://localhost:5173", "http://localhost", "http://localhost:80", "http://localhost:5050")
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowFrontend");
app.UseAuthorization();
app.MapControllers();

app.Run();
