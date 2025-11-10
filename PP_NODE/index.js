/********** NODE JS CONEXION CON MYSQL *************************/
// const mysql = require('mysql2');
// const connection = mysql.createConnection({
//     host: '11.12.1.25',
//     user: 'db_eu_local',
//     password: 'o83R%V*!A5',
//     database: 'modipsa_xerotolerance1'
// });
// connection.connect((err) => {
//     if (err) {
//         console.error('Error al conectar a la base de datos:', err.stack);
//         return;
//     }
//     console.log('Conectado a la base de datos MySQL con ID:', connection.threadId);
// });
// connection.query('SELECT * FROM admin', (err, results, fields) => {
//     if (err) {
//         console.error('Error al realizar la consulta:', err.stack);
//         return;
//     }
//     console.log('Resultados de la consulta:', results);
// });
// connection.end();

/********** NODE JS CONEXION CON SQL SERVER *************************/
/*
// un framework de Node.js que facilita crear servidores HTTP y manejar rutas (endpoints) de forma sencilla.
*/
const express = require('express');
/*
Este módulo sirve para interpretar el cuerpo (body) de las peticiones HTTP.
Ejemplo: convierte el JSON que envía un cliente en un objeto JavaScript para que lo puedas usar en tus rutas
*/
const bodyParser = require('body-parser');
const userRoutes = require('./routes/userRoutes');


const app = express();
const port = 8383;

/*
Permite que Express entienda y procese cuerpos de tipo JSON.
*/
app.use(bodyParser.json());
/*
Permite procesar datos enviados desde formularios HTML.
La opción { extended: true } permite analizar datos complejos (por ejemplo, objetos anidados).
*/
app.use(bodyParser.urlencoded({ extended: true }));


// Conectar el workerRoutes a la app
app.use('/api', userRoutes);

// Iniciar el servidor
app.listen(port, () => {
    console.log(`Server escuchando en el puerto http://10.80.41.179:${port}`);
});