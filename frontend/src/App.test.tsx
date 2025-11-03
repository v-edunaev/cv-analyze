import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import App from './App';

describe('App Component', () => {
  it('renders navigation bar with logo', () => {
    render(<App />);
    
    const logo = screen.getByText('CV Analyzer');
    expect(logo).toBeInTheDocument();
  });

  it('renders Upload CV navigation link', () => {
    render(<App />);
    
    const uploadLink = screen.getByRole('link', { name: /upload cv/i });
    expect(uploadLink).toBeInTheDocument();
    expect(uploadLink).toHaveAttribute('href', '/');
  });

  it('renders Dashboard navigation link', () => {
    render(<App />);
    
    const dashboardLink = screen.getByRole('link', { name: /dashboard/i });
    expect(dashboardLink).toBeInTheDocument();
    expect(dashboardLink).toHaveAttribute('href', '/dashboard');
  });

  it('renders main content area', () => {
    render(<App />);
    
    const mainContent = screen.getByRole('main');
    expect(mainContent).toBeInTheDocument();
    expect(mainContent).toHaveClass('main-content');
  });

  it('renders toast container for notifications', () => {
    const { container } = render(<App />);
    
    // ToastContainer is rendered but may not be visible until a toast is shown
    // Check if it exists in the DOM
    expect(container.querySelector('.Toastify')).toBeInTheDocument();
  });

  it('renders UploadCv page by default on root route', () => {
    render(<App />);
    
    // UploadCv component should render on the root route - use getByRole to get the specific heading
    const uploadHeading = screen.getByRole('heading', { name: /upload cv/i, level: 1 });
    expect(uploadHeading).toBeInTheDocument();
  });
});
