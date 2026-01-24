# INFORMACJE TECHNICZNE DO PREZENTACJI
## System automatycznej detekcji smartfonów w szkołach podstawowych

---

## 1. OGÓLNY OPIS PROJEKTU

### Cel systemu
System został zaprojektowany do automatycznego wykrywania telefonów komórkowych podczas zajęć lekcyjnych w szkołach podstawowych. Głównym celem jest pomoc nauczycielom w monitorowaniu problemu nieodpowiedniego korzystania ze smartfonów przez uczniów, przy jednoczesnym zachowaniu prywatności uczniów poprzez automatyczną anonimizację ich wizerunków zgodnie z wymogami RODO.

### Główne funkcjonalności
- **Detekcja w czasie rzeczywistym** - Wykrywanie telefonów komórkowych podczas lekcji z prędkością 20-30 FPS
- **Automatyczna anonimizacja** - Zamazywanie głów uczniów na zdjęciach przed zapisem do bazy danych
- **Panel webowy** - Interfejs do przeglądania detekcji, statystyk i zarządzania systemem
- **Strefy ROI** - Możliwość definiowania konkretnych miejsc w klasie (ławki, rzędy)
- **Harmonogram pracy** - Automatyczne włączanie/wyłączanie kamery zgodnie z planem lekcji
- **Powiadomienia** - Email i SMS dla nauczycieli przy wykryciu telefonu
- **Historia detekcji** - Baza danych z możliwością eksportu i analizy statystycznej

---

## 2. ARCHITEKTURA SYSTEMU

### 2.1. Wzorzec Producer-Consumer

System wykorzystuje **wzorzec Producer-Consumer** do rozdzielenia operacji wymagających niskiej latencji (detekcja) od operacji czasochłonnych (anonimizacja).

```
┌─────────────────────────────────────────────────────────┐
│         WĄTEK GŁÓWNY (Producer)                         │
│         Real-Time Phone Detection                       │
│                                                         │
│  📷 Kamera → 🔍 YOLOv8 → 💾 Zapis → 📤 Kolejka         │
│  (20-30 FPS)                                            │
└────────────────────────┼────────────────────────────────┘
                         │
                    Queue<zadania>
                         │
                         ↓
┌────────────────────────┼────────────────────────────────┐
│         WĄTEK WORKERA (Consumer)                        │
│         Offline Head Anonymization                      │
│                                                         │
│  📥 Kolejka → 👁️ Roboflow → 🔒 Blur → 💾 DB → 📧 Alert│
│  (asynchronicznie)                                     │
└─────────────────────────────────────────────────────────┘
```

**Dlaczego ten wzorzec?**
- Główna pętla kamery działa w czasie rzeczywistym (20-30 FPS)
- Anonimizacja głów trwa 1-2 sekundy (wykrywanie przez API + blur)
- Bez rozdzielenia wątków, detekcja byłaby blokowana przez anonimizację
- Kolejka (`queue.Queue`) pełni rolę bufora między wątkami

### 2.2. Architektura rozdzielona (Separated Frontend/Backend)

```
┌─────────────────────┐         ┌─────────────────────┐
│   Frontend (React)  │ ◄─────► │   Backend (Flask)   │
│   Port: 3000        │  REST   │   Port: 5000        │
│                     │  API    │                     │
│  - React 18         │         │  - Flask 3.0        │
│  - TypeScript       │         │  - SQLAlchemy      │
│  - Material-UI      │         │  - OpenCV          │
│  - Axios            │         │  - YOLOv8         │
└─────────────────────┘         └─────────────────────┘
```

**Zalety:**
- Separacja odpowiedzialności (UI vs logika biznesowa)
- Niezależne skalowanie (frontend na CDN, backend na serwerze z GPU)
- Łatwość utrzymania (zmiany w UI nie wymagają restartu serwera)
- CORS kontrolowany przez `flask-cors`

---

## 3. TECHNOLOGIE WYKORZYSTANE

### 3.1. Backend (Python)

#### Framework webowy
- **Flask 3.0.2** - Lekki framework do REST API
- **Flask-CORS 4.0.0** - Cross-Origin Resource Sharing
- **Flask-Login 0.6.3** - Zarządzanie sesjami użytkowników
- **Flask-SQLAlchemy 3.1.1** - ORM do bazy danych

#### Przetwarzanie obrazu i wizja komputerowa
- **OpenCV 4.9.0.80** - Przechwytywanie wideo, preprocessing, anonimizacja
- **NumPy 1.26.4** - Operacje na macierzach obrazu
- **Pillow 10.2.0** - Dodatkowe operacje na obrazach

