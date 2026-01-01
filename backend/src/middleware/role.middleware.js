const User = require("../models/user.models");

const authorizedRoles = (...allowed) => {
  return async (req, res, next) => {
    try {
      const user = await User.findOne({ firebaseUid: req.user.uid });
      if (!user) return res.status(404).json({ message: "User not found" });
      if (!allowed.includes(user.role))
        return res.status(403).json({ message: "Permission denied" });
      req.currentUser = user;
      next();
    } catch (err) {
      res.status(500).json({ message: err.message });
    }
  };
};

module.exports = authorizedRoles;
