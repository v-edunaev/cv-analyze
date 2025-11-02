import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { MemoryRouter } from 'react-router-dom'
import { describe, it, expect, vi, beforeEach } from 'vitest'
import Dashboard from './Dashboard'
import * as api from '../services/api'
import { mockCandidateListResponse } from '../test/mockData'

// Mock the API
vi.mock('../services/api', () => ({
  candidatesApi: {
    getCandidates: vi.fn(),
    deleteCandidate: vi.fn()
  }
}))

import { toast } from 'react-toastify'

// Mock react-toastify
vi.mock('react-toastify', () => ({
  toast: {
    success: vi.fn(),
    error: vi.fn(),
    info: vi.fn()
  }
}))

const renderDashboard = () => {
  return render(
    <MemoryRouter>
      <Dashboard />
    </MemoryRouter>
  )
}

describe('Dashboard Component', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('renders dashboard correctly', async () => {
    const mockGetCandidates = vi.mocked(api.candidatesApi.getCandidates)
    mockGetCandidates.mockResolvedValue(mockCandidateListResponse)
    
    renderDashboard()
    
    expect(screen.getByText('Candidates Dashboard')).toBeInTheDocument()
    expect(screen.getByPlaceholderText(/search by name/i)).toBeInTheDocument()
    
    await waitFor(() => {
      expect(screen.getByText('John Smith')).toBeInTheDocument()
      expect(screen.getByText('Jane Doe')).toBeInTheDocument()
    })
  })

  it('loads candidates on mount', async () => {
    const mockGetCandidates = vi.mocked(api.candidatesApi.getCandidates)
    mockGetCandidates.mockResolvedValue(mockCandidateListResponse)
    
    renderDashboard()
    
    await waitFor(() => {
      expect(mockGetCandidates).toHaveBeenCalledWith(
        1, 10, '', 'createdAt', true
      )
    })
  })

  it('filters candidates by search term', async () => {
    const user = userEvent.setup()
    const mockGetCandidates = vi.mocked(api.candidatesApi.getCandidates)
    mockGetCandidates.mockResolvedValue(mockCandidateListResponse)
    
    renderDashboard()
    
    await waitFor(() => {
      expect(screen.getByText('John Smith')).toBeInTheDocument()
    })
    
    const searchInput = screen.getByPlaceholderText(/search by name/i)
    await user.type(searchInput, 'jane')
    
    await waitFor(() => {
      expect(mockGetCandidates).toHaveBeenCalledWith(
        1, 10, 'jane', 'createdAt', true
      )
    })
  })

  it('sorts candidates by column', async () => {
    const user = userEvent.setup()
    const mockGetCandidates = vi.mocked(api.candidatesApi.getCandidates)
    mockGetCandidates.mockResolvedValue(mockCandidateListResponse)
    
    renderDashboard()
    
    await waitFor(() => {
      expect(screen.getByText('John Smith')).toBeInTheDocument()
    })
    
    // Click on Name column header to sort
    const nameHeader = screen.getByText('Name')
    await user.click(nameHeader)
    
    await waitFor(() => {
      expect(mockGetCandidates).toHaveBeenCalledWith(
        1, 10, '', 'name', false
      )
    })
  })

  it('shows candidate details modal', async () => {
    const user = userEvent.setup()
    const mockGetCandidates = vi.mocked(api.candidatesApi.getCandidates)
    mockGetCandidates.mockResolvedValue(mockCandidateListResponse)
    
    renderDashboard()
    
    await waitFor(() => {
      expect(screen.getByText('John Smith')).toBeInTheDocument()
    })
    
    // Click on view details button
    const viewButtons = screen.getAllByRole('button', { name: /view details/i })
    await user.click(viewButtons[0])
    
    // Should show modal with candidate details
    await waitFor(() => {
      expect(screen.getByText('Contact Information')).toBeInTheDocument()
      expect(screen.queryAllByText('john.smith@email.com')).toHaveLength(2) // One in table, one in modal
    })
  })

  it('deletes candidate with confirmation', async () => {
    const user = userEvent.setup()
    const mockGetCandidates = vi.mocked(api.candidatesApi.getCandidates)
    const mockDeleteCandidate = vi.mocked(api.candidatesApi.deleteCandidate)
    
    mockGetCandidates.mockResolvedValue(mockCandidateListResponse)
    mockDeleteCandidate.mockResolvedValue(undefined)
    
    renderDashboard()
    
    await waitFor(() => {
      expect(screen.getByText('John Smith')).toBeInTheDocument()
    })
    
    // Click on delete button
    const deleteButtons = screen.getAllByRole('button', { name: /delete/i })
    await user.click(deleteButtons[0])
    
    // Should show confirmation dialog
    await waitFor(() => {
      expect(screen.getByText(/are you sure you want to delete/i)).toBeInTheDocument()
    })
    
    // Confirm deletion
    const confirmButton = screen.getByRole('button', { name: /confirm/i })
    await user.click(confirmButton)
    
    await waitFor(() => {
      expect(mockDeleteCandidate).toHaveBeenCalledWith(1)
    })
  })

  it('handles loading state', async () => {
    const mockGetCandidates = vi.mocked(api.candidatesApi.getCandidates)
    
    // Create a promise that we can control
    let resolveCandidates!: (value: typeof mockCandidateListResponse) => void
    const candidatesPromise = new Promise<typeof mockCandidateListResponse>((resolve) => {
      resolveCandidates = resolve
    })
    mockGetCandidates.mockReturnValue(candidatesPromise)
    
    renderDashboard()
    
    // Should show loading state
    expect(screen.getByTestId('loading-spinner')).toBeInTheDocument()
    
    // Resolve the promise
    resolveCandidates!(mockCandidateListResponse)
    
    await waitFor(() => {
      expect(screen.queryByTestId('loading-spinner')).not.toBeInTheDocument()
      expect(screen.getByText('John Smith')).toBeInTheDocument()
    })
  })

  it('handles error state', async () => {
    const mockGetCandidates = vi.mocked(api.candidatesApi.getCandidates)
    mockGetCandidates.mockRejectedValue(new Error('Failed to load candidates'))
    
    renderDashboard()
    
    await waitFor(() => {
      expect(toast.error).toHaveBeenCalledWith('Failed to load candidates')
    })
  })

  it('handles empty state', async () => {
    const mockGetCandidates = vi.mocked(api.candidatesApi.getCandidates)
    mockGetCandidates.mockResolvedValue({
      candidates: [],
      totalCount: 0,
      page: 1,
      pageSize: 10
    })
    
    renderDashboard()
    
    await waitFor(() => {
      expect(screen.getByText(/no candidates found/i)).toBeInTheDocument()
    })
  })

  it('paginates results correctly', async () => {
    const user = userEvent.setup()
    const mockGetCandidates = vi.mocked(api.candidatesApi.getCandidates)
    
    // Mock response with more candidates for pagination
    const paginatedResponse = {
      ...mockCandidateListResponse,
      totalCount: 25,
      page: 1
    }
    mockGetCandidates.mockResolvedValue(paginatedResponse)
    
    renderDashboard()
    
    await waitFor(() => {
      expect(screen.getByText('John Smith')).toBeInTheDocument()
    })
    
    // Should show pagination controls
    expect(screen.getByText(/showing.*of 25/i)).toBeInTheDocument()
    
    // Click next page
    const nextButton = screen.getByRole('button', { name: /next/i })
    await user.click(nextButton)
    
    await waitFor(() => {
      expect(mockGetCandidates).toHaveBeenCalledWith(
        2, 10, '', 'createdAt', true
      )
    })
  })
})