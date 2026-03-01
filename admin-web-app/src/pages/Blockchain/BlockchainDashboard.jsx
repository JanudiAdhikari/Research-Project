import { useNavigate } from 'react-router-dom';
import { CheckCircle, QrCode, ArrowLeft, Info } from 'lucide-react';
import '../../App.css';

export default function BlockchainDashboard() {
    const navigate = useNavigate();

    return (
        <div className="dashboard-layout">
            <main className="main-content" style={{ marginLeft: 0, width: '100%', padding: '2rem' }}>
                <header className="dashboard-header" style={{ marginBottom: '2rem' }}>
                    <div className="header-text" style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                        <button
                            onClick={() => navigate('/dashboard')}
                            className="btn btn-outline"
                            style={{ padding: '0.5rem', borderRadius: '50%' }}
                        >
                            <ArrowLeft size={24} />
                        </button>
                        <div>
                            <p className="greeting">Blockchain System</p>
                            <h1>Process Management</h1>
                        </div>
                    </div>
                </header>

                <div className="content-pad" style={{ maxWidth: '800px', margin: '0 auto' }}>

                    {/* Information Banner */}
                    <div className="notice-card" style={{
                        backgroundColor: '#f0fdf4',
                        border: '1px solid #bbf7d0',
                        marginBottom: '2rem',
                        display: 'flex',
                        alignItems: 'flex-start',
                        gap: '1rem',
                        padding: '1.5rem',
                        borderRadius: '12px'
                    }}>
                        <Info size={24} color="#166534" style={{ flexShrink: 0 }} />
                        <p style={{ color: '#14532d', margin: 0, lineHeight: 1.5 }}>
                            Please verify pepper batches to ensure QR codes represent for approved products. Tap "Verify Pepper Batches" to proceed.
                        </p>
                    </div>

                    <div className="feature-grid" style={{ gridTemplateColumns: '1fr', gap: '1.5rem' }}>
                        {/* Verify Batches Card */}
                        <div
                            className="feature-card"
                            style={{
                                '--card-color': 'var(--success)',
                                display: 'flex',
                                flexDirection: 'row',
                                alignItems: 'center',
                                gap: '1.5rem',
                                padding: '1.5rem 2rem',
                                minHeight: 'auto'
                            }}
                            onClick={() => navigate('/blockchain/verify-batches')}
                        >
                            <div className="card-icon-wrapper" style={{ margin: 0, width: '60px', height: '60px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                <CheckCircle size={32} />
                            </div>
                            <div style={{ flex: 1, textAlign: 'left' }}>
                                <h3 style={{ margin: '0 0 0.5rem 0', fontSize: '1.25rem' }}>Verify Pepper Batches</h3>
                                <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.95rem' }}>Review submitted batches and mark as verified</p>
                            </div>
                        </div>

                        {/* Generate QR Card */}
                        <div
                            className="feature-card"
                            style={{
                                '--card-color': 'var(--info)',
                                display: 'flex',
                                flexDirection: 'row',
                                alignItems: 'center',
                                gap: '1.5rem',
                                padding: '1.5rem 2rem',
                                minHeight: 'auto'
                            }}
                            onClick={() => navigate('/blockchain/generate-qr')}
                        >
                            <div className="card-icon-wrapper" style={{ margin: 0, width: '60px', height: '60px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                <QrCode size={32} />
                            </div>
                            <div style={{ flex: 1, textAlign: 'left' }}>
                                <h3 style={{ margin: '0 0 0.5rem 0', fontSize: '1.25rem' }}>Generate QR Code</h3>
                                <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '0.95rem' }}>Create QR codes for verified batches</p>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    );
}
