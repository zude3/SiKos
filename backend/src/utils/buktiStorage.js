const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

const privateUploadDirectory = path.resolve(__dirname, '../../private_uploads');

function imageExtension(buffer) {
  if (
    buffer.length >= 3 &&
    buffer[0] === 0xff &&
    buffer[1] === 0xd8 &&
    buffer[2] === 0xff
  ) {
    return 'jpg';
  }
  if (
    buffer.length >= 8 &&
    buffer.subarray(0, 8).equals(Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]))
  ) {
    return 'png';
  }
  if (
    buffer.length >= 12 &&
    buffer.toString('ascii', 0, 4) === 'RIFF' &&
    buffer.toString('ascii', 8, 12) === 'WEBP'
  ) {
    return 'webp';
  }
  return null;
}

function storedProofPath(relativePath) {
  if (!/^proofs\/[a-f0-9-]+\.(jpg|png|webp)$/.test(relativePath || '')) {
    return null;
  }
  return path.resolve(privateUploadDirectory, relativePath);
}

async function saveStoredProof(buffer, extension) {
  const relativePath = `proofs/${crypto.randomUUID()}.${extension}`;
  const absolutePath = storedProofPath(relativePath);
  await fs.promises.mkdir(path.dirname(absolutePath), { recursive: true });
  await fs.promises.writeFile(absolutePath, buffer, { flag: 'wx' });
  return relativePath;
}

async function removeStoredProof(relativePath) {
  const filePath = storedProofPath(relativePath);
  if (!filePath) return;
  try {
    await fs.promises.unlink(filePath);
  } catch (error) {
    if (error.code !== 'ENOENT') throw error;
  }
}

module.exports = {
  imageExtension,
  removeStoredProof,
  saveStoredProof,
  storedProofPath,
};
