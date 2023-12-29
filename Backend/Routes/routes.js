const express = require("express");
const router = express.Router(); 
const User = require("../Models/usermodel.js")

router.get("/", async (req, res) => {
    res.status(200).json({"test": "This is test"});
});

router.get("/accountinfo/:username", async (req, res) => {
    const user = await User.findOne({
        userName: req.params.username
    });
    res.status(200).json({"userId": user.id,"userName":user.userName});
});

router.post("/registration", async (req, res) => {
    await User.create({
        userName: req.body.userName,
        password: req.body.password,
    });
    res.status(200).json({"message": "User registered successfully!"});
});

router.get("/login", async (req, res) => {
    const user = await User.findOne({
        userName: req.body.userName
    });

    if (user && req.body.password == user.password) {
        res.status(200).json({"message": "Logged in successfully!"});
    }
    else {
        res.status(400).json({"message": "Incorrect username or password!"});
    }
});

router.put("/editUser/:id", async (req, res) => {
    await User.findByIdAndUpdate(req.params.id, {
        userName: req.body.userName,
        password: req.body.password,
    });

    res.status(200).json({"message": "Update successful!"});
    
});

router.delete("/deleteUser/:id", async (req, res) => {
    await User.findByIdAndDelete(req.params.id);
    res.status(200).json({"message": "User " + req.params.id + " deleted successfully!"});
});





module.exports = router;