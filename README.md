# Automatic Smartphone Detection System for Elementary Schools to Improve Student Concentration

Application for monitoring mobile phone usage by students during class. The system was designed for elementary schools, where the problem of inappropriate smartphone use during lessons is particularly visible.

## Problem

Nowadays, students often use phones during class, which negatively affects concentration and academic performance. Teachers have difficulty controlling this phenomenon, especially in larger classes. The system was created to help monitor this problem automatically and objectively.

## Features

- Real-time phone detection during lessons using YOLOv8 model
- Automatic face anonymization of students for privacy protection (head blurring via Roboflow AI)
- Web panel for viewing detections and managing the system
- History of all detections with export capability
- Configurable camera work schedules (adapted to lesson plans)
- ROI Zones - ability to define specific locations in the classroom (desks, rows)
- Notifications for teachers:
  - Email with anonymized photo attached
  - SMS with link to photo
- Cloud integration for photo storage
- Login system for teachers and administrators

## Project Structure

```
Detection-phone/
├── app.py
├── camera_controller.py
├── models.py
├── requirements.txt
├── package.json
├── src/
│   ├── components/
│   ├── pages/
│   ├── contexts/
│   └── App.tsx
├── detections/
├── instance/admin.db
└── static/
```

## Requirements

- Python 3.8-3.12 (backend)
- Node.js 14 or newer (frontend)
- Web camera (can be built-in laptop or external)
- Internet access (for Roboflow AI, notifications and cloud storage)

## Installation

### 1. Download the project

```bash
git clone <repository-url>
cd Detection-phone
```

### 2. Install dependencies

Backend (Python):
```bash
pip install -r requirements.txt
```

Frontend (React):
```bash
npm install
```

### 3. Configure environment variables

Create a `.env` file in the main directory:

```env
# Email Configuration
GMAIL_USER=your_email@gmail.com
GMAIL_APP_PASSWORD=your_16_character_app_password
EMAIL_RECIPIENT=teacher@school.pl

# Cloudinary Configuration
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# SMS Configuration (Optional)
VONAGE_API_KEY=your_vonage_key
VONAGE_API_SECRET=your_vonage_secret
VONAGE_FROM_NUMBER=PhoneDetection
VONAGE_TO_NUMBER=48123456789
```

### 4. Run the application

You need to run the backend and frontend in separate terminals:

Terminal 1 - Backend (Flask):
```bash
flask run --debug --no-reload
```
Backend runs on `http://localhost:5000`

Terminal 2 - Frontend (React):
```bash
npm start
```
Frontend runs on `http://localhost:3000`

The application will be available at `http://localhost:3000`

Default login credentials:
- Username: `admin`
- Password: `admin`

### 5. System configuration

1. Log in to the panel at `http://localhost:3000`
2. Go to Settings → Set camera schedule (adjust to lesson plan)
3. Configure notifications (Email/SMS) if you want to receive alerts
4. Adjust phone detection confidence threshold (default: 0.2)
5. Define ROI zones for specific locations in the classroom (details below)
6. The system will automatically start detecting phones during scheduled hours

## Configuration

The system can be configured through the Settings page:

- Weekly schedule - Automatic camera activation on specific days with start/end times (e.g., Monday 8:00-14:00)
- Head anonymization - Student privacy protection (head blurring via Roboflow AI)
- Phone detection confidence - Adjust detection sensitivity (default: 0.2, range: 0.0-1.0)
- Notification channels (Email, SMS) - Alert preferences for teachers
- Camera selection - Choose which camera to use (if you have multiple)
- ROI Zones - Define specific locations in the classroom (see below)

### ROI Zones Configuration for Classrooms

ROI Zones (Region of Interest) allow you to define specific areas in the classroom where phone detection should occur. This is particularly useful in schools where we want to monitor specific desks or locations.

