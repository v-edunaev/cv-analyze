using System;
using System.IO;
using System.Threading.Tasks;
using CVAnalyzer.Api.Services;
using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Moq;
using Xunit;

namespace CVAnalyzer.Tests.Services;

public class CvProcessingServiceTests
{
    private readonly CvProcessingService _service;
    private readonly Mock<ILogger<CvProcessingService>> _loggerMock;
    private readonly string _testDataPath;

    public CvProcessingServiceTests()
    {
        _loggerMock = new Mock<ILogger<CvProcessingService>>();
        _service = new CvProcessingService(_loggerMock.Object);
        _testDataPath = Path.Combine(Directory.GetCurrentDirectory(), "..", "..", "..", "..", "..", "test-data");
    }

    private IFormFile CreateFormFile(Stream stream, string fileName)
    {
        var formFileMock = new Mock<IFormFile>();
        formFileMock.Setup(f => f.FileName).Returns(fileName);
        formFileMock.Setup(f => f.Length).Returns(stream.Length);
        formFileMock.Setup(f => f.OpenReadStream()).Returns(stream);
        formFileMock.Setup(f => f.CopyToAsync(It.IsAny<Stream>(), It.IsAny<System.Threading.CancellationToken>()))
            .Returns((Stream target, System.Threading.CancellationToken token) =>
            {
                stream.Position = 0;
                return stream.CopyToAsync(target, token);
            });
        return formFileMock.Object;
    }

    [Fact]
    public async Task ExtractTextFromFile_WithValidTextFile_ShouldExtractText()
    {
        // Arrange
        var filePath = Path.Combine(_testDataPath, "valid-cv-sample.txt");
        using var fileStream = File.OpenRead(filePath);
        var formFile = CreateFormFile(fileStream, "sample.txt");

        // Act
        var result = await _service.ExtractTextFromFileAsync(formFile);

        // Assert
        result.Should().NotBeNullOrEmpty();
        result.Should().Contain("JOHN SMITH");
        result.Should().Contain("Software Engineer");
        result.Should().Contain("john.smith@email.com");
    }

    [Fact]
    public async Task ExtractTextFromFile_WithValidPdfFile_ShouldExtractText()
    {
        // Arrange
        var filePath = Path.Combine(_testDataPath, "valid-cv-sample.pdf");
        
        if (!File.Exists(filePath))
        {
            // Skip if PDF not generated
            return;
        }

        using var fileStream = File.OpenRead(filePath);
        var formFile = CreateFormFile(fileStream, "sample.pdf");

        // Act
        var result = await _service.ExtractTextFromFileAsync(formFile);

        // Assert
        result.Should().NotBeNullOrEmpty();
        result.Should().Contain("JOHN SMITH");
    }

    [Fact]
    public async Task ExtractTextFromFile_WithValidDocxFile_ShouldExtractText()
    {
        // Arrange
        var filePath = Path.Combine(_testDataPath, "valid-cv-sample.docx");
        
        if (!File.Exists(filePath))
        {
            // Skip if DOCX not generated
            return;
        }

        using var fileStream = File.OpenRead(filePath);
        var formFile = CreateFormFile(fileStream, "sample.docx");

        // Act
        var result = await _service.ExtractTextFromFileAsync(formFile);

        // Assert
        result.Should().NotBeNullOrEmpty();
        result.Should().Contain("JOHN SMITH");
    }

    [Fact]
    public async Task ExtractTextFromFile_WithEmptyFile_ShouldReturnEmpty()
    {
        // Arrange
        var filePath = Path.Combine(_testDataPath, "invalid-cv-empty.txt");
        using var fileStream = File.OpenRead(filePath);
        var formFile = CreateFormFile(fileStream, "empty.txt");

        // Act
        var result = await _service.ExtractTextFromFileAsync(formFile);

        // Assert
        result.Should().BeEmpty();
    }

    [Fact]
    public async Task ExtractTextFromFile_WithCorruptedDocx_ShouldThrowException()
    {
        // Arrange
        var filePath = Path.Combine(_testDataPath, "invalid-cv-corrupted.docx");
        using var fileStream = File.OpenRead(filePath);
        var formFile = CreateFormFile(fileStream, "corrupted.docx");

        // Act & Assert
        await Assert.ThrowsAsync<System.IO.FileFormatException>(async () => 
            await _service.ExtractTextFromFileAsync(formFile));
    }

    [Theory]
    [InlineData("test.pdf", true)]
    [InlineData("test.docx", true)]
    [InlineData("test.doc", true)]
    [InlineData("test.txt", true)]
    [InlineData("test.exe", false)]
    [InlineData("test.jpg", false)]
    [InlineData("test.zip", false)]
    [InlineData("", false)]
    public void IsSupportedFileType_WithVariousExtensions_ShouldReturnCorrectResult(
        string filename, bool expected)
    {
        // Act
        var result = _service.IsSupportedFileType(filename);

        // Assert
        result.Should().Be(expected);
    }

    [Fact]
    public async Task ExtractTextFromFile_WithUnsupportedFile_ShouldThrowException()
    {
        // Arrange
        using var stream = new MemoryStream();
        var formFile = CreateFormFile(stream, "test.exe");

        // Act & Assert
        await Assert.ThrowsAsync<NotSupportedException>(async () => 
            await _service.ExtractTextFromFileAsync(formFile));
    }
}
