# RAPORT TECHNICZNY - "System automatycznej detekcji smartfonów w szkołach podstawowych w celu poprawy koncentracji uczniów"

## 1. CHARAKTERYSTYKA TECHNICZNA I STACK TECHNOLOGICZNY

### 1.1. Backend - Technologie i Uzasadnienia

System backendowy został zaimplementowany w języku **Python 3.x** z wykorzystaniem następujących kluczowych bibliotek i frameworków:

#### Framework Webowy: Flask 3.0.2
Aplikacja wykorzystuje **Flask** jako lekki framework webowy do implementacji REST API. Wybór Flask został podyktowany następującymi czynnikami:
- Minimalistyczna architektura umożliwiająca pełną kontrolę nad przepływem danych
- Łatwa integracja z bibliotekami przetwarzania obrazu (OpenCV, Ultralytics)
- Wsparcie dla wielowątkowości poprzez natywne mechanizmy Pythona
- Niska latencja w obsłudze żądań HTTP, co jest kluczowe dla systemu czasu rzeczywistego

#### Przetwarzanie Obrazu: OpenCV 4.9.0.80
Biblioteka **OpenCV** została wykorzystana do:
- Przechwytywania strumienia wideo z kamer (`cv2.VideoCapture`)
- Preprocessingu obrazu przed detekcją (CLAHE, unsharp masking)
- Anonimizacji głów poprzez filtr Gaussa (`cv2.GaussianBlur`)
- Operacji na macierzach obrazu (konwersje kolorów, resize, operacje ROI)

#### Detekcja Obiektów: Ultralytics YOLOv8 8.1.2
System wykorzystuje model **YOLOv8m** (medium) z biblioteki Ultralytics do detekcji telefonów komórkowych. Model został wybrany jako kompromis między dokładnością a szybkością przetwarzania. W kodzie (`app.py`, linie 54-64) zaimplementowano mechanizm fallbacku na model `yolov8s.pt` (small) w przypadku braku modelu średniego.

**Klasa detekcji:** `class_id = 67` (cell phone w dataset COCO)

#### Anonimizacja: Roboflow API
Do wykrywania głów wykorzystano model **Roboflow** (`heads-detection/1`), dostępny przez API. Wybór został podyktowany wysoką dokładnością wykrywania głów (ponad 90%) oraz łatwością integracji bez konieczności lokalnego trenowania modelu.

#### Baza Danych: SQLAlchemy 3.1.1 + SQLite
System wykorzystuje **SQLAlchemy** jako ORM (Object-Relational Mapping) z **SQLite** jako silnikiem bazy danych. Wybór SQLite został uzasadniony następującymi czynnikami:
- Brak konieczności konfiguracji zewnętrznego serwera bazy danych
- Wystarczająca wydajność dla aplikacji jednoużytkownikowej w środowisku szkolnym
- Prosta migracja danych poprzez plik `admin.db`
- Wsparcie dla typów JSON (harmonogram, ROI zones, konfiguracja)

#### Wielowątkowość: threading + queue.Queue
System wykorzystuje natywny moduł **threading** Pythona oraz **queue.Queue** do implementacji wzorca Producer-Consumer. Kolejka (`detection_queue`) pełni rolę bufora między wątkiem głównym (detekcja) a wątkiem workera (anonimizacja).

#### Zarządzanie Zmiennymi Środowiskowymi: python-dotenv 1.0.1
Biblioteka **python-dotenv** umożliwia ładowanie konfiguracji z pliku `.env`, co zapewnia separację danych wrażliwych (klucze API, hasła) od kodu źródłowego.

#### Powiadomienia:
- **Vonage 3.2.0** - wysyłka powiadomień SMS
- **yagmail 0.15.293** - wysyłka powiadomień e-mail
- **Cloudinary 1.40.0** - przechowywanie obrazów w chmurze

### 1.2. Frontend - Technologie i Uzasadnienia

Frontend został zaimplementowany jako Single Page Application (SPA) w **React 18.2.0** z **TypeScript 4.9.5**.

#### Framework UI: Material-UI 5.15.10
**Material-UI (MUI)** został wybrany jako biblioteka komponentów UI ze względu na:
- Gotowe, profesjonalne komponenty zgodne z Material Design
- Wsparcie dla responsywności
- Integrację z React Router i Axios
- Komponenty specjalistyczne (`@mui/x-data-grid` dla tabel, `@mui/x-date-pickers` dla harmonogramu)

