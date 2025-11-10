// services/jwt.js
const jwt = require('jsonwebtoken');
const SECRET_KEY = 'MiClaveSuperSecreta123!'; // Puedes moverlo a .env

/**
 * Generar token
 * @param {Object} user - objeto con info del usuario (id, email, rol, etc.)
 * @param {String} expiresIn - duración opcional del token
 */
function generateToken(user, expiresIn = '2h') {
  return jwt.sign(user, SECRET_KEY, { expiresIn });
}

/**
 * Middleware para proteger rutas
 */
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) return res.status(401).json({ error: 'Token faltante' });

  jwt.verify(token, SECRET_KEY, (err, user) => {
    if (err) return res.status(403).json({ error: 'Token inválido' });
    req.user = user; // Agregamos info del usuario a la request
    next();
  });
}

module.exports = { generateToken, authenticateToken };
