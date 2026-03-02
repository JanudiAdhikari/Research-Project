import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { fetchActualPriceData, generateBatchQr } from "../../services/api";
import {
  ArrowLeft,
  Search,
  RefreshCw,
  QrCode,
  Inbox,
  X,
  FileJson,
  ShieldCheck,
  CheckCircle,
} from "lucide-react";
import "../../App.css";

export default function QRGeneration() {
  const navigate = useNavigate();
  const [batches, setBatches] = useState([]);
  const [filteredBatches, setFilteredBatches] = useState([]);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedPayload, setSelectedPayload] = useState(null);

  const loadBatches = async (silent = false) => {
    if (!silent) setLoading(true);
    try {
      const data = await fetchActualPriceData();
      // We only want to show VERIFIED batches awaiting QR generation
      const verified = data.filter(
        (r) => (r.currentStatus || "").toUpperCase() === "VERIFIED",
      );
      setBatches(verified);
      applyFilter(verified, searchQuery);
    } catch (err) {
      console.error("Failed to load batches:", err);
    } finally {
      if (!silent) setLoading(false);
    }
  };

  useEffect(() => {
    loadBatches();
  }, []);

  // Applies search filter to the given data and updates filteredBatches
  const applyFilter = (data, search) => {
    if (!search) {
      setFilteredBatches(data);
      return;
    }
    const lower = search.toLowerCase();
    setFilteredBatches(
      data.filter((b) => (b.batchId || "").toLowerCase().includes(lower)),
    );
  };

  // Handles search input changes
  const handleSearchChange = (e) => {
    const val = e.target.value;
    setSearchQuery(val);
    applyFilter(batches, val);
  };

  // Clears search input and resets filter
  const clearSearch = () => {
    setSearchQuery("");
    applyFilter(batches, "");
  };

  // Prepares the payload for QR code generation and shows it in a modal
  const handlePreviewPayload = (batch) => {
    const payload = {
      batchId: batch.batchId || batch._id,
      pepperType: batch.pepperType || "",
      grade: batch.grade || "",
      quantity: batch.quantity || "",
      pricePerKg: batch.pricePerKg || "",
      saleDate: batch.saleDate || "",
      farmer: batch.farmerName || "",
    };
    setSelectedPayload(JSON.stringify(payload, null, 2));
  };

  const handleGenerateQR = async (batch) => {
    if (actionLoading) return;

    if (
      !window.confirm(
        `Are you sure you want to generate a QR code for batch ${batch.batchId}?`,
      )
    )
      return;

    setActionLoading(true);
    try {
      await generateBatchQr(batch._id);
      // Remove locally and re-apply
      const updated = batches.filter((r) => r._id !== batch._id);
      setBatches(updated);
      applyFilter(updated, searchQuery);
      alert(
        `QR code for batch ${batch.batchId} is ready. You can now share it with the exporter.`,
      );
    } catch (err) {
      alert("Failed to generate QR: " + (err.message || String(err)));
    } finally {
      setActionLoading(false);
    }
  };

  // Function to format the date as dd/mm/yyyy
  const formatDate = (dateString) => {
    if (!dateString) return "-";

    const d = new Date(dateString);

    const day = String(d.getDate()).padStart(2, "0");
    const month = String(d.getMonth() + 1).padStart(2, "0"); // Months are 0-based
    const year = d.getFullYear();

    return `${day}/${month}/${year}`;
  };

  return (
    <div className="dashboard-layout" style={{ position: "relative" }}>
      {/* Sidebar */}
      <aside className="sidebar">
        <div className="sidebar-header">
          <div className="brand-logo-small">
            <ShieldCheck size={24} color="#fff" />
          </div>
          <h2>Admin Portal</h2>
        </div>

        <nav className="sidebar-nav">
          <div
            className="nav-item"
            onClick={() => navigate("/dashboard")}
            style={{ cursor: "pointer" }}
          >
            <ArrowLeft size={20} />
            <span>Back to Dashboard</span>
          </div>

          <div
            className="nav-item"
            onClick={() => navigate("/blockchain")}
            style={{ cursor: "pointer" }}
          >
            <CheckCircle size={20} />
            <span>Blockchain System</span>
          </div>

          <div className="nav-item active">
            <QrCode size={20} />
            <span>Generate QR</span>
          </div>

          <div
            className="nav-item"
            onClick={() => navigate("/blockchain/verify-batches")}
            style={{ cursor: "pointer" }}
          >
            <CheckCircle size={20} />
            <span>Verify Batches</span>
          </div>
        </nav>
      </aside>

      {/* Main Section */}
      <main className="main-content">
        <header
          className="dashboard-header"
          style={{ marginBottom: "1.25rem" }}
        >
          <div
            className="header-text"
            style={{ display: "flex", alignItems: "center", gap: "1rem" }}
          >
            <button
              onClick={() => navigate("/blockchain")}
              className="btn btn-outline"
              style={{
                padding: "0.6rem",
                borderRadius: "14px",
                background: "white",
                border: "1px solid #e5e7eb",
                boxShadow: "0 6px 16px rgba(0,0,0,0.06)",
              }}
              title="Back"
            >
              <ArrowLeft size={22} />
            </button>
            <div>
              <p className="greeting" style={{ marginBottom: 2 }}>
                QR Sub-System
              </p>
              <h1 style={{ margin: 0 }}>Generate QR Code</h1>
            </div>
          </div>
        </header>

        <div className="content-pad" style={{ maxWidth: "900px" }}>
          {/* Information Banner */}
          <div
            className="notice-card"
            style={{
              backgroundColor: "#ffffff",
              border: "1px solid #e2e8f0",
              marginBottom: "1.25rem",
              display: "flex",
              alignItems: "flex-start",
              gap: "0.9rem",
              padding: "1.1rem 1.15rem",
              borderRadius: "12px",
              boxShadow: "0 2px 6px rgba(0,0,0,0.03)",
            }}
          >
            <div
              style={{
                width: 40,
                height: 40,
                borderRadius: 12,
                border: "1px solid #e2e8f0",
                background: "#f8fafc",
                display: "flex",
                alignItems: "center",
                justifyContent: "center",
                flexShrink: 0,
              }}
            >
              <QrCode size={20} color="#0f172a" />
            </div>

            <p style={{ color: "#0f172a", margin: 0, lineHeight: 1.5 }}>
              Only <strong>verified batches</strong> are shown here. Generate QR
              codes for exporters to scan into their supply chain systems.
            </p>
          </div>

          {/* Search Bar */}
          <div style={{ marginBottom: "1rem" }}>
            <div
              style={{
                background: "white",
                border: "1px solid #e5e7eb",
                borderRadius: "14px",
                padding: "0.85rem 1rem",
                boxShadow: "0 10px 22px rgba(0,0,0,0.07)",
                display: "flex",
                alignItems: "center",
                gap: "0.75rem",
              }}
            >
              <Search size={20} color="#64748b" />
              <input
                type="text"
                placeholder="Search by Batch No."
                value={searchQuery}
                onChange={handleSearchChange}
                style={{
                  flex: 1,
                  border: "none",
                  outline: "none",
                  fontSize: "0.95rem",
                  color: "#0f172a",
                  background: "transparent",
                }}
              />
              {searchQuery && (
                <button
                  onClick={clearSearch}
                  title="Clear"
                  style={{
                    border: "none",
                    background: "#f1f5f9",
                    width: 34,
                    height: 34,
                    borderRadius: 10,
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    cursor: "pointer",
                  }}
                >
                  <X size={18} color="#475569" />
                </button>
              )}
            </div>
          </div>

          <div
            style={{
              marginBottom: "1.5rem",
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              gap: "1rem",
              flexWrap: "wrap",
            }}
          >
            <div style={{ color: "#64748b", fontSize: "0.9rem" }}>
              Showing <b>{filteredBatches.length}</b> of <b>{batches.length}</b>{" "}
              verified batches
            </div>

            <button
              className="btn btn-outline"
              onClick={() => loadBatches()}
              disabled={loading || actionLoading}
              style={{
                display: "flex",
                alignItems: "center",
                gap: "0.5rem",
                background: "white",
                border: "1px solid #e5e7eb",
                boxShadow: "0 6px 16px rgba(0,0,0,0.06)",
                borderRadius: "14px",
                padding: "0.65rem 1rem",
                cursor: loading || actionLoading ? "not-allowed" : "pointer",
              }}
            >
              <RefreshCw size={18} className={loading ? "spin" : ""} />
              Refresh
            </button>
          </div>

          {/* Results */}
          {loading ? (
            <div className="loading-screen" style={{ minHeight: "300px" }}>
              Scanning Registry...
            </div>
          ) : batches.length === 0 ? (
            <div
              style={{
                textAlign: "center",
                padding: "4rem 2rem",
                backgroundColor: "#f8fafc",
                borderRadius: "12px",
                border: "1px dashed #cbd5e1",
              }}
            >
              <Inbox
                size={48}
                color="#94a3b8"
                style={{ marginBottom: "1rem" }}
              />
              <h3>No verified batches found</h3>
              <p style={{ color: "#64748b" }}>
                Approve pending batches before generating QRs.
              </p>
            </div>
          ) : filteredBatches.length === 0 ? (
            <div style={{ textAlign: "center", padding: "3rem 2rem" }}>
              <p style={{ color: "#64748b" }}>
                No batches match "{searchQuery}"
              </p>
            </div>
          ) : (
            <div
              style={{ display: "flex", flexDirection: "column", gap: "1rem" }}
            >
              {filteredBatches.map((batch) => (
                <div
                  key={batch._id}
                  style={{
                    backgroundColor: "white",
                    borderRadius: "12px",
                    padding: "1.25rem",
                    border: "1px solid #e2e8f0",
                    display: "flex",
                    alignItems: "center",
                    gap: "1.25rem",
                    boxShadow: "0 2px 6px rgba(0,0,0,0.03)",
                  }}
                >
                  <div
                    style={{
                      width: "6px",
                      height: "40px",
                      backgroundColor: "var(--info)",
                      borderRadius: "4px",
                    }}
                  />

                  <div style={{ flex: 1, minWidth: 0 }}>
                    <h3
                      style={{
                        margin: "0 0 0.25rem 0",
                        fontSize: "1.05rem",
                        fontWeight: 600,
                        color: "#0f172a",
                        whiteSpace: "nowrap",
                        overflow: "hidden",
                        textOverflow: "ellipsis",
                      }}
                      title={batch.batchId}
                    >
                      {batch.batchId}
                    </h3>
                    <span style={{ fontSize: "0.85rem", color: "#64748b" }}>
                      Verified on: {formatDate(batch.saleDate)}
                    </span>
                  </div>

                  <div style={{ display: "flex", gap: "0.5rem" }}>
                    <button
                      className="btn-icon"
                      title="View Payload"
                      onClick={() => handlePreviewPayload(batch)}
                      style={{
                        backgroundColor: "#f1f5f9",
                        color: "#475569",
                        borderRadius: "10px",
                        padding: "0.55rem",
                        border: "1px solid #e2e8f0",
                        cursor: "pointer",
                      }}
                    >
                      <FileJson size={20} />
                    </button>

                    <button
                      className="btn btn-primary"
                      onClick={() => handleGenerateQR(batch)}
                      disabled={actionLoading}
                      style={{
                        display: "flex",
                        alignItems: "center",
                        gap: "0.5rem",
                        backgroundColor: "var(--info)",
                        borderRadius: "10px",
                        padding: "0.65rem 0.95rem",
                      }}
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
          <div
            className="modal-content"
            onClick={(e) => e.stopPropagation()}
            style={{ maxWidth: "520px" }}
          >
            <div className="modal-header">
              <h2>QR Payload Preview</h2>
              <button
                className="btn-icon"
                onClick={() => setSelectedPayload(null)}
              >
                <X size={20} />
              </button>
            </div>

            <div
              className="modal-body"
              style={{
                backgroundColor: "#f8fafc",
                padding: "1.25rem",
                borderRadius: "10px",
                overflowX: "auto",
                border: "1px solid #e2e8f0",
              }}
            >
              <pre
                style={{
                  margin: 0,
                  color: "#334155",
                  fontSize: "0.9rem",
                  whiteSpace: "pre-wrap",
                  wordBreak: "break-word",
                }}
              >
                {selectedPayload}
              </pre>
            </div>

            <div
              className="modal-footer"
              style={{
                marginTop: "1.25rem",
                display: "flex",
                justifyContent: "flex-end",
              }}
            >
              <button
                className="btn btn-outline"
                onClick={() => setSelectedPayload(null)}
              >
                Close
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Loading Overlay */}
      {actionLoading && (
        <div
          style={{
            position: "absolute",
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: "rgba(255,255,255,0.7)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            zIndex: 1000,
          }}
        >
          <RefreshCw size={32} className="spin" color="var(--primary)" />
        </div>
      )}
    </div>
  );
}
