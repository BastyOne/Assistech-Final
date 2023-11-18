require('dotenv').config(); 


const mysql = require('mysql2');
// Cargar variables de entorno desde un archivo .env

const connection = mysql.createConnection({
  host: process.env.DB_HOST || '127.0.0.1',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_DATABASE || 'assistech',
  port: process.env.DB_PORT || 3306,
});


connection.connect((err) => {
  if (err) {
    console.error('Error al conectar a la base de datos: ' + err.message);
  } else {
    console.log('Conexión a la base de datos MySQL exitosa');
  }
});

module.exports = connection;


