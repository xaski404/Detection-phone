# LinkedIn Project Description

Technologies:

Backend: 🐍 Python, 🔥 Flask, 🗄️ SQLAlchemy, 💾 SQLite, 🤖 YOLOv8 (Ultralytics), 👁️ Roboflow AI, 📸 OpenCV, ☁️ Cloudinary, 📧 Yagmail, 📱 Vonage API, 🧵 Threading, 🔐 Flask-Login, 🔒 Werkzeug Security

Frontend: ⚛️ React 18, 📘 TypeScript, 🎨 Material-UI (MUI), 🧭 React Router, 📊 Recharts, 📈 Chart.js, 🌐 Axios, 🎯 React Context API

Automatic Smartphone Detection System for Elementary Schools is a real-time computer vision application designed to help teachers monitor and reduce inappropriate smartphone usage during classes. The system uses YOLOv8 deep learning model to detect mobile phones in real-time (20-30 FPS) through classroom cameras, automatically anonymizes student faces using Roboflow AI and Gaussian blur to ensure GDPR compliance, and sends instant notifications to teachers via email and SMS. The application features a modern web dashboard built with React and Material-UI for viewing detections, managing camera schedules, configuring ROI zones for specific classroom areas, and analyzing detection statistics. The backend, built with Flask and SQLAlchemy, implements a Producer-Consumer pattern with multithreading to ensure non-blocking real-time detection while processing face anonymization asynchronously. The system includes advanced image preprocessing (CLAHE, unsharp masking) for improved detection accuracy, configurable detection zones with per-zone alert muting, and secure authentication with JWT and session management. All detected images are automatically anonymized before storage, ensuring student privacy compliance with GDPR regulations.








