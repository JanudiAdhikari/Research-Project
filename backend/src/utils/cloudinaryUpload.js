const cloudinary = require("../config/cloudinary");

const uploadBufferToCloudinary = ({ buffer, folder, publicId, resourceType }) => {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      {
        folder,
        public_id: publicId,
        resource_type: resourceType, // "image" or "raw"
        overwrite: true,
      },
      (error, result) => {
        if (error) return reject(error);
        resolve(result);
      }
    );

    stream.end(buffer);
  });
};

const deleteFromCloudinary = async ({ publicId, resourceType }) => {
  if (!publicId) return;
  await cloudinary.uploader.destroy(publicId, { resource_type: resourceType || "image" });
};

module.exports = { uploadBufferToCloudinary, deleteFromCloudinary };