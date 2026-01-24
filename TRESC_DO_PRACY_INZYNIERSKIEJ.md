# Materiały do pracy inżynierskiej - System detekcji smartfonów

## 1. STOS TECHNOLOGICZNY

### 1.1. Backend

System backendowy został zaimplementowany w języku **Python 3.x** z wykorzystaniem następujących technologii:

**Framework Webowy: Flask 3.0.2**
- Minimalistyczna architektura umożliwiająca pełną kontrolę nad przepływem danych
- Łatwa integracja z bibliotekami przetwarzania obrazu (OpenCV, Ultralytics)
- Wsparcie dla wielowątkowości poprzez natywne mechanizmy Pythona
- Niska latencja w obsłudze żądań HTTP, kluczowa dla systemu czasu rzeczywistego

**Przetwarzanie Obrazu: OpenCV 4.9.0.80**
- Przechwytywanie strumienia wideo z kamer
- Preprocessing obrazu przed detekcją (CLAHE, unsharp masking)
- Anonimizacja głów poprzez filtr Gaussa
- Operacje na macierzach obrazu (konwersje kolorów, resize, operacje ROI)

**Detekcja Obiektów: Ultralytics YOLOv8 8.1.2**
- Model YOLOv8m (medium) jako kompromis między dokładnością a szybkością przetwarzania
- Mechanizm fallbacku na model YOLOv8s (small) w przypadku braku modelu średniego
- Klasa detekcji: `class_id = 67` (cell phone w dataset COCO)

**Anonimizacja: Roboflow API**
- Model `heads-detection/1` do wykrywania głów
- Wysoka dokładność wykrywania głów (ponad 90%)
- Łatwa integracja bez konieczności lokalnego trenowania modelu

**Baza Danych: SQLAlchemy 3.1.1 + SQLite**
- SQLAlchemy jako ORM (Object-Relational Mapping)
- SQLite jako silnik bazy danych
- Uzasadnienie wyboru:
  - Brak konieczności konfiguracji zewnętrznego serwera bazy danych
  - Wystarczająca wydajność dla aplikacji jednoużytkownikowej w środowisku szkolnym
  - Prosta migracja danych poprzez plik bazy danych
  - Wsparcie dla typów JSON (harmonogram, ROI zones, konfiguracja)

**Wielowątkowość: threading + queue.Queue**
- Wzorzec Producer-Consumer do rozdzielenia operacji czasochłonnych od operacji wymagających niskiej latencji
- Kolejka jako bufor thread-safe między wątkiem głównym a wątkiem workera

**Powiadomienia:**
- Vonage 3.2.0 - wysyłka powiadomień SMS
- yagmail 0.15.293 - wysyłka powiadomień e-mail
- Cloudinary 1.40.0 - przechowywanie obrazów w chmurze

**Konfiguracja:**
- python-dotenv 1.0.1 - zarządzanie zmiennymi środowiskowymi

### 1.2. Frontend

Frontend został zaimplementowany jako Single Page Application (SPA) w **React 18.2.0** z **TypeScript 4.9.5**.

**Framework UI: Material-UI 5.15.10**
- Gotowe, profesjonalne komponenty zgodne z Material Design
- Wsparcie dla responsywności
- Integracja z React Router i Axios
- Komponenty specjalistyczne (DataGrid dla tabel, DatePickers dla harmonogramu)

**Komunikacja z Backendem: Axios 1.6.7**
- Interceptory dla automatycznego dodawania tokenów autoryzacji
- Obsługa błędów 401 (przekierowanie do logowania)
- Konfiguracja z obsługą sesji Flask-Login

**Wizualizacja Danych:**
- Recharts 2.10.3 - wykresy statystyczne
- Chart.js 4.4.1 - wykresy statystyczne

**Routing: React Router DOM 6.22.1**
- Obsługa nawigacji między stronami (Dashboard, Detections, Settings, Login)

### 1.3. Uzasadnienie Architektury Flask + React

Wybór architektury rozdzielonej (separated frontend/backend) został podyktowany następującymi czynnikami:

