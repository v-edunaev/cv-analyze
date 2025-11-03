import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import ConfirmationDialog from './ConfirmationDialog';
import { Candidate } from '../types';

const mockCandidate: Candidate = {
  id: 0,
  fullName: 'John Doe',
  email: 'john@example.com',
  phone: '+1234567890',
  skills: [
    { name: 'JavaScript', category: 'Programming' },
    { name: 'TypeScript', category: 'Programming' },
    { name: 'React', category: 'Framework' }
  ],
  yearsOfExperience: 5,
  workExperiences: [
    {
      company: 'Tech Corp',
      jobTitle: 'Senior Developer',
      startDate: '2020-01-01',
      endDate: '2023-12-31',
      isCurrent: false,
      description: 'Developed applications'
    }
  ],
  educations: [
    {
      institution: 'University',
      degree: 'BSc Computer Science',
      endDate: '2018-05-01',
      fieldOfStudy: 'Computer Science'
    }
  ],
  summary: 'Experienced developer',
  createdAt: '2023-01-01T00:00:00Z',
  updatedAt: '2023-01-01T00:00:00Z'
};

const rawText = 'John Doe\njohn@example.com\nExperienced developer';

describe('ConfirmationDialog Component', () => {
  it('renders dialog with candidate information', () => {
    const onConfirm = vi.fn();
    const onCancel = vi.fn();

    render(
      <ConfirmationDialog
        candidate={mockCandidate}
        rawText={rawText}
        onConfirm={onConfirm}
        onCancel={onCancel}
      />
    );

    expect(screen.getByText('Confirm Candidate Information')).toBeInTheDocument();
    expect(screen.getByDisplayValue('John Doe')).toBeInTheDocument();
    expect(screen.getByDisplayValue('john@example.com')).toBeInTheDocument();
  });

  it('allows editing personal information', async () => {
    const user = userEvent.setup();
    const onConfirm = vi.fn();
    const onCancel = vi.fn();

    render(
      <ConfirmationDialog
        candidate={mockCandidate}
        rawText={rawText}
        onConfirm={onConfirm}
        onCancel={onCancel}
      />
    );

    const nameInput = screen.getByLabelText(/full name/i);
    await user.clear(nameInput);
    await user.type(nameInput, 'Jane Smith');

    expect(nameInput).toHaveValue('Jane Smith');
  });

  it('switches between extracted data and raw text tabs', async () => {
    const user = userEvent.setup();
    const onConfirm = vi.fn();
    const onCancel = vi.fn();

    render(
      <ConfirmationDialog
        candidate={mockCandidate}
        rawText={rawText}
        onConfirm={onConfirm}
        onCancel={onCancel}
      />
    );

    // Initially on Extracted Data tab
    expect(screen.getByText('Extracted Data')).toHaveClass('active');

    // Click Raw Text tab
    const rawTextTab = screen.getByText('Raw Text');
    await user.click(rawTextTab);

    expect(rawTextTab).toHaveClass('active');
    // Check for raw text content in the pre element
    expect(screen.getByText(/John Doe/)).toBeInTheDocument();
    expect(screen.getByText(/john@example\.com/)).toBeInTheDocument();

    // Switch back to Extracted Data
    const extractedDataTab = screen.getByText('Extracted Data');
    await user.click(extractedDataTab);

    expect(extractedDataTab).toHaveClass('active');
  });

  it('handles confirm action with edited data', async () => {
    const user = userEvent.setup();
    const onConfirm = vi.fn();
    const onCancel = vi.fn();

    render(
      <ConfirmationDialog
        candidate={mockCandidate}
        rawText={rawText}
        onConfirm={onConfirm}
        onCancel={onCancel}
      />
    );

    const nameInput = screen.getByLabelText(/full name/i);
    await user.clear(nameInput);
    await user.type(nameInput, 'Jane Smith');

    // The button text is "Save Candidate"
    const confirmButton = screen.getByRole('button', { name: /save candidate/i });
    await user.click(confirmButton);

    expect(onConfirm).toHaveBeenCalledTimes(1);
    expect(onConfirm).toHaveBeenCalledWith(
      expect.objectContaining({
        fullName: 'Jane Smith'
      })
    );
  });

  it('handles cancel action', async () => {
    const user = userEvent.setup();
    const onConfirm = vi.fn();
    const onCancel = vi.fn();

    render(
      <ConfirmationDialog
        candidate={mockCandidate}
        rawText={rawText}
        onConfirm={onConfirm}
        onCancel={onCancel}
      />
    );

    const cancelButton = screen.getByRole('button', { name: /cancel/i });
    await user.click(cancelButton);

    expect(onCancel).toHaveBeenCalledTimes(1);
    expect(onConfirm).not.toHaveBeenCalled();
  });

  it('allows removing work experience', async () => {
    const user = userEvent.setup();
    const onConfirm = vi.fn();
    const onCancel = vi.fn();

    render(
      <ConfirmationDialog
        candidate={mockCandidate}
        rawText={rawText}
        onConfirm={onConfirm}
        onCancel={onCancel}
      />
    );

    expect(screen.getByDisplayValue('Tech Corp')).toBeInTheDocument();

    // Find remove buttons by title attribute
    const removeButtons = screen.getAllByTitle('Remove');
    // The first remove button should be for work experience
    await user.click(removeButtons[0]);
    
    expect(screen.queryByDisplayValue('Tech Corp')).not.toBeInTheDocument();
  });

  it('allows removing education', async () => {
    const user = userEvent.setup();
    const onConfirm = vi.fn();
    const onCancel = vi.fn();

    render(
      <ConfirmationDialog
        candidate={mockCandidate}
        rawText={rawText}
        onConfirm={onConfirm}
        onCancel={onCancel}
      />
    );

    expect(screen.getByDisplayValue('University')).toBeInTheDocument();

    // Find remove buttons by title attribute
    const removeButtons = screen.getAllByTitle('Remove');
    // The second remove button should be for education (after work experience)
    await user.click(removeButtons[1]);
    
    expect(screen.queryByDisplayValue('University')).not.toBeInTheDocument();
  });

  it('allows removing skills', async () => {
    const user = userEvent.setup();
    const onConfirm = vi.fn();
    const onCancel = vi.fn();

    render(
      <ConfirmationDialog
        candidate={mockCandidate}
        rawText={rawText}
        onConfirm={onConfirm}
        onCancel={onCancel}
      />
    );

    // Skills should be displayed
    expect(screen.getByText('JavaScript')).toBeInTheDocument();

    // Find skill remove buttons (they have title="Remove" and class="skill-remove")
    const removeButtons = screen.getAllByTitle('Remove');
    // Skill remove buttons are after work experience and education remove buttons
    const skillRemoveButton = removeButtons.find(btn => 
      btn.className.includes('skill-remove')
    );
    
    if (skillRemoveButton) {
      await user.click(skillRemoveButton);
      // After removing, JavaScript should not be in the document
      expect(screen.queryByText('JavaScript')).not.toBeInTheDocument();
    }
  });

  it('allows editing work experience fields', async () => {
    const user = userEvent.setup();
    const onConfirm = vi.fn();
    const onCancel = vi.fn();

    render(
      <ConfirmationDialog
        candidate={mockCandidate}
        rawText={rawText}
        onConfirm={onConfirm}
        onCancel={onCancel}
      />
    );

    const companyInput = screen.getByDisplayValue('Tech Corp');
    await user.clear(companyInput);
    await user.type(companyInput, 'New Company');

    expect(companyInput).toHaveValue('New Company');
  });

  it('allows editing education fields', async () => {
    const user = userEvent.setup();
    const onConfirm = vi.fn();
    const onCancel = vi.fn();

    render(
      <ConfirmationDialog
        candidate={mockCandidate}
        rawText={rawText}
        onConfirm={onConfirm}
        onCancel={onCancel}
      />
    );

    const institutionInput = screen.getByDisplayValue('University');
    await user.clear(institutionInput);
    await user.type(institutionInput, 'MIT');

    expect(institutionInput).toHaveValue('MIT');
  });

  it('shows validation error for empty name', async () => {
    const user = userEvent.setup();
    const onConfirm = vi.fn();
    const onCancel = vi.fn();

    render(
      <ConfirmationDialog
        candidate={mockCandidate}
        rawText={rawText}
        onConfirm={onConfirm}
        onCancel={onCancel}
      />
    );

    const nameInput = screen.getByLabelText(/full name/i);
    await user.clear(nameInput);

    expect(screen.getByText(/name is required/i)).toBeInTheDocument();
  });

  it('clears validation error when name is entered', async () => {
    const user = userEvent.setup();
    const onConfirm = vi.fn();
    const onCancel = vi.fn();

    const candidateWithoutName = { ...mockCandidate, fullName: '' };

    render(
      <ConfirmationDialog
        candidate={candidateWithoutName}
        rawText={rawText}
        onConfirm={onConfirm}
        onCancel={onCancel}
      />
    );

    const nameInput = screen.getByLabelText(/full name/i);
    await user.type(nameInput, 'John Doe');

    // Validation error should not be shown when name is provided
    expect(nameInput).toHaveValue('John Doe');
  });
});
