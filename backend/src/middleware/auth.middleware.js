const admin = require("../config/firebaseAdmin");

const verifyToken = async (req, res, next) => {
  const header = req.headers.authorization || "";
  if (!header.startsWith("Bearer "))
    return res.status(401).json({ message: "No token" });

  const idToken = header.split(" ")[1];
  try {
    const decoded = await admin.auth().verifyIdToken(idToken);
    req.user = decoded; // contains .uid, .email, etc.
    next();
  } catch (err) {
    return res
      .status(401)
      .json({ message: "Invalid token", error: err.message });
  }
};

module.exports = verifyToken;
