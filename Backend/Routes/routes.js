const express = require("express");
const router = express.Router(); 

router.get("/", async (req, res) => {
    res.status(200).json({"test": "This is test"});
});

router.get("/login", async (req, res) => {
    res.status(200).json({"login": "You are logged in"});
});

router.get("/userlogin/:id", async (req, res) => {
    res.status(200).json({"id": req.params.id});
});

module.exports = router;