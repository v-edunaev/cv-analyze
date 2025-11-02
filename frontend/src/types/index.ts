export interface Candidate {
  id: number;
  fullName: string;
  email: string;
  phone?: string;
  address?: string;
  linkedin?: string;
  github?: string;
  portfolio?: string;
  summary?: string;
  yearsOfExperience?: number;
  currentPosition?: string;
  currentCompany?: string;
  createdAt: string;
  updatedAt: string;
  workExperiences: WorkExperience[];
  educations: Education[];
  skills: Skill[];
}

export interface WorkExperience {
  id?: number;
  jobTitle: string;
  company: string;
  location?: string;
  startDate: string;
  endDate?: string;
  isCurrent: boolean;
  description?: string;
}

export interface Education {
  id?: number;
  degree: string;
  institution: string;
  fieldOfStudy?: string;
  startDate?: string;
  endDate?: string;
  grade?: string;
}

export interface Skill {
  id?: number;
  name: string;
  category?: string;
  proficiencyLevel?: string;
}

export interface UploadCvResponse {
  success: boolean;
  message?: string;
  candidate?: Candidate;
  rawText?: string;
}

export interface CandidateListResponse {
  candidates: Candidate[];
  totalCount: number;
  page: number;
  pageSize: number;
}
