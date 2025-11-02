// Test data for CV Analyzer frontend tests
import { Candidate, UploadCvResponse, CandidateListResponse } from '../types'

export const mockValidCvText = `JOHN SMITH
Software Engineer

Contact Information:
Email: john.smith@email.com
Phone: +1 (555) 123-4567
Location: San Francisco, CA
LinkedIn: linkedin.com/in/johnsmith
GitHub: github.com/johnsmith

PROFESSIONAL SUMMARY
Experienced software engineer with 8+ years of expertise in full-stack development. Proven track record of delivering scalable web applications using modern technologies. Strong background in cloud architecture and microservices.

WORK EXPERIENCE

Senior Software Engineer
Tech Solutions Inc., San Francisco, CA
January 2020 - Present
• Led development of microservices architecture serving 1M+ daily users
• Implemented CI/CD pipelines reducing deployment time by 60%
• Mentored team of 5 junior developers
• Technologies: C#, .NET Core, React, Azure, Kubernetes

Software Engineer
Digital Innovations LLC, San Jose, CA
June 2017 - December 2019
• Developed RESTful APIs for e-commerce platform
• Optimized database queries improving performance by 40%
• Collaborated with cross-functional teams on agile projects
• Technologies: ASP.NET, SQL Server, Angular, Docker

EDUCATION

Bachelor of Science in Computer Science
University of California, San Francisco
September 2013 - May 2017
GPA: 3.8/4.0

SKILLS
• Programming Languages: C#, JavaScript, TypeScript, Python
• Frameworks: .NET Core, React, Angular, Express.js
• Databases: SQL Server, PostgreSQL, MongoDB
• Cloud: Azure, AWS, Google Cloud
• DevOps: Docker, Kubernetes, CI/CD, Git`

export const mockCandidate: Candidate = {
  id: 1,
  fullName: 'John Smith',
  email: 'john.smith@email.com',
  phone: '+1 (555) 123-4567',
  address: 'San Francisco, CA',
  linkedin: 'linkedin.com/in/johnsmith',
  github: 'github.com/johnsmith',
  portfolio: undefined,
  summary: 'Experienced software engineer with 8+ years of expertise in full-stack development. Proven track record of delivering scalable web applications using modern technologies. Strong background in cloud architecture and microservices.',
  yearsOfExperience: 8,
  currentPosition: 'Senior Software Engineer',
  currentCompany: 'Tech Solutions Inc.',
  createdAt: '2023-11-01T10:00:00.000Z',
  updatedAt: '2023-11-01T10:00:00.000Z',
  workExperiences: [
    {
      id: 1,
      jobTitle: 'Senior Software Engineer',
      company: 'Tech Solutions Inc.',
      location: 'San Francisco, CA',
      startDate: '2020-01-01',
      endDate: undefined,
      isCurrent: true,
      description: 'Led development of microservices architecture serving 1M+ daily users. Implemented CI/CD pipelines reducing deployment time by 60%. Mentored team of 5 junior developers.'
    },
    {
      id: 2,
      jobTitle: 'Software Engineer',
      company: 'Digital Innovations LLC',
      location: 'San Jose, CA',
      startDate: '2017-06-01',
      endDate: '2019-12-31',
      isCurrent: false,
      description: 'Developed RESTful APIs for e-commerce platform. Optimized database queries improving performance by 40%. Collaborated with cross-functional teams on agile projects.'
    }
  ],
  educations: [
    {
      id: 1,
      degree: 'Bachelor of Science',
      fieldOfStudy: 'Computer Science',
      institution: 'University of California, San Francisco',
      startDate: '2013-09-01',
      endDate: '2017-05-31',
      grade: '3.8/4.0'
    }
  ],
  skills: [
    { id: 1, name: 'C#', proficiencyLevel: 'Expert' },
    { id: 2, name: 'JavaScript', proficiencyLevel: 'Expert' },
    { id: 3, name: 'TypeScript', proficiencyLevel: 'Advanced' },
    { id: 4, name: 'React', proficiencyLevel: 'Expert' },
    { id: 5, name: '.NET Core', proficiencyLevel: 'Expert' },
    { id: 6, name: 'Azure', proficiencyLevel: 'Advanced' },
    { id: 7, name: 'Kubernetes', proficiencyLevel: 'Intermediate' }
  ]
}

export const mockCandidates: Candidate[] = [
  mockCandidate,
  {
    ...mockCandidate,
    id: 2,
    fullName: 'Jane Doe',
    email: 'jane.doe@email.com',
    currentPosition: 'Frontend Developer',
    currentCompany: 'UI/UX Corp',
    yearsOfExperience: 5,
    workExperiences: [{
      id: 3,
      jobTitle: 'Frontend Developer',
      company: 'UI/UX Corp',
      location: 'New York, NY',
      startDate: '2019-03-01',
      endDate: undefined,
      isCurrent: true,
      description: 'Developing modern web applications using React and TypeScript.'
    }],
    skills: [
      { id: 8, name: 'React', proficiencyLevel: 'Expert' },
      { id: 9, name: 'TypeScript', proficiencyLevel: 'Advanced' },
      { id: 10, name: 'CSS', proficiencyLevel: 'Expert' }
    ]
  }
]

export const mockUploadResponse: UploadCvResponse = {
  success: true,
  candidate: mockCandidate,
  rawText: mockValidCvText
}

export const mockCandidateListResponse: CandidateListResponse = {
  candidates: mockCandidates,
  totalCount: 2,
  page: 1,
  pageSize: 10
}

export const mockFile = new File(['mock cv content'], 'test-cv.txt', {
  type: 'text/plain'
})

export const mockPdfFile = new File(['mock pdf content'], 'test-cv.pdf', {
  type: 'application/pdf'
})

export const mockEmptyFile = new File([''], 'empty-cv.txt', {
  type: 'text/plain'
})

export const mockInvalidFile = new File(['invalid content'], 'invalid.xyz', {
  type: 'application/unknown'
})