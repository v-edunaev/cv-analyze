# CV Analyzer Application

A full-stack application for analyzing and managing job candidate CVs/resumes. The system automatically extracts information from uploaded CV files using AI (OpenAI GPT or Google Gemini) and provides an interactive dashboard for managing candidates.

## 🌟 Features

- **Multi-Format CV Upload**: Support for PDF, DOCX, DOC, and TXT files
- **AI-Powered Data Extraction**: Automatic parsing of CV content using LLM (OpenAI or Gemini)
- **Confirmation Dialog**: Review and edit extracted data before saving
- **Interactive Dashboard**: 
  - Sort and filter candidates
  - Search across all fields
  - View detailed candidate profiles
  - Delete candidates
- **Rich Candidate Profiles**: Store work experience, education, skills, and contact information
- **RESTful API**: Clean API architecture with ASP.NET Core
- **Modern UI**: Responsive React + TypeScript frontend

## 🏗️ Architecture

### Backend
- **Framework**: ASP.NET Core 8.0 (C#)
- **Database**: PostgreSQL with Entity Framework Core
- **CV Processing**: PdfPig (PDF), DocumentFormat.OpenXml (DOCX)
- **AI Integration**: OpenAI GPT-4 / Google Gemini API

### Frontend
- **Framework**: React 18 with TypeScript
- **Build Tool**: Vite
- **Routing**: React Router v6
- **HTTP Client**: Axios
- **UI Components**: Custom components with CSS

### Database Schema
- **Candidates**: Core candidate information
- **WorkExperiences**: Employment history
- **Educations**: Academic background
- **Skills**: Technical and soft skills
- **CvFiles**: Original uploaded files and extracted text

## 📋 Prerequisites

- [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- [Node.js](https://nodejs.org/) (v18 or higher)
- [PostgreSQL](https://www.postgresql.org/download/) (v12 or higher)
- API Key for either:
  - [OpenAI API](https://platform.openai.com/api-keys) (recommended: GPT-4o-mini)
  - [Google Gemini API](https://ai.google.dev/)

## 🚀 Quick Start

### Option 1: Docker Compose (Recommended for Quick Testing) 🐳

The fastest way to get started - no need to install PostgreSQL, Node.js, or .NET!

```powershell
# Copy and configure environment
Copy-Item .env.docker .env
# Edit .env with your API keys

# Start all services
docker-compose up -d

# Access application
# Frontend: http://localhost
# Backend API: http://localhost:5000
# Swagger: http://localhost:5000/swagger
```

**See [DOCKER_K8S_GUIDE.md](DOCKER_K8S_GUIDE.md) for detailed Docker instructions.**

### Option 2: Kubernetes (Production Deployment) ☸️

For scalable production deployments with auto-scaling and high availability:

```powershell
# Update secrets first!
# Edit k8s/secrets.yaml with your API keys

# Deploy to Kubernetes
.\deploy-k8s.ps1

# Or for Minikube local development
.\setup-minikube.ps1
```

**See [DOCKER_K8S_GUIDE.md](DOCKER_K8S_GUIDE.md) for comprehensive Kubernetes setup.**

### Option 3: Local Development (Traditional) 💻

If you prefer to run services locally without containers:

See [SETUP.md](SETUP.md) for detailed local development setup instructions.

## 🔧 Installation & Setup (Local Development)

Only follow these steps if you chose **Option 3** above. For Docker/Kubernetes, skip to the relevant guide.

### 1. Clone the Repository

```bash
cd c:\dev\misc\projects\analyze-cv
```

### 2. Database Setup

1. Install PostgreSQL if not already installed
2. Create a new database:

```sql
CREATE DATABASE cv_analyzer;
```

3. Update the connection string in `backend/appsettings.json`:

```json
"ConnectionStrings": {
  "DefaultConnection": "Host=localhost;Database=cv_analyzer;Username=your_username;Password=your_password"
}
```

### 3. Backend Setup

1. Navigate to the backend directory:

```bash
cd backend
```

2. Restore NuGet packages:

```bash
dotnet restore
```

3. Configure your LLM API key in `appsettings.json`:

**For OpenAI:**
```json
"LLM": {
  "Provider": "OpenAI",
  "OpenAI": {
    "ApiKey": "sk-your-openai-api-key-here",
    "Model": "gpt-4o-mini"
  }
}
```

**For Google Gemini:**
```json
"LLM": {
  "Provider": "Gemini",
  "Gemini": {
    "ApiKey": "your-gemini-api-key-here",
    "Model": "gemini-1.5-flash"
  }
}
```

4. Run database migrations:

```bash
dotnet ef migrations add InitialCreate
dotnet ef database update
```

5. Run the backend:

```bash
dotnet run
```

The API will be available at `http://localhost:5000`

### 4. Frontend Setup

1. Navigate to the frontend directory:

```bash
cd ..\frontend
```

2. Install dependencies:

```bash
npm install
```

3. Start the development server:

```bash
npm run dev
```

The application will be available at `http://localhost:3000`

## 📖 Usage

### Uploading a CV

1. Navigate to the **Upload CV** page
2. Select a CV file (PDF, DOCX, DOC, or TXT)
3. Click **Upload and Process CV**
4. Review the extracted information in the confirmation dialog
5. Edit any fields as needed
6. Click **Save Candidate** to add to the database

### Managing Candidates

1. Navigate to the **Dashboard** page
2. Use the search bar to filter candidates by name, email, position, company, or skills
3. Click column headers to sort the table
4. Click the eye icon (👁️) to view detailed candidate information
5. Click the trash icon (🗑️) to delete a candidate

## 🔧 API Endpoints

### CV Upload
- `POST /api/cvupload/upload` - Upload and process a CV file
- `POST /api/cvupload/confirm` - Confirm and save candidate data

### Candidates
- `GET /api/candidates` - Get paginated list of candidates
  - Query params: `page`, `pageSize`, `search`, `sortBy`, `sortDescending`
- `GET /api/candidates/{id}` - Get candidate by ID
- `POST /api/candidates` - Create a new candidate
- `PUT /api/candidates/{id}` - Update candidate
- `DELETE /api/candidates/{id}` - Delete candidate

## 🗂️ Project Structure

```
analyze-cv/
├── backend/
│   ├── Controllers/          # API controllers
│   ├── Data/                 # Database context
│   ├── DTOs/                 # Data transfer objects
│   ├── Models/               # Entity models
│   ├── Services/             # Business logic
│   │   ├── CvProcessingService.cs    # File text extraction
│   │   ├── LlmService.cs             # AI integration
│   │   └── CandidateService.cs       # Candidate CRUD
│   ├── Program.cs            # Application entry point
│   └── appsettings.json      # Configuration
│
├── frontend/
│   ├── src/
│   │   ├── components/       # React components
│   │   │   ├── CandidateTable.tsx
│   │   │   ├── CandidateDetailModal.tsx
│   │   │   └── ConfirmationDialog.tsx
│   │   ├── pages/            # Page components
│   │   │   ├── UploadCv.tsx
│   │   │   └── Dashboard.tsx
│   │   ├── services/         # API client
│   │   ├── types/            # TypeScript types
│   │   ├── App.tsx           # Main app component
│   │   └── main.tsx          # Application entry point
│   ├── package.json
│   └── vite.config.ts
│
└── README.md
```

## 🎨 Features in Detail

### AI-Powered CV Parsing

The application uses advanced LLMs to extract structured data from unstructured CV text:

- **Personal Information**: Name, email, phone, address, social profiles
- **Professional Summary**: Career overview and objectives
- **Work Experience**: Job titles, companies, dates, responsibilities
- **Education**: Degrees, institutions, fields of study, grades
- **Skills**: Technical skills, soft skills, proficiency levels

### Supported File Formats

- **PDF**: Uses PdfPig for text extraction
- **DOCX/DOC**: Uses DocumentFormat.OpenXml
- **TXT**: Direct text reading

### Search & Filter

The dashboard supports comprehensive searching across:
- Candidate name
- Email address
- Current position
- Current company
- Skills

### Sorting

Click any column header to sort by:
- Name
- Email
- Years of experience
- Date added

## 🔐 Security Considerations

- Store API keys in environment variables for production
- Implement authentication/authorization for production use
- Add rate limiting for API endpoints
- Validate and sanitize all file uploads
- Use HTTPS in production

## 🐛 Troubleshooting

### Database Connection Issues
- Ensure PostgreSQL is running
- Verify connection string in `appsettings.json`
- Check username/password credentials

### LLM API Errors
- Verify API key is correct and active
- Check API quota/rate limits
- Ensure internet connectivity

### File Upload Errors
- Check file size limits
- Verify file format is supported
- Ensure uploads directory has write permissions

## 📝 Environment Variables (Production)

For production deployment, use environment variables instead of hardcoded values:

**Docker Compose** - Set in `.env` file:
```bash
DB_PASSWORD=your_password
LLM_PROVIDER=OpenAI
OPENAI_API_KEY=sk-your-key
OPENAI_MODEL=gpt-4o-mini
```

**Kubernetes** - Set in `k8s/secrets.yaml` and `k8s/configmap.yaml`:
```yaml
# secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: cv-analyzer-secrets
stringData:
  openai-api-key: "sk-your-key"
  database-password: "your-password"
```

**Traditional Deployment** - Use environment variables:
```bash
ConnectionStrings__DefaultConnection="Host=...;Database=...;Username=...;Password=..."
LLM__Provider="OpenAI"
LLM__OpenAI__ApiKey="sk-..."
```

## 🚀 Deployment Options

### Docker Compose (Development/Testing)

```powershell
docker-compose up -d
```

See [DOCKER_K8S_GUIDE.md](DOCKER_K8S_GUIDE.md#-docker-deployment) for details.

### Kubernetes (Production)

**Cloud Providers:**
- Azure Kubernetes Service (AKS)
- Amazon Elastic Kubernetes Service (EKS)
- Google Kubernetes Engine (GKE)

**Local Testing:**
- Minikube
- Docker Desktop Kubernetes

```powershell
# Quick deploy
.\deploy-k8s.ps1

# Minikube setup
.\setup-minikube.ps1

# Cleanup
.\cleanup-k8s.ps1
```

See [DOCKER_K8S_GUIDE.md](DOCKER_K8S_GUIDE.md#-kubernetes-deployment) for comprehensive guide.

### Traditional Hosting

**Backend (ASP.NET Core)**
```bash
cd backend
dotnet publish -c Release -o ./publish
```

Deploy to:
- Azure App Service
- AWS Elastic Beanstalk
- Digital Ocean
- Self-hosted IIS/Nginx

**Frontend (React)**
```bash
cd frontend
npm run build
```

Deploy the `dist` folder to:
- Vercel
- Netlify
- Azure Static Web Apps
- AWS S3 + CloudFront
- Self-hosted Nginx

## 📚 Documentation

- **[SETUP.md](SETUP.md)** - Detailed local development setup
- **[DOCKER_K8S_GUIDE.md](DOCKER_K8S_GUIDE.md)** - Complete Docker & Kubernetes guide
- **[PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)** - Architecture and design decisions
- **[COMMANDS.md](COMMANDS.md)** - Quick command reference
- **[CHECKLIST.md](CHECKLIST.md)** - Development checklist
- **[BUILD_STATUS.md](BUILD_STATUS.md)** - Current build status

## 📄 License

This project is for educational/demonstration purposes.

## 🤝 Contributing

This is a demonstration project. Feel free to fork and modify for your needs.

## 📧 Support

For issues or questions, please check the code documentation or create an issue in the repository.

---

**Built with** ❤️ **using ASP.NET Core, React, TypeScript, and AI**
