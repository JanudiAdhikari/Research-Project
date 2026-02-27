const crypto = require("crypto");
const ActualPriceData = require("../../models/market_forecast/actual_price_data.model");

const STATUSES = {
  BATCH_CREATED: "BATCH_CREATED", // Block 1 (user)
  MARKETPLACE_LISTED: "MARKETPLACE_LISTED", // Block 1 (user)
  VERIFIED: "VERIFIED", // Block 2 (admin)
  RECEIVED: "RECEIVED", // Block 3 (exporter)
};

const ROLES = {
  USER: "USER",
  ADMIN: "ADMIN",
  EXPORTER: "EXPORTER",
};

// Helpers
function normalizeStatus(s) {
  if (!s) return "";
  return String(s).trim().replaceAll(" ", "_").toUpperCase();
}

function sha256(input) {
  return crypto.createHash("sha256").update(input).digest("hex");
}

function getActor(req) {
  // ✅ Adjust these based on your auth middleware
  // Must exist:
  // req.user.uid
  // req.user.role  (USER / ADMIN / EXPORTER)
  const actorId = req.user?.uid;
  const actorRole = (req.user?.role || ROLES.USER).toUpperCase();

  return { actorId, actorRole };
}

function lastBlock(record) {
  const history = record.statusHistory || [];
  return history.length ? history[history.length - 1] : null;
}

function makeBlock({
  recordId,
  nextIndex,
  status,
  actorId,
  actorRole,
  prevHash,
}) {
  const timestamp = new Date();

  const payload = JSON.stringify({
    recordId: String(recordId),
    index: nextIndex,
    status,
    timestamp: timestamp.toISOString(),
    actorId,
    actorRole,
    prevHash,
  });

  const hash = sha256(payload);

  return {
    index: nextIndex,
    status,
    timestamp,
    actorId,
    actorRole,
    prevHash,
    hash,
  };
}

// Every status change is a NEW block
function appendStatusBlock(record, newStatus, actorId, actorRole) {
  const history = record.statusHistory || [];
  const prev = history.length ? history[history.length - 1] : null;

  const nextIndex = history.length + 1;
  const prevHash = prev ? prev.hash : "GENESIS";

  const block = makeBlock({
    recordId: record._id,
    nextIndex,
    status: newStatus,
    actorId,
    actorRole,
    prevHash,
  });

  record.statusHistory = [...history, block];
  record.currentStatus = newStatus;
}

// Transition + permission rules
function canTransition({ fromStatus, toStatus, actorRole }) {
  // Create block 1
  if (!fromStatus) {
    return toStatus === STATUSES.BATCH_CREATED; // first block only
  }

  // After RECEIVED, lock everything
  if (fromStatus === STATUSES.RECEIVED) return false;

  // Block 1 updates (USER)
  if (
    fromStatus === STATUSES.BATCH_CREATED &&
    toStatus === STATUSES.MARKETPLACE_LISTED
  ) {
    return actorRole === ROLES.USER;
  }

  // Admin verify (Block 2)
  // Allow admin to verify either from BATCH_CREATED or MARKETPLACE_LISTED
  if (
    (fromStatus === STATUSES.BATCH_CREATED ||
      fromStatus === STATUSES.MARKETPLACE_LISTED) &&
    toStatus === STATUSES.VERIFIED
  ) {
    return actorRole === ROLES.ADMIN;
  }

  // Exporter received (Block 3)
  if (fromStatus === STATUSES.VERIFIED && toStatus === STATUSES.RECEIVED) {
    return actorRole === ROLES.EXPORTER || actorRole === ROLES.ADMIN;
  }

  // Allow user to keep editing normal fields while not VERIFIED/RECEIVED?
  // This function is ONLY for status changes, so return false for other status jumps
  return false;
}

function isApprovedLocked(status) {
  // In your blockchain flow, VERIFIED is the “admin approved” stage.
  // After VERIFIED, you can choose to lock edits or still allow some.
  return (
    normalizeStatus(status) === STATUSES.VERIFIED ||
    normalizeStatus(status) === STATUSES.RECEIVED
  );
}

// Controllers

// Get all records
const getActualPriceData = async (req, res) => {
  try {
    const { pepperType, grade, district, limit } = req.query;
    const filter = { userId: req.user?.uid };

    if (!filter.userId) {
      return res.status(401).json({ message: "No user id" });
    }

    if (pepperType) filter.pepperType = pepperType;
    if (grade) filter.grade = grade;
    if (district) filter.district = district;

    const query = ActualPriceData.find(filter).sort({ saleDate: -1 }).lean();

    if (limit) {
      const parsedLimit = parseInt(limit, 10);
      if (parsedLimit > 0) query.limit(parsedLimit);
    }

    const records = await query.exec();
    return res.json(records);
  } catch (err) {
    console.error("Error fetching data:", err);
    return res
      .status(500)
      .json({ message: "Server error", error: err.message });
  }
};