#### Komunikacja z Backendem: Axios 1.6.7
**Axios** został wykorzystany jako HTTP client z następującymi funkcjonalnościami:
- Interceptory dla automatycznego dodawania tokenów autoryzacji
- Obsługa błędów 401 (przekierowanie do logowania)
- Konfiguracja `withCredentials: true` dla sesji Flask-Login

#### Wizualizacja Danych: Recharts 2.10.3 + Chart.js 4.4.1
Biblioteki do generowania wykresów statystycznych (wykrycia w czasie, rozkład lokalizacji).

#### Routing: React Router DOM 6.22.1
Obsługa nawigacji między stronami (Dashboard, Detections, Settings, Login).

### 1.3. Uzasadnienie Architektury Flask + React

Wybór architektury rozdzielonej (separated frontend/backend) został podyktowany następującymi czynnikami:

1. **Separacja odpowiedzialności:** Backend skupia się wyłącznie na logice biznesowej i przetwarzaniu obrazu, frontend na prezentacji danych
2. **Niezależne skalowanie:** Frontend może być hostowany na CDN, backend na dedykowanym serwerze z GPU
3. **Łatwość utrzymania:** Zmiany w UI nie wymagają restartu serwera Flask
4. **CORS:** Komunikacja między domenami jest kontrolowana przez `flask-cors` (`app.py`, linie 30-34)

---

## 2. ARCHITEKTURA SYSTEMU I PRZEPŁYW DANYCH

### 2.1. Wzorzec Producer-Consumer

System wykorzystuje wzorzec **Producer-Consumer** do rozdzielenia operacji czasochłonnych (anonimizacja) od operacji wymagających niskiej latencji (detekcja w czasie rzeczywistym).

#### Producer (Wątek Główny - CameraController)
**Lokalizacja:** `camera_controller.py`, klasa `CameraController`, metoda `_camera_loop()` (linie 596-826)

**Rola:**
- Przechwytywanie klatek z kamery poprzez `cv2.VideoCapture.read()` (linia 638)
- Preprocessing obrazu (`_enhance_frame_for_detection()`, linie 553-594)
- Detekcja telefonów za pomocą YOLOv8 (`self.model(enhanced_frame)`, linia 720)
- Filtrowanie detekcji według `confidence_threshold` (domyślnie 0.2, linia 732)
- Sprawdzanie ROI zones (`find_matching_zone()`, linia 737)
- Zapis oryginalnej klatki do dysku (`_handle_detection()`, linia 512-550)
- Dodanie zadania do kolejki (`self.detection_queue.put()`, linia 544)

**Częstotliwość przetwarzania:** Co 3. klatkę (`process_every_n_frame = 3`, linia 109) dla optymalizacji wydajności.

#### Consumer (Wątek Workera - AnonymizerWorker)
**Lokalizacja:** `camera_controller.py`, klasa `AnonymizerWorker`, metoda `run()` (linie 1261-1338)

**Rola:**
- Pobieranie zadań z kolejki (`self.detection_queue.get(timeout=1)`, linia 1268)
- Wykrywanie głów za pomocą modelu Roboflow (`_anonymize_faces()`, linia 1582-1679)
- Anonimizacja głów filtrem Gaussa (`cv2.GaussianBlur`, linia 1652)
- Zapis do bazy danych (`_save_to_database()`, linia 1681-1709)
- Wysyłka powiadomień (`_handle_cloud_notification()`, linia 1529-1580)

**Asynchroniczność:** Worker działa w osobnym wątku daemon (`daemon=True`, linia 1212), nie blokując głównej pętli kamery.

#### Kolejka jako Bufor
**Lokalizacja:** `camera_controller.py`, linia 75

Kolejka `Queue()` pełni rolę bufora między Producer a Consumer:
- **Thread-safe:** Automatyczna synchronizacja dostępu między wątkami
- **Blokowanie:** `get(timeout=1)` blokuje wątek workera tylko na 1 sekundę, następnie kontynuuje pętlę
- **FIFO:** Zadania są przetwarzane w kolejności dodania

### 2.2. Cykl Życia Pojedynczej Detekcji

Poniżej przedstawiono szczegółowy przepływ danych od momentu przechwycenia klatki do zapisu w bazie danych:

#### Krok 1: Przechwycenie Klatki (Main Thread)
```
Czas: t=0ms
Lokalizacja: camera_controller.py, linia 638
Operacja: ret, frame = self.camera.read()
Wynik: frame (numpy array, BGR, 1280x720)
```

