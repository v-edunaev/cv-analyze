# Security Policy

## Supported Versions

We actively maintain security updates for the following versions of CV Analyzer:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take security vulnerabilities seriously. If you discover a security vulnerability in CV Analyzer, please report it responsibly.

### How to Report

**Please do NOT create a public GitHub issue for security vulnerabilities.**

Instead, please report security vulnerabilities through one of these channels:

1. **GitHub Security Advisories** (Preferred)
   - Go to the [Security tab](https://github.com/v-edunaev/cv-analyze/security/advisories) of this repository
   - Click "Report a vulnerability"
   - Fill out the form with details

2. **Email**
   - Send details to the repository maintainers
   - Include "SECURITY" in the subject line
   - Provide detailed information about the vulnerability

### What to Include

When reporting a vulnerability, please include:

- **Description**: Clear description of the vulnerability
- **Impact**: Potential impact and attack scenarios
- **Reproduction Steps**: Step-by-step instructions to reproduce
- **Affected Components**: Which parts of the system are affected
- **Suggested Fix**: If you have ideas for remediation
- **Your Contact Information**: For follow-up questions

### Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Fix Timeline**: Depends on severity
  - Critical: 1-3 days
  - High: 1-2 weeks
  - Medium: 2-4 weeks
  - Low: Next minor release

## Security Measures

### Application Security

#### Data Protection
- **API Keys**: All API keys are stored as GitHub secrets, never in code
- **Database**: Passwords and sensitive data are properly encrypted
- **File Upload**: Strict validation and sanitization of uploaded files
- **Input Validation**: All user inputs are validated and sanitized

#### Authentication & Authorization
- **API Security**: RESTful APIs with proper error handling
- **File Access**: Controlled file upload and processing
- **Database Access**: Parameterized queries to prevent SQL injection

#### Infrastructure Security
- **Container Security**: Regular base image updates
- **Dependency Scanning**: Automated vulnerability scanning with Trivy
- **Docker**: Multi-stage builds with minimal attack surface
- **Kubernetes**: Security-focused deployment configurations

### Development Security

#### Secure Development Practices
- **Code Review**: All changes require review before merging
- **Dependency Management**: Regular updates and vulnerability scanning
- **Secrets Management**: No hardcoded secrets in source code
- **Static Analysis**: Automated security scanning in CI/CD pipeline

#### CI/CD Security
- **GitHub Actions**: Secure workflow configurations
- **Container Scanning**: Trivy security scanning for vulnerabilities
- **Dependency Checks**: Automated dependency vulnerability detection
- **Secret Scanning**: GitHub's secret scanning enabled

## Security Configuration

### Environment Variables

Never commit these sensitive values to source control:

```bash
# API Keys
OPENAI_API_KEY=sk-...
GEMINI_API_KEY=...

# Database
DB_PASSWORD=...
CONNECTION_STRING=...

# Other sensitive configuration
JWT_SECRET=...
ENCRYPTION_KEY=...
```

### File Upload Security

- **Allowed Extensions**: `.pdf`, `.docx`, `.doc`, `.txt`
- **File Size Limits**: Maximum 10MB per file
- **Content Validation**: File content verification
- **Virus Scanning**: Consider implementing in production
- **Storage**: Temporary processing only, no permanent storage

### Database Security

- **Connection Strings**: Use environment variables
- **Parameterized Queries**: Prevent SQL injection
- **Access Control**: Minimal required permissions
- **Encryption**: Data at rest and in transit

## Deployment Security

### Docker Security

```dockerfile
# Use non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs

# Minimal base images
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine

# Security updates
RUN apk update && apk upgrade
```

### Kubernetes Security

```yaml
# Security context
securityContext:
  runAsNonRoot: true
  runAsUser: 1001
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false

# Resource limits
resources:
  limits:
    memory: "512Mi"
    cpu: "500m"
  requests:
    memory: "256Mi"
    cpu: "250m"
```

### Network Security

- **HTTPS Only**: All communications encrypted
- **CORS Policy**: Restrictive cross-origin policies
- **Rate Limiting**: API rate limiting implemented
- **Input Validation**: Server-side validation for all inputs

## Vulnerability Management

### Dependency Management

```bash
# Regular dependency audits
npm audit
dotnet list package --vulnerable

# Automated updates
npm update
dotnet outdated
```

### Container Security

```bash
# Regular base image updates
docker pull mcr.microsoft.com/dotnet/aspnet:8.0-alpine
docker pull node:18-alpine

# Security scanning
trivy image cv-analyzer:latest
```

### Monitoring

- **Error Monitoring**: Structured logging without sensitive data
- **Security Events**: Failed authentication attempts
- **File Upload Monitoring**: Unusual upload patterns
- **API Abuse**: Rate limiting and monitoring

## Security Checklist

### Before Deployment

- [ ] All secrets configured in GitHub/environment
- [ ] No hardcoded credentials in code
- [ ] Dependencies updated and scanned
- [ ] Container images scanned for vulnerabilities
- [ ] HTTPS configured
- [ ] Input validation implemented
- [ ] Error handling doesn't expose sensitive info
- [ ] File upload restrictions in place
- [ ] Database connections secured
- [ ] Rate limiting configured

### Regular Maintenance

- [ ] Update dependencies monthly
- [ ] Review security advisories
- [ ] Update base container images
- [ ] Review access logs
- [ ] Test backup and recovery procedures
- [ ] Review and rotate API keys quarterly
- [ ] Security testing with updated threat models

## Incident Response

### In Case of Security Incident

1. **Immediate Response**
   - Assess the scope and impact
   - Contain the vulnerability if possible
   - Document all findings

2. **Communication**
   - Notify maintainers immediately
   - Prepare public communication if needed
   - Update affected users/deployments

3. **Remediation**
   - Develop and test fixes
   - Deploy patches as soon as possible
   - Verify the fix resolves the issue

4. **Post-Incident**
   - Conduct post-mortem analysis
   - Update security measures
   - Document lessons learned

## Security Contact

For security-related questions or concerns that are not vulnerabilities:

- Review this security policy
- Check existing GitHub Issues (for non-sensitive topics)
- Contact repository maintainers through GitHub

## Acknowledgments

We appreciate the security research community and will acknowledge responsible disclosure of vulnerabilities in our release notes (with permission from the reporter).

---

**Last Updated**: November 2, 2025  
**Version**: 1.0