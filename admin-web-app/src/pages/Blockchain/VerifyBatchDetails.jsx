import { useState, useEffect } from "react";
import { useLocation, useNavigate, useParams } from "react-router-dom";
import { getQualityChecksByBatch, verifyBatchRecord } from "../../services/api";
import {
  ArrowLeft,
  RefreshCw,
  CheckCircle,
  Info,
  Activity,
  XCircle,
  Droplets,
  MapPin,
  DollarSign,
  Target,
  Package,
} from "lucide-react";
import "../../App.css";

export default function VerifyBatchDetails() {
  const { state } = useLocation();
  const navigate = useNavigate();
  const { batchId } = useParams();

  const [batch, setBatch] = useState(state?.batch || null);
  const [qualityChecks, setQualityChecks] = useState([]);
  const [loadingQc, setLoadingQc] = useState(true);
  const [verifying, setVerifying] = useState(false);
  const [error, setError] = useState("");

  const loadQualityChecks = async () => {
    if (!batch || !batch.batchId) return;
    setLoadingQc(true);
    setError("");
    try {
      const checks = await getQualityChecksByBatch(batch.batchId);
      setQualityChecks(checks || []);
    } catch (err) {
      setError(err.message || "Failed to load quality checks.");
    } finally {
      setLoadingQc(false);
    }
  };

  useEffect(() => {
    if (!batch) {
      navigate("/blockchain/verify-batches");
    } else {
      loadQualityChecks();
    }
  }, [batch]);

  const handleVerify = async () => {
    if (verifying || isAlreadyVerified || isQrGenerated) return;

    setVerifying(true);
    try {
      const updated = await verifyBatchRecord(batch._id);
      setBatch((prev) => ({
        ...prev,
        currentStatus: updated.currentStatus || "VERIFIED",
        statusHistory: updated.statusHistory,
        marketplaceProductId: updated.marketplaceProductId,
      }));
      alert("Batch Verified Successfully!");
    } catch (err) {
      alert("Verify failed: " + (err.message || "Unknown Error"));
    } finally {
      setVerifying(false);
    }
  };

  if (!batch) return null;

  const isAlreadyVerified = batch.currentStatus === "VERIFIED";
  const isQrGenerated = batch.currentStatus === "QR_GENERATED";

  // Function to format the date as dd/mm/yyyy
  const formatDate = (dateString) => {
    if (!dateString) return "-";

    const d = new Date(dateString);

    const day = String(d.getDate()).padStart(2, "0");
    const month = String(d.getMonth() + 1).padStart(2, "0"); // Months are 0-based
    const year = d.getFullYear();

    return `${day}/${month}/${year}`;
  };

  // Function to get color based on batch status
  const getStatusColor = (status) => {
    switch ((status || "").toUpperCase()) {
      case "BATCH_CREATED":
        return "#3b82f6";
      case "MARKETPLACE_LISTED":
        return "#8b5cf6";
      case "VERIFIED":
        return "#22c55e";
      case "RECEIVED":
        return "#f97316";
      default:
        return "#64748b";
    }
  };

  const statusColor = getStatusColor(batch.currentStatus);

  return (
    <div className="dashboard-layout">
      <main
        className="main-content"
        style={{ marginLeft: 0, width: "100%", padding: "2rem" }}
      >
        <header className="dashboard-header" style={{ marginBottom: "2rem" }}>
          <div
            className="header-text"
            style={{ display: "flex", alignItems: "center", gap: "1rem" }}
          >
            <button
              onClick={() => navigate(-1)}
              className="btn btn-outline"
              style={{ padding: "0.5rem", borderRadius: "50%" }}
            >
              <ArrowLeft size={24} />
            </button>
            <div>
              <p className="greeting">Batch Details</p>
              <h1>{batch.batchId || "Unknown Batch"}</h1>
            </div>
          </div>

          <button
            className="btn btn-primary"
            style={{
              display: "flex",
              alignItems: "center",
              gap: "0.5rem",
              backgroundColor:
                isAlreadyVerified || isQrGenerated
                  ? "#ffffff"
                  : "var(--success)",
              cursor:
                isAlreadyVerified || isQrGenerated || verifying
                  ? "not-allowed"
                  : "pointer",
              opacity: isAlreadyVerified || isQrGenerated ? 0.8 : 1,
            }}
            onClick={handleVerify}
            disabled={isAlreadyVerified || isQrGenerated || verifying}
          >
            {verifying ? (
              <>
                <RefreshCw className="spin" size={20} /> Verifying...
              </>
            ) : isAlreadyVerified ? (
              <>
                <CheckCircle size={20} /> Verified
              </>
            ) : isQrGenerated ? (
              <>
                <CheckCircle size={20} /> QR Generated
              </>
            ) : (
              <>
                <CheckCircle size={20} /> Verify Batch
              </>
            )}
          </button>
        </header>

        <div
          className="content-pad"
          style={{
            maxWidth: "1000px",
            margin: "0 auto",
            display: "grid",
            gridTemplateColumns: "minmax(0, 2fr) minmax(0, 1fr)",
            gap: "2rem",
            alignItems: "stretch",
          }}
        >
          <div
            style={{
              backgroundColor: "#fff",
              borderRadius: "12px",
              border: "1px solid #e2e8f0",
              padding: "1.5rem",
              height: "100%",
              display: "flex",
              flexDirection: "column",
              gap: "1.25rem",
            }}
          >
            {/* Batch Status */}
            <div
              style={{
                display: "flex",
                alignItems: "flex-start",
                justifyContent: "space-between",
                gap: "1rem",
                paddingBottom: "1rem",
                borderBottom: "1px solid #eef2f7",
              }}
            >
              <div style={{ display: "flex", gap: "0.85rem", minWidth: 0 }}>
                <div
                  style={{
                    width: "42px",
                    height: "42px",
                    borderRadius: "12px",
                    border: "1px solid #e2e8f0",
                    backgroundColor: "#f8fafc",
                    display: "flex",
                    alignItems: "center",
                    justifyContent: "center",
                    flexShrink: 0,
                  }}
                >
                  <Info size={20} color="#0f172a" />
                </div>

                <div style={{ minWidth: 0 }}>
                  <div
                    style={{
                      fontSize: "1rem",
                      fontWeight: 600,
                      color: "#0f172a",
                    }}
                  >
                    Batch Status
                  </div>

                  <div
                    style={{ marginTop: 6, color: "#475569", lineHeight: 1.5 }}
                  >
                    Currently marked as{" "}
                    <span style={{ color: statusColor, fontWeight: 600 }}>
                      {batch.currentStatus || "Unknown"}
                    </span>
                    .
                  </div>

                  <div
                    style={{ marginTop: 6, color: "#475569", lineHeight: 1.5 }}
                  >
                    Date:{" "}
                    <span style={{ color: "#0f172a", fontWeight: 600 }}>
                      {formatDate(batch.saleDate)}
                    </span>
                    .
                  </div>
                </div>
              </div>

              <span
                style={{
                  padding: "0.35rem 0.75rem",
                  borderRadius: 999,
                  border: `1px solid ${statusColor}55`,
                  background: `${statusColor}12`,
                  color: statusColor,
                  fontSize: "0.85rem",
                  fontWeight: 600,
                  whiteSpace: "nowrap",
                  height: "fit-content",
                }}
              >
                {batch.currentStatus || "Unknown"}
              </span>
            </div>

            {/* Metrics */}
            <div
              style={{
                display: "grid",
                gridTemplateColumns: "repeat(2, minmax(0, 1fr))",
                gap: "1rem",
              }}
            >
              <div className="metric-box">
                <DollarSign size={20} color="#0d9488" />
                <div>
                  <div className="metric-label">Price / Kg</div>
                  <div className="metric-value">
                    LKR {batch.pricePerKg?.toFixed(2) || "-"}
                  </div>
                </div>
              </div>

              <div className="metric-box">
                <Package size={20} color="#ea580c" />
                <div>
                  <div className="metric-label">Quantity</div>
                  <div className="metric-value">
                    {batch.quantity?.toFixed(2) || "-"} Kg
                  </div>
                </div>
              </div>

              <div className="metric-box">
                <MapPin size={20} color="#3b82f6" />
                <div>
                  <div className="metric-label">District</div>
                  <div className="metric-value">{batch.district || "-"}</div>
                </div>
              </div>

              <div className="metric-box">
                <Target size={20} color="#8b5cf6" />
                <div>
                  <div className="metric-label">Pepper Type & Grade</div>
                  <div className="metric-value">
                    {batch.pepperType || "-"}
                    <br />
                    {batch.grade || "-"}
                  </div>
                </div>
              </div>
            </div>

            {/*  Notes  */}
            <div style={{ paddingTop: "1rem", borderTop: "1px solid #eef2f7" }}>
              <div
                style={{
                  display: "flex",
                  alignItems: "center",
                  gap: "0.5rem",
                  marginBottom: "0.35rem",
                  color: "#0f172a",
                  fontWeight: 600,
                }}
              >
                <Info size={18} /> Notes
              </div>

              <div style={{ color: "#475569", lineHeight: 1.6 }}>
                {batch.notes ? batch.notes : "-"}
              </div>
            </div>
          </div>

          {/* Quality Checks*/}
          <div
            style={{
              backgroundColor: "#fff",
              borderRadius: "12px",
              padding: "1.5rem",
              border: "1px solid #e2e8f0",
              height: "100%",
              display: "flex",
              flexDirection: "column",
            }}
          >
            <div
              style={{
                display: "flex",
                alignItems: "center",
                justifyContent: "space-between",
                marginBottom: "1rem",
                paddingBottom: "1rem",
                borderBottom: "1px solid #eef2f7",
              }}
            >
              <div
                style={{ display: "flex", alignItems: "center", gap: "0.5rem" }}
              >
                <Activity size={20} color="#0f172a" />
                <h3 style={{ margin: 0, fontWeight: 600, color: "#0f172a" }}>
                  Quality Checks
                </h3>
              </div>

              <button
                onClick={loadQualityChecks}
                className="btn-icon"
                style={{
                  background: "#fff",
                  border: "1px solid #e2e8f0",
                  cursor: "pointer",
                  color: "#64748b",
                  borderRadius: "10px",
                  padding: "0.45rem",
                }}
                title="Refresh"
              >
                <RefreshCw size={18} className={loadingQc ? "spin" : ""} />
              </button>
            </div>

            <div style={{ flex: 1 }}>
              {loadingQc ? (
                <div
                  style={{
                    textAlign: "center",
                    padding: "2rem 0",
                    color: "#64748b",
                  }}
                >
                  <RefreshCw
                    className="spin"
                    size={24}
                    style={{ marginBottom: "1rem" }}
                  />
                  <p style={{ margin: 0 }}>Loading quality data...</p>
                </div>
              ) : error ? (
                <div className="notice-card error" style={{ padding: "1rem" }}>
                  <XCircle size={20} />
                  <span style={{ fontSize: "0.9rem" }}>{error}</span>
                </div>
              ) : qualityChecks.length === 0 ? (
                <div
                  style={{
                    textAlign: "center",
                    padding: "2.5rem 1rem",
                    backgroundColor: "#f8fafc",
                    borderRadius: "8px",
                    border: "1px dashed #cbd5e1",
                    color: "#64748b",
                  }}
                >
                  <Info
                    size={28}
                    color="#94a3b8"
                    style={{ marginBottom: "0.5rem" }}
                  />
                  <p style={{ margin: 0, fontSize: "0.95rem" }}>
                    No quality checks found for this batch.
                  </p>
                </div>
              ) : (
                <div
                  style={{
                    display: "flex",
                    flexDirection: "column",
                    gap: "1rem",
                  }}
                >
                  {qualityChecks.map((qc, i) => (
                    <div
                      key={i}
                      style={{
                        border: "1px solid #e2e8f0",
                        borderRadius: "10px",
                        padding: "1rem",
                        backgroundColor: "#fff",
                      }}
                    >
                      <div
                        style={{ marginBottom: "0.85rem", color: "#0f172a" }}
                      >
                        <span style={{ fontWeight: 600 }}>
                          Result: {qc.result || qc.grade || "N/A"}
                        </span>
                      </div>

                      <div
                        style={{
                          display: "flex",
                          flexDirection: "column",
                          gap: "0.65rem",
                        }}
                      >
                        <div
                          style={{
                            display: "flex",
                            justifyContent: "space-between",
                          }}
                        >
                          <span
                            style={{
                              color: "#64748b",
                              display: "flex",
                              gap: "0.5rem",
                              alignItems: "center",
                            }}
                          >
                            <Activity size={16} /> Density
                          </span>
                          <span style={{ fontWeight: 600, color: "#0f172a" }}>
                            {qc.density?.value
                              ? `${Number(qc.density.value).toFixed(2)} g/L`
                              : qc.density || "-"}
                          </span>
                        </div>

                        <div
                          style={{
                            display: "flex",
                            justifyContent: "space-between",
                          }}
                        >
                          <span
                            style={{
                              color: "#64748b",
                              display: "flex",
                              gap: "0.5rem",
                              alignItems: "center",
                            }}
                          >
                            <Droplets size={16} /> Moisture
                          </span>
                          <span style={{ fontWeight: 600, color: "#0f172a" }}>
                            {qc.moisture || "-"}
                          </span>
                        </div>

                        <div
                          style={{
                            display: "flex",
                            justifyContent: "space-between",
                          }}
                        >
                          <span
                            style={{
                              color: "#64748b",
                              display: "flex",
                              gap: "0.5rem",
                              alignItems: "center",
                            }}
                          >
                            <XCircle size={16} /> Defects
                          </span>
                          <span style={{ fontWeight: 600, color: "#0f172a" }}>
                            {qc.defectRate || qc.defects || "-"}
                          </span>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Responsive */}
        <style>
          {`
            @media (max-width: 980px) {
              .content-pad {
                grid-template-columns: 1fr !important;
              }
            }
            @media (max-width: 600px) {
              .content-pad div[style*="grid-template-columns: repeat(2"] {
                grid-template-columns: 1fr !important;
              }
            }
          `}
        </style>
      </main>
    </div>
  );
}