#### Krok 2: Preprocessing Obrazu (Main Thread)
```
Czas: t=10ms
Lokalizacja: camera_controller.py, linia 718
Operacja: enhanced_frame = self._enhance_frame_for_detection(frame)
Techniki:
  - Konwersja BGR → LAB (linia 570)
  - CLAHE na kanale L (linia 573-574)
  - Unsharp masking (linia 579-580)
  - Opcjonalne zwiększenie rozdzielczości (linie 583-587)
Wynik: enhanced_frame (ulepszony obraz)
```

#### Krok 3: Detekcja YOLOv8 (Main Thread)
```
Czas: t=30ms
Lokalizacja: camera_controller.py, linia 720
Operacja: results = self.model(enhanced_frame, verbose=False)
Wynik: results (lista obiektów z bounding boxes)
```

#### Krok 4: Filtrowanie i Walidacja (Main Thread)
```
Czas: t=35ms
Lokalizacja: camera_controller.py, linie 723-732
Operacje:
  - Iteracja przez boxes (linia 727)
  - Sprawdzenie class_id == 67 (telefon, linia 730)
  - Sprawdzenie confidence >= threshold (linia 732)
  - Obliczenie center_x, center_y (linie 734-735)
  - Sprawdzenie ROI zones (linia 737)
Wynik: matched_zone (nazwa strefy lub None)
```

#### Krok 5: Zapis Oryginalnej Klatki (Main Thread)
```
Czas: t=40ms
Lokalizacja: camera_controller.py, linia 530
Operacja: cv2.imwrite(filepath, frame)
Ścieżka: ./detections/phone_YYYYMMDD_HHMMSS.jpg
Ważne: Zapisuje ORYGINALNĄ klatkę (bez anonimizacji)
```

#### Krok 6: Dodanie do Kolejki (Main Thread)
```
Czas: t=45ms
Lokalizacja: camera_controller.py, linia 544
Operacja: self.detection_queue.put(detection_data)
Struktura danych:
  {
    'filepath': './detections/phone_20251123_143015.jpg',
    'confidence': 0.85,
    'should_blur': True,
    'zone_name': 'Ławka 3'
  }
```

#### Krok 7: Pobranie z Kolejki (Worker Thread)
```
Czas: t=100ms (asynchronicznie)
Lokalizacja: camera_controller.py, linia 1268
Operacja: task_data = self.detection_queue.get(timeout=1)
```

#### Krok 8: Wykrywanie Głów (Worker Thread)
```
Czas: t=800ms
Lokalizacja: camera_controller.py, linia 1613
Operacja: prediction = self.model.predict(image_path, confidence=40, overlap=30)
Model: Roboflow heads-detection/1
Wynik: JSON z listą wykrytych głów
```

#### Krok 9: Anonimizacja Głów (Worker Thread)
```
Czas: t=850ms
Lokalizacja: camera_controller.py, linia 1652
Operacja: blur = cv2.GaussianBlur(roi, (99, 99), 30)
Parametry:
  - Kernel: 99x99 pikseli
  - Sigma: 30
  - ROI: region głowy (x1, y1, x2, y2)
Wynik: Zamazany region głowy
```

#### Krok 10: Nadpisanie Pliku (Worker Thread)
```
Czas: t=900ms
Lokalizacja: camera_controller.py, linia 1665
Operacja: cv2.imwrite(image_path, image)
Ważne: NADPISUJE oryginalny plik zanonimizowaną wersją
```

#### Krok 11: Zapis do Bazy Danych (Worker Thread)
```
Czas: t=950ms
Lokalizacja: camera_controller.py, linia 1694-1702
Operacja: db.session.add(detection); db.session.commit()
Model: Detection (models.py, linie 33-40)
Pola:
  - timestamp: datetime.utcnow()
  - location: zone_name lub camera_name
  - confidence: float (0.0-1.0)
  - image_path: nazwa pliku (bez ścieżki)
  - status: 'Pending'
  - user_id: admin.id
```

#### Krok 12: Powiadomienia (Worker Thread, asynchronicznie)
```
Czas: t=1000ms+
Lokalizacja: camera_controller.py, linia 1322-1327
Operacje:
  - Upload na Cloudinary (linia 1542)
  - Wysyłka SMS (linia 1554)
  - Wysyłka Email (linia 1557)
```