1. **Separacja odpowiedzialności:** Backend skupia się wyłącznie na logice biznesowej i przetwarzaniu obrazu, frontend na prezentacji danych
2. **Niezależne skalowanie:** Frontend może być hostowany na CDN, backend na dedykowanym serwerze z GPU
3. **Łatwość utrzymania:** Zmiany w UI nie wymagają restartu serwera Flask
4. **CORS:** Komunikacja między domenami jest kontrolowana przez flask-cors

---

## 2. ARCHITEKTURA SYSTEMU

### 2.1. Wzorzec Producer-Consumer

System wykorzystuje wzorzec **Producer-Consumer** do rozdzielenia operacji czasochłonnych (anonimizacja) od operacji wymagających niskiej latencji (detekcja w czasie rzeczywistym).

#### Producer (Wątek Główny - CameraController)

**Rola:**
- Przechwytywanie klatek z kamery
- Preprocessing obrazu
- Detekcja telefonów za pomocą YOLOv8
- Filtrowanie detekcji według progu pewności (confidence threshold, domyślnie 0.2)
- Sprawdzanie ROI zones (Region of Interest)
- Zapis oryginalnej klatki do dysku
- Dodanie zadania do kolejki

**Częstotliwość przetwarzania:** Co 3. klatkę dla optymalizacji wydajności.

#### Consumer (Wątek Workera - AnonymizerWorker)

**Rola:**
- Pobieranie zadań z kolejki
- Wykrywanie głów za pomocą modelu Roboflow
- Anonimizacja głów filtrem Gaussa
- Zapis do bazy danych
- Wysyłka powiadomień

**Asynchroniczność:** Worker działa w osobnym wątku daemon, nie blokując głównej pętli kamery.

#### Kolejka jako Bufor

Kolejka `Queue()` pełni rolę bufora między Producer a Consumer:
- **Thread-safe:** Automatyczna synchronizacja dostępu między wątkami
- **Blokowanie:** Pobieranie z kolejki z timeoutem, zapewniającym responsywność
- **FIFO:** Zadania są przetwarzane w kolejności dodania

### 2.2. Cykl Życia Pojedynczej Detekcji

Poniżej przedstawiono przepływ danych od momentu przechwycenia klatki do zapisu w bazie danych:

1. **Przechwycenie Klatki** (Main Thread, ~0ms)
   - Odczytywanie klatki z kamery (1280x720, BGR)

2. **Preprocessing Obrazu** (Main Thread, ~10ms)
   - Konwersja BGR → LAB
   - CLAHE na kanale L
   - Unsharp masking
   - Opcjonalne zwiększenie rozdzielczości

3. **Detekcja YOLOv8** (Main Thread, ~30ms)
   - Przetwarzanie przez model YOLOv8
   - Zwrócenie listy obiektów z bounding boxes

4. **Filtrowanie i Walidacja** (Main Thread, ~35ms)
   - Iteracja przez wykryte obiekty
   - Sprawdzenie class_id == 67 (telefon)
   - Sprawdzenie confidence >= threshold
   - Obliczenie współrzędnych centrum
   - Sprawdzenie ROI zones

5. **Zapis Oryginalnej Klatki** (Main Thread, ~40ms)
   - Zapis oryginalnej klatki (bez anonimizacji) do pliku

6. **Dodanie do Kolejki** (Main Thread, ~45ms)
   - Utworzenie zadania z danymi detekcji
   - Dodanie do kolejki przetwarzania

7. **Pobranie z Kolejki** (Worker Thread, ~100ms, asynchronicznie)
   - Pobranie zadania z kolejki przez worker

8. **Wykrywanie Głów** (Worker Thread, ~800ms)
   - Wywołanie API Roboflow do wykrywania głów
   - Zwrócenie listy wykrytych głów

9. **Anonimizacja Głów** (Worker Thread, ~850ms)
   - Zastosowanie filtru Gaussa na regionach głów
   - Parametry: kernel 99x99, sigma=30

10. **Nadpisanie Pliku** (Worker Thread, ~900ms)
    - Nadpisanie oryginalnego pliku zanonimizowaną wersją

