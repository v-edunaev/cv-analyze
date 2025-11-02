import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import axios from 'axios'
import { cvApi, candidatesApi } from './api'
import { mockCandidate, mockUploadResponse, mockCandidateListResponse, mockFile } from '../test/mockData'

// Mock axios
vi.mock('axios')
const mockedAxios = vi.mocked(axios, true)

describe('API Service', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  afterEach(() => {
    vi.resetAllMocks()
  })

  describe('cvApi', () => {
    describe('uploadCv', () => {
      it('uploads CV file successfully', async () => {
        const mockResponse = { data: mockUploadResponse }
        mockedAxios.post.mockResolvedValue(mockResponse)

        const result = await cvApi.uploadCv(mockFile)

        expect(mockedAxios.post).toHaveBeenCalledWith(
          'http://localhost:5050/api/cvupload/upload',
          expect.any(FormData),
          {
            headers: {
              'Content-Type': 'multipart/form-data',
            },
          }
        )
        expect(result).toEqual(mockUploadResponse)
      })

      it('handles upload error', async () => {
        const errorMessage = 'Upload failed'
        mockedAxios.post.mockRejectedValue(new Error(errorMessage))

        await expect(cvApi.uploadCv(mockFile)).rejects.toThrow(errorMessage)
      })

      it('sends FormData with correct file', async () => {
        const mockResponse = { data: mockUploadResponse }
        mockedAxios.post.mockResolvedValue(mockResponse)

        await cvApi.uploadCv(mockFile)

        const formDataCall = mockedAxios.post.mock.calls[0]
        const formData = formDataCall[1] as FormData
        
        expect(formData.get('file')).toBe(mockFile)
      })
    })

    describe('confirmCandidate', () => {
      it('confirms candidate successfully', async () => {
        const mockResponse = { data: mockCandidate }
        mockedAxios.post.mockResolvedValue(mockResponse)

        const result = await cvApi.confirmCandidate(mockCandidate)

        expect(mockedAxios.post).toHaveBeenCalledWith(
          'http://localhost:5050/api/cvupload/confirm',
          mockCandidate
        )
        expect(result).toEqual(mockCandidate)
      })

      it('handles confirmation error', async () => {
        const errorMessage = 'Confirmation failed'
        mockedAxios.post.mockRejectedValue(new Error(errorMessage))

        await expect(cvApi.confirmCandidate(mockCandidate)).rejects.toThrow(errorMessage)
      })
    })
  })

  describe('candidatesApi', () => {
    describe('getCandidates', () => {
      it('fetches candidates with default parameters', async () => {
        const mockResponse = { data: mockCandidateListResponse }
        mockedAxios.get.mockResolvedValue(mockResponse)

        const result = await candidatesApi.getCandidates()

        expect(mockedAxios.get).toHaveBeenCalledWith('/candidates', {
          params: {
            page: 1,
            pageSize: 10,
            search: '',
            sortBy: 'createdAt',
            sortDescending: true
          }
        })
        expect(result).toEqual(mockCandidateListResponse)
      })

      it('fetches candidates with custom parameters', async () => {
        const mockResponse = { data: mockCandidateListResponse }
        mockedAxios.get.mockResolvedValue(mockResponse)

        const result = await candidatesApi.getCandidates(2, 20, 'john', 'fullName', false)

        expect(mockedAxios.get).toHaveBeenCalledWith('/candidates?page=2&pageSize=20&search=john&sortBy=fullName&sortDescending=false')
        expect(result).toEqual(mockCandidateListResponse)
      })

      it('handles fetch error', async () => {
        const errorMessage = 'Fetch failed'
        mockedAxios.get.mockRejectedValue(new Error(errorMessage))

        await expect(candidatesApi.getCandidates()).rejects.toThrow(errorMessage)
      })
    })

    describe('getCandidate', () => {
      it('fetches candidate by ID successfully', async () => {
        const mockResponse = { data: mockCandidate }
        mockedAxios.get.mockResolvedValue(mockResponse)

        const result = await candidatesApi.getCandidate(1)

        expect(mockedAxios.get).toHaveBeenCalledWith('/candidates/1')
        expect(result).toEqual(mockCandidate)
      })

      it('handles fetch by ID error', async () => {
        const errorMessage = 'Candidate not found'
        mockedAxios.get.mockRejectedValue(new Error(errorMessage))

        await expect(candidatesApi.getCandidate(999)).rejects.toThrow(errorMessage)
      })
    })

    describe('updateCandidate', () => {
      it('updates candidate successfully', async () => {
        const updatedCandidate = { ...mockCandidate, fullName: 'Updated Name' }
        const mockResponse = { data: updatedCandidate }
        mockedAxios.put.mockResolvedValue(mockResponse)

        const result = await candidatesApi.updateCandidate(1, updatedCandidate)

        expect(mockedAxios.put).toHaveBeenCalledWith('/candidates/1', updatedCandidate)
        expect(result).toEqual(updatedCandidate)
      })

      it('handles update error', async () => {
        const errorMessage = 'Update failed'
        mockedAxios.put.mockRejectedValue(new Error(errorMessage))

        await expect(candidatesApi.updateCandidate(1, mockCandidate)).rejects.toThrow(errorMessage)
      })
    })

    describe('deleteCandidate', () => {
      it('deletes candidate successfully', async () => {
        mockedAxios.delete.mockResolvedValue({ data: null })

        await candidatesApi.deleteCandidate(1)

        expect(mockedAxios.delete).toHaveBeenCalledWith('/candidates/1')
      })

      it('handles delete error', async () => {
        const errorMessage = 'Delete failed'
        mockedAxios.delete.mockRejectedValue(new Error(errorMessage))

        await expect(candidatesApi.deleteCandidate(1)).rejects.toThrow(errorMessage)
      })
    })

    describe('createCandidate', () => {
      it('creates candidate successfully', async () => {
        const newCandidate = { ...mockCandidate, id: 0 }
        const mockResponse = { data: mockCandidate }
        mockedAxios.post.mockResolvedValue(mockResponse)

        const result = await candidatesApi.createCandidate(newCandidate)

        expect(mockedAxios.post).toHaveBeenCalledWith('/candidates', newCandidate)
        expect(result).toEqual(mockCandidate)
      })

      it('handles create error', async () => {
        const errorMessage = 'Create failed'
        mockedAxios.post.mockRejectedValue(new Error(errorMessage))

        await expect(candidatesApi.createCandidate(mockCandidate)).rejects.toThrow(errorMessage)
      })
    })
  })

  describe('Error handling', () => {
    it('handles network errors', async () => {
      const networkError = new Error('Network Error')
      networkError.name = 'NetworkError'
      mockedAxios.get.mockRejectedValue(networkError)

      await expect(candidatesApi.getCandidates()).rejects.toThrow('Network Error')
    })

    it('handles HTTP error responses', async () => {
      const httpError = {
        response: {
          status: 404,
          data: { message: 'Not Found' }
        }
      }
      mockedAxios.get.mockRejectedValue(httpError)

      await expect(candidatesApi.getCandidateById(999)).rejects.toEqual(httpError)
    })

    it('handles timeout errors', async () => {
      const timeoutError = new Error('timeout of 5000ms exceeded')
      timeoutError.name = 'TimeoutError'
      mockedAxios.post.mockRejectedValue(timeoutError)

      await expect(cvApi.uploadCv(mockFile)).rejects.toThrow('timeout of 5000ms exceeded')
    })
  })

  describe('Request configuration', () => {
    it('uses correct base URL for CV upload', async () => {
      const mockResponse = { data: mockUploadResponse }
      mockedAxios.post.mockResolvedValue(mockResponse)

      await cvApi.uploadCv(mockFile)

      expect(mockedAxios.post).toHaveBeenCalledWith(
        'http://localhost:5050/api/cvupload/upload',
        expect.any(FormData),
        expect.objectContaining({
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        })
      )
    })

    it('uses axios instance for candidates API', async () => {
      const mockResponse = { data: mockCandidateListResponse }
      mockedAxios.get.mockResolvedValue(mockResponse)

      await candidatesApi.getCandidates()

      expect(mockedAxios.get).toHaveBeenCalledWith(
        '/candidates',
        expect.objectContaining({
          params: expect.any(Object)
        })
      )
    })
  })
})