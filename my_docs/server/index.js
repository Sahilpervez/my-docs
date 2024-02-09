const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const http = require('http')

require('dotenv').config();

const authRouter = require("./routes/auth");
const documentRouter = require("./routes/document");
const Document = require('../server/models/document');

const PORT = process.env.PORT | 3001;
const app = express();

const DB = process.env.DB_URL;

var server = http.createServer((req, res) => {
    const headers = {
      'Access-Control-Allow-Origin': '*', /* @dev First, read about security */
      'Access-Control-Allow-Methods': 'OPTIONS, POST, GET',
      "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept,x-auth-token"
      /** add other headers as per requirement */
    };
  
    if (req.method === 'OPTIONS') {
      res.writeHead(204, headers);
      res.end();
      return;
    }
  
    if (['GET', 'POST'].indexOf(req.method) > -1) {
      res.writeHead(200, headers);
      res.end('Hello World');
      return;
    }
  
    res.writeHead(405, headers);
    res.end(`${req.method} is not allowed for the request.`);
  });
var io = require('socket.io')(server);
app.use(express.json());
app.use(authRouter);
app.use(documentRouter);
app.use(cors({origin : true,credentials : true}));

// app.use(function(req, res, next) {
//     res.header("Access-Control-Allow-Origin", "*");
//     res.header("Access-Control-Allow-Methods", "GET,PUT,PATCH,POST,DELETE");
//     res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept,x-auth-token");
//     next();
//   });

mongoose.connect(DB).then((value) => {
    console.log("DataBase Connected");
}).catch((err) => {
    console.log("DB URL = " + DB)
    console.log(err);
});

io.on('connection',(socket)=>{
    console.log('socket connected : '+ socket.id );
    socket.on('join',(documentId)=>{
        socket.join(documentId);
        console.log("JOINED!!");
        console.log("joined the room ID = " + documentId);
    });

    socket.on('typing', (data)=>{
        socket.to(data.room).emit('changes',data);
        // console.log("Boradcasting now...")
    });

    socket.on('save', (data) => {
        autoSaveData(data);
    });
})

const autoSaveData = async (data) => {
    let document = await Document.findById(data.room);
    document.content = data.delta;
    document = await document.save();
}

server.on('request', app);

server.listen(PORT, "0.0.0.0", () => {
    console.log(`Listening to port: ${PORT}`);
})
