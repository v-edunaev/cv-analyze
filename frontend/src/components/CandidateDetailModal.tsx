import { Candidate } from '../types';
import { FaTimes, FaEnvelope, FaPhone, FaMapMarkerAlt, FaLinkedin, FaGithub, FaLink } from 'react-icons/fa';
import './CandidateDetailModal.css';

interface CandidateDetailModalProps {
  candidate: Candidate;
  onClose: () => void;
}

function CandidateDetailModal({ candidate, onClose }: CandidateDetailModalProps) {
  const formatDate = (dateString?: string) => {
    if (!dateString) return 'Present';
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
    });
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={e => e.stopPropagation()}>
        <button className="modal-close" onClick={onClose}>
          <FaTimes />
        </button>

        <div className="modal-header">
          <h2>{candidate.fullName}</h2>
          {candidate.currentPosition && (
            <p className="current-role">
              {candidate.currentPosition}
              {candidate.currentCompany && ` at ${candidate.currentCompany}`}
            </p>
          )}
        </div>

        <div className="modal-body">
          <section className="detail-section">
            <h3>Contact Information</h3>
            <div className="contact-info">
              <div className="contact-item">
                <FaEnvelope className="contact-icon" />
                <a href={`mailto:${candidate.email}`}>{candidate.email}</a>
              </div>
              {candidate.phone && (
                <div className="contact-item">
                  <FaPhone className="contact-icon" />
                  <a href={`tel:${candidate.phone}`}>{candidate.phone}</a>
                </div>
              )}
              {candidate.address && (
                <div className="contact-item">
                  <FaMapMarkerAlt className="contact-icon" />
                  <span>{candidate.address}</span>
                </div>
              )}
              {candidate.linkedin && (
                <div className="contact-item">
                  <FaLinkedin className="contact-icon" />
                  <a href={candidate.linkedin} target="_blank" rel="noopener noreferrer">
                    LinkedIn Profile
                  </a>
                </div>
              )}
              {candidate.github && (
                <div className="contact-item">
                  <FaGithub className="contact-icon" />
                  <a href={candidate.github} target="_blank" rel="noopener noreferrer">
                    GitHub Profile
                  </a>
                </div>
              )}
              {candidate.portfolio && (
                <div className="contact-item">
                  <FaLink className="contact-icon" />
                  <a href={candidate.portfolio} target="_blank" rel="noopener noreferrer">
                    Portfolio
                  </a>
                </div>
              )}
            </div>
          </section>

          {candidate.summary && (
            <section className="detail-section">
              <h3>Professional Summary</h3>
              <p className="summary-text">{candidate.summary}</p>
            </section>
          )}

          {candidate.workExperiences.length > 0 && (
            <section className="detail-section">
              <h3>Work Experience</h3>
              <div className="timeline">
                {candidate.workExperiences.map((exp, index) => (
                  <div key={index} className="timeline-item">
                    <div className="timeline-marker"></div>
                    <div className="timeline-content">
                      <h4>{exp.jobTitle}</h4>
                      <p className="company">{exp.company}</p>
                      <p className="period">
                        {formatDate(exp.startDate)} - {exp.isCurrent ? 'Present' : formatDate(exp.endDate)}
                        {exp.location && ` • ${exp.location}`}
                      </p>
                      {exp.description && (
                        <p className="description">{exp.description}</p>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </section>
          )}

          {candidate.educations.length > 0 && (
            <section className="detail-section">
              <h3>Education</h3>
              <div className="timeline">
                {candidate.educations.map((edu, index) => (
                  <div key={index} className="timeline-item">
                    <div className="timeline-marker"></div>
                    <div className="timeline-content">
                      <h4>{edu.degree}</h4>
                      <p className="company">{edu.institution}</p>
                      {edu.fieldOfStudy && (
                        <p className="field">{edu.fieldOfStudy}</p>
                      )}
                      {(edu.startDate || edu.endDate) && (
                        <p className="period">
                          {formatDate(edu.startDate)} - {formatDate(edu.endDate)}
                        </p>
                      )}
                      {edu.grade && (
                        <p className="grade">Grade: {edu.grade}</p>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </section>
          )}

          {candidate.skills.length > 0 && (
            <section className="detail-section">
              <h3>Skills</h3>
              <div className="skills-container">
                {candidate.skills.map((skill, index) => (
                  <div key={index} className="skill-item">
                    <span className="skill-name">{skill.name}</span>
                    {skill.proficiencyLevel && (
                      <span className="skill-level">{skill.proficiencyLevel}</span>
                    )}
                  </div>
                ))}
              </div>
            </section>
          )}

          <section className="detail-section">
            <h3>Metadata</h3>
            <div className="metadata">
              <p>
                <strong>Added:</strong> {new Date(candidate.createdAt).toLocaleString()}
              </p>
              <p>
                <strong>Last Updated:</strong> {new Date(candidate.updatedAt).toLocaleString()}
              </p>
              {candidate.yearsOfExperience && (
                <p>
                  <strong>Total Experience:</strong> {candidate.yearsOfExperience} years
                </p>
              )}
            </div>
          </section>
        </div>
      </div>
    </div>
  );
}

export default CandidateDetailModal;
