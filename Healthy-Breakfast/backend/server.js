const express = require("express");
const cors = require("cors");
const app = express();

const PORT = process.env.PORT || 8080;

app.use(cors());
app.use(express.json());

const menu = [
  { id: 1, name: "Oats Porridge", price: 45 },
  { id: 2, name: "Vegetable Upma", price: 50 },
  { id: 3, name: "Sprouts Salad", price: 60 }
];

app.get("/api/menu", (req, res) => {
  res.json(menu);
});

app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});
