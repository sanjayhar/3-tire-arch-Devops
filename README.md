# 3-tire-arch-Devops

# 3-Tier Architecture Project (Render Deployment)

## 💡 Overview
This project implements a classic 3-tier architecture using:
- Frontend: HTML/React (Render Docker Service)
- Backend: Java Spring Boot (Render Docker Service)
- Database: PostgreSQL (Render PostgreSQL Service)

## 📦 Folder Structure
- `frontend/`: Static site or React app with Dockerfile
- `backend/`: Spring Boot app with Dockerfile
- `database/`: Schema scripts (optional)

## 🚀 Deployment
1. Push this repo to GitHub
2. Deploy each component (frontend, backend) as a separate **Docker Web Service** on Render
3. Use Render PostgreSQL as DB
4. Link backend to DB using `DATABASE_URL` environment variable

## 🔗 Live URLs
- Frontend: https://your-frontend.onrender.com
- Backend: https://your-backend.onrender.com