#### Uczenie maszynowe
- **Ultralytics 8.1.2** - YOLOv8 do detekcji telefonów
  - Model: `yolov8m.pt` (medium) - kompromis szybkość/dokładność
  - Klasa: `class_id = 67` (cell phone w dataset COCO)
- **PyTorch 2.0.1** + **Torchvision 0.15.2** - Zależności YOLOv8
- **Roboflow** - API do detekcji głów (`heads-detection/1`)
  - Dokładność: >90%
  - Confidence threshold: 40%

#### Baza danych
- **SQLite** - Relacyjna baza danych (plik `admin.db`)
- **SQLAlchemy 3.1.1** - ORM (Object-Relational Mapping)
- **Flask-Migrate** - Migracje schematu bazy (Alembic)

#### Wielowątkowość
- **threading** - Wzorzec Producer-Consumer
- **queue.Queue** - Thread-safe kolejka między wątkami

#### Powiadomienia i chmura
- **Vonage 3.2.0** - Wysyłka SMS
- **yagmail 0.15.293** - Wysyłka email (Gmail)
- **Cloudinary 1.40.0** - Przechowywanie obrazów w chmurze (opcjonalne)

#### Narzędzia pomocnicze
- **python-dotenv 1.0.1** - Zarządzanie zmiennymi środowiskowymi (`.env`)
- **werkzeug.security** - Hashowanie haseł (SHA-256)

### 3.2. Frontend (React + TypeScript)

#### Framework i język
- **React 18.2.0** - Biblioteka UI
- **TypeScript 4.9.5** - Typowanie statyczne
- **Create React App** (react-scripts 5.0.1) - Narzędzie do budowania

#### Biblioteka UI
- **Material-UI (MUI) 5.15.10** - Komponenty zgodne z Material Design
  - `@mui/material` - Główne komponenty
  - `@mui/icons-material` - Ikony
  - `@mui/x-data-grid` - Zaawansowane tabele
  - `@mui/x-date-pickers` - Selektory daty/czasu

#### Routing i komunikacja
- **React Router DOM 6.22.1** - Routing SPA
- **Axios 1.6.7** - HTTP client z interceptors
  - `withCredentials: true` - Sesje Flask-Login
  - Automatyczne przekierowanie przy błędzie 401

#### Wizualizacja danych
- **Recharts 2.10.3** - Wykresy statystyczne
- **Chart.js 4.4.1** + **react-chartjs-2 5.2.0** - Alternatywne wykresy

#### Zarządzanie stanem
- **React Context API** - Stan globalny (AuthContext, ConfigContext)
- **NIE** Redux - używa Context API

#### Narzędzia pomocnicze
- **date-fns 2.30.0** - Manipulacja datami
- **react-responsive-masonry 2.1.7** - Responsywna galeria obrazów

---

## 4. JAK DZIAŁA SYSTEM - PRZEPŁYW DANYCH

### 4.1. Cykl życia pojedynczej detekcji

#### Krok 1: Przechwycenie klatki (Main Thread)
```
Czas: t=0ms
Operacja: cv2.VideoCapture.read()
Wynik: frame (numpy array, BGR, 1280x720)
```

#### Krok 2: Preprocessing obrazu (Main Thread)
```
Czas: t=10ms
Techniki:
  - CLAHE (Contrast Limited Adaptive Histogram Equalization)
  - Unsharp masking (wyostrzenie)
  - Opcjonalne zwiększenie rozdzielczości dla małych obrazów
Cel: Poprawa jakości obrazu dla lepszej detekcji
```

#### Krok 3: Detekcja YOLOv8 (Main Thread)
```
Czas: t=30ms
Operacja: model(enhanced_frame)
Model: YOLOv8m (yolov8m.pt)
Klasa: 67 (cell phone)
Wynik: Lista obiektów z bounding boxes i confidence
```

#### Krok 4: Filtrowanie (Main Thread)
```
Czas: t=35ms
Operacje:
  - Sprawdzenie class_id == 67 (telefon)
  - Sprawdzenie confidence >= threshold (domyślnie 0.2)
  - Sprawdzenie ROI zones (czy telefon w monitorowanej strefie)
Wynik: matched_zone (nazwa strefy lub None)
```

