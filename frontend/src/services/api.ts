import axios from 'axios';
import { Candidate, UploadCvResponse, CandidateListResponse } from '../types';

const API_BASE_URL = 'http://localhost:5000/api';

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

export const cvApi = {
  uploadCv: async (file: File): Promise<UploadCvResponse> => {
    const formData = new FormData();
    formData.append('file', file);
    
    const response = await axios.post<UploadCvResponse>(
      `${API_BASE_URL}/cvupload/upload`,
      formData,
      {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      }
    );
    return response.data;
  },

  confirmCandidate: async (candidate: Candidate): Promise<Candidate> => {
    const response = await api.post<Candidate>('/cvupload/confirm', { candidate });
    return response.data;
  },
};

export const candidatesApi = {
  getCandidates: async (
    page: number = 1,
    pageSize: number = 10,
    search?: string,
    sortBy?: string,
    sortDescending: boolean = false
  ): Promise<CandidateListResponse> => {
    const params = new URLSearchParams({
      page: page.toString(),
      pageSize: pageSize.toString(),
      ...(search && { search }),
      ...(sortBy && { sortBy }),
      sortDescending: sortDescending.toString(),
    });
    
    const response = await api.get<CandidateListResponse>(`/candidates?${params}`);
    return response.data;
  },

  getCandidate: async (id: number): Promise<Candidate> => {
    const response = await api.get<Candidate>(`/candidates/${id}`);
    return response.data;
  },

  updateCandidate: async (id: number, candidate: Candidate): Promise<Candidate> => {
    const response = await api.put<Candidate>(`/candidates/${id}`, candidate);
    return response.data;
  },

  deleteCandidate: async (id: number): Promise<void> => {
    await api.delete(`/candidates/${id}`);
  },
};