11. **Zapis do Bazy Danych** (Worker Thread, ~950ms)
    - Utworzenie rekordu Detection
    - Zapis timestamp, location, confidence, image_path, status

12. **Powiadomienia** (Worker Thread, ~1000ms+, asynchronicznie)
    - Upload obrazu na Cloudinary
    - Wysyłka SMS (opcjonalnie)
    - Wysyłka Email (opcjonalnie)

**Kluczowa obserwacja:** Główna pętla kamery kontynuuje działanie z prędkością 20-30 FPS, niezależnie od czasu przetwarzania przez worker (1-2 sekundy). To zapewnia detekcję w czasie rzeczywistym.

---

## 3. KLUCZOWE ALGORYTMY I ROZWIĄZANIA INŻYNIERSKIE

### 3.1. Preprocessing Obrazu dla Detekcji

#### Problem
Oryginalne klatki z kamery mogą mieć niski kontrast, rozmycie lub niewystarczającą rozdzielczość dla małych obiektów (telefony), co obniża dokładność detekcji YOLOv8.

#### Rozwiązanie: Trzyetapowy Preprocessing

**Etap 1: CLAHE (Contrast Limited Adaptive Histogram Equalization)**

```python
lab = cv2.cvtColor(enhanced, cv2.COLOR_BGR2LAB)  # Konwersja BGR → LAB
l_channel, a, b = cv2.split(lab)  # Rozdzielenie kanałów
clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
l_channel_enhanced = clahe.apply(l_channel)  # Zastosowanie CLAHE na kanale L
lab_enhanced = cv2.merge([l_channel_enhanced, a, b])
enhanced = cv2.cvtColor(lab_enhanced, cv2.COLOR_LAB2BGR)  # Powrót do BGR
```

**Uzasadnienie:**
- CLAHE działa lokalnie (8x8 tiles), co zapobiega nadmiernemu wzmocnieniu szumu
- Operacja na kanale L (jasność) w przestrzeni LAB zachowuje kolory
- `clipLimit=2.0` ogranicza wzmocnienie kontrastu, zapobiegając artefaktom

**Etap 2: Unsharp Masking (Wyostrzenie)**

```python
gaussian = cv2.GaussianBlur(enhanced, (0, 0), 2.0)
enhanced = cv2.addWeighted(enhanced, 1.5, gaussian, -0.5, 0)
```

**Uzasadnienie:**
- Wzór: `output = 1.5 * original - 0.5 * blurred`
- Efekt: Wyostrzenie krawędzi bez wzmocnienia szumu
- Sigma=2.0 zapewnia subtelne wyostrzenie

**Etap 3: Zwiększenie Rozdzielczości (Opcjonalne)**

```python
h, w = enhanced.shape[:2]
if w < 640:
    scale_factor = 640 / w
    new_width = int(w * scale_factor)
    new_height = int(h * scale_factor)
    enhanced = cv2.resize(enhanced, (new_width, new_height), interpolation=cv2.INTER_LINEAR)
```

**Uzasadnienie:**
- YOLOv8 działa najlepiej na obrazach ≥640px szerokości
- Interpolacja liniowa zachowuje jakość przy upscalingu

### 3.2. Obsługa Kamery i Wymuszenie Rozdzielczości HD

#### Problem
Sterowniki kamer (szczególnie wirtualnych, np. Iriun Webcam) mogą zwracać niestabilne rozdzielczości lub artefakty przy domyślnych ustawieniach.

#### Rozwiązanie: Wymuszenie Rozdzielczości 1280x720 (HD)

```python
preferred_res = [(1280, 720), (640, 480)]  # Priorytet: HD, fallback: VGA
for w, h in preferred_res:
    try:
        self.camera.set(cv2.CAP_PROP_FRAME_WIDTH, w)
        self.camera.set(cv2.CAP_PROP_FRAME_HEIGHT, h)
    except Exception:
        continue
    if self._capture_has_valid_frame(self.camera, warmup_reads=5, delay_s=0.05):
        applied = (w, h)
        break
```

