const express = require("express");
const app = express();
const mongoose = require("mongoose");
const dotenv = require("dotenv").config();

mongoose.connect(process.env.MONGODBURL);


app.use(express.json());
app.use(express.urlencoded({extended:false}));


app.use("/api/routes", require("./Routes/routes"));

//localhost:3000/api/routes/

app.listen(3000, () => console.log("Running on port 3000"));