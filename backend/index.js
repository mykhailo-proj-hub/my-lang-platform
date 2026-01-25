require("dotenv").config();
const express = require("express");
const http = require('http');
const cors = require("cors");
const cookieParser = require("cookie-parser");
const authRoutes = require("./src/routes/auth");
const chatRoutes = require('./src/routes/chat');
const practiceRoutes = require('./src/routes/practice');
const aiRoutes = require('./src/routes/ai');
const analyticsRoutes = require('./src/routes/analytics');
const initializeSocket = require('./src/socket'); // Імпорт сокетів

const app = express();
const server = http.createServer(app);

// Ініціалізація сокетів
const io = initializeSocket(server);

app.use(cors({ origin: "http://localhost:3000", credentials: true }));
app.use(express.json());
app.use(cookieParser());

app.use("/api/auth", authRoutes);
app.use('/api/chat', chatRoutes(io));
app.use('/api/ai', aiRoutes);
app.use('/api/practice', practiceRoutes);
app.use('/api/analytics', analyticsRoutes);

const PORT = process.env.PORT;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));