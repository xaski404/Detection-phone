# ANALIZA TECHNICZNA - ROZDZIAŁ 4
## Charakterystyka wykorzystanych technologii i narzędzi

---

## 1. KOMUNIKACJA BACKEND-FRONTEND

### 1.1. Strumieniowanie wideo
- **Protokół:** MJPEG (Motion JPEG) stream over HTTP
- **Endpoint:** `GET /api/camera/video_feed`
- **Implementacja:** 
  - Generator funkcji `generate_frames()` w `app.py` (linie 597-630)
  - Flask `Response` z `mimetype='multipart/x-mixed-replace; boundary=frame'`
  - Format: każda klatka jako osobny JPEG w multipart response
  - Częstotliwość: ~20 FPS (delay 0.05s między klatkami)
  - Przetwarzanie: klatki są przetwarzane przez filtr Canny (wykrywanie krawędzi) dla prywatności przed wysłaniem
- **Bezpieczeństwo:** Wymaga autoryzacji (`@login_required`)

### 1.2. REST API - Komunikacja danych
- **Biblioteka frontend:** Axios 1.6.7
- **Konfiguracja:**
  - Base URL: `process.env.REACT_APP_API_URL` (domyślnie puste - używa proxy)
  - Proxy: `http://localhost:5000` (zdefiniowane w `package.json`)
  - `withCredentials: true` - wysyłanie cookies dla sesji Flask-Login
- **Interceptory Axios:**
  - **Request:** Dodaje token Bearer z `localStorage` (jeśli istnieje)
  - **Response:** Automatyczne przekierowanie do `/login` przy błędzie 401
- **Format danych:** JSON (Content-Type: application/json)

### 1.3. Endpointy API

#### Autoryzacja:
- `POST /api/login` - Logowanie (Flask-Login session)
- `GET /api/logout` - Wylogowanie

#### Detekcje:
- `GET /api/detections?page=1&per_page=20` - Lista z paginacją
- `GET /api/detections/<id>` - Szczegóły detekcji
- `DELETE /api/detections/<id>` - Usunięcie pojedynczej
- `DELETE /api/detections/batch` - Masowe usuwanie
- `GET /detections/<filename>` - Pobranie obrazu (blob)

#### Dashboard i statystyki:
- `GET /api/dashboard-stats` - Statystyki w czasie rzeczywistym
- `GET /api/stats/detections_over_time` - Statystyki z ostatnich 7 dni

#### Ustawienia:
- `GET /api/settings` - Pobranie konfiguracji
- `POST /api/settings` - Aktualizacja konfiguracji
- `GET /api/settings/roi` - Pobranie ROI zones
- `POST /api/settings/roi` - Zapis ROI zones

#### Kamera:
- `POST /api/camera/start` - Ręczne uruchomienie
- `POST /api/camera/stop` - Ręczne zatrzymanie
- `GET /api/camera/status` - Status kamery
- `GET /api/camera/config_snapshot` - Snapshot do konfiguracji ROI (anonimizowany)

---

## 2. PRZECHOWYWANIE DANYCH

### 2.1. Baza danych
- **Silnik:** SQLite
- **ORM:** SQLAlchemy 3.1.1 (przez Flask-SQLAlchemy 3.1.1)
- **Migracje:** Flask-Migrate + Alembic
- **Plik bazy:** `admin.db` (domyślnie, konfigurowalne przez `DATABASE_URI`)

### 2.2. Modele danych (SQLAlchemy)

#### User:
- `id` (Integer, PK)
- `username` (String 80, unique)
- `password_hash` (String 255) - SHA-256 przez werkzeug.security

#### Detection:
- `id` (Integer, PK)
- `timestamp` (DateTime, default=utcnow)
- `location` (String 100) - nazwa strefy ROI lub kamery
- `confidence` (Float) - pewność detekcji (0.0-1.0)
- `image_path` (String 200) - nazwa pliku (bez pełnej ścieżki)
- `status` (String 20) - status detekcji
- `user_id` (Integer, FK do User, nullable)

#### Settings:
- `id` (Integer, PK)
- `schedule` (JSON) - harmonogram pracy kamery (7 dni)
- `roi_zones` (JSON) - lista stref ROI
- `config` (JSON) - konfiguracja systemu (threshold, notifications, etc.)
- `created_at` (DateTime)
- `updated_at` (DateTime, auto-update)

### 2.3. Przechowywanie obrazów
- **Lokalizacja:** Folder `./detections/` (względem `app.py`)
- **Format plików:** JPEG (`.jpg`)
- **Nazewnictwo:** `phone_YYYYMMDD_HHMMSS.jpg` (np. `phone_20241123_143015.jpg`)
- **Proces zapisu:**
  1. Wykrycie telefonu → zapis ORYGINALNEJ klatki do `./detections/phone_XXX.jpg`
  2. Worker thread → anonimizacja głów (Gaussian blur)
  3. Nadpisanie pliku zanonimizowaną wersją
  4. Zapis metadanych do bazy (tylko nazwa pliku w `image_path`)
- **Bezpieczeństwo:** Baza danych NIGDY nie zawiera oryginalnych obrazów - tylko zanonimizowane

