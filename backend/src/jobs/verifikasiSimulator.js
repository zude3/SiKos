const cron = require('node-cron');

const tagihanModel = require('../models/tagihanModel');

const rejectionReason = 'Bukti tidak terbaca, silakan unggah ulang';

function positiveInteger(value, fallback) {
  if (value == null || value === '') return fallback;
  if (!/^[1-9]\d*$/.test(value)) return null;
  const number = Number(value);
  return Number.isSafeInteger(number) ? number : null;
}

function simulationUserIds(value) {
  if (!value || !value.trim()) return [];
  const parts = value.split(',').map((part) => part.trim());
  if (parts.some((part) => !/^[1-9]\d*$/.test(part))) return null;
  const ids = parts.map(Number);
  if (ids.some((id) => !Number.isSafeInteger(id))) return null;
  return [...new Set(ids)];
}

async function processPending(config) {
  try {
    const candidates = await tagihanModel.listSimulationCandidates(
      config.userIds,
      config.waitSeconds
    );
    for (const candidate of candidates) {
      const status = candidate.id % config.rejectEvery === 0 ? 'ditolak' : 'lunas';
      try {
        const changed = await tagihanModel.verify(
          candidate.id,
          null,
          status,
          status === 'ditolak' ? rejectionReason : '',
          candidate.bukti_updated_at
        );
        if (changed) {
          console.log(`[verifikasi-simulator] tagihan ${candidate.id}: ${status}`);
        }
      } catch (error) {
        console.error(`[verifikasi-simulator] tagihan ${candidate.id}: gagal`);
      }
    }
  } catch (error) {
    console.error('[verifikasi-simulator] proses gagal');
  }
}

function start() {
  if ((process.env.SIMULASI_AKTIF || 'false').toLowerCase() !== 'true') {
    return null;
  }

  const userIds = simulationUserIds(process.env.SIMULASI_USER_IDS || '');
  const intervalSeconds = positiveInteger(process.env.SIMULASI_INTERVAL_DETIK, 10);
  const waitSeconds = positiveInteger(process.env.SIMULASI_TUNGGU_DETIK, 30);
  const rejectEvery = positiveInteger(process.env.SIMULASI_TOLAK_SETIAP, 3);
  if (!userIds || intervalSeconds == null || waitSeconds == null || rejectEvery == null) {
    console.error('[verifikasi-simulator] konfigurasi tidak valid; simulasi tidak dijalankan');
    return null;
  }
  if (userIds.length === 0) return null;

  const config = { userIds, waitSeconds, rejectEvery };
  let lastRunAt = 0;
  let running = false;
  return cron.schedule('* * * * * *', async () => {
    const now = Date.now();
    if (now - lastRunAt < intervalSeconds * 1000 || running) return;
    lastRunAt = now;
    running = true;
    try {
      await processPending(config);
    } finally {
      running = false;
    }
  });
}

module.exports = { start };
