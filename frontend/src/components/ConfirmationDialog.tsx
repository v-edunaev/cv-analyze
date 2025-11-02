import { useState } from 'react';
import { Candidate, WorkExperience, Education } from '../types';
// @ts-ignore: side-effect CSS import has no type declarations
import './ConfirmationDialog.css';

interface ConfirmationDialogProps {
  candidate: Candidate;
  rawText: string;
  onConfirm: (candidate: Candidate) => void;
  onCancel: () => void;
}

function ConfirmationDialog({ candidate, rawText, onConfirm, onCancel }: ConfirmationDialogProps) {
  const [editedCandidate, setEditedCandidate] = useState<Candidate>(candidate);
  const [showRawText, setShowRawText] = useState(false);
  const [validationErrors, setValidationErrors] = useState<{[key: string]: string}>({});

  const handleChange = (field: keyof Candidate, value: any) => {
    setEditedCandidate(prev => ({ ...prev, [field]: value }));
  };

  const handleWorkExperienceChange = (index: number, field: keyof WorkExperience, value: any) => {
    const updated = [...editedCandidate.workExperiences];
    updated[index] = { ...updated[index], [field]: value };
    setEditedCandidate(prev => ({ ...prev, workExperiences: updated }));
  };

  const handleEducationChange = (index: number, field: keyof Education, value: any) => {
    const updated = [...editedCandidate.educations];
    updated[index] = { ...updated[index], [field]: value };
    setEditedCandidate(prev => ({ ...prev, educations: updated }));
  };


  const removeWorkExperience = (index: number) => {
    const updated = editedCandidate.workExperiences.filter((_, i) => i !== index);
    setEditedCandidate(prev => ({ ...prev, workExperiences: updated }));
  };

  const removeEducation = (index: number) => {
    const updated = editedCandidate.educations.filter((_, i) => i !== index);
    setEditedCandidate(prev => ({ ...prev, educations: updated }));
  };

  const removeSkill = (index: number) => {
    const updated = editedCandidate.skills.filter((_, i) => i !== index);
    setEditedCandidate(prev => ({ ...prev, skills: updated }));
  };

  return (
    <div className="dialog-overlay">
      <div className="dialog-content">
        <div className="dialog-header">
          <h2>Confirm Candidate Information</h2>
          <p>Review and edit the extracted information before saving</p>
        </div>

        <div className="dialog-body">
          <div className="tabs">
            <button
              className={`tab ${!showRawText ? 'active' : ''}`}
              onClick={() => setShowRawText(false)}
            >
              Extracted Data
            </button>
            <button
              className={`tab ${showRawText ? 'active' : ''}`}
              onClick={() => setShowRawText(true)}
            >
              Raw Text
            </button>
          </div>

          {showRawText ? (
            <div className="raw-text-container">
              <pre>{rawText}</pre>
            </div>
          ) : (
            <div className="form-container">
              <section className="form-section">
                <h3>Personal Information</h3>
                <div className="form-grid">
                  <div className="form-field">
                    <label htmlFor="fullName">Full Name *</label>
                    <input
                      id="fullName"
                      type="text"
                      value={editedCandidate.fullName}
                      onChange={e => {
                        handleChange('fullName', e.target.value);
                        setValidationErrors(prev => ({ ...prev, fullName: '' }));
                      }}
                      required
                    />
                    {(!editedCandidate.fullName || validationErrors.fullName) && (
                      <div className="error-text">Name is required</div>
                    )}
                  </div>
                  <div className="form-field">
                    <label htmlFor="email">Email *</label>
                    <input
                      id="email"
                      type="email"
                      value={editedCandidate.email}
                      onChange={e => {
                        handleChange('email', e.target.value);
                        setValidationErrors(prev => ({ ...prev, email: '' }));
                      }}
                      required
                    />
                    {(!editedCandidate.email || validationErrors.email) && (
                      <div className="error-text">Email is required</div>
                    )}
                  </div>
                  <div className="form-field">
                    <label>Phone</label>
                    <input
                      type="tel"
                      value={editedCandidate.phone || ''}
                      onChange={e => handleChange('phone', e.target.value)}
                    />
                  </div>
                  <div className="form-field">
                    <label>Address</label>
                    <input
                      type="text"
                      value={editedCandidate.address || ''}
                      onChange={e => handleChange('address', e.target.value)}
                    />
                  </div>
                  <div className="form-field">
                    <label>LinkedIn</label>
                    <input
                      type="url"
                      value={editedCandidate.linkedin || ''}
                      onChange={e => handleChange('linkedin', e.target.value)}
                    />
                  </div>
                  <div className="form-field">
                    <label>GitHub</label>
                    <input
                      type="url"
                      value={editedCandidate.github || ''}
                      onChange={e => handleChange('github', e.target.value)}
                    />
                  </div>
                  <div className="form-field full-width">
                    <label>Summary</label>
                    <textarea
                      rows={3}
                      value={editedCandidate.summary || ''}
                      onChange={e => handleChange('summary', e.target.value)}
                    />
                  </div>
                  <div className="form-field">
                    <label>Years of Experience</label>
                    <input
                      type="number"
                      value={editedCandidate.yearsOfExperience || ''}
                      onChange={e => handleChange('yearsOfExperience', parseInt(e.target.value) || null)}
                    />
                  </div>
                  <div className="form-field">
                    <label>Current Position</label>
                    <input
                      type="text"
                      value={editedCandidate.currentPosition || ''}
                      onChange={e => handleChange('currentPosition', e.target.value)}
                    />
                  </div>
                  <div className="form-field">
                    <label>Current Company</label>
                    <input
                      type="text"
                      value={editedCandidate.currentCompany || ''}
                      onChange={e => handleChange('currentCompany', e.target.value)}
                    />
                  </div>
                </div>
              </section>

              <section className="form-section">
                <h3>Work Experience</h3>
                {editedCandidate.workExperiences.map((exp, index) => (
                  <div key={index} className="item-card">
                    <button
                      className="btn-remove"
                      onClick={() => removeWorkExperience(index)}
                      title="Remove"
                    >
                      ✕
                    </button>
                    <div className="form-grid">
                      <div className="form-field">
                        <label>Job Title</label>
                        <input
                          type="text"
                          value={exp.jobTitle}
                          onChange={e => handleWorkExperienceChange(index, 'jobTitle', e.target.value)}
                        />
                      </div>
                      <div className="form-field">
                        <label>Company</label>
                        <input
                          type="text"
                          value={exp.company}
                          onChange={e => handleWorkExperienceChange(index, 'company', e.target.value)}
                        />
                      </div>
                      <div className="form-field">
                        <label>Start Date</label>
                        <input
                          type="date"
                          value={exp.startDate?.split('T')[0] || ''}
                          onChange={e => handleWorkExperienceChange(index, 'startDate', e.target.value)}
                        />
                      </div>
                      <div className="form-field">
                        <label>End Date</label>
                        <input
                          type="date"
                          value={exp.endDate?.split('T')[0] || ''}
                          onChange={e => handleWorkExperienceChange(index, 'endDate', e.target.value)}
                          disabled={exp.isCurrent}
                        />
                      </div>
                      <div className="form-field full-width">
                        <label>
                          <input
                            type="checkbox"
                            checked={exp.isCurrent}
                            onChange={e => handleWorkExperienceChange(index, 'isCurrent', e.target.checked)}
                          />
                          {' '}Current Position
                        </label>
                      </div>
                    </div>
                  </div>
                ))}
              </section>

              <section className="form-section">
                <h3>Education</h3>
                {editedCandidate.educations.map((edu, index) => (
                  <div key={index} className="item-card">
                    <button
                      className="btn-remove"
                      onClick={() => removeEducation(index)}
                      title="Remove"
                    >
                      ✕
                    </button>
                    <div className="form-grid">
                      <div className="form-field">
                        <label>Degree</label>
                        <input
                          type="text"
                          value={edu.degree}
                          onChange={e => handleEducationChange(index, 'degree', e.target.value)}
                        />
                      </div>
                      <div className="form-field">
                        <label>Institution</label>
                        <input
                          type="text"
                          value={edu.institution}
                          onChange={e => handleEducationChange(index, 'institution', e.target.value)}
                        />
                      </div>
                      <div className="form-field">
                        <label>Field of Study</label>
                        <input
                          type="text"
                          value={edu.fieldOfStudy || ''}
                          onChange={e => handleEducationChange(index, 'fieldOfStudy', e.target.value)}
                        />
                      </div>
                    </div>
                  </div>
                ))}
              </section>

              <section className="form-section">
                <h3>Skills</h3>
                <div className="skills-grid">
                  {editedCandidate.skills.map((skill, index) => (
                    <div key={index} className="skill-chip">
                      <span>{skill.name}</span>
                      <button
                        className="skill-remove"
                        onClick={() => removeSkill(index)}
                        title="Remove"
                      >
                        ✕
                      </button>
                    </div>
                  ))}
                </div>
              </section>
            </div>
          )}
        </div>

        <div className="dialog-footer">
          <button className="btn-secondary" onClick={onCancel}>
            Cancel
          </button>
          <button
            className="btn-primary"
            onClick={() => {
              if (!editedCandidate.fullName || !editedCandidate.email) {
                setValidationErrors({
                  fullName: !editedCandidate.fullName ? 'Name is required' : '',
                  email: !editedCandidate.email ? 'Email is required' : ''
                });
                return;
              }
              onConfirm(editedCandidate);
            }}
          >
            Save Candidate
          </button>
        </div>
      </div>
    </div>
  );
}

export default ConfirmationDialog;
