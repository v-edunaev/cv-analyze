# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy solution and project files
COPY analyze-cv.sln .
COPY backend/Directory.Packages.props backend/
COPY backend/CVAnalyzer.Api.csproj backend/
COPY backend/CVAnalyzer.Tests/CVAnalyzer.Tests.csproj backend/CVAnalyzer.Tests/

# Restore dependencies
RUN dotnet restore analyze-cv.sln

# Copy backend source code
COPY backend/ backend/

# Build and publish
RUN dotnet publish analyze-cv.sln -c Release -o /app/publish

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime
WORKDIR /app

# Copy published files
COPY --from=build /app/publish .

# Create uploads directory
RUN mkdir -p /app/uploads

# Expose port
EXPOSE 5050

# Set environment variables
ENV ASPNETCORE_URLS=http://+:5050
ENV ASPNETCORE_ENVIRONMENT=Production

# Run the application
ENTRYPOINT ["dotnet", "CVAnalyzer.Api.dll"]