import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-toastify';
import { cvApi } from '../services/api';
import { Candidate } from '../types';
import ConfirmationDialog from '../components/ConfirmationDialog';
import './UploadCv.css';

function UploadCv() {
  const [file, setFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);
  const [showConfirmation, setShowConfirmation] = useState(false);
  const [extractedData, setExtractedData] = useState<Candidate | null>(null);
  const [rawText, setRawText] = useState<string>('');
  const navigate = useNavigate();

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      setFile(e.target.files[0]);
    }
  };

  const handleUpload = async () => {
    if (!file) {
      toast.error('Please select a file first');
      return;
    }

    setUploading(true);
    try {
      const response = await cvApi.uploadCv(file);
      
      if (response.success && response.candidate) {
        setExtractedData(response.candidate);
        setRawText(response.rawText || '');
        setShowConfirmation(true);
        toast.success('CV processed successfully!');
      } else {
        toast.error(response.message || 'Failed to process CV');
      }
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Error uploading CV');
      console.error('Upload error:', error);
    } finally {
      setUploading(false);
    }
  };

  const handleConfirm = async (candidate: Candidate) => {
    try {
      await cvApi.confirmCandidate(candidate);
      toast.success('Candidate saved successfully!');
      setShowConfirmation(false);
      setFile(null);
      setExtractedData(null);
      navigate('/dashboard');
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Error saving candidate');
      console.error('Save error:', error);
    }
  };

  const handleCancel = () => {
    setShowConfirmation(false);
    setExtractedData(null);
    setRawText('');
  };

  return (
    <div className="upload-cv-page">
      <div className="upload-container">
        <h1>Upload CV</h1>
        <p className="subtitle">
          Upload a CV in PDF, DOCX, DOC, or TXT format. Our AI will automatically extract
          candidate information for you to review.
        </p>

        <div className="upload-card card">
          <div className="file-upload-area">
            <input
              type="file"
              id="cv-file"
              accept=".pdf,.docx,.doc,.txt"
              onChange={handleFileChange}
              className="file-input"
            />
            <label htmlFor="cv-file" className="file-label">
              {file ? (
                <>
                  <div className="file-icon">📄</div>
                  <div className="file-name">{file.name}</div>
                  <div className="file-size">
                    {(file.size / 1024).toFixed(2)} KB
                  </div>
                </>
              ) : (
                <>
                  <div className="upload-icon">📤</div>
                  <div className="upload-text">
                    Click to select a CV file or drag and drop
                  </div>
                  <div className="upload-hint">
                    Supported formats: PDF, DOCX, DOC, TXT
                  </div>
                </>
              )}
            </label>
          </div>

          <button
            className="btn-primary upload-button"
            onClick={handleUpload}
            disabled={!file || uploading}
          >
            {uploading ? (
              <>
                <div className="spinner-small"></div>
                Processing...
              </>
            ) : (
              'Upload and Process CV'
            )}
          </button>
        </div>

        {uploading && (
          <div className="processing-info card">
            <h3>Processing your CV...</h3>
            <p>We're extracting text and analyzing the content with AI. This may take a few moments.</p>
          </div>
        )}
      </div>

      {showConfirmation && extractedData && (
        <ConfirmationDialog
          candidate={extractedData}
          rawText={rawText}
          onConfirm={handleConfirm}
          onCancel={handleCancel}
        />
      )}
    </div>
  );
}

export default UploadCv;
