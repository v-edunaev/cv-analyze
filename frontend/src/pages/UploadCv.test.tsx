import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import { describe, it, expect, vi, beforeEach } from 'vitest'
import UploadCv from './UploadCv'
import * as api from '../services/api'
import { mockUploadResponse, mockFile, mockEmptyFile, mockInvalidFile } from '../test/mockData'

// Mock the API
vi.mock('../services/api', () => ({
  cvApi: {
    uploadCv: vi.fn(),
    confirmCandidate: vi.fn()
  }
}))

// Mock react-toastify
vi.mock('react-toastify', () => ({
  toast: {
    success: vi.fn(),
    error: vi.fn(),
    info: vi.fn()
  }
}))

const renderUploadCv = () => {
  return render(
    <MemoryRouter>
      <UploadCv />
    </MemoryRouter>
  )
}

describe('UploadCv Component', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('renders upload form correctly', () => {
    renderUploadCv()
    
    expect(screen.getByText('Upload CV')).toBeInTheDocument()
    expect(screen.getByText('Choose File')).toBeInTheDocument()
    expect(screen.getByText('Supported formats: PDF, DOCX, DOC, TXT')).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /upload and process cv/i })).toBeDisabled()
  })

  it('enables upload button when valid file is selected', async () => {
    const user = userEvent.setup()
    renderUploadCv()
    
    const fileInput = screen.getByLabelText(/choose file/i)
    await user.upload(fileInput, mockFile)
    
    expect(screen.getByRole('button', { name: /upload and process cv/i })).toBeEnabled()
    expect(screen.getByText('test-cv.txt')).toBeInTheDocument()
  })

  it('shows error for invalid file type', async () => {
    const user = userEvent.setup()
    renderUploadCv()
    
    const fileInput = screen.getByLabelText(/choose file/i)
    await user.upload(fileInput, mockInvalidFile)
    
    expect(screen.getByText(/please select a valid file type/i)).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /upload and process cv/i })).toBeDisabled()
  })

  it('shows error for empty file', async () => {
    const user = userEvent.setup()
    renderUploadCv()
    
    const fileInput = screen.getByLabelText(/choose file/i)
    await user.upload(fileInput, mockEmptyFile)
    
    expect(screen.getByText(/file is empty/i)).toBeInTheDocument()
    expect(screen.getByRole('button', { name: /upload and process cv/i })).toBeDisabled()
  })

  it('uploads file successfully and shows confirmation dialog', async () => {
    const user = userEvent.setup()
    const mockUploadCv = vi.mocked(api.cvApi.uploadCv)
    mockUploadCv.mockResolvedValue(mockUploadResponse)
    
    renderUploadCv()
    
    const fileInput = screen.getByLabelText(/choose file/i)
    await user.upload(fileInput, mockFile)
    
    const uploadButton = screen.getByRole('button', { name: /upload and process cv/i })
    await user.click(uploadButton)
    
    await waitFor(() => {
      expect(mockUploadCv).toHaveBeenCalledWith(mockFile)
    })
    
    // Should show confirmation dialog
    await waitFor(() => {
      expect(screen.getByText(/review extracted information/i)).toBeInTheDocument()
      expect(screen.getByDisplayValue('John Smith')).toBeInTheDocument()
      expect(screen.getByDisplayValue('john.smith@email.com')).toBeInTheDocument()
    })
  })

  it('handles upload error gracefully', async () => {
    const user = userEvent.setup()
    const mockUploadCv = vi.mocked(api.cvApi.uploadCv)
    mockUploadCv.mockRejectedValue(new Error('Upload failed'))
    
    renderUploadCv()
    
    const fileInput = screen.getByLabelText(/choose file/i)
    await user.upload(fileInput, mockFile)
    
    const uploadButton = screen.getByRole('button', { name: /upload and process cv/i })
    await user.click(uploadButton)
    
    await waitFor(() => {
      expect(mockUploadCv).toHaveBeenCalledWith(mockFile)
    })
    
    // Should show error message
    await waitFor(() => {
      expect(screen.getByText(/failed to upload cv/i)).toBeInTheDocument()
    })
  })

  it('shows loading state during upload', async () => {
    const user = userEvent.setup()
    const mockUploadCv = vi.mocked(api.cvApi.uploadCv)
    
    // Create a promise that we can control
    let resolveUpload: (value: any) => void
    const uploadPromise = new Promise((resolve) => {
      resolveUpload = resolve
    })
    mockUploadCv.mockReturnValue(uploadPromise)
    
    renderUploadCv()
    
    const fileInput = screen.getByLabelText(/choose file/i)
    await user.upload(fileInput, mockFile)
    
    const uploadButton = screen.getByRole('button', { name: /upload and process cv/i })
    await user.click(uploadButton)
    
    // Should show loading state
    expect(screen.getByText(/uploading/i)).toBeInTheDocument()
    expect(uploadButton).toBeDisabled()
    
    // Resolve the promise
    resolveUpload!(mockUploadResponse)
    
    await waitFor(() => {
      expect(screen.queryByText(/uploading/i)).not.toBeInTheDocument()
    })
  })

  it('allows editing candidate information in confirmation dialog', async () => {
    const user = userEvent.setup()
    const mockUploadCv = vi.mocked(api.cvApi.uploadCv)
    const mockConfirmCandidate = vi.mocked(api.cvApi.confirmCandidate)
    
    mockUploadCv.mockResolvedValue(mockUploadResponse)
    mockConfirmCandidate.mockResolvedValue(mockUploadResponse.candidate!)
    
    renderUploadCv()
    
    const fileInput = screen.getByLabelText(/choose file/i)
    await user.upload(fileInput, mockFile)
    
    const uploadButton = screen.getByRole('button', { name: /upload and process cv/i })
    await user.click(uploadButton)
    
    await waitFor(() => {
      expect(screen.getByDisplayValue('John Smith')).toBeInTheDocument()
    })
    
    // Edit the name
    const nameInput = screen.getByDisplayValue('John Smith')
    await user.clear(nameInput)
    await user.type(nameInput, 'John Updated Smith')
    
    // Save the candidate
    const saveButton = screen.getByRole('button', { name: /save candidate/i })
    await user.click(saveButton)
    
    await waitFor(() => {
      expect(mockConfirmCandidate).toHaveBeenCalledWith(
        expect.objectContaining({
          fullName: 'John Updated Smith'
        })
      )
    })
  })

  it('validates required fields in confirmation dialog', async () => {
    const user = userEvent.setup()
    const mockUploadCv = vi.mocked(api.cvApi.uploadCv)
    
    mockUploadCv.mockResolvedValue(mockUploadResponse)
    
    renderUploadCv()
    
    const fileInput = screen.getByLabelText(/choose file/i)
    await user.upload(fileInput, mockFile)
    
    const uploadButton = screen.getByRole('button', { name: /upload and process cv/i })
    await user.click(uploadButton)
    
    await waitFor(() => {
      expect(screen.getByDisplayValue('John Smith')).toBeInTheDocument()
    })
    
    // Clear required fields
    const nameInput = screen.getByDisplayValue('John Smith')
    const emailInput = screen.getByDisplayValue('john.smith@email.com')
    
    await user.clear(nameInput)
    await user.clear(emailInput)
    
    const saveButton = screen.getByRole('button', { name: /save candidate/i })
    await user.click(saveButton)
    
    // Should show validation errors
    expect(screen.getByText(/name is required/i)).toBeInTheDocument()
    expect(screen.getByText(/email is required/i)).toBeInTheDocument()
  })
})