**Uzasadnienie:**
- **1280x720 (HD):** Zapewnia wystarczającą rozdzielczość dla detekcji małych obiektów (telefony)
- **640x480 (VGA):** Fallback dla kamer nieobsługujących HD
- **Warmup reads:** Niektóre kamery wirtualne wymagają kilku odczytów przed zwróceniem prawidłowych klatek

#### Obsługa Backendów OpenCV

```python
for backend in ('default', 'dshow'):
    if backend == 'default':
        cap = cv2.VideoCapture(self.camera_index)  # MSMF na Windows
    else:
        cap = cv2.VideoCapture(self.camera_index, cv2.CAP_DSHOW)  # DirectShow
```

**Uzasadnienie:**
- **MSMF (default):** Preferowany dla kamer wirtualnych (Iriun)
- **DirectShow (CAP_DSHOW):** Fallback dla starszych kamer USB

### 3.3. Filtr Gaussa do Anonimizacji (RODO)

**Czym jest filtr Gaussa?**

Filtr Gaussa to algorytm rozmywania obrazu, który zastępuje każdy piksel średnią ważoną wartości pikseli w jego otoczeniu. Wagi są rozłożone zgodnie z rozkładem normalnym (Gaussa), gdzie piksele bliżej centrum mają większy wpływ niż te dalej. Efektem jest płynne, naturalne rozmycie, które eliminuje szczegóły obrazu, czyniąc go nieczytelnym i nieodwracalnym - idealne do anonimizacji zgodnej z RODO.

```python
blur = cv2.GaussianBlur(roi, (99, 99), 30)
anonymized_frame[y1:y2, x1:x2] = blur
```

**Parametry:**
- **Kernel size: 99x99** - Bardzo duży kernel zapewnia całkowite rozmycie głowy
- **Sigma: 30** - Wysokie odchylenie standardowe zapewnia płynne przejście między zamazanym a normalnym obszarem

**Matematyka:**
Filtr Gaussa jest zdefiniowany jako:
```
G(x,y) = (1/(2πσ²)) * exp(-(x²+y²)/(2σ²))
```

Dla sigma=30, kernel 99x99 obejmuje obszar ±3σ, co zapewnia 99.7% energii filtru w obrębie kernela.

**Uzasadnienie wyboru parametrów:**
- **99x99:** Wystarczająco duży, aby zamazać całą głowę (typowa głowa: 50-80px)
- **Sigma=30:** Zapewnia nieodwracalne rozmycie (nie można odzyskać oryginalnego obrazu)
- **Nieodwracalność:** Kluczowe dla zgodności z RODO - anonimizacja jest trwała

**Proces anonimizacji:**
1. Wykrycie głowy przez Roboflow (confidence ≥ 40%)
2. Wycięcie ROI głowy: `roi = image[y1:y2, x1:x2]`
3. Zastosowanie blur: `blur = cv2.GaussianBlur(roi, (99, 99), 30)`
4. Wklejenie z powrotem: `image[y1:y2, x1:x2] = blur`
5. Nadpisanie oryginalnego pliku

### 3.4. Obsługa Różnic Proporcji: Letterboxing i Skalowanie

YOLOv8 automatycznie obsługuje różne rozdzielczości wejściowe poprzez wewnętrzne mechanizmy preprocessing:

1. **Resize z zachowaniem proporcji:** Obraz jest skalowany do 640x640 (lub innej rozdzielczości modelu) z zachowaniem aspect ratio
2. **Letterboxing:** Jeśli proporcje obrazu różnią się od 1:1, dodawane są czarne paski (padding)
3. **Przeliczanie współrzędnych:** Współrzędne bounding boxes są automatycznie przeliczane z przestrzeni modelu (640x640) na przestrzeń oryginalnego obrazu

**Przykład: Kamera 16:9 (1280x720) → Model 1:1 (640x640)**
```
Oryginalny obraz: 1280x720 (aspect ratio 16:9)
                    ↓
Skalowanie: 640x360 (zachowanie proporcji)
                    ↓
Letterboxing: 640x640 (dodanie 140px paddingu na górze i dole)
                    ↓
Model YOLOv8: detekcja na 640x640
                    ↓
Przeliczenie współrzędnych: z powrotem na 1280x720
```