### 2.4. Opcjonalne przechowywanie w chmurze
- **Serwis:** Cloudinary 1.40.0
- **Konfiguracja:** Przez zmienne środowiskowe (CLOUDINARY_CLOUD_NAME, API_KEY, API_SECRET)
- **Użycie:** Opcjonalne - obrazy mogą być uploadowane do Cloudinary po anonimizacji

---

## 3. STOS TECHNOLOGICZNY - BACKEND (Python)

### 3.1. Framework webowy
- **Flask 3.0.2** - główny framework
- **Flask-CORS 4.0.0** - Cross-Origin Resource Sharing
  - Konfiguracja: `origins=["http://localhost:3000"]`, `supports_credentials=True`
- **Flask-Login 0.6.3** - zarządzanie sesjami użytkowników
- **Flask-Migrate** - migracje bazy danych (Alembic)

### 3.2. Baza danych i ORM
- **SQLAlchemy 3.1.1** (przez Flask-SQLAlchemy 3.1.1)
- **SQLite** - silnik bazy danych
- **Flask-Migrate** - zarządzanie wersjami schematu

### 3.3. Przetwarzanie obrazu i wizja komputerowa
- **OpenCV 4.9.0.80** (`opencv-python`)
  - Przechwytywanie wideo (`cv2.VideoCapture`)
  - Preprocessing (CLAHE, unsharp masking)
  - Anonimizacja (Gaussian blur)
  - Operacje na macierzach (konwersje kolorów, resize, ROI)
- **NumPy 1.26.4** - operacje na macierzach obrazu
- **Pillow 10.2.0** - dodatkowe operacje na obrazach

### 3.4. Uczenie maszynowe
- **Ultralytics 8.1.2** - YOLOv8 dla detekcji telefonów
  - Model: `yolov8m.pt` (medium) z fallbackiem na `yolov8s.pt` (small)
  - Klasa: `class_id = 67` (cell phone w COCO dataset)
- **PyTorch 2.0.1** + **Torchvision 0.15.2** - zależności YOLOv8
- **Roboflow** - API do detekcji głów (`heads-detection/1`)

### 3.5. Powiadomienia
- **Vonage 3.2.0** - wysyłka SMS
- **yagmail 0.15.293** - wysyłka email (Gmail)
- **Cloudinary 1.40.0** - przechowywanie obrazów w chmurze

### 3.6. Narzędzia pomocnicze
- **python-dotenv 1.0.1** - zarządzanie zmiennymi środowiskowymi (`.env`)
- **werkzeug.security** - hashowanie haseł (SHA-256)
- **python-jose 3.3.0** - JWT (potencjalnie używane, ale głównie Flask-Login)

### 3.7. Biblioteki systemowe
- **threading** - wielowątkowość (Producer-Consumer pattern)
- **queue.Queue** - kolejka między wątkami
- **datetime** - zarządzanie czasem
- **logging** - logowanie zdarzeń

---

## 4. STOS TECHNOLOGICZNY - FRONTEND (React)

### 4.1. Framework i język
- **React 18.2.0** - biblioteka UI
- **TypeScript 4.9.5** - typowanie statyczne
- **Create React App** (react-scripts 5.0.1) - narzędzie do budowania
  - **NIE** Vite - używa CRA (Create React App)
  - Proxy: `http://localhost:5000` (w `package.json`)

### 4.2. Biblioteka UI
- **Material-UI (MUI) 5.15.10** - komponenty UI
  - `@mui/material` - główne komponenty
  - `@mui/icons-material` - ikony
  - `@mui/lab` - komponenty eksperymentalne (LoadingButton)
  - `@mui/x-data-grid` - zaawansowane tabele
  - `@mui/x-date-pickers` - selektory daty/czasu
- **@emotion/react** + **@emotion/styled** - styling engine dla MUI

### 4.3. Routing
- **React Router DOM 6.22.1** - routing SPA
  - `BrowserRouter` - główny router
  - Routes: `/login`, `/dashboard`, `/detections`, `/settings`

### 4.4. Komunikacja HTTP
- **Axios 1.6.7** - HTTP client
  - Instancja z konfiguracją baseURL, withCredentials
  - Interceptory dla autoryzacji i obsługi błędów
  - Modułowa struktura API (`api.ts`)

### 4.5. Zarządzanie stanem
- **React Context API** - zarządzanie stanem globalnym
  - `AuthContext` - stan autoryzacji
  - `ConfigContext` - konfiguracja systemu
- **NIE** Redux - używa Context API
- **NIE** React Query - używa Axios bezpośrednio

### 4.6. Wizualizacja danych
- **Recharts 2.10.3** - wykresy statystyczne
- **Chart.js 4.4.1** + **react-chartjs-2 5.2.0** - alternatywne wykresy

### 4.7. Narzędzia pomocnicze
- **date-fns 2.30.0** - manipulacja datami
- **react-responsive-masonry 2.1.7** - responsywna galeria obrazów
- **web-vitals 2.1.4** - metryki wydajności

