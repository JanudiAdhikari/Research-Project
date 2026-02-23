const Certification = require("../models/certification.models");
const User = require("../models/user.models");
const {
  uploadBufferToCloudinary,
  deleteFromCloudinary,
} = require("../utils/cloudinaryUpload");

// Helper: compute expired
const isExpired = (expiryDate) => {
  const now = new Date();
  const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
  const exp = new Date(
    expiryDate.getFullYear(),
    expiryDate.getMonth(),
    expiryDate.getDate(),
  );
  return exp < today;
};

const mapCertForResponse = (cert) => {
  const obj = cert.toObject();
  obj.isExpired = isExpired(cert.expiryDate);
  obj.effectiveStatus = obj.isExpired ? "expired" : obj.status; // for UI
  return obj;
};

const parseDate = (value) => {
  const d = new Date(value);
  return Number.isNaN(d.getTime()) ? null : d;
};

const validateIssueExpiry = (issueDate, expiryDate) => {
  if (!issueDate || !expiryDate)
    return { ok: false, message: "Issue and expiry dates are required" };

  // Compare by date only (ignore time)
  const issue = new Date(
    issueDate.getFullYear(),
    issueDate.getMonth(),
    issueDate.getDate(),
  );
  const expiry = new Date(
    expiryDate.getFullYear(),
    expiryDate.getMonth(),
    expiryDate.getDate(),
  );

  if (expiry <= issue) {
    return { ok: false, message: "Expiry date must be after issue date" };
  }
  return { ok: true };
};

// CREATE (user)
const createCertification = async (req, res) => {
  try {
    const {
      certificationType,
      certificateNumber,
      issuingBody,
      issueDate,
      expiryDate,
    } = req.body;

    if (
      !certificationType ||
      !certificateNumber ||
      !issuingBody ||
      !issueDate ||
      !expiryDate
    ) {
      return res.status(400).json({ message: "Missing required fields" });
    }

    const user = await User.findOne({ firebaseUid: req.user.uid });
    if (!user) return res.status(404).json({ message: "User not found" });

    const issue = parseDate(issueDate);
    const expiry = parseDate(expiryDate);
    if (!issue || !expiry) {
      return res
        .status(400)
        .json({ message: "Invalid issueDate or expiryDate" });
    }

    const check = validateIssueExpiry(issue, expiry);
    if (!check.ok) return res.status(400).json({ message: check.message });

    // Optional attachment upload
    let attachment = {
      url: null,
      publicId: null,
      resourceType: null,
      originalName: null,
    };

    if (req.file) {
      const isPdf = req.file.mimetype === "application/pdf";
      const resourceType = isPdf ? "raw" : "image";

      const uploadResult = await uploadBufferToCloudinary({
        buffer: req.file.buffer,
        folder: "ceylonpepper/certifications",
        publicId: `${req.user.uid}_${certificateNumber}_${Date.now()}`,
        resourceType,
      });

      attachment = {
        url: uploadResult.secure_url,
        publicId: uploadResult.public_id,
        resourceType: uploadResult.resource_type,
        originalName: req.file.originalname,
      };
    }

    const cert = await Certification.create({
      userId: user._id,
      firebaseUid: req.user.uid,
      certificationType,
      certificateNumber,
      issuingBody,
      issueDate: issue,
      expiryDate: expiry,
      attachment,
      status: "pending",
      verifiedBy: null,
      verificationDate: null,
      rejectionReason: null,
    });

    return res.status(201).json({
      message: "Certification created",
      cert: mapCertForResponse(cert),
    });
  } catch (err) {
    if (err.code === 11000) {
      return res.status(409).json({ message: "Certificate already exists" });
    }
    return res.status(500).json({ message: err.message });
  }
};

