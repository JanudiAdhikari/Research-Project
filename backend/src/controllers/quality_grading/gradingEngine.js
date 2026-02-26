// Piecewise linear interpolation helper
function lerp(x, x0, x1, y0, y1) {
  if (x1 === x0) return y0;
  const t = (x - x0) / (x1 - x0);
  return y0 + t * (y1 - y0);
}

function clamp(n, min, max) {
  return Math.max(min, Math.min(max, n));
}

// Density scoring based on IPC-like thresholds (black pepper example)
// T1=550 (Grade I), T2=500 (Grade II), T3=450 (Grade III) :contentReference[oaicite:2]{index=2}
function scoreDensity(d) {
  if (d == null || Number.isNaN(Number(d))) return 0;
  const x = Number(d);

  const T1 = 550;
  const T2 = 500;
  const T3 = 450;

  if (x >= T1) return 100;
  if (x >= T2) return clamp(lerp(x, T2, T1, 70, 100), 0, 100);
  if (x >= T3) return clamp(lerp(x, T3, T2, 40, 70), 0, 100);

  // below T3, taper down to 0 as it gets very low
  // choose 350 as a "very poor" floor (can tune later)
  if (x <= 350) return 0;
  return clamp(lerp(x, 350, T3, 0, 40), 0, 100);
}

// Extraneous matter scoring (IPC anchor exists, you map your visual % as proxy) :contentReference[oaicite:3]{index=3}
// Grade I max 1%, Grade II max 2%, Grade III max 2% (from your screenshot table)
// We'll use: <=1% => 100, <=2% => 70, <=5% => 40, >10% => 0 (tunable)
function scoreExtraneous(pct) {
  const x = Number(pct ?? 0);
  if (x <= 1) return 100;
  if (x <= 2) return clamp(lerp(x, 1, 2, 100, 70), 0, 100);
  if (x <= 5) return clamp(lerp(x, 2, 5, 70, 40), 0, 100);
  if (x <= 10) return clamp(lerp(x, 5, 10, 40, 10), 0, 100);
  return 0;
}

// Mold scoring (IPC anchor exists: Grade I max 1%, Grade II max 3%, Grade III max 3%)
// We'll map: <=1% => 100, <=3% => 70, <=6% => 30, >10% => 0 (tunable)
function scoreMold(pct) {
  const x = Number(pct ?? 0);
  if (x <= 1) return 100;
  if (x <= 3) return clamp(lerp(x, 1, 3, 100, 70), 0, 100);
  if (x <= 6) return clamp(lerp(x, 3, 6, 70, 30), 0, 100);
  if (x <= 10) return clamp(lerp(x, 6, 10, 30, 5), 0, 100);
  return 0;
}

// Abnormal texture as "broken/pinheads" proxy
// IPC pinheads/broken berries max: 1% / 2% / 4% (from your screenshot table)
// We'll map: <=1% => 100, <=2% => 80, <=4% => 60, <=10% => 20, >20% => 0 (tunable)
function scoreBrokenLike(pct) {
  const x = Number(pct ?? 0);
  if (x <= 1) return 100;
  if (x <= 2) return clamp(lerp(x, 1, 2, 100, 80), 0, 100);
  if (x <= 4) return clamp(lerp(x, 2, 4, 80, 60), 0, 100);
  if (x <= 10) return clamp(lerp(x, 4, 10, 60, 20), 0, 100);
  if (x <= 20) return clamp(lerp(x, 10, 20, 20, 0), 0, 100);
  return 0;
}

// Adulteration scoring with a strong penalty and optional hard reject :contentReference[oaicite:4]{index=4}
function scoreAdulteration(pct) {
  const x = Number(pct ?? 0);
  if (x <= 0) return 100;
  if (x <= 0.1) return clamp(lerp(x, 0, 0.1, 100, 70), 0, 100);
  if (x <= 0.5) return clamp(lerp(x, 0.1, 0.5, 70, 0), 0, 100);
  return 0;
}

// Variety to estimated piperine points (starter, you can update later) :contentReference[oaicite:5]{index=5}
function scoreVarietyPiperine(pepperVariety) {
  const v = (pepperVariety || "").toLowerCase();

  // You can tune these when you find better sources for malabar/kuching
  const table = {
    ceylon_pepper: 100,
    panniyur_1: 40,
    dingi_rala: 40,
    kohukumbure_rala: 65,
    bootawe_rala: 65,
    malabar: 60, // unknown in your data, keep neutral
    kuching: 40, // provisional
    unknown: 60,
  };

  return table[v] ?? 60;
}

// Certifications bonus score: if any verified + not expired => 100 else 0,
// then apply low weight (bonus) :contentReference[oaicite:6]{index=6}
function scoreCertBonus(snapshotCount) {
  const c = Number(snapshotCount ?? 0);
  return c > 0 ? 100 : 0;
}

