const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const authRouter = require("./routes/auth");
const documentRouter = require("./routes/document");

const PORT = process.env.PORT | 3001;
const app = express();

const DB = "mongodb+srv://sahilpervez26122002:Solution12345@cluster0.mo0ctim.mongodb.net/?retryWrites=true";

app.use(express.json());
app.use(authRouter);
app.use(documentRouter);
app.use(cors());

mongoose.connect(DB).then((value) => {
    console.log("DataBase Connected");
}).catch((err) => {
    console.log(err);
});

app.listen(PORT, "0.0.0.0", () => {
    console.log(`Listening to port: ${PORT}`);
})