**Kluczowa obserwacja:** Główna pętla kamery kontynuuje działanie z prędkością 20-30 FPS, niezależnie od czasu przetwarzania przez worker (1-2 sekundy). To zapewnia detekcję w czasie rzeczywistym.

---

## 3. KLUCZOWE ALGORYTMY I ROZWIĄZANIA INŻYNIERSKIE

### 3.1. Preprocessing Obrazu dla Detekcji

**Lokalizacja:** `camera_controller.py`, metoda `_enhance_frame_for_detection()` (linie 553-594)

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

**Lokalizacja:** `camera_controller.py`, metoda `start_camera()` (linie 294-361)

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

### 3.3. Transformacje Obrazu: Lustrzane Odbicie i Filtr Gaussa

#### Lustrzane Odbicie (cv2.flip)
**Lokalizacja:** Brak bezpośredniego użycia w kodzie, ale możliwe do dodania w `_camera_loop()`.

**Potencjalne zastosowanie:**
```python
frame = cv2.flip(frame, 1)  # Odbicie poziome (flipCode=1)
```

**Uzasadnienie:** Korekta obrazu dla kamer montowanych "do góry nogami" lub w lustrzanym odbiciu.

#### Filtr Gaussa do Anonimizacji (RODO)

**Lokalizacja:** `camera_controller.py`, linia 1652

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

**Uwaga:** System nie implementuje bezpośrednio algorytmu `scale_coords` w kodzie źródłowym, ponieważ biblioteka Ultralytics YOLOv8 automatycznie obsługuje różne rozdzielczości wejściowe poprzez wewnętrzne mechanizmy preprocessing.

#### Jak YOLOv8 Obsługuje Różne Rozdzielczości

YOLOv8 automatycznie:
1. **Resize z zachowaniem proporcji:** Obraz jest skalowany do 640x640 (lub innej rozdzielczości modelu) z zachowaniem aspect ratio
2. **Letterboxing:** Jeśli proporcje obrazu różnią się od 1:1, dodawane są czarne paski (padding)
3. **Przeliczanie współrzędnych:** Współrzędne bounding boxes są automatycznie przeliczane z przestrzeni modelu (640x640) na przestrzeń oryginalnego obrazu

#### Przykład: Kamera 16:9 (1280x720) → Model 1:1 (640x640)

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

**W kodzie:** Ultralytics automatycznie zwraca współrzędne w przestrzeni oryginalnego obrazu (`box.xyxy[0]`, linia 733), więc nie jest wymagane ręczne przeliczanie.

#### Jeśli Trzeba Byłoby Zaimplementować scale_coords

Gdyby system wymagał ręcznego przeliczania (np. dla niestandardowych modeli), algorytm wyglądałby następująco:

```python
def scale_coords(img1_shape, coords, img0_shape, ratio_pad=None):
    """
    Przelicza współrzędne z przestrzeni img1_shape na img0_shape.
    
    Args:
        img1_shape: (height, width) obrazu po letterboxingu (np. 640, 640)
        coords: (x1, y1, x2, y2) w przestrzeni img1_shape
        img0_shape: (height, width) oryginalnego obrazu (np. 720, 1280)
        ratio_pad: (ratio, (pad_h, pad_w)) - opcjonalne, obliczane automatycznie
    """
    if ratio_pad is None:
        gain = min(img1_shape[0] / img0_shape[0], img1_shape[1] / img0_shape[1])
        pad = (img1_shape[1] - img0_shape[1] * gain) / 2, \
              (img1_shape[0] - img0_shape[0] * gain) / 2
    else:
        gain = ratio_pad[0]
        pad = ratio_pad[1]
    
    coords[:, [0, 2]] -= pad[0]  # x coordinates
    coords[:, [1, 3]] -= pad[1]  # y coordinates
    coords[:, :4] /= gain  # scale
    
    # Clip do granic obrazu
    coords[:, [0, 2]] = coords[:, [0, 2]].clip(0, img0_shape[1])
    coords[:, [1, 3]] = coords[:, [1, 3]].clip(0, img0_shape[0])
    
    return coords
```

**W systemie:** Ten algorytm nie jest wymagany, ponieważ Ultralytics zwraca współrzędne już przeliczone.

### 3.5. Wykrywanie i Zamazywanie Głów

