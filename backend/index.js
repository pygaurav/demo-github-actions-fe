var express = require("express");
var app = express(); app.listen(8000, () => {
    console.log("Server running on port 8000");
});

app.get("/", (req, res, next) => {
    res.json(["Hello World"]);
});