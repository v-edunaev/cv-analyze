import { useState, useEffect } from 'react';
import { toast } from 'react-toastify';
import { candidatesApi } from '../services/api';
import { Candidate } from '../types';
import CandidateTable from '../components/CandidateTable';
import CandidateDetailModal from '../components/CandidateDetailModal';
import DeleteConfirmationDialog from '../components/DeleteConfirmationDialog';
import './Dashboard.css';

function Dashboard() {
  const [candidates, setCandidates] = useState<Candidate[]>([]);
  const [loading, setLoading] = useState(true);
  const [totalCount, setTotalCount] = useState(0);
  const [page, setPage] = useState(1);
  const [pageSize] = useState(10);
  const [search, setSearch] = useState('');
  const [sortBy, setSortBy] = useState<string>('createdAt');
  const [sortDescending, setSortDescending] = useState(true);
  const [selectedCandidate, setSelectedCandidate] = useState<Candidate | null>(null);
  const [deleteId, setDeleteId] = useState<number | null>(null);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);

  useEffect(() => {
    fetchCandidates();
  }, [page, search, sortBy, sortDescending]);

  const fetchCandidates = async () => {
    setLoading(true);
    try {
      const response = await candidatesApi.getCandidates(
        page,
        pageSize,
        search,
        sortBy,
        sortDescending
      );
      setCandidates(response.candidates);
      setTotalCount(response.totalCount);
    } catch (error: any) {
      toast.error('Failed to load candidates');
      console.error('Error fetching candidates:', error);
    } finally {
      setLoading(false);
    }
  };

  const handleSort = (column: string) => {
    if (sortBy === column) {
      setSortDescending(!sortDescending);
    } else {
      setSortBy(column);
      setSortDescending(false);
    }
  };

  const handleSearch = (value: string) => {
    setSearch(value);
    setPage(1);
  };

  const handleViewDetails = (candidate: Candidate) => {
    setSelectedCandidate(candidate);
  };

  const handleCloseDetails = () => {
    setSelectedCandidate(null);
  };

  const handleDelete = async (id: number) => {
    setDeleteId(id);
    setShowDeleteConfirm(true);
  };

  const handleDeleteConfirm = async () => {
    if (!deleteId) {return;}
    try {
      await candidatesApi.deleteCandidate(deleteId);
      toast.success('Candidate deleted successfully');
      fetchCandidates();
    } catch (error) {
      toast.error('Error deleting candidate');
      console.error('Error deleting candidate:', error);
    } finally {
      setShowDeleteConfirm(false);
      setDeleteId(null);
    }
  };

  const totalPages = Math.ceil(totalCount / pageSize);

  return (
    <div className="dashboard-page">
      <div className="dashboard-header">
        <h1>Candidates Dashboard</h1>
        <p className="subtitle">
          Manage and review all candidate applications
        </p>
      </div>

      <div className="dashboard-controls card">
        <div className="search-box">
          <input
            type="text"
            placeholder="Search by name, email, position, company, or skills..."
            value={search}
            onChange={e => handleSearch(e.target.value)}
            className="search-input"
          />
        </div>
        <div className="stats">
          <div className="stat">
            <span className="stat-label">Total Candidates:</span>
            <span className="stat-value">{totalCount}</span>
          </div>
        </div>
      </div>

      {loading ? (
        <div className="loading">
          <div className="spinner" data-testid="loading-spinner"></div>
        </div>
      ) : candidates.length > 0 ? (
        <>
          <CandidateTable
            candidates={candidates}
            sortBy={sortBy}
            sortDescending={sortDescending}
            onSort={handleSort}
            onViewDetails={handleViewDetails}
            onDelete={handleDelete}
          />

          {totalPages > 1 && (
            <div className="pagination">
              <button
                className="btn-secondary"
                onClick={() => setPage(p => Math.max(1, p - 1))}
                disabled={page === 1}
              >
                Previous
              </button>
              <span className="page-info">
                Showing {((page - 1) * pageSize) + 1}-{Math.min(page * pageSize, totalCount)} of {totalCount}
              </span>
              <button
                className="btn-secondary"
                onClick={() => setPage(p => Math.min(totalPages, p + 1))}
                disabled={page === totalPages}
              >
                Next
              </button>
            </div>
          )}
        </>
      ) : (
        <div className="empty-state card">
          <div className="empty-icon">📋</div>
          <h3>No candidates found</h3>
          <p>Upload a CV to get started</p>
        </div>
      )}

      {selectedCandidate && (
        <CandidateDetailModal
          candidate={selectedCandidate}
          onClose={handleCloseDetails}
        />
      )}
      {showDeleteConfirm && (
        <DeleteConfirmationDialog
          message="Are you sure you want to delete this candidate?"
          onConfirm={handleDeleteConfirm}
          onCancel={() => {
            setShowDeleteConfirm(false);
            setDeleteId(null);
          }}
        />
      )}
    </div>
  );
}

export default Dashboard;
