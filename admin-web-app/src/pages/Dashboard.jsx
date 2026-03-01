import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    LogOut, User, Settings, PieChart, Activity,
    CheckCircle, Database, LayoutDashboard, Share2
} from 'lucide-react';
import '../App.css';

export default function Dashboard() {
    const [userName, setUserName] = useState('Admin');
    const [loading, setLoading] = useState(true);
    const navigate = useNavigate();

    useEffect(() => {
        // Simulate loading user data
        const timer = setTimeout(() => {
            setLoading(false);
        }, 500);
        return () => clearTimeout(timer);
    }, []);

    const handleLogout = () => {
        navigate('/');
    };

    const featureCards = [
        { title: 'Users Management', icon: <User size={32} />, color: 'var(--info)' },
        { title: 'View Reports', icon: <PieChart size={32} />, color: '#0d9488' },
        { title: 'System Analytics', icon: <Activity size={32} />, color: '#ea580c' },
        { title: 'Verify Pepper Batches', icon: <CheckCircle size={32} />, color: 'var(--success)' },
        { title: 'Market Control', icon: <Share2 size={32} />, color: '#9333ea' },
        { title: 'Blockchain Logs', icon: <Database size={32} />, color: 'var(--error)' },
    ];

    if (loading) {
        return <div className="loading-screen">Loading System...</div>;
    }

    return (
        <div className="dashboard-layout">
            {/* Sidebar Navigation */}
            <aside className="sidebar">
                <div className="sidebar-header">
                    <div className="brand-logo-small">
                        <LayoutDashboard size={24} color="#fff" />
                    </div>
                    <h2>Farm Admin</h2>
                </div>

                <nav className="sidebar-nav">
                    <a href="#" className="nav-item active">
                        <LayoutDashboard size={20} />
                        <span>Dashboard</span>
                    </a>
                    <a href="#" className="nav-item">
                        <User size={20} />
                        <span>Profile</span>
                    </a>
                    <a href="#" className="nav-item">
                        <Settings size={20} />
                        <span>Settings</span>
                    </a>
                </nav>

                <div className="sidebar-footer">
                    <button className="logout-btn" onClick={handleLogout}>
                        <LogOut size={20} />
                        <span>Logout</span>
                    </button>
                </div>
            </aside>

            {/* Main Content Area */}
            <main className="main-content">
                {/* Header Ribbon */}
                <header className="dashboard-header">
                    <div className="header-text">
                        <p className="greeting">Hello, {userName} 👋</p>
                        <h1>System Control Panel</h1>
                    </div>

                    <div className="system-status">
                        <div className="status-indicator"></div>
                        <span>System Online</span>
                    </div>
                </header>

                <div className="content-pad">
                    {/* Section Headings */}
                    <div className="section-title">
                        <div className="title-marker"></div>
                        <h2>Management Tools</h2>
                    </div>

                    {/* Feature Grid */}
                    <div className="feature-grid">
                        {featureCards.map((card, idx) => (
                            <div
                                className="feature-card"
                                key={idx}
                                style={{ '--card-color': card.color }}
                            >
                                <div className="card-icon-wrapper">
                                    {card.icon}
                                </div>
                                <h3>{card.title}</h3>
                                <div className="card-bg-icon">
                                    {card.icon}
                                </div>
                            </div>
                        ))}
                    </div>

                    {/* System Notices */}
                    <div className="section-title" style={{ marginTop: '3rem' }}>
                        <div className="title-marker" style={{ backgroundColor: 'var(--text-muted)' }}></div>
                        <h2>System Notices</h2>
                    </div>

                    <div className="notices-list">
                        <div className="notice-card warning">
                            <Activity size={24} />
                            <span>Pending Verification Actions Required</span>
                        </div>
                        <div className="notice-card success">
                            <CheckCircle size={24} />
                            <span>Core Servers Running Optimally</span>
                        </div>
                        <div className="notice-card info">
                            <User size={24} />
                            <span>12 New Registrations Today</span>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    );
}