// LIST MY CERTIFICATIONS (user) with search/filter/sort
// GET /api/certifications/me?status=pending&q=SLGAP&type=SL-GAP&issuingBody=Department&sort=newest
const getMyCertifications = async (req, res) => {
  try {
    const { status, q, type, issuingBody, sort } = req.query;

    const filter = { firebaseUid: req.user.uid };

    if (
      status &&
      ["pending", "verified", "rejected"].includes(status.toLowerCase())
    ) {
      filter.status = status.toLowerCase();
    }

    if (type) {
      filter.certificationType = { $regex: type, $options: "i" };
    }

    if (issuingBody) {
      filter.issuingBody = { $regex: issuingBody, $options: "i" };
    }

    if (q) {
      filter.$or = [
        { certificationType: { $regex: q, $options: "i" } },
        { certificateNumber: { $regex: q, $options: "i" } },
        { issuingBody: { $regex: q, $options: "i" } },
        { status: { $regex: q, $options: "i" } },
      ];
    }

    let cursor = Certification.find(filter);

    if ((sort || "").toLowerCase() === "oldest") {
      cursor = cursor.sort({ createdAt: 1 });
    } else if ((sort || "").toLowerCase() === "expiry") {
      cursor = cursor.sort({ expiryDate: 1 });
    } else {
      cursor = cursor.sort({ createdAt: -1 }); // newest default
    }

    const certs = await cursor.exec();
    return res.json(certs.map(mapCertForResponse));
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// GET ONE (user)
const getCertificationById = async (req, res) => {
  try {
    const { id } = req.params;

    const cert = await Certification.findOne({
      _id: id,
      firebaseUid: req.user.uid,
    });

    if (!cert) return res.status(404).json({ message: "Not found" });

    return res.json(mapCertForResponse(cert));
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// UPDATE (user) only if pending + owner
// PATCH /api/certifications/:id
const updateMyCertification = async (req, res) => {
  try {
    const { id } = req.params;

    const cert = await Certification.findOne({
      _id: id,
      firebaseUid: req.user.uid,
    });
    if (!cert) return res.status(404).json({ message: "Not found" });

    if (cert.status !== "pending") {
      return res
        .status(400)
        .json({ message: "Only pending certifications can be edited" });
    }

    const {
      certificationType,
      certificateNumber,
      issuingBody,
      issueDate,
      expiryDate,
      removeAttachment,
    } = req.body;

    const finalIssue =
      issueDate != null ? parseDate(issueDate) : cert.issueDate;
    const finalExpiry =
      expiryDate != null ? parseDate(expiryDate) : cert.expiryDate;

    if (
      (issueDate != null && !finalIssue) ||
      (expiryDate != null && !finalExpiry)
    ) {
      return res
        .status(400)
        .json({ message: "Invalid issueDate or expiryDate" });
    }

    const check = validateIssueExpiry(finalIssue, finalExpiry);
    if (!check.ok) return res.status(400).json({ message: check.message });

    if (certificationType != null) cert.certificationType = certificationType;
    if (certificateNumber != null) cert.certificateNumber = certificateNumber;
    if (issuingBody != null) cert.issuingBody = issuingBody;
    if (issueDate != null) cert.issueDate = finalIssue;
    if (expiryDate != null) cert.expiryDate = finalExpiry;

    // Attachment logic
    const shouldRemove =
      String(removeAttachment || "").toLowerCase() === "true";

    if (shouldRemove && cert.attachment?.publicId) {
      await deleteFromCloudinary({
        publicId: cert.attachment.publicId,
        resourceType: cert.attachment.resourceType,
      });
      cert.attachment = {
        url: null,
        publicId: null,
        resourceType: null,
        originalName: null,
      };
    }

    if (req.file) {
      // replace old
      if (cert.attachment?.publicId) {
        await deleteFromCloudinary({
          publicId: cert.attachment.publicId,
          resourceType: cert.attachment.resourceType,
        });
      }

      const isPdf = req.file.mimetype === "application/pdf";
      const resourceType = isPdf ? "raw" : "image";

      const uploadResult = await uploadBufferToCloudinary({
        buffer: req.file.buffer,
        folder: "ceylonpepper/certifications",
        publicId: `${req.user.uid}_${cert.certificateNumber || "CERT"}_${Date.now()}`,
        resourceType,
      });

      cert.attachment = {
        url: uploadResult.secure_url,
        publicId: uploadResult.public_id,
        resourceType: uploadResult.resource_type,
        originalName: req.file.originalname,
      };
    }

    // Reset verification metadata since user changed data
    cert.verifiedBy = null;
    cert.verificationDate = null;
    cert.rejectionReason = null;

    await cert.save();

    return res.json({ message: "Updated", cert: mapCertForResponse(cert) });
  } catch (err) {
    if (err.code === 11000) {
      return res.status(409).json({ message: "Certificate already exists" });
    }
    return res.status(500).json({ message: err.message });
  }
};

// DELETE (user) only if pending + owner
// DELETE /api/certifications/:id
const deleteMyCertification = async (req, res) => {
  try {
    const { id } = req.params;

    const cert = await Certification.findOne({
      _id: id,
      firebaseUid: req.user.uid,
    });
    if (!cert) return res.status(404).json({ message: "Not found" });

    if (cert.status !== "pending") {
      return res
        .status(400)
        .json({ message: "Only pending certifications can be deleted" });
    }

    if (cert.attachment?.publicId) {
      await deleteFromCloudinary({
        publicId: cert.attachment.publicId,
        resourceType: cert.attachment.resourceType,
      });
    }

    await Certification.deleteOne({ _id: id });
    return res.json({ message: "Deleted" });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

/* ---------------- ADMIN SIDE ---------------- */

// LIST PENDING (admin)
const adminListCertifications = async (req, res) => {
  try {
    const { status, q, sort } = req.query;

    const filter = {};
    if (
      status &&
      ["pending", "verified", "rejected"].includes(status.toLowerCase())
    ) {
      filter.status = status.toLowerCase();
    }

    if (q) {
      filter.$or = [
        { certificationType: { $regex: q, $options: "i" } },
        { certificateNumber: { $regex: q, $options: "i" } },
        { issuingBody: { $regex: q, $options: "i" } },
        { firebaseUid: { $regex: q, $options: "i" } },
      ];
    }

    let cursor = Certification.find(filter);

    if ((sort || "").toLowerCase() === "oldest") {
      cursor = cursor.sort({ createdAt: 1 });
    } else {
      cursor = cursor.sort({ createdAt: -1 });
    }

    const certs = await cursor.exec();
    return res.json(certs.map(mapCertForResponse));
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

// APPROVE/REJECT (admin)
// PATCH /api/certifications/admin/:id/verify  { action: "verify" | "reject", reason?: "..." }
const adminVerifyCertification = async (req, res) => {
  try {
    const { id } = req.params;
    const { action, reason } = req.body;

    if (!["verify", "reject"].includes((action || "").toLowerCase())) {
      return res.status(400).json({ message: "Invalid action" });
    }

    const cert = await Certification.findById(id);
    if (!cert) return res.status(404).json({ message: "Not found" });

    if (action.toLowerCase() === "verify") {
      cert.status = "verified";
      cert.verifiedBy = "admin";
      cert.verificationDate = new Date();
      cert.rejectionReason = null;
    } else {
      cert.status = "rejected";
      cert.verifiedBy = "admin";
      cert.verificationDate = new Date();
      cert.rejectionReason = (reason || "").trim() || "Rejected by admin";
    }

    await cert.save();
    return res.json({ message: "Updated", cert: mapCertForResponse(cert) });
  } catch (err) {
    return res.status(500).json({ message: err.message });
  }
};

module.exports = {
  createCertification,
  getMyCertifications,
  getCertificationById,
  adminListCertifications,
  adminVerifyCertification,
  updateMyCertification,
  deleteMyCertification,
};