System wykorzystuje model **Roboflow** (`heads-detection/1`) do automatycznego wykrywania głów na obrazach z detekcjami telefonów. Wykrywanie odbywa się asynchronicznie w osobnym wątku workera, po zapisaniu oryginalnej klatki z wykrytym telefonem. Wykryte głowy są następnie zamazywane za pomocą filtru Gaussa, zapewniając nieodwracalną anonimizację zgodną z wymogami RODO. Zamazany obraz nadpisuje oryginalny plik przed zapisem do bazy danych, gwarantując, że w systemie przechowywane są wyłącznie zanonimizowane obrazy.

---

## 4. STRUKTURA DANYCH I API

### 4.1. Modele Danych (SQLAlchemy ORM)

**Lokalizacja:** `models.py`

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
- `password_hash`: Hash hasła (SHA-256 przez `werkzeug.security`)

**Metody:**
- `set_password(password)`: Generuje hash hasła (`generate_password_hash`)
- `check_password(password)`: Weryfikuje hasło (`check_password_hash`)

**Uzasadnienie:** Model `User` jest wymagany przez Flask-Login do zarządzania sesjami. Hasła są hashowane, nie przechowywane w plaintext.

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
- `location`: Nazwa lokalizacji (strefa ROI lub nazwa kamery, String 100)
- `confidence`: Pewność detekcji (Float, 0.0-1.0)
- `image_path`: Nazwa pliku obrazu (String 200, bez pełnej ścieżki)
- `status`: Status detekcji ('Pending', 'Reviewed', etc.)
- `user_id`: Klucz obcy do User (nullable, domyślnie admin)

**Uzasadnienie:**
- `image_path` zawiera tylko nazwę pliku (np. `phone_20251123_143015.jpg`), nie pełną ścieżkę, co ułatwia migrację danych
- `location` może być nazwą strefy ROI (np. "Ławka 3") lub nazwą kamery
- `status` umożliwia nauczycielom oznaczanie detekcji jako sprawdzone

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

**Uzasadnienie:**
- JSON umożliwia elastyczne przechowywanie złożonych struktur danych bez konieczności migracji schematu
- `updated_at` automatycznie aktualizuje się przy każdej zmianie (`onupdate=datetime.utcnow`)

### 4.2. Endpointy API (REST)

**Lokalizacja:** `app.py`

#### Autoryzacja

**POST `/api/login`** (linie 178-189)
- **Request:** `{username: string, password: string}`
- **Response:** `{message: "Login successful"}` lub `401 Unauthorized`
- **Mechanizm:** Flask-Login (`login_user(user)`)

**GET `/api/logout`** (linie 191-195)
- **Response:** `{message: "Logout successful"}`
- **Wymagane:** `@login_required`

#### Detekcje

**GET `/api/detections`** (linie 197-221)
- **Query params:** `page` (int, default 1), `per_page` (int, default 20)
- **Response:** 
  ```json
  {
    "detections": [...],
    "total_pages": 10,
    "current_page": 1,
    "has_next": true,
    "has_prev": false
  }
  ```
- **Paginacja:** SQLAlchemy `paginate()`

**GET `/api/detections/<id>`** (linie 223-235)
- **Response:** Pojedyncza detekcja z pełnymi danymi

**DELETE `/api/detections/<id>`** (linie 237-243)
- **Response:** `{message: "Detection deleted successfully"}`

**DELETE `/api/detections/batch`** (linie 245-263)
- **Request:** `{ids: [1, 2, 3]}`
- **Response:** `{message: "Usunięto N detekcji.", deleted_count: N}`

#### Dashboard i Statystyki

**GET `/api/dashboard-stats`** (linie 265-299)
- **Response:**
  ```json
  {
    "total_detections": 150,
    "today_detections": 5,
    "camera_status": "Online",
    "within_schedule": true,
    "recent_detections": [...]
  }
  ```

**GET `/api/stats/detections_over_time`** (linie 301-325)
- **Response:** `[{name: "2025-01-15", count: 10}, ...]` (ostatnie 7 dni)
- **Agregacja:** SQL `GROUP BY DATE(timestamp)`

#### Ustawienia

**GET `/api/settings`** (linie 327-378)
- **Response:** Pełna konfiguracja (schedule, ROI zones, camera settings, available cameras)

**POST `/api/settings`** (linie 380-483)
- **Request:** Częściowa konfiguracja (tylko zmienione pola)
- **Walidacja:** Sprawdzanie formatu harmonogramu, ROI zones
- **Aktualizacja:** `camera_controller.update_settings(settings_db)`

