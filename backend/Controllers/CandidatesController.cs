using CVAnalyzer.Api.DTOs;
using CVAnalyzer.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace CVAnalyzer.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CandidatesController : ControllerBase
{
    private readonly ICandidateService _candidateService;
    private readonly ILogger<CandidatesController> _logger;

    public CandidatesController(ICandidateService candidateService, ILogger<CandidatesController> logger)
    {
        _candidateService = candidateService;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<CandidateListResponse>> GetCandidates(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 10,
        [FromQuery] string? search = null,
        [FromQuery] string? sortBy = null,
        [FromQuery] bool sortDescending = false)
    {
        try
        {
            var result = await _candidateService.GetCandidatesAsync(page, pageSize, search, sortBy, sortDescending);
            return Ok(result);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting candidates");
            return StatusCode(500, new { message = "An error occurred while retrieving candidates" });
        }
    }

    [HttpGet("{id}")]
    public async Task<ActionResult<CandidateDto>> GetCandidate(int id)
    {
        try
        {
            var candidate = await _candidateService.GetCandidateByIdAsync(id);
            if (candidate == null)
                return NotFound(new { message = $"Candidate with ID {id} not found" });

            return Ok(candidate);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error getting candidate {Id}", id);
            return StatusCode(500, new { message = "An error occurred while retrieving the candidate" });
        }
    }

    [HttpPost]
    public async Task<ActionResult<CandidateDto>> CreateCandidate([FromBody] ConfirmCandidateRequest request)
    {
        try
        {
            var candidate = await _candidateService.CreateCandidateAsync(request.Candidate);
            return CreatedAtAction(nameof(GetCandidate), new { id = candidate.Id }, candidate);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error creating candidate");
            return StatusCode(500, new { message = "An error occurred while creating the candidate" });
        }
    }

    [HttpPut("{id}")]
    public async Task<ActionResult<CandidateDto>> UpdateCandidate(int id, [FromBody] CandidateDto candidateDto)
    {
        try
        {
            var candidate = await _candidateService.UpdateCandidateAsync(id, candidateDto);
            return Ok(candidate);
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { message = $"Candidate with ID {id} not found" });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error updating candidate {Id}", id);
            return StatusCode(500, new { message = "An error occurred while updating the candidate" });
        }
    }

    [HttpDelete("{id}")]
    public async Task<ActionResult> DeleteCandidate(int id)
    {
        try
        {
            var result = await _candidateService.DeleteCandidateAsync(id);
            if (!result)
                return NotFound(new { message = $"Candidate with ID {id} not found" });

            return NoContent();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error deleting candidate {Id}", id);
            return StatusCode(500, new { message = "An error occurred while deleting the candidate" });
        }
    }
}
