import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { fetchActualPriceData } from '../../services/api';
import { ArrowLeft, Search, RefreshCw, Filter, Inbox, X, ChevronRight } from 'lucide-react';
import '../../App.css';

export default function VerifyBatches() {
    const navigate = useNavigate();
    const [batches, setBatches] = useState([]);
    const [filteredBatches, setFilteredBatches] = useState([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [searchQuery, setSearchQuery] = useState('');
    const [statusFilter, setStatusFilter] = useState('ALL');

    const loadBatches = async () => {
        setLoading(true);
        setError('');
        try {
            const data = await fetchActualPriceData();
            setBatches(data);
            applyFilters(data, searchQuery, statusFilter);
        } catch (err) {
            setError(err.message || 'Failed to load pepper batches.');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        loadBatches();
    }, []);

    const applyFilters = (data, search, status) => {
        let filtered = data;
        const searchLower = search.toLowerCase();

        if (status !== 'ALL') {
            filtered = filtered.filter(b => (b.currentStatus || '').toUpperCase() === status);
        }

        if (searchLower) {
            filtered = filtered.filter(b =>
                (b.batchId && b.batchId.toLowerCase().includes(searchLower)) ||
                (b.district && b.district.toLowerCase().includes(searchLower)) ||
                (b.farmerName && b.farmerName.toLowerCase().includes(searchLower)) ||
                (b.pepperType && b.pepperType.toLowerCase().includes(searchLower))
            );
        }

        setFilteredBatches(filtered);
    };

    useEffect(() => {
        applyFilters(batches, searchQuery, statusFilter);
    }, [searchQuery, statusFilter]);

    const handleSearchChange = (e) => {
        setSearchQuery(e.target.value);
    };

    const clearSearch = () => {
        setSearchQuery('');
    };

    // UI Helpers
    const getStatusColor = (status) => {
        switch ((status || '').toUpperCase()) {
            case 'BATCH_CREATED': return '#3b82f6'; // blue
            case 'MARKETPLACE_LISTED': return '#8b5cf6'; // purple
            case 'VERIFIED': return '#22c55e'; // green
            case 'RECEIVED': return '#f97316'; // orange
            default: return '#64748b'; // slate
        }
    };

    const formatStatus = (status) => {
        switch ((status || '').toUpperCase()) {
            case 'BATCH_CREATED': return 'Batch Created';
            case 'MARKETPLACE_LISTED': return 'Listed';
            case 'VERIFIED': return 'Verified';
            case 'RECEIVED': return 'Received';
            default: return status || 'Unknown';
        }
    };

    const formatDate = (dateString) => {
        if (!dateString) return '-';
        const d = new Date(dateString);
        return d.toISOString().split('T')[0];
    };

    return (
        <div className="dashboard-layout">
            <main className="main-content" style={{ marginLeft: 0, width: '100%' }}>
                <header className="dashboard-header">
                    <div className="header-text" style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                        <button onClick={() => navigate('/blockchain')} className="btn btn-outline" style={{ padding: '0.5rem', borderRadius: '50%' }}>
                            <ArrowLeft size={24} />
                        </button>
                        <div>
                            <p className="greeting">Quality Assurance</p>
                            <h1>Verify Pepper Batches</h1>
                        </div>
                    </div>
                    <button
                        className="btn btn-outline"
                        onClick={loadBatches}
                        disabled={loading}
                        style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}
                    >
                        <RefreshCw size={18} className={loading ? 'spin' : ''} />
                        Refresh
                    </button>
                </header>

                <div className="content-pad">
                    {/* Search & Filters */}
                    <div style={{ marginBottom: '2rem' }}>
                        <div style={{ display: 'flex', gap: '1rem', flexWrap: 'wrap', marginBottom: '1rem' }}>
                            <div style={{ flex: '1 1 300px', position: 'relative' }}>
                                <Search size={20} style={{ position: 'absolute', left: '1rem', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
                                <input
                                    type="text"
                                    className="form-input"
                                    placeholder="Search by Batch ID, Farmer, District..."
                                    value={searchQuery}
                                    onChange={handleSearchChange}
                                    style={{ paddingLeft: '3rem', paddingRight: '3rem' }}
                                />
                                {searchQuery && (
                                    <button
                                        onClick={clearSearch}
                                        style={{ position: 'absolute', right: '1rem', top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-muted)' }}
                                    >
                                        <X size={18} />
                                    </button>
                                )}
                            </div>
                        </div>

                        {/* Filter Chips */}
                        <div style={{ display: 'flex', gap: '0.75rem', flexWrap: 'wrap' }}>
                            {['ALL', 'BATCH_CREATED', 'MARKETPLACE_LISTED', 'VERIFIED'].map(status => (
                                <button
                                    key={status}
                                    onClick={() => setStatusFilter(status)}
                                    style={{
                                        padding: '0.5rem 1rem',
                                        borderRadius: '999px',
                                        border: `1px solid ${statusFilter === status ? getStatusColor(status) : '#e2e8f0'}`,
                                        backgroundColor: statusFilter === status ? `${getStatusColor(status)}15` : 'white',
                                        color: statusFilter === status ? getStatusColor(status) : 'var(--text-color)',
                                        fontWeight: statusFilter === status ? '600' : '500',
                                        cursor: 'pointer',
                                        transition: 'all 0.2s'
                                    }}
                                >
                                    {status === 'ALL' ? 'All' : formatStatus(status)}
                                </button>
                            ))}
                        </div>

                        <div style={{ marginTop: '1rem', fontSize: '0.9rem', color: 'var(--text-muted)' }}>
                            Showing {filteredBatches.length} of {batches.length} batches
                        </div>
                    </div>

                    {/* Results Area */}
                    {loading ? (
                        <div className="loading-screen" style={{ minHeight: '300px' }}>Loading Batches...</div>
                    ) : error ? (
                        <div className="notice-card error">
                            <Filter size={24} />
                            <span>{error}</span>
                        </div>
                    ) : filteredBatches.length === 0 ? (
                        <div style={{ textAlign: 'center', padding: '4rem 2rem', backgroundColor: '#f8fafc', borderRadius: '12px', border: '1px dashed #cbd5e1' }}>
                            <Inbox size={48} color="#94a3b8" style={{ marginBottom: '1rem' }} />
                            <h3>No batches found</h3>
                            <p style={{ color: 'var(--text-muted)' }}>Try adjusting your filters or search keywords.</p>
                        </div>
                    ) : (
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                            {filteredBatches.map(batch => (
                                <div
                                    key={batch._id}
                                    style={{
                                        backgroundColor: 'white',
                                        borderRadius: '12px',
                                        padding: '1.5rem',
                                        boxShadow: '0 4px 6px rgba(0,0,0,0.02)',
                                        border: '1px solid #f1f5f9',
                                        display: 'flex',
                                        alignItems: 'center',
                                        cursor: 'pointer',
                                        transition: 'transform 0.2s, box-shadow 0.2s'
                                    }}
                                    onClick={() => navigate(`/blockchain/verify-batches/${batch._id}`, { state: { batch } })}
                                    onMouseOver={(e) => {
                                        e.currentTarget.style.transform = 'translateY(-2px)';
                                        e.currentTarget.style.boxShadow = '0 10px 15px rgba(0,0,0,0.05)';
                                    }}
                                    onMouseOut={(e) => {
                                        e.currentTarget.style.transform = 'none';
                                        e.currentTarget.style.boxShadow = '0 4px 6px rgba(0,0,0,0.02)';
                                    }}
                                >
                                    <div style={{ flex: 1 }}>
                                        <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '0.75rem' }}>
                                            <h3 style={{ margin: 0, fontSize: '1.1rem' }}>{batch.batchId || 'Unknown Batch'}</h3>
                                            <span style={{
                                                padding: '0.25rem 0.75rem',
                                                borderRadius: '999px',
                                                fontSize: '0.75rem',
                                                fontWeight: '700',
                                                backgroundColor: `${getStatusColor(batch.currentStatus)}15`,
                                                color: getStatusColor(batch.currentStatus)
                                            }}>
                                                {formatStatus(batch.currentStatus)}
                                            </span>
                                            <span style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                                                {formatDate(batch.saleDate)}
                                            </span>
                                        </div>
                                        <div style={{ display: 'flex', gap: '2rem', fontSize: '0.9rem', color: 'var(--text-muted)' }}>
                                            <span><strong>Farmer:</strong> {batch.farmerName || '-'}</span>
                                            <span><strong>Type:</strong> {batch.pepperType || '-'}</span>
                                            <span><strong>District:</strong> {batch.district || '-'}</span>
                                        </div>
                                    </div>
                                    <ChevronRight size={20} color="#cbd5e1" />
                                </div>
                            ))}
                        </div>
                    )}
                </div>
            </main>
        </div>
    );
}