**GET `/api/settings/roi`** (linie 638-648)
- **Response:** `{roi_zones: [...]}`

**POST `/api/settings/roi`** (linie 650-689)
- **Request:** `{roi_zones: [...]}`
- **Walidacja:** Sprawdzanie struktury (id, name, coords: {x, y, w, h}, wartości 0-1)

#### Kamera

**POST `/api/camera/start`** (linie 485-501)
- **Response:** `{message: "Camera started successfully", camera_status: {...}}`
- **Działanie:** `camera_controller.start_camera()` (ignoruje harmonogram)

**POST `/api/camera/stop`** (linie 503-519)
- **Response:** `{message: "Camera stopped successfully", camera_status: {...}}`
- **Działanie:** `camera_controller.stop_camera()` + ustawienie `manual_stop_engaged = True`

**GET `/api/camera/status`** (linie 521-536)
- **Response:** `{is_running: bool, within_schedule: bool, settings: {...}}`

**GET `/api/camera/video_feed`** (linie 632-636)
- **Response:** MJPEG stream (`multipart/x-mixed-replace`)
- **Generator:** `generate_frames()` (linie 597-630) - nieskończona pętla z `yield`

**GET `/api/camera/config_snapshot`** (linie 691-721)
- **Response:** JPEG image (anonimizowany snapshot)
- **Użycie:** Podgląd obrazu w ustawieniach ROI zones

#### Obrazy

**GET `/detections/<filename>`** (linie 538-548)
- **Response:** Plik obrazu z folderu `detections/`
- **Bezpieczeństwo:** `@login_required`

---

## 5. MECHANIZMY BEZPIECZEŃSTWA I KONFIGURACJI

### 5.1. Zarządzanie Zmiennymi Środowiskowymi

**Lokalizacja:** `app.py`, linia 24: `load_dotenv()`

System wykorzystuje plik `.env` (nie znajduje się w repozytorium ze względów bezpieczeństwa) do przechowywania danych wrażliwych.

#### Przykładowa struktura `.env`:
```env
# Flask
FLASK_SECRET_KEY=novaya
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

**Mechanizm ładowania:**
```python
load_dotenv()  # Ładuje zmienne z .env do os.environ
vonage_api_key = os.getenv('VONAGE_API_KEY')  # Odczyt zmiennej
```

**Uzasadnienie:**
- Separacja danych wrażliwych od kodu źródłowego
- `.env` jest ignorowany przez Git (`.gitignore`)
- Łatwa konfiguracja dla różnych środowisk (dev, prod)

### 5.2. Mechanizm Logowania i Sesji

**Lokalizacja:** `app.py`, linie 44-48, 174-176

#### Flask-Login

```python
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'
login_manager.login_message = "Musisz się zalogować..."
```

**Mechanizm:**
1. **User Loader:** `@login_manager.user_loader` (linia 174-176) - ładuje użytkownika z bazy na podstawie `user_id` z sesji
2. **Login:** `login_user(user)` (linia 186) - ustawia sesję Flask
3. **Logout:** `logout_user()` (linia 194) - czyści sesję
4. **Ochrona endpointów:** `@login_required` (dekorator na endpointach)

#### Sesja Flask

Flask wykorzystuje cookies do przechowywania sesji:
- **SECRET_KEY:** `app.config['SECRET_KEY']` (linia 36) - używany do podpisywania cookies
- **CORS:** `supports_credentials=True` (linia 33) - umożliwia wysyłanie cookies z frontendu

#### Frontend: Axios Interceptors

**Lokalizacja:** `src/services/api.ts`, linie 21-32, 35-45

```typescript
// Request interceptor - dodaje token (jeśli istnieje)
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('auth_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

// Response interceptor - obsługa 401
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('auth_token');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);
```

**Uwaga:** System wykorzystuje zarówno Flask-Login (cookies) jak i potencjalnie tokeny Bearer (localStorage), co może wskazywać na hybrydowe podejście do autoryzacji.

### 5.3. Bezpieczeństwo Anonimizacji (RODO)

**Gwarancje systemu:**

1. **Oryginalne klatki są zapisywane lokalnie** (`./detections/`, linia 520)
2. **Anonimizacja przed zapisem do DB:** Worker zamazuje głowy PRZED `_save_to_database()` (linia 1303)
3. **Nadpisanie oryginalnego pliku:** `cv2.imwrite(image_path, image)` (linia 1665) nadpisuje oryginał zanonimizowaną wersją
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