Benefits:
- Monitor specific desks or rows
- Ignore areas where phones are allowed (e.g., teacher's desk)
- Reduce false alarms from background objects
- Per-zone alert muting (prevents spam when a student keeps using their phone)

How to configure:

1. Load Configuration Image:
   - Go to Settings → ROI Zones section
   - Click the "Load Configuration Image" button
   - System captures current camera view as background

2. Select Drawing Mode:
   - Single Zone: Draw individual zones one after another
   - Grid Generator: Draw one rectangle and automatically generate a grid (perfect for classrooms!)

3. Drawing Single Zone:
   - Click and drag on the image to draw a rectangle
   - Release mouse to finish
   - Enter zone name (e.g., "Desk 1", "Row 2 - Seat 3")
   - Click "Save Zone"

4. Grid Generator (Recommended for Classrooms):
   - Draw one large rectangle covering all seats in the classroom
   - Set rows (e.g., 4) and columns (e.g., 5)
   - Choose naming mode:
     - Sequential: "Desk 1", "Desk 2", ..., "Desk 20"
     - Grid: "R1-M1", "R1-M2", ..., "R4-M5"
   - Optional: Add prefix (e.g., "Desk")
   - Click "Generate Grid" → Creates 20 zones automatically!

5. Zone Editing:
   - Move: Click and drag zone
   - Resize: Drag corner handles
   - Rename: Click edit icon
   - Delete: Click delete icon

6. Auto-Save:
   - Zones automatically save 2 seconds after changes
   - Green notification confirms save

Per-Zone Muting:

Each zone has independent 5-minute alert muting. This prevents spam when a student keeps using their phone:

```
Example:
14:00 - Phone in "Desk 1" → Alert sent, "Desk 1" muted for 5 min
14:01 - Phone in "Desk 2" → Alert sent (separate muting)
14:02 - Phone in "Desk 1" → Ignored (still muted)
14:06 - Phone in "Desk 1" → Alert sent (muting expired)
```

Example Configuration for Classrooms:

```
4 rows × 5 columns = 20 zones

┌─────────┬─────────┬─────────┬─────────┬─────────┐
│ Desk 1  │ Desk 2  │ Desk 3  │ Desk 4  │ Desk 5  │
├─────────┼─────────┼─────────┼─────────┼─────────┤
│ Desk 6  │ Desk 7  │ Desk 8  │ Desk 9  │ Desk 10 │
├─────────┼─────────┼─────────┼─────────┼─────────┤
│ Desk 11 │ Desk 12 │ Desk 13 │ Desk 14 │ Desk 15 │
├─────────┼─────────┼─────────┼─────────┼─────────┤
│ Desk 16 │ Desk 17 │ Desk 18 │ Desk 19 │ Desk 20 │
└─────────┴─────────┴─────────┴─────────┴─────────┘

Grid Generator Settings:
- Rows: 4
- Columns: 5
- Naming Mode: Sequential
- Prefix: "Desk"

Result: 20 zones with independent muting!
```

## How It Works

The system uses a Producer-Consumer pattern for efficient, non-blocking detection:

### Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│         MAIN THREAD - Real-Time Detection               │
│                                                         │
│  📷 Camera → 🔍 Phone Detection (YOLOv8)               │
│                        │                                │
│                        ↓ (phone detected)                │
│                  💾 Save ORIGINAL frame                 │
│                        │                                │
│                        ↓                                │
│                  📤 Add to Queue                        │
└────────────────────────┼────────────────────────────────┘
                         │
                    Queue<filepath>
                         │
                         ↓
┌────────────────────────┼────────────────────────────────┐
│         WORKER THREAD - Offline Head Anonymization      │
│                        │                                │
│                  📥 Get from Queue                      │
│                        ↓                                │
│            👁️ Detect Heads (Roboflow AI)              │
│                        ↓                                │
│            🔒 Blur Heads (Gaussian 99x99)              │
│                        ↓                                │
│            💾 Overwrite with anonymized version        │
│                        ↓                                │
│            💾 Save to Database                         │
│                        ↓                                │
│            📧 Send Notifications (Email/SMS)           │
└─────────────────────────────────────────────────────────┘
```

### Key Features:

1. Real-Time Phone Detection (Main Thread): 
   - Camera captures frames at 20-30 FPS
   - YOLOv8 detects phones immediately
   - Saves original frame to disk
   - Adds to processing queue

2. Offline Head Anonymization (Worker Thread): 
   - Processes queue asynchronously
   - Detects heads using Roboflow AI model (confidence ≥ 40%)
   - Blurs entire head region with Gaussian blur (99x99, sigma=30)
   - Overwrites original file with anonymized version
   - Saves to database (only anonymized images!)
   - Sends notifications if enabled

3. ROI Zones and Muting:
   - Define multiple detection zones (e.g., "desk 1", "desk 2")
   - Per-zone muting for 5 minutes prevents alert spam
   - Detections outside zones are ignored

This architecture ensures:
- Real-time phone detection at 20-30 FPS (not blocked by anonymization)
- Accurate head detection using Roboflow AI (90%+ accuracy)
- Database contains only anonymized images
- Non-blocking operations
- Project with priority on student privacy

Detailed system architecture: see CURRENT_ARCHITECTURE.md

## Tech Stack

### Backend

- Flask - Web framework with SQLAlchemy ORM
- SQLite - Database
- YOLOv8 - Phone detection (Ultralytics)
- Roboflow AI - Head detection for anonymization
- OpenCV - Image processing and Gaussian blur
- Cloudinary - Cloud image storage
- Vonage API - SMS notifications
- Yagmail - Email notifications
- Threading - Non-blocking processing queue

### Frontend

- React 18 with TypeScript
- Material-UI (MUI) - UI components
- React Router - Navigation
- Recharts - Data visualization
- Axios - HTTP client
- Chart.js - Additional charts

## Privacy and Security

- JWT Authentication - Secure user sessions
- Secure password storage (hashed with Werkzeug)
- API key management via environment variables
- Project with priority on student privacy:
  - Original frames are saved temporarily
  - Heads are detected and blurred using Roboflow AI
  - Original files are overwritten with anonymized versions
  - Database contains only anonymized images
  - Gaussian blur (99x99) is irreversible
- Ready HTTPS support

## Troubleshooting

### Camera doesn't start
- Check camera permissions in Windows settings
- Verify that camera schedule is set correctly
- Make sure no other application is using the camera (close Zoom, Teams, OBS, etc.)
- Try restarting the Flask server

### Heads are not being blurred
- System uses Roboflow AI for head detection (90%+ accuracy)
- Check if head anonymization is enabled in Settings
- Verify internet connection (Roboflow requires API access)
- Check console logs for Roboflow API errors

### Too many false phone detections
- Increase phone detection confidence threshold in Settings (default: 0.2)
- Higher values = fewer false alarms (try 0.3-0.5)
- Define ROI zones to limit detection to specific areas in the classroom

### Frontend doesn't connect to backend
- Make sure both Flask (port 5000) and React (port 3000) are running
- Check if `proxy` is set to `http://localhost:5000` in `package.json`
- Verify that CORS is enabled in Flask backend (should be automatic)
- Check browser console for CORS errors

### Notifications don't work
- Email: Verify that Gmail App Password is correct (16 characters, no spaces)
- SMS: Check Vonage API credentials and phone number format
- Cloudinary: Verify cloud name, API key and API secret
- Check console logs for detailed error messages

## License

MIT License