### 4.8. Konfiguracja TypeScript
- **tsconfig.json:**
  - Target: ES2020
  - JSX: react-jsx
  - Strict mode: enabled
  - Module: ESNext

---

## 5. STRUKTURA PROJEKTU

### 5.1. Struktura katalogów (Backend - Python)

```
Detection-phone/
├── app.py                    # Główny plik Flask (endpointy API)
├── camera_controller.py      # Logika kamery, detekcji, anonimizacji
├── models.py                 # Modele SQLAlchemy (User, Detection, Settings)
├── requirements.txt          # Zależności Python
├── init_db.py               # Inicjalizacja bazy danych
├── reset_db.py              # Reset bazy danych
├── migrations/              # Migracje Alembic
│   ├── alembic.ini
│   ├── env.py
│   └── versions/
├── detections/              # Folder z obrazami detekcji (tworzony automatycznie)
├── static/                  # Pliki statyczne (CSS, JS)
│   ├── css/
│   └── js/
├── templates/               # Szablony HTML (legacy, nieużywane przez React)
└── models/                  # Modele ML (deploy.prototxt.txt)
```

### 5.2. Struktura katalogów (Frontend - React)

```
Detection-phone/
├── package.json             # Zależności Node.js
├── tsconfig.json            # Konfiguracja TypeScript
├── public/                  # Pliki publiczne
│   ├── index.html
│   ├── manifest.json
│   └── robots.txt
└── src/                     # Kod źródłowy React
    ├── App.tsx              # Główny komponent (routing)
    ├── index.tsx            # Entry point
    ├── index.css            # Globalne style
    ├── components/
    │   └── Layout.tsx       # Layout z nawigacją
    ├── contexts/
    │   ├── AuthContext.tsx  # Kontekst autoryzacji
    │   └── ConfigContext.tsx # Kontekst konfiguracji
    ├── pages/
    │   ├── Dashboard.tsx    # Strona główna (statystyki)
    │   ├── Detections.tsx   # Lista detekcji
    │   ├── Login.tsx        # Logowanie
    │   └── Settings.tsx     # Ustawienia systemu
    ├── services/
    │   └── api.ts           # Klient Axios + definicje API
    ├── theme/
    │   └── index.ts         # Konfiguracja MUI Theme
    └── utils/
        └── download.ts      # Narzędzia pomocnicze
```

### 5.3. Architektura komunikacji

```
Frontend (React)                    Backend (Flask)
     │                                    │
     ├─ Axios ──────────────────────────►│ REST API (JSON)
     │   (withCredentials: true)         │ /api/detections
     │                                    │ /api/settings
     │                                    │ /api/camera/*
     │                                    │
     ├─ <img src="/api/camera/video_feed">│ MJPEG Stream
     │                                    │ (multipart/x-mixed-replace)
     │                                    │
     └─ Axios (blob) ───────────────────►│ GET /detections/<filename>
                                          │ (obrazy JPEG)
```

### 5.4. Wzorzec architektoniczny
- **Producer-Consumer Pattern:**
  - **Producer (Main Thread):** Przechwytywanie klatek, detekcja YOLOv8, zapis do kolejki
  - **Consumer (Worker Thread):** Anonimizacja głów, zapis do bazy, powiadomienia
  - **Kolejka:** `queue.Queue` - bufor thread-safe między wątkami

---

## 6. DODATKOWE INFORMACJE TECHNICZNE

### 6.1. Bezpieczeństwo
- **Autoryzacja:** Flask-Login (sesje przez cookies) + potencjalnie JWT (localStorage)
- **CORS:** Konfigurowany dla `http://localhost:3000`
- **Hasła:** Hashowane przez werkzeug.security (SHA-256)
- **Anonimizacja:** Gaussian blur (99x99, sigma=30) - nieodwracalne

### 6.2. Wydajność
- **Frame skipping:** Przetwarzanie co 3. klatkę
- **Asynchroniczność:** Anonimizacja w osobnym wątku (nie blokuje detekcji)
- **Częstotliwość:** 20-30 FPS dla detekcji, ~20 FPS dla streamu wideo

### 6.3. Konfiguracja
- **Zmienne środowiskowe:** `.env` (python-dotenv)
- **Baza danych:** SQLite (plik `admin.db`)
- **Migracje:** Alembic (automatyczne wersjonowanie schematu)

---

## PODSUMOWANIE - KLUCZOWE PUNKTY DO ROZDZIAŁU 4

1. **Komunikacja:** MJPEG stream (HTTP) dla wideo, REST API (JSON) dla danych, Axios jako HTTP client
2. **Baza danych:** SQLite + SQLAlchemy ORM, migracje przez Flask-Migrate/Alembic
3. **Przechowywanie obrazów:** Lokalny folder `./detections/`, tylko zanonimizowane obrazy w bazie
4. **Backend:** Flask + OpenCV + YOLOv8 + Roboflow, wielowątkowość (Producer-Consumer)
5. **Frontend:** React 18 + TypeScript + Material-UI, Create React App (nie Vite), Context API dla stanu
6. **Architektura:** Rozdzielona (separated frontend/backend), SPA z REST API
