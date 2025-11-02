namespace CVAnalyzer.Api.Services;

public interface ICvProcessingService
{
    Task<string> ExtractTextFromFileAsync(IFormFile file);
    bool IsSupportedFileType(string fileName);
}
