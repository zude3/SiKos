const express = require('express');

const { authenticate, allowRoles } = require('../middleware/auth');
const uploadBukti = require('../middleware/uploadBukti');
const tagihanController = require('../controllers/tagihanController');

const router = express.Router();

router.use(authenticate);

router.get('/', tagihanController.list);
router.post('/', allowRoles('pemilik'), tagihanController.create);
router.get('/:id', tagihanController.getById);
router.post(
  '/:id/bukti',
  allowRoles('penyewa'),
  uploadBukti.single('bukti'),
  tagihanController.uploadBukti
);
router.delete(
  '/:id/bukti',
  allowRoles('penyewa'),
  tagihanController.deleteBukti
);
router.get('/:id/bukti', tagihanController.getBukti);
router.patch(
  '/:id/verifikasi',
  allowRoles('pemilik'),
  tagihanController.verify
);

module.exports = router;