// Create new record => ALWAYS creates Block #1 with BATCH_CREATED
const createActualPriceData = async (req, res) => {
  try {
    const { actorId, actorRole } = getActor(req);
    if (!actorId) return res.status(401).json({ message: "No user id" });

    const {
      saleDate,
      pepperType,
      grade,
      district,
      pricePerKg,
      quantity,
      notes,
      batchId,
    } = req.body;

    const parsedDate = new Date(saleDate);
    if (Number.isNaN(parsedDate.getTime())) {
      return res.status(400).json({ message: "Invalid saleDate" });
    }

    const parsedPrice = Number(pricePerKg);
    const parsedQuantity = Number(quantity);

    if (!Number.isFinite(parsedPrice) || !Number.isFinite(parsedQuantity)) {
      return res.status(400).json({ message: "Invalid numeric fields" });
    }

    const record = new ActualPriceData({
      userId: actorId,
      saleDate: parsedDate,
      pepperType,
      grade: grade || undefined,
      district: district || undefined,
      pricePerKg: parsedPrice,
      quantity: parsedQuantity,
      notes: notes || undefined,
      batchId: batchId || undefined,
      currentStatus: STATUSES.BATCH_CREATED,
      statusHistory: [],
    });

    // Block 1
    appendStatusBlock(record, STATUSES.BATCH_CREATED, actorId, ROLES.USER);

    await record.save();
    return res.status(201).json(record);
  } catch (err) {
    console.error("Error while saving data:", err);
    return res
      .status(500)
      .json({ message: "Server error", error: err.message });
  }
};

// Update record:
// - user can update fields until VERIFIED (you can change this rule if you want)
// - status changes create NEW blocks (Option A)
const updateActualPriceData = async (req, res) => {
  try {
    const { actorId, actorRole } = getActor(req);
    if (!actorId) return res.status(401).json({ message: "No user id" });

    const { id } = req.params;

    const record = await ActualPriceData.findById(id);
    if (!record) return res.status(404).json({ message: "Record not found" });

    // Ownership:
    // - USER can update only own records
    // - ADMIN/EXPORTER can update status (verify/receive) regardless of owner
    const isOwner = record.userId === actorId;

    const existingStatus = normalizeStatus(record.currentStatus);
    const incomingStatusRaw = req.body.currentStatus;
    const incomingStatus = normalizeStatus(incomingStatusRaw);

    const wantsStatusChange = Boolean(incomingStatus);

    // ✅ If user (owner) edits fields: allow only while NOT VERIFIED/RECEIVED
    if (!wantsStatusChange) {
      if (actorRole === ROLES.USER && !isOwner) {
        return res.status(403).json({ message: "Not authorized" });
      }
      if (actorRole === ROLES.USER && isApprovedLocked(existingStatus)) {
        return res
          .status(400)
          .json({ message: "Record is locked after verification" });
      }
    }

    // ✅ Status change path (blockchain)
    if (wantsStatusChange) {
      // Permission + transition check
      if (actorRole === ROLES.USER && !isOwner) {
        return res.status(403).json({ message: "Not authorized" });
      }

      const ok = canTransition({
        fromStatus: existingStatus,
        toStatus: incomingStatus,
        actorRole,
      });

      if (!ok) {
        return res.status(400).json({
          message: `Invalid status transition: ${existingStatus} -> ${incomingStatus} for role ${actorRole}`,
        });
      }

      // Append new block (Option A)
      appendStatusBlock(record, incomingStatus, actorId, actorRole);

      await record.save();
      return res.json(record);
    }

    // ✅ Field updates (normal updates)
    const {
      saleDate,
      pepperType,
      grade,
      district,
      pricePerKg,
      quantity,
      notes,
      batchId,
    } = req.body;

    if (saleDate !== undefined) {
      const parsedDate = new Date(saleDate);
      if (Number.isNaN(parsedDate.getTime())) {
        return res.status(400).json({ message: "Invalid saleDate" });
      }
      record.saleDate = parsedDate;
    }

    if (pepperType !== undefined) record.pepperType = pepperType;
    if (grade !== undefined) record.grade = grade;
    if (district !== undefined) record.district = district;
    if (batchId !== undefined) record.batchId = batchId;

    if (pricePerKg !== undefined) {
      const parsedPrice = Number(pricePerKg);
      if (!Number.isFinite(parsedPrice))
        return res.status(400).json({ message: "Invalid pricePerKg" });
      record.pricePerKg = parsedPrice;
    }

    if (quantity !== undefined) {
      const parsedQuantity = Number(quantity);
      if (!Number.isFinite(parsedQuantity))
        return res.status(400).json({ message: "Invalid quantity" });
      record.quantity = parsedQuantity;
    }

    if (notes !== undefined) record.notes = notes;

    await record.save();
    return res.json(record);
  } catch (err) {
    console.error("Error while updating data:", err);
    return res
      .status(500)
      .json({ message: "Server error", error: err.message });
  }
};

// Delete a record
const deleteActualPriceData = async (req, res) => {
  try {
    const { actorId, actorRole } = getActor(req);
    if (!actorId) return res.status(401).json({ message: "No user id" });

    const { id } = req.params;

    const record = await ActualPriceData.findById(id);
    if (!record) return res.status(404).json({ message: "Record not found" });

    // Only owner can delete (recommended)
    if (record.userId !== actorId) {
      return res
        .status(403)
        .json({ message: "Not authorized to delete this record" });
    }

    const existingStatus = normalizeStatus(record.currentStatus);

    // After VERIFIED / RECEIVED, block delete
    if (isApprovedLocked(existingStatus)) {
      return res
        .status(400)
        .json({ message: "Cannot delete after verification" });
    }

    await ActualPriceData.findByIdAndDelete(id);
    return res.json({ message: "Record deleted successfully" });
  } catch (err) {
    console.error("Error while deleting data:", err);
    return res
      .status(500)
      .json({ message: "Server error", error: err.message });
  }
};

module.exports = {
  getActualPriceData,
  createActualPriceData,
  updateActualPriceData,
  deleteActualPriceData,
};
