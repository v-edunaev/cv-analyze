using CVAnalyzer.Api.DTOs;
using CVAnalyzer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace CVAnalyzer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CvUploadController : ControllerBase
{
    private readonly ICvProcessingService _cvProcessingService;
    private readonly ILlmService _llmService;
    private readonly ICandidateService _candidateService;
    private readonly ILogger<CvUploadController> _logger;
    private readonly IWebHostEnvironment _environment;

    public CvUploadController(
        ICvProcessingService cvProcessingService,
        ILlmService llmService,
        ICandidateService candidateService,
        ILogger<CvUploadController> logger,
        IWebHostEnvironment environment)
    {
        _cvProcessingService = cvProcessingService;
        _llmService = llmService;
        _candidateService = candidateService;
        _logger = logger;
        _environment = environment;
    }

    [HttpPost("upload")]
    public async Task<ActionResult<UploadCvResponse>> UploadCv([FromForm] IFormFile file)
    {
        try
        {
            // Validate file
            if (file == null || file.Length == 0)
            {
                return BadRequest(new UploadCvResponse
                {
                    Success = false,
                    Message = "No file uploaded"
                });
            }

            if (!_cvProcessingService.IsSupportedFileType(file.FileName))
            {
                return BadRequest(new UploadCvResponse
                {
                    Success = false,
                    Message = "Unsupported file type. Please upload PDF, DOCX, DOC, or TXT files."
                });
            }

            // Extract text from CV
            _logger.LogInformation("Extracting text from file: {FileName}", file.FileName);
            var cvText = await _cvProcessingService.ExtractTextFromFileAsync(file);

            if (string.IsNullOrWhiteSpace(cvText))
            {
                return BadRequest(new UploadCvResponse
                {
                    Success = false,
                    Message = "Could not extract text from the uploaded file"
                });
            }

            // Parse CV using LLM
            _logger.LogInformation("Parsing CV with LLM");
            var candidateData = await _llmService.ParseCvTextAsync(cvText);

            // Save the file
            var uploadsFolder = Path.Combine(_environment.ContentRootPath, "uploads");
            Directory.CreateDirectory(uploadsFolder);
            
            var uniqueFileName = $"{Guid.NewGuid()}_{file.FileName}";
            var filePath = Path.Combine(uploadsFolder, uniqueFileName);
            
            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            return Ok(new UploadCvResponse
            {
                Success = true,
                Message = "CV processed successfully",
                Candidate = candidateData,
                RawText = cvText
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error uploading CV");
            return StatusCode(500, new UploadCvResponse
            {
                Success = false,
                Message = $"An error occurred while processing the CV: {ex.Message}"
            });
        }
    }

    [HttpPost("confirm")]
    public async Task<ActionResult<CandidateDto>> ConfirmCandidate([FromBody] ConfirmCandidateRequest request)
    {
        try
        {
            var candidate = await _candidateService.CreateCandidateAsync(request.Candidate);
            return Ok(candidate);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error confirming candidate");
            return StatusCode(500, new { message = "An error occurred while saving the candidate" });
        }
    }
}
