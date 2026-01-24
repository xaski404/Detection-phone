# INFORMACJE DO ROZDZIAŁU 4 - IMPLEMENTACJA

## 1. DIAGRAM ARCHITEKTURY SYSTEMU

Diagram architektury został utworzony w pliku `system_architecture_diagram.txt`. 
Możesz go przekonwertować na obraz PNG używając narzędzi takich jak:
- draw.io (zaimportuj tekst i wyeksportuj jako PNG)
- Online ASCII to Image converters
- Lub ręcznie narysuj w draw.io na podstawie struktury

**Struktura architektury:**
```
Frontend (React) 
    ↓ HTTP/REST API
Backend (Flask)
    ├── CameraController (Main Thread - Producer)
    │   └── AnonymizerWorker (Worker Thread - Consumer)
    └── Database (SQLite)
```

**Kluczowe komponenty:**
- **Frontend:** React + TypeScript + Material-UI
- **Backend:** Flask + Python
- **CameraController:** Główna pętla detekcji (Producer)
- **AnonymizerWorker:** Asynchroniczna anonimizacja (Consumer)
- **Database:** SQLite z SQLAlchemy ORM

---

## 2. SCHEMAT BAZY DANYCH

### Tabela `Detection` - PEŁNA STRUKTURA

**Plik:** `models.py`, linie 33-40

```python
class Detection(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    timestamp = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    location = db.Column(db.String(100))      # Nazwa strefy ROI lub kamery
    confidence = db.Column(db.Float)         # Pewność detekcji (0.0-1.0)
    image_path = db.Column(db.String(200))   # Nazwa pliku obrazu (np. "phone_20250101_120000.jpg")
    status = db.Column(db.String(20))        # Status detekcji (np. "Pending")
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=True)
```

**Wszystkie kolumny:**
1. `id` - Integer, Primary Key
2. `timestamp` - DateTime, NOT NULL, default=datetime.utcnow
3. `location` - String(100), nullable - Nazwa strefy ROI (np. "Ławka 3") lub nazwa kamery
4. `confidence` - Float, nullable - Pewność detekcji YOLOv8 (0.0-1.0)
5. `image_path` - String(200), nullable - Nazwa pliku obrazu w folderze `detections/`
6. `status` - String(20), nullable - Status detekcji (domyślnie "Pending")
7. `user_id` - Integer, Foreign Key do `user.id`, nullable

**Dodatkowe tabele:**

### Tabela `User`
```python
class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
```

### Tabela `Settings`
```python
class Settings(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    schedule = db.Column(db.JSON, nullable=False, default=DEFAULT_SCHEDULE)
    roi_zones = db.Column(db.JSON, nullable=False, default=lambda: [])
    config = db.Column(db.JSON, nullable=False, default={...})
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)
```

---

## 3. WERYFIKACJA LISTINGÓW KODU

### ✅ Funkcja `generate_frames()` - ZGODNA

**W pliku LISTINGI_KODU_ROZDZIAL_IMPLEMENTACJA.md:**
- Linie 147-180: Listing funkcji `generate_frames()`

**W rzeczywistym kodzie (`app.py`):**
- Linie 597-630: Funkcja `generate_frames()` - **ZGODNA**

**Różnice (drobne):**
- W rzeczywistym kodzie jest więcej obsługi błędów (try-except)
- W rzeczywistym kodzie jest `logger.debug()` zamiast komentarzy
- **Funkcjonalność jest identyczna** - generator MJPEG stream z filtrem Canny

**Rekomendacja:** Listing w pracy jest uproszczony, ale poprawny. Możesz go zostawić lub dodać więcej obsługi błędów.

---

### ⚠️ Funkcja `worker()` - WYMAGA POPRAWKI

**W pliku LISTINGI_KODU_ROZDZIAL_IMPLEMENTACJA.md:**
- **BRAK** funkcji `worker()` w listingach!

**W rzeczywistym kodzie (`camera_controller.py`):**
- Klasa: `AnonymizerWorker` (dziedziczy po `threading.Thread`)
- Metoda: `run()` (linie 1261-1338) - to jest odpowiednik `worker()`

**Rekomendacja:** Dodaj listing funkcji `run()` z klasy `AnonymizerWorker`:

```python
def run(self):
    """Główna pętla workera - przetwarza zadania z kolejki"""
    while self.is_running:
        try:
            task_data = self.detection_queue.get(timeout=1)
            
            if task_data is None:
                self.detection_queue.task_done()
                break
            
            filepath = task_data.get('filepath')
            confidence = task_data.get('confidence', 0.0)
            zone_name = task_data.get('zone_name')
            should_blur = task_data.get('should_blur', True)
            
            # Anonimizacja głów (jeśli włączona)
            if should_blur:
                success = self._anonymize_faces(filepath)
                if success:
                    self.tasks_processed += 1
            
            # Zapis do bazy danych
            self._save_to_database(task_data)
            
            # Powiadomienia (Email/SMS) - asynchronicznie
            if self.email_enabled or self.sms_enabled:
                notification_thread = threading.Thread(
                    target=self._handle_cloud_notification,
                    args=(filepath, confidence, zone_name),
                    daemon=True
                )
                notification_thread.start()
            
            self.detection_queue.task_done()
            
        except Exception as e:
            logging.error(f"Error in AnonymizerWorker: {e}")
            try:
                self.detection_queue.task_done()
            except:
                pass
```

**Lokalizacja w kodzie:** `camera_controller.py`, klasa `AnonymizerWorker`, metoda `run()`, linie 1261-1338

---

## 4. PODSUMOWANIE ZMIAN DO WPROWADZENIA

### ✅ Co jest OK:
1. ✅ `generate_frames()` - listing jest zgodny z kodem
2. ✅ Struktura bazy danych - wszystkie kolumny są uwzględnione
3. ✅ Diagram architektury - struktura jest poprawna

### ⚠️ Co wymaga poprawki:
1. ⚠️ **Dodaj listing funkcji `AnonymizerWorker.run()`** - to jest odpowiednik `worker()` w Twoim projekcie
2. ⚠️ W sekcji 4.3 (Baza danych) upewnij się, że wszystkie 7 kolumn tabeli `Detection` są wymienione

### 📝 Sugestie:
1. W sekcji o `generate_frames()` możesz wspomnieć, że funkcja używa filtru Canny dla prywatności (pokazuje tylko krawędzie, nie pełny obraz)
2. W sekcji o Producer-Consumer podkreśl, że `AnonymizerWorker.run()` jest metodą wątku roboczego, która przetwarza zadania z kolejki

---

## 5. DODATKOWE INFORMACJE

### Endpointy API (dla sekcji 4.2):
- `GET /api/camera/video_feed` - Strumieniowanie MJPEG (używa `generate_frames()`)
- `GET /api/detections` - Lista detekcji z paginacją
- `POST /api/settings` - Aktualizacja konfiguracji
- `GET /api/dashboard-stats` - Statystyki w czasie rzeczywistym

### Wzorce projektowe:
- **Producer-Consumer:** `CameraController` (Producer) → `Queue` → `AnonymizerWorker` (Consumer)
- **Singleton:** Globalne instancje modeli YOLOv8 i Roboflow
- **Repository Pattern:** SQLAlchemy ORM jako warstwa dostępu do danych

---

**Data weryfikacji:** 2025-01-XX
**Wersja kodu:** Detection-phone (główny folder projektu)

