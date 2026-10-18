const express = require('express');
const asyncHandler = require('../utils/asyncHandler');
const controller = require('../controllers/kosController');

// ROUTE Kos: hanya memetakan URL ke controller. Data kos berasal dari "API pemilik kos fiktif"
// (seed.sql) dan hanya dibaca (GET), tanpa login.
const router = express.Router();

router.get('/', asyncHandler(controller.daftar));
router.get('/:id', asyncHandler(controller.detail));

module.exports = router;
