using System;
using System.Net;
using System.Net.Http;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using CVAnalyzer.Api.Services;
using Moq;
using Xunit;
using Moq.Protected;

namespace CVAnalyzer.Tests.Services;

public class LlmServiceTests
{
    private readonly Mock<ILogger> _mockLogger;
    private readonly Mock<IConfiguration> _mockConfiguration;

    public LlmServiceTests()
    {
        _mockLogger = new Mock<ILogger>();
        _mockConfiguration = new Mock<IConfiguration>();
    }

    [Fact]
    public void OpenAIService_Constructor_ThrowsWhenApiKeyMissing()
    {
        // Arrange
        _mockConfiguration.Setup(x => x["LLM:OpenAI:ApiKey"]).Returns((string?)null);

        // Act & Assert
        Assert.Throws<InvalidOperationException>(() => new OpenAIService(_mockConfiguration.Object, Mock.Of<ILogger<OpenAIService>>()));
    }

    [Fact]
    public void GeminiService_Constructor_ThrowsWhenApiKeyMissing()
    {
        // Arrange
        var mockHttpClient = new HttpClient();
        _mockConfiguration.Setup(x => x["LLM:Gemini:ApiKey"]).Returns((string?)null);

        // Act & Assert
        Assert.Throws<InvalidOperationException>(() => new GeminiService(mockHttpClient, _mockConfiguration.Object, Mock.Of<ILogger<GeminiService>>()));
    }

    [Fact]
    public async Task GeminiService_ParseCvTextAsync_HandlesHttpError()
    {
        // Arrange
        var mockHttpMessageHandler = new Mock<HttpMessageHandler>();
        mockHttpMessageHandler
            .Protected()
            .Setup<Task<HttpResponseMessage>>("SendAsync", ItExpr.IsAny<HttpRequestMessage>(), ItExpr.IsAny<CancellationToken>())
            .ReturnsAsync(new HttpResponseMessage(HttpStatusCode.BadRequest));

        var httpClient = new HttpClient(mockHttpMessageHandler.Object);
        
        _mockConfiguration.Setup(x => x["LLM:Gemini:ApiKey"]).Returns("test-key");
        _mockConfiguration.Setup(x => x["LLM:Gemini:Model"]).Returns("gemini-1.5-flash");

        var service = new GeminiService(httpClient, _mockConfiguration.Object, Mock.Of<ILogger<GeminiService>>());

        // Act & Assert
        await Assert.ThrowsAsync<InvalidOperationException>(() => service.ParseCvTextAsync("test cv text"));
    }

    [Fact]
    public async Task GeminiService_ParseCvTextAsync_ReturnsValidResponse()
    {
        // Arrange
        var geminiResponse = new
        {
            candidates = new[]
            {
                new
                {
                    content = new
                    {
                        parts = new[]
                        {
                            new { text = "{\"fullName\": \"John Doe\", \"email\": \"john@example.com\"}" }
                        }
                    }
                }
            }
        };

        var mockHttpMessageHandler = new Mock<HttpMessageHandler>();
        mockHttpMessageHandler
            .Protected()
            .Setup<Task<HttpResponseMessage>>("SendAsync", ItExpr.IsAny<HttpRequestMessage>(), ItExpr.IsAny<CancellationToken>())
            .ReturnsAsync(new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(JsonSerializer.Serialize(geminiResponse))
            });

        var httpClient = new HttpClient(mockHttpMessageHandler.Object);
        
        _mockConfiguration.Setup(x => x["LLM:Gemini:ApiKey"]).Returns("test-key");
        _mockConfiguration.Setup(x => x["LLM:Gemini:Model"]).Returns("gemini-1.5-flash");

        var service = new GeminiService(httpClient, _mockConfiguration.Object, Mock.Of<ILogger<GeminiService>>());

        // Act
        var result = await service.ParseCvTextAsync("test cv text");

        // Assert
        Assert.NotNull(result);
        Assert.Equal("John Doe", result.FullName);
        Assert.Equal("john@example.com", result.Email);
    }
}