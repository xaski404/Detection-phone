# ZAKTUALIZOWANY FLOWCHART DZIAŁANIA SYSTEMU
## Wersja poprawiona - zgodna z obecną implementacją

---

## GŁÓWNA ŚCIEŻKA (Main Thread → Worker Thread)

```
┌─────────────────────────────────────────────────────────────────┐
│                    DZIAŁANIE SYSTEMU                            │
│              (Producer-Consumer Pattern)                        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│  MAIN THREAD (Producer) - Real-Time Detection (20-30 FPS)       │
└─────────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │  📷 CAMERA   │
    │  (OpenCV)    │
    │  1280x720    │
    └──────┬───────┘
           │
           │ Klatka wideo
           ▼
    ┌──────────────┐
    │  🔍 YOLOv8   │
    │  (Detection) │
    │  yolov8m.pt  │
    │  class_id=67 │
    └──────┬───────┘
           │
           │ Telefon wykryty
           │ (confidence ≥ 0.2)
           ▼
    ┌──────────────┐
    │  💾 SAVE     │
    │  (Original)  │
    │  ./detections│
    │  /phone_*.jpg│
    └──────┬───────┘
           │
           │ Dodanie do kolejki
           ▼
    ┌──────────────┐
    │  📤 QUEUE    │
    │  (Thread-Safe│
    │   Queue)     │
    └──────┬───────┘
           │
           │ Worker Thread
           │ (asynchronicznie)
           ▼

┌─────────────────────────────────────────────────────────────────┐
│  WORKER THREAD (Consumer) - Offline Anonymization (1-2s)        │
└─────────────────────────────────────────────────────────────────┘

    ┌──────────────┐
    │  👁️ ROBOFLOW │
    │  (Head       │
    │   Detection) │
    │  heads-      │
    │  detection/1 │
    │  (API)       │
    └──────┬───────┘
           │
           │ Głowy wykryte
           │ (confidence ≥ 40%)
           ▼
    ┌──────────────┐
    │  🔒 BLUR     │
    │  (Anonymiz.) │
    │  Gaussian    │
    │  99x99, σ=30 │
    └──────┬───────┘
           │
           │ Nadpisanie pliku
           │ zanonimizowaną wersją
           ▼
    ┌──────────────┐
    │  💾 DATABASE │
    │  (SQLite)    │
    │  Metadane +  │
    │  image_path  │
    └──────┬───────┘
           │
           │ Zapis metadanych
           │ (tylko zanonimizowane!)
           ▼
    ┌──────────────┐
    │  ☁️ CLOUDINARY│
    │  (Storage)   │
    │  Upload z    │
    │  pliku       │
    │  (opcjonalne)│
    └──────┬───────┘
           │
           │ Publiczny link
           ▼
    ┌──────────────┐
    │  📧 NOTIF.   │
    │  (Email+SMS) │
    │  Vonage +    │
    │  Yagmail     │
    └──────────────┘
```

---

## WERSJA UPROSZCZONA (Dla prezentacji)

```
┌─────────────────────────────────────────────────────────────────┐
│                    DZIAŁANIE SYSTEMU                            │
└─────────────────────────────────────────────────────────────────┘

MAIN THREAD (Real-Time):
    📷 CAMERA
       │
       ▼
    🔍 YOLOv8 (Detection)
       │
       ▼
    💾 SAVE (Original)
       │
       ▼
    📤 QUEUE

WORKER THREAD (Async):
    👁️ ROBOFLOW (heads-detection/1)
       │
       ▼
    🔒 BLUR (Gaussian 99x99)
       │
       ▼
    💾 DATABASE (SQLite)
       │
       ▼
    ☁️ CLOUDINARY
       │
       ▼
    📧 NOTIFICATIONS (Email + SMS)
```

---

## WERSJA Z CZASEM WYKONANIA

