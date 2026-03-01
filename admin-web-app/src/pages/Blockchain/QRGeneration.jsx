import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { fetchActualPriceData, generateBatchQr } from '../../services/api';
import { ArrowLeft, Search, RefreshCw, QrCode, Inbox, X, FileJson } from 'lucide-react';
import '../../App.css';

export default function QRGeneration() {
    const navigate = useNavigate();
    const [batches, setBatches] = useState([]);
    const [filteredBatches, setFilteredBatches] = useState([]);
    const [loading, setLoading] = useState(true);
    const [actionLoading, setActionLoading] = useState(false);
    const [searchQuery, setSearchQuery] = useState('');
    const [selectedPayload, setSelectedPayload] = useState(null);

    const loadBatches = async (silent = false) => {
        if (!silent) setLoading(true);
        try {
            const data = await fetchActualPriceData();
            // We only want to show VERIFIED batches awaiting QR generation
            const verified = data.filter(r => (r.currentStatus || '').toUpperCase() === 'VERIFIED');
            setBatches(verified);
            applyFilter(verified, searchQuery);
        } catch (err) {
            console.error('Failed to load batches:', err);
        } finally {
            if (!silent) setLoading(false);
        }
    };

    useEffect(() => {
        loadBatches();
    }, []);

    const applyFilter = (data, search) => {
        if (!search) {
            setFilteredBatches(data);
            return;
        }
        const lower = search.toLowerCase();
        setFilteredBatches(data.filter(b => (b.batchId || '').toLowerCase().includes(lower)));
    };

    const handleSearchChange = (e) => {
        const val = e.target.value;
        setSearchQuery(val);
        applyFilter(batches, val);
    };

    const clearSearch = () => {
        setSearchQuery('');
        applyFilter(batches, '');
    };

    const handlePreviewPayload = (batch) => {
        const payload = {
            batchId: batch.batchId || batch._id,
            pepperType: batch.pepperType || '',
            grade: batch.grade || '',
            quantity: batch.quantity || '',
            pricePerKg: batch.pricePerKg || '',
            saleDate: batch.saleDate || '',
            farmer: batch.farmerName || ''
        };
        setSelectedPayload(JSON.stringify(payload, null, 2));
    };

    const handleGenerateQR = async (batch) => {
        if (actionLoading) return;

        if (!window.confirm(`Are you sure you want to generate a QR code for batch ${batch.batchId}?`)) return;

        setActionLoading(true);
        try {
            await generateBatchQr(batch._id);
            // Remove locally and re-apply
            const updated = batches.filter(r => r._id !== batch._id);
            setBatches(updated);
            applyFilter(updated, searchQuery);
            alert(`QR code for batch ${batch.batchId} is ready. You can now share it with the exporter.`);
        } catch (err) {
            alert('Failed to generate QR: ' + (err.message || String(err)));
        } finally {
            setActionLoading(false);
        }
    };

    const formatDate = (dateString) => {
        if (!dateString) return '-';
        return new Date(dateString).toISOString().split('T')[0];
    };

    return (
        <div className="dashboard-layout" style={{ position: 'relative' }}>
            <main className="main-content" style={{ marginLeft: 0, width: '100%', padding: '2rem' }}>
                <header className="dashboard-header" style={{ marginBottom: '2rem' }}>
                    <div className="header-text" style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                        <button onClick={() => navigate('/blockchain')} className="btn btn-outline" style={{ padding: '0.5rem', borderRadius: '50%' }}>
                            <ArrowLeft size={24} />
                        </button>
                        <div>
                            <p className="greeting">QR Sub-System</p>
                            <h1>Generate QR Code</h1>
                        </div>
                    </div>
                    <button
                        className="btn btn-outline"
                        onClick={() => loadBatches()}
                        disabled={loading || actionLoading}
                        style={{ display: 'flex', alignItems: 'center', gap: '0.5rem' }}
                    >
                        <RefreshCw size={18} className={loading ? 'spin' : ''} />
                        Refresh
                    </button>
                </header>

                <div className="content-pad" style={{ maxWidth: '800px', margin: '0 auto' }}>
                    {/* Information Banner */}
                    <div className="notice-card" style={{
                        backgroundColor: '#f8fafc',
                        border: '1px solid #e2e8f0',
                        marginBottom: '1.5rem',
                        display: 'flex',
                        alignItems: 'flex-start',
                        gap: '1rem',
                        padding: '1.25rem',
                        borderRadius: '12px'
                    }}>
                        <QrCode size={24} color="#0EA5E9" style={{ flexShrink: 0 }} />
                        <p style={{ color: '#0f172a', margin: 0, lineHeight: 1.5 }}>
                            Only <strong>verified batches</strong> are shown here. Generate QR codes for exporters to scan into their supply chain systems.
                        </p>
                    </div>

                    {/* Search */}
                    <div style={{ marginBottom: '2rem', position: 'relative' }}>
                        <Search size={20} style={{ position: 'absolute', left: '1rem', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
                        <input
                            type="text"
                            className="form-input"
                            placeholder="Search by Batch No."
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

                    {/* Results Table/List */}
                    {loading ? (
                        <div className="loading-screen" style={{ minHeight: '300px' }}>Scanning Registry...</div>
                    ) : batches.length === 0 ? (
                        <div style={{ textAlign: 'center', padding: '4rem 2rem', backgroundColor: '#f8fafc', borderRadius: '12px', border: '1px dashed #cbd5e1' }}>
                            <Inbox size={48} color="#94a3b8" style={{ marginBottom: '1rem' }} />
                            <h3>No verified batches found</h3>
                            <p style={{ color: 'var(--text-muted)' }}>Approve pending batches before generating QRs.</p>
                        </div>
                    ) : filteredBatches.length === 0 ? (
                        <div style={{ textAlign: 'center', padding: '3rem 2rem' }}>
                            <p style={{ color: 'var(--text-muted)' }}>No batches match "{searchQuery}"</p>
                        </div>
                    ) : (
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                            {filteredBatches.map(batch => (
                                <div key={batch._id} style={{
                                    backgroundColor: 'white',
                                    borderRadius: '12px',
                                    padding: '1.25rem',
                                    border: '1px solid #e2e8f0',
                                    display: 'flex',
                                    alignItems: 'center',
                                    gap: '1.5rem',
                                    boxShadow: '0 2px 4px rgba(0,0,0,0.02)'
                                }}>
                                    <div style={{
                                        width: '6px',
                                        height: '40px',
                                        backgroundColor: 'var(--info)',
                                        borderRadius: '4px'
                                    }}></div>
                                    <div style={{ flex: 1 }}>
                                        <h3 style={{ margin: '0 0 0.25rem 0', fontSize: '1.1rem' }}>{batch.batchId}</h3>
                                        <span style={{ fontSize: '0.85rem', color: 'var(--text-muted)' }}>
                                            Verified on: {formatDate(batch.saleDate)}
                                        </span>
                                    </div>
                                    <div style={{ display: 'flex', gap: '0.5rem' }}>
                                        <button
                                            className="btn-icon"
                                            title="View Payload"
                                            onClick={() => handlePreviewPayload(batch)}
                                            style={{ backgroundColor: '#f1f5f9', color: '#475569', borderRadius: '8px', padding: '0.5rem', border: 'none', cursor: 'pointer' }}
                                        >
                                            <FileJson size={20} />
                                        </button>
                                        <button
                                            className="btn btn-primary"
                                            onClick={() => handleGenerateQR(batch)}
                                            disabled={actionLoading}
                                            style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', backgroundColor: 'var(--info)' }}
                                        >
                                            <QrCode size={18} />
                                            Generate
                                        </button>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </div>
            </main>

            {/* View Payload Modal */}
            {selectedPayload && (
                <div className="modal-overlay" onClick={() => setSelectedPayload(null)}>
                    <div className="modal-content" onClick={e => e.stopPropagation()} style={{ maxWidth: '500px' }}>
                        <div className="modal-header">
                            <h2>QR Payload Preview</h2>
                            <button className="btn-icon" onClick={() => setSelectedPayload(null)}>
                                <X size={20} />
                            </button>
                        </div>
                        <div className="modal-body" style={{ backgroundColor: '#f8fafc', padding: '1.5rem', borderRadius: '8px', overflowX: 'auto' }}>
                            <pre style={{ margin: 0, color: '#334155', fontSize: '0.9rem', whiteSpace: 'pre-wrap', wordBreak: 'break-all' }}>
                                {selectedPayload}
                            </pre>
                        </div>
                        <div className="modal-footer" style={{ marginTop: '1.5rem', display: 'flex', justifyContent: 'flex-end' }}>
                            <button className="btn btn-outline" onClick={() => setSelectedPayload(null)}>Close</button>
                        </div>
                    </div>
                </div>
            )}

            {/* Loading Overlay */}
            {actionLoading && (
                <div style={{
                    position: 'absolute', top: 0, left: 0, right: 0, bottom: 0,
                    backgroundColor: 'rgba(255,255,255,0.7)',
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    zIndex: 1000
                }}>
                    <RefreshCw size={32} className="spin" color="var(--primary)" />
                </div>
            )}
        </div>
    );
}
