import { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { KeyRound, Mail, ArrowLeft, Send, CheckCircle2 } from 'lucide-react';
import '../App.css';

export default function ForgotPassword() {
    const [email, setEmail] = useState('');
    const [isEmailValid, setIsEmailValid] = useState(true);
    const [loading, setLoading] = useState(false);
    const [isSubmitted, setIsSubmitted] = useState(false);
    const navigate = useNavigate();

    const handleSendResetEmail = async (e) => {
        e.preventDefault();

        // Basic validation
        if (!email || !email.includes('@')) {
            setIsEmailValid(false);
            return;
        }

        setIsEmailValid(true);
        setLoading(true);

        try {
            // Simulate API call to auth service
            await new Promise(resolve => setTimeout(resolve, 1000));

            // On success, show confirmation state
            setIsSubmitted(true);
        } catch (err) {
            // Handle error (mock)
            alert("Failed to send reset email. Try again.");
        } finally {
            setLoading(false);
        }
    };

    const handleBackToLogin = () => {
        navigate('/');
    };

    // --- Render Confirmation State ---
    if (isSubmitted) {
        return (
            <div className="login-container">
                <div className="login-right" style={{ flex: '1 1 100%', maxWidth: '100%' }}>
                    <div className="login-card" style={{ maxWidth: '480px', margin: '0 auto', textAlign: 'center' }}>

                        <div className="icon-circle" style={{ backgroundColor: 'var(--success)', margin: '0 auto 2rem' }}>
                            <CheckCircle2 color="#fff" size={40} />
                        </div>

                        <h2 style={{ marginBottom: '1rem' }}>Check Your Email</h2>
                        <p className="login-subtitle" style={{ marginBottom: '2rem' }}>
                            We've sent a password reset link to your email. Please check your inbox and spam folder.
                        </p>

                        <div className="info-box">
                            <span className="info-text">Link expires in 15 minutes</span>
                        </div>

                        <div style={{ marginTop: '2rem' }}>
                            <button
                                type="button"
                                className="btn-primary login-btn"
                                onClick={handleBackToLogin}
                            >
                                <ArrowLeft size={18} />
                                Back to Login
                            </button>

                            <div style={{ marginTop: '1.5rem', fontSize: '0.9rem' }}>
                                <span style={{ color: 'var(--text-muted)' }}>Didn't receive the email? </span>
                                <button
                                    type="button"
                                    className="text-btn"
                                    onClick={() => alert("Reset link sent again!")}
                                >
                                    Resend
                                </button>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
        );
    }

    // --- Render Input State ---
    return (
        <div className="login-container">
            <div className="login-right" style={{ flex: '1 1 100%', maxWidth: '100%' }}>
                <div className="login-card" style={{ maxWidth: '440px', margin: '0 auto' }}>

                    <button onClick={handleBackToLogin} className="back-btn" aria-label="Go back">
                        <ArrowLeft size={20} />
                    </button>

                    <div className="icon-circle" style={{ margin: '1rem 0 2rem' }}>
                        <KeyRound color="var(--primary)" size={40} />
                    </div>

                    <h2>Forgot Password?</h2>
                    <p className="login-subtitle">
                        Enter your email and we'll send you reset instructions
                    </p>

                    <form onSubmit={handleSendResetEmail} className="login-form">

                        <div className="form-group">
                            <label htmlFor="email">Email Address</label>
                            <div className="input-wrapper">
                                <Mail className="input-icon" size={20} />
                                <input
                                    type="email"
                                    id="email"
                                    placeholder="admin@farm.com"
                                    value={email}
                                    onChange={(e) => {
                                        setEmail(e.target.value);
                                        if (!isEmailValid) setIsEmailValid(true);
                                    }}
                                    className={!isEmailValid ? 'input-error' : ''}
                                    required
                                />
                            </div>
                            {!isEmailValid && (
                                <span className="error-text">Please enter a valid email</span>
                            )}
                        </div>

                        <button
                            type="submit"
                            className="btn-primary login-btn"
                            disabled={loading}
                            style={{ marginTop: '2rem' }}
                        >
                            {loading ? 'Sending...' : 'Send Reset Link'}
                            {!loading && <Send size={18} />}
                        </button>
                    </form>

                </div>
            </div>
        </div>
    );
}