#### Krok 5: Zapis oryginalnej klatki (Main Thread)
```
Czas: t=40ms
Operacja: cv2.imwrite(filepath, frame)
Ścieżka: ./detections/phone_YYYYMMDD_HHMMSS.jpg
Ważne: Zapisuje ORYGINALNĄ klatkę (bez anonimizacji)
```

#### Krok 6: Dodanie do kolejki (Main Thread)
```
Czas: t=45ms
Operacja: detection_queue.put(detection_data)
Struktura:
  {
    'filepath': './detections/phone_20251123_143015.jpg',
    'confidence': 0.85,
    'should_blur': True,
    'zone_name': 'Ławka 3'
  }
```

**Główna pętla kontynuuje działanie - nie czeka na worker!**

#### Krok 7-12: Przetwarzanie przez Worker Thread (asynchronicznie)
```
Czas: t=100ms - 2000ms (nie blokuje głównej pętli)

7. Pobranie z kolejki (t=100ms)
8. Wykrywanie głów przez Roboflow API (t=800ms)
   - Model: heads-detection/1
   - Confidence: 40%
9. Anonimizacja głów (t=850ms)
   - Gaussian blur: kernel 99x99, sigma=30
   - Nieodwracalne rozmycie
10. Nadpisanie pliku (t=900ms)
    - Oryginalny plik zastępowany zanonimizowaną wersją
11. Zapis do bazy danych (t=950ms)
    - Tylko zanonimizowane obrazy w bazie!
12. Powiadomienia (t=1000ms+)
    - Upload na Cloudinary (opcjonalne)
    - Email do nauczyciela
    - SMS (opcjonalne)
```

### 4.2. Preprocessing obrazu dla lepszej detekcji

System stosuje trzyetapowy preprocessing przed detekcją YOLOv8:

1. **CLAHE (Contrast Limited Adaptive Histogram Equalization)**
   - Poprawa kontrastu lokalnego
   - Działa na kanale L w przestrzeni LAB
   - Zapobiega nadmiernemu wzmocnieniu szumu

2. **Unsharp Masking**
   - Wyostrzenie krawędzi
   - Wzór: `output = 1.5 * original - 0.5 * blurred`
   - Subtelne wyostrzenie bez wzmocnienia szumu

3. **Zwiększenie rozdzielczości (opcjonalne)**
   - Dla obrazów <640px szerokości
   - YOLOv8 działa najlepiej na obrazach ≥640px

### 4.3. Anonimizacja głów (RODO)

**Proces:**
1. Wykrycie głów przez Roboflow API (confidence ≥ 40%)
2. Wycięcie regionu głowy (ROI)
3. Zastosowanie Gaussian blur:
   - Kernel: 99x99 pikseli
   - Sigma: 30
   - Nieodwracalne rozmycie
4. Nadpisanie oryginalnego pliku zanonimizowaną wersją
5. Zapis do bazy danych (tylko zanonimizowane obrazy!)

**Gwarancje bezpieczeństwa:**
- Baza danych NIGDY nie zawiera oryginalnych obrazów
- Gaussian blur jest nieodwracalny
- Oryginalne klatki są nadpisywane przed zapisem do DB

---

## 5. KLUCZOWE FUNKCJONALNOŚCI TECHNICZNE

### 5.1. Strefy ROI (Region of Interest)

**Cel:** Monitorowanie konkretnych miejsc w klasie (ławki, rzędy)

**Funkcjonalności:**
- Definiowanie wielu stref na obrazie z kamery
- Grid Generator - automatyczne tworzenie siatki stref (np. 4x5 = 20 ławek)
- Per-zone muting - wyciszanie alertów na 5 minut dla każdej strefy osobno
- Współrzędne znormalizowane (0.0-1.0) - niezależne od rozdzielczości

**Przykład:**
```
Klasa: 4 rzędy × 5 ławek = 20 stref
Nazwy: "Desk 1", "Desk 2", ..., "Desk 20"
Muting: Każda strefa ma osobny timer (5 minut)
```

### 5.2. Harmonogram pracy kamery

**Funkcjonalność:** Automatyczne włączanie/wyłączanie kamery zgodnie z planem lekcji

**Struktura:**
```json
{
  "monday": {"enabled": true, "start": "08:00", "end": "15:00"},
  "tuesday": {"enabled": true, "start": "08:00", "end": "15:00"},
  ...
}
```

**Działanie:**
- System sprawdza aktualny czas i dzień tygodnia
- Automatycznie uruchamia/zatrzymuje kamerę
- Możliwość ręcznego nadpisania (start/stop przez panel)

### 5.3. Frame Skipping