// Grade bands (custom names)
function scoreToGrade(score) {
  if (score >= 90) return "PREMIUM";
  if (score >= 80) return "GOLD";
  if (score >= 65) return "SILVER";
  if (score >= 50) return "BASIC";
  return "REJECT";
}

function buildImprovements(raw, factorScores) {
  const tips = [];

  if ((raw.adulterantPct ?? 0) > 0) tips.push("Remove adulterant seeds by careful sorting before drying and packaging.");
  if ((raw.extraneousPct ?? 0) > 2) tips.push("Improve cleaning: remove stones, stems and foreign matter using sieving and winnowing.");
  if ((raw.moldPct ?? 0) > 1) tips.push("Reduce mold risk: dry faster to safe moisture, store in dry ventilated conditions, avoid damp bags.");
  if ((raw.abnormalTexturePct ?? 0) > 4) tips.push("Reduce broken/light berries: improve threshing and handling, remove pinheads and broken berries by grading.");
  if ((raw.density ?? 0) < 500) tips.push("Improve bulk density: ensure proper maturity at harvest and good drying and cleaning.");
  if ((factorScores.varietyPiperine ?? 0) < 60) tips.push("Consider higher-piperine varieties where suitable, and keep batches variety-pure for premium markets.");

  // Keep it short
  return tips.slice(0, 6);
}

/**
 * Main grading function
 * Inputs:
 * - pepperType: "black" | "white" (you can enforce black-only for now)
 * - pepperVariety: from your enum
 * - density: number (g/L)
 * - factors: { adulterantPct, extraneousPct, moldPct, abnormalTexturePct, healthyVisualPct }
 * - certSnapshotCount: number
 */
function gradeBatch({ pepperType, pepperVariety, density, factors, certSnapshotCount }) {
  const type = (pepperType || "").toLowerCase();
  if (type !== "black") {
    // for now
    return {
      overallScore: 0,
      grade: "REJECT",
      hardReject: true,
      hardRejectReasons: ["Only black pepper grading is implemented currently"],
      factorScores: {},
      weights: {},
      improvements: ["Select black pepper type for grading (white pepper rules not added yet)."],
    };
  }

  const raw = {
    density: Number(density ?? 0),
    adulterantPct: Number(factors?.adulterantPct ?? 0),
    extraneousPct: Number(factors?.extraneousPct ?? 0),
    moldPct: Number(factors?.moldPct ?? 0),
    abnormalTexturePct: Number(factors?.abnormalTexturePct ?? 0),
    healthyVisualPct: Number(factors?.healthyVisualPct ?? 0),
  };

  // Hard reject rules (keep them explainable) :contentReference[oaicite:7]{index=7}
  const hardRejectReasons = [];
  if (raw.adulterantPct > 0.5) hardRejectReasons.push("Adulterant seeds above 0.5%");
  // Optional: if you want mold hard reject
  // if (raw.moldPct > 10) hardRejectReasons.push("Mold above 10%");

  const hardReject = hardRejectReasons.length > 0;

  const factorScores = {
    density: scoreDensity(raw.density),
    adulteration: scoreAdulteration(raw.adulterantPct),
    extraneous: scoreExtraneous(raw.extraneousPct),
    mold: scoreMold(raw.moldPct),
    brokenLike: scoreBrokenLike(raw.abnormalTexturePct),
    varietyPiperine: scoreVarietyPiperine(pepperVariety),
    certBonus: scoreCertBonus(certSnapshotCount),
  };

  // Default weights (sum ~1.0). Based on your doc idea: density strong, adulteration strong, GAP small bonus. :contentReference[oaicite:8]{index=8}
  const weights = {
    density: 0.20,
    adulteration: 0.20,
    extraneous: 0.12,
    mold: 0.12,
    brokenLike: 0.10,
    varietyPiperine: 0.09,
    certBonus: 0.05,
    // remaining 0.12 reserved for future factors (insects, color, size). For now, distribute into healthyVisual as a soft quality factor.
    healthyVisual: 0.12,
  };

  // Healthy visual can be a soft factor: use it as-is (0–100 already)
  const healthyVisualScore = clamp(raw.healthyVisualPct, 0, 100);

  let score =
    factorScores.density * weights.density +
    factorScores.adulteration * weights.adulteration +
    factorScores.extraneous * weights.extraneous +
    factorScores.mold * weights.mold +
    factorScores.brokenLike * weights.brokenLike +
    factorScores.varietyPiperine * weights.varietyPiperine +
    factorScores.certBonus * weights.certBonus +
    healthyVisualScore * weights.healthyVisual;

  score = clamp(score, 0, 100);

  // If hard reject, override
  const finalGrade = hardReject ? "REJECT" : scoreToGrade(score);

  const improvements = buildImprovements(raw, factorScores);

  return {
    overallScore: Number(score.toFixed(2)),
    grade: finalGrade,
    hardReject,
    hardRejectReasons,
    factorScores,
    weights,
    improvements,
  };
}

module.exports = {
  gradeBatch,
};