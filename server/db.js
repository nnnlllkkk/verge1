const sql = require('mssql');
require('dotenv').config();

const config = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    server: 'localhost',
    database: process.env.DB_DATABASE,
    options: {
        encrypt: false,
        trustServerCertificate: true,
        instanceName: 'SQLEXPRESS' 
    }
};

async function connectDB() {
    try {
        let pool = await sql.connect(config);
        console.log("Успешное подключение к базе данных MS SQL!");
        return pool;
    } catch (err) {
        console.error("ОШИБКА ПОДКЛЮЧЕНИЯ:", err.message);
    }
}

module.exports = { sql, connectDB };