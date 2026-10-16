const express = require('express');
const sql = require('mssql');
const cors = require('cors');
const path = require('path');
const fs = require('fs');

const app = express();

app.use(cors());
app.use(express.json());

const publicPath = path.join(__dirname, '..', 'public');

// Раздача статики
app.use(express.static(publicPath));

// Правильная конфигурация для именованного экземпляра SQLEXPRESS в Node.js
const dbConfig = {
    user: 'sa',
    password: '12345',
    server: '127.0.0.1',
    database: 'WEB_db',
    options: {
        encrypt: false,
        trustServerCertificate: true,
        instanceName: 'SQLEXPRESS' // Вот эта строчка заставляет драйвер найти правильный порт через Browser
    }
};

async function connectDB() {
    try {
        await sql.connect(dbConfig);
        console.log('УСПЕШНО ПОДКЛЮЧИЛИСЬ К БАЗЕ ДАННЫХ VERGE!');
    } catch (err) {
        console.error('Ошибка подключения к MS SQL:', err.message);
    }
}
connectDB();

// API Endpoints
app.get('/api/products', async (req, res) => {
    try {
        const result = await sql.query('SELECT * FROM Products');
        res.json(result.recordset);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Главная
app.get('/', (req, res) => {
    if (!fs.existsSync(publicPath)) {
        return res.status(404).send('Папка public не найдена!');
    }
    const files = fs.readdirSync(publicPath);
    const homeFile = files.find(f => f.toLowerCase().includes('01home') || f.toLowerCase().includes('home')) || files[0];
    
    if (homeFile) {
        res.sendFile(path.join(publicPath, homeFile));
    } else {
        res.status(404).send('Главная страница не найдена в папке public.');
    }
});

// УМНЫЙ РОУТЕР: Находит файл, даже если в названии запятая или опечатка
app.get('/:page', (req, res) => {
    const requested = req.params.page.replace('.html', '').toLowerCase();
    
    if (!fs.existsSync(publicPath)) {
        return res.status(404).send('Папка public не найдена!');
    }

    const files = fs.readdirSync(publicPath);
    const matchedFile = files.find(f => f.toLowerCase().replace(',', '.').includes(requested));

    if (matchedFile) {
        res.sendFile(path.join(publicPath, matchedFile));
    } else {
        res.status(404).send(`Файл не найден. Доступные файлы: ${files.join(', ')}`);
    }
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(` Сервер запущен на http://localhost:${PORT}`);
});