**Optymalizacja wydajności:**
- Przetwarzanie co 3. klatkę (`process_every_n_frame = 3`)
- Redukcja obciążenia CPU/GPU o ~66%
- Zachowanie płynności detekcji (20-30 FPS → efektywnie 7-10 FPS przetwarzania)

### 5.4. Wymuszenie rozdzielczości HD

**Cel:** Zapewnienie wystarczającej jakości obrazu dla detekcji małych obiektów

**Implementacja:**
- Priorytet: 1280x720 (HD)
- Fallback: 640x480 (VGA)
- Warmup reads dla kamer wirtualnych (np. Iriun Webcam)

### 5.5. Strumieniowanie wideo (MJPEG)

**Protokół:** MJPEG (Motion JPEG) stream over HTTP

**Funkcjonalności:**
- Endpoint: `GET /api/camera/video_feed`
- Format: `multipart/x-mixed-replace; boundary=frame`
- Częstotliwość: ~20 FPS
- Bezpieczeństwo: Filtr Canny (wykrywanie krawędzi) dla prywatności przed wysłaniem
- Wymaga autoryzacji (`@login_required`)

---

## 6. STRUKTURA BAZY DANYCH

### 6.1. Modele danych (SQLAlchemy ORM)

#### User
- `id` - Klucz główny
- `username` - Unikalna nazwa użytkownika
- `password_hash` - Hash hasła (SHA-256)

#### Detection
- `id` - Klucz główny
- `timestamp` - Data i czas detekcji (UTC)
- `location` - Nazwa lokalizacji (strefa ROI lub nazwa kamery)
- `confidence` - Pewność detekcji (0.0-1.0)
- `image_path` - Nazwa pliku obrazu (tylko nazwa, bez ścieżki)
- `status` - Status detekcji ('Pending', 'Reviewed', etc.)
- `user_id` - Klucz obcy do User

#### Settings
- `id` - Klucz główny
- `schedule` - Harmonogram pracy kamery (JSON)
- `roi_zones` - Lista stref ROI (JSON)
- `config` - Konfiguracja systemu (JSON)
  - `blur_faces` - Włącz/wyłącz anonimizację
  - `confidence_threshold` - Próg pewności detekcji (0.0-1.0)
  - `camera_index` - Indeks kamery
  - `email_notifications` - Powiadomienia email
  - `sms_notifications` - Powiadomienia SMS
- `created_at` - Data utworzenia
- `updated_at` - Data ostatniej aktualizacji (auto-update)

### 6.2. Przechowywanie obrazów

**Lokalizacja:** Folder `./detections/` (względem `app.py`)

**Format:** JPEG (`.jpg`)

**Nazewnictwo:** `phone_YYYYMMDD_HHMMSS.jpg`

**Proces:**
1. Wykrycie telefonu → zapis ORYGINALNEJ klatki
2. Worker thread → anonimizacja głów (Gaussian blur)
3. Nadpisanie pliku zanonimizowaną wersją
4. Zapis metadanych do bazy (tylko nazwa pliku)

**Bezpieczeństwo:** Baza danych zawiera tylko zanonimizowane obrazy!

---

## 7. API ENDPOINTS (REST)

### Autoryzacja
- `POST /api/login` - Logowanie (Flask-Login session)
- `GET /api/logout` - Wylogowanie

### Detekcje
- `GET /api/detections?page=1&per_page=20` - Lista z paginacją
- `GET /api/detections/<id>` - Szczegóły detekcji
- `DELETE /api/detections/<id>` - Usunięcie pojedynczej
- `DELETE /api/detections/batch` - Masowe usuwanie
- `GET /detections/<filename>` - Pobranie obrazu (blob)

### Dashboard i statystyki
- `GET /api/dashboard-stats` - Statystyki w czasie rzeczywistym
- `GET /api/stats/detections_over_time` - Statystyki z ostatnich 7 dni

### Ustawienia
- `GET /api/settings` - Pobranie konfiguracji
- `POST /api/settings` - Aktualizacja konfiguracji
- `GET /api/settings/roi` - Pobranie ROI zones
- `POST /api/settings/roi` - Zapis ROI zones

### Kamera
- `POST /api/camera/start` - Ręczne uruchomienie
- `POST /api/camera/stop` - Ręczne zatrzymanie
- `GET /api/camera/status` - Status kamery
- `GET /api/camera/video_feed` - MJPEG stream
- `GET /api/camera/config_snapshot` - Snapshot do konfiguracji ROI

---

## 8. BEZPIECZEŃSTWO I PRYWATNOŚĆ

