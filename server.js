const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");
const bodyParser = require("body-parser");

const app = express();
app.use(cors());
app.use(bodyParser.json());

const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "flutter_crud",
});

db.connect((err) => {
  if (err) throw err;
  console.log("MySQL Connected...");
});





// Forda new user (when u add user)
app.post("/users", (req, res) => {
  const { username, email, password } = req.body;
  if (!username || !email || !password) {
    return res.status(400).json({ error: "All fields are required" });
  }

  db.query(
    "INSERT INTO users (username, email, password) VALUES (?, ?, ?)",
    [username, email, password],
    (err, result) => {
      if (err) throw err;
      res.json({ message: "User added", id: result.insertId });
    }
  );
});




// All Users 
app.get("/users", (req, res) => {
  db.query("SELECT id, username, email FROM users", (err, results) => {
    if (err) throw err;
    res.json(results);
  });
});




// Forda update user (when u click the edit)
app.put("/users/:id", (req, res) => {
  const { username, email, password } = req.body;
  db.query(
    "UPDATE users SET username = ?, email = ?, password = ? WHERE id = ?",
    [username, email, password, req.params.id],
    (err) => {
      if (err) throw err;
      res.json({ message: "User updated" });
    }
  );
});



// Forda delete user (when u click the bin image)
app.delete("/users/:id", (req, res) => {
  db.query("DELETE FROM users WHERE id = ?", [req.params.id], (err) => {
    if (err) throw err;
    res.json({ message: "User deleted" });
  });
});

app.listen(5000, () => {
  console.log("Server running on port 5000");
});
