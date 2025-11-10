// services/database.js
const mssql = require('mssql');

// Configuración SQL Server
const sqlServerConfig = {
  user: 'USER_DEV',
  password: 'Cr@ckDEV',
  server: '10.80.40.243',
  database: 'DB_PIONIER_PUNTOS',
  options: {
    encrypt: false,
    trustServerCertificate: true
  },
  pool: {
    max: 10,
    min: 0,
    idleTimeoutMillis: 30000
  }
};

// Crear pool global
let pool;
(async () => {
  try {
    pool = await mssql.connect(sqlServerConfig);
    console.log(`✅ Conexión a SQL Server establecida`);
  } catch (err) {
    console.error("❌ Error conectando a SQL Server:", err);
  }
})();

/**
 * Ejecuta un procedimiento almacenado con o sin parámetros.
 * Parámetros opcionales: [{ name: 'ParamName', value: 'valor' }, ...]
 */
async function executeProcedure(spName, params = []) {
  if (!pool) throw new Error("Pool no inicializado");

  try {
    const request = pool.request();

    // Agregar parámetros con nombre
    params.forEach(p => request.input(p.name, p.value));

    // Crear query
    const query = params.length
      ? `EXEC ${spName} ${params.map(p => `@${p.name}`).join(', ')}`
      : `EXEC ${spName}`;

    const res = await request.query(query);

    try {
      return JSON.parse(jsonString);
    } catch {
      return res.recordset;
    }
  } catch (err) {
    console.error("❌ Error ejecutando procedimiento:", err);
    throw err;
  }
}

module.exports = { executeProcedure };