---

## 4. STRUKTURA DANYCH I API

### 4.1. Modele Danych (SQLAlchemy ORM)

#### Model: User
```python
class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
```

**Atrybuty:**
- `id`: Klucz główny (Integer, auto-increment)
- `username`: Unikalna nazwa użytkownika (String 80)
- `password_hash`: Hash hasła (SHA-256 przez werkzeug.security)

**Uzasadnienie:** Model User jest wymagany przez Flask-Login do zarządzania sesjami. Hasła są hashowane, nie przechowywane w plaintext.

#### Model: Detection
```python
class Detection(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    timestamp = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    location = db.Column(db.String(100))
    confidence = db.Column(db.Float)
    image_path = db.Column(db.String(200))
    status = db.Column(db.String(20))
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=True)
```

**Atrybuty:**
- `id`: Klucz główny
- `timestamp`: Data i czas detekcji (UTC)
- `location`: Nazwa lokalizacji (strefa ROI lub nazwa kamery)
- `confidence`: Pewność detekcji (Float, 0.0-1.0)
- `image_path`: Nazwa pliku obrazu (bez pełnej ścieżki)
- `status`: Status detekcji ('Pending', 'Reviewed', etc.)
- `user_id`: Klucz obcy do User (nullable, domyślnie admin)

#### Model: Settings
```python
class Settings(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    schedule = db.Column(db.JSON, nullable=False, default=lambda: DEFAULT_SCHEDULE)
    roi_zones = db.Column(db.JSON, nullable=False, default=lambda: [])
    config = db.Column(db.JSON, nullable=False, default=lambda: {...})
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)
```

**Struktura `schedule` (JSON):**
```json
{
  "monday": {"enabled": true, "start": "07:00", "end": "16:00"},
  "tuesday": {"enabled": true, "start": "07:00", "end": "16:00"},
  ...
}
```

**Struktura `roi_zones` (JSON):**
```json
[
  {
    "id": "zone1",
    "name": "Ławka 1",
    "coords": {"x": 0.1, "y": 0.1, "w": 0.2, "h": 0.2}
  }
]
```

**Struktura `config` (JSON):**
```json
{
  "blur_faces": true,
  "confidence_threshold": 0.2,
  "camera_index": 0,
  "camera_name": "Camera 1",
  "email_notifications": false,
  "sms_notifications": false,
  "anonymization_percent": 50,
  "roi_coordinates": null
}
```

**Uzasadnienie:** JSON umożliwia elastyczne przechowywanie złożonych struktur danych bez konieczności migracji schematu.

### 4.2. Endpointy API (REST)

#### Autoryzacja
- **POST `/api/login`** - Logowanie użytkownika
- **GET `/api/logout`** - Wylogowanie użytkownika

#### Detekcje
- **GET `/api/detections`** - Lista detekcji z paginacją
- **GET `/api/detections/<id>`** - Pojedyncza detekcja
- **DELETE `/api/detections/<id>`** - Usunięcie detekcji
- **DELETE `/api/detections/batch`** - Masowe usuwanie detekcji

#### Dashboard i Statystyki
- **GET `/api/dashboard-stats`** - Statystyki dashboardu
- **GET `/api/stats/detections_over_time`** - Statystyki w czasie (ostatnie 7 dni)

#### Ustawienia
- **GET `/api/settings`** - Pobranie konfiguracji
- **POST `/api/settings`** - Aktualizacja konfiguracji
- **GET `/api/settings/roi`** - Pobranie ROI zones
- **POST `/api/settings/roi`** - Aktualizacja ROI zones

#### Kamera
- **POST `/api/camera/start`** - Uruchomienie kamery
- **POST `/api/camera/stop`** - Zatrzymanie kamery
- **GET `/api/camera/status`** - Status kamery
- **GET `/api/camera/video_feed`** - Strumień wideo (MJPEG)
- **GET `/api/camera/config_snapshot`** - Snapshot do konfiguracji ROI

#### Obrazy
- **GET `/detections/<filename>`** - Pobranie obrazu detekcji (wymaga autoryzacji)

---

