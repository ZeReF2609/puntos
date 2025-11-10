const express = require('express');
const { executeProcedure } = require('../services/database');
const { authenticateToken } = require('../services/jwt'); 
const router = express.Router();

// POST para login
router.post('/auth/login/', async (req, res) => {
  const { USER_NAME, USER_PASSWORD, DEVICE, APP_VERSION } = req.body;

  try {
    const params = [
      { name: 'USER_NAME', value: USER_NAME },
      { name: 'USER_PASSWORD', value: USER_PASSWORD },
      { name: 'DEVICE', value: DEVICE },
      { name: 'APP_VERSION', value: APP_VERSION }
    ];
    const result = await executeProcedure('SP_LOGIN_VALIDATE', params);

    res.status(200).json({ success: true, data: result });
  } catch (err) {
    console.error(err);
    res.status(401).json({ success: false, message: err.message || 'Error en login' });
  }
});


// POST para insertar con parámetros
router.post('/res', async (req, res) => {
  try {
    // Obtenemos los 5 parámetros desde el body
    const { USER_EMAIL, USER_NDOC, USER_NAME, USER_PHONE, USER_LASTNAME, USER_PASSWORD } = req.body;

    // Los pasamos como array de objetos con nombre y valor
    const params = [
      { name: 'USER_EMAIL', value: USER_EMAIL },
      { name: 'USER_NDOC', value: USER_NDOC },
      { name: 'USER_NAME', value: USER_NAME },
      { name: 'USER_PHONE', value: USER_PHONE },
      { name: 'USER_LASTNAME', value: USER_LASTNAME },
      { name: 'USER_PASSWORD', value: USER_PASSWORD }
    ];

    // Ejecutamos el procedimiento con los parámetros
    const result = await executeProcedure('SP_LOGIN_INSERT_USER', params);

    // Mostrar resultado en consola
    console.log("📦 Resultado del SP_LOGIN_INSERT_USER:", result);

    res.status(200).json({ result });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error ejecutando el procedimiento con parámetros' });
  }
});


module.exports = router;
