# 📈 BTC Prediction Game - Rails API

This is a Rails API backend for a fun prediction game where users guess whether the price of Bitcoin (BTC) will go **up** or **down**. Points are awarded or deducted based on how accurate the guesses are. The app uses real-time BTC price data via Coinbase, JWT-based authentication, and background job processing via Solid Queue.

---

## 🛠️ Tech Stack

- **Rails 8**  
- **PostgreSQL**  
- **Devise + JWT** for authentication  
- **Solid Queue** for background jobs  

---

## 🧠 Core Features

### 🔐 User Authentication
- Users can **sign up** and **log in** with email and password.
- Auth is handled via **Devise + JWT** tokens.

### 📊 BTC Price Fetching
- The current BTC price is fetched from the **Coinbase API**.
- Prices are **cached** to reduce API load (default: 30 seconds).

### 🎯 Make a Prediction (aka "Bid")
- Users submit a prediction whether the price will go *up* or *down*.
- Only **one active bid** is allowed at a time per user.
- The system waits 60 seconds and then **resolves** the prediction in the background.

### ⚙️ Background Jobs
- Predictions are resolved by a **Solid Queue** job after 60 seconds.
- BTC price is fetched again during resolution to determine result.
- Failed jobs will automatically retry up to 3 times.

---

## 🌐 Frontend

This project uses a separate React frontend.  
You can find it here:  
👉 [BTC Game Frontend](https://github.com/pallavibanakar/btc_game)

---

## 🧩 Installation and Setup

### ✅ Ruby version  
```
3.4.3
```

### ⚙️ Configuration  
Set up the following ENV variables:
- `DATABASE_URL`  
- `RAILS_MASTER_KEY`  
- `DEVISE_JWT_SECRET_KEY`

### 🛢️ Database Creation  
```bash
rails db:create
rails db:migrate
# or simply
rails db:prepare
```

### 🚀 Start Server  
```bash
rails s
```

### 🧵 Services (Job Queues)  
```bash
bin/jobs
```

### 🧪 How to Run the Test Suite  
```bash
rspec
```

### 🚢 Deployment Instructions  
Have provided the link of the deployed application
