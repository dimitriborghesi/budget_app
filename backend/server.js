const express = require("express");
const axios = require("axios");
require("dotenv").config();

const app = express();

let accessToken = null;

// 🔐 TOKEN TINK
app.get("/token", async (req, res) => {
  try {
    const response = await axios.post(
      "https://api.tink.com/api/v1/oauth/token",
      new URLSearchParams({
        client_id: process.env.CLIENT_ID,
        client_secret: process.env.CLIENT_SECRET,
        grant_type: "client_credentials",
        scope: "accounts:read transactions:read",
      }),
      {
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      }
    );

    accessToken = response.data.access_token;

    res.json(response.data);
  } catch (e) {
    console.log("ERREUR TOKEN:", e.response?.data);
    res.status(500).json(e.response?.data);
  }
});

// 🔗 LINK TINK
app.get("/link", async (req, res) => {
  try {
    const linkUrl = `https://link.tink.com/1.0/authorize/?client_id=${process.env.CLIENT_ID}&redirect_uri=http://localhost:3000&scope=accounts:read,transactions:read`;

    res.json({ url: linkUrl });
  } catch (e) {
    console.log(e);
    res.status(500).json(e);
  }
});

// 🚀 START SERVER
app.listen(3000, () => {
  console.log("Server Tink 🚀 http://localhost:3000");
});

app.get("/user", async (req, res) => {
  try {
    const response = await axios.post(
      "https://api.tink.com/api/v1/user/create",
      {},
      {
        headers: {
          Authorization: `Bearer ${accessToken}`,
        },
      }
    );

    res.json(response.data);
  } catch (e) {
    console.log("ERREUR USER:", e.response?.data);
    res.status(500).json(e.response?.data);
  }
});
app.get("/exchange", async (req, res) => {
  const code = req.query.code;

  try {
    const response = await axios.post(
      "https://api.tink.com/api/v1/oauth/token",
      new URLSearchParams({
        client_id: process.env.CLIENT_ID,
        client_secret: process.env.CLIENT_SECRET,
        grant_type: "authorization_code",
        code: code,
      }),
      {
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
      }
    );

    res.json(response.data);
  } catch (e) {
    console.log("ERREUR EXCHANGE:", e.response?.data);
    res.status(500).json(e.response?.data);
  }
});

app.get("/transactions", async (req, res) => {
  const token = req.query.token;

  try {
    const response = await axios.get(
      "https://api.tink.com/data/v2/transactions?pageSize=100",
      {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      }
    );

    res.json(response.data);
  } catch (e) {
    console.log("ERREUR TRANSACTIONS:", e.response?.data);
    res.status(500).json(e.response?.data);
  }
});

app.get("/accounts", async (req, res) => {
  const token = req.query.token;

  const response = await axios.get(
    "https://api.tink.com/data/v2/accounts",
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    }
  );

  res.json(response.data);
});