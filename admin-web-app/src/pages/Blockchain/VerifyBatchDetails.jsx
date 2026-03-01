import { useState, useEffect } from 'react';
import { useLocation, useNavigate, useParams } from 'react-router-dom';
import { getQualityChecksByBatch, verifyBatchRecord } from '../../services/api';
import { ArrowLeft, RefreshCw, CheckCircle, Info, Activity, XCircle, Droplets, MapPin, DollarSign, Target, Package } from 'lucide-react';
import '../../App.css';

export default function VerifyBatchDetails() {
    const { state } = useLocation();
    const navigate = useNavigate();
    const { batchId } = useParams();

    const [batch, setBatch] = useState(state?.batch || null);
    const [qualityChecks, setQualityChecks] = useState([]);
    const [loadingQc, setLoadingQc] = useState(true);
    const [verifying, setVerifying] = useState(false);
    const [error, setError] = useState('');

    const loadQualityChecks = async () => {
        if (!batch || !batch.batchId) return;
        setLoadingQc(true);
        setError('');
        try {
            const checks = await getQualityChecksByBatch(batch.batchId);
            setQualityChecks(checks || []);
        } catch (err) {
            setError(err.message || 'Failed to load quality checks.');
        } finally {
            setLoadingQc(false);
        }
    };

    useEffect(() => {
        if (!batch) {
            // Ideally fetch by ID if state is empty, but relying on nav state for now
            navigate('/blockchain/verify-batches');
        } else {
            loadQualityChecks();
        }
    }, [batch]);

    const handleVerify = async () => {
        if (verifying || isAlreadyVerified || isQrGenerated) return;

        setVerifying(true);
        try {
            const updated = await verifyBatchRecord(batch._id);
            setBatch(prev => ({
                ...prev,
                currentStatus: updated.currentStatus || 'VERIFIED',
                statusHistory: updated.statusHistory,
                marketplaceProductId: updated.marketplaceProductId
            }));
            alert('Batch Verified Successfully!');
        } catch (err) {
            alert('Verify failed: ' + (err.message || 'Unknown Error'));
        } finally {
            setVerifying(false);
        }
    };

    if (!batch) return null;

    const isAlreadyVerified = batch.currentStatus === 'VERIFIED';
    const isQrGenerated = batch.currentStatus === 'QR_GENERATED';

    const formatDate = (dateString) => {
        if (!dateString) return '-';
        return new Date(dateString).toISOString().split('T')[0];
    };

    const getStatusColor = (status) => {
        switch ((status || '').toUpperCase()) {
            case 'BATCH_CREATED': return '#3b82f6';
            case 'MARKETPLACE_LISTED': return '#8b5cf6';
            case 'VERIFIED': return '#22c55e';
            case 'RECEIVED': return '#f97316';
            default: return '#64748b';
        }
    };

    return (
        <div className="dashboard-layout">
            <main className="main-content" style={{ marginLeft: 0, width: '100%', padding: '2rem' }}>
                <header className="dashboard-header" style={{ marginBottom: '2rem' }}>
                    <div className="header-text" style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                        <button onClick={() => navigate(-1)} className="btn btn-outline" style={{ padding: '0.5rem', borderRadius: '50%' }}>
                            <ArrowLeft size={24} />
                        </button>
                        <div>
                            <p className="greeting">Batch Details</p>
                            <h1>{batch.batchId || 'Unknown Batch'}</h1>
                        </div>
                    </div>

                    <button
                        className="btn btn-primary"
                        style={{
                            display: 'flex',
                            alignItems: 'center',
                            gap: '0.5rem',
                            backgroundColor: (isAlreadyVerified || isQrGenerated) ? '#94a3b8' : 'var(--success)',
                            cursor: (isAlreadyVerified || isQrGenerated || verifying) ? 'not-allowed' : 'pointer',
                            opacity: (isAlreadyVerified || isQrGenerated) ? 0.8 : 1
                        }}
                        onClick={handleVerify}
                        disabled={isAlreadyVerified || isQrGenerated || verifying}
                    >
                        {verifying ? (
                            <><RefreshCw className="spin" size={20} /> Verifying...</>
                        ) : isAlreadyVerified ? (
                            <><CheckCircle size={20} /> Verified</>
                        ) : isQrGenerated ? (
                            <><CheckCircle size={20} /> QR Generated</>
                        ) : (
                            <><CheckCircle size={20} /> Verify Batch</>
                        )}
                    </button>
                </header>

                <div className="content-pad" style={{ maxWidth: '1000px', margin: '0 auto', display: 'grid', gridTemplateColumns: 'minmax(0, 2fr) minmax(0, 1fr)', gap: '2rem' }}>

                    {/* Left Column - Details */}
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
                        {/* Summary Card */}
                        <div className="feature-card" style={{ '--card-color': getStatusColor(batch.currentStatus), padding: '1.5rem', minHeight: 'auto', cursor: 'default' }}>
                            <div style={{ display: 'flex', alignItems: 'flex-start', gap: '1.5rem' }}>
                                <div style={{
                                    width: '60px', height: '60px',
                                    backgroundColor: `${getStatusColor(batch.currentStatus)}15`,
                                    color: getStatusColor(batch.currentStatus),
                                    borderRadius: '12px', display: 'flex', alignItems: 'center', justifyContent: 'center'
                                }}>
                                    <Info size={32} />
                                </div>
                                <div style={{ flex: 1, paddingRight: '2rem' }}>
                                    <h3 style={{ margin: '0 0 0.5rem 0', fontSize: '1.25rem' }}>Batch Status</h3>
                                    <p style={{ margin: 0, color: 'var(--text-muted)' }}>
                                        Currently marked as <strong>{batch.currentStatus || 'Unknown'}</strong>. Sale date recorded as {formatDate(batch.saleDate)}.
                                    </p>
                                </div>
                            </div>
                        </div>

                        {/* Metrics Grid */}
                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '1.5rem' }}>
                            <div className="metric-box">
                                <DollarSign size={20} color="#0d9488" />
                                <div>
                                    <div className="metric-label">Price / Kg</div>
                                    <div className="metric-value">LKR {batch.pricePerKg?.toFixed(2) || '-'}</div>
                                </div>
                            </div>
                            <div className="metric-box">
                                <Package size={20} color="#ea580c" />
                                <div>
                                    <div className="metric-label">Quantity</div>
                                    <div className="metric-value">{batch.quantity?.toFixed(2) || '-'} Kg</div>
                                </div>
                            </div>
                            <div className="metric-box">
                                <MapPin size={20} color="#3b82f6" />
                                <div>
                                    <div className="metric-label">District</div>
                                    <div className="metric-value">{batch.district || '-'}</div>
                                </div>
                            </div>
                            <div className="metric-box">
                                <Target size={20} color="#8b5cf6" />
                                <div>
                                    <div className="metric-label">Pepper Type & Grade</div>
                                    <div className="metric-value">{batch.pepperType || '-'} • {batch.grade || '-'}</div>
                                </div>
                            </div>
                        </div>

                        {/* Notes */}
                        {batch.notes && (
                            <div style={{ backgroundColor: '#fff', borderRadius: '12px', padding: '1.5rem', border: '1px solid #e2e8f0' }}>
                                <h4 style={{ margin: '0 0 0.5rem 0', display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                                    <Info size={18} /> Notes
                                </h4>
                                <p style={{ margin: 0, color: 'var(--text-muted)', lineHeight: 1.6 }}>{batch.notes}</p>
                            </div>
                        )}
                    </div>

                    {/* Right Column - Quality Checks */}
                    <div>
                        <div style={{ backgroundColor: '#fff', borderRadius: '12px', padding: '1.5rem', border: '1px solid #e2e8f0', height: '100%' }}>
                            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '1.5rem' }}>
                                <h3 style={{ margin: 0, display: 'flex', alignItems: 'center', gap: '0.5rem' }}>
                                    <Activity size={20} color="var(--primary)" />
                                    Quality Checks
                                </h3>
                                <button onClick={loadQualityChecks} className="btn-icon" style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-muted)' }}>
                                    <RefreshCw size={18} className={loadingQc ? 'spin' : ''} />
                                </button>
                            </div>

                            {loadingQc ? (
                                <div style={{ textAlign: 'center', padding: '2rem 0', color: 'var(--text-muted)' }}>
                                    <RefreshCw className="spin" size={24} style={{ marginBottom: '1rem' }} />
                                    <p>Loading quality data...</p>
                                </div>
                            ) : error ? (
                                <div className="notice-card error" style={{ padding: '1rem' }}>
                                    <XCircle size={20} />
                                    <span style={{ fontSize: '0.9rem' }}>{error}</span>
                                </div>
                            ) : qualityChecks.length === 0 ? (
                                <div style={{ textAlign: 'center', padding: '3rem 1rem', backgroundColor: '#f8fafc', borderRadius: '8px', border: '1px dashed #cbd5e1' }}>
                                    <Info size={32} color="#94a3b8" style={{ marginBottom: '0.5rem' }} />
                                    <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.95rem' }}>No quality checks found for this batch.</p>
                                </div>
                            ) : (
                                <div style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
                                    {qualityChecks.map((qc, i) => (
                                        <div key={i} style={{ backgroundColor: '#f8fafc', border: '1px solid #e2e8f0', borderRadius: '8px', padding: '1.25rem' }}>
                                            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '1rem' }}>
                                                <span style={{
                                                    backgroundColor: '#14b8a6',
                                                    color: 'white',
                                                    padding: '0.2rem 0.6rem',
                                                    borderRadius: '4px',
                                                    fontSize: '0.75rem',
                                                    fontWeight: 'bold'
                                                }}>
                                                    QC LOG
                                                </span>
                                                <span style={{ fontWeight: 'bold', color: '#0f766e' }}>
                                                    Result: {qc.result || qc.grade || 'N/A'}
                                                </span>
                                            </div>

                                            <div style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem', fontSize: '0.9rem' }}>
                                                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                                                    <span style={{ color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: '0.5rem' }}><Activity size={16} /> Density</span>
                                                    <span style={{ fontWeight: '600' }}>
                                                        {qc.density?.value ? `${Number(qc.density.value).toFixed(2)} g/L` : (qc.density || '-')}
                                                    </span>
                                                </div>
                                                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                                                    <span style={{ color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: '0.5rem' }}><Droplets size={16} /> Moisture</span>
                                                    <span style={{ fontWeight: '600' }}>{qc.moisture || '-'}</span>
                                                </div>
                                                <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                                                    <span style={{ color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: '0.5rem' }}><XCircle size={16} /> Defects</span>
                                                    <span style={{ fontWeight: '600' }}>{qc.defectRate || qc.defects || '-'}</span>
                                                </div>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </div>
                    </div>

                </div>
            </main>
        </div>
    );
}