```
┌─────────────────────────────────────────────────────────────────┐
│                    DZIAŁANIE SYSTEMU                            │
│              Z czasem wykonania (przybliżonym)                 │
└─────────────────────────────────────────────────────────────────┘

MAIN THREAD (0-45ms):
    📷 CAMERA              [0ms]
       │
       ▼
    🔍 YOLOv8              [30ms]  ← Preprocessing + Detection
       │
       ▼
    💾 SAVE (Original)     [40ms]  ← Zapis do pliku
       │
       ▼
    📤 QUEUE               [45ms]  ← Dodanie do kolejki
       │
       │ ⚡ Główna pętla kontynuuje (20-30 FPS)
       │   Nie czeka na worker!

WORKER THREAD (100-1050ms):
    👁️ ROBOFLOW            [800ms] ← API call (asynchronicznie)
       │
       ▼
    🔒 BLUR                [850ms] ← Gaussian blur
       │
       ▼
    💾 DATABASE            [900ms] ← Zapis metadanych
       │
       ▼
    ☁️ CLOUDINARY          [1000ms]← Upload (opcjonalnie)
       │
       ▼
    📧 NOTIFICATIONS       [1050ms]← Email + SMS
```

---

## KLUCZOWE POPRAWKI W STOSUNKU DO OBRAZKA:

### ✅ Poprawione:
1. **ROBOFLOW (H66s)** → **ROBOFLOW (heads-detection/1)** ✅
2. **Dodano oznaczenia wątków:** Main Thread vs Worker Thread ✅
3. **Dodano szczegóły techniczne:** yolov8m.pt, class_id=67, confidence thresholds ✅
4. **Wyjaśniono kolejność:** Cloudinary uploaduje z pliku, nie z bazy ✅
5. **Dodano informacje o czasie:** Pokazuje, że detekcja nie jest blokowana ✅

### 📋 Elementy zgodne z obrazkiem:
- ✅ Główna ścieżka (CAMERA → YOLOv8 → SAVE → QUEUE → ROBOFLOW → BLUR → DATABASE)
- ✅ Ścieżka powiadomień (DATABASE → CLOUDINARY → NOTIFICATIONS)
- ✅ Kolejność operacji
- ✅ Wizualizacja przepływu danych

---

## WERSJA DO POWERPOINT/GOOGLE SLIDES

### Tytuł: "DZIAŁANIE SYSTEMU"

### Lewa strona - Flowchart:

**Górny rząd (Main Thread):**
- 📷 CAMERA (OpenCV)
- 🔍 YOLOv8 (Detection, yolov8m.pt)
- 💾 SAVE (Original)
- 📤 QUEUE (Thread-Safe)

**Środkowy rząd (Worker Thread):**
- 👁️ ROBOFLOW (heads-detection/1)
- 🔒 BLUR (Gaussian 99x99)
- 💾 DATABASE (SQLite)

**Dolny rząd (Notifications):**
- ☁️ CLOUDINARY (Storage)
- 📧 NOTIFICATIONS (Email + SMS)

### Prawa strona - Opisy (4 boxy):

**BOX 1: Wykrywanie Smartfonów**
- System analizuje obraz w czasie rzeczywistym (20-30 FPS)
- Wykorzystuje YOLOv8 (yolov8m.pt) do detekcji telefonów
- Preprocessing obrazu (CLAHE, unsharp masking) dla lepszej jakości

**BOX 2: Anonimizacja Głów (RODO)**
- Wykrywanie głów przez Roboflow API (heads-detection/1, dokładność >90%)
- Zamazywanie głów filtrem Gaussa (kernel 99x99, sigma=30)
- Nieodwracalna anonimizacja - tylko zanonimizowane obrazy w bazie

**BOX 3: Powiadomienia**
- Upload obrazu na Cloudinary (opcjonalnie)
- Email z osadzonym zanonimizowanym zdjęciem
- SMS z linkiem do obrazu i informacjami o detekcji
- Per-zone muting (5 minut) zapobiega spamowi

**BOX 4: Przetwarzanie w czasie rzeczywistym**
- Wzorzec Producer-Consumer z wielowątkowością
- Main Thread: detekcja w czasie rzeczywistym (0-45ms)
- Worker Thread: anonimizacja asynchronicznie (1-2s)
- Detekcja nie jest blokowana przez anonimizację

---

## SUGEROWANE KOLORY:

- **CAMERA:** Niebieski (#2196F3)
- **YOLOv8:** Pomarańczowy (#FF9800)
- **SAVE:** Zielony (#4CAF50)
- **QUEUE:** Żółty (#FFC107)
- **ROBOFLOW:** Turkusowy (#00BCD4)
- **BLUR:** Czerwony (#F44336)
- **DATABASE:** Fioletowy (#9C27B0)
- **CLOUDINARY:** Niebieski (#00A8E8)
- **NOTIFICATIONS:** Pomarańczowy (#FF9800)

---

*Zaktualizowany flowchart zgodny z obecną wersją systemu*






