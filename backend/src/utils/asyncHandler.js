// Membungkus route async agar error otomatis diteruskan ke penangan error di app.js.
module.exports = (fn) => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);
