const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const http = require('http');

require('dotenv').config();

const authRouter = require("./routes/auth");
const documentRouter = require("./routes/document");
const Document = require('../server/models/document');

const PORT = process.env.PORT || 3001;
const app = express();

const DB = process.env.DB_URL;

var server = http.createServer(app);
var io = require('socket.io')(server, {
  cors: {
    origin: "*", // Or specify your Flutter app's URL
    methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
    allowedHeaders: ["Content-Type", "Authorization", "x-auth-token"],
    credentials: true
  }
});

// Middleware
app.use(express.json());
app.use(cors({
  origin: "*", // Or specify your Flutter app's URL
  methods: ["GET", "POST", "PUT", "DELETE", "PATCH"],
  allowedHeaders: ["Content-Type", "Authorization", "x-auth-token"],
  credentials: true
}));

// Routes
app.use(authRouter);
app.use(documentRouter);

// Database connection
mongoose.connect(DB).then(() => {
  console.log("Database Connected");
}).catch((err) => {
  console.log("DB URL = " + DB);
  console.log(err);
});

// Socket.io logic
io.on('connection', (socket) => {
  console.log('socket connected : ' + socket.id);
  
  socket.on('join', (documentId) => {
    socket.join(documentId);
    console.log("JOINED!!");
    console.log("joined the room ID = " + documentId);
  });

  socket.on('typing', (data) => {
    socket.to(data.room).emit('changes', data);
  });

  socket.on('save', (data) => {
    autoSaveData(data);
  });
});

const autoSaveData = async (data) => {
    try{
        let document = await Document.findById(data.room);
        document.content = data.delta;
        document = await document.save();
    }catch(e){
        console.log(e);
    }
};

server.listen(PORT, "0.0.0.0", () => {
  console.log(`Listening to port: ${PORT}`);
});