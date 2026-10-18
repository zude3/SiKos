const express = require('express');
const asyncHandler = require('../utils/asyncHandler');
const auth = require('../middleware/auth');
const { buatUploadFoto, tanganiUpload } = require('../middleware/upload');
const controller = require('../controllers/komplainController');

const MAKS_FOTO = 3;
const router = express.Router();
const unggahFoto = tanganiUpload(buatUploadFoto('komplain', MAKS_FOTO), MAKS_FOTO);

router.use(auth); 

router.post('/', unggahFoto, asyncHandler(controller.buat));
router.get('/', asyncHandler(controller.daftar)); 
router.get('/:id', asyncHandler(controller.detail)); 
router.put('/:id', asyncHandler(controller.ubah)); 
router.delete('/:id', asyncHandler(controller.hapus)); 
router.put('/:id/konfirmasi', asyncHandler(controller.konfirmasi)); //          D5
router.post('/:id/penilaian', asyncHandler(controller.beriPenilaian)); //       D5

module.exports = router;
