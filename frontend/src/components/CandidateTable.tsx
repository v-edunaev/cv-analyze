import { Candidate } from '../types';
import { FaSort, FaSortUp, FaSortDown, FaEye, FaTrash } from 'react-icons/fa';
import './CandidateTable.css';

interface CandidateTableProps {
  candidates: Candidate[];
  sortBy: string;
  sortDescending: boolean;
  onSort: (column: string) => void;
  onViewDetails: (candidate: Candidate) => void;
  onDelete: (id: number) => void;
}

function CandidateTable({
  candidates,
  sortBy,
  sortDescending,
  onSort,
  onViewDetails,
  onDelete,
}: CandidateTableProps) {
  const getSortIcon = (column: string) => {
    if (sortBy !== column) {
      return <FaSort className="sort-icon" />;
    }
    return sortDescending ? (
      <FaSortDown className="sort-icon active" />
    ) : (
      <FaSortUp className="sort-icon active" />
    );
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    });
  };

  if (candidates.length === 0) {
    return (
      <div className="empty-state card">
        <div className="empty-icon">📋</div>
        <h3>No candidates found</h3>
        <p>Upload a CV to get started</p>
      </div>
    );
  }

  return (
    <div className="table-container card">
      <table className="candidates-table">
        <thead>
          <tr>
            <th onClick={() => onSort('name')}>
              <div className="th-content">
                Name {getSortIcon('name')}
              </div>
            </th>
            <th onClick={() => onSort('email')}>
              <div className="th-content">
                Email {getSortIcon('email')}
              </div>
            </th>
            <th>Phone</th>
            <th>Current Position</th>
            <th>Current Company</th>
            <th onClick={() => onSort('experience')}>
              <div className="th-content">
                Experience {getSortIcon('experience')}
              </div>
            </th>
            <th>Skills</th>
            <th onClick={() => onSort('createdAt')}>
              <div className="th-content">
                Added {getSortIcon('createdAt')}
              </div>
            </th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {candidates.map(candidate => (
            <tr key={candidate.id}>
              <td className="name-cell">
                <strong>{candidate.fullName}</strong>
              </td>
              <td>{candidate.email}</td>
              <td>{candidate.phone || '-'}</td>
              <td>{candidate.currentPosition || '-'}</td>
              <td>{candidate.currentCompany || '-'}</td>
              <td>
                {candidate.yearsOfExperience
                  ? `${candidate.yearsOfExperience} years`
                  : '-'}
              </td>
              <td>
                <div className="skills-preview">
                  {candidate.skills.slice(0, 3).map(skill => (
                    <span key={skill.id} className="skill-badge">
                      {skill.name}
                    </span>
                  ))}
                  {candidate.skills.length > 3 && (
                    <span className="skill-badge more">
                      +{candidate.skills.length - 3}
                    </span>
                  )}
                </div>
              </td>
              <td>{formatDate(candidate.createdAt)}</td>
              <td>
                <div className="action-buttons">
                  <button
                    className="btn-icon btn-view"
                    onClick={() => onViewDetails(candidate)}
                    title="View Details"
                  >
                    <FaEye />
                  </button>
                  <button
                    className="btn-icon btn-delete"
                    onClick={() => onDelete(candidate.id)}
                    title="Delete"
                  >
                    <FaTrash />
                  </button>
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default CandidateTable;
