const express = require("express");
const app = express();


app.use(express.json());
app.use(express.urlencoded({extended:false}));


app.use("/api/routes", require("./Routes/routes"));

//localhost:3000/api/routes/

app.listen(3000, () => console.log("Running on port 3000"));