### 8.1. Autoryzacja
- **Flask-Login** - Sesje przez cookies
- **Hasła** - Hashowane przez werkzeug.security (SHA-256)
- **CORS** - Konfigurowany dla `http://localhost:3000`
- **Ochrona endpointów** - Dekorator `@login_required`

### 8.2. Anonimizacja (RODO)
- **Wykrywanie głów** - Roboflow API (dokładność >90%)
- **Gaussian blur** - Kernel 99x99, sigma=30 (nieodwracalne)
- **Gwarancje:**
  1. Oryginalne klatki są zapisywane lokalnie
  2. Głowy są wykrywane przez Roboflow
  3. Głowy są zamazywane PRZED zapisem do DB
  4. Oryginalny plik jest NADPISYWANY zanonimizowaną wersją
  5. Baza danych zawiera TYLKO zanonimizowane obrazy
  6. Gaussian blur jest nieodwracalny

### 8.3. Zarządzanie danymi wrażliwymi
- **Zmienne środowiskowe** - Plik `.env` (nie w repozytorium)
- **Klucze API** - Przechowywane w `.env`, nie w kodzie
- **Hasła** - Hashowane, nie plaintext

---

## 9. WYDAJNOŚĆ I OPTYMALIZACJE

### 9.1. Optymalizacje wydajnościowe
- **Frame skipping** - Przetwarzanie co 3. klatkę (redukcja obciążenia o ~66%)
- **Wielowątkowość** - Producer-Consumer (detekcja nie blokowana przez anonimizację)
- **Asynchroniczność** - Anonimizacja w osobnym wątku
- **Preprocessing** - Tylko dla klatek przeznaczonych do detekcji

### 9.2. Parametry wydajnościowe
- **Częstotliwość detekcji:** 20-30 FPS (przed frame skipping)
- **Efektywna częstotliwość przetwarzania:** 7-10 FPS
- **Czas detekcji YOLOv8:** ~30ms na klatkę
- **Czas anonimizacji:** 1-2 sekundy (asynchronicznie, nie blokuje)
- **Rozdzielczość kamery:** 1280x720 (HD) lub 640x480 (VGA fallback)

---

## 10. PODSUMOWANIE TECHNICZNE

### Kluczowe technologie
1. **YOLOv8** (`yolov8m.pt`) - Detekcja telefonów w czasie rzeczywistym
2. **Roboflow AI** (`heads-detection/1`) - Wykrywanie głów dla anonimizacji
3. **OpenCV** - Przetwarzanie obrazu, Gaussian blur
4. **Flask** - Backend REST API
5. **React + TypeScript** - Frontend SPA
6. **SQLite + SQLAlchemy** - Baza danych
7. **Producer-Consumer Pattern** - Wielowątkowość dla wydajności

### Architektura
- **Rozdzielona** - Frontend (React) + Backend (Flask)
- **Wielowątkowa** - Main thread (detekcja) + Worker thread (anonimizacja)
- **Asynchroniczna** - Kolejka między wątkami

### Bezpieczeństwo
- **RODO** - Automatyczna anonimizacja głów (Gaussian blur)
- **Autoryzacja** - Flask-Login + hashowane hasła
- **Separacja danych** - Tylko zanonimizowane obrazy w bazie

### Wydajność
- **Real-time** - 20-30 FPS detekcji
- **Optymalizacje** - Frame skipping, preprocessing, wielowątkowość
- **Skalowalność** - Architektura rozdzielona umożliwia niezależne skalowanie

---

## DODATKOWE INFORMACJE

### Wymagania systemowe
- **Python 3.8-3.12** (backend)
- **Node.js 14+** (frontend)
- **Kamera** - Wbudowana lub zewnętrzna (USB)
- **Internet** - Dla Roboflow API, powiadomienia, Cloudinary (opcjonalne)

### Struktura projektu
```
Detection-phone/
├── app.py                    # Flask server, API endpoints
├── camera_controller.py      # Logika kamery, detekcji, anonimizacji
├── models.py                 # Modele SQLAlchemy
├── requirements.txt          # Zależności Python
├── package.json             # Zależności Node.js
├── src/                     # Frontend React
│   ├── pages/              # Strony (Dashboard, Detections, Settings)
│   ├── components/          # Komponenty UI
│   └── services/           # API client (Axios)
└── detections/             # Folder z obrazami (tworzony automatycznie)
```

---

*Materiał przygotowany do prezentacji na seminarium inżynierskim*






