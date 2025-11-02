using System.Text;
using DocumentFormat.OpenXml.Packaging;
using UglyToad.PdfPig;

namespace CVAnalyzer.Api.Services;

public class CvProcessingService : ICvProcessingService
{
    private readonly ILogger<CvProcessingService> _logger;
    private static readonly string[] SupportedExtensions = { ".pdf", ".docx", ".doc", ".txt" };

    public CvProcessingService(ILogger<CvProcessingService> logger)
    {
        _logger = logger;
    }

    public bool IsSupportedFileType(string fileName)
    {
        var extension = System.IO.Path.GetExtension(fileName).ToLowerInvariant();
        return SupportedExtensions.Contains(extension);
    }

    public async Task<string> ExtractTextFromFileAsync(IFormFile file)
    {
        var extension = System.IO.Path.GetExtension(file.FileName).ToLowerInvariant();

        try
        {
            return extension switch
            {
                ".pdf" => await ExtractTextFromPdfAsync(file),
                ".docx" => await ExtractTextFromDocxAsync(file),
                ".doc" => await ExtractTextFromDocAsync(file),
                ".txt" => await ExtractTextFromTxtAsync(file),
                _ => throw new NotSupportedException($"File type {extension} is not supported")
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error extracting text from file {FileName}", file.FileName);
            throw;
        }
    }

    private async Task<string> ExtractTextFromPdfAsync(IFormFile file)
    {
        using var stream = new MemoryStream();
        await file.CopyToAsync(stream);
        stream.Position = 0;

        var sb = new StringBuilder();
        using var document = PdfDocument.Open(stream);

        foreach (var page in document.GetPages())
        {
            var text = page.Text;
            sb.AppendLine(text);
        }

        return sb.ToString();
    }

    private async Task<string> ExtractTextFromDocxAsync(IFormFile file)
    {
        using var stream = new MemoryStream();
        await file.CopyToAsync(stream);
        stream.Position = 0;

        using var doc = WordprocessingDocument.Open(stream, false);
        var body = doc.MainDocumentPart?.Document.Body;
        
        if (body == null)
            return string.Empty;

        return body.InnerText;
    }

    private async Task<string> ExtractTextFromDocAsync(IFormFile file)
    {
        // For .doc files (older Word format), we'll need a different approach
        // For simplicity, we'll suggest converting to .docx or using a specialized library
        // In production, consider using Aspose.Words or similar
        _logger.LogWarning(".doc format support is limited. Please convert to .docx for better results.");
        
        using var stream = new MemoryStream();
        await file.CopyToAsync(stream);
        stream.Position = 0;

        // Try to read as plain text (won't work perfectly for binary .doc files)
        using var reader = new StreamReader(stream, Encoding.UTF8, detectEncodingFromByteOrderMarks: true);
        return await reader.ReadToEndAsync();
    }

    private async Task<string> ExtractTextFromTxtAsync(IFormFile file)
    {
        using var stream = new MemoryStream();
        await file.CopyToAsync(stream);
        stream.Position = 0;

        using var reader = new StreamReader(stream);
        return await reader.ReadToEndAsync();
    }
}