## 5. MECHANIZMY BEZPIECZEŃSTWA I KONFIGURACJI

### 5.1. Zarządzanie Zmiennymi Środowiskowymi

System wykorzystuje plik `.env` (nie znajduje się w repozytorium ze względów bezpieczeństwa) do przechowywania danych wrażliwych.

**Przykładowa struktura `.env`:**
```env
# Flask
FLASK_SECRET_KEY=xxx
DATABASE_URI=sqlite:///admin.db

# Vonage (SMS)
VONAGE_API_KEY=xxx
VONAGE_API_SECRET=xxx
VONAGE_FROM_NUMBER=PhoneDetection
VONAGE_TO_NUMBER=+48123456789

# Cloudinary
CLOUDINARY_CLOUD_NAME=xxx
CLOUDINARY_API_KEY=xxx
CLOUDINARY_API_SECRET=xxx

# Email (Gmail)
GMAIL_USER=xxx@gmail.com
GMAIL_APP_PASSWORD=xxx
EMAIL_RECIPIENT=teacher@school.edu
```

**Uzasadnienie:**
- Separacja danych wrażliwych od kodu źródłowego
- `.env` jest ignorowany przez Git (`.gitignore`)
- Łatwa konfiguracja dla różnych środowisk (dev, prod)

### 5.2. Mechanizm Logowania i Sesji

#### Flask-Login

System wykorzystuje Flask-Login do zarządzania sesjami użytkowników:
- **User Loader:** Ładuje użytkownika z bazy na podstawie `user_id` z sesji
- **Login:** Ustawia sesję Flask po pomyślnym logowaniu
- **Logout:** Czyści sesję
- **Ochrona endpointów:** Dekorator `@login_required` na chronionych endpointach

#### Sesja Flask

Flask wykorzystuje cookies do przechowywania sesji:
- **SECRET_KEY:** Używany do podpisywania cookies
- **CORS:** `supports_credentials=True` umożliwia wysyłanie cookies z frontendu

### 5.3. Bezpieczeństwo Anonimizacji (RODO)

**Gwarancje systemu:**

1. **Oryginalne klatki są zapisywane lokalnie** przed anonimizacją
2. **Anonimizacja przed zapisem do DB:** Worker zamazuje głowy PRZED zapisem do bazy danych
3. **Nadpisanie oryginalnego pliku:** Oryginalny plik jest nadpisywany zanonimizowaną wersją
4. **Baza danych zawiera tylko zanonimizowane obrazy:** `image_path` w modelu `Detection` wskazuje na plik, który został już zanonimizowany
5. **Nieodwracalność:** Gaussian blur (99x99, sigma=30) jest nieodwracalny

**Przepływ bezpieczeństwa:**
```
1. Telefon wykryty → Zapis ORYGINAŁU do ./detections/phone_XXX.jpg
2. Worker pobiera z Queue
3. Worker wykrywa głowy (Roboflow)
4. Worker zamazuje głowy (Gaussian blur)
5. Worker NADPISUJE plik zanonimizowaną wersją
6. Worker zapisuje do DB (tylko zanonimizowany plik!)
```

**Konsekwencja:** Nawet jeśli ktoś uzyska dostęp do bazy danych, nie będzie mógł zidentyfikować uczniów na zdjęciach.

---

## PODSUMOWANIE

System wykrywania telefonów komórkowych został zaimplementowany jako aplikacja webowa z architekturą rozdzieloną (Flask backend + React frontend), wykorzystującą wzorzec Producer-Consumer do zapewnienia detekcji w czasie rzeczywistym przy jednoczesnej asynchronicznej anonimizacji głów. Kluczowe rozwiązania inżynierskie obejmują preprocessing obrazu (CLAHE, unsharp masking), wymuszenie rozdzielczości HD (1280x720), oraz nieodwracalną anonimizację głów filtrem Gaussa (99x99, sigma=30) zgodnie z wymogami RODO. System wykorzystuje YOLOv8 do detekcji telefonów oraz Roboflow API do wykrywania głów, zapewniając wysoką dokładność przy zachowaniu wydajności (20-30 FPS).

